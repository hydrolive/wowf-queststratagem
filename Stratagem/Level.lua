-- One level at a time. Grey quests drop out. The bar is this level's XP.
-- Quest ids for the mid levels are not authored; the plan uses the dungeon
-- in band and mob kills in the zone a player of this level should be in.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Level = {}
QS.Level = Level

local ZONE_LEVEL = {
    ["Durotar"] = 6,
    ["Elwynn Forest"] = 6,
    ["Teldrassil"] = 6,
    ["Dun Morogh"] = 6,
    ["Mulgore"] = 6,
    ["Tirisfal Glades"] = 6,
    ["The Barrens"] = 12,
    ["Westfall"] = 12,
    ["Loch Modan"] = 15,
    ["Darkshore"] = 14,
    ["Silverpine Forest"] = 12,
    ["Redridge Mountains"] = 18,
}

local HORDE_ZONE = {
    { max = 12, zone = "The Barrens", hub = "The Crossroads", mapID = 1413, x = 0.520, y = 0.298 },
    { max = 22, zone = "The Barrens", hub = "Camp Taurajo", mapID = 1413, x = 0.446, y = 0.586 },
    { max = 28, zone = "Thousand Needles", hub = "Freewind Post", mapID = 1441, x = 0.460, y = 0.510, note = "Fast road for 25-28 when the log has nothing left in band. Hillsbrad is the other road. Stonetalon is the earlier road, about 20-26." },
    { max = 36, zone = "Stranglethorn Vale", hub = "Grom'gol Base Camp", mapID = 1434, x = 0.318, y = 0.292 },
    { max = 44, zone = "Tanaris", hub = "Gadgetzan", mapID = 1446, x = 0.516, y = 0.287 },
    { max = 52, zone = "Un'Goro Crater", hub = "Marshal's Refuge", mapID = 1449, x = 0.446, y = 0.082 },
    { max = 60, zone = "Winterspring", hub = "Everlook", mapID = 1452, x = 0.614, y = 0.387 },
}

local ALLIANCE_ZONE = {
    { max = 12, zone = "Westfall", hub = "Sentinel Hill", mapID = 1436, x = 0.565, y = 0.474 },
    { max = 20, zone = "Loch Modan", hub = "Thelsamar", mapID = 1432, x = 0.357, y = 0.485 },
    { max = 28, zone = "Duskwood", hub = "Darkshire", mapID = 1431, x = 0.772, y = 0.444 },
    { max = 36, zone = "Stranglethorn Vale", hub = "Booty Bay", mapID = 1434, x = 0.266, y = 0.763 },
    { max = 44, zone = "Tanaris", hub = "Gadgetzan", mapID = 1446, x = 0.516, y = 0.287 },
    { max = 52, zone = "Un'Goro Crater", hub = "Marshal's Refuge", mapID = 1449, x = 0.446, y = 0.082 },
    { max = 60, zone = "Eastern Plaguelands", hub = "Light's Hope Chapel", mapID = 1423, x = 0.770, y = 0.530 },
}

function Level.GreenRange(level)
    if type(GetQuestGreenRange) == "function" then
        local ok, n = pcall(GetQuestGreenRange)
        if ok and type(n) == "number" and n > 0 then
            return n
        end
    end
    level = level or 1
    if level <= 10 then
        return 5
    end
    local n = 5 + math.floor(((level - 10) * 7 / 50) + 0.5)
    if n > 12 then
        n = 12
    end
    return n
end

function Level.MobXP(level)
    if not level or level < 1 then
        return 50
    end
    return 45 + 5 * level
end

local function DungeonRow(id)
    local rows = QS.Registry and QS.Registry.dungeons
    if not rows or not id then
        return nil
    end
    for i = 1, #rows do
        if rows[i].id == id then
            return rows[i]
        end
    end
    return nil
end

local function ClusterDungeon(step)
    local cluster = step and step.cluster
    if cluster and string.sub(cluster, 1, 8) == "dungeon-" then
        return string.sub(cluster, 9)
    end
    if step and step.dungeon and step.dungeon.id then
        return step.dungeon.id
    end
    return nil
end

function Level.ContentLevel(step)
    if not step then
        return nil
    end
    if step.questLevel then
        return step.questLevel
    end
    if step.atLevel then
        return step.atLevel
    end
    local did = ClusterDungeon(step)
    if did then
        local row = DungeonRow(did)
        if row then
            return math.floor(((row.min or 1) + (row.max or row.min or 1)) / 2)
        end
    end
    if step.minLevel then
        return step.minLevel
    end
    if step.maxLevel then
        return step.maxLevel
    end
    if step.zone and ZONE_LEVEL[step.zone] then
        return ZONE_LEVEL[step.zone]
    end
    return nil
end

-- Published levels. Used so a log row with no level still waits for the fast band.
Level.KNOWN = {
    ["defending the dead"] = { questLevel = 30, minLevel = 23 },
    ["the broodmother"] = { questLevel = 31, minLevel = 23, elite = true },
}

function Level.FastQuest(questLevel, elite, minLevel)
    local level = UnitLevel("player") or 1
    if type(minLevel) == "number" and level < minLevel then
        return false
    end
    if type(questLevel) ~= "number" or questLevel < 1 then
        return true
    end
    if Level.IsGrey({ kind = "accept", questLevel = questLevel }) then
        return false
    end
    local cap = level + 1
    if elite then
        cap = level
    end
    if questLevel > cap then
        return false
    end
    if questLevel < level - 2 then
        return false
    end
    return true
end

function Level.FastTitle(title, questLevel)
    local known = title and Level.KNOWN[string.lower(title)]
    local elite = known and known.elite or false
    local minLevel = known and known.minLevel
    local level = questLevel
    if (type(level) ~= "number" or level < 1) and known then
        level = known.questLevel
    end
    return Level.FastQuest(level, elite, minLevel)
end

function Level.IsGrey(step)
    if not step then
        return false
    end
    local kind = step.kind
    if kind == "kills" or kind == "talent" or kind == "vendor" or kind == "craft"
        or kind == "proftrain" or kind == "bank" or kind == "auction" or kind == "area"
        or kind == "flight" or kind == "weapon" or kind == "armor" or kind == "dual"
        or kind == "opportunity" then
        return false
    end
    if kind == "hearth" and not step.questID then
        return false
    end
    local level = UnitLevel("player") or 1
    local content = Level.ContentLevel(step)
    if not content then
        return false
    end
    return (level - content) > Level.GreenRange(level)
end

local function ZoneFor(level, faction)
    local list = faction == "Horde" and HORDE_ZONE or ALLIANCE_ZONE
    for i = 1, #list do
        if level <= list[i].max then
            return list[i]
        end
    end
    return list[#list]
end

local function Cleared(dungeon, char)
    local bosses = QS.Services and QS.Services.bosses and QS.Services.bosses[dungeon.id]
    if not bosses or #bosses == 0 then
        return false
    end
    for i = 1, #bosses do
        local name = bosses[i].name
        if not (char.bossDown and char.bossDown[name]) then
            return false
        end
    end
    return true
end

local function PickDungeon(steps, level, faction, char)
    local present = {}
    for i = 1, #steps do
        local id = ClusterDungeon(steps[i])
        if id then
            present[id] = true
        end
    end
    local best, bestDist
    local range = Level.GreenRange(level)
    for id in pairs(present) do
        local row = DungeonRow(id)
        if row and (not row.faction or row.faction == faction) and not Cleared(row, char) then
            local mid = ((row.min or level) + (row.max or level)) / 2
            local grey = (level - mid) > range
            local inBand = level + 1 >= (row.min or 1) and level <= (row.max or 60) + 1
            if inBand and not grey then
                local dist = math.abs(mid - level)
                if not best or dist < bestDist or (dist == bestDist and (row.min or 0) > (best.min or 0)) then
                    best = row
                    bestDist = dist
                end
            end
        end
    end
    return best
end

local function InBandQuests(steps, log, level)
    local order, byId = {}, {}
    for i = 1, #steps do
        local step = steps[i]
        local kind = step.kind
        if step.questID and (kind == "accept" or kind == "objective" or kind == "turnin")
            and not Level.IsGrey(step) and not QS.Resume.Done(step, log) then
            local content = Level.ContentLevel(step)
            if content and content <= level + 3 then
                local row = byId[step.questID]
                if not row then
                    row = {
                        xp = 0,
                        title = step.questName or step.title or ("Quest " .. step.questID),
                        stepId = step.id,
                    }
                    byId[step.questID] = row
                    order[#order + 1] = row
                end
                if (step.xp or 0) > row.xp then
                    row.xp = step.xp
                end
            end
        end
    end
    return order
end

local function KillStep(level, index, hub, bite, xpStart, xpMark, perKill)
    local kills = math.ceil(bite / perKill)
    if kills < 1 then
        kills = 1
    end
    local where = hub.hub .. ", " .. hub.zone
    return {
        id = "dyn-kills-" .. level .. "-" .. index,
        cluster = "level-" .. level,
        kind = "kills",
        atLevel = level,
        xpStart = xpStart,
        xpMark = xpMark,
        xpPerKill = perKill,
        title = "Kill mobs in " .. hub.zone,
        text = "Level " .. level .. " XP still open. About " .. kills
            .. " same-level kills around " .. where
            .. ". Grey quests are skipped. Quest ids for this band are not in the guide yet, so this finishes the bar."
            .. (hub.note and (" " .. hub.note) or ""),
        zone = hub.zone,
        mapID = hub.mapID,
        x = hub.x,
        y = hub.y,
        pin = "approx",
        goalHeader = "Kills",
        goals = { { name = "Mobs around " .. hub.hub, have = 0, need = kills } },
        minutes = math.ceil(kills * 22 / 60),
        confidence = "reported",
        source = "level-plan-2026-10-05",
    }
end

function Level.Apply(built, char, log)
    if not built or not built.steps or char.demo or built.key == "demo" then
        return
    end
    local steps = built.steps
    local level = UnitLevel("player") or 1
    local xp = UnitXP("player") or 0
    local xpMax = UnitXPMax("player") or 0
    if xpMax < 1 then
        xpMax = 1
    end
    if xp < 0 then
        xp = 0
    end
    if xp > xpMax then
        xp = xpMax
    end
    local remaining = xpMax - xp
    local faction = (QS.identity and QS.identity.faction) or "Horde"
    local hub = ZoneFor(level, faction)
    local quests = InBandQuests(steps, log, level)
    local focus = (#quests == 0)
    local dungeon
    if focus and remaining > xpMax * 0.20 then
        dungeon = PickDungeon(steps, level, faction, char)
    end

    if focus then
        for i = 1, #steps do
            local step = steps[i]
            local id = step.id or ""
            if id == "band-next-horde" or id == "band-next-alliance" then
                step.levelDefer = true
            end
            local did = ClusterDungeon(step)
            if did and (not dungeon or did ~= dungeon.id) then
                step.levelDefer = true
            end
        end
        if dungeon then
            for i = 1, #steps do
                if steps[i].id == "dungeon-" .. dungeon.id .. "-door" then
                    steps[i].text = (steps[i].text or "")
                        .. " Level " .. level .. " dungeon. Then mobs in " .. hub.zone
                        .. " finish the XP bar. Grey quests stay behind you."
                end
            end
        end
        built.routeName = "Level " .. level .. " · " .. hub.zone
    end

    local work = {}
    local function addWork(xpPart, seconds, title, stepId)
        if xpPart > 0 then
            work[#work + 1] = {
                xp = xpPart,
                seconds = seconds,
                title = title,
                stepId = stepId,
            }
        end
    end

    local budget = remaining
    for i = 1, #quests do
        if budget <= 0 then
            break
        end
        local row = quests[i]
        local bite = row.xp
        if bite < 1 then
            bite = math.floor(xpMax * 0.08)
        end
        if bite > budget then
            bite = budget
        end
        local seconds = 8 * 60
        if bite > 0 and row.xp > 0 then
            seconds = math.floor(8 * 60 * (bite / row.xp))
        end
        addWork(bite, seconds, row.title, row.stepId)
        budget = budget - bite
    end

    local dungeonXp = 0
    if dungeon and budget > 0 then
        dungeonXp = math.floor(xpMax * 0.35)
        if dungeonXp > budget then
            dungeonXp = budget
        end
        local bosses = (QS.Services and QS.Services.bosses and QS.Services.bosses[dungeon.id]) or {}
        local n = #bosses
        if n < 1 then
            n = 1
        end
        if n > 8 then
            n = 8
        end
        local each = math.floor(dungeonXp / n)
        local used = 0
        for i = 1, n do
            local bite = each
            if i == n then
                bite = dungeonXp - used
            end
            local name = (bosses[i] and bosses[i].name) or dungeon.name
            addWork(bite, 4 * 60, name, "boss-" .. dungeon.id .. "-" .. i)
            used = used + bite
        end
        budget = budget - dungeonXp
    end

    local killSteps = {}
    if budget > 0 and focus then
        local parts = math.floor((budget / (xpMax * 0.10)) + 0.5)
        if parts < 1 then
            parts = 1
        end
        if parts > 4 then
            parts = 4
        end
        local per = Level.MobXP(level)
        local cursor = xp + (remaining - budget)
        local left = budget
        for i = 1, parts do
            local bite = math.floor(budget / parts)
            if i == parts then
                bite = left
            end
            if bite > left then
                bite = left
            end
            local startAt = cursor
            cursor = cursor + bite
            local mark = nil
            if cursor < xpMax then
                mark = cursor
            end
            local step = KillStep(level, i, hub, bite, startAt, mark, per)
            killSteps[#killSteps + 1] = step
            addWork(bite, (step.minutes or 1) * 60, step.title, step.id)
            left = left - bite
        end
        local spot
        if dungeon then
            for i = 1, #steps do
                if ClusterDungeon(steps[i]) == dungeon.id and not steps[i].levelDefer then
                    spot = i + 1
                end
            end
        end
        if not spot then
            spot = QS.Resume.FirstOpen(steps, log, char.skips) or (#steps + 1)
        end
        for i = #killSteps, 1, -1 do
            table.insert(steps, spot, killSteps[i])
        end
    elseif budget > 0 then
        local per = Level.MobXP(level)
        local kills = math.ceil(budget / per)
        addWork(budget, kills * 22, "Kills beside the quests", nil)
    end

    built.levelPlan = {
        level = level,
        xpAt = xp,
        xpMax = xpMax,
        work = work,
        zone = hub.zone,
        dungeon = dungeon and dungeon.name or nil,
    }
end

function Level.Visual(plan)
    if not plan then
        return {}
    end
    local xp = UnitXP("player") or 0
    local xpMax = UnitXPMax("player") or plan.xpMax or 1
    local level = UnitLevel("player") or plan.level
    if level ~= plan.level or xpMax < 1 then
        return { { xp = xpMax, title = "This level", filled = xp / xpMax } }
    end
    if xp < 0 then
        xp = 0
    end
    if xp > xpMax then
        xp = xpMax
    end
    local parts = {}
    if xp > 0 then
        parts[#parts + 1] = { xp = xp, title = "Earned", filled = 1 }
    end
    local gain = xp - (plan.xpAt or 0)
    if gain < 0 then
        gain = 0
    end
    local left = xpMax - xp
    local work = plan.work or {}
    for i = 1, #work do
        local item = work[i]
        local xpPart = item.xp or 0
        if gain > 0 then
            if gain >= xpPart then
                gain = gain - xpPart
                xpPart = 0
            else
                xpPart = xpPart - gain
                gain = 0
            end
        end
        if xpPart > 0 and left > 0 then
            if xpPart > left then
                xpPart = left
            end
            parts[#parts + 1] = { xp = xpPart, title = item.title, filled = 0 }
            left = left - xpPart
        end
    end
    if #parts > 16 then
        local merged = {}
        merged[1] = parts[1]
        local rest = #parts - 1
        local bucket = math.ceil(rest / 15)
        local acc, count
        for i = 2, #parts do
            if not acc then
                acc = { xp = 0, title = parts[i].title, filled = parts[i].filled }
                count = 0
            end
            acc.xp = acc.xp + parts[i].xp
            count = count + 1
            if count >= bucket or i == #parts then
                merged[#merged + 1] = acc
                acc = nil
            end
        end
        parts = merged
    end
    return parts
end

function Level.RemainingSeconds(plan)
    if not plan or not plan.work then
        return 0
    end
    local xp = UnitXP("player") or 0
    local gain = xp - (plan.xpAt or 0)
    if UnitLevel("player") ~= plan.level or gain < 0 then
        gain = 0
    end
    local seconds = 0
    for i = 1, #plan.work do
        local item = plan.work[i]
        local left = item.xp or 0
        if gain > 0 then
            if gain >= left then
                gain = gain - left
                left = 0
            else
                left = left - gain
                gain = 0
            end
        end
        if left > 0 and item.xp and item.xp > 0 then
            seconds = seconds + (item.seconds or 0) * (left / item.xp)
        end
    end
    return seconds * (QS.Config.ClassMod() or 1) * (QS.Config.PaceMod() or 1)
end

-- Places still on the fast road. These are camps and dungeons, not quest ids.
local function Stop(at, zone, title)
    return { at = at, zone = zone, title = title }
end

local HORDE_ROAD = {
    Stop(26, "Thousand Needles", "Freewind Post"),
    Stop(26, "Thousand Needles", "The Great Lift"),
    Stop(27, "Thousand Needles", "Darkcloud Pinnacle"),
    Stop(27, "Thousand Needles", "Highperch"),
    Stop(27, "Thousand Needles", "Splithoof Crag"),
    Stop(27, "The Barrens", "Razorfen Kraul"),
    Stop(28, "Thousand Needles", "Windbreak Canyon"),
    Stop(28, "Thousand Needles", "Camp E'thok"),
    Stop(28, "Thousand Needles", "Roguefeather Den"),
    Stop(28, "Thousand Needles", "The Screeching Canyon"),
    Stop(29, "Thousand Needles", "Tahonda Ruins"),
    Stop(30, "Thousand Needles", "The Shimmering Flats"),
    Stop(30, "Thousand Needles", "Mirage Raceway"),
    Stop(30, "Thousand Needles", "Weazel's Crater"),
    Stop(31, "Stranglethorn Vale", "Nesingwary's Expedition"),
    Stop(32, "Stranglethorn Vale", "Grom'gol Base Camp"),
    Stop(32, "Stranglethorn Vale", "Bal'lal Ruins"),
    Stop(32, "Stranglethorn Vale", "Ziata'jai Ruins"),
    Stop(33, "Stranglethorn Vale", "Zul'Kunda Ruins"),
    Stop(33, "Stranglethorn Vale", "Ruins of Zul'Mamwe"),
    Stop(33, "Stranglethorn Vale", "Ruins of Aboraz"),
    Stop(34, "Stranglethorn Vale", "Venture Co. Base Camp"),
    Stop(34, "Stranglethorn Vale", "Kurzen's Compound"),
    Stop(35, "Stranglethorn Vale", "Crystalvein Mine"),
    Stop(35, "Stranglethorn Vale", "Mistvale Valley"),
    Stop(36, "Stranglethorn Vale", "Bloodsail Compound"),
    Stop(36, "Stranglethorn Vale", "Booty Bay"),
    Stop(36, "Stranglethorn Vale", "Gurubashi Arena"),
    Stop(37, "Stranglethorn Vale", "The Vile Reef"),
    Stop(37, "Stranglethorn Vale", "Jaguero Isle"),
    Stop(38, "The Barrens", "Razorfen Downs"),
    Stop(40, "Tanaris", "Gadgetzan"),
    Stop(41, "Tanaris", "Steamwheedle Port"),
    Stop(41, "Tanaris", "Noonshade Ruins"),
    Stop(42, "Tanaris", "Waterspring Field"),
    Stop(42, "Tanaris", "Broken Pillar"),
    Stop(43, "Tanaris", "Lost Rigger Cove"),
    Stop(43, "Tanaris", "Thistleshrub Valley"),
    Stop(44, "Tanaris", "Southbreak Shore"),
    Stop(44, "Tanaris", "Eastmoon Ruins"),
    Stop(44, "Tanaris", "Southmoon Ruins"),
    Stop(44, "Tanaris", "Zul'Farrak"),
    Stop(44, "Tanaris", "Caverns of Time"),
    Stop(45, "Tanaris", "Land's End"),
    Stop(45, "Tanaris", "Valley of the Watchers"),
    Stop(46, "Desolace", "Maraudon"),
    Stop(48, "Un'Goro Crater", "Marshal's Refuge"),
    Stop(49, "Un'Goro Crater", "Lakkari Tar Pits"),
    Stop(49, "Un'Goro Crater", "Golakka Hot Springs"),
    Stop(49, "Un'Goro Crater", "The Marshlands"),
    Stop(50, "Un'Goro Crater", "Fire Plume Ridge"),
    Stop(50, "Un'Goro Crater", "Fungal Rock"),
    Stop(50, "Un'Goro Crater", "Ironstone Plateau"),
    Stop(50, "Swamp of Sorrows", "Temple of Atal'Hakkar"),
    Stop(51, "Un'Goro Crater", "Terror Run"),
    Stop(51, "Un'Goro Crater", "The Slithering Scar"),
    Stop(53, "Winterspring", "Everlook"),
    Stop(54, "Burning Steppes", "Blackrock Depths"),
    Stop(55, "Winterspring", "Timbermaw Hold"),
    Stop(56, "Winterspring", "Starfall Village"),
    Stop(56, "Winterspring", "Owl Wing Thicket"),
    Stop(56, "Winterspring", "Lake Kel'Theril"),
    Stop(56, "Feralas", "Dire Maul"),
    Stop(57, "Winterspring", "Frostsaber Rock"),
    Stop(57, "Winterspring", "Mazthoril"),
    Stop(58, "Winterspring", "Ice Thistle Hills"),
    Stop(58, "Winterspring", "Frostwhisper Gorge"),
    Stop(58, "Burning Steppes", "Lower Blackrock Spire"),
    Stop(59, "Winterspring", "Darkwhisper Gorge"),
    Stop(59, "Winterspring", "Winterfall Village"),
    Stop(60, "Western Plaguelands", "Scholomance"),
    Stop(60, "Eastern Plaguelands", "Stratholme"),
}

local ALLIANCE_ROAD = {
    Stop(26, "Duskwood", "Darkshire"),
    Stop(27, "Duskwood", "Raven Hill Cemetery"),
    Stop(28, "Duskwood", "The Yorgen Farmstead"),
    Stop(30, "Stranglethorn Vale", "Rebel Camp"),
    Stop(31, "Stranglethorn Vale", "Nesingwary's Expedition"),
    Stop(32, "Stranglethorn Vale", "Bal'lal Ruins"),
    Stop(34, "Stranglethorn Vale", "Kurzen's Compound"),
    Stop(36, "Stranglethorn Vale", "Booty Bay"),
    Stop(40, "Tanaris", "Gadgetzan"),
    Stop(43, "Tanaris", "Lost Rigger Cove"),
    Stop(44, "Tanaris", "Zul'Farrak"),
    Stop(48, "Un'Goro Crater", "Marshal's Refuge"),
    Stop(50, "Un'Goro Crater", "Fire Plume Ridge"),
    Stop(52, "Un'Goro Crater", "Terror Run"),
    Stop(55, "Eastern Plaguelands", "Light's Hope Chapel"),
    Stop(58, "Eastern Plaguelands", "Tyr's Hand"),
    Stop(60, "Eastern Plaguelands", "Stratholme"),
}

function Level.AheadStops(level, faction)
    level = tonumber(level) or 1
    local list = faction == "Alliance" and ALLIANCE_ROAD or HORDE_ROAD
    local out = {}
    for i = 1, #list do
        local stop = list[i]
        if stop.at >= level - 2 then
            out[#out + 1] = stop
        end
    end
    return out
end
