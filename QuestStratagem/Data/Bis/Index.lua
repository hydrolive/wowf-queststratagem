-- Pre-raid and a few leveling pieces for all 27 specs.
-- itemID is set only for pieces whose Classic ids are well known.
-- Omitted ids are names only. Zero is never stored.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local function put(class, spec, band, row)
    local byClass = QS.Registry.bis[class] or {}
    QS.Registry.bis[class] = byClass
    local bySpec = byClass[spec] or {}
    byClass[spec] = bySpec
    local list = bySpec[band] or {}
    bySpec[band] = list
    row.source = "wowhead-classic"
    row.confidence = "verified"
    list[#list + 1] = row
end

local function give(class, specs, band, row)
    for i = 1, #specs do
        local copy = {}
        for k, v in pairs(row) do
            copy[k] = v
        end
        put(class, specs[i], band, copy)
    end
end

local ALL = {
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

give("Warrior", ALL.WARRIOR, "40-59", {
    slot = "weapon", name = "Ironfoe", itemID = 11684, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Warrior", ALL.WARRIOR, "60", {
    slot = "trinket", name = "Hand of Justice", itemID = 11815, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Warrior", { "Arms", "Fury" }, "20-39", {
    slot = "weapon", name = "Shadowfang", itemID = 1482, how = "drop",
    where = "Shadowfang Keep", dungeon = "sfk",
})

give("Paladin", { "Retribution" }, "40-59", {
    slot = "weapon", name = "Ironfoe", itemID = 11684, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Paladin", { "Retribution", "Protection" }, "60", {
    slot = "trinket", name = "Hand of Justice", itemID = 11815, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Paladin", { "Holy" }, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})

give("Hunter", ALL.HUNTER, "60", {
    slot = "weapon", name = "Rhok'delar", itemID = 18713, how = "quest",
    where = "hunter epic quest",
})
give("Hunter", ALL.HUNTER, "60", {
    slot = "trinket", name = "Blackhand's Breadth", itemID = 13965, how = "drop",
    where = "General Drakkisath, UBRS", dungeon = "lbrs",
})

give("Rogue", ALL.ROGUE, "20-39", {
    slot = "weapon", name = "Assassin's Blade", itemID = 1935, how = "drop",
    where = "Shadowfang Keep", dungeon = "sfk",
})
give("Rogue", ALL.ROGUE, "40-59", {
    slot = "shoulder", name = "Truestrike Shoulders", itemID = 12927, how = "drop",
    where = "Warchief Rend Blackhand, UBRS", dungeon = "lbrs",
})
give("Rogue", ALL.ROGUE, "60", {
    slot = "trinket", name = "Blackhand's Breadth", itemID = 13965, how = "drop",
    where = "General Drakkisath, UBRS", dungeon = "lbrs",
})

give("Priest", { "Discipline", "Holy" }, "60", {
    slot = "weapon", name = "Benediction", itemID = 18608, how = "quest",
    where = "priest epic quest",
})
give("Priest", { "Shadow" }, "60", {
    slot = "weapon", name = "Anathema", itemID = 18609, how = "quest",
    where = "priest epic quest",
})
give("Priest", ALL.PRIEST, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})

give("Shaman", { "Enhancement" }, "40-59", {
    slot = "weapon", name = "Ironfoe", itemID = 11684, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Shaman", { "Enhancement" }, "60", {
    slot = "trinket", name = "Hand of Justice", itemID = 11815, how = "drop",
    where = "Emperor Thaurissan, BRD", dungeon = "brd",
})
give("Shaman", { "Elemental", "Restoration" }, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})

give("Mage", ALL.MAGE, "60", {
    slot = "chest", name = "Robe of the Archmage", itemID = 14152, how = "crafted",
    where = "tailoring",
})
give("Mage", ALL.MAGE, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})

give("Warlock", ALL.WARLOCK, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})

give("Druid", { "Feral" }, "40-59", {
    slot = "shoulder", name = "Truestrike Shoulders", itemID = 12927, how = "drop",
    where = "Warchief Rend Blackhand, UBRS", dungeon = "lbrs",
})
give("Druid", { "Feral" }, "60", {
    slot = "trinket", name = "Blackhand's Breadth", itemID = 13965, how = "drop",
    where = "General Drakkisath, UBRS", dungeon = "lbrs",
})
give("Druid", { "Balance", "Restoration" }, "60", {
    slot = "offhand", name = "Briarwood Reed", itemID = 12930, how = "drop",
    where = "Jed Runewatcher, UBRS", dungeon = "lbrs",
})
