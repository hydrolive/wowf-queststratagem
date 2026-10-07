QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Router = {}
QS.Router = Router

local function CopyList(list)
    local out = {}
    for i = 1, #list do
        out[i] = list[i]
    end
    return out
end

local function Allowed(step, identity, char)
    if step.classes and not step.classes[identity.class] then
        return false
    end
    if step.races and not step.races[identity.race] then
        return false
    end
    if step.classQuest and not char.classQuests then
        return false
    end
    if step.profession and not char.professionSteps then
        return false
    end
    if step.confidence == "stub" and not char.includeStubs and not step.always then
        return false
    end
    return true
end

local function DropExclusive(steps, log)
    local out = {}
    for i = 1, #steps do
        local step = steps[i]
        local blocked = false
        if step.exclusive then
            for n = 1, #step.exclusive do
                local id = step.exclusive[n]
                if log.completed[id] or QS.Api.NoteIfFlagged(log, id) then
                    blocked = true
                    break
                end
            end
        end
        if not blocked then
            out[#out + 1] = step
        end
    end
    return out
end

local function KeepStubsIfEmpty(steps, original)
    if #steps > 0 then
        return steps
    end
    return CopyList(original)
end

local function ApplyOverlays(steps, char)
    local overlays = QS.Registry.overlays
    for i = 1, #overlays do
        local op = overlays[i]
        if op.confidence == "stub" and not char.includeStubs then
            -- Forever stubs stay off until a source names them.
        elseif op.op == "disable" and op.anchor then
            local kept = {}
            for n = 1, #steps do
                if steps[n].id ~= op.anchor then
                    kept[#kept + 1] = steps[n]
                end
            end
            steps = kept
        elseif op.op == "insert_after" and op.anchor and op.step then
            local nextSteps = {}
            local placed = false
            for n = 1, #steps do
                nextSteps[#nextSteps + 1] = steps[n]
                if steps[n].id == op.anchor then
                    nextSteps[#nextSteps + 1] = op.step
                    placed = true
                end
            end
            if placed then
                steps = nextSteps
            end
        elseif op.op == "replace" and op.anchor and op.step then
            for n = 1, #steps do
                if steps[n].id == op.anchor then
                    steps[n] = op.step
                end
            end
        end
    end
    return steps
end

local function QuestSatisfied(log, questID, state)
    local turned = log.completed[questID] or QS.Api.NoteIfFlagged(log, questID)
    local accepted = (log.inLog[questID] ~= nil) or turned
    if state == "accepted" then
        return accepted
    end
    if state == "not_turnedin" then
        return not turned
    end
    return turned
end

local function EarlierQuest(steps, index, questID)
    for i = 1, index - 1 do
        local step = steps[i]
        if step.questID == questID then
            return true
        end
    end
    return false
end

local function InjectPrecursors(steps, log, debug)
    local guard = 0
    local index = 1
    while index <= #steps and guard < 8 do
        local step = steps[index]
        local missing
        if step.requiresQuest then
            for n = 1, #step.requiresQuest do
                local questID = step.requiresQuest[n]
                if not QuestSatisfied(log, questID, step.requiresState) and not EarlierQuest(steps, index, questID) then
                    missing = questID
                    break
                end
            end
        end
        if not missing then
            index = index + 1
        else
            local block = {}
            local kept = {}
            for n = 1, #steps do
                if steps[n].questID == missing then
                    block[#block + 1] = steps[n]
                else
                    kept[#kept + 1] = steps[n]
                end
            end
            if #block == 0 then
                index = index + 1
            else
                local spot = 1
                for n = 1, #kept do
                    if kept[n].id == step.id then
                        spot = n
                        break
                    end
                end
                local merged = {}
                for n = 1, spot - 1 do
                    merged[#merged + 1] = kept[n]
                end
                for n = 1, #block do
                    merged[#merged + 1] = block[n]
                end
                for n = spot, #kept do
                    merged[#merged + 1] = kept[n]
                end
                steps = merged
                guard = guard + 1
            end
        end
    end
    if guard >= 8 and debug then
        QS:Print("Precursor walk stopped at depth 8.")
    end
    return steps
end

local function Sum(group, field)
    local n = 0
    for i = 1, #group do
        n = n + (group[i][field] or 0)
    end
    return n
end

local function BatchAccepts(group)
    local first = group[1]
    local ids = {}
    local goals = {}
    for i = 1, #group do
        local step = group[i]
        ids[#ids + 1] = step.questID
        goals[#goals + 1] = {
            name = (step.npc or "NPC") .. " · " .. step.title,
            questID = step.questID,
        }
    end
    return {
        id = "batch-" .. (first.cluster or "hub") .. "-" .. first.id,
        cluster = first.cluster,
        order = first.order,
        kind = "accept",
        title = "Pick up at " .. (first.hubName or first.zone or "the hub"),
        text = "Accept these before you leave. The goals list is the order.",
        zone = first.zone,
        mapID = first.mapID,
        x = first.x,
        y = first.y,
        npc = first.npc,
        pin = first.pin or "npc",
        questIDs = ids,
        goals = goals,
        hubName = first.hubName,
        minutes = Sum(group, "minutes"),
        xp = Sum(group, "xp"),
        source = first.source,
        confidence = first.confidence,
        starter = first.starter,
        synthetic = true,
    }
end

local function ClusterBatch(steps)
    local out = {}
    local i = 1
    while i <= #steps do
        local step = steps[i]
        if step.kind == "accept" and step.cluster and step.questID and not step.noBatch then
            local group = { step }
            local j = i
            while steps[j + 1]
                and steps[j + 1].kind == "accept"
                and steps[j + 1].cluster == step.cluster
                and steps[j + 1].questID
                and not steps[j + 1].noBatch
            do
                j = j + 1
                group[#group + 1] = steps[j]
            end
            if #group >= 2 then
                out[#out + 1] = BatchAccepts(group)
            else
                out[#out + 1] = step
            end
            i = j + 1
        else
            out[#out + 1] = step
            i = i + 1
        end
    end
    return out
end

local function InsertDungeons(steps, identity, char, level)
    if not char.dungeonDetours then
        return steps
    end
    local dungeons = QS.Registry.dungeons
    for i = 1, #dungeons do
        local dungeon = dungeons[i]
        if dungeon.confidence == "stub" and not char.includeStubs then
            -- off
        elseif level >= dungeon.min and level <= dungeon.max then
            local factionOK = (not dungeon.faction) or dungeon.faction == identity.faction
            local hasQuest = dungeon.quests and #dungeon.quests > 0
            local bossSteps = (QS.Live and QS.Live.BossSteps(dungeon)) or {}
            local hasBoss = #bossSteps > 0
            if factionOK and (hasQuest or hasBoss) and not char.skips["dungeon-" .. dungeon.id] then
                local block = {}
                if hasQuest then
                    block[#block + 1] = {
                        id = "dungeon-" .. dungeon.id .. "-accept",
                        cluster = "dungeon-" .. dungeon.id,
                        kind = "accept",
                        title = "Pick up " .. dungeon.name,
                        text = dungeon.pickup or "Pick up the dungeon quests before you walk in.",
                        zone = dungeon.zone,
                        mapID = dungeon.mapID,
                        x = dungeon.x,
                        y = dungeon.y,
                        pin = "approx",
                        questIDs = dungeon.quests,
                        noBatch = true,
                        confidence = dungeon.confidence,
                        source = dungeon.source,
                        minutes = 8,
                    }
                end
                block[#block + 1] = {
                    id = "dungeon-" .. dungeon.id .. "-door",
                    cluster = "dungeon-" .. dungeon.id,
                    kind = "travel",
                    title = dungeon.name .. " entrance",
                    text = "Arrow to the entrance. Boss steps inside are kills, not quests.",
                    zone = dungeon.zone,
                    mapID = dungeon.mapID,
                    x = dungeon.entranceX or dungeon.x,
                    y = dungeon.entranceY or dungeon.y,
                    pin = "approx",
                    completeOnZone = dungeon.insideZone,
                    confidence = dungeon.confidence,
                    source = dungeon.source,
                    minutes = 6,
                }
                if hasBoss then
                    for b = 1, #bossSteps do
                        block[#block + 1] = bossSteps[b]
                    end
                else
                    block[#block + 1] = {
                        id = "dungeon-" .. dungeon.id .. "-inside",
                        cluster = "dungeon-" .. dungeon.id,
                        kind = "dungeon",
                        title = "Inside " .. dungeon.name,
                        text = dungeon.note or "Quest objectives and any BiS drop named in the goals.",
                        zone = dungeon.zone,
                        dungeon = { id = dungeon.id },
                        questIDs = dungeon.quests,
                        confidence = dungeon.confidence,
                        source = dungeon.source,
                        minutes = dungeon.minutes or 35,
                    }
                end
                if hasQuest then
                    block[#block + 1] = {
                        id = "dungeon-" .. dungeon.id .. "-turnin",
                        cluster = "dungeon-" .. dungeon.id,
                        kind = "turnin",
                        title = "Turn in " .. dungeon.name,
                        text = "Turn the dungeon quests in outside.",
                        zone = dungeon.zone,
                        mapID = dungeon.mapID,
                        x = dungeon.x,
                        y = dungeon.y,
                        pin = "approx",
                        questIDs = dungeon.quests,
                        confidence = dungeon.confidence,
                        source = dungeon.source,
                        minutes = 5,
                    }
                end
                local spot = #steps + 1
                for n = 1, #steps do
                    if (steps[n].minLevel or 1) >= dungeon.min then
                        spot = n
                        break
                    end
                end
                for n = #block, 1, -1 do
                    table.insert(steps, spot, block[n])
                end
            end
        end
    end
    return steps
end

local function Terminal(identity)
    if identity.faction == "Horde" then
        return {
            id = "band-next-horde",
            cluster = "next-band",
            kind = "travel",
            title = "Next band is not authored",
            text = "Barrens, Silverpine, and the road to 60 are not in this data version. Next parks this note.",
            zone = "The Barrens",
            confidence = "stub",
            always = true,
            source = "design-2026-10-05",
            minutes = 30,
        }
    end
    return {
        id = "band-next-alliance",
        cluster = "next-band",
        kind = "travel",
        title = "Next band is not authored",
        text = "Westfall, Loch Modan, and the road to 60 are not in this data version. Next parks this note.",
        zone = "Westfall",
        confidence = "stub",
        always = true,
        source = "design-2026-10-05",
        minutes = 30,
    }
end

function Router.Build(identity, char)
    if char.demo and QS.Registry.demo then
        return {
            steps = CopyList(QS.Registry.demo),
            routeName = "Demo route",
            warning = "Demo steps for the panel. /qs demo returns to the stratagem.",
            key = "demo",
            fallback = false,
        }
    end
    local faction, race, class = identity.faction, identity.race, identity.class
    local cover = QS.Registry.coverage[faction] and QS.Registry.coverage[faction][race]
    local known = cover and cover[class]
    local def = QS.Registry.races[faction] and QS.Registry.races[faction][race]
    local warning
    local fallback = false
    if not def or def.stub then
        local fbRace = (def and def.fallback) or (faction == "Horde" and "Orc" or "Human")
        local fb = QS.Registry.races[faction] and QS.Registry.races[faction][fbRace]
        if fb and not fb.stub then
            warning = string.format("No stratagem for %s %s yet. Classic spine will be used.", race, class)
            def = fb
            fallback = true
        end
    elseif not known then
        warning = string.format("No stratagem for %s %s yet. Classic spine will be used.", race, class)
        fallback = true
    end
    local source = (def and def.steps) or {}
    local steps = {}
    for i = 1, #source do
        if Allowed(source[i], identity, char) then
            steps[#steps + 1] = source[i]
        end
    end
    steps = KeepStubsIfEmpty(steps, source)
    local log = QS.Api.Snapshot()
    steps = ApplyOverlays(steps, char)
    steps = DropExclusive(steps, log)
    steps = InsertDungeons(steps, identity, char, UnitLevel("player") or 1)
    steps = InjectPrecursors(steps, log, QS.db and QS.db.debug)
    steps = ClusterBatch(steps)
    if not fallback and not (def and def.noTerminal) then
        steps[#steps + 1] = Terminal(identity)
    end
    return {
        steps = steps,
        routeName = (def and def.routeName) or "Stratagem",
        warning = warning,
        key = faction .. "-" .. race .. "-" .. class,
        fallback = fallback,
    }
end
