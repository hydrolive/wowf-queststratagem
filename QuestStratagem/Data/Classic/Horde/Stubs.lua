-- Coverage spines for Horde races that are not authored yet.
-- Orc and Troll share Durotar. Everyone else falls back to that spine.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

QS.Registry.races.Horde = QS.Registry.races.Horde or {}

local function stub(race, zone, text)
    QS.Registry.races.Horde[race] = {
        routeName = zone .. " stub",
        stub = true,
        fallback = "Orc",
        steps = {
            {
                id = "H-" .. race .. "-stub",
                cluster = "stub",
                order = 1,
                kind = "note",
                title = race .. " starter",
                text = text,
                zone = zone,
                confidence = "stub",
                always = true,
                source = "design-2026-10-05",
                minutes = 1,
            },
        },
    }
end

stub("Undead", "Tirisfal Glades", "Deathknell is not authored yet. The Orc Durotar spine is the stand-in.")
stub("Tauren", "Mulgore", "Mulgore is not authored yet. The Orc Durotar spine is the stand-in.")
