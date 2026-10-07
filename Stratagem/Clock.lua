QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Clock = {}
QS.Clock = Clock

local GOAL_BASE = 72 * 3600

function Clock:Tick(dt)
    local char = QS.char
    if not char or not QS.loggedIn then
        return
    end
    char.totalSeconds = (char.totalSeconds or 0) + dt
end

function Clock:SampleXP()
    local char = QS.char
    local leg = char and char.legStart
    if not leg then
        return
    end
    local xp = UnitXP("player") or 0
    local level = UnitLevel("player") or 1
    local maxp = UnitXPMax("player") or 0
    if leg.lastXP == nil then
        leg.lastXP = xp
        leg.lastLevel = level
        leg.lastMax = maxp
        leg.xp = leg.xp or 0
        return
    end
    local gained = 0
    if level > (leg.lastLevel or level) then
        gained = ((leg.lastMax or 0) - (leg.lastXP or 0)) + xp
        if gained < 0 then
            gained = 0
        end
    elseif xp >= (leg.lastXP or 0) then
        gained = xp - leg.lastXP
    end
    leg.xp = (leg.xp or 0) + gained
    leg.lastXP = xp
    leg.lastLevel = level
    leg.lastMax = maxp
end

function Clock:CloseLeg()
    local char = QS.char
    local leg = char and char.legStart
    if not leg or not leg.epoch then
        return
    end
    self:SampleXP()
    local seconds = math.max(0, time() - leg.epoch)
    local xp = leg.xp or 0
    local prev = char.lastLeg
    -- A rebuild that flips the step for a moment must not erase the recorded leg.
    if not (seconds < 15 and xp <= 0 and prev and (prev.seconds or 0) >= 15) then
        char.lastLeg = {
            seconds = seconds,
            xp = xp,
        }
    end
    char.legStart = nil
end

function Clock:OnStep(stepId)
    local char = QS.char
    if not char then
        return
    end
    local leg = char.legStart
    if stepId and leg and leg.id == stepId then
        return
    end
    if leg then
        self:CloseLeg()
    end
    if not stepId then
        return
    end
    char.legStart = {
        id = stepId,
        epoch = time(),
        xp = 0,
        lastXP = UnitXP("player") or 0,
        lastLevel = UnitLevel("player") or 1,
        lastMax = UnitXPMax("player") or 0,
    }
end

function Clock.GoalSeconds()
    return GOAL_BASE * QS.Config.ClassMod() * QS.Config.PaceMod()
end

function Clock.FormatTracked(seconds)
    seconds = math.floor(seconds or 0)
    if seconds < 0 then
        seconds = 0
    end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 0 then
        return string.format("%dh %dm", h, m)
    end
    if m > 0 then
        return string.format("%dm", m)
    end
    return string.format("%ds", seconds % 60)
end

function Clock.FormatHours(seconds)
    local h = math.floor((seconds / 3600) + 0.5)
    if h < 1 then
        h = 1
    end
    return h .. "h"
end

function Clock.FormatLeg(leg)
    if not leg or not leg.seconds then
        return "Last leg: —"
    end
    local seconds = math.floor(leg.seconds + 0.5)
    if seconds < 0 then
        seconds = 0
    end
    local text
    if seconds < 60 then
        text = seconds .. "s"
    else
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        if hours > 0 then
            text = string.format("%dh %dm", hours, minutes)
        else
            text = minutes .. " min"
        end
    end
    return string.format("Last leg: %s · +%s XP", text, Clock.Comma(leg.xp or 0))
end

function Clock.Comma(n)
    local s = tostring(math.floor((n or 0) + 0.5))
    local left
    repeat
        s, left = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until left == 0
    return s
end

function Clock.Header()
    local char = QS.char
    local level = UnitLevel("player") or 1
    local xp = UnitXP("player") or 0
    local xpMax = UnitXPMax("player") or 0
    local plan = QS.route and QS.route.levelPlan
    local spec, confirmed = QS.Config.ActiveSpec()
    local line
    if plan and QS.Level and xpMax > 0 then
        if level >= 60 then
            line = string.format("L60 · %s/%s", Clock.Comma(xp), Clock.Comma(xpMax))
        else
            local eta = Clock.FormatTracked(QS.Level.RemainingSeconds(plan))
            line = string.format("L%d in %s · %s/%s", level + 1, eta, Clock.Comma(xp), Clock.Comma(xpMax))
        end
    else
        local goal = Clock.FormatHours(Clock.GoalSeconds())
        local tracked = Clock.FormatTracked(char and char.totalSeconds or 0)
        line = string.format("Goal %s · Tracked %s · L%d", goal, tracked, level)
    end
    if not confirmed then
        line = line .. " · Spec assumed: " .. QS.Config.SpecLabel(spec)
    end
    return line
end

function Clock.RemainingSeconds(steps, index, log)
    if not steps or not index then
        return 0
    end
    local minutes = 0
    local skips = (QS.char and QS.char.skips) or {}
    for i = index, #steps do
        local step = steps[i]
        if not skips[step.id] and not QS.Resume.Done(step, log) then
            minutes = minutes + (step.minutes or 0)
        end
    end
    return minutes * 60 * QS.Config.ClassMod() * QS.Config.PaceMod()
end
