-- One area at a time, taken from the quest log.
-- Quests that share a turn-in, or a log zone, are worked together.
-- A quest with its own turn-in stays on its own until that hand-in is done.
-- Pins and tips below are from public Forever pages. The quest id on the
-- step is the id the client put in the log.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Area = {}
QS.Area = Area

local PLACES = {
    ["changing tastes"] = {
        npc = "Borstan",
        zone = "Orgrimmar",
        mapID = 1454,
        x = 0.573,
        y = 0.533,
        where = "upstairs in the meat hut, the Drag",
        watch = "Thicket raptor meat drops from the raptors past the first boss, in Stalker's Thicket. The entrance camps do not drop it.",
        source = "warcrafttavern-forever-2026-10",
    },
    ["elder knowledge"] = {
        npc = "Bashana Runetotem",
        zone = "Thunder Bluff",
        mapID = 1456,
        x = 0.708,
        y = 0.337,
        where = "a tent on the Elder Rise",
        watch = "The Elder Rise is the high northeast bluff. Bashana Runetotem is in a tent there, not at the inn on the lower rise.",
        note = "Beta reports said Earthen Echo still asks for the Titan Relic after this hand-in. Read the reward before you leave for Mulgore.",
        source = "warcrafttavern-forever-2026-10",
    },
    ["earthen echo"] = {
        npc = "Muln Earthfury",
        zone = "Mulgore",
        mapID = 1412,
        x = 0.334,
        y = 0.224,
        placeName = "Skywatcher Plateau",
        fromZone = "Thunder Bluff",
        where = "the biggest tent on Skywatcher Plateau, northwest Mulgore",
        watch = "Northwest Mulgore. Climb from 39.7, 16.9 to Skywatcher Plateau. Biggest tent.",
        climb = "Climb from 39.7, 16.9, then the biggest tent.",
        note = "Relic gone: abandon, accept again from Bashana. She returns it.",
        noteGoal = true,
        source = "realmfirst-2026-10-04",
    },
    ["defending the dead"] = {
        npc = "Muln Earthfury",
        zone = "Mulgore",
        mapID = 1412,
        x = 0.334,
        y = 0.224,
        placeName = "Skywatcher Plateau",
        fromZone = "Thunder Bluff",
        where = "the biggest tent on Skywatcher Plateau, northwest Mulgore",
        watch = "Muln Earthfury on Skywatcher Plateau. Level 30, same tent as Earthen Echo. No public quest id, so this matches the log title.",
        source = "wowhead-forever-npc-259118",
    },
    ["the broodmother"] = {
        npc = "Muln Earthfury",
        zone = "Mulgore",
        mapID = 1412,
        x = 0.334,
        y = 0.224,
        placeName = "Skywatcher Plateau",
        fromZone = "Thunder Bluff",
        where = "the biggest tent on Skywatcher Plateau, northwest Mulgore",
        watch = "Kill Broodmother Valraxx at Gloomrise. Bring help. Turn it in to Muln Earthfury. Gloomrise has no published pin.",
        note = "Kill Broodmother Valraxx at Gloomrise. Bring help.",
        noteGoal = true,
        source = "wowhead-forever-96261",
    },
}

local function PlaceFor(title)
    if not title then
        return nil
    end
    return PLACES[string.lower(title)]
end

function Area.KnownTitle(title)
    return PlaceFor(title) and true or false
end

local function ZoneHere(zone)
    if not zone or zone == "" then
        return false
    end
    local place = QS.Api.Place()
    return zone == place.zone or zone == place.real or zone == place.sub
end

-- 34.3, 25.8 is the Valanaar zeppelin. Horde flights out of Mulgore leave from Tal.
local WIND_HERE = {
    ["Mulgore"] = true,
    ["Thunder Bluff"] = true,
    ["Skywatcher Plateau"] = true,
}

local function NamedHere(name)
    return name and WIND_HERE[name] and true or false
end

local function LeavingByWind(dest)
    if not dest or NamedHere(dest) then
        return false
    end
    local id = QS.identity
    if not id or id.faction ~= "Horde" then
        return false
    end
    local place = QS.Api and QS.Api.Place and QS.Api.Place()
    if not place then
        return false
    end
    return NamedHere(place.zone) or NamedHere(place.sub) or NamedHere(place.real)
end

local function WindText(dest)
    return "Fly from Tal, inside the totem on the central rise in Thunder Bluff (47, 49). "
        .. "34.3, 25.8 on Skywatcher Plateau is the zeppelin to Valanaar. It does not fly to "
        .. dest .. "."
end

local function ObjectivesReady(objectives)
    if not objectives or #objectives == 0 then
        return false
    end
    for i = 1, #objectives do
        local obj = objectives[i]
        local need = obj.need or 0
        local have = obj.have or 0
        if not (obj.finished or (need > 0 and have >= need)) then
            return false
        end
    end
    return true
end

function Area.Ready(info)
    if not info then
        return false
    end
    if info.complete then
        return true
    end
    return ObjectivesReady(info.objectives)
end

local function MakeRow(id, info)
    local place = PlaceFor(info.title)
    return {
        id = id,
        title = info.title or ("Quest " .. id),
        complete = Area.Ready(info),
        level = info.level,
        objectives = info.objectives or {},
        zone = (place and place.zone) or info.zone or "Quests",
        place = place,
    }
end

local function InThisZone(row)
    if ZoneHere(row.zone) then
        return true
    end
    if row.place and ZoneHere(row.place.placeName or row.place.zone) then
        return true
    end
    return false
end

local function KeepRow(row)
    local here = InThisZone(row)
    if row.complete and here then
        return true
    end
    -- Below the fast band is not a new trip. A quest you are already
    -- doing in the zone you are standing in stays on that camp.
    if here and not row.complete then
        if QS.Level and QS.Level.IsGrey then
            if QS.Level.IsGrey({ kind = "accept", questLevel = row.level }) then
                return false
            end
        end
        return true
    end
    if QS.Level and QS.Level.FastTitle then
        return QS.Level.FastTitle(row.title, row.level)
    end
    return true
end

local function Rows(log)
    local rows, seen = {}, {}
    local zones = log.zones or {}
    for z = 1, #zones do
        local zone = zones[z]
        for i = 1, #(zone.quests or {}) do
            local id = zone.quests[i]
            local info = log.inLog[id]
            if info and not seen[id] then
                seen[id] = true
                rows[#rows + 1] = MakeRow(id, info)
            end
        end
    end
    for id, info in pairs(log.inLog or {}) do
        if not seen[id] then
            rows[#rows + 1] = MakeRow(id, info)
        end
    end
    return rows
end

local function ClusterOf(row)
    if row.place then
        return row.place.zone .. "|" .. row.place.npc
    end
    return "log|" .. (row.zone or "Quests")
end

local function BuildClusters(rows)
    local order, byKey = {}, {}
    for i = 1, #rows do
        local row = rows[i]
        local key = ClusterOf(row)
        local cluster = byKey[key]
        if not cluster then
            cluster = {
                key = key,
                zone = row.zone,
                place = row.place,
                rows = {},
            }
            byKey[key] = cluster
            order[#order + 1] = cluster
        end
        cluster.rows[#cluster.rows + 1] = row
    end
    return order
end

local function Tally(cluster)
    local ready, open = 0, 0
    for i = 1, #cluster.rows do
        if cluster.rows[i].complete then
            ready = ready + 1
        else
            open = open + 1
        end
    end
    return ready, open
end

local function Score(cluster)
    local ready, open = Tally(cluster)
    if ready == 0 and open == 0 then
        return nil
    end
    local place = cluster.place
    local here = ZoneHere(cluster.zone)
    local score
    if here and ready > 0 then
        score = 3000 + ready
    elseif here and open > 0 then
        score = 2000 + open
    elseif place and open > 0 and not here then
        score = 1500 + open
    elseif ready > 0 then
        score = 1000 + ready
    else
        score = open
    end
    if place and place.fromZone and place.zone ~= place.fromZone and ZoneHere(place.fromZone) then
        local carried = 2500 + ready + open
        if carried > score then
            score = carried
        end
    end
    return score
end

local function Slug(text)
    local s = string.lower(text or "area")
    s = string.gsub(s, "[^%w]+", "-")
    s = string.gsub(s, "^-+", "")
    s = string.gsub(s, "-+$", "")
    if s == "" then
        s = "area"
    end
    return s
end

local function IdList(cluster)
    local ids = {}
    for i = 1, #cluster.rows do
        ids[#ids + 1] = cluster.rows[i].id
    end
    table.sort(ids)
    local tail = ""
    for i = 1, #ids do
        tail = tail .. "-" .. ids[i]
    end
    return ids, tail
end

local function ClusterStepIds(cluster)
    local _, tail = IdList(cluster)
    local slug = Slug(cluster.key)
    return "dyn-area-" .. slug .. tail, "dyn-area-go-" .. slug .. tail
end

local function TagClusters(clusters)
    for i = 1, #clusters do
        local areaId, goId = ClusterStepIds(clusters[i])
        clusters[i].areaId = areaId
        clusters[i].goId = goId
    end
end

local function Skipped(cluster, skips)
    return skips[cluster.areaId] and true or false
end

local function StickyCluster(clusters, char, log, skips)
    local prev = QS.route
    if not prev or not prev.steps or not log then
        return nil
    end
    local prevIds = {}
    for i = 1, #prev.steps do
        local step = prev.steps[i]
        if step.kind == "area" and step.questIDs then
            for q = 1, #step.questIDs do
                prevIds[step.questIDs[q]] = true
            end
        end
    end
    for i = 1, #clusters do
        local cluster = clusters[i]
        if not Skipped(cluster, skips) then
            for r = 1, #cluster.rows do
                local id = cluster.rows[r].id
                if prevIds[id] and log.inLog[id] then
                    return cluster
                end
            end
        end
    end
    return nil
end

local function Pick(clusters, char, log)
    local skips = (char and char.skips) or {}
    TagClusters(clusters)
    local manual = char and char.manualStepId
    local manualCluster
    local best, bestScore
    for i = 1, #clusters do
        local cluster = clusters[i]
        if manual and (manual == cluster.areaId or manual == cluster.goId) and not Skipped(cluster, skips) then
            manualCluster = cluster
        end
        if not Skipped(cluster, skips) then
            local score = Score(cluster)
            if score and (not best or score > bestScore) then
                best = cluster
                bestScore = score
            end
        end
    end
    if manualCluster then
        return manualCluster
    end
    local sticky = StickyCluster(clusters, char, log, skips)
    if sticky then
        for i = 1, #clusters do
            local cluster = clusters[i]
            if cluster ~= sticky and not Skipped(cluster, skips) then
                local ready = Tally(cluster)
                if ready > 0 and ZoneHere(cluster.zone) then
                    return cluster
                end
            end
        end
        return sticky
    end
    return best
end

local function Describe(cluster, others, arrived)
    local place = cluster.place
    local ready, open = Tally(cluster)
    local text
    if place and not arrived and place.placeName then
        text = place.watch or ("Go to " .. place.placeName .. ". " .. place.npc .. " is in " .. place.where .. ".")
    elseif place and ready > 0 and open == 0 then
        text = "Turn in to " .. place.npc .. " in " .. place.where .. "."
        if place.watch and not place.placeName then
            text = text .. " " .. place.watch
        end
        if place.note and not place.noteGoal then
            text = text .. " " .. place.note
        end
    elseif place and open > 0 then
        text = place.watch or ("Work this quest around " .. place.where .. ".")
        if ready > 0 then
            text = text .. " Turn the finished one in to " .. place.npc .. " while you are here."
        end
    elseif ready > 0 and open == 0 then
        text = "These quests are ready to turn in in " .. cluster.zone .. ". Hand them in before you leave the area."
    else
        text = "These quests overlap in " .. cluster.zone .. ". Kill, collect, and gather what is listed before you move on."
    end
    if arrived and others then
        local extra = others[1]
        if extra then
            local who = (extra.place and extra.place.npc) or extra.zone
            text = text .. " Next area: " .. extra.title .. " with " .. who .. " in " .. extra.zone .. "."
        end
    end
    return text
end

local function ObjectiveLabel(text)
    if type(text) ~= "string" then
        return text
    end
    local stripped = string.match(text, "^%d+%s*/%s*%d+%s+(.+)$")
    if stripped and stripped ~= "" then
        return stripped
    end
    return text
end

local function GoalCount(obj, complete)
    local have = obj.have or 0
    local need = obj.need or 0
    local done = obj.finished or complete or (need > 0 and have >= need)
    if done and need > 0 and have < need then
        have = need
    end
    local goal = {
        have = have,
        need = need,
    }
    if done then
        goal.count = "(Completed)"
    end
    return goal
end

local function GoalsFor(cluster)
    local goals = {}
    for i = 1, #cluster.rows do
        local row = cluster.rows[i]
        local added = false
        for j = 1, #row.objectives do
            local obj = row.objectives[j]
            local goal = GoalCount(obj, row.complete)
            goal.name = ObjectiveLabel(obj.text) or row.title
            goals[#goals + 1] = goal
            added = true
        end
        if not added then
            if row.complete then
                goals[#goals + 1] = { name = row.title, have = 1, need = 1, count = "(Completed)" }
            else
                goals[#goals + 1] = { name = row.title, have = 0, need = 1 }
            end
        end
    end
    return goals
end

local function BestOther(clusters, chosen)
    local best, bestScore
    for i = 1, #clusters do
        local cluster = clusters[i]
        if cluster ~= chosen then
            local score = Score(cluster)
            if score and (not best or score > bestScore) then
                best = cluster
                bestScore = score
            end
        end
    end
    if not best or not best.rows[1] then
        return nil
    end
    return {
        title = best.rows[1].title,
        zone = best.zone,
        place = best.place,
    }
end

local function AppendExtras(goals, cluster, others, arrived)
    local place = cluster.place
    if place and place.climb and place.placeName and not arrived then
        table.insert(goals, 1, { name = place.climb, have = 0, need = 1 })
    end
    if place and place.noteGoal and place.note then
        goals[#goals + 1] = { name = place.note, have = 0, need = 1 }
    end
    local extra = others and others[1]
    if extra then
        local whereName = extra.place and (extra.place.placeName or extra.place.zone) or extra.zone
        goals[#goals + 1] = { name = "Still out: " .. extra.title .. " (" .. whereName .. ")", have = 0, need = 1 }
    end
    local main = cluster.place
    for i = 1, #cluster.rows do
        local rowPlace = cluster.rows[i].place
        if rowPlace and rowPlace ~= main and rowPlace.note then
            goals[#goals + 1] = { name = rowPlace.note, have = 0, need = 1 }
        end
    end
    return goals
end

local function Arrived(cluster)
    local place = cluster.place
    if place and place.placeName then
        return ZoneHere(place.placeName)
    end
    return ZoneHere(cluster.zone)
end

local function ClearStaleAssume(char)
    if not char or not char.assumeZone then
        return
    end
    local place = QS.Api and QS.Api.Place and QS.Api.Place()
    if not place then
        return
    end
    local zone = place.zone or ""
    if zone == "" then
        return
    end
    if zone == char.assumeZone or NamedHere(zone) or NamedHere(place.sub) or NamedHere(place.real) then
        return
    end
    char.assumeZone = nil
end

local function TripArrived(char, zone)
    if ZoneHere(zone) then
        return true
    end
    return char and char.assumeZone == zone or false
end

-- Public places for log objectives that share a zone. A pin is set only
-- where a public page gives the spot. Quest ids stay the ids in the log.
local POCKETS = {
    ["Stonetalon Mountains"] = {
        {
            key = "charred-vale",
            name = "The Charred Vale",
            where = "south of Sun Rock Retreat",
            hub = "Sun Rock Retreat",
            mapID = 1442,
            x = 0.32,
            y = 0.68,
            order = 1,
            -- Harpies, the sunstone, and Incendrites are this valley.
            -- New Life plants Gaea seeds here. Gathering them is the lake.
            patterns = {
                "bloodfury",
                "glittering sunstone",
                "incendrite",
                "gaea seed planted",
                "new life",
                "elemental war",
            },
            source = "wowhead-classic-6282",
        },
        {
            key = "mirkfallon",
            name = "Mirkfallon Lake",
            where = "north of Sun Rock Retreat, along the water",
            mapID = 1442,
            x = 0.48,
            y = 0.40,
            order = 2,
            patterns = { "gaea seed" },
            unless = { "planted" },
            source = "warcraft-wiki-cycle-of-rebirth",
        },
        {
            key = "peak",
            name = "Stonetalon Peak",
            where = "the grove on the peak, north past Mirkfallon Lake",
            mapID = 1442,
            x = 0.33,
            y = 0.11,
            order = 3,
            patterns = { "cenarius", "cenarion botanist" },
            source = "warcraft-wiki-cenarion-botanist",
        },
        {
            key = "windshear",
            name = "Windshear Crag",
            where = "east of Sun Rock Retreat",
            mapID = 1442,
            x = 0.59,
            y = 0.63,
            order = 4,
            patterns = { "super reaper", "venture co" },
            source = "forever-codex-stonetalon",
        },
    },
}

local function PocketBlob(row)
    local parts = { string.lower(row.title or "") }
    for i = 1, #(row.objectives or {}) do
        local obj = row.objectives[i]
        if obj.text then
            parts[#parts + 1] = string.lower(obj.text)
        end
    end
    return table.concat(parts, " ")
end

local function PocketScore(def, blob)
    if def.unless then
        for i = 1, #def.unless do
            if string.find(blob, def.unless[i], 1, true) then
                return 0
            end
        end
    end
    local score = 0
    for i = 1, #def.patterns do
        if string.find(blob, def.patterns[i], 1, true) then
            score = score + 1
        end
    end
    return score
end

local function BestDef(defs, blob)
    local best, bestScore
    for i = 1, #defs do
        local score = PocketScore(defs[i], blob)
        if score > 0 and (not best or score > bestScore) then
            best = defs[i]
            bestScore = score
        end
    end
    return best
end

local function WithPlace(name, placeName)
    if not placeName or placeName == "" then
        return name
    end
    if name and string.find(string.lower(name), string.lower(placeName), 1, true) then
        return name
    end
    return (name or placeName) .. " · " .. placeName
end

local function GoalsNamed(rows, placeName)
    local goals = {}
    for i = 1, #rows do
        local row = rows[i]
        local added = false
        for j = 1, #row.objectives do
            local obj = row.objectives[j]
            local goal = GoalCount(obj, row.complete)
            goal.name = WithPlace(ObjectiveLabel(obj.text) or row.title, placeName)
            goal.questID = row.id
            goals[#goals + 1] = goal
            added = true
        end
        if not added then
            if row.complete then
                goals[#goals + 1] = {
                    name = WithPlace(row.title, placeName),
                    questID = row.id,
                    have = 1,
                    need = 1,
                    count = "(Completed)",
                }
            else
                goals[#goals + 1] = {
                    name = WithPlace(row.title, placeName),
                    questID = row.id,
                    have = 0,
                    need = 1,
                }
            end
        end
    end
    return goals
end

local function GoalKey(name)
    return string.lower(name or "")
end

local function KeepDone(previous, goals, ids)
    if not previous then
        return goals
    end
    local allowed
    if ids then
        allowed = {}
        for i = 1, #ids do
            allowed[ids[i]] = true
        end
    end
    local seen = {}
    for i = 1, #goals do
        seen[GoalKey(goals[i].name)] = true
    end
    for i = 1, #previous do
        local old = previous[i]
        local key = GoalKey(old.name)
        local full = old.need and old.need > 0 and (old.have or 0) >= old.need
        local done = old.count == "(Completed)" or old.count == "complete" or full
        -- A quest from an earlier visit stays on that visit. A goal with no
        -- quest id is an older snapshot and still belongs on this step.
        local owned = true
        if old.questID and allowed and not allowed[old.questID] then
            owned = false
        end
        if done and owned and key ~= "" and not seen[key] then
            goals[#goals + 1] = {
                name = old.name,
                questID = old.questID,
                have = old.have,
                need = old.need,
                count = "(Completed)",
            }
            seen[key] = true
        end
    end
    return goals
end

local function PreviousStep(id)
    local route = QS.route
    if route and route.steps then
        for i = 1, #route.steps do
            local step = route.steps[i]
            if step.id == id then
                return step
            end
        end
    end
    local hist = QS.char and QS.char.history
    if type(hist) == "table" then
        for i = #hist, 1, -1 do
            if hist[i].id == id then
                return hist[i]
            end
        end
    end
    return nil
end

local function PreviousGoals(id)
    local step = PreviousStep(id)
    if step and step.goals then
        return step.goals
    end
    return nil
end

-- Quests this step already owned, including one that has since left the log.
local function AllowIds(stepId, rowIds)
    local seen = {}
    local ids = {}
    local function add(id)
        if id ~= nil and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end
    for i = 1, #rowIds do
        add(rowIds[i])
    end
    local prev = PreviousStep(stepId)
    if prev and prev.questIDs then
        for i = 1, #prev.questIDs do
            add(prev.questIDs[i])
        end
    end
    return ids
end

local function SellJunkDone()
    local bags = QS.Api and QS.Api.Bags and QS.Api.Bags()
    if type(bags) ~= "table" or type(bags.list) ~= "table" then
        return false
    end
    if #bags.list == 0 and (tonumber(bags.free) or 0) <= 0 then
        return false
    end
    for i = 1, #bags.list do
        local item = bags.list[i]
        if item and item.quality == 0 then
            return false
        end
    end
    return true
end

local function ApplySellJunk(goal)
    if SellJunkDone() then
        goal.have = 1
        goal.need = 1
        goal.count = "(Completed)"
    else
        goal.have = 0
        goal.need = 1
        goal.count = nil
    end
end

function Area.RefreshStep(step, log)
    if not step or not log then
        return
    end
    -- A quest that left the log stays on the turn-in as (Completed).
    if step.handIn and step.goals then
        for i = 1, #step.goals do
            local goal = step.goals[i]
            local qid = goal.questID
            if qid and not log.inLog[qid] then
                goal.have = 1
                goal.need = goal.need or 1
                goal.count = "(Completed)"
            elseif goal.name == "Sell junk" then
                ApplySellJunk(goal)
            end
        end
        return
    end
    if step.kind ~= "area" or not step.placeName then
        return
    end
    local defs = POCKETS[step.zone]
    if not defs then
        return
    end
    local owned
    if step.questIDs then
        owned = {}
        for i = 1, #step.questIDs do
            owned[step.questIDs[i]] = true
        end
    end
    local rows = {}
    local raw = Rows(log)
    for i = 1, #raw do
        local row = raw[i]
        if row.zone == step.zone then
            local best = BestDef(defs, PocketBlob(row))
            if best and best.name == step.placeName and (not owned or owned[row.id]) then
                rows[#rows + 1] = row
            end
        end
    end
    if #rows == 0 then
        return
    end
    local ids = {}
    for i = 1, #rows do
        ids[#ids + 1] = rows[i].id
    end
    table.sort(ids)
    local allow = ids
    if step.questIDs then
        allow = AllowIds(step.id, ids)
        for i = 1, #step.questIDs do
            local id = step.questIDs[i]
            local seen = false
            for j = 1, #allow do
                if allow[j] == id then
                    seen = true
                end
            end
            if not seen then
                allow[#allow + 1] = id
            end
        end
    end
    step.questIDs = ids
    step.goals = KeepDone(step.goals, GoalsNamed(rows, step.placeName), allow)
end

local function ActivePockets(cluster, char)
    local defs = POCKETS[cluster.zone]
    local buckets = {}
    local order = {}
    local function bucket(def)
        local found = buckets[def.key]
        if not found then
            found = {
                key = def.key,
                name = def.name,
                where = def.where,
                mapID = def.mapID,
                x = def.x,
                y = def.y,
                order = def.order or 50,
                source = def.source,
                hub = def.hub,
                rows = {},
            }
            buckets[def.key] = found
            order[#order + 1] = found
        end
        return found
    end
    if defs then
        for i = 1, #defs do
            bucket(defs[i])
        end
    end
    local rest = {
        key = "rest",
        name = "Other quests in " .. (cluster.zone or "this zone"),
        where = "no published place for these",
        order = 100,
        rows = {},
    }
    for i = 1, #cluster.rows do
        local row = cluster.rows[i]
        local blob = PocketBlob(row)
        local best = defs and BestDef(defs, blob)
        if best then
            local found = bucket(best)
            found.rows[#found.rows + 1] = row
        else
            rest.rows[#rest.rows + 1] = row
        end
    end
    if #rest.rows > 0 then
        order[#order + 1] = rest
    end
    local skips = (char and char.skipPockets) or {}
    local slug = Slug(cluster.zone)
    local listed = {}
    for i = 1, #order do
        local pocket = order[i]
        if #pocket.rows > 0 then
            pocket.id = slug .. "-" .. pocket.key
            pocket.skipped = skips[pocket.id] and true or false
            listed[#listed + 1] = pocket
        end
    end
    table.sort(listed, function(a, b)
        if a.order == b.order then
            return a.name < b.name
        end
        return a.order < b.order
    end)
    return listed
end

local function ShortPlace(name)
    if type(name) == "string" and string.sub(name, 1, 4) == "The " then
        return string.sub(name, 5)
    end
    if type(name) ~= "string" or name == "" then
        return "these"
    end
    return name
end

-- One step for every ready quest in the camp. No pin: the hub is a name only.
local function HandInStep(cluster, pocket)
    local ready = {}
    for i = 1, #pocket.rows do
        if pocket.rows[i].complete then
            ready[#ready + 1] = pocket.rows[i]
        end
    end
    if #ready == 0 then
        return nil
    end
    table.sort(ready, function(a, b)
        if a.title == b.title then
            return a.id < b.id
        end
        return (a.title or "") < (b.title or "")
    end)
    local openId = {}
    local openName = {}
    for i = 1, #ready do
        local row = ready[i]
        openId[row.id] = true
        openName["turn in " .. string.lower(row.title or "")] = true
    end
    local id = "dyn-hand-" .. pocket.id
    local goals = {}
    local kept = {}
    local previous = PreviousGoals(id)
    if previous then
        for i = 1, #previous do
            local old = previous[i]
            local name = old.name or ""
            local low = string.lower(name)
            local qid = old.questID
            local still = (qid and openId[qid]) or openName[low]
            local turnin = qid or string.sub(low, 1, 8) == "turn in "
            if low ~= "" and low ~= "sell junk" and turnin and not still then
                local key = qid or low
                if not kept[key] then
                    goals[#goals + 1] = {
                        name = name,
                        questID = qid,
                        have = 1,
                        need = 1,
                        count = "(Completed)",
                    }
                    kept[key] = true
                end
            end
        end
    end
    local ids = {}
    for i = 1, #ready do
        local row = ready[i]
        ids[#ids + 1] = row.id
        goals[#goals + 1] = {
            name = "Turn in " .. row.title,
            questID = row.id,
            have = 0,
            need = 1,
        }
    end
    local sell = { name = "Sell junk" }
    ApplySellJunk(sell)
    goals[#goals + 1] = sell
    local hub = pocket.hub
    local text = "These " .. pocket.name .. " quests are finished. Hand these in after " .. pocket.name .. "."
    if type(hub) == "string" and hub ~= "" then
        text = "These " .. pocket.name .. " quests are finished. Hand these in at " .. hub .. "."
    end
    local step = {
        id = id,
        handIn = true,
        cluster = "area-" .. Slug(cluster.zone),
        kind = "turnin",
        title = "Turn in " .. ShortPlace(pocket.name) .. " quests",
        zone = cluster.zone,
        placeName = pocket.name,
        questIDs = ids,
        text = text,
        goalHeader = "Turn in",
        goals = goals,
        minutes = 5,
        confidence = "log",
        source = pocket.source or "quest-log",
    }
    if type(hub) == "string" and hub ~= "" then
        step.turnInAt = hub
    end
    return step
end

local function PocketStep(cluster, pocket, rows, spec)
    rows = rows or pocket.rows
    spec = spec or {}
    local place = QS.Api and QS.Api.Place and QS.Api.Place()
    local sub = place and place.sub or ""
    local standing = sub == pocket.name or ZoneHere(pocket.name)
    local title = spec.title
    if not title then
        title = pocket.name
        if not standing then
            title = "Go to " .. pocket.name
        end
    end
    local text = spec.text
    if not text then
        text = "These overlap in " .. pocket.name .. ", " .. (pocket.where or pocket.name) .. "."
        if pocket.x then
            text = text .. " The arrow points there."
        else
            text = text .. " That spot has no published pin."
        end
    end
    local ids = {}
    for i = 1, #rows do
        ids[#ids + 1] = rows[i].id
    end
    table.sort(ids)
    local stepId = spec.id or ("dyn-area-pocket-" .. pocket.id)
    local named = GoalsNamed(rows, pocket.name)
    local goals = named
    if not spec.fresh then
        goals = KeepDone(PreviousGoals(stepId), named, AllowIds(stepId, ids))
    end
    local step = {
        id = stepId,
        pocket = spec.pocket or pocket.id,
        cluster = "area-" .. Slug(cluster.zone),
        kind = "area",
        title = title,
        text = text,
        zone = cluster.zone,
        placeName = pocket.name,
        questIDs = ids,
        goalHeader = "Area",
        goals = goals,
        minutes = 12,
        confidence = pocket.x and "reported" or "log",
        source = pocket.source or "quest-log",
    }
    if pocket.mapID and pocket.x and pocket.y then
        step.mapID = pocket.mapID
        step.x = pocket.x
        step.y = pocket.y
        step.pin = "approx"
    end
    return step
end

-- The previous camp is finished when every quest it owned is ready or gone.
local function VisitDone(pocket, ids, log)
    if not ids or #ids == 0 or not log or not QS.Resume or not QS.Resume.Done then
        return false
    end
    return QS.Resume.Done({
        id = "dyn-area-pocket-" .. pocket.id,
        pocket = pocket.id,
        kind = "area",
        questIDs = ids,
    }, log) and true or false
end

-- Newest finished set for this camp. A later snapshot may already list the
-- new quest; that snapshot is not finished, so the one before it still counts.
local function FinishedVisitIds(pocket, log)
    local baseId = "dyn-area-pocket-" .. pocket.id
    local sets = {}
    local function consider(step)
        if step and step.id == baseId and type(step.questIDs) == "table" and #step.questIDs > 0 then
            sets[#sets + 1] = step.questIDs
        end
    end
    local hist = QS.char and QS.char.history
    if type(hist) == "table" then
        for i = 1, #hist do
            consider(hist[i])
        end
    end
    local route = QS.route
    if route and route.steps then
        for i = 1, #route.steps do
            consider(route.steps[i])
        end
    end
    for i = #sets, 1, -1 do
        if VisitDone(pocket, sets[i], log) then
            return sets[i]
        end
    end
    return nil
end

-- A quest accepted after the camp was finished is a new visit.
local function SplitVisit(pocket, log)
    local ownedIds = FinishedVisitIds(pocket, log)
    if not ownedIds then
        return nil
    end
    local owned = {}
    for i = 1, #ownedIds do
        owned[ownedIds[i]] = true
    end
    local stay, fresh = {}, {}
    for i = 1, #pocket.rows do
        local row = pocket.rows[i]
        if owned[row.id] then
            stay[#stay + 1] = row
        else
            fresh[#fresh + 1] = row
        end
    end
    if #fresh == 0 then
        return nil
    end
    return stay, fresh
end

local function FreshStep(cluster, pocket, rows)
    local ids = {}
    for i = 1, #rows do
        ids[#ids + 1] = rows[i].id
    end
    table.sort(ids)
    local parts = {}
    for i = 1, #ids do
        parts[i] = tostring(ids[i])
    end
    local tail = table.concat(parts, "-")
    local title = "Return to " .. pocket.name
    local text = "These quests are in " .. pocket.name .. ", " .. (pocket.where or pocket.name) .. "."
    if #rows == 1 then
        title = rows[1].title
        text = "This quest is in " .. pocket.name .. ", " .. (pocket.where or pocket.name) .. "."
    end
    if pocket.x then
        text = text .. " The arrow points there."
    else
        text = text .. " That spot has no published pin."
    end
    return PocketStep(cluster, pocket, rows, {
        id = "dyn-area-pocket-" .. pocket.id .. "-next-" .. tail,
        pocket = pocket.id .. "-next-" .. tail,
        title = title,
        text = text,
        fresh = true,
    })
end

local function TravelStep(chosen, tail, lead)
    local byWind = LeavingByWind(chosen.zone)
    local title = "Go to " .. chosen.zone
    local mapID, x, y, npc
    local text = "Go to " .. chosen.zone .. "."
    local source = "quest-log"
    if byWind then
        title = "Fly to " .. chosen.zone
        mapID = 1456
        x = 0.47
        y = 0.49
        npc = "Tal"
        text = WindText(chosen.zone)
        source = "wowhead-thunder-bluff-tal"
    end
    if lead then
        text = text .. " First stop is " .. lead.name .. ", " .. (lead.where or lead.name) .. "."
    end
    return {
        id = chosen.goId or ("dyn-area-go-" .. Slug(chosen.key) .. tail),
        cluster = "area-" .. Slug(chosen.zone),
        kind = "travel",
        title = title,
        text = text,
        zone = chosen.zone,
        mapID = mapID,
        x = x,
        y = y,
        pin = (mapID and x and y) and "approx" or nil,
        npc = npc,
        completeOnZone = chosen.zone,
        goalHeader = "Area",
        goals = { { name = title, have = 0, need = 1 } },
        flyGoal = byWind and title or nil,
        minutes = 15,
        confidence = byWind and "reported" or "log",
        source = source,
    }
end

local function AreaStep(cluster, ids, tail, arrived, others)
    local place = cluster.place
    local ready, open = Tally(cluster)
    local title
    local atHandin = arrived and ready > 0 and open == 0
    if place and place.placeName and not arrived then
        title = "Go to " .. place.placeName
    elseif place and ready > 0 and open == 0 then
        title = "Turn in to " .. place.npc
    elseif arrived then
        title = cluster.zone
    else
        title = "Go to " .. cluster.zone
    end
    local step = {
        id = cluster.areaId or ("dyn-area-" .. Slug(cluster.key) .. tail),
        cluster = "area-" .. Slug(cluster.zone),
        kind = "area",
        areaTurnin = atHandin or nil,
        title = title,
        text = Describe(cluster, others, arrived),
        zone = cluster.zone,
        placeName = place and place.placeName or nil,
        questIDs = ids,
        goalHeader = atHandin and "Turn in" or "Area",
        goals = AppendExtras(GoalsFor(cluster), cluster, others, arrived),
        minutes = arrived and 8 or 15,
        confidence = place and "reported" or "log",
        source = (place and place.source) or "quest-log",
    }
    if place then
        step.mapID = place.mapID
        step.x = place.x
        step.y = place.y
        step.pin = "approx"
        step.npc = place.npc
    end
    return step
end

local function MergeTitles(step, extra)
    if not extra then
        return
    end
    local titles = step.acceptTitles or {}
    local seen = {}
    for i = 1, #titles do
        seen[string.lower(titles[i])] = true
    end
    for i = 1, #extra do
        local name = extra[i]
        local key = string.lower(name)
        if not seen[key] then
            titles[#titles + 1] = name
            seen[key] = true
        end
    end
    if #titles > 0 then
        step.acceptTitles = titles
    end
end

local function CopyGoals(step, goals)
    if not goals or #goals == 0 then
        return
    end
    step.goals = step.goals or {}
    for i = #goals, 1, -1 do
        table.insert(step.goals, 1, goals[i])
    end
end

local function LeadGoal(step, name)
    local goals = step.goals
    if not goals or not name then
        return
    end
    for i = 2, #goals do
        if goals[i].name == name then
            local row = table.remove(goals, i)
            table.insert(goals, 1, row)
            return
        end
    end
end

function Area.Apply(built, char, log)
    if not built or not built.steps or not log or char.demo or built.key == "demo" then
        return
    end
    ClearStaleAssume(char)
    local raw = Rows(log)
    local rows = {}
    for i = 1, #raw do
        if KeepRow(raw[i]) then
            rows[#rows + 1] = raw[i]
        end
    end
    if #rows == 0 then
        return
    end
    local clusters = BuildClusters(rows)
    local chosen = Pick(clusters, char, log)
    if not chosen then
        return
    end
    local ids, tail = IdList(chosen)
    local arrived = Arrived(chosen)
    local extra = BestOther(clusters, chosen)
    local others = extra and { extra } or nil
    local steps = built.steps
    local kept = {}
    for i = 1, #steps do
        local step = steps[i]
        local liveNote = step.kind == "opportunity" and step.liveNote
        if step.kind ~= "proftrain" and not liveNote then
            kept[#kept + 1] = step
        end
    end
    local block = {}
    local place = chosen.place
    -- A log zone is one pocket at a time. A named NPC place stays one step.
    if not place then
        local pockets = ActivePockets(chosen, char)
        local lead
        local any = false
        for i = 1, #pockets do
            if not pockets[i].skipped then
                lead = pockets[i]
                break
            end
        end
        for i = 1, #pockets do
            local pocket = pockets[i]
            if not pocket.skipped then
                any = true
            end
            for r = 1, #pocket.rows do
                if pocket.rows[r].complete then
                    any = true
                end
            end
        end
        if not any then
            return
        end
        local here = TripArrived(char, chosen.zone)
        if lead and not here then
            block[#block + 1] = TravelStep(chosen, tail, lead)
        end
        for i = 1, #pockets do
            local pocket = pockets[i]
            local stay, fresh
            if not pocket.skipped then
                stay, fresh = SplitVisit(pocket, log)
            end
            if fresh then
                if stay and #stay > 0 then
                    block[#block + 1] = PocketStep(chosen, pocket, stay)
                end
            elseif not pocket.skipped then
                block[#block + 1] = PocketStep(chosen, pocket)
            end
            local hand = HandInStep(chosen, pocket)
            if hand then
                block[#block + 1] = hand
            end
            if fresh then
                block[#block + 1] = FreshStep(chosen, pocket, fresh)
            end
        end
    else
        -- A named plateau stays on the area step, so a starter zone does not grey the walk.
        if not arrived and not place.placeName then
            local goals = GoalsFor(chosen)
            local byWind = LeavingByWind(chosen.zone)
            local title = "Go to " .. chosen.zone
            local arrive = "Arrive in " .. chosen.zone
            local mapID = place.mapID
            local x = place.x
            local y = place.y
            local npc = place.npc
            local text = Describe(chosen, others, false)
            local source = place.source or "quest-log"
            if byWind then
                title = "Fly to " .. chosen.zone
                arrive = title
                mapID = 1456
                x = 0.47
                y = 0.49
                npc = "Tal"
                text = WindText(chosen.zone) .. " " .. text
                source = "wowhead-thunder-bluff-tal"
            end
            table.insert(goals, 1, { name = arrive, have = 0, need = 1 })
            block[#block + 1] = {
                id = chosen.goId or ("dyn-area-go-" .. Slug(chosen.key) .. tail),
                cluster = "area-" .. Slug(chosen.zone),
                kind = "travel",
                title = title,
                text = text,
                zone = chosen.zone,
                mapID = mapID,
                x = x,
                y = y,
                pin = (mapID and x and y) and "approx" or nil,
                npc = npc,
                completeOnZone = chosen.zone,
                goalHeader = "Area",
                goals = AppendExtras(goals, chosen, others, false),
                flyGoal = byWind and title or nil,
                minutes = 15,
                confidence = (place or byWind) and "reported" or "log",
                source = source,
            }
        end
        block[#block + 1] = AreaStep(chosen, ids, tail, arrived, others)
    end
    local onMuln = place and place.npc == "Muln Earthfury"
    local plateauSkipped = char.skips and char.skips["dyn-opportunity-plateau"]
    if built.plateauLead and not onMuln and not plateauSkipped then
        table.insert(block, 1, {
            id = "dyn-opportunity-plateau",
            kind = "opportunity",
            title = "Skywatcher Plateau",
            text = "Muln Earthfury still offers Defending the Dead and The Broodmother. Both are in range. The Broodmother is an elite at Gloomrise. Bring help. The pin is Muln. Gloomrise has no published coordinates.",
            zone = "Mulgore",
            placeName = "Skywatcher Plateau",
            mapID = 1412,
            x = 0.334,
            y = 0.224,
            pin = "approx",
            npc = "Muln Earthfury",
            goalHeader = "Pick up",
            goals = {},
            minutes = 10,
            confidence = "reported",
            source = "wowhead-forever-npc-259118",
        })
    end
    for i = 1, #block do
        CopyGoals(block[i], built.opportunityGoals)
        if block[i].flyGoal then
            LeadGoal(block[i], block[i].flyGoal)
            block[i].flyGoal = nil
        end
        if (place and place.npc == "Muln Earthfury") or block[i].npc == "Muln Earthfury" then
            local pickup = {}
            local offered = { "Defending the Dead", "The Broodmother" }
            for n = 1, #offered do
                local name = offered[n]
                if not QS.Level or not QS.Level.FastTitle or QS.Level.FastTitle(name, nil) then
                    pickup[#pickup + 1] = name
                end
            end
            MergeTitles(block[i], pickup)
        end
        MergeTitles(block[i], built.acceptTitles)
    end
    for i = #block, 1, -1 do
        table.insert(kept, 1, block[i])
    end
    built.steps = kept
    if place then
        built.routeName = (place.placeName or chosen.zone) .. " · " .. place.npc
    else
        built.routeName = chosen.zone
    end
    built.areaFocus = true
end
