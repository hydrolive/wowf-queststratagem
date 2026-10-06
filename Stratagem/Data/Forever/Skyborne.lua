-- Skyborne starters. No quest ids: Forever has not published them.
-- These are the race spine, so they show even when stub rows are hidden.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local function stepsFor(side)
    return {
        {
            id = "F-zephras-0001-" .. side,
            cluster = "zephras",
            order = 1,
            kind = "note",
            starter = true,
            title = "Land on Zephras Isle",
            text = "Skyborne characters start on Zephras Isle. No public quest id yet. Speak to the first camp trainer and follow their marker.",
            zone = "Zephras Isle",
            confidence = "stub",
            always = true,
            source = "memory-2026-10-05",
            minutes = 10,
        },
        {
            id = "F-zephras-0002-" .. side,
            cluster = "zephras",
            order = 2,
            kind = "note",
            starter = true,
            title = "Clear the first camp",
            text = "Do the isle's opening kills and pickups. Leave this note with Next when the camp has nothing left to offer.",
            zone = "Zephras Isle",
            confidence = "stub",
            always = true,
            source = "memory-2026-10-05",
            minutes = 40,
        },
        {
            id = "F-zephras-0003-" .. side,
            cluster = "zephras",
            order = 3,
            kind = "travel",
            title = "Leave Zephras Isle",
            text = side == "Alliance"
                and "When the isle lets you go, the Alliance road is not authored past this note."
                or "When the isle lets you go, the Horde road is not authored past this note.",
            zone = "Zephras Isle",
            confidence = "stub",
            always = true,
            source = "memory-2026-10-05",
            minutes = 15,
        },
    }
end

QS.Registry.races.Alliance = QS.Registry.races.Alliance or {}
QS.Registry.races.Horde = QS.Registry.races.Horde or {}

QS.Registry.races.Alliance.HighOrder = {
    routeName = "Zephras Isle",
    stub = false,
    noTerminal = true,
    steps = stepsFor("Alliance"),
}

QS.Registry.races.Horde.Windshaper = {
    routeName = "Zephras Isle",
    stub = false,
    noTerminal = true,
    steps = stepsFor("Horde"),
}
