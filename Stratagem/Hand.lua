-- Turn in a finished quest while the NPC dialog is open, then accept the
-- next quest only when this route names it, or it is the single follow-up
-- of a turn-in this route was already on. A dungeon quest shared by a
-- player is accepted on its own. Hold Shift to leave the dialog alone.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Hand = {}
QS.Hand = Hand

local DUNGEON_TAG = 81
local followUntil = 0
local lastSelect = 0
local depth = 0
local pendingAccept = false
local chainedDetail = false

function Hand.OnRoute(route, questID, title)
    if not route or not route.steps then
        return false
    end
    local id = type(questID) == "number" and questID or 0
    local name = type(title) == "string" and string.lower(title) or nil
    if name == "" then
        name = nil
    end
    for i = 1, #route.steps do
        local step = route.steps[i]
        if id > 0 then
            if step.questID == id then
                return true
            end
            local ids = step.questIDs
            if ids then
                for j = 1, #ids do
                    if ids[j] == id then
                        return true
                    end
                end
            end
        end
        if name then
            if step.questName and string.lower(step.questName) == name then
                return true
            end
            local titled = step.kind == "accept" or step.kind == "turnin" or step.kind == "objective"
            if titled and step.title and string.lower(step.title) == name then
                return true
            end
        end
    end
    -- Gossip on some clients has the title and no id. The area step stores the log id.
    if name and id == 0 and route.log and route.log.inLog then
        for logID, info in pairs(route.log.inLog) do
            if info.title and string.lower(info.title) == name then
                if Hand.OnRoute(route, logID, nil) then
                    return true
                end
            end
        end
    end
    return false
end

function Hand.ChooseAccept(route, offers, follow)
    local routeHits, followHits = {}, {}
    for i = 1, #offers do
        local row = offers[i]
        if Hand.OnRoute(route, row.questID, row.title) then
            routeHits[#routeHits + 1] = i
        elseif follow and not row.trivial then
            followHits[#followHits + 1] = i
        end
    end
    if routeHits[1] then
        return routeHits[1]
    end
    if follow and #followHits == 1 then
        return followHits[1]
    end
    return nil
end

function Hand.IsSharedDungeon(tagID, title, names, inDungeon)
    if tagID == DUNGEON_TAG then
        return true
    end
    if inDungeon then
        return true
    end
    if title and names then
        local lower = string.lower(title)
        for i = 1, #names do
            local name = names[i]
            if name and name ~= "" and string.find(lower, string.lower(name), 1, true) then
                return true
            end
        end
    end
    return false
end

local function Enabled()
    return QS.char and QS.char.autoHand ~= false and not (IsShiftKeyDown and IsShiftKeyDown())
end

local function Now()
    return GetTime and GetTime() or 0
end

local function ArmFollow(questID, title)
    if Hand.OnRoute(QS.route, questID, title) then
        followUntil = Now() + 3
    end
end

local function FollowHot()
    return Now() < followUntil
end

local function CanSelect()
    local now = Now()
    if now - lastSelect < 0.2 then
        return false
    end
    lastSelect = now
    return true
end

local function Note(text)
    if QS.Print and text and text ~= "" then
        QS:Print(text)
    end
end

local function QuestTag(questID)
    if type(questID) ~= "number" or questID <= 0 then
        return nil
    end
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, info = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and type(info) == "table" then
            return info.tagID
        end
        if ok and type(info) == "number" then
            return info
        end
    end
    if type(GetQuestTagInfo) == "function" then
        local ok, tag = pcall(GetQuestTagInfo, questID)
        if ok then
            return tag
        end
    end
    return nil
end

local function DungeonNames()
    local names = {}
    local rows = QS.Registry and QS.Registry.dungeons
    if not rows then
        return names
    end
    for i = 1, #rows do
        names[#names + 1] = rows[i].name
    end
    return names
end

local function InDungeon()
    if type(IsInInstance) ~= "function" then
        return false
    end
    local ok, inside, kind = pcall(IsInInstance)
    return ok and inside and (kind == "party" or kind == "raid")
end

local function PlayerShare()
    if UnitExists and UnitIsPlayer then
        if UnitExists("questnpc") and UnitIsPlayer("questnpc") then
            return true
        end
        if UnitExists("npc") and UnitIsPlayer("npc") then
            return true
        end
    end
    if type(UnitGUID) == "function" then
        local guid = UnitGUID("questnpc") or UnitGUID("npc")
        if type(guid) == "string" and string.sub(guid, 1, 6) == "Player" then
            return true
        end
    end
    return false
end

local function DialogTitle()
    if type(GetTitleText) == "function" then
        return GetTitleText()
    end
    return nil
end

local function DialogID()
    if type(GetQuestID) == "function" then
        local id = GetQuestID()
        if type(id) == "number" then
            return id
        end
    end
    return 0
end

local function CompleteFlag(value)
    return value == true or value == 1
end

local function LogComplete(questID)
    local log = QS.route and QS.route.log
    local row = log and log.inLog and questID and log.inLog[questID]
    return row and row.complete and true or false
end

local function GossipActive()
    local out = {}
    if C_GossipInfo and C_GossipInfo.GetActiveQuests then
        local ok, list = pcall(C_GossipInfo.GetActiveQuests)
        if ok and type(list) == "table" then
            for i = 1, #list do
                local row = list[i]
                out[#out + 1] = {
                    index = i,
                    questID = row.questID or 0,
                    title = row.title,
                    done = CompleteFlag(row.isComplete) or LogComplete(row.questID),
                }
            end
            return out
        end
    end
    if type(GetGossipActiveQuests) ~= "function" then
        return out
    end
    local ok, packed = pcall(function() return { GetGossipActiveQuests() } end)
    if not ok or type(packed) ~= "table" then
        return out
    end
    local n = 0
    for i = 1, #packed, 6 do
        n = n + 1
        out[#out + 1] = {
            index = n,
            questID = 0,
            title = packed[i],
            done = CompleteFlag(packed[i + 3]),
        }
    end
    return out
end

local function GossipOffers()
    local out = {}
    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        local ok, list = pcall(C_GossipInfo.GetAvailableQuests)
        if ok and type(list) == "table" then
            for i = 1, #list do
                local row = list[i]
                out[#out + 1] = {
                    index = i,
                    questID = row.questID or 0,
                    title = row.title,
                    trivial = row.isTrivial and true or false,
                }
            end
            return out
        end
    end
    if type(GetGossipAvailableQuests) ~= "function" then
        return out
    end
    local ok, packed = pcall(function() return { GetGossipAvailableQuests() } end)
    if not ok or type(packed) ~= "table" then
        return out
    end
    local n = 0
    for i = 1, #packed, 7 do
        n = n + 1
        out[#out + 1] = {
            index = n,
            questID = 0,
            title = packed[i],
            trivial = CompleteFlag(packed[i + 2]),
        }
    end
    return out
end

local function SelectActive(row)
    if not CanSelect() then
        return false
    end
    ArmFollow(row.questID, row.title)
    if C_GossipInfo and C_GossipInfo.SelectActiveQuest and row.questID and row.questID > 0 then
        C_GossipInfo.SelectActiveQuest(row.questID)
        return true
    end
    if type(SelectGossipActiveQuest) == "function" then
        SelectGossipActiveQuest(row.index)
        return true
    end
    if type(SelectActiveQuest) == "function" then
        SelectActiveQuest(row.index)
        return true
    end
    return false
end

local function SelectOffer(row)
    if not CanSelect() then
        return false
    end
    -- Set before the select call. The detail event can run inside that call.
    pendingAccept = true
    if C_GossipInfo and C_GossipInfo.SelectAvailableQuest and row.questID and row.questID > 0 then
        C_GossipInfo.SelectAvailableQuest(row.questID)
        return true
    end
    if type(SelectGossipAvailableQuest) == "function" then
        SelectGossipAvailableQuest(row.index)
        return true
    end
    if type(SelectAvailableQuest) == "function" then
        SelectAvailableQuest(row.index)
        return true
    end
    pendingAccept = false
    return false
end

local function FirstDone(rows)
    for i = 1, #rows do
        if rows[i].done then
            return rows[i]
        end
    end
    return nil
end

local function GreetingActive()
    local out = {}
    local n = type(GetNumActiveQuests) == "function" and (GetNumActiveQuests() or 0) or 0
    for i = 1, n do
        local title, done = nil, false
        if type(GetActiveTitle) == "function" then
            title, done = GetActiveTitle(i)
        end
        local qid = 0
        if type(GetActiveQuestID) == "function" then
            local id = GetActiveQuestID(i)
            if type(id) == "number" then
                qid = id
            end
        end
        out[#out + 1] = {
            index = i,
            questID = qid,
            title = title,
            done = CompleteFlag(done) or LogComplete(qid),
        }
    end
    return out
end

local function GreetingOffers()
    local out = {}
    local n = type(GetNumAvailableQuests) == "function" and (GetNumAvailableQuests() or 0) or 0
    for i = 1, n do
        local title = type(GetAvailableTitle) == "function" and GetAvailableTitle(i) or nil
        local qid, trivial = 0, false
        if type(GetAvailableQuestInfo) == "function" then
            local ok, a, _, c, _, e = pcall(GetAvailableQuestInfo, i)
            if ok then
                if type(e) == "number" and e > 0 then
                    qid = e
                elseif type(a) == "number" and a > 0 then
                    qid = a
                end
                trivial = CompleteFlag(c)
            end
        end
        out[#out + 1] = { index = i, questID = qid, title = title, trivial = trivial }
    end
    return out
end

local function TakeAccept(offers)
    local index = Hand.ChooseAccept(QS.route, offers, FollowHot())
    if not index then
        return false
    end
    local row = offers[index]
    if SelectOffer(row) then
        Note("Accepting " .. (row.title or "the next quest"))
        return true
    end
    return false
end

local function OnGossip()
    chainedDetail = false
    local done = FirstDone(GossipActive())
    if done and SelectActive(done) then
        Note("Turning in " .. (done.title or "a finished quest"))
        return
    end
    TakeAccept(GossipOffers())
end

local function OnGreeting()
    chainedDetail = false
    local done = FirstDone(GreetingActive())
    if done then
        ArmFollow(done.questID, done.title)
        if CanSelect() and type(SelectActiveQuest) == "function" then
            SelectActiveQuest(done.index)
            Note("Turning in " .. (done.title or "a finished quest"))
            return
        end
    end
    TakeAccept(GreetingOffers())
end

local function RewardPick()
    local n = type(GetNumQuestChoices) == "function" and (GetNumQuestChoices() or 0) or 0
    if n <= 1 then
        return n <= 0 and 0 or 1
    end
    local spec = QS.Config and QS.Config.ActiveSpec and QS.Config.ActiveSpec() or nil
    local questID = DialogID()
    local want
    local steps = QS.route and QS.route.steps
    if spec and steps then
        for i = 1, #steps do
            local step = steps[i]
            local match = step.questID == questID
            if not match and step.questIDs then
                for j = 1, #step.questIDs do
                    if step.questIDs[j] == questID then
                        match = true
                    end
                end
            end
            if match and step.rewardChoice and step.rewardChoice[spec] and step.rewardChoice[spec].name then
                want = string.lower(step.rewardChoice[spec].name)
            end
        end
    end
    if not want or type(GetQuestItemInfo) ~= "function" then
        return nil
    end
    for i = 1, n do
        local ok, name = pcall(GetQuestItemInfo, "choice", i)
        if ok and type(name) == "string" and string.lower(name) == want then
            return i
        end
    end
    return nil
end

local function FinishReward(index)
    if type(GetQuestReward) ~= "function" then
        return
    end
    local ok = pcall(GetQuestReward, index)
    if not ok and index == 0 then
        pcall(GetQuestReward, 1)
    end
end

local function OnProgress()
    if type(IsQuestCompletable) == "function" and IsQuestCompletable() and type(CompleteQuest) == "function" then
        ArmFollow(DialogID(), DialogTitle())
        CompleteQuest()
    end
end

local function OnComplete()
    local id, title = DialogID(), DialogTitle()
    ArmFollow(id, title)
    local pick = RewardPick()
    if not pick then
        Note("Reward choice left open")
        return
    end
    -- Some clients open the follow-up detail inside GetQuestReward, with no gossip in between.
    chainedDetail = true
    FinishReward(pick)
    if title and title ~= "" then
        Note("Turned in " .. title)
    end
end

local function OnDetail()
    local id, title = DialogID(), DialogTitle()
    local shared = PlayerShare() and Hand.IsSharedDungeon(QuestTag(id), title, DungeonNames(), InDungeon())
    local take = pendingAccept or (chainedDetail and FollowHot()) or shared or Hand.OnRoute(QS.route, id, title)
    pendingAccept = false
    chainedDetail = false
    if take and type(AcceptQuest) == "function" then
        AcceptQuest()
        if title and title ~= "" then
            Note("Accepted " .. title)
        end
    end
end

local function OnConfirm(arg1, arg2)
    local id = type(arg1) == "number" and arg1 or (type(arg2) == "number" and arg2 or DialogID())
    local title = type(arg1) == "string" and arg1 or (type(arg2) == "string" and arg2 or DialogTitle())
    if not Hand.IsSharedDungeon(QuestTag(id), title, DungeonNames(), InDungeon()) then
        return
    end
    if type(ConfirmAcceptQuest) == "function" then
        ConfirmAcceptQuest()
        Note("Accepted shared dungeon quest")
    end
end

function Hand:OnEvent(event, arg1, arg2)
    if not Enabled() or depth > 6 then
        return
    end
    depth = depth + 1
    local ok, err = pcall(function()
        if event == "GOSSIP_SHOW" then
            OnGossip()
        elseif event == "QUEST_GREETING" then
            OnGreeting()
        elseif event == "QUEST_PROGRESS" then
            OnProgress()
        elseif event == "QUEST_COMPLETE" then
            OnComplete()
        elseif event == "QUEST_DETAIL" then
            OnDetail()
        elseif event == "QUEST_ACCEPT_CONFIRM" then
            OnConfirm(arg1, arg2)
        end
    end)
    depth = depth - 1
    if not ok then
        Note(tostring(err))
    end
end

if type(CreateFrame) == "function" then
    local frame = CreateFrame("Frame", "StratagemHandFrame")
    frame:SetScript("OnEvent", function(_, event, arg1, arg2)
        Hand:OnEvent(event, arg1, arg2)
    end)
    local function reg(name)
        pcall(frame.RegisterEvent, frame, name)
    end
    reg("GOSSIP_SHOW")
    reg("QUEST_GREETING")
    reg("QUEST_DETAIL")
    reg("QUEST_PROGRESS")
    reg("QUEST_COMPLETE")
    reg("QUEST_ACCEPT_CONFIRM")
end
