QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Config = {}
QS.Config = Config

Config.SPEC_KEYS = {
    WARRIOR = { "Arms", "Fury", "Protection" },
    PALADIN = { "Holy", "Protection", "Retribution" },
    HUNTER = { "BeastMastery", "Marksmanship", "Survival" },
    ROGUE = { "Assassination", "Combat", "Subtlety" },
    PRIEST = { "Discipline", "Holy", "Shadow" },
    SHAMAN = { "Elemental", "Enhancement", "Restoration" },
    MAGE = { "Arcane", "Fire", "Frost" },
    WARLOCK = { "Affliction", "Demonology", "Destruction" },
    DRUID = { "Balance", "Feral", "Restoration" },
}

Config.SPEC_LABEL = {
    BeastMastery = "Beast Mastery",
}

Config.DEFAULT_SPEC = {
    WARRIOR = "Arms",
    PALADIN = "Retribution",
    HUNTER = "BeastMastery",
    ROGUE = "Combat",
    PRIEST = "Shadow",
    SHAMAN = "Enhancement",
    MAGE = "Frost",
    WARLOCK = "Affliction",
    DRUID = "Feral",
}

Config.CLASS_MOD = {
    HUNTER = 0.90,
    WARLOCK = 0.95,
    MAGE = 0.95,
    DRUID = 1.00,
    ROGUE = 1.00,
    PALADIN = 1.05,
    SHAMAN = 1.05,
    PRIEST = 1.10,
    WARRIOR = 1.15,
}

Config.PACE_MOD = {
    guide = 1.0,
    steady = 1.5,
    first = 2.5,
}

Config.PACE_LABEL = {
    guide = "Guide",
    steady = "Steady",
    first = "First run",
}

local CLASS_NAME = {
    WARRIOR = "Warrior",
    PALADIN = "Paladin",
    HUNTER = "Hunter",
    ROGUE = "Rogue",
    PRIEST = "Priest",
    SHAMAN = "Shaman",
    MAGE = "Mage",
    WARLOCK = "Warlock",
    DRUID = "Druid",
}

local RACE_NAME = {
    Human = "Human",
    Dwarf = "Dwarf",
    Gnome = "Gnome",
    NightElf = "NightElf",
    Orc = "Orc",
    Scourge = "Undead",
    Undead = "Undead",
    Tauren = "Tauren",
    Troll = "Troll",
    HighOrder = "HighOrder",
    Windshaper = "Windshaper",
}

function Config.SpecLabel(key)
    if not key then
        return "Unknown"
    end
    return Config.SPEC_LABEL[key] or key
end

function Config.NormalizeRace(raceFile, locRace, faction)
    local loc = locRace or ""
    if raceFile == "HighOrder" or loc == "High Order" then
        return "HighOrder"
    end
    if raceFile == "Windshaper" or loc == "Windshaper" then
        return "Windshaper"
    end
    if loc == "Skyborne" or raceFile == "Skyborne" then
        if faction == "Horde" then
            return "Windshaper"
        end
        return "HighOrder"
    end
    return RACE_NAME[raceFile] or RACE_NAME[loc] or loc or "Human"
end

function Config.Identity()
    local locRace, raceFile = UnitRace("player")
    local locClass, classFile = UnitClass("player")
    local faction = UnitFactionGroup("player") or "Alliance"
    local race = Config.NormalizeRace(raceFile, locRace, faction)
    local class = CLASS_NAME[classFile] or locClass or "Warrior"
    local char = QS.char
    if QS.db and QS.db.debug and char then
        if char.factionOverride then
            faction = char.factionOverride
        end
        if char.raceOverride then
            race = char.raceOverride
        end
        if char.classOverride then
            class = char.classOverride
        end
    end
    return {
        faction = faction,
        race = race,
        class = class,
        classFile = classFile or "WARRIOR",
        raceFile = raceFile,
        locRace = locRace,
        locClass = locClass,
    }
end

function Config.SpecOptions(classFile)
    return Config.SPEC_KEYS[classFile] or Config.SPEC_KEYS.WARRIOR
end

function Config.ActiveSpec()
    local id = QS.identity or Config.Identity()
    local char = QS.char
    if char and char.spec and char.spec ~= "" then
        return char.spec, char.specConfirmed and true or false
    end
    return Config.DEFAULT_SPEC[id.classFile] or "Arms", false
end

function Config.GuessSpec(forcePrint)
    local char = QS.char
    if not char or char.specConfirmed then
        return
    end
    if not GetTalentTabInfo then
        return
    end
    local bestKey, bestPoints, bestIndex = nil, 0, nil
    local id = QS.identity or Config.Identity()
    local keys = Config.SpecOptions(id.classFile)
    for i = 1, 3 do
        local _, _, points = GetTalentTabInfo(i)
        points = points or 0
        if points > bestPoints then
            bestPoints = points
            bestIndex = i
            bestKey = keys[i]
        end
    end
    if bestKey and bestPoints >= 10 then
        if char.spec ~= bestKey then
            char.spec = bestKey
            if forcePrint then
                QS:Print("Spec guess: " .. Config.SpecLabel(bestKey) .. ". Confirm it in /qs config.")
            end
        end
    elseif not char.spec then
        char.spec = Config.DEFAULT_SPEC[id.classFile]
    end
end

function Config.ConfirmSpec(key)
    QS.char.spec = key
    QS.char.specConfirmed = true
    QS:Rebuild()
end

function Config.SetPace(pace)
    QS.char.pace = pace
    if QS.UI then
        QS.UI:Refresh(false)
    end
end

function Config.ClassMod()
    local id = QS.identity or Config.Identity()
    return Config.CLASS_MOD[id.classFile] or 1
end

function Config.PaceMod()
    local pace = (QS.char and QS.char.pace) or "guide"
    return Config.PACE_MOD[pace] or 1
end
