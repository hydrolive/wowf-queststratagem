-- Orc and Troll Valley of Trials through the Razor Hill hearth, about level 1-6.
-- Shared steps. Class letters are race-tagged.
-- Quest ids are the Classic set (4641, 788, 789, 790, 804, 4402, 5441,
-- 6394, 792, 794, 805, 2161, orc parchments, troll tablets).
-- 3087 was checked on Wowhead Classic. Coordinates are published valley pins.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Durotar"
    row.mapID = row.mapID or 1411
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "horde-durotar"
    if not row.pin then
        row.pin = row.npc and "npc" or "approx"
    end
    steps[#steps + 1] = row
end

local function pin(base, extra)
    for k, v in pairs(base) do
        if extra[k] == nil then
            extra[k] = v
        end
    end
    return extra
end

local KALTUNK = { x = 0.432, y = 0.685, npc = "Kaltunk", hubName = "the Valley of Trials" }
local GORNEK = { x = 0.421, y = 0.683, npc = "Gornek", hubName = "the Valley of Trials" }
local HANAZUA = { x = 0.406, y = 0.627, npc = "Hana'zua" }
local GALGAR = { x = 0.427, y = 0.672, npc = "Galgar", hubName = "the Valley of Trials" }
local ZUREETHA = { x = 0.430, y = 0.690, npc = "Zureetha Fargaze", hubName = "the Valley of Trials" }
local THAZZ = { x = 0.449, y = 0.686, npc = "Foreman Thazz'ril", hubName = "the Valley of Trials" }

add(pin(KALTUNK, {
    id = "H-durotar-0001", order = 1, cluster = "den", starter = true,
    kind = "accept", title = "Your Place In The World", questID = 4641,
    text = "In the Den. He sends you to Gornek.",
    xp = 40, minutes = 1, minLevel = 1,
}))

add(pin(GORNEK, {
    id = "H-durotar-0002", order = 2, cluster = "den", starter = true,
    kind = "turnin", title = "Your Place In The World", questName = "Your Place In The World",
    questID = 4641, requiresQuest = { 4641 }, requiresState = "accepted",
    text = "Gornek is just inside the Den.",
    xp = 40, minutes = 1,
}))

add(pin(GORNEK, {
    id = "H-durotar-0003", order = 3, cluster = "den", starter = true,
    kind = "accept", title = "Cutting Teeth", questID = 788,
    requiresQuest = { 4641 }, requiresState = "turnedin",
    text = "Mottled boars north of the Den.",
    xp = 170, minutes = 1,
}))

add({
    id = "H-durotar-0004", order = 4, cluster = "valley-north", starter = true,
    kind = "objective", title = "Mottled Boars", questName = "Cutting Teeth",
    questID = 788, objective = 1,
    requiresQuest = { 788 }, requiresState = "accepted",
    text = "Leave the Den and head north. Kill mottled boars.",
    x = 0.440, y = 0.630, pin = "approx", minutes = 4,
})

add(pin(HANAZUA, {
    id = "H-durotar-0005", order = 5, cluster = "sarkoth", starter = true,
    kind = "accept", title = "Sarkoth", questID = 790,
    text = "Hana'zua is in a small cave west of the boars. She is hurt. Kill the scorpid named Sarkoth.",
    xp = 110, minutes = 2,
}))

add({
    id = "H-durotar-0006", order = 6, cluster = "sarkoth", starter = true,
    kind = "objective", title = "Sarkoth's Claw", questName = "Sarkoth",
    questID = 790, objective = 1,
    requiresQuest = { 790 }, requiresState = "accepted",
    text = "Sarkoth is just south of Hana'zua's cave.",
    x = 0.405, y = 0.660, pin = "approx", minutes = 3,
})

add(pin(HANAZUA, {
    id = "H-durotar-0007", order = 7, cluster = "sarkoth", starter = true,
    kind = "turnin", title = "Sarkoth", questName = "Sarkoth", questID = 790,
    requiresQuest = { 790 }, requiresState = "accepted",
    text = "Claw back to Hana'zua.",
    xp = 110, minutes = 1,
}))

add(pin(HANAZUA, {
    id = "H-durotar-0008", order = 8, cluster = "sarkoth", starter = true,
    kind = "accept", title = "Sarkoth", questID = 804, questName = "Sarkoth",
    requiresQuest = { 790 }, requiresState = "turnedin",
    text = "She asks you to tell Gornek. This is the second Sarkoth step.",
    xp = 450, minutes = 1,
}))

add(pin(GORNEK, {
    id = "H-durotar-0009", order = 9, cluster = "den", starter = true,
    kind = "turnin", title = "Cutting Teeth", questName = "Cutting Teeth", questID = 788,
    requiresQuest = { 788 }, requiresState = "accepted",
    text = "Boar tusks, or the kill credit, back to Gornek.",
    xp = 170, minutes = 2,
}))

add(pin(GORNEK, {
    id = "H-durotar-0010", order = 10, cluster = "den", starter = true,
    kind = "turnin", title = "Sarkoth", questName = "Sarkoth", questID = 804,
    requiresQuest = { 804 }, requiresState = "accepted",
    text = "Tell Gornek what happened to Hana'zua.",
    xp = 450, minutes = 1,
}))

add(pin(GORNEK, {
    id = "H-durotar-0011", order = 11, cluster = "den", starter = true,
    kind = "accept", title = "Sting of the Scorpid", questID = 789,
    requiresQuest = { 788 }, requiresState = "turnedin",
    text = "Scorpid worker tails. The scorpids are south of the Den.",
    xp = 250, minutes = 1,
}))

local orcLetters = {
    { id = "2383", questID = 2383, class = "Warrior", title = "Simple Parchment", npc = "Frang" },
    { id = "3087", questID = 3087, class = "Hunter", title = "Etched Parchment", npc = "Jen'shan" },
    { id = "3088", questID = 3088, class = "Rogue", title = "Encrypted Parchment", npc = "Rwag" },
    { id = "3089", questID = 3089, class = "Shaman", title = "Rune-Inscribed Parchment", npc = "Shikrik" },
    { id = "3090", questID = 3090, class = "Warlock", title = "Tainted Parchment", npc = "Nartok" },
}
local trollLetters = {
    { id = "3065", questID = 3065, class = "Warrior", title = "Simple Tablet", npc = "Frang" },
    { id = "3082", questID = 3082, class = "Hunter", title = "Etched Tablet", npc = "Jen'shan" },
    { id = "3083", questID = 3083, class = "Rogue", title = "Encrypted Tablet", npc = "Rwag" },
    { id = "3084", questID = 3084, class = "Priest", title = "Hallowed Tablet", npc = "Ken'jai" },
    { id = "3085", questID = 3085, class = "Shaman", title = "Rune-Inscribed Tablet", npc = "Shikrik" },
    { id = "3086", questID = 3086, class = "Mage", title = "Glyphic Tablet", npc = "Mai'ah" },
}

local function letters(list, race, orderBase)
    for i = 1, #list do
        local letter = list[i]
        local classes = {}
        classes[letter.class] = true
        local races = {}
        races[race] = true
        add(pin(GORNEK, {
            id = "H-durotar-letter-" .. letter.id,
            order = orderBase + i, cluster = "den", starter = true,
            kind = "accept", title = letter.title, questID = letter.questID,
            classQuest = true, classes = classes, races = races,
            requiresQuest = { 788 }, requiresState = "turnedin",
            text = "Read it and speak to " .. letter.npc .. " in the Den.",
            xp = 40, minutes = 1,
        }))
        add({
            id = "H-durotar-train-" .. letter.id,
            order = orderBase + 20 + i, cluster = "den", starter = true,
            kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
            classQuest = true, classes = classes, races = races,
            npc = letter.npc, x = 0.418, y = 0.678, pin = "npc",
            hubName = "the Valley of Trials",
            requiresQuest = { letter.questID }, requiresState = "accepted",
            text = letter.npc .. " is inside the Den. Train your first ranks.",
            xp = 40, minutes = 1,
        })
    end
end

letters(orcLetters, "Orc", 30)
letters(trollLetters, "Troll", 40)

add({
    id = "H-durotar-mage-orc",
    order = 70, cluster = "den", starter = true,
    kind = "note", title = "Orc Mage",
    classQuest = true, classes = { Mage = true }, races = { Orc = true },
    always = true, confidence = "stub",
    npc = "Gornek", x = 0.421, y = 0.683, pin = "npc",
    text = "Orc mages are new on Forever. No Classic letter exists. Train in the Den, then Next.",
    minutes = 2, source = "design-2026-10-05",
})

add({
    id = "H-durotar-warlock-troll",
    order = 71, cluster = "den", starter = true,
    kind = "note", title = "Troll Warlock",
    classQuest = true, classes = { Warlock = true }, races = { Troll = true },
    always = true, confidence = "stub",
    npc = "Gornek", x = 0.421, y = 0.683, pin = "npc",
    text = "Troll warlocks are new on Forever. No Classic tablet exists. Train in the Den, then Next.",
    minutes = 2, source = "design-2026-10-05",
})

add(pin(GALGAR, {
    id = "H-durotar-0080", order = 80, cluster = "den", starter = true,
    kind = "accept", title = "Galgar's Cactus Apple Surprise", questID = 4402,
    text = "Cactus apples around the valley. Galgar is near the Den.",
    xp = 380, minutes = 1,
}))

add(pin(ZUREETHA, {
    id = "H-durotar-0081", order = 81, cluster = "den", starter = true,
    kind = "accept", title = "Vile Familiars", questID = 792, noBatch = true,
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    text = "Zureetha stands outside the Den. Familiars spill from the cave to the north. Warlocks take a different version.",
    xp = 450, minutes = 1,
}))

add({
    id = "H-durotar-warlock-familiars",
    order = 82, cluster = "den", starter = true,
    kind = "note", title = "Vile Familiars (Warlock)",
    classQuest = true, classes = { Warlock = true },
    always = true, confidence = "stub",
    npc = "Ruzan", x = 0.418, y = 0.678, pin = "npc",
    text = "Warlocks pick up Vile Familiars from the warlock trainer, not Zureetha. The Classic id is not pinned in this file. Next if your log already has it.",
    minutes = 2, source = "design-2026-10-05",
})

add(pin(THAZZ, {
    id = "H-durotar-0083", order = 83, cluster = "den", starter = true,
    kind = "accept", title = "Lazy Peons", questID = 5441,
    text = "Foreman Thazz'ril, outside the Den. Wake sleeping peons with his blackjack.",
    xp = 450, minutes = 1, minLevel = 3,
}))

add({
    id = "H-durotar-0084", order = 84, cluster = "valley-work", starter = true,
    kind = "objective", title = "Scorpid Worker Tails", questName = "Sting of the Scorpid",
    questID = 789, objective = 1,
    requiresQuest = { 789 }, requiresState = "accepted",
    text = "Scorpid workers south of the Den.",
    x = 0.418, y = 0.715, pin = "approx", minutes = 5,
})

add({
    id = "H-durotar-0085", order = 85, cluster = "valley-work", starter = true,
    kind = "objective", title = "Cactus Apples", questName = "Galgar's Cactus Apple Surprise",
    questID = 4402, objective = 1,
    requiresQuest = { 4402 }, requiresState = "accepted",
    text = "Cactus plants around the valley floor.",
    x = 0.448, y = 0.635, pin = "approx", minutes = 4,
})

add({
    id = "H-durotar-0086", order = 86, cluster = "valley-work", starter = true,
    kind = "objective", title = "Wake the Peons", questName = "Lazy Peons",
    questID = 5441, objective = 1,
    requiresQuest = { 5441 }, requiresState = "accepted",
    text = "Sleeping peons near the trees. Use the blackjack.",
    x = 0.450, y = 0.640, pin = "approx", minutes = 4,
})

add({
    id = "H-durotar-0087", order = 87, cluster = "valley-cave", starter = true,
    kind = "objective", title = "Vile Familiars", questName = "Vile Familiars",
    questID = 792, objective = 1,
    requiresQuest = { 792 }, requiresState = "accepted",
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    text = "Burning Blade cave north of the Den. Kill the familiars at the mouth.",
    x = 0.452, y = 0.568, pin = "approx", minutes = 6,
})

add(pin(THAZZ, {
    id = "H-durotar-0088", order = 88, cluster = "den", starter = true,
    kind = "turnin", title = "Lazy Peons", questName = "Lazy Peons", questID = 5441,
    requiresQuest = { 5441 }, requiresState = "accepted",
    text = "Blackjack back to Thazz'ril.",
    xp = 450, minutes = 2,
}))

add(pin(THAZZ, {
    id = "H-durotar-0089", order = 89, cluster = "den", starter = true,
    kind = "accept", title = "Thazz'ril's Pick", questID = 6394,
    requiresQuest = { 5441 }, requiresState = "turnedin",
    text = "His pick is inside the Burning Blade cave.",
    xp = 450, minutes = 1,
}))

add({
    id = "H-durotar-0090", order = 90, cluster = "valley-cave", starter = true,
    kind = "objective", title = "Thazz'ril's Pick", questName = "Thazz'ril's Pick",
    questID = 6394, objective = 1,
    requiresQuest = { 6394 }, requiresState = "accepted",
    text = "Deeper in the Burning Blade cave.",
    x = 0.434, y = 0.545, pin = "approx", minutes = 4,
})

add(pin(GORNEK, {
    id = "H-durotar-0091", order = 91, cluster = "den", starter = true,
    kind = "turnin", title = "Sting of the Scorpid", questName = "Sting of the Scorpid",
    questID = 789, requiresQuest = { 789 }, requiresState = "accepted",
    text = "Tails back to Gornek.",
    xp = 250, minutes = 2,
}))

add(pin(GALGAR, {
    id = "H-durotar-0092", order = 92, cluster = "den", starter = true,
    kind = "turnin", title = "Galgar's Cactus Apple Surprise", questName = "Galgar's Cactus Apple Surprise",
    questID = 4402, requiresQuest = { 4402 }, requiresState = "accepted",
    text = "Apples back to Galgar.",
    xp = 380, minutes = 1,
}))

add(pin(ZUREETHA, {
    id = "H-durotar-0093", order = 93, cluster = "den", starter = true,
    kind = "turnin", title = "Vile Familiars", questName = "Vile Familiars", questID = 792,
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    requiresQuest = { 792 }, requiresState = "accepted",
    text = "Back to Zureetha. Take the weapon that matches your spec.",
    xp = 450, minutes = 2,
    rewardChoice = {
        Arms = { name = "Primitive Club", slot = "weapon", how = "reward" },
        Fury = { name = "Primitive Club", slot = "weapon", how = "reward" },
        Protection = { name = "Primitive Club", slot = "weapon", how = "reward" },
        Enhancement = { name = "Primitive Club", slot = "weapon", how = "reward" },
        Assassination = { name = "Primitive Hand Blade", slot = "weapon", how = "reward" },
        Combat = { name = "Primitive Hand Blade", slot = "weapon", how = "reward" },
        Subtlety = { name = "Primitive Hand Blade", slot = "weapon", how = "reward" },
        BeastMastery = { name = "Primitive Hatchet", slot = "weapon", how = "reward" },
        Marksmanship = { name = "Primitive Hatchet", slot = "weapon", how = "reward" },
        Survival = { name = "Primitive Hatchet", slot = "weapon", how = "reward" },
        Elemental = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Restoration = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Arcane = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Fire = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Frost = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Discipline = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Holy = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
        Shadow = { name = "Primitive Walking Stick", slot = "weapon", how = "reward" },
    },
}))

add(pin(ZUREETHA, {
    id = "H-durotar-0094", order = 94, cluster = "den", starter = true,
    kind = "accept", title = "Burning Blade Medallion", questID = 794,
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    requiresQuest = { 792 }, requiresState = "turnedin",
    text = "Yarrog Baneshadow, at the back of the same cave. Bring his medallion.",
    xp = 675, minutes = 1,
}))

add({
    id = "H-durotar-0095", order = 95, cluster = "valley-cave", starter = true,
    kind = "objective", title = "Burning Blade Medallion", questName = "Burning Blade Medallion",
    questID = 794, objective = 1,
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    requiresQuest = { 794 }, requiresState = "accepted",
    text = "Back of the Burning Blade cave.",
    x = 0.424, y = 0.530, pin = "approx", minutes = 5,
})

add(pin(ZUREETHA, {
    id = "H-durotar-0096", order = 96, cluster = "den", starter = true,
    kind = "turnin", title = "Burning Blade Medallion", questName = "Burning Blade Medallion",
    questID = 794,
    classes = {
        Warrior = true, Hunter = true, Rogue = true, Shaman = true,
        Mage = true, Priest = true, Druid = true,
    },
    requiresQuest = { 794 }, requiresState = "accepted",
    text = "Medallion back to Zureetha. She sends you to Sen'jin Village.",
    xp = 675, minutes = 2,
}))

add(pin(THAZZ, {
    id = "H-durotar-0097", order = 97, cluster = "den", starter = true,
    kind = "turnin", title = "Thazz'ril's Pick", questName = "Thazz'ril's Pick", questID = 6394,
    requiresQuest = { 6394 }, requiresState = "accepted",
    text = "Pick back to Foreman Thazz'ril.",
    xp = 450, minutes = 2,
}))

add(pin(ZUREETHA, {
    id = "H-durotar-0098", order = 98, cluster = "den", starter = true,
    kind = "accept", title = "Report to Sen'jin Village", questID = 805,
    requiresQuest = { 794 }, requiresState = "turnedin",
    text = "Master Gadrin, in Sen'jin Village. Leave the valley to the east.",
    xp = 230, minutes = 1,
}))

add({
    id = "H-durotar-0099", order = 99, cluster = "valley-exit",
    kind = "accept", title = "A Peon's Burden", questID = 2161,
    npc = "Ukor", x = 0.521, y = 0.683, pin = "npc", hubName = "the valley exit",
    text = "Ukor stands where the valley opens onto Durotar. He sends a load to the Razor Hill inn.",
    xp = 110, minutes = 1,
})

add({
    id = "H-durotar-0100", order = 100, cluster = "senjin",
    kind = "turnin", title = "Report to Sen'jin Village", questName = "Report to Sen'jin Village",
    questID = 805, npc = "Master Gadrin", x = 0.560, y = 0.747, pin = "npc",
    requiresQuest = { 805 }, requiresState = "accepted",
    text = "Sen'jin Village. Gadrin is in the big hut.",
    xp = 230, minutes = 4,
})

add({
    id = "H-durotar-0101", order = 101, cluster = "razorhill",
    kind = "hearth", title = "A Peon's Burden", questName = "A Peon's Burden", questID = 2161,
    npc = "Innkeeper Grosk", x = 0.515, y = 0.416, pin = "npc",
    requiresQuest = { 2161 }, requiresState = "accepted",
    text = "Razor Hill inn. Set your hearth with Grosk.",
    xp = 110, minutes = 3,
})

local def = {
    routeName = "Durotar priority route",
    stub = false,
    steps = steps,
}

QS.Registry.races.Horde = QS.Registry.races.Horde or {}
QS.Registry.races.Horde.Orc = def
QS.Registry.races.Horde.Troll = def
