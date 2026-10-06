QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Resume = {}
QS.Resume = Resume

local function HasQuest(step, questID)
    if step.questID == questID then
        return true
    end
    local ids = step.questIDs
    if ids then
        for i = 1, #ids do
            if ids[i] == questID then
                return true
            end
        end
    end
    return false
end

local function QuestDone(log, questID)
    if not questID then
        return false
    end
    if log.completed[questID] then
        return true
    end
    return QS.Api.NoteIfFlagged(log, questID)
end

local function InLog(log, questID)
    return questID and log.inLog[questID] ~= nil
end

local function ObjectiveDone(log, step)
    local questID = step.questID
    if QuestDone(log, questID) then
        return true
    end
    local info = questID and log.inLog[questID]
    if not info then
        return false
    end
    if info.complete then
        return true
    end
    local objs = info.objectives
    if step.objective and objs[step.objective] then
        return objs[step.objective].finished and true or false
    end
    if #objs == 0 then
        return false
    end
    for i = 1, #objs do
        if not objs[i].finished then
            return false
        end
    end
    return true
end

local function AllLoggedOrDone(log, ids)
    for i = 1, #ids do
        local id = ids[i]
        if not InLog(log, id) and not QuestDone(log, id) then
            return false
        end
    end
    return true
end

local function AllTurnedIn(log, ids)
    for i = 1, #ids do
        if not QuestDone(log, ids[i]) then
            return false
        end
    end
    return true
end

function Resume.ZoneMatch(step)
    if not step.completeOnZone then
        return false
    end
    local zone = GetZoneText() or ""
    local real = GetRealZoneText and GetRealZoneText() or ""
    return zone == step.completeOnZone or real == step.completeOnZone or zone == step.zone
end

function Resume.Done(step, log)
    if not step or not log then
        return false
    end
    local kind = step.kind
    if kind == "accept" then
        if step.questIDs then
            return AllLoggedOrDone(log, step.questIDs)
        end
        return InLog(log, step.questID) or QuestDone(log, step.questID)
    end
    if kind == "objective" then
        return ObjectiveDone(log, step)
    end
    if kind == "turnin" or kind == "hearth" or kind == "train" then
        if step.questIDs then
            return AllTurnedIn(log, step.questIDs)
        end
        return QuestDone(log, step.questID)
    end
    if kind == "dungeon" then
        if step.questIDs and not AllTurnedIn(log, step.questIDs) then
            return false
        end
        if step.bisRequired and step.bisItemID and not QS.Bis.PlayerHas(step.bisItemID) then
            return false
        end
        if step.questIDs then
            return true
        end
        return false
    end
    if kind == "travel" or kind == "fly" or kind == "note" then
        return Resume.ZoneMatch(step)
    end
    return false
end

function Resume.FirstOpen(steps, log, skips)
    for i = 1, #steps do
        local step = steps[i]
        if not skips[step.id] and not Resume.Done(step, log) then
            return i
        end
    end
    return nil
end

local function Find(steps, id)
    if not id then
        return nil
    end
    for i = 1, #steps do
        if steps[i].id == id then
            return i
        end
    end
    return nil
end

function Resume.Choose(steps, log, char)
    local skips = char.skips or {}
    local frontier = Resume.FirstOpen(steps, log, skips)
    local manual = char.manualStepId
    if manual then
        local mi = Find(steps, manual)
        if not mi then
            char.manualStepId = nil
            char.manualFrontierId = nil
        else
            local old = Find(steps, char.manualFrontierId)
            if frontier and old and frontier > old and frontier > mi then
                char.manualStepId = nil
                char.manualFrontierId = nil
                return frontier
            end
            return mi
        end
    end
    return frontier
end

function Resume.PullForward(steps, log, skips)
    local index = Resume.FirstOpen(steps, log, skips)
    if not index or not steps[index] then
        return
    end
    local allow = {}
    local seen = {}
    local found = 0
    for i = index, #steps do
        local cluster = steps[i].cluster
        if cluster and not seen[cluster] then
            seen[cluster] = true
            allow[cluster] = true
            found = found + 1
            if found == 2 then
                break
            end
        end
    end
    local function blocked(idx, questID)
        for i = 1, idx - 1 do
            local earlier = steps[i]
            if HasQuest(earlier, questID) and not skips[earlier.id] and not Resume.Done(earlier, log) then
                return true
            end
        end
        return false
    end
    local head, moved, tail = {}, {}, {}
    for i = 1, #steps do
        local step = steps[i]
        local questID = step.questID
        local take = i > index
            and step.cluster and allow[step.cluster]
            and questID and log.inLog[questID]
            and not skips[step.id]
            and not Resume.Done(step, log)
            and not blocked(i, questID)
        if i < index then
            head[#head + 1] = step
        elseif take then
            moved[#moved + 1] = step
        else
            tail[#tail + 1] = step
        end
    end
    if #moved == 0 then
        return
    end
    local n = 0
    for i = 1, #head do
        n = n + 1
        steps[n] = head[i]
    end
    for i = 1, #moved do
        n = n + 1
        steps[n] = moved[i]
    end
    for i = 1, #tail do
        n = n + 1
        steps[n] = tail[i]
    end
    for i = n + 1, #steps do
        steps[i] = nil
    end
end

function Resume.Next()
    local route = QS.route
    local char = QS.char
    if not route or not route.index or not char then
        return
    end
    local step = route.steps[route.index]
    if not step then
        return
    end
    char.skips[step.id] = true
    char.manualStepId = nil
    char.manualFrontierId = nil
    QS:Rebuild()
end

function Resume.Back()
    local route = QS.route
    local char = QS.char
    if not route or not route.index or route.index <= 1 or not char then
        return
    end
    local prev = route.steps[route.index - 1]
    char.skips[prev.id] = nil
    local log = route.log or QS.Api.Snapshot()
    local frontier = Resume.FirstOpen(route.steps, log, char.skips)
    char.manualStepId = prev.id
    char.manualFrontierId = frontier and route.steps[frontier] and route.steps[frontier].id or nil
    QS:Rebuild()
end

function Resume.UnskipCurrent()
    local route = QS.route
    local char = QS.char
    if not route or not route.index or not char then
        return
    end
    local step = route.steps[route.index]
    if step then
        char.skips[step.id] = nil
    end
    char.manualStepId = nil
    char.manualFrontierId = nil
    QS:Rebuild()
end

function Resume.Reset()
    local char = QS.char
    char.skips = {}
    char.manualStepId = nil
    char.manualFrontierId = nil
    QS:Print("Skips cleared. Resuming from the quest log.")
    QS:Rebuild()
end

function Resume.Where()
    local route = QS.route
    if not route or not route.index then
        QS:Print("No current step. Data " .. QS.DATA_VERSION)
        return
    end
    local step = route.steps[route.index]
    local quest = step.questID and (" quest " .. step.questID) or " no quest id"
    local ids = ""
    if step.questIDs then
        ids = " quests"
        for i = 1, #step.questIDs do
            ids = ids .. " " .. step.questIDs[i]
        end
    end
    QS:Print(string.format(
        "%s · %s · %s · %s%s%s · %s",
        step.id,
        step.kind,
        step.zone or "?",
        step.confidence or "?",
        quest,
        ids,
        QS.DATA_VERSION
    ))
end

function Resume.Status(step, log, measure)
    if not step then
        return "Ready"
    end
    local char = QS.char
    if char and char.manualStepId == step.id and Resume.Done(step, log) then
        return "Already done"
    end
    if step.kind == "dungeon" then
        if step.bisRequired and step.bisItemID and not QS.Bis.PlayerHas(step.bisItemID) then
            local questsDone = true
            if step.questIDs then
                for i = 1, #step.questIDs do
                    if not (log.completed[step.questIDs[i]]) then
                        questsDone = false
                    end
                end
            end
            if questsDone then
                return "BiS still missing"
            end
        end
        return "Dungeon"
    end
    if step.kind == "turnin" or step.kind == "hearth" or step.kind == "train" then
        local info = step.questID and log.inLog[step.questID]
        if (info and info.complete) or (measure and measure.mode == "ok" and measure.yards and measure.yards < 8) then
            return "Turn in"
        end
    end
    if measure and measure.mode == "instance" then
        return "Dungeon"
    end
    if measure and measure.mode == "ok" and measure.yards and measure.yards < 8 then
        return "In range"
    end
    if measure and measure.mode == "ok" then
        return "Walking"
    end
    return "Ready"
end
