-- Race/class coverage. Every Forever combo has a key.
-- A stub race falls back to the nearest authored spine.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

QS.Registry = {
    races = {},
    coverage = {},
    overlays = {},
    dungeons = {},
    bis = {},
    demo = nil,
}

local function Cover(faction, race, classes)
    QS.Registry.coverage[faction] = QS.Registry.coverage[faction] or {}
    QS.Registry.coverage[faction][race] = {}
    for i = 1, #classes do
        QS.Registry.coverage[faction][race][classes[i]] = true
    end
end

Cover("Alliance", "Human", { "Warrior", "Paladin", "Rogue", "Priest", "Mage", "Warlock", "Hunter" })
Cover("Alliance", "Dwarf", { "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman" })
Cover("Alliance", "Gnome", { "Warrior", "Rogue", "Mage", "Warlock", "Priest" })
Cover("Alliance", "NightElf", { "Warrior", "Hunter", "Rogue", "Priest", "Druid" })
Cover("Alliance", "HighOrder", { "Warrior", "Hunter", "Rogue", "Druid", "Mage" })
Cover("Horde", "Orc", { "Warrior", "Hunter", "Rogue", "Shaman", "Warlock", "Mage" })
Cover("Horde", "Undead", { "Warrior", "Rogue", "Priest", "Mage", "Warlock", "Paladin" })
Cover("Horde", "Tauren", { "Warrior", "Hunter", "Shaman", "Druid" })
Cover("Horde", "Troll", { "Warrior", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock" })
Cover("Horde", "Windshaper", { "Warrior", "Hunter", "Rogue", "Druid", "Shaman" })

-- Entrance pins are reported Classic coordinates. Quest lists stay empty
-- until cited. Boss kill steps still insert when the level band matches.
local function Dungeon(row)
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "reported"
    QS.Registry.dungeons[#QS.Registry.dungeons + 1] = row
end

Dungeon({ id = "rfc", name = "Ragefire Chasm", min = 13, max = 18, faction = "Horde", zone = "Orgrimmar", mapID = 1454, x = 0.52, y = 0.49, quests = {} })
Dungeon({ id = "deadmines", name = "The Deadmines", min = 16, max = 22, faction = "Alliance", zone = "Westfall", mapID = 1436, x = 0.426, y = 0.717, entranceX = 0.426, entranceY = 0.717, quests = {} })
Dungeon({ id = "wailingcaverns", name = "Wailing Caverns", min = 17, max = 24, faction = "Horde", zone = "The Barrens", mapID = 1413, x = 0.460, y = 0.366, quests = {} })
-- Group Finder ranges from this client. A dungeon stays off the path
-- until the player's level is inside that range.
-- At 28 the finder lists Shadowfang Keep 20-30, Blackfathom Deeps 24-32,
-- and Excavation Site 26-33. Gnomeregan and Razorfen Kraul open at 29.
Dungeon({ id = "sfk", name = "Shadowfang Keep", min = 20, max = 30, zone = "Silverpine Forest", mapID = 1421, x = 0.445, y = 0.678, quests = {} })
Dungeon({ id = "bfd", name = "Blackfathom Deeps", min = 24, max = 32, zone = "Ashenvale", mapID = 1440, x = 0.141, y = 0.144, quests = {} })
Dungeon({ id = "stockades", name = "The Stockade", min = 24, max = 32, faction = "Alliance", zone = "Stormwind City", mapID = 1453, x = 0.40, y = 0.55, quests = {} })
Dungeon({ id = "gnomeregan", name = "Gnomeregan", min = 29, max = 38, zone = "Dun Morogh", mapID = 1426, x = 0.24, y = 0.40, quests = {} })
Dungeon({ id = "rfk", name = "Razorfen Kraul", min = 29, max = 38, zone = "The Barrens", mapID = 1413, x = 0.42, y = 0.90, quests = {} })
Dungeon({ id = "sm", name = "Scarlet Monastery", min = 30, max = 42, zone = "Tirisfal Glades", mapID = 1420, x = 0.85, y = 0.32, quests = {} })
Dungeon({ id = "rfd", name = "Razorfen Downs", min = 35, max = 45, zone = "The Barrens", mapID = 1413, x = 0.49, y = 0.90, quests = {} })
Dungeon({ id = "uldaman", name = "Uldaman", min = 38, max = 46, zone = "Badlands", mapID = 1418, x = 0.44, y = 0.12, quests = {} })
Dungeon({ id = "zf", name = "Zul'Farrak", min = 42, max = 50, zone = "Tanaris", mapID = 1446, x = 0.39, y = 0.21, quests = {} })
Dungeon({ id = "maraudon", name = "Maraudon", min = 42, max = 52, zone = "Desolace", mapID = 1443, x = 0.30, y = 0.62, quests = {} })
Dungeon({ id = "st", name = "Temple of Atal'Hakkar", min = 48, max = 56, zone = "Swamp of Sorrows", mapID = 1435, x = 0.70, y = 0.44, quests = {} })
Dungeon({ id = "brd", name = "Blackrock Depths", min = 52, max = 60, zone = "Burning Steppes", mapID = 1428, x = 0.28, y = 0.25, quests = {} })
Dungeon({ id = "lbrs", name = "Lower Blackrock Spire", min = 55, max = 60, zone = "Burning Steppes", mapID = 1428, x = 0.28, y = 0.25, quests = {} })
Dungeon({ id = "diremaul", name = "Dire Maul", min = 56, max = 60, zone = "Feralas", mapID = 1444, x = 0.59, y = 0.44, quests = {} })
Dungeon({ id = "scholo", name = "Scholomance", min = 58, max = 60, zone = "Western Plaguelands", mapID = 1422, x = 0.69, y = 0.73, quests = {} })
Dungeon({ id = "strat", name = "Stratholme", min = 58, max = 60, zone = "Eastern Plaguelands", mapID = 1423, x = 0.27, y = 0.11, quests = {} })
