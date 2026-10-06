QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

QS.VERSION = "0.1.13"
QS.DATA_VERSION = "classic-1.12 + forever-2026-10-05"
QS.loggedIn = false
QS.route = nil
QS.prevInLog = nil

QS.COLOR = {
    gold = { 1, 0.820, 0 },
    body = { 0.902, 0.878, 0.831 },
    muted = { 0.659, 0.627, 0.565 },
    bis = { 0.941, 0.780, 0.369 },
    danger = { 0.878, 0.314, 0.314 },
    fill = { 0.941, 0.816, 0.376 },
    empty = { 0.227, 0.204, 0.173 },
    bg = { 0.10, 0.09, 0.08, 0.94 },
    edge = { 0.78, 0.62, 0.28, 1 },
}

local CHAR_DEFAULTS = {
    size = "large",
    point = "CENTER",
    relative = "CENTER",
    x = 0,
    y = 80,
    spec = nil,
    specConfirmed = false,
    pace = "guide",
    skips = {},
    stepBack = {},
    history = {},
    historyAt = nil,
    flights = {},
    questSeen = {},
    questTitles = {},
    questZones = {},
    skipPockets = {},
    assumeZone = nil,
    manualStepId = nil,
    manualFrontierId = nil,
    turnedIn = {},
    legStart = nil,
    lastLeg = nil,
    totalSeconds = 0,
    dungeonDetours = true,
    bisCallouts = true,
    classQuests = true,
    professionSteps = true,
    bossDown = {},
    talentUnspent = nil,
    includeStubs = false,
    routeKey = nil,
    demo = false,
    shown = true,
    autoHand = true,
    minimapAngle = 0.8,
    factionOverride = nil,
    raceOverride = nil,
    classOverride = nil,
}

local GLOBAL_DEFAULTS = {
    debug = false,
}

local function CopyDefaults(src)
    local out = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            out[k] = CopyDefaults(v)
        else
            out[k] = v
        end
    end
    return out
end

local function FillDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                dst[k] = CopyDefaults(v)
            else
                dst[k] = v
            end
        end
    end
    return dst
end

function QS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffFFD100Stratagem|r " .. tostring(msg))
end

function QS:EnsureReady()
    if not QS.char then
        QS:InitDB()
    end
    if QS.UI and not QS.UI.frame then
        QS.UI:Init()
    end
end

function QS:InitDB()
    -- Phase A saved professionSteps = false before the field existed as a
    -- default. Read the revision before FillDefaults, which would stamp it.
    local hadRev = QuestStratagemCharDB and QuestStratagemCharDB.liveRev
    local hadBack = QuestStratagemCharDB and type(QuestStratagemCharDB.stepBack) == "table"
    QuestStratagemDB = FillDefaults(QuestStratagemDB or {}, GLOBAL_DEFAULTS)
    QuestStratagemCharDB = FillDefaults(QuestStratagemCharDB or {}, CHAR_DEFAULTS)
    if type(QuestStratagemCharDB.skips) ~= "table" then
        QuestStratagemCharDB.skips = {}
    end
    if type(QuestStratagemCharDB.stepBack) ~= "table" then
        QuestStratagemCharDB.stepBack = {}
    end
    if type(QuestStratagemCharDB.history) ~= "table" then
        QuestStratagemCharDB.history = {}
    end
    if type(QuestStratagemCharDB.flights) ~= "table" then
        QuestStratagemCharDB.flights = {}
    end
    if type(QuestStratagemCharDB.questSeen) ~= "table" then
        QuestStratagemCharDB.questSeen = {}
    end
    if type(QuestStratagemCharDB.questTitles) ~= "table" then
        QuestStratagemCharDB.questTitles = {}
    end
    if type(QuestStratagemCharDB.questZones) ~= "table" then
        QuestStratagemCharDB.questZones = {}
    end
    if type(QuestStratagemCharDB.skipPockets) ~= "table" then
        QuestStratagemCharDB.skipPockets = {}
    end
    -- 0.1.5 could skip an area with no way back. Those skips are not in stepBack.
    if not hadBack then
        for id in pairs(QuestStratagemCharDB.skips) do
            if type(id) == "string" and string.sub(id, 1, 9) == "dyn-area-" then
                QuestStratagemCharDB.skips[id] = nil
            end
        end
    end
    if type(QuestStratagemCharDB.turnedIn) ~= "table" then
        QuestStratagemCharDB.turnedIn = {}
    end
    if type(QuestStratagemCharDB.bossDown) ~= "table" then
        QuestStratagemCharDB.bossDown = {}
    end
    if not hadRev then
        QuestStratagemCharDB.professionSteps = true
        QuestStratagemCharDB.liveRev = 1
    end
    QS.db = QuestStratagemDB
    QS.char = QuestStratagemCharDB
end

function QS:RequestRebuild()
    local frame = QS.eventFrame
    if not frame then
        return
    end
    frame.rebuildAt = GetTime() + 0.2
end

function QS:Rebuild()
    if not QS.loggedIn or not QS.char then
        return
    end
    local id = QS.Config.Identity()
    QS.identity = id
    local built = QS.Router.Build(id, QS.char)
    local log = QS.Api.Snapshot()
    QS.Resume.PullForward(built.steps, log, QS.char.skips)
    if QS.Level and QS.Level.Apply then
        QS.Level.Apply(built, QS.char, log)
    end
    if QS.Live and QS.Live.Apply then
        QS.Live.Apply(built, id, QS.char, log)
    end
    if QS.Area and QS.Area.Apply then
        QS.Area.Apply(built, QS.char, log)
    end
    QS.Resume.SeedHistory(QS.char, log)
    local prevStep = QS.route and QS.route.index and QS.route.steps[QS.route.index]
    if not QS.char.historyAt and prevStep then
        QS.Resume.Remember(QS.char, prevStep)
    end
    local index = QS.Resume.Choose(built.steps, log, QS.char)
    local liveId = index and built.steps[index] and built.steps[index].id or nil
    if QS.char.historyAt and QS.char.history[QS.char.historyAt] then
        local snap = QS.Resume.Snapshot(QS.char.history[QS.char.historyAt])
        snap.review = true
        local found = nil
        for i = 1, #built.steps do
            if built.steps[i].id == snap.id then
                found = i
            end
        end
        if not found then
            table.insert(built.steps, 1, snap)
            found = 1
        else
            built.steps[found] = snap
        end
        index = found
    end
    local prevId = QS.route and QS.route.stepId
    QS.route = built
    QS.route.index = index
    QS.route.log = log
    QS.route.liveId = liveId
    QS.route.stepId = index and built.steps[index] and built.steps[index].id or nil
    QS.char.routeKey = built.key
    QS.Bis.Annotate(built, id)
    local current = index and built.steps[index]
    if current and QS.Bis.Attach then
        QS.Bis.Attach(current, log)
    end
    QS.Clock:OnStep(QS.route.stepId)
    if QS.UI and QS.UI.Refresh then
        QS.UI:Refresh(prevId ~= QS.route.stepId)
    end
    if QS.Pin and QS.Pin.Sync then
        QS.Pin.Sync(index and built.steps[index] or nil)
    end
    QS:DiffEquip()
end

local function SafeRegister(frame, event)
    pcall(frame.RegisterEvent, frame, event)
end

local objReady = false
local objState = {}
local equipReady = false
local equipState = {}

local function PlayDone()
    if type(PlaySoundFile) == "function" then
        local ok, played = pcall(PlaySoundFile, "Sound\\Interface\\PickUp\\PickUpRing.ogg", "Master")
        if ok and played then
            return
        end
        ok, played = pcall(PlaySoundFile, "Sound\\Interface\\iQuestComplete.ogg", "Master")
        if ok and played then
            return
        end
    end
    if type(PlaySound) == "function" and type(SOUNDKIT) == "table" and SOUNDKIT.QUEST_COMPLETED then
        local ok, played = pcall(PlaySound, SOUNDKIT.QUEST_COMPLETED, "Master")
        if ok and played ~= false then
            return
        end
    end
    if type(PlaySound) == "function" then
        pcall(PlaySound, "QUESTCOMPLETED", "Master")
    end
end

function QS:DiffEquip()
    local step = QS.route and QS.route.index and QS.route.steps[QS.route.index]
    local rows = step and step.rewardRows or {}
    local nextState = {}
    local ding = false
    for i = 1, #rows do
        local pick = rows[i]
        if pick.equip and QS.Bis and QS.Bis.Wearing then
            local key = tostring(pick.itemID or "") .. ":" .. tostring(pick.name or "")
            local worn = QS.Bis.Wearing(pick.itemID, pick.name) and true or false
            nextState[key] = worn
            if equipReady and worn and equipState[key] == false then
                ding = true
            end
        end
    end
    equipState = nextState
    if not equipReady then
        equipReady = true
        return
    end
    if ding then
        PlayDone()
    end
end

local function DiffObjectives(inLog)
    if QS.scanningLog or type(inLog) ~= "table" then
        return
    end
    local nextState = {}
    local ding = false
    for id, info in pairs(inLog) do
        local objs = info.objectives or {}
        for i = 1, #objs do
            local key = tostring(id) .. ":" .. i
            local fin = objs[i].finished and true or false
            nextState[key] = fin
            if objReady and fin and objState[key] == false then
                ding = true
            end
        end
        local ckey = "c:" .. tostring(id)
        local complete = info.complete and true or false
        nextState[ckey] = complete
        if objReady and complete and objState[ckey] == false then
            ding = true
        end
    end
    objState = nextState
    if not objReady then
        objReady = true
        return
    end
    if ding then
        PlayDone()
    end
end

local function RecordFlights()
    if not QS.char or type(NumTaxiNodes) ~= "function" or type(TaxiNodeName) ~= "function" then
        return
    end
    if type(QS.char.flights) ~= "table" then
        QS.char.flights = {}
    end
    local flights = QS.char.flights
    local had = next(flights) ~= nil
    local n = NumTaxiNodes() or 0
    local changed = false
    local addedCurrent = false
    local function Mark(key)
        if key and key ~= "" and not flights[key] then
            flights[key] = true
            changed = true
        end
    end
    for i = 1, n do
        local typ = "REACHABLE"
        if type(TaxiNodeGetType) == "function" then
            typ = TaxiNodeGetType(i)
        end
        local name = TaxiNodeName(i)
        if type(name) == "string" and name ~= "" and (typ == "CURRENT" or typ == "REACHABLE") then
            if not flights[name] then
                flights[name] = true
                changed = true
                if typ == "CURRENT" then
                    addedCurrent = true
                end
            end
            if typ == "CURRENT" then
                local zone = GetZoneText and GetZoneText() or ""
                local real = GetRealZoneText and GetRealZoneText() or ""
                local sub = GetSubZoneText and GetSubZoneText() or ""
                Mark("zone:" .. zone)
                if real ~= zone then
                    Mark("zone:" .. real)
                end
                Mark("zone:" .. sub)
            end
        end
    end
    if addedCurrent and had then
        PlayDone()
    end
    if changed then
        QS:RequestRebuild()
    end
end

local function OnQuestRemoved()
    -- Leaving the log without a turn-in must not advance. Resume treats
    -- an accept as open again when the id is neither logged nor completed.
end

local function DiffTurnIns(now)
    local prev = QS.prevInLog
    if prev and QS.char then
        for questID, info in pairs(prev) do
            if info.complete and not now[questID] then
                QS.char.turnedIn[questID] = time()
            end
        end
    end
    QS.prevInLog = now
end

function QS:OnEvent(event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "Stratagem" then
        QS:EnsureReady()
        if UnitLevel("player") and UnitLevel("player") > 0 then
            QS.loggedIn = true
            QS.Config.GuessSpec(false)
            QS:RequestRebuild()
            if QS.UI then
                QS.UI:ApplyShown()
            end
        end
        return
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        QS.loggedIn = true
        QS:EnsureReady()
        QS.Config.GuessSpec(false)
        if QS.Api.QueryCompleted then
            QS.Api.QueryCompleted()
        end
        QS:RequestRebuild()
        if QS.UI then
            QS.UI:ApplyShown()
        end
        return
    end
    if event == "PLAYER_LOGOUT" then
        QS.Clock:SampleXP()
        return
    end
    if not QS.loggedIn then
        return
    end
    if event == "QUEST_TURNED_IN" then
        local questID = arg1
        if type(questID) == "number" and questID > 0 then
            QS.char.turnedIn[questID] = time()
        end
        QS:RequestRebuild()
        return
    end
    if event == "QUEST_ACCEPTED" or event == "QUEST_FINISHED" or event == "QUEST_LOG_UPDATE" or event == "PLAYER_LEVEL_UP" then
        if QS.scanningLog then
            return
        end
        if event == "QUEST_LOG_UPDATE" or event == "QUEST_FINISHED" then
            local now = QS.Api.ReadLog()
            DiffTurnIns(now)
            DiffObjectives(now)
        end
        QS:RequestRebuild()
        return
    end
    if event == "QUEST_REMOVED" then
        OnQuestRemoved()
        local now = QS.Api.ReadLog()
        DiffTurnIns(now)
        DiffObjectives(now)
        QS:RequestRebuild()
        return
    end
    if event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        QS:RequestRebuild()
        return
    end
    if event == "CHARACTER_POINTS_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        QS.Config.GuessSpec(false)
        QS:RequestRebuild()
        return
    end
    if event == "BAG_UPDATE" or event == "SKILL_LINES_CHANGED" or event == "UPDATE_INVENTORY_DURABILITY" or event == "MERCHANT_CLOSED" or event == "BANKFRAME_CLOSED" or event == "AUCTION_HOUSE_CLOSED" or event == "TRAINER_CLOSED" or event == "GOSSIP_CLOSED" then
        QS:RequestRebuild()
        return
    end
    if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
        local text = arg1
        local name
        if type(text) == "string" then
            name = text:match("^(.+) dies%.$") or text:match("slain ([^!]+)!")
        end
        if name and QS.Services and QS.Services.bossNames and QS.Services.bossNames[name] and QS.char then
            QS.char.bossDown[name] = true
            QS:RequestRebuild()
        end
        return
    end
    if event == "QUEST_QUERY_COMPLETE" then
        QS:RequestRebuild()
        return
    end
    if event == "TAXIMAP_OPENED" then
        RecordFlights()
        return
    end
    if event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" then
            QS:RequestRebuild()
        end
        return
    end
    if event == "PLAYER_XP_UPDATE" then
        QS.Clock:SampleXP()
    end
end

function QS:Slash(msg)
    QS:EnsureReady()
    msg = (msg or ""):lower()
    msg = msg:match("^%s*(.-)%s*$") or ""
    if msg == "" then
        QS.UI:Toggle()
    elseif msg == "next" then
        QS.Resume.Next()
    elseif msg == "back" then
        QS.Resume.Back()
    elseif msg == "config" then
        QS.UI:ToggleConfig()
    elseif msg == "where" then
        QS.Resume.Where()
    elseif msg == "reset" then
        QS.Resume.Reset()
    elseif msg == "api" then
        local lines = QS.Api.Probe()
        for i = 1, #lines do
            QS:Print(lines[i])
        end
    elseif msg == "size" then
        QS.UI:CycleSize()
    elseif msg == "demo" then
        QS.char.demo = not QS.char.demo
        QS.char.manualStepId = nil
        QS.char.manualFrontierId = nil
        QS:Print(QS.char.demo and "Demo route on." or "Demo route off.")
        QS:Rebuild()
    elseif msg == "debug" then
        QS.db.debug = not QS.db.debug
        QS:Print(QS.db.debug and "Debug overrides on." or "Debug overrides off.")
        if QS.UI and QS.UI.config then
            QS.UI:RefreshConfig()
        end
    else
        QS:Print("Commands: /qs, next, back, config, where, reset, api, size, demo, debug")
    end
end

local frame = CreateFrame("Frame", "QuestStratagemEventFrame")
QS.eventFrame = frame
frame.acc = 0
frame.saveAcc = 0
frame:SetScript("OnEvent", function(_, event, arg1, arg2)
    QS:OnEvent(event, arg1, arg2)
end)
frame:SetScript("OnUpdate", function(self, elapsed)
    if self.rebuildAt and GetTime() >= self.rebuildAt then
        self.rebuildAt = nil
        QS:Rebuild()
    end
    if not QS.loggedIn then
        return
    end
    self.acc = self.acc + elapsed
    if self.acc < 0.1 then
        return
    end
    local dt = self.acc
    self.acc = 0
    QS.Clock:Tick(dt)
    self.saveAcc = self.saveAcc + dt
    if self.saveAcc >= 30 then
        self.saveAcc = 0
        QS.Clock:SampleXP()
    end
    if QS.UI and QS.char and QS.char.shown then
        QS.UI:OnTick()
    end
    self.liveAcc = (self.liveAcc or 0) + dt
    if self.liveAcc >= 2 and QS.route and QS.route.index and QS.char then
        self.liveAcc = 0
        local step = QS.route.steps[QS.route.index]
        local live = step and (step.kind == "boss" or step.kind == "kills" or string.sub(step.id or "", 1, 4) == "dyn-")
        if live and QS.Resume.Done(step, QS.route.log or QS.Api.Snapshot()) then
            QS:RequestRebuild()
        end
    end
end)

SafeRegister(frame, "ADDON_LOADED")
SafeRegister(frame, "PLAYER_LOGIN")
SafeRegister(frame, "PLAYER_ENTERING_WORLD")
SafeRegister(frame, "PLAYER_LOGOUT")
SafeRegister(frame, "PLAYER_LEVEL_UP")
SafeRegister(frame, "PLAYER_XP_UPDATE")
SafeRegister(frame, "QUEST_ACCEPTED")
SafeRegister(frame, "QUEST_TURNED_IN")
SafeRegister(frame, "QUEST_FINISHED")
SafeRegister(frame, "QUEST_LOG_UPDATE")
SafeRegister(frame, "QUEST_REMOVED")
SafeRegister(frame, "QUEST_QUERY_COMPLETE")
SafeRegister(frame, "ZONE_CHANGED_NEW_AREA")
SafeRegister(frame, "ZONE_CHANGED")
SafeRegister(frame, "ZONE_CHANGED_INDOORS")
SafeRegister(frame, "CHARACTER_POINTS_CHANGED")
SafeRegister(frame, "PLAYER_TALENT_UPDATE")
SafeRegister(frame, "BAG_UPDATE")
SafeRegister(frame, "SKILL_LINES_CHANGED")
SafeRegister(frame, "UPDATE_INVENTORY_DURABILITY")
SafeRegister(frame, "MERCHANT_CLOSED")
SafeRegister(frame, "BANKFRAME_CLOSED")
SafeRegister(frame, "AUCTION_HOUSE_CLOSED")
SafeRegister(frame, "TRAINER_CLOSED")
SafeRegister(frame, "GOSSIP_CLOSED")
SafeRegister(frame, "CHAT_MSG_COMBAT_HOSTILE_DEATH")
SafeRegister(frame, "TAXIMAP_OPENED")
SafeRegister(frame, "UNIT_INVENTORY_CHANGED")

SLASH_QUESTSTRATAGEM1 = "/qs"
SLASH_QUESTSTRATAGEM2 = "/stratagem"
SlashCmdList["QUESTSTRATAGEM"] = function(msg)
    QS:Slash(msg)
end
-- A second list entry keeps /stratagem on its own first alias. Some clients
-- only hash SLASH_<NAME>1 when the list entry is assigned.
SLASH_STRATAGEM1 = "/stratagem"
SlashCmdList["STRATAGEM"] = function(msg)
    QS:Slash(msg)
end
