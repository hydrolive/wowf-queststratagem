QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

QS.VERSION = "0.1.0"
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
    manualStepId = nil,
    manualFrontierId = nil,
    turnedIn = {},
    legStart = nil,
    lastLeg = nil,
    totalSeconds = 0,
    dungeonDetours = true,
    bisCallouts = true,
    classQuests = true,
    professionSteps = false,
    includeStubs = false,
    routeKey = nil,
    demo = false,
    shown = true,
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
    DEFAULT_CHAT_FRAME:AddMessage("|cffFFD100QuestStratagem|r " .. tostring(msg))
end

function QS:InitDB()
    QuestStratagemDB = FillDefaults(QuestStratagemDB or {}, GLOBAL_DEFAULTS)
    QuestStratagemCharDB = FillDefaults(QuestStratagemCharDB or {}, CHAR_DEFAULTS)
    if type(QuestStratagemCharDB.skips) ~= "table" then
        QuestStratagemCharDB.skips = {}
    end
    if type(QuestStratagemCharDB.turnedIn) ~= "table" then
        QuestStratagemCharDB.turnedIn = {}
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
    local index = QS.Resume.Choose(built.steps, log, QS.char)
    local prevId = QS.route and QS.route.stepId
    QS.route = built
    QS.route.index = index
    QS.route.log = log
    QS.route.stepId = index and built.steps[index] and built.steps[index].id or nil
    QS.char.routeKey = built.key
    QS.Bis.Annotate(built, id)
    QS.Clock:OnStep(QS.route.stepId)
    if QS.UI and QS.UI.Refresh then
        QS.UI:Refresh(prevId ~= QS.route.stepId)
    end
end

local function SafeRegister(frame, event)
    pcall(frame.RegisterEvent, frame, event)
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
    if event == "ADDON_LOADED" and arg1 == "QuestStratagem" then
        QS:InitDB()
        if QS.UI and not QS.UI.frame then
            QS.UI:Init()
        end
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
        QS.Config.GuessSpec(false)
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
        if event == "QUEST_LOG_UPDATE" or event == "QUEST_FINISHED" then
            DiffTurnIns(QS.Api.ReadLog())
        end
        QS:RequestRebuild()
        return
    end
    if event == "QUEST_REMOVED" then
        OnQuestRemoved()
        DiffTurnIns(QS.Api.ReadLog())
        QS:RequestRebuild()
        return
    end
    if event == "ZONE_CHANGED_NEW_AREA" then
        if QS.UI then
            QS.UI:Refresh(false)
        end
        return
    end
    if event == "CHARACTER_POINTS_CHANGED" then
        QS.Config.GuessSpec(false)
        if QS.UI then
            QS.UI:Refresh(false)
        end
        return
    end
    if event == "PLAYER_XP_UPDATE" then
        QS.Clock:SampleXP()
    end
end

function QS:Slash(msg)
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
SafeRegister(frame, "ZONE_CHANGED_NEW_AREA")
SafeRegister(frame, "CHARACTER_POINTS_CHANGED")

SLASH_QUESTSTRATAGEM1 = "/qs"
SlashCmdList["QUESTSTRATAGEM"] = function(msg)
    QS:Slash(msg)
end
