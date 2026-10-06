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

local function ZoneHere(zone)
    if not zone or zone == "" then
        return false
    end
    local place = QS.Api.Place()
    return zone == place.zone or zone == place.real or zone == place.sub
end

local function MakeRow(id, info)
    local place = PlaceFor(info.title)
    return {
        id = id,
        title = info.title or ("Quest " .. id),
        complete = info.complete and true or false,
        objectives = info.objectives or {},
        zone = (place and place.zone) or info.zone or "Quests",
        place = place,
    }
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

local function GoalsFor(cluster)
    local goals = {}
    for i = 1, #cluster.rows do
        local row = cluster.rows[i]
        if row.complete then
            goals[#goals + 1] = { name = "Turn in " .. row.title, have = 0, need = 1 }
        else
            local added = false
            for j = 1, #row.objectives do
                local obj = row.objectives[j]
                if not obj.finished then
                    goals[#goals + 1] = {
                        name = obj.text or row.title,
                        have = obj.have or 0,
                        need = obj.need or 0,
                    }
                    added = true
                end
            end
            if not added then
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

function Area.Apply(built, char, log)
    if not built or not built.steps or not log or char.demo or built.key == "demo" then
        return
    end
    local rows = Rows(log)
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
    -- A named plateau stays on the area step, so a starter zone does not grey the walk.
    if not arrived and not (place and place.placeName) then
        local goals = GoalsFor(chosen)
        table.insert(goals, 1, { name = "Arrive in " .. chosen.zone, have = 0, need = 1 })
        block[#block + 1] = {
            id = chosen.goId or ("dyn-area-go-" .. Slug(chosen.key) .. tail),
            cluster = "area-" .. Slug(chosen.zone),
            kind = "travel",
            title = "Go to " .. chosen.zone,
            text = Describe(chosen, others, false),
            zone = chosen.zone,
            mapID = place and place.mapID or nil,
            x = place and place.x or nil,
            y = place and place.y or nil,
            pin = place and "approx" or nil,
            npc = place and place.npc or nil,
            completeOnZone = chosen.zone,
            goalHeader = "Area",
            goals = AppendExtras(goals, chosen, others, false),
            minutes = 15,
            confidence = place and "reported" or "log",
            source = (place and place.source) or "quest-log",
        }
    end
    block[#block + 1] = AreaStep(chosen, ids, tail, arrived, others)
    local onMuln = place and place.npc == "Muln Earthfury"
    local plateauSkipped = char.skips and char.skips["dyn-opportunity-plateau"]
    if built.plateauLead and not onMuln and not plateauSkipped then
        table.insert(block, 1, {
            id = "dyn-opportunity-plateau",
            kind = "opportunity",
            title = "Skywatcher Plateau",
            text = "Muln Earthfury still offers Defending the Dead and The Broodmother. Both are in range. The Broodmother is an elite at Gloomrise. Bring help. The pin is Muln. Gloomrise has no published coordinates.",
            zone = "Mulgore",
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
        if (place and place.npc == "Muln Earthfury") or block[i].npc == "Muln Earthfury" then
            MergeTitles(block[i], { "Defending the Dead", "The Broodmother" })
        end
        MergeTitles(block[i], built.acceptTitles)
    end
    for i = #block, 1, -1 do
        table.insert(kept, 1, block[i])
    end
    built.steps = kept
    if built.plateauLead and not onMuln and not plateauSkipped then
        built.routeName = "Skywatcher Plateau · Muln Earthfury"
    elseif place then
        built.routeName = (place.placeName or chosen.zone) .. " · " .. place.npc
    else
        built.routeName = chosen.zone
    end
    built.areaFocus = true
end
