-- Steps that depend on where you are: hearth, talents, trainers, crafting,
-- full bags, bank, auction, and the boss you are walking toward.
-- These are rebuilt every refresh. They are not written into the race files.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Live = {}
QS.Live = Live

local GATHER_NEED = 20
local KEEP_STACK = 20
local SELL_AT = 3

local CRAFT_ORDER = {
    "Alchemy", "Blacksmithing", "Engineering", "Enchanting",
    "Leatherworking", "Tailoring", "First Aid", "Cooking",
}

local TRAIN_NAMES = {
    Herbalism = true, Mining = true, Skinning = true,
    Alchemy = true, Blacksmithing = true, Engineering = true,
    Enchanting = true, Leatherworking = true, Tailoring = true,
    Cooking = true, ["First Aid"] = true, Fishing = true,
}

local GATHER_KINDS = {
    accept = true, objective = true, turnin = true, travel = true,
    train = true, hearth = true, fly = true, dungeon = true, note = true,
    area = true,
}

-- Classic skill-line names a class can learn from a weapon master.
local CLASS_WEAPONS = {
    WARRIOR = { "Axes", "Two-Handed Axes", "Swords", "Two-Handed Swords", "Maces", "Two-Handed Maces", "Daggers", "Fist Weapons", "Staves", "Polearms", "Bows", "Guns", "Crossbows", "Thrown" },
    PALADIN = { "Swords", "Two-Handed Swords", "Maces", "Two-Handed Maces", "Polearms" },
    HUNTER = { "Axes", "Two-Handed Axes", "Swords", "Two-Handed Swords", "Daggers", "Fist Weapons", "Staves", "Polearms", "Bows", "Guns", "Crossbows", "Thrown" },
    ROGUE = { "Swords", "Maces", "Daggers", "Fist Weapons", "Bows", "Guns", "Crossbows", "Thrown" },
    PRIEST = { "Maces", "Staves", "Daggers" },
    MAGE = { "Swords", "Staves", "Daggers" },
    WARLOCK = { "Swords", "Staves", "Daggers" },
    SHAMAN = { "Axes", "Two-Handed Axes", "Maces", "Two-Handed Maces", "Staves", "Fist Weapons", "Daggers" },
    DRUID = { "Maces", "Two-Handed Maces", "Staves", "Daggers", "Fist Weapons", "Polearms" },
}

-- Blizzard Watch, 2024-11-27. Coordinates are the classic city pins, not inns.
local WEAPON_MASTERS = {
    ["Orgrimmar"] = {
        { npc = "Sayoc and Hanashi", where = "Valley of Honor (81, 19)", skills = { "Bows", "Daggers", "Fist Weapons", "Axes", "Staves", "Thrown", "Two-Handed Axes" } },
    },
    ["Undercity"] = {
        { npc = "Archibald", where = "War Quarter (57, 32)", skills = { "Crossbows", "Daggers", "Swords", "Two-Handed Swords", "Polearms" } },
    },
    ["Thunder Bluff"] = {
        { npc = "Ansekhwa", where = "central mesa, south-southwest of the pond (40, 63)", skills = { "Guns", "Maces", "Staves", "Two-Handed Maces" } },
    },
    ["Stormwind City"] = {
        { npc = "Woo Ping", where = "Trade District, Weller's Arsenal (57, 57)", skills = { "Crossbows", "Daggers", "Swords", "Staves", "Two-Handed Swords", "Polearms" } },
    },
    ["Ironforge"] = {
        { npc = "Bixi Wobblebonk and Buliwyf Stonehand", where = "Timberline Arms (61, 89)", skills = { "Crossbows", "Daggers", "Thrown", "Fist Weapons", "Guns", "Axes", "Two-Handed Axes", "Maces", "Two-Handed Maces" } },
    },
    ["Darnassus"] = {
        { npc = "Ilyenia Moonfire", where = "Warrior's Terrace (57, 46)", skills = { "Bows", "Daggers", "Fist Weapons", "Staves", "Thrown" } },
    },
}

local PLATEAU_OFFERS = {
    {
        title = "Defending the Dead",
        minLevel = 23,
        questLevel = 30,
        faction = "Horde",
        goal = "Accept Defending the Dead from Muln Earthfury",
        text = "Muln Earthfury on Skywatcher Plateau offers Defending the Dead, a level 30 Mulgore quest.",
        source = "wowhead-forever-npc-259118",
    },
    {
        title = "The Broodmother",
        questID = 96261,
        minLevel = 23,
        questLevel = 31,
        elite = true,
        faction = "Horde",
        goal = "Accept The Broodmother (elite, Gloomrise, bring help)",
        text = "Muln Earthfury offers The Broodmother. Kill Broodmother Valraxx at Gloomrise and bring help. The pin stays on Muln.",
        source = "wowhead-forever-96261",
    },
}

local function Data()
    return QS.Services
end

local function Show(char, id, want)
    if not want then
        char.skips[id] = nil
        return false
    end
    if char.skips[id] then
        return false
    end
    return true
end

local function Capital(faction)
    if faction == "Horde" then
        return "Orgrimmar"
    end
    return "Stormwind City"
end

local function CountOf(bags, itemID)
    local row = bags.byId[itemID]
    return row and row.count or 0
end

function Live.TalentKey(identity)
    local spec = QS.Config.ActiveSpec()
    local map = Data().classTalent[identity.classFile]
    local key = map and map[spec]
    if key and Data().talents[key] then
        return Data().talents[key], spec
    end
    return Data().talents[spec], spec
end

function Live.NextTalent(identity)
    local order, spec = Live.TalentKey(identity)
    if not order then
        return nil
    end
    local level = UnitLevel("player") or 1
    local unspent = QS.Api.UnspentTalents() or 0
    if level < 10 or unspent < 1 then
        return nil
    end
    local lockedName, lockedRank
    local saw = false
    for i = 1, #order do
        local name = order[i]
        local rank, available = QS.Api.TalentState(name)
        if rank ~= nil then
            saw = true
            local want = 0
            for n = 1, i do
                if order[n] == name then
                    want = want + 1
                end
            end
            if rank < want then
                if available then
                    return name, want, unspent, spec, false
                elseif not lockedName then
                    lockedName, lockedRank = name, want
                end
            end
        end
    end
    if lockedName then
        return lockedName, lockedRank, unspent, spec, true
    end
    if not saw then
        local spent = (level - 9) - unspent
        if spent < 0 then
            spent = 0
        end
        local name = order[spent + 1]
        if name then
            return name, 1, unspent, spec, false
        end
    end
    return nil, nil, unspent, spec, false
end

function Live.BossSteps(dungeon)
    local list = Data().bosses[dungeon.id]
    if not list then
        return {}
    end
    local steps = {}
    for i = 1, #list do
        local boss = list[i]
        steps[#steps + 1] = {
            id = "boss-" .. dungeon.id .. "-" .. i,
            cluster = "dungeon-" .. dungeon.id,
            kind = "boss",
            title = boss.name,
            boss = boss.name,
            text = "Boss " .. i .. " of " .. #list .. " in " .. (dungeon.insideZone or dungeon.name)
                .. ". Not a quest and not a BiS check. Kill " .. boss.name .. ".",
            zone = dungeon.insideZone or dungeon.name,
            mapID = boss.mapID,
            x = boss.x,
            y = boss.y,
            pin = boss.x and "approx" or nil,
            goalHeader = "Boss",
            goals = { { name = boss.name, have = 0, need = 1 } },
            dungeon = { id = dungeon.id },
            minutes = 4,
            confidence = "reported",
            source = "classic-boss-order-2026-10-05",
        }
    end
    return steps
end

function Live.HereDungeon()
    local place = QS.Api.Place()
    local dungeons = QS.Registry.dungeons
    for i = 1, #dungeons do
        local row = dungeons[i]
        if row.insideZone and (row.insideZone == place.real or row.insideZone == place.zone) then
            return row
        end
    end
    return nil
end

local function CurrentCity(place)
    local cities = Data().cities
    if cities[place.sub] then
        return place.sub, cities[place.sub]
    end
    if cities[place.zone] then
        return place.zone, cities[place.zone]
    end
    if cities[place.real] then
        return place.real, cities[place.real]
    end
    return nil
end

local function FindInn(zone, hub, cluster)
    local inns = Data().inns
    for i = 1, #inns do
        local inn = inns[i]
        if inn.zone == zone and hub and inn.hub == hub then
            return inn
        end
        if inn.zone == zone and cluster and inn.cluster == cluster then
            return inn
        end
    end
    return nil
end

local function InnByBind(bind)
    local inns = Data().inns
    for i = 1, #inns do
        if inns[i].bind == bind then
            return inns[i]
        end
    end
    return nil
end

local function InnForZone(zone, faction)
    local inns = Data().inns
    for i = 1, #inns do
        if inns[i].zone == zone then
            return inns[i]
        end
    end
    local capital = Capital(faction)
    for i = 1, #inns do
        if inns[i].zone == capital then
            return inns[i]
        end
    end
    return nil
end

local function UpcomingSetHearth(steps, index, zone, log)
    local last = index + 15
    if last > #steps then
        last = #steps
    end
    for i = index, last do
        local step = steps[i]
        if step.kind == "hearth" and not step.hearthUse and step.zone == zone and not QS.Resume.Done(step, log) then
            return true
        end
    end
    return false
end

local function CopyWith(step, extra)
    local copy = {}
    for k, v in pairs(step) do
        copy[k] = v
    end
    copy.extraGoals = extra
    return copy
end

local function PickNodes(list, rank, limit)
    local picked = {}
    for i = 1, #list do
        local node = list[i]
        if node.skill <= rank + 25 and node.skill >= rank - 50 then
            picked[#picked + 1] = node
        end
    end
    if #picked > limit then
        local trimmed = {}
        for i = #picked - limit + 1, #picked do
            trimmed[#trimmed + 1] = picked[i]
        end
        picked = trimmed
    end
    return picked
end

local function GatherFor(zone, bags, char)
    if not char.professionSteps or not zone or Data().cities[zone] then
        return nil
    end
    local goals = {}
    local function push(node)
        if #goals >= 3 then
            return
        end
        local have = CountOf(bags, node.id)
        if have > GATHER_NEED then
            have = GATHER_NEED
        end
        goals[#goals + 1] = { name = "Gather " .. node.name, have = have, need = GATHER_NEED }
    end
    local herb = QS.Api.Skill("Herbalism")
    local herbs = herb and Data().herbs[zone]
    if herbs then
        local picked = PickNodes(herbs, herb.rank, 2)
        for i = 1, #picked do
            push(picked[i])
        end
    end
    local mine = QS.Api.Skill("Mining")
    local ore = mine and Data().ore[zone]
    if ore then
        local picked = PickNodes(ore, mine.rank, 2)
        for i = 1, #picked do
            push(picked[i])
        end
    end
    local skin = QS.Api.Skill("Skinning")
    if skin then
        for i = 1, #Data().skins do
            local node = Data().skins[i]
            if skin.rank >= node.skill and skin.rank < node.untilSkill then
                push(node)
            end
        end
    end
    if #goals == 0 then
        return nil
    end
    return goals
end

local function Annotate(steps, bags, char)
    local cache = {}
    local out = {}
    for i = 1, #steps do
        local step = steps[i]
        local extra
        if GATHER_KINDS[step.kind] and step.zone then
            extra = cache[step.zone]
            if extra == nil then
                extra = GatherFor(step.zone, bags, char) or false
                cache[step.zone] = extra
            end
            if extra == false then
                extra = nil
            end
        end
        if extra then
            out[#out + 1] = CopyWith(step, extra)
        else
            out[#out + 1] = step
        end
    end
    return out
end

local function TalentStep(identity)
    local name, rank, unspent, spec, locked = Live.NextTalent(identity)
    if not unspent or unspent < 1 then
        return nil
    end
    if not name then
        name = QS.Config.SpecLabel(spec)
        rank = unspent
    end
    local text = "Apply " .. name
    if rank and rank > 1 then
        text = text .. " rank " .. rank
    end
    text = text .. " for " .. QS.Config.SpecLabel(spec) .. ". Open the talent frame and spend the point."
    if locked then
        text = text .. " If the talent is locked, it needs more points in that tree first."
    end
    return {
        id = "dyn-talent",
        kind = "talent",
        talentName = name,
        talentRank = rank or 1,
        unspentAt = unspent,
        title = "Talent: " .. name,
        text = text,
        goalHeader = "Talent",
        goals = { { name = name, have = (rank or 1) - 1, need = rank or 1 } },
        minutes = 1,
        confidence = "reported",
        source = "classic-leveling-2026-10-05",
    }
end

local function CanMake(bags, recipe)
    local makes = 999
    for i = 1, #recipe.reagents do
        local reagent = recipe.reagents[i]
        local need = reagent[3]
        if not need or need < 1 then
            return 0
        end
        local have = CountOf(bags, reagent[1])
        local n = math.floor(have / need)
        if n < makes then
            makes = n
        end
    end
    if makes == 999 or makes < 1 then
        return 0
    end
    return makes
end

local function CraftStep(bags, char)
    if not char.professionSteps then
        return nil
    end
    for i = 1, #CRAFT_ORDER do
        local prof = CRAFT_ORDER[i]
        local skill = QS.Api.Skill(prof)
        local list = skill and Data().crafts[prof]
        if list then
            for n = 1, #list do
                local recipe = list[n]
                if skill.rank < recipe.untilSkill and skill.rank + 25 >= recipe.skill then
                    local makes = CanMake(bags, recipe)
                    if makes > 0 then
                        local goals = {}
                        for r = 1, #recipe.reagents do
                            local reagent = recipe.reagents[r]
                            goals[#goals + 1] = {
                                name = reagent[2],
                                have = CountOf(bags, reagent[1]),
                                need = reagent[3],
                            }
                        end
                        local cap = recipe.untilSkill - skill.rank
                        if cap < 1 then
                            cap = 1
                        end
                        if makes > cap then
                            makes = cap
                        end
                        goals[#goals + 1] = { name = "Craft " .. recipe.name, have = 0, need = makes }
                        local text = "You have the materials for " .. recipe.name .. ". Craft it until " .. prof .. " reaches " .. recipe.untilSkill .. "."
                        if recipe.station == "fire" then
                            text = text .. " Stand at a fire."
                        end
                        local productAt = 0
                        if recipe.product then
                            productAt = CountOf(bags, recipe.product)
                        end
                        return {
                            id = "dyn-craft",
                            kind = "craft",
                            profession = prof,
                            product = recipe.product,
                            productAt = productAt,
                            rankAt = skill.rank,
                            title = "Craft " .. recipe.name,
                            text = text,
                            goalHeader = "Craft",
                            goals = goals,
                            minutes = 5,
                            confidence = "reported",
                            source = "classic-profession-2026-10-05",
                        }
                    end
                end
            end
        end
    end
    return nil
end

function Live.NextTrain(skill)
    if not skill then
        return nil
    end
    local maxRank = skill.max or 0
    local rank = skill.rank or 0
    local gate, name
    if maxRank <= 75 then
        gate, name = 50, "Journeyman"
    elseif maxRank <= 150 then
        gate, name = 125, "Expert"
    elseif maxRank <= 225 then
        gate, name = 200, "Artisan"
    else
        return nil
    end
    if rank + 5 < gate then
        return nil
    end
    return name
end

local function TrainerStep(cityName, prof, skill, away, rankName)
    local row = Data().trainers[cityName] and Data().trainers[cityName][prof]
    if not row then
        return nil
    end
    local text = "Train " .. rankName .. " " .. prof .. " (" .. skill.rank .. "/" .. skill.max .. ") with " .. row.npc
    if row.where then
        text = text .. " in " .. row.where
    end
    text = text .. ". Recipes you already know are not listed."
    if away then
        text = "Your " .. prof .. " cap is " .. skill.rank .. "/" .. skill.max .. ". " .. row.npc .. " in " .. cityName .. " trains " .. rankName .. "."
    end
    return {
        id = "dyn-train-" .. cityName .. "-" .. prof .. "-" .. rankName,
        kind = "proftrain",
        profession = prof,
        rankAt = skill.rank,
        maxAt = skill.max,
        title = "Train " .. rankName .. " " .. prof,
        npc = row.npc,
        text = text,
        zone = cityName,
        mapID = row.mapID,
        x = row.x,
        y = row.y,
        pin = "approx",
        goalHeader = "Train",
        goals = { { name = "Train " .. rankName .. " " .. prof, have = 0, need = 1 } },
        minutes = away and 8 or 3,
        confidence = "reported",
        source = "classic-profession-2026-10-05",
    }
end

local function VendorStep(bags, place, faction, low)
    local inn = InnForZone(place.zone, faction) or InnForZone(place.real, faction)
    if not inn then
        return nil
    end
    local goals = {}
    for i = 1, #bags.list do
        local item = bags.list[i]
        if item.quality == 0 and #goals < 4 then
            goals[#goals + 1] = { name = "Sell " .. item.name, have = item.count, need = item.count }
        end
    end
    if low then
        goals[#goals + 1] = { name = "Repair", have = 0, need = 1 }
    end
    if #goals == 0 then
        goals[1] = { name = "Empty bags down to quest items and food", have = bags.free, need = 8 }
    end
    local title = "Sell and repair"
    if bags.free > SELL_AT then
        title = "Repair"
    elseif not low then
        title = "Sell junk"
    end
    return {
        id = "dyn-vendor",
        kind = "vendor",
        wantSell = bags.free <= SELL_AT,
        wantRepair = low and true or false,
        title = title,
        npc = inn.npc,
        text = "Bags or gear need a vendor. " .. inn.npc .. " in " .. (inn.bind or inn.zone) .. " buys junk and repairs.",
        zone = inn.zone,
        mapID = inn.mapID,
        x = inn.x,
        y = inn.y,
        pin = inn.pin or "approx",
        goalHeader = "Vendor",
        goals = goals,
        minutes = 4,
        confidence = "reported",
        source = "design-2026-10-05",
    }
end

local function StackGoals(rows, prefix, limit)
    local goals = {}
    for i = 1, #rows do
        if #goals >= limit then
            break
        end
        local item = rows[i]
        goals[#goals + 1] = { name = prefix .. item.name, have = item.count, need = item.count }
    end
    return goals
end

local function TownLists(bags)
    local bank, auction = {}, {}
    for i = 1, #bags.list do
        local item = bags.list[i]
        local class = item.class or ""
        if item.id ~= 6948 and class ~= "Quest" and item.subclass ~= "Quest" and item.subclass ~= "Key" then
            local trade = class == "Trade Goods" or class == "Recipe" or class == "Reagent"
            local extraFood = class == "Consumable" and item.count > KEEP_STACK
            if (trade or extraFood) and item.count > KEEP_STACK then
                bank[#bank + 1] = item
            elseif item.quality >= 2 and (class == "Weapon" or class == "Armor") and item.bound ~= true then
                auction[#auction + 1] = item
            end
        end
    end
    return bank, auction
end

local function Sig(rows)
    local s = ""
    local n = #rows
    if n > 5 then
        n = 5
    end
    for i = 1, n do
        s = s .. rows[i].id .. "x" .. rows[i].count .. "-"
    end
    return s
end

local function HearthSteps(steps, index, char, log, place)
    local out = {}
    local level = UnitLevel("player") or 1
    local bind = QS.Api.BindLocation()
    local frontier = steps[index]
    if frontier then
        local inn = FindInn(frontier.zone, frontier.hubName, frontier.cluster)
        local arrived
        if not inn then
            local inns = Data().inns
            for i = 1, #inns do
                local row = inns[i]
                if row.bind == place.sub and (row.zone == place.zone or row.zone == place.real) then
                    inn = row
                    arrived = true
                end
            end
        end
        if inn and bind == inn.bind then
            Show(char, "dyn-hearth-set-" .. inn.bind, false)
        elseif inn and level >= (inn.minLevel or 1) and bind ~= inn.bind then
            local quiet = (not arrived) and UpcomingSetHearth(steps, index, inn.zone, log)
            local id = "dyn-hearth-set-" .. inn.bind
            if not quiet and Show(char, id, true) then
                out[#out + 1] = {
                    id = id,
                    kind = "hearth",
                    bind = inn.bind,
                    title = "Set hearth in " .. inn.bind,
                    npc = inn.npc,
                    text = "New hub. Set your hearth with " .. inn.npc .. " in " .. inn.bind .. " before you leave.",
                    zone = inn.zone,
                    mapID = inn.mapID,
                    x = inn.x,
                    y = inn.y,
                    pin = inn.pin or "approx",
                    goalHeader = "Hearth",
                    goals = { { name = "Bind at " .. inn.bind, have = 0, need = 1 } },
                    minutes = 2,
                    confidence = "reported",
                    source = "design-2026-10-05",
                }
            elseif quiet then
                Show(char, "dyn-hearth-set-" .. inn.bind, false)
            end
        end
    end
    if frontier and (frontier.kind == "turnin" or (frontier.kind == "hearth" and frontier.questID)) then
        local inn = InnByBind(bind)
        if inn and (place.zone == inn.zone or place.real == inn.zone) then
            Show(char, "dyn-hearth-use-" .. inn.bind, false)
        elseif inn and inn.zone == frontier.zone and place.zone ~= inn.zone and place.real ~= inn.zone then
            local id = "dyn-hearth-use-" .. inn.bind
            if Show(char, id, true) then
                local remain = QS.Api.HearthCooldown()
                local text = "Turn-ins are in " .. inn.bind .. ". Use the Hearthstone."
                if remain > 0 then
                    text = "Hearthstone cooldown " .. remain .. "s. The arrow still walks you to " .. inn.npc .. "."
                end
                out[#out + 1] = {
                    id = id,
                    kind = "hearth",
                    hearthUse = true,
                    bind = inn.bind,
                    title = "Hearth to " .. inn.bind,
                    npc = inn.npc,
                    text = text,
                    zone = inn.zone,
                    mapID = inn.mapID,
                    x = inn.x,
                    y = inn.y,
                    pin = inn.pin or "approx",
                    goalHeader = "Hearth",
                    goals = { { name = "Arrive in " .. inn.bind, have = 0, need = 1 } },
                    minutes = 1,
                    confidence = "reported",
                    source = "design-2026-10-05",
                }
            end
        end
    end
    return out
end

local function SurfaceBosses(steps, char, log)
    local dungeon = Live.HereDungeon()
    if not dungeon then
        return
    end
    local pulled, kept = {}, {}
    for i = 1, #steps do
        local step = steps[i]
        local mine = step.kind == "boss" and step.dungeon and step.dungeon.id == dungeon.id
        if mine and not char.skips[step.id] and not QS.Resume.Done(step, log) then
            pulled[#pulled + 1] = step
        else
            kept[#kept + 1] = step
        end
    end
    if #pulled == 0 then
        local fresh = Live.BossSteps(dungeon)
        for i = 1, #fresh do
            local step = fresh[i]
            if not char.skips[step.id] and not (char.bossDown and char.bossDown[step.boss]) then
                pulled[#pulled + 1] = step
            end
        end
    end
    if #pulled == 0 then
        return
    end
    local spot = QS.Resume.FirstOpen(kept, log, char.skips) or (#kept + 1)
    for i = #pulled, 1, -1 do
        table.insert(kept, spot, pulled[i])
    end
    local previous = #steps
    for i = 1, #kept do
        steps[i] = kept[i]
    end
    for i = #kept + 1, previous do
        steps[i] = nil
    end
end

local function SlugId(text)
    local s = string.lower(text or "step")
    s = string.gsub(s, "[^%w]+", "-")
    s = string.gsub(s, "^-+", "")
    s = string.gsub(s, "-+$", "")
    if s == "" then
        s = "step"
    end
    return s
end

local function JoinWords(list, limit)
    local show = #list
    if show > limit then
        show = limit
    end
    local text = ""
    for i = 1, show do
        if i > 1 then
            text = text .. ", "
        end
        text = text .. list[i]
    end
    if #list > limit then
        text = text .. " +" .. (#list - limit)
    end
    return text
end

local function InColor(level, questLevel, minLevel)
    if level < (minLevel or 1) then
        return false
    end
    local span = 8
    if QS.Level and QS.Level.GreenRange then
        span = QS.Level.GreenRange(level)
    end
    return (level - questLevel) <= span
end

local function KnownSkills()
    if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then
        return nil
    end
    if (GetNumSkillLines() or 0) < 1 then
        return nil
    end
    local known = {}
    local skills = QS.Api.Skills()
    for i = 1, #skills do
        known[skills[i].name] = true
    end
    return known
end

local function KnowsSpell(name)
    if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function" or type(GetSpellBookItemName) ~= "function" then
        return nil
    end
    local tabs = GetNumSpellTabs() or 0
    if tabs < 1 then
        return nil
    end
    local book = BOOKTYPE_SPELL or "spell"
    for t = 1, tabs do
        local _, _, offset, numSpells = GetSpellTabInfo(t)
        offset = offset or 0
        numSpells = numSpells or 0
        for i = offset + 1, offset + numSpells do
            if GetSpellBookItemName(i, book) == name then
                return true
            end
        end
    end
    return false
end

local function HasDualSpec()
    if type(GetNumSpecGroups) ~= "function" then
        return nil
    end
    local ok, n = pcall(GetNumSpecGroups)
    if not ok or type(n) ~= "number" then
        return nil
    end
    return n >= 2
end

local function TitleLogged(log, title)
    if not log or not log.inLog or not title then
        return false
    end
    local want = string.lower(title)
    for _, info in pairs(log.inLog) do
        if info.title and string.lower(info.title) == want then
            return true
        end
    end
    return false
end

local function QuestFinished(log, questID)
    if not questID or not log then
        return false
    end
    if log.completed and log.completed[questID] then
        return true
    end
    if QS.Api and QS.Api.NoteIfFlagged then
        return QS.Api.NoteIfFlagged(log, questID) and true or false
    end
    return false
end

local function RememberTitles(char, log)
    if type(char.questSeen) ~= "table" then
        char.questSeen = {}
    end
    for _, info in pairs(log.inLog or {}) do
        if info.title then
            char.questSeen[string.lower(info.title)] = true
        end
    end
end

local function AddGoal(goals, name)
    if #goals >= 6 then
        return
    end
    goals[#goals + 1] = { name = name, have = 0, need = 1 }
end

local function HashGoals(goals)
    local n = 0
    for i = 1, #goals do
        local name = goals[i].name or ""
        for c = 1, #name do
            n = (n * 33 + string.byte(name, c)) % 100000
        end
    end
    return string.format("%05d", n)
end

local function OnPlateau(place)
    if not place then
        return false
    end
    local function hit(name)
        return name == "Mulgore" or name == "Thunder Bluff" or name == "Skywatcher Plateau"
    end
    return hit(place.zone) or hit(place.sub) or hit(place.real)
end

function Live.Opportunities(identity, char, log, place)
    local goals, titles, tails, plateauGoals = {}, {}, {}, {}
    if not char or not log then
        return goals, titles, tails, false, plateauGoals
    end
    RememberTitles(char, log)
    local level = UnitLevel("player") or 1
    local faction = identity and identity.faction or ""
    local classFile = identity and identity.classFile or ""
    for i = 1, #PLATEAU_OFFERS do
        local offer = PLATEAU_OFFERS[i]
        local open = true
        if offer.faction and offer.faction ~= faction then
            open = false
        end
        if open and QS.Level and QS.Level.FastQuest and not QS.Level.FastQuest(offer.questLevel, offer.elite, offer.minLevel) then
            open = false
        end
        if open and not InColor(level, offer.questLevel, offer.minLevel) then
            open = false
        end
        if open and offer.questID and QuestFinished(log, offer.questID) then
            open = false
        end
        if open and TitleLogged(log, offer.title) then
            open = false
        end
        if open and not offer.questID and char.questSeen[string.lower(offer.title)] then
            open = false
        end
        if open then
            titles[#titles + 1] = offer.title
            plateauGoals[#plateauGoals + 1] = { name = offer.goal, have = 0, need = 1 }
            AddGoal(goals, offer.goal)
            tails[#tails + 1] = {
                id = "dyn-accept-" .. SlugId(offer.title),
                kind = "accept",
                title = offer.title,
                questName = offer.title,
                questID = offer.questID,
                questLevel = offer.questLevel,
                text = offer.text,
                zone = "Mulgore",
                mapID = 1412,
                x = 0.334,
                y = 0.224,
                pin = "approx",
                npc = "Muln Earthfury",
                goalHeader = "Pick up",
                goals = { { name = offer.goal, have = 0, need = 1 } },
                minutes = 8,
                confidence = "reported",
                source = offer.source,
            }
        end
    end
    local function NeedFlight(label, text, pin)
        if QS.Resume and QS.Resume.FlightKnown and QS.Resume.FlightKnown(char, label) then
            return
        end
        AddGoal(goals, text)
        if not pin then
            return
        end
        tails[#tails + 1] = {
            id = "dyn-flight-" .. SlugId(label),
            kind = "flight",
            flight = label,
            title = "Flight path, " .. label,
            text = text,
            zone = pin.zone,
            mapID = pin.mapID,
            x = pin.x,
            y = pin.y,
            pin = "approx",
            npc = "the flight master",
            goalHeader = "Flight",
            goals = { { name = text, have = 0, need = 1 } },
            minutes = 3,
            confidence = "reported",
            source = "classicwowforever-2026-09-27",
        }
    end
    local cityName = place and CurrentCity(place) or nil
    if cityName then
        NeedFlight(cityName, "Get the " .. cityName .. " flight path", nil)
    end
    if char.classQuests ~= false and classFile == "WARRIOR" and InColor(level, 30, 30) then
        local title = "The Islander"
        if not TitleLogged(log, title) and not char.questSeen[string.lower(title)] then
            local who = "Kelv Sternhammer in Ironforge, Wu Shen in Stormwind, or Darnath Bladesinger in Darnassus"
            if faction == "Horde" then
                who = "Sorek in Orgrimmar, Torm Ragetotem in Thunder Bluff, or Baltus Fowler in Undercity"
            end
            local goal = "Accept The Islander (" .. who .. ")"
            AddGoal(goals, goal)
            titles[#titles + 1] = title
            tails[#tails + 1] = {
                id = "dyn-accept-the-islander",
                kind = "accept",
                title = title,
                questName = title,
                questLevel = 30,
                text = "The Islander starts at level 30 with a warrior trainer. " .. who .. ".",
                goalHeader = "Pick up",
                goals = { { name = goal, have = 0, need = 1 } },
                minutes = 10,
                confidence = "reported",
                source = "wowforever-codex-2026-10-05",
            }
        end
    end
    local known = KnownSkills()
    local allowed = CLASS_WEAPONS[classFile]
    local masters = cityName and WEAPON_MASTERS[cityName]
    if masters and known and allowed then
        local allow = {}
        for i = 1, #allowed do
            allow[allowed[i]] = true
        end
        for m = 1, #masters do
            local master = masters[m]
            local missing = {}
            local pole = false
            for s = 1, #master.skills do
                local skill = master.skills[s]
                if allow[skill] and not known[skill] then
                    missing[#missing + 1] = skill
                    if skill == "Polearms" then
                        pole = true
                    end
                end
            end
            if #missing > 0 then
                local line = "Weapon skills, " .. master.npc .. ", " .. master.where .. ": " .. JoinWords(missing, 4) .. ". 10 silver each"
                if pole then
                    line = line .. ". Polearms cost 1 gold"
                end
                AddGoal(goals, line)
            end
        end
    end
    if known and level >= 40 then
        if (classFile == "WARRIOR" or classFile == "PALADIN") and not known["Plate Mail"] then
            AddGoal(goals, "Train Plate Mail at your class trainer")
        elseif (classFile == "HUNTER" or classFile == "SHAMAN") and not known["Mail"] then
            AddGoal(goals, "Train Mail at your class trainer")
        end
    end
    if classFile == "WARRIOR" and level >= 20 then
        if KnowsSpell("Dual Wield") == false then
            AddGoal(goals, "Train Dual Wield at your class trainer")
        end
    end
    if level >= 40 and HasDualSpec() ~= true then
        AddGoal(goals, "Buy a second specialization from your class trainer (50 gold)")
    end
    return goals, titles, tails, OnPlateau(place) and #plateauGoals > 0, plateauGoals
end

function Live.Apply(built, identity, char, log)
    if not built or char.demo or not Data() then
        return
    end
    local bags = QS.Api.Bags()
    local steps = Annotate(built.steps, bags, char)
    built.steps = steps
    local index = QS.Resume.FirstOpen(steps, log, char.skips) or (#steps + 1)
    local place = QS.Api.Place()
    local block = {}

    local unspentNow = QS.Api.UnspentTalents() or 0
    if char.talentUnspent ~= unspentNow then
        char.skips["dyn-talent"] = nil
        char.talentUnspent = unspentNow
    end
    local talent = TalentStep(identity)
    if Show(char, "dyn-talent", talent ~= nil) and talent then
        block[#block + 1] = talent
    end

    -- Sell junk is an objective on the camp turn-in. This step is repair.
    local low = QS.Api.DurabilityRatio() < 0.25
    if Show(char, "dyn-vendor", low) then
        local vendor = VendorStep(bags, place, identity.faction, low)
        if vendor then
            block[#block + 1] = vendor
        end
    end

    local hearth = HearthSteps(steps, index, char, log, place)
    for i = 1, #hearth do
        block[#block + 1] = hearth[i]
    end

    if char.professionSteps then
        local cityName = CurrentCity(place)
        local skills = QS.Api.Skills()
        local trained = 0
        for i = 1, #skills do
            local skill = skills[i]
            local mastered = skill.max >= 300 and skill.rank >= skill.max
            local rankName = Live.NextTrain(skill)
            if TRAIN_NAMES[skill.name] and trained < 4 and not mastered and rankName then
                local step
                if cityName then
                    step = TrainerStep(cityName, skill.name, skill, false, rankName)
                else
                    step = TrainerStep(Capital(identity.faction), skill.name, skill, true, rankName)
                end
                if step and Show(char, step.id, true) then
                    block[#block + 1] = step
                    trained = trained + 1
                end
            end
        end
        local craft = CraftStep(bags, char)
        local sig = ""
        if craft then
            sig = craft.profession .. ":" .. (craft.product or craft.title)
        end
        if char.craftSig ~= sig then
            char.skips["dyn-craft"] = nil
            char.craftSig = sig
        end
        if Show(char, "dyn-craft", craft ~= nil) and craft then
            block[#block + 1] = craft
        end
    end

    local cityName = CurrentCity(place)
    if cityName then
        local bankRows, auctionRows = TownLists(bags)
        if #bankRows > 0 then
            local id = "dyn-bank-" .. Sig(bankRows)
            if Show(char, id, true) then
                block[#block + 1] = {
                    id = id,
                    kind = "bank",
                    title = "Bank in " .. cityName,
                    text = "Bank the overflow. Keep a stack of " .. KEEP_STACK .. " on you for the craft and gather goals. Quest items stay in your bags.",
                    zone = cityName,
                    mapID = Data().cities[cityName].mapID,
                    x = Data().cities[cityName].x,
                    y = Data().cities[cityName].y,
                    pin = "approx",
                    goalHeader = "Bank",
                    goals = StackGoals(bankRows, "Bank ", 8),
                    minutes = 3,
                    confidence = "reported",
                    source = "design-2026-10-05",
                }
            end
        end
        if #auctionRows > 0 then
            local id = "dyn-auction-" .. Sig(auctionRows)
            if Show(char, id, true) then
                block[#block + 1] = {
                    id = id,
                    kind = "auction",
                    title = "Auction in " .. cityName,
                    text = "Auction these. Leave anything soulbound out. Greys go to the vendor step, not the auction house.",
                    zone = cityName,
                    mapID = Data().cities[cityName].mapID,
                    x = Data().cities[cityName].x,
                    y = Data().cities[cityName].y,
                    pin = "approx",
                    goalHeader = "Auction",
                    goals = StackGoals(auctionRows, "Auction ", 8),
                    minutes = 4,
                    confidence = "reported",
                    source = "design-2026-10-05",
                }
            end
        end
    end

    for i = #block, 1, -1 do
        table.insert(steps, index, block[i])
    end

    local goals, titles, tails, plateauLead, plateauGoals = Live.Opportunities(identity, char, log, place)
    built.opportunityGoals = goals
    built.acceptTitles = titles
    built.plateauLead = plateauLead
    if #goals > 0 then
        local note = {
            id = "dyn-opportunity-" .. HashGoals(goals),
            liveNote = true,
            kind = "opportunity",
            title = "While you are here",
            text = "Flight paths, training, and quests that are easy to miss. Next leaves this list.",
            acceptTitles = titles,
            goalHeader = "Don't miss",
            goals = goals,
            minutes = 5,
            confidence = "reported",
            source = "design-2026-10-05",
        }
        if plateauGoals and #plateauGoals > 0 then
            note.title = "Skywatcher Plateau"
            note.text = "Muln Earthfury offers Defending the Dead and The Broodmother. The Broodmother is an elite at Gloomrise. Bring help. The pin is Muln."
            note.zone = "Mulgore"
            note.mapID = 1412
            note.x = 0.334
            note.y = 0.224
            note.pin = "approx"
            note.npc = "Muln Earthfury"
        end
        local spot = QS.Resume.FirstOpen(steps, log, char.skips) or (#steps + 1)
        table.insert(steps, spot, note)
    end
    for i = 1, #tails do
        steps[#steps + 1] = tails[i]
    end
    SurfaceBosses(steps, char, log)
end

-- One class trainer per class. Coordinates are Wowhead's TBC Classic city
-- guides (/way points), not inns. A missing row still names the capital.
local CLASS_TRAINERS = {
    Horde = {
        WARRIOR = { npc = "Sorek", zone = "Orgrimmar", where = "Hall of the Brave, Valley of Honor", mapID = 1454, x = 0.804, y = 0.324, source = "wowhead-tbc-orgrimmar-class-trainers" },
        HUNTER = { npc = "Ormak Grimshot", zone = "Orgrimmar", where = "Hunter's Hall, Valley of Honor", mapID = 1454, x = 0.660, y = 0.185, source = "wowhead-tbc-orgrimmar-class-trainers" },
        MAGE = { npc = "Deino", zone = "Orgrimmar", where = "Darkbriar Lodge, Valley of Spirits", mapID = 1454, x = 0.385, y = 0.860, source = "wowhead-tbc-orgrimmar-class-trainers" },
        PRIEST = { npc = "Ur'kyo", zone = "Orgrimmar", where = "Spirit Lodge, Valley of Spirits", mapID = 1454, x = 0.356, y = 0.877, source = "wowhead-tbc-orgrimmar-class-trainers" },
        ROGUE = { npc = "Ormok", zone = "Orgrimmar", where = "Cleft of Shadow", mapID = 1454, x = 0.440, y = 0.546, source = "wowhead-tbc-orgrimmar-class-trainers" },
        SHAMAN = { npc = "Kardris Dreamseeker", zone = "Orgrimmar", where = "Valley of Wisdom", mapID = 1454, x = 0.389, y = 0.364, source = "wowhead-tbc-orgrimmar-class-trainers" },
        WARLOCK = { npc = "Grol'dar", zone = "Orgrimmar", where = "Darkfire Enclave, Cleft of Shadow", mapID = 1454, x = 0.480, y = 0.460, source = "wowhead-tbc-orgrimmar-class-trainers" },
        DRUID = { npc = "Turak Runetotem", zone = "Thunder Bluff", where = "Elder Rise, Hall of Elders", mapID = 1456, x = 0.765, y = 0.272, source = "wowhead-tbc-thunder-bluff-class-trainers" },
    },
    Alliance = {
        DRUID = { npc = "Sheldras Moontree", zone = "Stormwind City", where = "the Park, south of the moonwell", mapID = 1453, x = 0.209, y = 0.555, source = "wowhead-tbc-stormwind-class-trainers" },
        PRIEST = { npc = "High Priestess Laurena", zone = "Stormwind City", where = "the Cathedral of Light, behind the altar", mapID = 1453, x = 0.386, y = 0.262, source = "wowhead-tbc-stormwind-class-trainers" },
        ROGUE = { npc = "Osborne the Night Man", zone = "Stormwind City", where = "SI:7, Old Town", mapID = 1453, x = 0.746, y = 0.528, source = "wowhead-tbc-stormwind-class-trainers" },
    },
}

function Live.SpellRankDue(level, xp, xpMax, trained)
    if type(level) ~= "number" or level < 1 or level >= 60 then
        return nil
    end
    trained = trained or 0
    if level % 2 == 0 and trained < level then
        return level
    end
    local nxt = level + 1
    if nxt <= 60 and nxt % 2 == 0 and trained < nxt then
        if type(xpMax) == "number" and xpMax > 0 and type(xp) == "number" and (xp / xpMax) >= 0.90 then
            return nxt
        end
    end
    return nil
end

local function ClassTrainStep(identity, trainAt)
    local faction = identity and identity.faction or "Horde"
    local classFile = identity and identity.classFile
    local book = CLASS_TRAINERS[faction]
    local row = book and classFile and book[classFile]
    local city = (faction == "Horde") and "Orgrimmar" or "Stormwind City"
    local title = "Train level " .. trainAt .. " spells"
    local npc = row and row.npc
    local zone = (row and row.zone) or city
    local text
    if row then
        text = "New spell ranks come at every even level. " .. row.npc
            .. " is in " .. row.where .. ", " .. row.zone
            .. ", about " .. string.format("%.1f, %.1f", row.x * 100, row.y * 100) .. "."
    else
        text = "New spell ranks come at every even level. Your class trainer is in " .. city .. "."
    end
    local step = {
        id = "dyn-classtrain-" .. trainAt,
        kind = "classtrain",
        trainAt = trainAt,
        title = title,
        npc = npc,
        text = text,
        zone = zone,
        goalHeader = "Train",
        goals = { { name = npc and (title .. " from " .. npc) or title, have = 0, need = 1 } },
        minutes = 8,
        confidence = row and "reported" or "log",
        source = (row and row.source) or "wowhead-classic-even-spell-ranks",
    }
    if row and row.mapID and row.x and row.y then
        step.mapID = row.mapID
        step.x = row.x
        step.y = row.y
        step.pin = "approx"
    end
    return step
end

function Live.SpliceSpellTrain(built, identity, char, log)
    if not built or not built.steps or not char or char.demo or built.key == "demo" then
        return
    end
    local level = UnitLevel and UnitLevel("player") or 1
    local xp = UnitXP and UnitXP("player") or 0
    local xpMax = UnitXPMax and UnitXPMax("player") or 1
    local trainAt = Live.SpellRankDue(level, xp, xpMax, char.trainedLevel)
    if not trainAt then
        return
    end
    local id = "dyn-classtrain-" .. trainAt
    if char.skips and char.skips[id] then
        return
    end
    local steps = built.steps
    for i = #steps, 1, -1 do
        if steps[i].id == id then
            table.remove(steps, i)
        end
    end
    local spot
    for i = 1, #steps do
        if steps[i].pocket then
            spot = i
            break
        end
    end
    if spot then
        while steps[spot + 1] and steps[spot + 1].handIn do
            spot = spot + 1
        end
    end
    if not spot then
        local skips = char.skips or {}
        for i = 1, #steps do
            local step = steps[i]
            if not step.levelDefer and not skips[step.id] and not (QS.Resume and QS.Resume.Done(step, log)) then
                spot = i
                break
            end
        end
    end
    if not spot then
        spot = #steps
    end
    table.insert(steps, spot + 1, ClassTrainStep(identity, trainAt))
end
