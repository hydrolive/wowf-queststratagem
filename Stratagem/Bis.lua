QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Bis = {}
QS.Bis = Bis

local function Add(list, row, reward)
    list[#list + 1] = {
        slot = row.slot,
        name = row.name,
        how = row.how,
        where = row.where,
        itemID = row.itemID,
        reward = reward and true or false,
        bis = not reward,
    }
end

function Bis.Annotate(route, identity)
    route.bisRows = {}
    local class = identity.class
    local spec = QS.Config.ActiveSpec()
    local tableFor = QS.Registry.bis[class]
    local bands = tableFor and tableFor[spec]
    local show = QS.char.bisCallouts
    for i = 1, #route.steps do
        local rows = {}
        local step = route.steps[i]
        if show then
            if step.rewardChoice and step.rewardChoice[spec] then
                Add(rows, step.rewardChoice[spec], true)
            end
            if step.bis and step.bis[spec] then
                Add(rows, step.bis[spec], false)
            end
            if step.demoBis then
                Add(rows, step.demoBis, false)
            end
            if bands then
                for _, band in pairs(bands) do
                    for n = 1, #band do
                        local item = band[n]
                        local hit = false
                        if step.questID and item.questID and item.questID == step.questID then
                            hit = true
                        end
                        if step.dungeon and step.dungeon.id and item.dungeon == step.dungeon.id then
                            hit = true
                        end
                        if hit then
                            Add(rows, item, item.how == "reward")
                        end
                    end
                end
            end
        end
        route.bisRows[i] = rows
    end
end

function Bis.PlayerHas(itemID)
    if not itemID or itemID == 0 then
        return false
    end
    if GetItemCount and GetItemCount(itemID) > 0 then
        return true
    end
    if GetInventoryItemID then
        for slot = 1, 19 do
            if GetInventoryItemID("player", slot) == itemID then
                return true
            end
        end
    end
    return false
end

function Bis.Line(row)
    local prefix = row.bis and "BiS " or ""
    local slot = row.slot and (row.slot .. ": ") or ""
    if row.reward or row.how == "reward" then
        return prefix .. slot .. row.name .. " — choose this reward"
    end
    if row.how == "drop" then
        return prefix .. slot .. row.name .. " — drop, " .. (row.where or "this dungeon")
    end
    if row.how == "crafted" then
        return prefix .. slot .. row.name .. " — crafted, not this quest"
    end
    return prefix .. slot .. row.name
end

local STATS = {
    "str", "agi", "sta", "int", "spi", "crit", "hit", "ap", "rap",
    "sp", "heal", "def", "dodge", "parry", "block", "mp5", "armor",
}

local STAT_TOKEN = {
    ITEM_MOD_STRENGTH_SHORT = "str",
    ITEM_MOD_AGILITY_SHORT = "agi",
    ITEM_MOD_STAMINA_SHORT = "sta",
    ITEM_MOD_INTELLECT_SHORT = "int",
    ITEM_MOD_SPIRIT_SHORT = "spi",
    ITEM_MOD_CRIT_RATING_SHORT = "crit",
    ITEM_MOD_CRIT_MELEE_RATING_SHORT = "crit",
    ITEM_MOD_CRIT_RANGED_RATING_SHORT = "crit",
    ITEM_MOD_CRIT_SPELL_RATING_SHORT = "crit",
    ITEM_MOD_HIT_RATING_SHORT = "hit",
    ITEM_MOD_HIT_MELEE_RATING_SHORT = "hit",
    ITEM_MOD_HIT_RANGED_RATING_SHORT = "hit",
    ITEM_MOD_HIT_SPELL_RATING_SHORT = "hit",
    ITEM_MOD_ATTACK_POWER_SHORT = "ap",
    ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "rap",
    ITEM_MOD_SPELL_POWER_SHORT = "sp",
    ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "sp",
    ITEM_MOD_SPELL_HEALING_DONE_SHORT = "heal",
    ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "def",
    ITEM_MOD_DODGE_RATING_SHORT = "dodge",
    ITEM_MOD_PARRY_RATING_SHORT = "parry",
    ITEM_MOD_BLOCK_RATING_SHORT = "block",
    ITEM_MOD_MANA_REGENERATION_SHORT = "mp5",
    ITEM_MOD_ARMOR_SHORT = "armor",
    RESISTANCE0_NAME = "armor",
    STRENGTH = "str",
    AGILITY = "agi",
    STAMINA = "sta",
    INTELLECT = "int",
    SPIRIT = "spi",
    ["CRITICAL STRIKE"] = "crit",
    ["CRITICAL STRIKE RATING"] = "crit",
    ["CRIT RATING"] = "crit",
    HIT = "hit",
    ["HIT RATING"] = "hit",
    ["ATTACK POWER"] = "ap",
    ["RANGED ATTACK POWER"] = "rap",
    ["SPELL POWER"] = "sp",
    ["SPELL DAMAGE"] = "sp",
    HEALING = "heal",
    ["SPELL HEALING"] = "heal",
    DEFENSE = "def",
    ["DEFENSE RATING"] = "def",
    DODGE = "dodge",
    ["DODGE RATING"] = "dodge",
    PARRY = "parry",
    ["PARRY RATING"] = "parry",
    BLOCK = "block",
    ["BLOCK RATING"] = "block",
    ["MANA PER 5 SEC."] = "mp5",
    ["MANA PER 5 SEC"] = "mp5",
    ARMOR = "armor",
}

local MELEE = { str = 1.0, agi = 0.7, crit = 0.9, hit = 1.0, ap = 0.45, sta = 0.25 }
local AGILE = { agi = 1.2, str = 0.45, crit = 0.9, hit = 1.0, ap = 0.4, rap = 0.45, sta = 0.2 }
local CASTER = { int = 1.0, sp = 1.1, crit = 0.7, hit = 0.9, spi = 0.25, sta = 0.2 }
local HEAL = { int = 1.0, heal = 1.2, sp = 0.4, spi = 0.55, mp5 = 0.8, sta = 0.35 }
local TANK = { sta = 1.1, def = 1.0, dodge = 0.8, parry = 0.7, block = 0.7, armor = 0.02, str = 0.35, agi = 0.3 }

local WEIGHT = {
    WARRIOR = { Arms = MELEE, Fury = MELEE, Protection = TANK },
    PALADIN = { Retribution = MELEE, Protection = TANK, Holy = HEAL },
    HUNTER = { BeastMastery = AGILE, Marksmanship = AGILE, Survival = AGILE },
    ROGUE = { Assassination = AGILE, Combat = AGILE, Subtlety = AGILE },
    PRIEST = { Shadow = CASTER, Discipline = HEAL, Holy = HEAL },
    SHAMAN = {
        Enhancement = { str = 1.0, agi = 0.9, int = 0.3, crit = 0.8, hit = 0.85, ap = 0.45, sta = 0.3, sp = 0.2 },
        Elemental = CASTER,
        Restoration = HEAL,
    },
    MAGE = { Arcane = CASTER, Fire = CASTER, Frost = CASTER },
    WARLOCK = { Affliction = CASTER, Demonology = CASTER, Destruction = CASTER },
    DRUID = {
        Feral = { agi = 1.15, str = 0.8, crit = 0.9, hit = 0.8, ap = 0.4, sta = 0.35, int = 0.2 },
        Balance = CASTER,
        Restoration = HEAL,
    },
}

local WEAPON_BIAS = {
    WARRIOR = { Arms = 1.0, Fury = 1.0, Protection = 0.55 },
    PALADIN = { Retribution = 1.0, Protection = 0.55, Holy = 0.3 },
    HUNTER = { BeastMastery = 0.9, Marksmanship = 0.9, Survival = 0.9 },
    ROGUE = { Assassination = 0.9, Combat = 0.9, Subtlety = 0.9 },
    PRIEST = { Shadow = 0.35, Discipline = 0.3, Holy = 0.3 },
    SHAMAN = { Enhancement = 0.85, Elemental = 0.35, Restoration = 0.3 },
    MAGE = { Arcane = 0.35, Fire = 0.35, Frost = 0.35 },
    WARLOCK = { Affliction = 0.35, Demonology = 0.35, Destruction = 0.35 },
    DRUID = { Feral = 0.9, Balance = 0.35, Restoration = 0.3 },
}

local ARMOR_OK = {
    WARRIOR = { Cloth = false, Leather = true, Mail = true, Plate = true },
    PALADIN = { Cloth = false, Leather = true, Mail = true, Plate = true },
    HUNTER = { Cloth = false, Leather = true, Mail = true, Plate = false },
    SHAMAN = { Cloth = false, Leather = true, Mail = true, Plate = false },
    ROGUE = { Cloth = false, Leather = true, Mail = false, Plate = false },
    DRUID = { Cloth = false, Leather = true, Mail = false, Plate = false },
    MAGE = { Cloth = true, Leather = false, Mail = false, Plate = false },
    PRIEST = { Cloth = true, Leather = false, Mail = false, Plate = false },
    WARLOCK = { Cloth = true, Leather = false, Mail = false, Plate = false },
}

local EQUIP_SLOTS = {
    INVTYPE_HEAD = { 1 },
    INVTYPE_NECK = { 2 },
    INVTYPE_SHOULDER = { 3 },
    INVTYPE_CHEST = { 5 },
    INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 },
    INVTYPE_LEGS = { 7 },
    INVTYPE_FEET = { 8 },
    INVTYPE_WRIST = { 9 },
    INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 },
    INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16 },
    INVTYPE_2HWEAPON = { 16, 17 },
    INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_WEAPONOFFHAND = { 17 },
    INVTYPE_SHIELD = { 17 },
    INVTYPE_HOLDABLE = { 17 },
    INVTYPE_RANGED = { 18 },
    INVTYPE_RANGEDRIGHT = { 18 },
    INVTYPE_THROWN = { 18 },
}

local SLOT_NAME = {
    INVTYPE_HEAD = "head",
    INVTYPE_NECK = "neck",
    INVTYPE_SHOULDER = "shoulder",
    INVTYPE_CHEST = "chest",
    INVTYPE_ROBE = "chest",
    INVTYPE_WAIST = "waist",
    INVTYPE_LEGS = "legs",
    INVTYPE_FEET = "feet",
    INVTYPE_WRIST = "wrist",
    INVTYPE_HAND = "hands",
    INVTYPE_FINGER = "finger",
    INVTYPE_TRINKET = "trinket",
    INVTYPE_CLOAK = "back",
    INVTYPE_WEAPON = "weapon",
    INVTYPE_2HWEAPON = "weapon",
    INVTYPE_WEAPONMAINHAND = "weapon",
    INVTYPE_WEAPONOFFHAND = "offhand",
    INVTYPE_SHIELD = "offhand",
    INVTYPE_HOLDABLE = "offhand",
    INVTYPE_RANGED = "ranged",
    INVTYPE_RANGEDRIGHT = "ranged",
    INVTYPE_THROWN = "ranged",
}

local WEAPON_LOC = {
    INVTYPE_WEAPON = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_THROWN = true,
}

function Bis.Weights(classFile, spec)
    local byClass = WEIGHT[classFile or ""]
    if byClass and spec and byClass[spec] then
        return byClass[spec]
    end
    return MELEE
end

function Bis.WeaponBias(classFile, spec)
    local byClass = WEAPON_BIAS[classFile or ""]
    if byClass and spec and byClass[spec] then
        return byClass[spec]
    end
    return 0.4
end

function Bis.NormalizeStats(raw)
    local stats = {}
    if type(raw) ~= "table" then
        return stats
    end
    for key, amount in pairs(raw) do
        local short = STAT_TOKEN[key]
        if not short and type(key) == "string" then
            short = STAT_TOKEN[string.upper(key)]
        end
        if short and type(amount) == "number" then
            stats[short] = (stats[short] or 0) + amount
        end
    end
    return stats
end

function Bis.Value(stats, iLevel, weights, weaponBias)
    local total = 0
    stats = stats or {}
    weights = weights or {}
    for i = 1, #STATS do
        local key = STATS[i]
        total = total + (stats[key] or 0) * (weights[key] or 0)
    end
    local ilvl = iLevel or 0
    if weaponBias and weaponBias > 0 then
        total = total + ilvl * weaponBias
    else
        total = total + ilvl * 0.15
    end
    return total
end

local function ItemValue(item, classFile, spec, weights)
    if not item then
        return 0
    end
    local bias = nil
    if item.equipLoc and WEAPON_LOC[item.equipLoc] then
        bias = Bis.WeaponBias(classFile, spec)
    end
    return Bis.Value(item.stats, item.iLevel, weights, bias)
end

local function SameName(a, b)
    if not a or not b or a == "" or b == "" then
        return false
    end
    return string.lower(a) == string.lower(b)
end

local function ArmorOk(classFile, armor)
    if not armor or armor == "" then
        return true
    end
    local row = ARMOR_OK[classFile or ""]
    if not row or row[armor] == nil then
        return true
    end
    return row[armor] and true or false
end

function Bis.List(className, spec)
    local out = {}
    local byClass = QS.Registry and QS.Registry.bis and QS.Registry.bis[className]
    local bands = byClass and spec and byClass[spec]
    if not bands then
        return out
    end
    for _, band in pairs(bands) do
        for i = 1, #band do
            local item = band[i]
            out[#out + 1] = {
                name = item.name,
                slot = item.slot,
                itemID = item.itemID,
            }
        end
    end
    return out
end

local function BisHit(choice, list)
    if not list then
        return nil
    end
    for i = 1, #list do
        local row = list[i]
        if choice.itemID and row.itemID and choice.itemID == row.itemID and row.itemID ~= 0 then
            return row
        end
        if SameName(choice.name, row.name) then
            return row
        end
    end
    return nil
end

local function BisForSlot(list, slotName)
    if not list or not slotName then
        return nil
    end
    for i = 1, #list do
        if list[i].slot == slotName then
            return list[i]
        end
    end
    return nil
end

function Bis.Inspect(linkOrID)
    if not linkOrID or linkOrID == "" or linkOrID == 0 or type(GetItemInfo) ~= "function" then
        return {}, nil, 0, nil, nil, nil
    end
    local name, _, _, iLevel, _, itemType, subType, _, equipLoc, texture = GetItemInfo(linkOrID)
    local raw = nil
    local getter = GetItemStats
    if type(getter) ~= "function" and type(C_Item) == "table" and type(C_Item.GetItemStats) == "function" then
        getter = C_Item.GetItemStats
    end
    if type(getter) == "function" then
        local ok, stats = pcall(getter, linkOrID)
        if ok then
            raw = stats
        end
    end
    local armor = nil
    if itemType == "Armor" then
        armor = subType
    end
    return Bis.NormalizeStats(raw), equipLoc, iLevel or 0, armor, texture, name
end

local function ChoiceFromLink(index, name, texture, usable, link, itemID)
    if not itemID and type(link) == "string" then
        local id = string.match(link, "item:(%d+)")
        itemID = id and tonumber(id) or nil
    end
    local stats, equipLoc, iLevel, armor, icon, inspected = Bis.Inspect(link or itemID)
    if (not name or name == "") and type(inspected) == "string" and inspected ~= "" then
        name = inspected
    end
    return {
        index = index,
        name = name,
        texture = texture or icon,
        link = link,
        itemID = itemID,
        stats = stats,
        equipLoc = equipLoc,
        iLevel = iLevel,
        armor = armor,
        usable = usable,
    }
end

function Bis.DialogChoices()
    if type(GetNumQuestChoices) ~= "function" then
        return {}
    end
    local n = GetNumQuestChoices() or 0
    local list = {}
    for i = 1, n do
        local name, texture, usable
        if type(GetQuestItemInfo) == "function" then
            local ok, a, b, _, _, e = pcall(GetQuestItemInfo, "choice", i)
            if ok then
                name = a
                texture = b
                usable = e
            end
        end
        local link
        if type(GetQuestItemLink) == "function" then
            local ok, value = pcall(GetQuestItemLink, "choice", i)
            if ok and type(value) == "string" then
                link = value
            end
        end
        list[#list + 1] = ChoiceFromLink(i, name, texture, usable, link, nil)
    end
    return list
end

function Bis.ReadLogChoices(logIndex)
    if not logIndex or type(SelectQuestLogEntry) ~= "function" or type(GetNumQuestLogChoices) ~= "function" then
        return nil
    end
    QS.scanningLog = true
    local prev = 0
    if type(GetQuestLogSelection) == "function" then
        prev = GetQuestLogSelection() or 0
    end
    local list = {}
    local ok = pcall(function()
        SelectQuestLogEntry(logIndex)
        local n = GetNumQuestLogChoices() or 0
        for i = 1, n do
            local name, texture, usable
            if type(GetQuestLogChoiceInfo) == "function" then
                local infoOk, a, b, _, _, e = pcall(GetQuestLogChoiceInfo, i)
                if infoOk then
                    name = a
                    texture = b
                    usable = e
                end
            end
            local link
            if type(GetQuestLogItemLink) == "function" then
                local linkOk, value = pcall(GetQuestLogItemLink, "choice", i)
                if linkOk and type(value) == "string" then
                    link = value
                end
            end
            list[#list + 1] = ChoiceFromLink(i, name, texture, usable, link, nil)
        end
        if prev > 0 then
            SelectQuestLogEntry(prev)
        end
    end)
    QS.scanningLog = false
    if not ok then
        return nil
    end
    return list
end

function Bis.Equipped()
    local out = {}
    if type(GetInventoryItemLink) ~= "function" then
        return out
    end
    for slot = 1, 18 do
        local ok, link = pcall(GetInventoryItemLink, "player", slot)
        if ok and type(link) == "string" and link ~= "" then
            local stats, equipLoc, iLevel, armor, texture, name = Bis.Inspect(link)
            out[slot] = {
                name = name,
                link = link,
                stats = stats,
                equipLoc = equipLoc,
                iLevel = iLevel,
                armor = armor,
                texture = texture,
            }
        end
    end
    return out
end

local function Replaced(choice, equipped, classFile, spec, weights)
    local slots = choice.equipLoc and EQUIP_SLOTS[choice.equipLoc]
    if not slots or #slots == 0 then
        return nil, nil
    end
    if choice.equipLoc == "INVTYPE_2HWEAPON" then
        local total, name = 0, nil
        local main = equipped[16]
        local off = equipped[17]
        total = ItemValue(main, classFile, spec, weights) + ItemValue(off, classFile, spec, weights)
        if main and main.name then
            name = main.name
        elseif off and off.name then
            name = off.name
        end
        return total, name
    end
    if #slots == 2 then
        local low, lowName = nil, nil
        for i = 1, #slots do
            local item = equipped[slots[i]]
            local value = ItemValue(item, classFile, spec, weights)
            if not low or value < low then
                low = value
                lowName = item and item.name or nil
            end
        end
        return low or 0, lowName
    end
    local item = equipped[slots[1]]
    return ItemValue(item, classFile, spec, weights), item and item.name or nil
end

function Bis.Choose(choices, equipped, ctx)
    if not choices or #choices == 0 then
        return nil
    end
    ctx = ctx or {}
    equipped = equipped or {}
    local classFile = ctx.classFile
    local spec = ctx.spec
    local weights = ctx.weights or Bis.Weights(classFile, spec)
    local best, second
    for i = 1, #choices do
        local choice = choices[i]
        local named = (ctx.prefer and SameName(choice.name, ctx.prefer)) or BisHit(choice, ctx.bis)
        if choice.usable == false and not named then
            choice = nil
        end
        if choice and not ArmorOk(classFile, choice.armor) and not named then
            choice = nil
        end
        if choice then
            local replaced, versus = Replaced(choice, equipped, classFile, spec, weights)
            local rewardValue = 0
            local gain = 0
            if replaced ~= nil then
                rewardValue = ItemValue(choice, classFile, spec, weights)
                gain = rewardValue - replaced
            end
            local hasStats = (choice.stats and next(choice.stats)) and true or false
            local known = replaced ~= nil and ((choice.iLevel or 0) > 0 or rewardValue ~= 0 or hasStats)
            local hit = BisHit(choice, ctx.bis)
            local prefer = ctx.prefer and SameName(choice.name, ctx.prefer)
            local tier = 0
            if known or hit or prefer then
                tier = 1
            end
            if hit then
                tier = 2
            end
            if prefer then
                tier = 3
            end
            if tier > 0 then
                local row = {
                    choice = choice,
                    tier = tier,
                    gain = gain,
                    versus = versus,
                    hit = hit,
                    hasStats = hasStats,
                    known = known or prefer or hit,
                }
                local better = false
                if not best then
                    better = true
                elseif row.tier > best.tier then
                    better = true
                elseif row.tier == best.tier and row.gain > best.gain then
                    better = true
                end
                if better then
                    second = best
                    best = row
                elseif not second or row.tier > second.tier or (row.tier == second.tier and row.gain > second.gain) then
                    second = row
                end
            end
        end
    end
    if not best then
        return nil
    end
    local choice = best.choice
    local slotName = choice.equipLoc and SLOT_NAME[choice.equipLoc]
    local slotBis = (not best.hit) and BisForSlot(ctx.bis, slotName) or nil
    local specName = spec or "this spec"
    local text
    if best.tier == 3 then
        text = "Choose " .. (choice.name or "this reward") .. " — listed for " .. specName
    elseif best.hit then
        text = "Choose " .. (choice.name or "this reward") .. " — BiS for " .. specName
    elseif best.gain > 0 and slotBis and best.versus then
        text = "Choose " .. (choice.name or "this reward") .. " — closer to " .. slotBis.name .. " than " .. best.versus
    elseif best.gain > 0 and best.versus then
        text = "Choose " .. (choice.name or "this reward") .. " — upgrade over " .. best.versus
    elseif best.gain > 0 then
        text = "Choose " .. (choice.name or "this reward") .. " — upgrade for " .. specName
    elseif best.versus then
        text = "Closest: " .. (choice.name or "this reward") .. " — behind " .. best.versus
    else
        text = "Choose " .. (choice.name or "this reward")
    end
    local take = best.tier >= 2
    if not take and best.gain > 0 and best.hasStats then
        local close = second and second.tier == best.tier and (best.gain - second.gain) < 0.5
        take = not close
    end
    return {
        index = choice.index,
        name = choice.name,
        link = choice.link,
        itemID = choice.itemID,
        texture = choice.texture,
        text = text,
        gain = best.gain,
        take = take and true or false,
    }
end

function Bis.Attach(step, log)
    if not step or not log or not log.inLog then
        return
    end
    local ids, seen = {}, {}
    local function add(id)
        if id and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end
    add(step.questID)
    if step.questIDs then
        for i = 1, #step.questIDs do
            add(step.questIDs[i])
        end
    end
    if #ids == 0 then
        return
    end
    local identity = QS.identity or (QS.Config and QS.Config.Identity and QS.Config.Identity())
    if not identity then
        return
    end
    local spec = QS.Config and QS.Config.ActiveSpec and QS.Config.ActiveSpec() or nil
    local equipped = Bis.Equipped()
    local list = Bis.List(identity.class, spec)
    local prefer = nil
    if spec and step.rewardChoice and step.rewardChoice[spec] then
        prefer = step.rewardChoice[spec].name
    end
    local rows = {}
    for i = 1, #ids do
        local info = log.inLog[ids[i]]
        if info and info.complete and info.index and #rows < 4 then
            local choices = Bis.ReadLogChoices(info.index)
            local pick = choices and Bis.Choose(choices, equipped, {
                classFile = identity.classFile,
                spec = spec,
                bis = list,
                prefer = prefer,
            })
            if pick then
                rows[#rows + 1] = pick
            end
        end
    end
    if #rows > 0 then
        step.rewardRows = rows
    end
end
