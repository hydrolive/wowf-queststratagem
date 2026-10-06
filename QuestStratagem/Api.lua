-- Probes for the Forever / Classic-lineage quest and map API.
-- /qs api prints what this client actually exposed.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Api = {}
QS.Api = Api

local function Has(fn)
    return type(fn) == "function"
end

function Api.Probe()
    local lines = {}
    local function add(label, value)
        lines[#lines + 1] = label .. ": " .. tostring(value)
    end
    add("GetQuestLogTitle", Has(GetQuestLogTitle))
    add("GetNumQuestLogEntries", Has(GetNumQuestLogEntries))
    add("GetQuestLogLeaderBoard", Has(GetQuestLogLeaderBoard))
    add("C_QuestLog", type(C_QuestLog) == "table")
    if type(C_QuestLog) == "table" then
        add("C_QuestLog.GetInfo", Has(C_QuestLog.GetInfo))
        add("C_QuestLog.GetNumQuestLogEntries", Has(C_QuestLog.GetNumQuestLogEntries))
        add("C_QuestLog.GetQuestObjectives", Has(C_QuestLog.GetQuestObjectives))
        add("C_QuestLog.IsQuestFlaggedCompleted", Has(C_QuestLog.IsQuestFlaggedCompleted))
        add("C_QuestLog.IsComplete", Has(C_QuestLog.IsComplete))
    end
    add("GetQuestsCompleted", Has(GetQuestsCompleted))
    add("IsQuestFlaggedCompleted", Has(IsQuestFlaggedCompleted))
    add("C_Map", type(C_Map) == "table")
    if type(C_Map) == "table" then
        add("C_Map.GetBestMapForUnit", Has(C_Map.GetBestMapForUnit))
        add("C_Map.GetPlayerMapPosition", Has(C_Map.GetPlayerMapPosition))
        add("C_Map.GetWorldPosFromMapPos", Has(C_Map.GetWorldPosFromMapPos))
        add("C_Map.GetMapWorldSize", Has(C_Map.GetMapWorldSize))
    end
    add("UnitPosition", Has(UnitPosition))
    add("GetPlayerFacing", Has(GetPlayerFacing))
    add("CreateVector2D", Has(CreateVector2D))
    local locRace, raceFile = UnitRace("player")
    local locClass, classFile = UnitClass("player")
    add("faction", UnitFactionGroup("player"))
    add("race", tostring(locRace) .. " / " .. tostring(raceFile))
    add("class", tostring(locClass) .. " / " .. tostring(classFile))
    add("level", UnitLevel("player"))
    add("zone", GetZoneText())
    if C_Map and C_Map.GetBestMapForUnit then
        add("map", C_Map.GetBestMapForUnit("player"))
    end
    local hbd = false
    if LibStub then
        local ok = pcall(function() return LibStub("HereBeDragons-2.0", true) end)
        hbd = ok and LibStub("HereBeDragons-2.0", true) ~= nil
    end
    add("HereBeDragons-2.0", hbd)
    add("data", QS.DATA_VERSION)
    return lines
end

function Api.LogCount()
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        local a, b = C_QuestLog.GetNumQuestLogEntries()
        return b or a or 0
    end
    if GetNumQuestLogEntries then
        local n = GetNumQuestLogEntries()
        return n or 0
    end
    return 0
end

local function ReadObjectives(questID, logIndex)
    local objectives = {}
    if C_QuestLog and C_QuestLog.GetQuestObjectives and questID then
        local objs = C_QuestLog.GetQuestObjectives(questID)
        if objs then
            for j = 1, #objs do
                local o = objs[j]
                objectives[#objectives + 1] = {
                    text = o.text,
                    finished = o.finished and true or false,
                    have = o.numFulfilled or 0,
                    need = o.numRequired or 0,
                }
            end
            if #objectives > 0 then
                return objectives
            end
        end
    end
    if GetNumQuestLeaderBoards and GetQuestLogLeaderBoard and logIndex then
        local num = GetNumQuestLeaderBoards(logIndex) or 0
        for j = 1, num do
            local text, _, finished = GetQuestLogLeaderBoard(j, logIndex)
            local have, need = 0, 0
            if type(text) == "string" then
                local h, n = text:match("(%d+)%s*/%s*(%d+)")
                if h then
                    have, need = tonumber(h) or 0, tonumber(n) or 0
                end
            end
            objectives[#objectives + 1] = {
                text = text,
                finished = finished and true or false,
                have = have,
                need = need,
            }
        end
    end
    return objectives
end

function Api.ReadLog()
    local inLog = {}
    local n = Api.LogCount()
    for i = 1, n do
        local title, isHeader, isComplete, questID
        if C_QuestLog and C_QuestLog.GetInfo then
            local info = C_QuestLog.GetInfo(i)
            if info then
                title = info.title
                isHeader = info.isHeader
                questID = info.questID
                isComplete = info.isComplete
            end
        end
        if not questID and GetQuestLogTitle then
            local t, _, _, header, _, complete, _, qid = GetQuestLogTitle(i)
            title = t
            isHeader = header
            isComplete = complete
            questID = qid
        end
        if questID and questID ~= 0 and not isHeader then
            local complete = (isComplete == 1 or isComplete == true)
            if not complete and C_QuestLog and C_QuestLog.IsComplete then
                local ok, v = pcall(C_QuestLog.IsComplete, questID)
                if ok and v then
                    complete = true
                end
            end
            inLog[questID] = {
                index = i,
                title = title,
                complete = complete,
                objectives = ReadObjectives(questID, i),
            }
        end
    end
    return inLog
end

function Api.IsFlagged(questID)
    if not questID then
        return nil
    end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, v = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
        if ok then
            return v and true or false
        end
    end
    if IsQuestFlaggedCompleted then
        local ok, v = pcall(IsQuestFlaggedCompleted, questID)
        if ok then
            return v and true or false
        end
    end
    return nil
end

function Api.ReadCompleted(turnedIn)
    local done = {}
    if turnedIn then
        for id, v in pairs(turnedIn) do
            if v then
                done[id] = true
            end
        end
    end
    if GetQuestsCompleted then
        local ok, t = pcall(GetQuestsCompleted)
        if ok and type(t) == "table" then
            for id, v in pairs(t) do
                if v then
                    done[id] = true
                end
            end
        end
    end
    return done
end

function Api.NoteIfFlagged(log, questID)
    if not questID or log.completed[questID] then
        return log.completed[questID] and true or false
    end
    if Api.IsFlagged(questID) then
        log.completed[questID] = true
    end
    return log.completed[questID] and true or false
end

function Api.Snapshot()
    local turnedIn = (QS.char and QS.char.turnedIn) or {}
    return {
        inLog = Api.ReadLog(),
        completed = Api.ReadCompleted(turnedIn),
    }
end
