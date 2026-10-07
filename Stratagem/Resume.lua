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

local function TitleInLog(log, title)
    if not title or not log or not log.inLog then
        return false
    end
    local want = string.lower(title)
    for _, info in pairs(log.inLog) do
        if info.title and string.lower(info.title) == want then
            return true
        end
    end
    return false
end

function Resume.FlightKnown(char, label)
    if not char or not label or type(char.flights) ~= "table" then
        return false
    end
    if char.flights[label] then
        return true
    end
    if char.flights["zone:" .. label] then
        return true
    end
    local want = string.lower(label)
    for name in pairs(char.flights) do
        if type(name) == "string" then
            local lower = string.lower(name)
            if lower == want or string.find(lower, want, 1, true) then
                return true
            end
        end
    end
    return false
end

local function ObjectiveSkipped(step, obj)
    if not obj or not QS.Area or not QS.Area.GoalKey then
        return false
    end
    local checks = QS.char and QS.char.goalChecks
    if type(checks) ~= "table" then
        return false
    end
    local key = QS.Area.GoalKey(step, {
        name = obj.text,
        questID = step.questID,
    })
    return key and checks[key] and true or false
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
        local obj = objs[step.objective]
        if obj.finished or ObjectiveSkipped(step, obj) then
            return true
        end
        return false
    end
    if #objs == 0 then
        return false
    end
    for i = 1, #objs do
        local obj = objs[i]
        if not obj.finished and not ObjectiveSkipped(step, obj) then
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
    if QS.char and QS.char.assumeZone == step.completeOnZone then
        return true
    end
    local zone = GetZoneText() or ""
    local real = GetRealZoneText and GetRealZoneText() or ""
    return zone == step.completeOnZone or real == step.completeOnZone or zone == step.zone
end

local function IsPocket(step)
    if step and step.pocket then
        return true
    end
    local id = step and step.id
    return type(id) == "string" and string.sub(id, 1, 16) == "dyn-area-pocket-"
end

function Resume.Done(step, log)
    if not step or not log then
        return false
    end
    if step.levelDefer then
        return true
    end
    if QS.Level and QS.Level.IsGrey(step) then
        return true
    end
    local kind = step.kind
    local pocket = kind == "area" and IsPocket(step)
    local campHand = kind == "turnin" and step.handIn and true or false
    -- A checked objective counts. Steps that are not a camp or a camp
    -- hand-in still finish the old way when the checkbox is not the reason.
    if not pocket and not campHand then
        if QS.Area and QS.Area.GoalsComplete and QS.Area.GoalsComplete(step) then
            return true
        end
    end
    if kind == "area" then
        local ids = step.questIDs
        if not ids or #ids == 0 then
            return false
        end
        -- A camp stays up while any objective is open. Checking the box
        -- completes that objective. When every one is done, the turn-in
        -- is next. An older snapshot may not have copied the pocket field.
        if pocket then
            if step.goals and #step.goals > 0 and QS.Area and QS.Area.GoalsComplete then
                return QS.Area.GoalsComplete(step)
            end
            for i = 1, #ids do
                local info = log.inLog[ids[i]]
                if info and not (QS.Area and QS.Area.Ready and QS.Area.Ready(info)) then
                    return false
                end
            end
            return true
        end
        for i = 1, #ids do
            if log.inLog[ids[i]] then
                return false
            end
        end
        return true
    end
    if kind == "kills" then
        local level = UnitLevel("player") or 1
        if level > (step.atLevel or level) then
            return true
        end
        local xp = UnitXP("player") or 0
        if step.xpMark and level == step.atLevel and xp >= step.xpMark then
            return true
        end
        return false
    end
    if kind == "hearth" and not step.questID then
        local place = QS.Api.Place()
        if step.hearthUse then
            return place.zone == step.zone or place.real == step.zone or place.sub == step.bind
        end
        return QS.Api.BindLocation() == step.bind
    end
    if kind == "talent" then
        local unspent = QS.Api.UnspentTalents() or 0
        if step.unspentAt and unspent < step.unspentAt then
            return true
        end
        local rank = step.talentName and QS.Api.TalentRank(step.talentName)
        if rank and step.talentRank and rank >= step.talentRank then
            return true
        end
        return false
    end
    if kind == "vendor" then
        if step.wantSell and QS.Api.FreeSlots() <= 3 then
            return false
        end
        if step.wantRepair and QS.Api.DurabilityRatio() < 0.25 then
            return false
        end
        return true
    end
    if kind == "boss" then
        return QS.char and QS.char.bossDown and step.boss and QS.char.bossDown[step.boss] and true or false
    end
    if kind == "craft" then
        if step.product and QS.Api.ItemCount(step.product) > (step.productAt or 0) then
            return true
        end
        local skill = QS.Api.Skill(step.profession)
        if skill and step.rankAt and skill.rank > step.rankAt then
            return true
        end
        return false
    end
    if kind == "proftrain" then
        local skill = QS.Api.Skill(step.profession)
        if skill and step.maxAt and skill.max > step.maxAt then
            return true
        end
        return false
    end
    if kind == "classtrain" then
        local trained = QS.char and QS.char.trainedLevel or 0
        return trained >= (step.trainAt or 1)
    end
    if kind == "accept" then
        if step.questIDs then
            return AllLoggedOrDone(log, step.questIDs)
        end
        if step.questName and TitleInLog(log, step.questName) then
            return true
        end
        if not step.questID then
            return false
        end
        return InLog(log, step.questID) or QuestDone(log, step.questID)
    end
    if kind == "flight" then
        return Resume.FlightKnown(QS.char, step.flight)
    end
    if kind == "weapon" or kind == "armor" or kind == "dual" or kind == "opportunity" then
        return false
    end
    if kind == "objective" then
        return ObjectiveDone(log, step)
    end
    if campHand and step.goals and #step.goals > 0 and QS.Area and QS.Area.GoalsComplete then
        return QS.Area.GoalsComplete(step)
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
            local held = steps[mi]
            -- A finished step does not stay pinned. Back can still review it.
            if held.levelDefer or Resume.Done(held, log) or (QS.Level and QS.Level.IsGrey(held)) then
                char.manualStepId = nil
                char.manualFrontierId = nil
                return frontier
            end
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

local function IsAreaFamily(step)
    local id = step and step.id
    return type(id) == "string" and string.sub(id, 1, 9) == "dyn-area-"
end

local SNAP_KEYS = {
    "id", "title", "text", "zone", "placeName", "mapID", "x", "y", "pin", "npc", "kind",
    "questID", "questName", "cluster", "goalHeader", "areaTurnin",
    "confidence", "where", "completeOnZone",
    "pocket", "handIn", "turnInAt", "logZone",
}

local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12|t "

function Resume.Caption(step)
    if not step then
        return "Stratagem"
    end
    if step.kind == "travel" or step.kind == "fly" then
        return step.title or "Travel"
    end
    local where = step.placeName
    if not where or where == "" then
        where = step.zone
    end
    if where and step.npc and where ~= step.npc then
        return where .. " · " .. step.npc
    end
    if step.title and step.title ~= "" then
        return step.title
    end
    return where or "Stratagem"
end

local function TrimCaption(text, limit)
    if not text or text == "" then
        return "Step"
    end
    if #text <= limit then
        return text
    end
    return string.sub(text, 1, limit - 3) .. "..."
end

local LINE_BUDGET = 50

local function DisplayLen(text)
    local n = 0
    local i = 1
    while i <= #text do
        if string.sub(text, i, i + 1) == "|T" then
            local close = string.find(text, "|t", i, true)
            if not close then
                n = n + (#text - i + 1)
                break
            end
            n = n + 2
            i = close + 2
        else
            n = n + 1
            i = i + 1
        end
    end
    return n
end

local function FitPiece(text, limit, marked)
    local mark = marked and CHECK or ""
    local room = limit - DisplayLen(mark)
    if room < 1 then
        return mark
    end
    return mark .. TrimCaption(text, room)
end

function Resume.Trail(char, step, log)
    local items = {}
    local hist = char and char.history
    local viewId = step and step.id
    local last = 0
    if type(hist) == "table" then
        last = #hist
        if step and step.review and char.historyAt then
            last = char.historyAt - 1
        end
        if last > #hist then
            last = #hist
        end
        if last < 0 then
            last = 0
        end
    end
    local seen = {}
    if type(hist) == "table" then
        for i = 1, last do
            local row = hist[i]
            if row.id and row.id ~= viewId and not seen[row.id] then
                seen[row.id] = true
                if log and Resume.Done(row, log) then
                    items[#items + 1] = {
                        text = Resume.Caption(row),
                        done = true,
                    }
                end
            end
        end
    end
    while #items > 2 do
        table.remove(items, 1)
    end
    if step then
        local done = false
        if step.review and log and Resume.Done(step, log) then
            done = true
        end
        items[#items + 1] = {
            text = Resume.Caption(step),
            done = done,
            view = true,
        }
    end
    return items
end

function Resume.RouteLine(char, step, log)
    local items = Resume.Trail(char, step, log)
    if #items == 0 then
        return "Stratagem"
    end
    local view = items[#items]
    local parts = { FitPiece(view.text, LINE_BUDGET, view.done) }
    local used = DisplayLen(parts[1])
    for i = #items - 1, 1, -1 do
        local room = LINE_BUDGET - used - 2
        if room < 8 then
            break
        end
        local piece = FitPiece(items[i].text, room, items[i].done)
        if DisplayLen(piece) > room then
            break
        end
        parts[#parts + 1] = piece
        used = used + 2 + DisplayLen(piece)
    end
    return table.concat(parts, "  ")
end

local function CopyGoals(step)
    if not step.goals then
        return nil
    end
    local goals = {}
    for i = 1, #step.goals do
        local goal = step.goals[i]
        goals[i] = {
            name = goal.name,
            have = goal.have,
            need = goal.need,
            count = goal.count,
            questID = goal.questID,
        }
    end
    return goals
end

local function CopyIds(step)
    if not step.questIDs then
        return nil
    end
    local ids = {}
    for i = 1, #step.questIDs do
        ids[i] = step.questIDs[i]
    end
    return ids
end

function Resume.Snapshot(step)
    local copy = {}
    for i = 1, #SNAP_KEYS do
        local key = SNAP_KEYS[i]
        copy[key] = step[key]
    end
    local goals = CopyGoals(step)
    if goals then
        copy.goals = goals
    end
    local ids = CopyIds(step)
    if ids then
        copy.questIDs = ids
    end
    return copy
end

function Resume.Remember(char, step)
    if not char or not step or step.review or not step.id then
        return
    end
    if type(char.history) ~= "table" then
        char.history = {}
    end
    local last = char.history[#char.history]
    if last and last.id == step.id then
        local goals = CopyGoals(step)
        if goals then
            last.goals = goals
        end
        local ids = CopyIds(step)
        if ids then
            last.questIDs = ids
        end
        if step.title then
            last.title = step.title
        end
        if step.text then
            last.text = step.text
        end
        if step.pocket then
            last.pocket = step.pocket
        end
        if step.handIn then
            last.handIn = step.handIn
        end
        if step.turnInAt then
            last.turnInAt = step.turnInAt
        end
        if step.mapID and step.x and step.y then
            last.mapID = step.mapID
            last.x = step.x
            last.y = step.y
            last.pin = step.pin
        end
        if step.zone then
            last.zone = step.zone
        end
        if step.logZone then
            last.logZone = step.logZone
        end
        if step.placeName then
            last.placeName = step.placeName
        end
        if char.pendingClear and char.pendingClear.id == step.id then
            last.clear = char.pendingClear.clear
            char.pendingClear = nil
        end
        if char.pendingPocket then
            last.pocketSkip = char.pendingPocket
            char.pendingPocket = nil
        end
        return
    end
    local snap = Resume.Snapshot(step)
    if char.pendingClear and char.pendingClear.id == step.id then
        snap.clear = char.pendingClear.clear
        char.pendingClear = nil
    end
    if char.pendingPocket then
        snap.pocketSkip = char.pendingPocket
        char.pendingPocket = nil
    end
    char.history[#char.history + 1] = snap
    while #char.history > 20 do
        table.remove(char.history, 1)
    end
end

local function LiveStepId()
    local route = QS.route
    if not route then
        return nil
    end
    return route.liveId or route.stepId
end

-- A single quest saved before that camp's turn-ins were one step.
local function CoveredHandIn(row)
    if not row or type(row.id) ~= "string" then
        return false
    end
    local steps = QS.route and QS.route.steps
    if not steps then
        return false
    end
    for i = 1, #steps do
        local step = steps[i]
        if step.handIn and type(step.id) == "string" and row.id ~= step.id then
            if string.sub(row.id, 1, #step.id + 1) == step.id .. "-" then
                return true
            end
        end
    end
    return false
end

local function PreviousAt(char, from)
    local live = LiveStepId()
    local at = from or 0
    while at >= 1 do
        local row = char.history[at]
        local liveRow = live and row and row.id == live
        if row and not liveRow and not CoveredHandIn(row) then
            return at
        end
        at = at - 1
    end
    return nil
end

function Resume.CanBack(char)
    char = char or QS.char
    if not char or type(char.history) ~= "table" then
        return false
    end
    local from = #char.history
    if char.historyAt then
        from = char.historyAt - 1
    end
    return PreviousAt(char, from) ~= nil
end

local function RememberBack(char, shown, clear)
    if type(char.stepBack) ~= "table" then
        char.stepBack = {}
    end
    char.stepBack[#char.stepBack + 1] = { id = shown, clear = clear }
    while #char.stepBack > 20 do
        table.remove(char.stepBack, 1)
    end
end

local function Hold(char, steps, log, id)
    char.manualStepId = id
    local frontier = Resume.FirstOpen(steps, log, char.skips)
    char.manualFrontierId = frontier and steps[frontier] and steps[frontier].id or nil
end

local ReleaseSkip

function Resume.Next()
    local route = QS.route
    local char = QS.char
    if not char then
        return
    end
    if char.historyAt then
        local nxt = char.historyAt + 1
        local live = LiveStepId()
        while nxt <= #char.history do
            local row = char.history[nxt]
            if live and row and row.id == live then
                nxt = #char.history + 1
            elseif not CoveredHandIn(row) then
                char.historyAt = nxt
                ReleaseSkip(char, row)
                QS:Rebuild()
                return
            else
                nxt = nxt + 1
            end
        end
        char.historyAt = nil
        char.manualStepId = nil
        char.manualFrontierId = nil
        QS:Rebuild()
        return
    end
    if not route or not route.index then
        return
    end
    local step = route.steps[route.index]
    if not step then
        return
    end
    local clear = {}
    if step.kind == "travel" and step.completeOnZone then
        -- Next on the flight means you are in the destination. The pockets stay.
        char.assumeZone = step.completeOnZone
    else
        char.skips[step.id] = true
        clear[1] = step.id
        if step.pocket then
            if type(char.skipPockets) ~= "table" then
                char.skipPockets = {}
            end
            char.skipPockets[step.pocket] = true
            char.pendingPocket = step.pocket
        elseif IsAreaFamily(step) and step.cluster then
            for i = 1, #route.steps do
                local other = route.steps[i]
                if other.id ~= step.id and other.cluster == step.cluster and IsAreaFamily(other) and not other.pocket then
                    char.skips[other.id] = true
                    clear[#clear + 1] = other.id
                end
            end
        end
    end
    RememberBack(char, step.id, clear)
    char.pendingClear = { id = step.id, clear = clear }
    char.historyAt = nil
    char.manualStepId = nil
    char.manualFrontierId = nil
    QS:Rebuild()
end

function ReleaseSkip(char, snap)
    if not snap or type(snap.clear) ~= "table" then
        return
    end
    for i = 1, #snap.clear do
        char.skips[snap.clear[i]] = nil
    end
    if snap.pocketSkip and type(char.skipPockets) == "table" then
        char.skipPockets[snap.pocketSkip] = nil
    end
    char.manualStepId = snap.id
end

function Resume.Back()
    local char = QS.char
    if not char or not Resume.CanBack(char) then
        return
    end
    if type(char.history) ~= "table" then
        return
    end
    local from = #char.history
    if char.historyAt then
        from = char.historyAt - 1
    end
    local at = PreviousAt(char, from)
    if not at then
        return
    end
    char.historyAt = at
    local snap = char.history[at]
    ReleaseSkip(char, snap)
    if snap and snap.kind == "travel" and snap.completeOnZone
        and char.assumeZone == snap.completeOnZone then
        char.assumeZone = nil
    end
    QS:Rebuild()
end

function Resume.SeedHistory(char, log)
    if not char or char.reviewSeeded or not log then
        return
    end
    local flagged = QS.Api and QS.Api.IsFlagged and QS.Api.IsFlagged(95664)
    local known = (log.completed and log.completed[95664]) or flagged ~= nil
    if not known then
        return
    end
    char.reviewSeeded = true
    if not (log.completed and log.completed[95664]) and flagged ~= true then
        return
    end
    if type(char.history) ~= "table" then
        char.history = {}
    end
    for i = 1, #char.history do
        if char.history[i].id == "review-elder-knowledge" then
            return
        end
    end
    char.history[#char.history + 1] = {
        id = "review-elder-knowledge",
        title = "Turn in to Bashana Runetotem",
        text = "Elder Knowledge turns in at a tent on the Elder Rise in Thunder Bluff. That is not the inn on the lower rise.",
        zone = "Thunder Bluff",
        mapID = 1456,
        x = 0.708,
        y = 0.337,
        npc = "Bashana Runetotem",
        kind = "turnin",
        questID = 95664,
        questName = "Elder Knowledge",
        goalHeader = "Turn in",
        goals = { { name = "Turn in Elder Knowledge", have = 1, need = 1 } },
        confidence = "reported",
    }
end

local function LowerTitle(title)
    if type(title) ~= "string" then
        return nil
    end
    local name = string.lower(title)
    if name == "" then
        return nil
    end
    return name
end

local function StepNamesQuest(step, questID, name)
    if questID and questID > 0 then
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
    end
    if not name then
        return false
    end
    if step.questName and string.lower(step.questName) == name then
        return true
    end
    local titles = step.acceptTitles
    if titles then
        for i = 1, #titles do
            if string.lower(titles[i]) == name then
                return true
            end
        end
    end
    local titled = step.kind == "accept" or step.kind == "turnin" or step.kind == "objective"
    if titled and step.title and string.lower(step.title) == name then
        return true
    end
    return false
end

function Resume.QuestIntended(route, questID, info)
    if not route or not route.steps or route.key == "demo" or (QS.char and QS.char.demo) then
        return true
    end
    local name = LowerTitle(info and info.title)
    local namedByWork = false
    local namedByArea = false
    for i = 1, #route.steps do
        local step = route.steps[i]
        if StepNamesQuest(step, questID, name) then
            local grey = QS.Level and QS.Level.IsGrey and QS.Level.IsGrey(step)
            if step.kind == "area" then
                namedByArea = true
            elseif not grey then
                namedByWork = true
            end
        end
    end
    if namedByWork then
        return true
    end
    local level = info and info.level
    if type(level) == "number" and QS.Level and QS.Level.IsGrey then
        if QS.Level.IsGrey({ kind = "accept", questLevel = level }) then
            return false
        end
    end
    if namedByArea then
        return true
    end
    if name and QS.Area and QS.Area.KnownTitle and QS.Area.KnownTitle(name) then
        return true
    end
    return false
end

function Resume.StrayQuests(route)
    local rows = {}
    local log = route and route.log
    if not route or not route.steps or not log or not log.inLog then
        return rows
    end
    if route.key == "demo" or (QS.char and QS.char.demo) then
        return rows
    end
    for questID, info in pairs(log.inLog) do
        if type(questID) == "number" and questID > 0 and not Resume.QuestIntended(route, questID, info) then
            rows[#rows + 1] = {
                id = questID,
                title = (info and info.title) or ("Quest " .. questID),
                index = (info and info.index) or 0,
                complete = info and info.complete and true or false,
            }
        end
    end
    table.sort(rows, function(a, b)
        if a.index == b.index then
            return a.id > b.id
        end
        return a.index > b.index
    end)
    return rows
end

local function LogIndex(questID)
    if not (GetQuestLogTitle and GetNumQuestLogEntries) then
        return nil
    end
    local n = GetNumQuestLogEntries() or 0
    for i = n, 1, -1 do
        local _, _, _, isHeader, _, _, _, qid = GetQuestLogTitle(i)
        if not isHeader and qid == questID then
            return i
        end
    end
    return nil
end

local function AbandonOne(row)
    local canScan = GetQuestLogTitle and GetNumQuestLogEntries
    local index = LogIndex(row.id)
    if not index and not canScan then
        index = row.index
    end
    if SelectQuestLogEntry and SetAbandonQuest and AbandonQuest and index and index > 0 then
        local ok = pcall(function()
            SelectQuestLogEntry(index)
            SetAbandonQuest()
            AbandonQuest()
        end)
        if ok and not canScan then
            return true
        end
        if ok and LogIndex(row.id) == nil then
            return true
        end
    end
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.SetAbandonQuest and C_QuestLog.AbandonQuest then
        local ok = pcall(function()
            C_QuestLog.SetSelectedQuest(row.id)
            C_QuestLog.SetAbandonQuest()
            C_QuestLog.AbandonQuest()
        end)
        return ok and true or false
    end
    return false
end

function Resume.AbandonStrays(route)
    local rows = Resume.StrayQuests(route)
    local removed = {}
    for i = 1, #rows do
        if AbandonOne(rows[i]) then
            removed[#removed + 1] = rows[i].title
        end
    end
    local n = #removed
    if n > 0 and QS.Print then
        local shown = {}
        local limit = n
        if limit > 8 then
            limit = 8
        end
        for i = 1, limit do
            shown[#shown + 1] = removed[i]
        end
        local msg = "Clean Quest Log removed " .. n
        if n == 1 then
            msg = msg .. " quest: "
        else
            msg = msg .. " quests: "
        end
        msg = msg .. table.concat(shown, ", ")
        if n > 8 then
            msg = msg .. ", ..."
        end
        pcall(function()
            QS:Print(msg)
        end)
    end
    return n
end

function Resume.Reset()
    local char = QS.char
    char.skips = {}
    char.stepBack = {}
    char.history = {}
    char.historyAt = nil
    char.pendingClear = nil
    char.reviewSeeded = nil
    char.manualStepId = nil
    char.manualFrontierId = nil
    char.assumeZone = nil
    char.skipPockets = {}
    QS:Print("Skips cleared. Resuming from the quest log.")
    QS:Rebuild()
end

function Resume.NormTitle(title)
    if type(title) ~= "string" then
        return nil
    end
    local name = string.lower(title)
    local prefixes = {
        "turn in to ", "turn in ", "fly to ", "go to ",
        "pick up at the ", "pick up at ", "pick up ",
        "talk to ", "kill mobs in ",
    }
    local changed = true
    while changed do
        changed = false
        for i = 1, #prefixes do
            local prefix = prefixes[i]
            if string.sub(name, 1, #prefix) == prefix then
                name = string.sub(name, #prefix + 1)
                changed = true
            end
        end
    end
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    name = string.gsub(name, "%s+", " ")
    if name == "" then
        return nil
    end
    return name
end

local function LevelShare(level, xp, xpMax)
    if level >= 60 then
        return 1
    end
    xp = tonumber(xp) or 0
    xpMax = tonumber(xpMax) or 0
    if xpMax < 1 then
        xpMax = 1
    end
    if xp < 0 then
        xp = 0
    end
    if xp > xpMax then
        xp = xpMax
    end
    -- The end of level 27 is about halfway to 60 on this road.
    local share = (level - 1 + (xp / xpMax)) / 54
    if share < 0 then
        share = 0
    end
    if share > 1 then
        share = 1
    end
    return share
end

function Resume.Journey(level, xp, xpMax, done, ahead)
    level = tonumber(level) or 1
    if level < 1 then
        level = 1
    end
    if level > 60 then
        level = 60
    end
    if level >= 60 then
        return "100%", 1
    end
    local share = LevelShare(level, xp, xpMax)
    done = tonumber(done) or 0
    ahead = tonumber(ahead) or 0
    local fraction = share
    -- A short turn-in log is not the whole history. Until dozens of
    -- finished quests are known, the bar stays on the level's share.
    if done >= 80 and (done + ahead) > 0 then
        local real = done / (done + ahead)
        if real < 0 then
            real = 0
        end
        if real > 1 then
            real = 1
        end
        -- A long finished list must not read as nearly done while half the
        -- road to 60 is still ahead. Extra quests can sit under that share.
        if real > share then
            fraction = share
        else
            fraction = real
        end
    end
    local pct = math.floor(fraction * 100 + 0.5)
    if pct < 0 then
        pct = 0
    end
    if pct > 100 then
        pct = 100
    end
    return pct .. "%", fraction
end

local function LearnStepTitle(step)
    if not step or not QS.Api or not QS.Api.RememberTitle then
        return
    end
    local title = step.questName
    if type(title) ~= "string" or title == "" then
        title = step.title
        if Resume.NormTitle(title) ~= string.lower(title or "") then
            return
        end
    end
    QS.Api.RememberTitle(step.questID, title, step.zone)
    local ids = step.questIDs
    if ids and step.questName then
        for i = 1, #ids do
            QS.Api.RememberTitle(ids[i], step.questName, step.zone)
        end
    end
end

local function PreferState(old, new)
    local rank = { ahead = 1, skip = 2, done = 3, now = 4 }
    if (rank[new] or 0) >= (rank[old] or 0) then
        return new
    end
    return old
end

function Resume.PathRows(route)
    local rows = {}
    local seen = {}
    local steps = route and route.steps or {}
    local index = route and route.index
    local log = route and route.log or { inLog = {}, completed = {} }
    local completed = log.completed or {}
    for i = 1, #steps do
        LearnStepTitle(steps[i])
    end
    local hist = QS.char and QS.char.history
    if type(hist) == "table" then
        for i = 1, #hist do
            LearnStepTitle(hist[i])
        end
    end

    local function add(row)
        local key = row.key
        if not key then
            return nil
        end
        local prev = seen[key]
        if prev then
            prev.state = PreferState(prev.state, row.state)
            if (row.band or 0) > (prev.band or 0) then
                prev.band = row.band
            end
            if (row.when or 0) > (prev.when or 0) then
                prev.when = row.when
            end
            if (row.seq or 0) > (prev.seq or 0) then
                prev.seq = row.seq
            end
            if (row.walk or 0) > (prev.walk or 0) then
                prev.walk = row.walk
            end
            if row.state == "now" then
                prev.id = row.id or prev.id
                prev.title = row.title or prev.title
                prev.zone = row.zone or prev.zone
            end
            return prev
        end
        seen[key] = row
        rows[#rows + 1] = row
        return row
    end

    local function keyFor(title, questID)
        local norm = Resume.NormTitle(title)
        if norm then
            return "t:" .. norm
        end
        if questID and questID > 0 then
            return "q:" .. questID
        end
        return nil
    end

    local ids = {}
    local doneCount = 0
    for id, v in pairs(completed) do
        if v then
            doneCount = doneCount + 1
            ids[#ids + 1] = id
        end
    end
    table.sort(ids)
    if QS.Api and QS.Api.QueueTitles then
        QS.Api.QueueTitles(completed)
    end
    if QS.Api and QS.Api.PumpTitles then
        QS.Api.PumpTitles()
    end
    local zones = (QS.char and QS.char.questZones) or {}
    local turnedIn = (QS.char and QS.char.turnedIn) or {}
    local seenTitles = (QS.char and QS.char.questSeen) or {}
    local oldKey = {}
    for i = 1, #steps do
        local step = steps[i]
        local old = step.starter or (QS.Level and QS.Level.IsGrey and QS.Level.IsGrey(step))
        if old then
            local title = step.questName or step.title
            local norm = Resume.NormTitle(title)
            if norm then
                oldKey["t:" .. norm] = true
            end
        end
    end
    for i = 1, #ids do
        local id = ids[i]
        local title = QS.Api and QS.Api.TitleFor and QS.Api.TitleFor(id)
        if title then
            local when = 0
            local stamp = turnedIn[id]
            if type(stamp) == "number" and stamp > 1 then
                when = stamp
            end
            local key = keyFor(title, id)
            local band = 1
            if when == 0 and key and oldKey[key] then
                band = 0
            end
            add({
                key = key,
                id = "done-" .. tostring(id),
                title = title,
                zone = zones[id],
                state = "done",
                band = band,
                when = when,
                seq = id,
            })
        end
    end

    local function consider(step, state, meta)
        if not step then
            return
        end
        local title = step.questName
        if type(title) ~= "string" or title == "" then
            title = step.title or Resume.Caption(step)
        end
        local shown = title
        if step.handIn and type(step.title) == "string" and step.title ~= "" then
            shown = step.title
        end
        meta = meta or {}
        add({
            key = keyFor(title, step.questID),
            id = step.id,
            title = shown,
            zone = step.placeName or step.zone,
            state = state,
            band = meta.band or 0,
            when = meta.when or 0,
            seq = meta.seq or 0,
            walk = meta.walk or 0,
        })
    end

    if type(hist) == "table" then
        for i = 1, #hist do
            local row = hist[i]
            if row and row.id and Resume.Done(row, log) then
                local seq = 10000000 + i
                if IsPocket(row) then
                    seq = 20000000 + i
                end
                -- walk keeps the order the steps were actually done, so the
                -- previous step sits on the row above the current one.
                consider(row, "done", { band = 1, when = 0, seq = seq, walk = i })
            end
        end
    end

    local function titleInLog(low)
        for _, info in pairs(log.inLog or {}) do
            if type(info.title) == "string" and string.lower(info.title) == low then
                return true
            end
        end
        return false
    end
    local function prettyTitle(low)
        return (string.gsub(low, "(%a)([%w']*)", function(a, rest)
            return string.upper(a) .. rest
        end))
    end
    local seenN = 0
    for low, on in pairs(seenTitles) do
        if on == true and type(low) == "string" and low ~= "" and not titleInLog(low) then
            local pretty = prettyTitle(low)
            local key = keyFor(pretty, nil)
            if key and not oldKey[key] then
                seenN = seenN + 1
                add({
                    key = key,
                    id = "seen-" .. low,
                    title = pretty,
                    state = "done",
                    band = 1,
                    when = 0,
                    seq = 5000000 + seenN,
                })
            end
        end
    end

    local aheadCount = 0
    local liveId = route and route.liveId
    local screen = index and steps[index]
    -- One gold row. While an earlier step is on screen, the live step
    -- stays in the list as the next row instead of being dropped.
    local reviewing = liveId and screen and screen.id ~= liveId
    for i = 1, #steps do
        local step = steps[i]
        local show = true
        if step.levelDefer then
            show = false
        elseif step.liveNote and i ~= index then
            show = false
        end
        if show then
            local state = "ahead"
            if liveId and step.id == liveId then
                if not reviewing then
                    state = "now"
                end
            elseif IsPocket(step) and Resume.Done(step, log) then
                state = "done"
            elseif i == index then
                state = "now"
            elseif Resume.Done(step, log) then
                state = "done"
            elseif index and i < index then
                state = "skip"
            end
            local grey = step.starter or (QS.Level and QS.Level.IsGrey and QS.Level.IsGrey(step))
            local stamp = step.questID and turnedIn[step.questID]
            local when = 0
            if not grey and type(stamp) == "number" and stamp > 1 then
                when = stamp
            end
            local band = 0
            if when > 0 or (state == "done" and not grey) then
                band = 1
            end
            local seq = i
            if state == "done" and IsPocket(step) then
                seq = 20000000 + i
            end
            consider(step, state, { band = band, when = when, seq = seq })
        end
    end

    local faction = QS.identity and QS.identity.faction
    local level = UnitLevel and UnitLevel("player") or 1
    if QS.Level and QS.Level.AheadStops then
        local stops = QS.Level.AheadStops(level, faction)
        for i = 1, #stops do
            local stop = stops[i]
            add({
                key = keyFor(stop.title, nil),
                id = "road-" .. tostring(stop.at) .. "-" .. (stop.title or i),
                title = stop.title,
                zone = stop.zone,
                state = "ahead",
            })
        end
    end

    local ordered = {}
    local doneRows, skips, now, ahead = {}, {}, nil, {}
    for i = 1, #rows do
        local row = rows[i]
        if row.state == "done" then
            doneRows[#doneRows + 1] = row
        elseif row.state == "skip" then
            skips[#skips + 1] = row
        elseif row.state == "now" then
            now = row
        else
            ahead[#ahead + 1] = row
        end
    end
    table.sort(doneRows, function(a, b)
        local awalk, bwalk = (a.walk or 0) > 0, (b.walk or 0) > 0
        if awalk ~= bwalk then
            return not awalk
        end
        if awalk then
            return (a.walk or 0) < (b.walk or 0)
        end
        local ab, bb = a.band or 0, b.band or 0
        if ab ~= bb then
            return ab < bb
        end
        local aw, bw = a.when or 0, b.when or 0
        if aw ~= bw then
            return aw < bw
        end
        local asq, bsq = a.seq or 0, b.seq or 0
        if asq ~= bsq then
            return asq < bsq
        end
        return (a.title or "") < (b.title or "")
    end)
    local walked = {}
    for i = 1, #doneRows do
        if (doneRows[i].walk or 0) > 0 then
            walked[#walked + 1] = doneRows[i]
        else
            ordered[#ordered + 1] = doneRows[i]
        end
    end
    for i = 1, #skips do
        ordered[#ordered + 1] = skips[i]
    end
    for i = 1, #walked do
        ordered[#ordered + 1] = walked[i]
    end
    local focus = #ordered + 1
    if now then
        ordered[#ordered + 1] = now
        focus = #ordered
    end
    for i = 1, #ahead do
        ordered[#ordered + 1] = ahead[i]
        aheadCount = aheadCount + 1
    end
    if now then
        aheadCount = aheadCount + 1
    end
    if focus < 1 then
        focus = 1
    end
    if focus > #ordered then
        focus = #ordered
    end
    if focus < 1 then
        focus = 1
    end
    ordered.doneCount = doneCount
    ordered.aheadCount = aheadCount
    return ordered, focus, doneCount, aheadCount
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

function Resume.PlaceLabel(label, step)
    if label ~= "Area" and label ~= "Already done" then
        return label
    end
    local zone = step and step.zone
    if type(zone) == "string" and zone ~= "" then
        label = label .. " · " .. zone
    end
    local route = QS.route
    local n = route and (route.viewStep or route.pathStep)
    if type(n) == "number" and n > 0 then
        label = label .. " - Step " .. n
    end
    return label
end

local function StepStamp(text)
    if type(text) ~= "string" or text == "" then
        text = "Step"
    end
    local route = QS.route
    local n = route and (route.viewStep or route.pathStep)
    if type(n) == "number" and n > 0 then
        return text .. " - Step " .. n
    end
    return text
end

function Resume.Status(step, log, measure)
    if not step then
        return "Ready"
    end
    if step.review then
        local title = step.title
        if type(title) ~= "string" or title == "" then
            title = Resume.Caption(step)
        end
        return StepStamp(title)
    end
    local char = QS.char
    if char and char.manualStepId == step.id and Resume.Done(step, log) then
        return Resume.PlaceLabel("Already done", step)
    end
    if step.kind == "boss" then
        return "Boss"
    end
    if step.kind == "kills" then
        return "Kills"
    end
    if step.kind == "area" then
        if step.areaTurnin then
            return "Turn in"
        end
        return Resume.PlaceLabel("Area", step)
    end
    if step.kind == "talent" then
        return "Talent"
    end
    if step.kind == "vendor" then
        return step.wantRepair and step.wantSell and "Sell" or (step.wantRepair and "Repair" or "Sell")
    end
    if step.kind == "craft" then
        return "Craft"
    end
    if step.kind == "proftrain" or step.kind == "classtrain" then
        return "Train"
    end
    if step.kind == "bank" then
        return "Bank"
    end
    if step.kind == "auction" then
        return "Auction"
    end
    if step.kind == "hearth" then
        return "Hearth"
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
        if step.handIn or (type(step.turnInAt) == "string" and step.turnInAt ~= "") then
            local title = step.title or "Turn in"
            if type(step.turnInAt) == "string" and step.turnInAt ~= "" then
                title = "Turn in at " .. step.turnInAt
            end
            return StepStamp(title)
        end
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
