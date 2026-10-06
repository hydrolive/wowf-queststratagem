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
    add("QueryQuestsCompleted", Has(QueryQuestsCompleted))
    add("IsQuestFlaggedCompleted", Has(IsQuestFlaggedCompleted))
    add("GetQuestGreenRange", Has(GetQuestGreenRange))
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
    add("GetBindLocation", Has(GetBindLocation))
    add("GetItemCooldown", Has(GetItemCooldown))
    add("GetNumSkillLines", Has(GetNumSkillLines))
    add("GetSkillLineInfo", Has(GetSkillLineInfo))
    add("GetProfessions", Has(GetProfessions))
    add("GetNumTalents", Has(GetNumTalents))
    add("GetTalentInfo", Has(GetTalentInfo))
    add("GetInventoryItemDurability", Has(GetInventoryItemDurability))
    add("C_Container", type(C_Container) == "table")
    add("GetContainerNumSlots", Has(GetContainerNumSlots))
    add("bind", Api.BindLocation())
    add("freeSlots", Api.FreeSlots())
    local skills = Api.Skills()
    for i = 1, #skills do
        add("skill " .. skills[i].name, skills[i].rank .. "/" .. tostring(skills[i].max))
    end
    add("data", QS.DATA_VERSION)
    return lines
end

function Api.Place()
    return {
        zone = GetZoneText and GetZoneText() or "",
        real = GetRealZoneText and GetRealZoneText() or "",
        sub = GetSubZoneText and GetSubZoneText() or "",
    }
end

function Api.BindLocation()
    if not GetBindLocation then
        return ""
    end
    return GetBindLocation() or ""
end

function Api.HearthCooldown()
    if not GetItemCooldown then
        return 0
    end
    local start, duration = GetItemCooldown(6948)
    if not start or not duration or start == 0 or duration == 0 then
        return 0
    end
    local remain = math.floor(start + duration - GetTime())
    if remain < 0 then
        return 0
    end
    return remain
end

function Api.UnspentTalents()
    if UnitCharacterPoints then
        local a = UnitCharacterPoints("player")
        if type(a) == "number" then
            return a
        end
    end
    if GetUnspentTalentPoints then
        return GetUnspentTalentPoints() or 0
    end
    return 0
end

function Api.TalentState(name)
    if not name or not GetNumTalents or not GetTalentInfo then
        return nil
    end
    for tab = 1, 3 do
        local n = GetNumTalents(tab) or 0
        for i = 1, n do
            local tname, _, _, _, rank, _, _, available = GetTalentInfo(tab, i)
            if tname == name then
                return rank or 0, available and true or false
            end
        end
    end
    return nil
end

function Api.TalentRank(name)
    local rank = Api.TalentState(name)
    return rank
end

function Api.Skills()
    local out = {}
    local seen = {}
    if GetProfessions and GetProfessionInfo then
        local ids = { GetProfessions() }
        for i = 1, #ids do
            local idx = ids[i]
            if idx then
                local name, _, rank, maxRank = GetProfessionInfo(idx)
                if name and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = { name = name, rank = rank or 0, max = maxRank or 0 }
                end
            end
        end
    end
    if GetNumSkillLines and GetSkillLineInfo then
        local n = GetNumSkillLines() or 0
        for i = 1, n do
            local name, header, _, rank, _, _, maxRank = GetSkillLineInfo(i)
            if name and not header and not seen[name] and rank and maxRank and maxRank > 0 then
                seen[name] = true
                out[#out + 1] = { name = name, rank = rank, max = maxRank }
            end
        end
    end
    return out
end

function Api.Skill(name)
    local skills = Api.Skills()
    for i = 1, #skills do
        if skills[i].name == name then
            return skills[i]
        end
    end
    return nil
end

local function BagSize(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag) or 0
    end
    if GetContainerNumSlots then
        return GetContainerNumSlots(bag) or 0
    end
    return 0
end

local function BagSlot(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info, count, _, _, _, _, link = C_Container.GetContainerItemInfo(bag, slot)
        if type(info) == "table" then
            return info.itemID, info.stackCount or info.stack or 1, info.isBound, info.hyperlink
        end
        if type(link) == "string" then
            return tonumber(link:match("item:(%d+)")), count or 1, nil, link
        end
    end
    if GetContainerItemInfo then
        local _, count, _, _, _, _, link = GetContainerItemInfo(bag, slot)
        if link then
            local id = link:match("item:(%d+)")
            return tonumber(id), count or 1, nil, link
        end
    end
    return nil
end

function Api.Bags()
    local free = 0
    local byId = {}
    local list = {}
    for bag = 0, 4 do
        local slots = BagSize(bag)
        for slot = 1, slots do
            local itemID, count, bound, link = BagSlot(bag, slot)
            if not itemID then
                free = free + 1
            else
                local name, _, quality, _, _, class, subclass = GetItemInfo(itemID)
                if not name and link then
                    name, _, quality, _, _, class, subclass = GetItemInfo(link)
                end
                if name then
                    local row = byId[itemID]
                    if not row then
                        row = {
                            id = itemID,
                            name = name,
                            quality = quality or 1,
                            count = 0,
                            class = class,
                            subclass = subclass,
                            bound = bound,
                        }
                        byId[itemID] = row
                        list[#list + 1] = row
                    end
                    row.count = row.count + (count or 1)
                    if bound then
                        row.bound = true
                    end
                end
            end
        end
    end
    return { free = free, byId = byId, list = list }
end

function Api.FreeSlots()
    return Api.Bags().free
end

function Api.ItemCount(itemID)
    if not itemID then
        return 0
    end
    if GetItemCount then
        return GetItemCount(itemID) or 0
    end
    local bags = Api.Bags()
    local row = bags.byId[itemID]
    return row and row.count or 0
end

function Api.DurabilityRatio()
    if not GetInventoryItemDurability then
        return 1
    end
    local cur, max = 0, 0
    for slot = 1, 18 do
        local c, m = GetInventoryItemDurability(slot)
        if c and m and m > 0 then
            cur = cur + c
            max = max + m
        end
    end
    if max == 0 then
        return 1
    end
    return cur / max
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
    local zones = {}
    local current
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
        if questID == nil and GetQuestLogTitle then
            local t, _, _, header, _, complete, _, qid = GetQuestLogTitle(i)
            title = t
            isHeader = header
            isComplete = complete
            questID = qid
        end
        if isHeader then
            current = { name = title or "Quests", quests = {} }
            zones[#zones + 1] = current
        elseif questID and questID ~= 0 then
            local complete = (isComplete == 1 or isComplete == true)
            if not complete and C_QuestLog and C_QuestLog.IsComplete then
                local ok, v = pcall(C_QuestLog.IsComplete, questID)
                if ok and v then
                    complete = true
                end
            end
            local zoneName = current and current.name or ""
            inLog[questID] = {
                index = i,
                title = title,
                complete = complete,
                zone = zoneName,
                objectives = ReadObjectives(questID, i),
            }
            if current then
                current.quests[#current.quests + 1] = questID
            end
        end
    end
    return inLog, zones
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

function Api.QueryCompleted()
    if QueryQuestsCompleted then
        pcall(QueryQuestsCompleted)
    end
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
    local inLog, zones = Api.ReadLog()
    return {
        inLog = inLog,
        zones = zones or {},
        completed = Api.ReadCompleted(turnedIn),
    }
end
