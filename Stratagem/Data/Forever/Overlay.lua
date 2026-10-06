-- Stratagem changelog
-- 0.1.3 (2026-10-05)
-- The addon is Stratagem. The window title is Stratagem. Options opens the spec buttons.
-- A profession trains only when the next rank is within 5 skill, and only at a real trainer pin.
-- Alchemy 15/75 no longer lists Minor Healing Potion or points at the inn.
-- The quest log leads, one area at a time. Thunder Bluff turns Elder Knowledge in to Bashana Runetotem.
-- 0.1.2 (2026-10-05)
-- Grey quests drop out. The header estimates time to the next level.
-- The bar matches this level's XP. A level with no authored quest keeps
-- one dungeon and kill steps, and says those quest ids are not in the guide.
-- 0.1.1 (2026-10-05)
-- Live steps: set hearth at a new hub, hearth back for turn-ins, talent point,
-- profession trainer and craft reminder, gather sub-goals, sell/repair,
-- bank and auction lists in cities, dungeon boss kills.
-- Classic dungeon windows now insert from the boss list even when quest ids
-- are empty. Interior boss pins are not in this build. The step names the boss.
-- 0.1.0 (2026-10-05)
-- Phase A shell: large / medium / small, arrow, config, resume, clock.
-- Classic starter data: Human Elwynn and Orc/Troll Durotar through about level 6.
-- Other races exist as keys. Their bodies point at the nearest authored spine.
-- Skyborne routes are Zephras Isle text steps. No invented Forever quest ids.
-- Dungeon windows and pre-raid BiS tables are present. Quest id lists were empty,
-- so 0.1.0 did not insert those windows. 0.1.1 inserts them for the boss order.
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
