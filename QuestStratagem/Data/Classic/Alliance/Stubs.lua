-- Coverage spines for Alliance races that are not authored yet.
-- The router substitutes the Human Elwynn spine and says so.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

QS.Registry.races.Alliance = QS.Registry.races.Alliance or {}

local function stub(race, zone, text)
    QS.Registry.races.Alliance[race] = {
        routeName = zone .. " stub",
        stub = true,
        fallback = "Human",
        steps = {
            {
                id = "A-" .. race .. "-stub",
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

stub("Dwarf", "Dun Morogh", "Dun Morogh is not authored yet. The Human Elwynn spine is the stand-in.")
stub("Gnome", "Dun Morogh", "Gnome Coldridge is not authored yet. The Human Elwynn spine is the stand-in.")
stub("NightElf", "Teldrassil", "Teldrassil is not authored yet. The Human Elwynn spine is the stand-in.")
