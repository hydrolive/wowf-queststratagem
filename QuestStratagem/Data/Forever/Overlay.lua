-- QuestStratagem changelog
-- 0.1.0 (2026-10-05)
-- Phase A shell: large / medium / small, arrow, config, resume, clock.
-- Classic starter data: Human Elwynn and Orc/Troll Durotar through about level 6.
-- Other races exist as keys. Their bodies point at the nearest authored spine.
-- Skyborne routes are Zephras Isle text steps. No invented Forever quest ids.
-- Dungeon windows and pre-raid BiS tables are present; dungeon quest ids are not,
-- so those windows do not insert.
-- Data classic-1.12 + forever-2026-10-05. The 1-60 route is not complete.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

-- Stub overlays stay unloaded unless Config → Include stub data is on.
-- None of these rows invent a quest id.

local function stubDungeon(id, name, zone, minLevel, maxLevel, faction)
    QS.Registry.overlays[#QS.Registry.overlays + 1] = {
        op = "insert_after",
        anchor = "missing-on-purpose",
        confidence = "stub",
        source = "memory-2026-10-05",
        step = {
            id = "F-dungeon-" .. id,
            cluster = "forever-" .. id,
            kind = "note",
            title = name,
            text = name .. " (" .. minLevel .. "-" .. maxLevel .. ") in " .. zone
                .. " has no public quest id yet.",
            zone = zone,
            confidence = "stub",
            always = true,
            source = "memory-2026-10-05",
            factionNote = faction,
        },
    }
end

stubDungeon("hall-of-thanes", "Hall of Thanes", "Ironforge", 13, 18, "Alliance")
stubDungeon("ruins-of-lordaeron", "Ruins of Lordaeron", "Tirisfal Glades", 15, 20, "Horde")
stubDungeon("excavation-site", "Excavation Site", "Wetlands", 24, 31, nil)
stubDungeon("city-of-dalaran", "City of Dalaran", "Alterac Mountains", 28, 33, nil)
stubDungeon("drowned-city", "The Drowned City", "Stranglethorn Vale", 35, 40, nil)
stubDungeon("kroldok", "Krol'dok Stronghold", "The Riverglades", 40, 45, nil)
stubDungeon("alcaz", "Alcaz Prison", "Dustwallow Marsh", 48, 53, nil)
stubDungeon("blackmaw", "Blackmaw Hold", "Azshara", 55, 60, nil)
stubDungeon("shapers-terrace", "Shaper's Terrace", "Un'Goro Crater", 58, 60, nil)
