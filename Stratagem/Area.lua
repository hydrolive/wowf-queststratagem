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

local function Pick(clusters)
    local best, bestScore
    for i = 1, #clusters do
        local cluster = clusters[i]
        local ready, open = Tally(cluster)
        if ready > 0 or open > 0 then
            local here = ZoneHere(cluster.zone)
            local score
            if here and ready > 0 then
                score = 3000 + ready
            elseif here and open > 0 then
                score = 2000 + open
            elseif ready > 0 then
                score = 1000 + ready
            else
                score = open
            end
            if not best or score > bestScore then
                best = cluster
                bestScore = score
            end
        end
    end
    return best
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

local function Describe(cluster, others)
    local place = cluster.place
    local ready, open = Tally(cluster)
    local text
    if place and ready > 0 and open == 0 then
        text = "Turn in to " .. place.npc .. " in " .. place.where .. ". " .. (place.watch or "")
        if place.note then
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
    if others then
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

local function OtherReady(clusters, chosen)
    local out = {}
    for i = 1, #clusters do
        local cluster = clusters[i]
        if cluster ~= chosen then
            for n = 1, #cluster.rows do
                local row = cluster.rows[n]
                if row.complete then
                    out[#out + 1] = {
                        title = row.title,
                        zone = cluster.zone,
                        place = cluster.place,
                    }
                end
            end
        end
    end
    return out
end

local function AreaStep(cluster, ids, tail, here, others)
    local place = cluster.place
    local ready, open = Tally(cluster)
    local title
    if place and ready > 0 and open == 0 then
        title = "Turn in to " .. place.npc
    elseif here then
        title = cluster.zone
    else
        title = "Go to " .. cluster.zone
    end
    local step = {
        id = "dyn-area-" .. Slug(cluster.key) .. tail,
        cluster = "area-" .. Slug(cluster.zone),
        kind = "area",
        areaTurnin = (ready > 0 and open == 0) or nil,
        title = title,
        text = Describe(cluster, others),
        zone = cluster.zone,
        questIDs = ids,
        goalHeader = (ready > 0 and open == 0) and "Turn in" or "Area",
        goals = GoalsFor(cluster),
        minutes = here and 8 or 15,
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

function Area.Apply(built, char, log)
    if not built or not built.steps or not log or char.demo or built.key == "demo" then
        return
    end
    local rows = Rows(log)
    if #rows == 0 then
        return
    end
    local clusters = BuildClusters(rows)
    local chosen = Pick(clusters)
    if not chosen then
        return
    end
    local ids, tail = IdList(chosen)
    local here = ZoneHere(chosen.zone)
    local others = OtherReady(clusters, chosen)
    local steps = built.steps
    local kept = {}
    for i = 1, #steps do
        if steps[i].kind ~= "proftrain" then
            kept[#kept + 1] = steps[i]
        end
    end
    local block = {}
    if not here then
        local place = chosen.place
        block[#block + 1] = {
            id = "dyn-area-go-" .. Slug(chosen.key) .. tail,
            cluster = "area-" .. Slug(chosen.zone),
            kind = "travel",
            title = "Go to " .. chosen.zone,
            text = Describe(chosen, others),
            zone = chosen.zone,
            mapID = place and place.mapID or nil,
            x = place and place.x or nil,
            y = place and place.y or nil,
            pin = place and "approx" or nil,
            npc = place and place.npc or nil,
            completeOnZone = chosen.zone,
            goalHeader = "Area",
            goals = { { name = "Arrive in " .. chosen.zone, have = 0, need = 1 } },
            minutes = 15,
            confidence = place and "reported" or "log",
            source = (place and place.source) or "quest-log",
        }
    end
    block[#block + 1] = AreaStep(chosen, ids, tail, here, others)
    for i = #block, 1, -1 do
        table.insert(kept, 1, block[i])
    end
    built.steps = kept
    local place = chosen.place
    if place then
        built.routeName = chosen.zone .. " · " .. place.npc
    else
        built.routeName = chosen.zone
    end
    built.areaFocus = true
end
