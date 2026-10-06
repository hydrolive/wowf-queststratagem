QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local UI = {}
QS.UI = UI

local SIZES = {
    large = { 460, 340 },
    medium = { 460, 64 },
    small = { 168, 52 },
}
local NEXT_SIZE = { large = "medium", medium = "small", small = "large" }

local function RGB(c, a)
    return c[1], c[2], c[3], a or 1
end

local function Strip(parent, layer)
    local tex = parent:CreateTexture(nil, layer or "BACKGROUND")
    tex:SetColorTexture(1, 1, 1, 1)
    return tex
end

local function Edge(frame)
    local bg = Strip(frame, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(RGB(QS.COLOR.bg))
    local function line(point, rel, x, y, w, h)
        local t = Strip(frame, "BORDER")
        t:SetColorTexture(RGB(QS.COLOR.edge))
        t:SetPoint(point, frame, rel or point, x or 0, y or 0)
        if w then
            t:SetSize(w, h)
        end
        return t
    end
    local top = line("TOPLEFT", "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    top:SetHeight(1)
    local bot = line("BOTTOMLEFT", "BOTTOMLEFT", 0, 0)
    bot:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bot:SetHeight(1)
    local left = line("TOPLEFT", "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    left:SetWidth(1)
    local right = line("TOPRIGHT", "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(1)
    for _, corner in ipairs({
        { "TOPLEFT", 0, 0 },
        { "TOPRIGHT", 0, 0 },
        { "BOTTOMLEFT", 0, 0 },
        { "BOTTOMRIGHT", 0, 0 },
    }) do
        local c = Strip(frame, "OVERLAY")
        c:SetColorTexture(RGB(QS.COLOR.edge))
        c:SetSize(4, 4)
        c:SetPoint(corner[1], frame, corner[1], corner[2], corner[3])
    end
end

local function Click(button, fn)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(self, btn)
        if btn == "RightButton" then
            UI:CycleSize()
            return
        end
        fn(self)
    end)
end

local function TextButton(parent, label, w, h, r, g, b)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(w, h)
    local bg = Strip(button, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(r, g, b, 1)
    local fs = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER")
    fs:SetText(label)
    fs:SetTextColor(RGB(QS.COLOR.body))
    button.label = fs
    button.bg = bg
    button:SetScript("OnEnter", function()
        bg:SetColorTexture(math.min(1, r + 0.08), math.min(1, g + 0.06), math.min(1, b + 0.04), 1)
    end)
    button:SetScript("OnLeave", function()
        bg:SetColorTexture(r, g, b, 1)
    end)
    return button
end

function UI:CycleSize()
    local size = QS.char.size or "large"
    QS.char.size = NEXT_SIZE[size] or "large"
    self:ApplySize()
    self:Refresh(true)
end

function UI:Toggle()
    if not self.frame then
        return
    end
    if self.frame:IsShown() then
        self.frame:Hide()
        QS.char.shown = false
    else
        self.frame:Show()
        QS.char.shown = true
        self:Refresh(true)
    end
end

function UI:ApplyShown()
    if not self.frame then
        return
    end
    if QS.char.shown == false then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function UI:ApplySize()
    local size = (QS.char and QS.char.size) or "large"
    if not SIZES[size] then
        size = "large"
    end
    local w, h = SIZES[size][1], SIZES[size][2]
    local frame = self.frame
    frame:SetSize(w, h)
    local large = size == "large"
    local medium = size == "medium"
    local small = size == "small"
    self.title:SetShown(large)
    self.closeBtn:SetShown(large)
    self.sizeBtn:SetShown(large)
    self.gearBtn:SetShown(large)
    if self.pathBtn then
        self.pathBtn:SetShown(large)
    end
    if not large and self.pathPanel then
        self.pathPanel:Hide()
    end
    self.status:SetShown(large)
    self.lastLeg:SetShown(large)
    self.goal:SetShown(large)
    self.goalHit:SetShown(large)
    self.nextBtn:SetShown(large)
    self:ApplyBack()
    self.warning:SetShown(large)
    self.route:SetShown(large)
    self.indexText:SetShown(large)
    self.body:SetShown(large)
    self.goalHeader:SetShown(large)
    self.footer:SetShown(large)
    for i = 1, #self.goalRows do
        if not large then
            self.goalRows[i].name:Hide()
            self.goalRows[i].count:Hide()
            if self.goalRows[i].icon then
                self.goalRows[i].icon:Hide()
            end
        end
    end
    self.stepTitle:SetShown(large or medium)
    self.dist:SetShown(true)
    self.segments:SetShown(large or medium)
    self.arrow:SetShown(true)

    self.arrow:ClearAllPoints()
    self.dist:ClearAllPoints()
    self.stepTitle:ClearAllPoints()
    self.segments:ClearAllPoints()

    if large then
        self.arrow:SetSize(28, 28)
        self.arrow:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -148)
        self.stepTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 52, -146)
        self.stepTitle:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
        self.dist:SetPoint("TOPLEFT", frame, "TOPLEFT", 52, -164)
        self.dist:SetJustifyH("LEFT")
        self.segments:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -128)
        self.segments:SetSize(428, 8)
    elseif medium then
        self.arrow:SetSize(28, 28)
        self.arrow:SetPoint("LEFT", frame, "LEFT", 12, 6)
        self.stepTitle:SetPoint("LEFT", self.arrow, "RIGHT", 8, 8)
        self.stepTitle:SetPoint("RIGHT", self.dist, "LEFT", -8, 0)
        self.dist:SetPoint("RIGHT", frame, "RIGHT", -12, 8)
        self.dist:SetJustifyH("RIGHT")
        self.segments:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 8)
        self.segments:SetSize(436, 6)
    else
        self.arrow:SetSize(26, 26)
        self.arrow:SetPoint("LEFT", frame, "LEFT", 10, 0)
        self.dist:SetPoint("LEFT", self.arrow, "RIGHT", 8, 0)
        self.dist:SetJustifyH("LEFT")
    end
end

function UI:ClusterProgress()
    local route = QS.route
    if not route or not route.index or not route.steps[route.index] then
        return 0, 0
    end
    local cluster = route.steps[route.index].cluster
    local count, pos = 0, 1
    for i = 1, #route.steps do
        if route.steps[i].cluster == cluster then
            count = count + 1
            if i == route.index then
                pos = count
            end
        end
    end
    return pos, count
end

function UI:LayoutLevelBar()
    local plan = QS.route and QS.route.levelPlan
    if not plan or not QS.Level then
        return false
    end
    local parts = QS.Level.Visual(plan)
    if not parts or #parts < 1 then
        return false
    end
    local bar = self.segments
    if not bar or not bar.segs then
        return false
    end
    local width = bar:GetWidth()
    if not width or width < 20 then
        width = 428
    end
    local total = 0
    for i = 1, #parts do
        total = total + (parts[i].xp or 0)
    end
    if total < 1 then
        total = 1
    end
    local gap = 2
    local gaps = (#parts - 1) * gap
    if gaps < 0 then
        gaps = 0
    end
    local usable = width - gaps
    if usable < #parts then
        usable = #parts
    end
    local x = 0
    for i = 1, 16 do
        local seg = bar.segs[i]
        local part = parts[i]
        if part and seg then
            local segW = usable * ((part.xp or 0) / total)
            if segW < 2 then
                segW = 2
            end
            seg:Show()
            seg:ClearAllPoints()
            seg:SetSize(segW, bar:GetHeight() > 0 and bar:GetHeight() or 8)
            seg:SetPoint("LEFT", bar, "LEFT", x, 0)
            if part.filled and part.filled >= 1 then
                seg:SetColorTexture(RGB(QS.COLOR.fill))
            elseif i == 1 or (parts[i - 1] and parts[i - 1].filled and parts[i - 1].filled >= 1) then
                seg:SetColorTexture(1, 0.92, 0.55, 1)
            else
                seg:SetColorTexture(RGB(QS.COLOR.empty))
            end
            x = x + segW + gap
        elseif seg then
            seg:Hide()
        end
    end
    return true
end

function UI:LayoutSegments(pos, count)
    local bar = self.segments
    if count < 1 then
        count = 1
        pos = 1
    end
    if count > 16 then
        count = 16
    end
    local width = bar:GetWidth()
    if not width or width < 20 then
        width = 428
    end
    local gap = 2
    local segW = (width - gap * (count - 1)) / count
    for i = 1, 16 do
        local seg = bar.segs[i]
        if i <= count then
            seg:Show()
            seg:ClearAllPoints()
            seg:SetSize(math.max(2, segW), bar:GetHeight() > 0 and bar:GetHeight() or 8)
            seg:SetPoint("LEFT", bar, "LEFT", (i - 1) * (segW + gap), 0)
            if i < pos then
                seg:SetColorTexture(RGB(QS.COLOR.fill))
            elseif i == pos then
                seg:SetColorTexture(1, 0.92, 0.55, 1)
            else
                seg:SetColorTexture(RGB(QS.COLOR.empty))
            end
        else
            seg:Hide()
        end
    end
end

local function GoalText(step, log)
    local rows = {}
    local header = step.questName or step.title or ""
    if step.kind == "accept" then
        header = "Pick up"
        if step.goals then
            for i = 1, #step.goals do
                rows[#rows + 1] = { name = step.goals[i].name, count = "" }
            end
        elseif step.questIDs then
            for i = 1, #step.questIDs do
                rows[#rows + 1] = { name = "Quest " .. step.questIDs[i], count = "" }
            end
        else
            rows[#rows + 1] = { name = (step.npc or "NPC") .. " · " .. (step.zone or ""), count = "" }
        end
    elseif step.kind == "objective" then
        header = step.questName or step.title
        local info = step.questID and log and log.inLog[step.questID]
        if step.goals then
            for i = 1, #step.goals do
                local g = step.goals[i]
                local count = ""
                if g.need and g.need > 0 then
                    count = (g.have or 0) .. "/" .. g.need
                end
                rows[#rows + 1] = { name = g.name, count = count }
            end
        elseif info and info.objectives and #info.objectives > 0 then
            for i = 1, #info.objectives do
                local o = info.objectives[i]
                local count = ""
                if o.need and o.need > 0 then
                    count = (o.have or 0) .. "/" .. o.need
                elseif o.finished then
                    count = "done"
                end
                rows[#rows + 1] = { name = o.text or ("Objective " .. i), count = count }
            end
        else
            rows[#rows + 1] = { name = step.text or "Objective", count = "" }
        end
    else
        header = step.goalHeader or step.questName or step.title or ""
        if step.goals and #step.goals > 0 then
            for i = 1, #step.goals do
                local g = step.goals[i]
                local count = ""
                if g.need and g.need > 0 then
                    count = (g.have or 0) .. "/" .. g.need
                end
                rows[#rows + 1] = { name = g.name, count = count }
            end
            return header, rows
        end
        if step.kind == "turnin" or step.kind == "hearth" or step.kind == "train" then
            rows[#rows + 1] = { name = (step.npc or "NPC") .. " · " .. (step.zone or ""), count = "" }
        elseif step.text then
            rows[#rows + 1] = { name = step.text, count = "" }
        end
    end
    return header, rows
end

local function ShowItemTip(owner)
    if not GameTooltip then
        return
    end
    local link = owner.link
    local itemID = owner.itemID
    if (not link or link == "") and not itemID then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if link and link ~= "" then
        GameTooltip:SetHyperlink(link)
    elseif GameTooltip.SetItemByID then
        GameTooltip:SetItemByID(itemID)
    else
        GameTooltip:SetHyperlink("item:" .. itemID)
    end
    GameTooltip:Show()
end

local function RowTexture(src)
    if src.texture and src.texture ~= "" then
        return src.texture
    end
    if src.itemID and src.itemID ~= 0 and type(GetItemInfo) == "function" then
        local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(src.itemID)
        return tex
    end
    return nil
end

function UI:ApplyBack()
    if not self.backBtn then
        return
    end
    local large = ((QS.char and QS.char.size) or "large") == "large"
    local show = large and QS.Resume and QS.Resume.CanBack and QS.Resume.CanBack(QS.char)
    self.backBtn:SetShown(show and true or false)
end

function UI:FitGoals(shown)
    if not self.frame then
        return
    end
    local size = (QS.char and QS.char.size) or "large"
    local h = SIZES[size] and SIZES[size][2] or 340
    if size == "large" and shown and shown > 5 then
        h = h + (shown - 5) * 16
    end
    self.frame:SetHeight(h)
end

function UI:PaintGoals(step, log)
    local header, rows = "", {}
    if step then
        header, rows = GoalText(step, log)
        if step.extraGoals then
            for i = 1, #step.extraGoals do
                local g = step.extraGoals[i]
                local count = ""
                if g.need and g.need > 0 then
                    count = (g.have or 0) .. "/" .. g.need
                end
                rows[#rows + 1] = { name = g.name, count = count }
            end
        end
    end
    local reward = (step and step.rewardRows) or {}
    local bis = (QS.route and QS.route.index and QS.route.bisRows and QS.route.bisRows[QS.route.index]) or {}
    for i = 1, #bis do
        if not (#reward > 0 and bis[i].reward) then
            rows[#rows + 1] = {
                name = QS.Bis.Line(bis[i]),
                count = "",
                bis = true,
                itemID = bis[i].itemID,
            }
        end
    end
    for i = 1, #reward do
        local pick = reward[i]
        rows[#rows + 1] = {
            name = pick.text or pick.name or "Reward",
            count = "",
            bis = true,
            link = pick.link,
            itemID = pick.itemID,
            texture = pick.texture,
        }
        if pick.equip and pick.name and QS.Bis and QS.Bis.Wearing then
            local worn = QS.Bis.Wearing(pick.itemID, pick.name)
            rows[#rows + 1] = {
                name = "Equip " .. pick.name,
                count = worn and "1/1" or "0/1",
                bis = true,
                link = pick.link,
                itemID = pick.itemID,
                texture = pick.texture,
            }
        end
    end
    if QS.char and QS.char.size ~= "large" then
        self.goalHeader:Hide()
        for i = 1, #self.goalRows do
            local row = self.goalRows[i]
            row.name:Hide()
            row.count:Hide()
            row.icon:Hide()
        end
        self:FitGoals(0)
        return
    end
    self.goalHeader:Show()
    self.goalHeader:SetText(header)
    local limit = #self.goalRows
    local shown = #rows
    if shown > limit then
        shown = limit
    end
    for i = 1, limit do
        local row = self.goalRows[i]
        local src = rows[i]
        local overflow = (i == limit and #rows > limit)
        if src and not overflow then
            row.name:SetText(src.name)
            row.count:SetText(src.count or "")
            local color = src.bis and QS.COLOR.bis or QS.COLOR.body
            row.name:SetTextColor(RGB(color))
            row.count:SetTextColor(RGB(QS.COLOR.muted))
            local tex = RowTexture(src)
            local y = -250 - (i - 1) * 16
            row.name:ClearAllPoints()
            if tex or src.itemID or (src.link and src.link ~= "") then
                row.icon.tex:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.icon.link = src.link
                row.icon.itemID = src.itemID
                row.icon:Show()
                row.name:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 36, y)
                row.name:SetWidth(300)
            else
                row.icon:Hide()
                row.icon.link = nil
                row.icon.itemID = nil
                row.name:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 28, y)
                row.name:SetWidth(320)
            end
            row.name:Show()
            row.count:Show()
        elseif overflow then
            row.name:ClearAllPoints()
            row.name:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 28, -250 - (i - 1) * 16)
            row.name:SetWidth(320)
            row.name:SetText("+" .. (#rows - limit + 1) .. " more in /qs where")
            row.name:SetTextColor(RGB(QS.COLOR.muted))
            row.count:SetText("")
            row.icon:Hide()
            row.icon.link = nil
            row.icon.itemID = nil
            row.name:Show()
            row.count:Hide()
        else
            row.name:Hide()
            row.count:Hide()
            row.icon:Hide()
            row.icon.link = nil
            row.icon.itemID = nil
        end
    end
    self:FitGoals(shown)
end

local function ShowArrow(arrow, measure, step)
    if measure.mode == "ok" then
        arrow:Show()
        arrow:SetRotation(measure.angle or 0)
        return
    end
    if measure.mode == "instance" or not (step and step.x and step.y) then
        arrow:Hide()
        return
    end
    arrow:Show()
    arrow:SetRotation(0)
end

function UI:Refresh()
    if not self.frame then
        return
    end
    local route = QS.route
    local step = route and route.index and route.steps[route.index]
    local log = route and route.log
    local measure = QS.Arrow.Measure(step)
    self.measure = measure
    ShowArrow(self.arrow, measure, step)
    local dist = QS.Arrow.DistanceText(measure, step)
    self.dist:SetText(dist)
    if step then
        local pos = self:ClusterProgress()
        local title = step.title or "Step"
        if step.review and log and QS.Resume.Done(step, log) then
            title = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t " .. title
        end
        self.stepTitle:SetText(pos .. ". " .. title)
        self.body:SetText(step.text or "")
    else
        self.stepTitle:SetText("Route complete")
        self.body:SetText("Every authored step is done or skipped.")
        self.dist:SetText("—")
    end
    self.status:SetText(QS.Resume.Status(step, log or { inLog = {}, completed = {} }, measure))
    self.lastLeg:SetText(QS.Clock.FormatLeg(QS.char and QS.char.lastLeg))
    self.goal:SetText(QS.Clock.Header())
    self.route:SetText(QS.Resume.RouteLine(QS.char, step, log))
    local pos, count = self:ClusterProgress()
    if self:LayoutLevelBar() then
        local xp = UnitXP("player") or 0
        local xpMax = UnitXPMax("player") or 0
        local pct = 0
        if xpMax > 0 then
            pct = math.floor((xp / xpMax) * 100 + 0.5)
        end
        self.indexText:SetText(pct .. "%")
        self.lastXp = xp
    elseif count > 0 then
        self.indexText:SetText(pos .. "/" .. count)
        self:LayoutSegments(pos, count)
    else
        self.indexText:SetText("—")
        self:LayoutSegments(pos, count)
    end
    local warn = route and route.warning
    if warn and QS.char.size == "large" then
        self.warning:SetText(warn)
        self.warning:Show()
    else
        self.warning:Hide()
    end
    self:PaintGoals(step, log)
    self:ApplyBack()
    self.footer:SetText("Data " .. QS.DATA_VERSION)
    if self.config and self.config:IsShown() then
        self:RefreshConfig()
    end
    if self.pathPanel and self.pathPanel:IsShown() then
        self:PaintPath()
    end
end

function UI:OnTick()
    if not self.frame or not self.frame:IsShown() then
        return
    end
    local route = QS.route
    local step = route and route.index and route.steps[route.index]
    local measure = QS.Arrow.Measure(step)
    ShowArrow(self.arrow, measure, step)
    local yards = measure.yards and math.floor(measure.yards + 0.5) or nil
    if yards ~= self.lastYards or measure.word ~= self.lastWord or measure.mode ~= self.lastMode then
        self.lastYards = yards
        self.lastWord = measure.word
        self.lastMode = measure.mode
        self.dist:SetText(QS.Arrow.DistanceText(measure, step))
        local log = route and route.log or { inLog = {}, completed = {} }
        self.status:SetText(QS.Resume.Status(step, log, measure))
    end
    local sec = math.floor((QS.char and QS.char.totalSeconds) or 0)
    local xp = UnitXP("player") or 0
    if self.goal and (sec ~= self.lastSec or xp ~= self.lastXp) then
        self.lastSec = sec
        self.lastXp = xp
        self.goal:SetText(QS.Clock.Header())
        if QS.route and QS.route.levelPlan then
            self:LayoutLevelBar()
            local xpMax = UnitXPMax("player") or 0
            local pct = 0
            if xpMax > 0 then
                pct = math.floor((xp / xpMax) * 100 + 0.5)
            end
            self.indexText:SetText(pct .. "%")
            if step and step.kind == "kills" and step.goals and step.goals[1] then
                local gained = xp - (step.xpStart or 0)
                if gained < 0 then
                    gained = 0
                end
                local have = math.floor(gained / (step.xpPerKill or 1))
                local need = step.goals[1].need or 0
                if have > need then
                    have = need
                end
                step.goals[1].have = have
                self:PaintGoals(step, route and route.log)
            end
        end
    end
end

function UI:ToggleConfig()
    if not self.config then
        return
    end
    if self.config:IsShown() then
        self.config:Hide()
    else
        self.config:Show()
        self:RefreshConfig()
    end
    if self.frame and not self.frame:IsShown() then
        self.frame:Show()
        QS.char.shown = true
    end
end

function UI:RefreshConfig()
    local id = QS.Config.Identity()
    local char = QS.char
    self.config.faction:SetText("Faction: " .. id.faction .. " (detected)")
    self.config.race:SetText("Race: " .. id.race)
    self.config.class:SetText("Class: " .. id.class)
    self.config.raw:SetText("Client: " .. tostring(id.locRace) .. " / " .. tostring(id.raceFile))
    local spec = QS.Config.ActiveSpec()
    local keys = QS.Config.SpecOptions(id.classFile)
    for i = 1, 3 do
        local button = self.config.specs[i]
        local key = keys[i]
        if key then
            button:Show()
            button.key = key
            local treeName
            if GetTalentTabInfo then
                treeName = GetTalentTabInfo(i)
            end
            button.label:SetText(treeName or QS.Config.SpecLabel(key))
            if key == spec then
                button.bg:SetColorTexture(0.45, 0.34, 0.12, 1)
            else
                button.bg:SetColorTexture(0.18, 0.16, 0.13, 1)
            end
        else
            button:Hide()
        end
    end
    local confirmed = char.specConfirmed and "confirmed" or "not confirmed"
    self.config.specState:SetText("Spec " .. confirmed)
    for i = 1, #self.config.paces do
        local button = self.config.paces[i]
        if button.key == char.pace then
            button.bg:SetColorTexture(0.45, 0.34, 0.12, 1)
        else
            button.bg:SetColorTexture(0.18, 0.16, 0.13, 1)
        end
    end
    for i = 1, #self.config.checks do
        local row = self.config.checks[i]
        row.box:SetText(char[row.key] and "[x]" or "[ ]")
    end
    local strays = (QS.Resume and QS.Resume.StrayQuests and QS.Resume.StrayQuests(QS.route)) or {}
    local clean = self.config.clean
    clean.strays = strays
    local n = #strays
    local word = "Quests"
    if n == 1 then
        word = "Quest"
    end
    self.config.cleanNote:SetText("Removes " .. n .. " " .. word)
    if n > 0 then
        clean.bg:SetColorTexture(0.45, 0.16, 0.12, 1)
        self.config.cleanNote:SetTextColor(RGB(QS.COLOR.body))
    else
        clean.bg:SetColorTexture(0.22, 0.16, 0.12, 1)
        self.config.cleanNote:SetTextColor(RGB(QS.COLOR.muted))
    end
    local debug = QS.db and QS.db.debug
    self.config.debugBlock:SetShown(debug and true or false)
end

local function PlaceMinimap(button, angle)
    local radius = 78
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local PATH_VISIBLE = 16

function UI:PaintPath()
    if not self.pathPanel or not self.pathPanel:IsShown() then
        return
    end
    local rows, focus = QS.Resume.PathRows(QS.route)
    self.pathRows = rows
    local level = UnitLevel("player") or 1
    local xp = UnitXP("player") or 0
    local xpMax = UnitXPMax("player") or 0
    local label, fraction = QS.Resume.Journey(level, xp, xpMax)
    self.pathLabel:SetText(label)
    local width = 308
    if fraction <= 0 then
        self.pathFill:Hide()
    else
        self.pathFill:Show()
        self.pathFill:SetWidth(math.max(1, math.floor(width * fraction + 0.5)))
    end
    local maxOffset = #rows - PATH_VISIBLE
    if maxOffset < 0 then
        maxOffset = 0
    end
    local nowId = rows[focus] and rows[focus].id
    if self.pathStick ~= nowId then
        self.pathStick = nowId
        local want = focus - 4
        if want < 0 then
            want = 0
        end
        if want > maxOffset then
            want = maxOffset
        end
        self.pathOffset = want
    end
    if not self.pathOffset or self.pathOffset < 0 then
        self.pathOffset = 0
    end
    if self.pathOffset > maxOffset then
        self.pathOffset = maxOffset
    end
    for i = 1, PATH_VISIBLE do
        local line = self.pathLines[i]
        local src = rows[self.pathOffset + i]
        if src then
            line:Show()
            local title = src.title or "Step"
            if src.state == "done" then
                title = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12|t " .. title
                line.name:SetTextColor(RGB(QS.COLOR.muted))
            elseif src.state == "now" then
                line.name:SetTextColor(RGB(QS.COLOR.gold))
            elseif src.state == "skip" then
                line.name:SetTextColor(RGB(QS.COLOR.muted))
            else
                line.name:SetTextColor(RGB(QS.COLOR.body))
            end
            line.name:SetText(title)
            if src.zone and src.zone ~= "" then
                line.zone:SetText(src.zone)
                line.zone:Show()
            else
                line.zone:Hide()
            end
            if src.state == "now" then
                line.bg:Show()
            else
                line.bg:Hide()
            end
        else
            line:Hide()
        end
    end
    local bar = self.pathScroll
    self.pathMax = maxOffset
    if maxOffset <= 0 then
        bar:Hide()
    else
        bar:Show()
        self.pathLock = true
        bar:SetMinMaxValues(0, maxOffset)
        bar:SetValue(maxOffset - self.pathOffset)
        self.pathLock = false
    end
end

function UI:TogglePath()
    if not self.pathPanel then
        return
    end
    if self.pathPanel:IsShown() then
        self.pathPanel:Hide()
        return
    end
    self.pathStick = nil
    self.pathPanel:Show()
    self:PaintPath()
end

function UI:BuildPath()
    local panel = CreateFrame("Frame", "QuestStratagemPath", UIParent)
    panel:SetSize(340, 440)
    panel:SetFrameStrata("HIGH")
    panel:SetClampedToScreen(true)
    panel:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", -8, 0)
    panel:EnableMouse(true)
    panel:Hide()
    Edge(panel)
    self.pathPanel = panel

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Path")
    title:SetTextColor(RGB(QS.COLOR.gold))

    local close = TextButton(panel, "X", 18, 18, 0.22, 0.16, 0.12)
    close:SetPoint("TOPRIGHT", -8, -8)
    Click(close, function()
        panel:Hide()
    end)

    local track = CreateFrame("Frame", nil, panel)
    track:SetPoint("TOPLEFT", 16, -40)
    track:SetSize(308, 16)
    local empty = Strip(track, "BACKGROUND")
    empty:SetAllPoints()
    empty:SetColorTexture(RGB(QS.COLOR.empty))
    local fill = Strip(track, "ARTWORK")
    fill:SetPoint("TOPLEFT", 0, 0)
    fill:SetPoint("BOTTOMLEFT", 0, 0)
    fill:SetWidth(1)
    fill:SetColorTexture(RGB(QS.COLOR.fill))
    self.pathFill = fill
    local label = track:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    label:SetTextColor(RGB(QS.COLOR.body))
    self.pathLabel = label

    self.pathLines = {}
    for i = 1, PATH_VISIBLE do
        local line = CreateFrame("Frame", nil, panel)
        line:SetSize(300, 20)
        line:SetPoint("TOPLEFT", 12, -64 - (i - 1) * 20)
        local bg = Strip(line, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(1, 0.82, 0, 0.16)
        bg:Hide()
        line.bg = bg
        local name = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", 4, 0)
        name:SetWidth(190)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        line.name = name
        local zone = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        zone:SetPoint("RIGHT", -4, 0)
        zone:SetWidth(96)
        zone:SetJustifyH("RIGHT")
        zone:SetWordWrap(false)
        zone:SetTextColor(RGB(QS.COLOR.muted))
        line.zone = zone
        self.pathLines[i] = line
    end

    local list = CreateFrame("Frame", nil, panel)
    list:SetPoint("TOPLEFT", 12, -64)
    list:SetPoint("BOTTOMRIGHT", -28, 12)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, delta)
        local count = #(UI.pathRows or {})
        local maxOffset = count - PATH_VISIBLE
        if maxOffset < 0 then
            maxOffset = 0
        end
        local nextOff = (UI.pathOffset or 0) - (delta * 3)
        if nextOff < 0 then
            nextOff = 0
        end
        if nextOff > maxOffset then
            nextOff = maxOffset
        end
        UI.pathOffset = nextOff
        UI.pathStick = UI.pathRows and UI.pathRows[1] and UI.pathStick
        UI:PaintPath()
    end)

    local bar = CreateFrame("Slider", nil, panel)
    bar:SetOrientation("VERTICAL")
    bar:SetWidth(12)
    bar:SetPoint("TOPRIGHT", -10, -64)
    bar:SetPoint("BOTTOMRIGHT", -10, 12)
    bar:SetMinMaxValues(0, 1)
    bar:SetValueStep(1)
    bar:SetValue(0)
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(RGB(QS.COLOR.edge))
    thumb:SetSize(12, 28)
    bar:SetThumbTexture(thumb)
    bar:SetScript("OnValueChanged", function(_, value)
        if UI.pathLock then
            return
        end
        local maxOffset = UI.pathMax or 0
        UI.pathOffset = maxOffset - math.floor((value or 0) + 0.5)
        if UI.pathOffset < 0 then
            UI.pathOffset = 0
        end
        if UI.pathOffset > maxOffset then
            UI.pathOffset = maxOffset
        end
        UI:PaintPath()
    end)
    self.pathScroll = bar
end

function UI:Init()
    local frame = CreateFrame("Frame", "QuestStratagemFrame", UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relative, x, y = self:GetPoint(1)
        QS.char.point = point
        QS.char.relative = relative
        QS.char.x = x
        QS.char.y = y
    end)
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            UI:CycleSize()
        end
    end)
    frame:SetScript("OnEnter", function()
        if QS.char.size ~= "small" then
            return
        end
        local step = QS.route and QS.route.index and QS.route.steps[QS.route.index]
        if not step then
            return
        end
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(step.title or "Stratagem", 1, 0.82, 0)
        GameTooltip:AddLine(step.zone or "", 0.90, 0.88, 0.83, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    Edge(frame)
    local point = QS.char.point or "CENTER"
    local relative = QS.char.relative or "CENTER"
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relative, QS.char.x or 0, QS.char.y or 80)
    self.frame = frame

    self.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.title:SetPoint("TOP", frame, "TOP", 0, -10)
    self.title:SetText("Stratagem")
    self.title:SetTextColor(RGB(QS.COLOR.gold))

    self.closeBtn = TextButton(frame, "X", 18, 18, 0.22, 0.16, 0.12)
    self.closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    Click(self.closeBtn, function()
        frame:Hide()
        QS.char.shown = false
    end)

    self.sizeBtn = TextButton(frame, "-", 18, 18, 0.22, 0.16, 0.12)
    self.sizeBtn:SetPoint("RIGHT", self.closeBtn, "LEFT", -4, 0)
    Click(self.sizeBtn, function()
        UI:CycleSize()
    end)

    self.gearBtn = TextButton(frame, "Options", 64, 18, 0.22, 0.16, 0.12)
    self.gearBtn:SetPoint("RIGHT", self.sizeBtn, "LEFT", -4, 0)
    Click(self.gearBtn, function()
        UI:ToggleConfig()
    end)

    self.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.status:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -40)
    self.status:SetTextColor(RGB(QS.COLOR.body))
    self.status:SetText("Ready")

    self.lastLeg = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.lastLeg:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -58)
    self.lastLeg:SetTextColor(RGB(QS.COLOR.muted))

    self.goal = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.goal:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -74)
    self.goal:SetTextColor(RGB(QS.COLOR.muted))
    self.goal:SetJustifyH("LEFT")
    self.goal:SetWidth(300)

    self.goalHit = CreateFrame("Frame", nil, frame)
    self.goalHit:SetPoint("TOPLEFT", self.goal, "TOPLEFT", 0, 0)
    self.goalHit:SetSize(300, 14)
    self.goalHit:EnableMouse(true)
    self.goalHit:SetScript("OnEnter", function(hit)
        local route = QS.route
        local plan = route and route.levelPlan
        GameTooltip:SetOwner(hit, "ANCHOR_RIGHT")
        if plan and QS.Level then
            local seconds = QS.Level.RemainingSeconds(plan)
            GameTooltip:SetText("Time to the next level", 1, 0.82, 0)
            GameTooltip:AddLine("About " .. QS.Clock.FormatTracked(seconds) .. " for the segments still open on this bar.", 0.9, 0.88, 0.83, true)
            GameTooltip:AddLine("Quests, one dungeon, and same-level kills. A guess, scaled by class and pace.", 0.66, 0.63, 0.56, true)
        else
            local seconds = QS.Clock.RemainingSeconds(route and route.steps, route and route.index, route and route.log)
            GameTooltip:SetText("Time on the authored steps", 1, 0.82, 0)
            GameTooltip:AddLine("About " .. QS.Clock.FormatTracked(seconds) .. " left at this pace.", 0.9, 0.88, 0.83, true)
            GameTooltip:AddLine("Tracked is addon time, not /played.", 0.66, 0.63, 0.56, true)
        end
        GameTooltip:Show()
    end)
    self.goalHit:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.nextBtn = TextButton(frame, "Next", 72, 18, 0.45, 0.16, 0.12)
    self.nextBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -40)
    Click(self.nextBtn, function()
        QS.Resume.Next()
    end)
    self.pathBtn = TextButton(frame, "Path", 56, 18, 0.22, 0.16, 0.12)
    self.pathBtn:SetPoint("RIGHT", self.nextBtn, "LEFT", -6, 0)
    Click(self.pathBtn, function()
        UI:TogglePath()
    end)
    self.backBtn = TextButton(frame, "Back", 72, 18, 0.45, 0.16, 0.12)
    self.backBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -62)
    Click(self.backBtn, function()
        QS.Resume.Back()
    end)

    self.warning = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.warning:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -92)
    self.warning:SetWidth(428)
    self.warning:SetJustifyH("LEFT")
    self.warning:SetTextColor(RGB(QS.COLOR.danger))

    local div = Strip(frame, "BORDER")
    div:SetColorTexture(RGB(QS.COLOR.edge))
    div:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -108)
    div:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -108)
    div:SetHeight(1)

    self.route = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.route:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -114)
    self.route:SetTextColor(RGB(QS.COLOR.gold))
    self.route:SetJustifyH("LEFT")
    self.route:SetWordWrap(false)
    self.route:SetWidth(340)

    self.indexText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.indexText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -112)
    self.indexText:SetJustifyH("RIGHT")
    self.indexText:SetTextColor(RGB(QS.COLOR.muted))

    self.segments = CreateFrame("Frame", nil, frame)
    self.segments.segs = {}
    for i = 1, 16 do
        local seg = Strip(self.segments, "ARTWORK")
        seg:SetColorTexture(RGB(QS.COLOR.empty))
        self.segments.segs[i] = seg
    end

    self.arrow = frame:CreateTexture(nil, "ARTWORK")
    self.arrow:SetTexture("Interface\\Minimap\\MinimapArrow")
    self.arrow:SetSize(28, 28)
    self.arrow:SetVertexColor(RGB(QS.COLOR.gold))

    self.stepTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.stepTitle:SetTextColor(RGB(QS.COLOR.body))
    self.stepTitle:SetJustifyH("LEFT")

    self.dist = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.dist:SetTextColor(RGB(QS.COLOR.muted))

    self.body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.body:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -196)
    self.body:SetWidth(428)
    self.body:SetJustifyH("LEFT")
    self.body:SetWordWrap(true)
    self.body:SetTextColor(RGB(QS.COLOR.body))
    if self.body.SetMaxLines then
        self.body:SetMaxLines(2)
    end

    self.goalHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.goalHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -232)
    self.goalHeader:SetTextColor(RGB(QS.COLOR.gold))

    self.goalRows = {}
    for i = 1, 12 do
        local y = -250 - (i - 1) * 16
        local icon = CreateFrame("Button", nil, frame)
        icon:SetSize(16, 16)
        icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y + 1)
        local tex = icon:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        icon.tex = tex
        icon:SetScript("OnEnter", ShowItemTip)
        icon:SetScript("OnLeave", function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        icon:Hide()
        local name = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("TOPLEFT", frame, "TOPLEFT", 28, y)
        name:SetWidth(320)
        name:SetJustifyH("LEFT")
        name:SetTextColor(RGB(QS.COLOR.body))
        local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        count:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, y)
        count:SetJustifyH("RIGHT")
        count:SetTextColor(RGB(QS.COLOR.muted))
        self.goalRows[i] = { name = name, count = count, icon = icon }
    end

    self.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 8)
    self.footer:SetTextColor(RGB(QS.COLOR.muted))
    self.footer:SetText("Data " .. QS.DATA_VERSION)

    self:BuildPath()
    self:BuildConfig()
    self:BuildMinimap()
    self:ApplySize()
    self:ApplyShown()
    self:Refresh()
end

function UI:BuildConfig()
    local panel = CreateFrame("Frame", "QuestStratagemConfig", UIParent)
    panel:SetSize(340, 500)
    panel:SetFrameStrata("HIGH")
    panel:SetClampedToScreen(true)
    panel:SetPoint("CENTER", UIParent, "CENTER", 220, 0)
    panel:EnableMouse(true)
    panel:Hide()
    Edge(panel)
    self.config = panel

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Options")
    title:SetTextColor(RGB(QS.COLOR.gold))

    local close = TextButton(panel, "X", 18, 18, 0.22, 0.16, 0.12)
    close:SetPoint("TOPRIGHT", -8, -8)
    close:SetScript("OnClick", function()
        panel:Hide()
    end)

    panel.faction = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.faction:SetPoint("TOPLEFT", 16, -40)
    panel.faction:SetTextColor(RGB(QS.COLOR.body))
    panel.race = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.race:SetPoint("TOPLEFT", 16, -58)
    panel.race:SetTextColor(RGB(QS.COLOR.body))
    panel.class = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.class:SetPoint("TOPLEFT", 16, -76)
    panel.class:SetTextColor(RGB(QS.COLOR.body))
    panel.raw = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.raw:SetPoint("TOPLEFT", 16, -94)
    panel.raw:SetTextColor(RGB(QS.COLOR.muted))

    local specLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetPoint("TOPLEFT", 16, -118)
    specLabel:SetText("Spec")
    specLabel:SetTextColor(RGB(QS.COLOR.gold))
    panel.specs = {}
    for i = 1, 3 do
        local button = TextButton(panel, "Spec", 96, 22, 0.18, 0.16, 0.13)
        button:SetPoint("TOPLEFT", 16 + (i - 1) * 102, -140)
        button:SetScript("OnClick", function(self)
            if self.key then
                QS.Config.ConfirmSpec(self.key)
                UI:RefreshConfig()
            end
        end)
        panel.specs[i] = button
    end
    panel.specState = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.specState:SetPoint("TOPLEFT", 16, -166)
    panel.specState:SetTextColor(RGB(QS.COLOR.muted))

    local paceLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    paceLabel:SetPoint("TOPLEFT", 16, -190)
    paceLabel:SetText("Pace")
    paceLabel:SetTextColor(RGB(QS.COLOR.gold))
    panel.paces = {}
    local paces = { "guide", "steady", "first" }
    for i = 1, 3 do
        local key = paces[i]
        local button = TextButton(panel, QS.Config.PACE_LABEL[key], 96, 22, 0.18, 0.16, 0.13)
        button.key = key
        button:SetPoint("TOPLEFT", 16 + (i - 1) * 102, -212)
        button:SetScript("OnClick", function()
            QS.Config.SetPace(key)
            UI:RefreshConfig()
        end)
        panel.paces[i] = button
    end

    panel.checks = {}
    local toggles = {
        { "dungeonDetours", "Dungeon detours" },
        { "bisCallouts", "BiS callouts" },
        { "classQuests", "Class quests" },
        { "professionSteps", "Profession steps" },
        { "includeStubs", "Include stub data" },
        { "autoHand", "Auto turn-in and accept" },
    }
    for i = 1, #toggles do
        local key, label = toggles[i][1], toggles[i][2]
        local row = CreateFrame("Button", nil, panel)
        row:SetSize(300, 18)
        row:SetPoint("TOPLEFT", 16, -246 - (i - 1) * 20)
        row.box = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.box:SetPoint("LEFT", 0, 0)
        row.box:SetTextColor(RGB(QS.COLOR.gold))
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", row.box, "RIGHT", 6, 0)
        text:SetText(label)
        text:SetTextColor(RGB(QS.COLOR.body))
        row.key = key
        if key == "autoHand" then
            row:SetScript("OnEnter", function()
                GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
                GameTooltip:SetText("Auto turn-in and accept", 1, 0.82, 0)
                GameTooltip:AddLine("Finished quests turn in while you talk to the NPC. The next quest is accepted when Stratagem already has it, or it is the only follow-up. A shared dungeon quest is accepted. Hold Shift to leave the dialog alone.", 0.9, 0.88, 0.83, true)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
        row:SetScript("OnClick", function()
            QS.char[key] = not QS.char[key]
            QS:Rebuild()
            UI:RefreshConfig()
        end)
        panel.checks[i] = row
    end

    local clean = TextButton(panel, "Clean Quest Log", 210, 36, 0.22, 0.16, 0.12)
    clean:SetPoint("BOTTOMLEFT", 16, 46)
    clean.label:ClearAllPoints()
    clean.label:SetPoint("TOP", 0, -5)
    panel.cleanNote = clean:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.cleanNote:SetPoint("BOTTOM", 0, 5)
    panel.cleanNote:SetText("Removes 0 Quests")
    panel.cleanNote:SetTextColor(RGB(QS.COLOR.muted))
    panel.clean = clean
    clean:SetScript("OnEnter", function(self)
        local count = self.strays and #self.strays or 0
        if count > 0 then
            self.bg:SetColorTexture(0.53, 0.22, 0.16, 1)
        end
        if not GameTooltip or count == 0 then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Clean Quest Log", 1, 0.82, 0)
        GameTooltip:AddLine("Drops quests in your log that this route will not do. Quests the route still names stay.", 0.9, 0.88, 0.83, true)
        local limit = count
        if limit > 12 then
            limit = 12
        end
        for i = 1, limit do
            local row = self.strays[i]
            local line = row.title or ("Quest " .. row.id)
            if row.complete then
                line = line .. " (ready to turn in)"
            end
            GameTooltip:AddLine(line, 0.9, 0.88, 0.83, true)
        end
        if count > 12 then
            GameTooltip:AddLine("and " .. (count - 12) .. " more", 0.66, 0.63, 0.57, true)
        end
        GameTooltip:Show()
    end)
    clean:SetScript("OnLeave", function(self)
        local count = self.strays and #self.strays or 0
        if count > 0 then
            self.bg:SetColorTexture(0.45, 0.16, 0.12, 1)
        else
            self.bg:SetColorTexture(0.22, 0.16, 0.12, 1)
        end
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    clean:SetScript("OnClick", function(self)
        local count = self.strays and #self.strays or 0
        if count == 0 or not QS.Resume or not QS.Resume.AbandonStrays then
            return
        end
        QS.Resume.AbandonStrays(QS.route)
        QS:RequestRebuild()
    end)

    local reset = TextButton(panel, "Reset route", 120, 22, 0.45, 0.16, 0.12)
    reset:SetPoint("BOTTOMLEFT", 16, 16)
    reset:SetScript("OnClick", function()
        QS.Resume.Reset()
    end)

    panel.debugBlock = CreateFrame("Frame", nil, panel)
    panel.debugBlock:SetSize(300, 22)
    panel.debugBlock:SetPoint("BOTTOMRIGHT", -16, 16)
    local cycle = TextButton(panel.debugBlock, "Cycle override", 120, 22, 0.22, 0.16, 0.12)
    cycle:SetPoint("RIGHT", 0, 0)
    cycle:SetScript("OnClick", function()
        local order = {
            { "Alliance", "Human", "Warrior" },
            { "Horde", "Orc", "Shaman" },
            { "Horde", "Troll", "Hunter" },
            { "Alliance", "HighOrder", "Mage" },
            { "Horde", "Windshaper", "Shaman" },
            { "Alliance", "Dwarf", "Paladin" },
        }
        local char = QS.char
        local found = 1
        for i = 1, #order do
            if char.factionOverride == order[i][1] and char.raceOverride == order[i][2] and char.classOverride == order[i][3] then
                found = i + 1
            end
        end
        if found > #order then
            char.factionOverride = nil
            char.raceOverride = nil
            char.classOverride = nil
        else
            char.factionOverride = order[found][1]
            char.raceOverride = order[found][2]
            char.classOverride = order[found][3]
        end
        QS:Rebuild()
        UI:RefreshConfig()
    end)
end

function UI:BuildMinimap()
    local button = CreateFrame("Button", "QuestStratagemMinimapButton", Minimap)
    button:SetSize(28, 28)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    local bg = Strip(button, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.09, 0.08, 0.9)
    local ring = button:CreateTexture(nil, "OVERLAY")
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetPoint("CENTER")
    ring:SetSize(44, 44)
    local art = button:CreateTexture(nil, "ARTWORK")
    art:SetTexture("Interface\\AddOns\\Stratagem\\icon")
    art:SetSize(18, 18)
    art:SetPoint("CENTER", 0, 0)
    button:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            UI:ToggleConfig()
        else
            UI:Toggle()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self.dragging = true
    end)
    button:SetScript("OnDragStop", function(self)
        self.dragging = false
    end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then
            return
        end
        local mx, my = Minimap:GetCenter()
        local scale = UIParent:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        cx, cy = cx / scale, cy / scale
        local angle = math.atan2(cy - my, cx - mx)
        QS.char.minimapAngle = angle
        PlaceMinimap(self, angle)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Stratagem", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click toggles the panel. Right-click opens options.", 0.9, 0.88, 0.83, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    PlaceMinimap(button, QS.char.minimapAngle or 0.8)
    self.minimap = button
end
