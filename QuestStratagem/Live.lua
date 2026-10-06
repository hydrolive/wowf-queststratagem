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

local function Bracket(maxRank)
    if not maxRank or maxRank <= 75 then
        return 75
    end
    if maxRank <= 150 then
        return 150
    end
    if maxRank <= 225 then
        return 225
    end
    return 300
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

local function TrainerStep(cityName, city, prof, skill, away)
    local bracket = Bracket(skill.max)
    local known = Data().spells[prof] and Data().spells[prof][bracket]
    local row = Data().trainers[cityName] and Data().trainers[cityName][prof]
    local npc = (row and row.npc) or ("the " .. prof .. " trainer")
    local where = row and row.where
    local goals = {}
    if known then
        for i = 1, #known do
            goals[#goals + 1] = { name = known[i] }
        end
    else
        goals[1] = { name = "Learn the next " .. prof .. " rank" }
    end
    local text = "Train " .. prof .. " (" .. skill.rank .. "/" .. skill.max .. ") with " .. npc
    if where then
        text = text .. " in " .. where
    end
    text = text .. ". The goals are the spells for this rank."
    if not row then
        text = text .. " Ask a guard for the trainer. The arrow points at the city."
    end
    if away then
        text = "Your " .. prof .. " rank is full (" .. skill.rank .. "/" .. skill.max .. "). Go to " .. npc .. " in " .. cityName .. "."
    end
    return {
        id = "dyn-train-" .. cityName .. "-" .. prof .. "-" .. bracket,
        kind = "proftrain",
        profession = prof,
        rankAt = skill.rank,
        maxAt = skill.max,
        title = "Train " .. prof,
        npc = npc,
        text = text,
        zone = cityName,
        mapID = (row and row.mapID) or city.mapID,
        x = (row and row.x) or city.x,
        y = (row and row.y) or city.y,
        pin = "approx",
        goalHeader = "Train",
        goals = goals,
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

    local low = QS.Api.DurabilityRatio() < 0.25
    local full = bags.free <= SELL_AT
    if Show(char, "dyn-vendor", full or low) then
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
        local cityName, city = CurrentCity(place)
        local skills = QS.Api.Skills()
        local trained = 0
        for i = 1, #skills do
            local skill = skills[i]
            local mastered = skill.max >= 300 and skill.rank >= skill.max
            if TRAIN_NAMES[skill.name] and trained < 4 and not mastered then
                local capped = skill.max < 300 and skill.rank + 5 >= skill.max
                if city and cityName then
                    local step = TrainerStep(cityName, city, skill.name, skill, false)
                    if Show(char, step.id, true) then
                        block[#block + 1] = step
                        trained = trained + 1
                    end
                elseif capped then
                    local capital = Capital(identity.faction)
                    local capCity = Data().cities[capital]
                    if capCity then
                        local step = TrainerStep(capital, capCity, skill.name, skill, true)
                        if Show(char, step.id, true) then
                            block[#block + 1] = step
                            trained = trained + 1
                        end
                    end
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
    SurfaceBosses(steps, char, log)
end
