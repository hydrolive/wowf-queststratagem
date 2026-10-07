-- Dwarf and Gnome Coldridge through the Kharanos hearth, about level 1-6.
-- Shared steps. Class letters are race-tagged.
-- Quest ids are the Classic set (179, 233, 234, 183, 182, 218, 282, 420,
-- 2160, 170, 3364, 3365, dwarf runes 3106-3110, gnome memos 3112-3115,
-- gnome warlock 1599, dwarf priest 5625).
-- Coordinates are the published Coldridge and Kharanos pins.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Dun Morogh"
    row.mapID = row.mapID or 1426
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "alliance-dunmorogh"
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

local STEN = { x = 0.2993, y = 0.7120, npc = "Sten Stoutarm", hubName = "Coldridge Valley" }
local BALIR = { x = 0.2971, y = 0.7126, npc = "Balir Frosthammer", hubName = "Anvilmar" }
local TALIN = { x = 0.2260, y = 0.7143, npc = "Talin Keeneye", hubName = "Coldridge Valley" }
local GRELIN = { x = 0.2508, y = 0.7571, npc = "Grelin Whitebeard", hubName = "Coldridge Valley" }
local NORI = { x = 0.2498, y = 0.7596, npc = "Nori Pridedrift", hubName = "Coldridge Valley" }
local DURNAN = { x = 0.2877, y = 0.6638, npc = "Durnan Furcutter", hubName = "Anvilmar" }
local ALAMAR = { x = 0.2865, y = 0.6615, npc = "Alamar Grimm", hubName = "Anvilmar" }

add(pin(STEN, {
    id = "A-dunmorogh-0001", order = 1, cluster = "coldridge", starter = true,
    kind = "accept", title = "Dwarven Outfitters", questID = 179,
    text = "Sten Stoutarm wants 8 pieces of tough wolf meat.",
    xp = 80, minutes = 1, minLevel = 1,
}))

add({
    id = "A-dunmorogh-0002", order = 2, cluster = "wolves", starter = true,
    kind = "objective", title = "Tough Wolf Meat", questName = "Dwarven Outfitters",
    questID = 179, objective = 1,
    requiresQuest = { 179 }, requiresState = "accepted",
    text = "Wolves are just south of Sten.",
    x = 0.2856, y = 0.7249, pin = "approx", minutes = 4,
})

add(pin(STEN, {
    id = "A-dunmorogh-0003", order = 3, cluster = "coldridge", starter = true,
    kind = "turnin", title = "Dwarven Outfitters", questName = "Dwarven Outfitters", questID = 179,
    requiresQuest = { 179 }, requiresState = "accepted",
    text = "Meat back to Sten. He has your class letter.",
    xp = 80, minutes = 2,
}))

local dwarfLetters = {
    { id = "3106", questID = 3106, class = "Warrior", title = "Simple Rune", npc = "Thran Khorman", x = 0.2883, y = 0.6724 },
    { id = "3107", questID = 3107, class = "Paladin", title = "Consecrated Rune", npc = "Bromos Grummner", x = 0.2883, y = 0.6833 },
    { id = "3108", questID = 3108, class = "Hunter", title = "Etched Rune", npc = "Thorgas Grimson", x = 0.2918, y = 0.6746 },
    { id = "3109", questID = 3109, class = "Rogue", title = "Encrypted Rune", npc = "Solm Hargrin", x = 0.2837, y = 0.6751 },
    { id = "3110", questID = 3110, class = "Priest", title = "Hallowed Rune", npc = "Branstock Khalder", x = 0.2860, y = 0.6639 },
}
local gnomeLetters = {
    { id = "3112", questID = 3112, class = "Warrior", title = "Simple Memorandum", npc = "Thran Khorman", x = 0.2883, y = 0.6724 },
    { id = "3113", questID = 3113, class = "Rogue", title = "Encrypted Memorandum", npc = "Solm Hargrin", x = 0.2837, y = 0.6751 },
    { id = "3114", questID = 3114, class = "Mage", title = "Glyphic Memorandum", npc = "Marryk Nurribit", x = 0.2871, y = 0.6637 },
    { id = "3115", questID = 3115, class = "Warlock", title = "Tainted Memorandum", npc = "Alamar Grimm", x = 0.2865, y = 0.6615 },
}

local function letters(list, race, orderBase)
    for i = 1, #list do
        local letter = list[i]
        local classes = {}
        classes[letter.class] = true
        local races = {}
        races[race] = true
        add(pin(STEN, {
            id = "A-dunmorogh-letter-" .. letter.id,
            order = orderBase + i, cluster = "coldridge", starter = true,
            kind = "accept", title = letter.title, questID = letter.questID,
            classQuest = true, classes = classes, races = races,
            requiresQuest = { 179 }, requiresState = "turnedin",
            text = "Read it and speak to " .. letter.npc .. " in Anvilmar.",
            xp = 40, minutes = 1,
        }))
        add({
            id = "A-dunmorogh-train-" .. letter.id,
            order = orderBase + 20 + i, cluster = "anvilmar", starter = true,
            kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
            classQuest = true, classes = classes, races = races,
            npc = letter.npc, x = letter.x, y = letter.y, pin = "npc",
            hubName = "Anvilmar",
            requiresQuest = { letter.questID }, requiresState = "accepted",
            text = letter.npc .. " is inside Anvilmar. Train your first ranks.",
            xp = 40, minutes = 1,
        })
    end
end

letters(dwarfLetters, "Dwarf", 10)
letters(gnomeLetters, "Gnome", 40)

add({
    id = "A-dunmorogh-shaman",
    order = 70, cluster = "anvilmar", starter = true,
    kind = "note", title = "Dwarf Shaman",
    classQuest = true, classes = { Shaman = true }, races = { Dwarf = true },
    always = true, confidence = "stub",
    npc = "Sten Stoutarm", x = 0.2993, y = 0.7120, pin = "npc",
    text = "Classic has no Dwarf shaman rune. Train in Anvilmar when Forever publishes the quest. Next leaves this note.",
    minutes = 2, source = "design-2026-10-06",
})

add({
    id = "A-dunmorogh-priest",
    order = 71, cluster = "anvilmar", starter = true,
    kind = "note", title = "Gnome Priest",
    classQuest = true, classes = { Priest = true }, races = { Gnome = true },
    always = true, confidence = "stub",
    npc = "Sten Stoutarm", x = 0.2993, y = 0.7120, pin = "npc",
    text = "Classic has no Gnome priest memorandum. Train in Anvilmar when Forever publishes the quest. Next leaves this note.",
    minutes = 2, source = "design-2026-10-06",
})

add(pin(BALIR, {
    id = "A-dunmorogh-0080", order = 80, cluster = "anvilmar", starter = true,
    kind = "accept", title = "A New Threat", questID = 170,
    text = "Balir Frosthammer, inside Anvilmar. Rockjaw troggs south of the camp.",
    xp = 250, minutes = 1,
}))

add({
    id = "A-dunmorogh-0081", order = 81, cluster = "troggs", starter = true,
    kind = "objective", title = "Rockjaw Troggs", questName = "A New Threat",
    questID = 170, requiresQuest = { 170 }, requiresState = "accepted",
    text = "Rockjaw Troggs and Burly Rockjaw Troggs are south of Anvilmar.",
    x = 0.2702, y = 0.7731, pin = "approx", minutes = 6,
})

add(pin(BALIR, {
    id = "A-dunmorogh-0082", order = 82, cluster = "anvilmar", starter = true,
    kind = "turnin", title = "A New Threat", questName = "A New Threat", questID = 170,
    requiresQuest = { 170 }, requiresState = "accepted",
    text = "Back to Balir Frosthammer.",
    xp = 250, minutes = 2,
}))

add(pin(STEN, {
    id = "A-dunmorogh-0083", order = 83, cluster = "coldridge", starter = true,
    kind = "accept", title = "Coldridge Valley Mail Delivery", questID = 233,
    requiresQuest = { 179 }, requiresState = "turnedin",
    text = "Sten sends a letter to Talin Keeneye, west along the valley.",
    xp = 170, minutes = 1,
}))

add(pin(TALIN, {
    id = "A-dunmorogh-0084", order = 84, cluster = "west", starter = true,
    kind = "turnin", title = "Coldridge Valley Mail Delivery", questName = "Coldridge Valley Mail Delivery",
    questID = 233, requiresQuest = { 233 }, requiresState = "accepted",
    text = "Talin Keeneye watches the boars west of Anvilmar.",
    xp = 170, minutes = 2,
}))

add(pin(TALIN, {
    id = "A-dunmorogh-0085", order = 85, cluster = "west", starter = true,
    kind = "accept", title = "The Boar Hunter", questID = 183,
    requiresQuest = { 233 }, requiresState = "turnedin",
    text = "Kill 12 Small Crag Boars around Talin.",
    xp = 250, minutes = 1,
}))

add(pin(TALIN, {
    id = "A-dunmorogh-0086", order = 86, cluster = "west", starter = true,
    kind = "accept", title = "Coldridge Valley Mail Delivery", questID = 234,
    requiresQuest = { 233 }, requiresState = "turnedin",
    text = "The second letter goes to Grelin Whitebeard, further up the valley.",
    xp = 250, minutes = 1,
}))

add({
    id = "A-dunmorogh-0087", order = 87, cluster = "west", starter = true,
    kind = "objective", title = "Small Crag Boars", questName = "The Boar Hunter",
    questID = 183, objective = 1,
    requiresQuest = { 183 }, requiresState = "accepted",
    text = "The boars are around Talin's camp.",
    x = 0.2436, y = 0.7259, pin = "approx", minutes = 5,
})

add(pin(TALIN, {
    id = "A-dunmorogh-0088", order = 88, cluster = "west", starter = true,
    kind = "turnin", title = "The Boar Hunter", questName = "The Boar Hunter", questID = 183,
    requiresQuest = { 183 }, requiresState = "accepted",
    text = "Back to Talin Keeneye.",
    xp = 250, minutes = 1,
}))

add(pin(GRELIN, {
    id = "A-dunmorogh-0089", order = 89, cluster = "grelin", starter = true,
    kind = "turnin", title = "Coldridge Valley Mail Delivery", questName = "Coldridge Valley Mail Delivery",
    questID = 234, requiresQuest = { 234 }, requiresState = "accepted",
    text = "Grelin Whitebeard is up the slope, near his brother Nori.",
    xp = 250, minutes = 3,
}))

add(pin(GRELIN, {
    id = "A-dunmorogh-0090", order = 90, cluster = "grelin", starter = true,
    kind = "accept", title = "The Troll Cave", questID = 182,
    requiresQuest = { 234 }, requiresState = "turnedin",
    text = "Kill 14 Frostmane Troll Whelps in the cave to the southwest.",
    xp = 360, minutes = 1,
}))

add(pin(ALAMAR, {
    id = "A-dunmorogh-warlock-1599", order = 91, cluster = "anvilmar", starter = true,
    kind = "accept", title = "Beginnings", questID = 1599,
    classQuest = true, classes = { Warlock = true }, races = { Gnome = true },
    text = "Alamar Grimm in Anvilmar wants Feather Charms from the Frostmane novices in that cave.",
    xp = 250, minutes = 3,
}))

add({
    id = "A-dunmorogh-0092", order = 92, cluster = "cave", starter = true,
    kind = "objective", title = "Frostmane Troll Whelps", questName = "The Troll Cave",
    questID = 182, objective = 1,
    requiresQuest = { 182 }, requiresState = "accepted",
    text = "The whelps are in and around the Frostmane cave.",
    x = 0.2067, y = 0.7584, pin = "approx", minutes = 6,
})

add({
    id = "A-dunmorogh-warlock-charms", order = 93, cluster = "cave", starter = true,
    kind = "objective", title = "Feather Charms", questName = "Beginnings",
    questID = 1599, objective = 1,
    classQuest = true, classes = { Warlock = true }, races = { Gnome = true },
    requiresQuest = { 1599 }, requiresState = "accepted",
    text = "Frostmane novices deeper in the cave carry the charms.",
    x = 0.3022, y = 0.8025, pin = "approx", minutes = 5,
})

add(pin(GRELIN, {
    id = "A-dunmorogh-0094", order = 94, cluster = "grelin", starter = true,
    kind = "turnin", title = "The Troll Cave", questName = "The Troll Cave", questID = 182,
    requiresQuest = { 182 }, requiresState = "accepted",
    text = "Back to Grelin Whitebeard.",
    xp = 360, minutes = 3,
}))

add(pin(GRELIN, {
    id = "A-dunmorogh-0095", order = 95, cluster = "grelin", starter = true,
    kind = "accept", title = "The Stolen Journal", questID = 218,
    requiresQuest = { 182 }, requiresState = "turnedin",
    text = "Grik'nir the Cold is in the cave. Bring Grelin's journal.",
    xp = 450, minutes = 1,
}))

add(pin(NORI, {
    id = "A-dunmorogh-0096", order = 96, cluster = "grelin", starter = true,
    kind = "accept", title = "Scalding Mornbrew Delivery", questID = 3364,
    text = "Nori stands beside Grelin. The mug cools fast. Run it to Durnan in Anvilmar before the cave.",
    xp = 85, minutes = 1,
}))

add(pin(DURNAN, {
    id = "A-dunmorogh-0098", order = 97, cluster = "anvilmar", starter = true,
    kind = "turnin", title = "Scalding Mornbrew Delivery", questName = "Scalding Mornbrew Delivery",
    questID = 3364, requiresQuest = { 3364 }, requiresState = "accepted",
    text = "Durnan Furcutter is inside Anvilmar. Do this while the mug is still hot.",
    xp = 85, minutes = 3,
}))

add(pin(DURNAN, {
    id = "A-dunmorogh-0099", order = 98, cluster = "anvilmar", starter = true,
    kind = "accept", title = "Bring Back the Mug", questID = 3365,
    requiresQuest = { 3364 }, requiresState = "turnedin",
    text = "He wants the empty mug taken back to Nori.",
    xp = 250, minutes = 1,
}))

add(pin(ALAMAR, {
    id = "A-dunmorogh-warlock-1599b", order = 99, cluster = "anvilmar", starter = true,
    kind = "turnin", title = "Beginnings", questName = "Beginnings", questID = 1599,
    classQuest = true, classes = { Warlock = true }, races = { Gnome = true },
    requiresQuest = { 1599 }, requiresState = "accepted",
    text = "Charms back to Alamar Grimm while you are in Anvilmar.",
    xp = 250, minutes = 1,
}))

add({
    id = "A-dunmorogh-0097", order = 100, cluster = "cave", starter = true,
    kind = "objective", title = "Grelin Whitebeard's Journal", questName = "The Stolen Journal",
    questID = 218, objective = 1,
    requiresQuest = { 218 }, requiresState = "accepted",
    text = "Grik'nir the Cold is at the back of the Frostmane cave. The journal turns in to Grelin after.",
    x = 0.3049, y = 0.8017, pin = "approx", minutes = 5,
})

add(pin(NORI, {
    id = "A-dunmorogh-0101", order = 101, cluster = "grelin", starter = true,
    kind = "turnin", title = "Bring Back the Mug", questName = "Bring Back the Mug", questID = 3365,
    requiresQuest = { 3365 }, requiresState = "accepted",
    text = "Empty mug back to Nori Pridedrift.",
    xp = 250, minutes = 3,
}))

add(pin(GRELIN, {
    id = "A-dunmorogh-0102", order = 102, cluster = "grelin", starter = true,
    kind = "turnin", title = "The Stolen Journal", questName = "The Stolen Journal", questID = 218,
    requiresQuest = { 218 }, requiresState = "accepted",
    text = "Journal back to Grelin Whitebeard.",
    xp = 450, minutes = 1,
}))

add(pin(GRELIN, {
    id = "A-dunmorogh-0103", order = 103, cluster = "grelin", starter = true,
    kind = "accept", title = "Senir's Observations", questID = 282,
    requiresQuest = { 218 }, requiresState = "turnedin",
    text = "Grelin sends his notes to Mountaineer Thalos at the tunnel out of the valley.",
    xp = 85, minutes = 1,
}))

add({
    id = "A-dunmorogh-0104", order = 104, cluster = "tunnel",
    kind = "turnin", title = "Senir's Observations", questName = "Senir's Observations", questID = 282,
    npc = "Mountaineer Thalos", x = 0.3348, y = 0.7184, pin = "npc", hubName = "Coldridge Pass",
    requiresQuest = { 282 }, requiresState = "accepted",
    text = "Mountaineer Thalos guards the tunnel to the rest of Dun Morogh.",
    xp = 85, minutes = 4,
})

add({
    id = "A-dunmorogh-0105", order = 105, cluster = "tunnel",
    kind = "accept", title = "Senir's Observations", questID = 420,
    npc = "Mountaineer Thalos", x = 0.3348, y = 0.7184, pin = "npc", hubName = "Coldridge Pass",
    requiresQuest = { 282 }, requiresState = "turnedin",
    text = "He sends the notes on to Senir Whitebeard in Kharanos.",
    xp = 340, minutes = 1,
})

add({
    id = "A-dunmorogh-0106", order = 106, cluster = "tunnel",
    kind = "accept", title = "Supplies to Tannok", questID = 2160,
    npc = "Hands Springsprocket", x = 0.3385, y = 0.7224, pin = "npc", hubName = "Coldridge Pass",
    text = "Hands Springsprocket stands with Thalos. The crate goes to Tannok in Kharanos.",
    xp = 110, minutes = 1,
})

add({
    id = "A-dunmorogh-0107", order = 107, cluster = "kharanos",
    kind = "turnin", title = "Senir's Observations", questName = "Senir's Observations", questID = 420,
    npc = "Senir Whitebeard", x = 0.4673, y = 0.5383, pin = "npc", hubName = "Kharanos",
    requiresQuest = { 420 }, requiresState = "accepted",
    text = "Through Coldridge Pass. Senir is at the Kharanos entrance.",
    xp = 340, minutes = 6,
})

add({
    id = "A-dunmorogh-0108", order = 108, cluster = "kharanos",
    kind = "turnin", title = "Supplies to Tannok", questName = "Supplies to Tannok", questID = 2160,
    npc = "Tannok Frosthammer", x = 0.4722, y = 0.5220, pin = "npc", hubName = "Kharanos",
    requiresQuest = { 2160 }, requiresState = "accepted",
    text = "Tannok is inside the Thunderbrew Distillery.",
    xp = 110, minutes = 1,
})

add({
    id = "A-dunmorogh-0109", order = 109, cluster = "kharanos",
    kind = "hearth", title = "Set your hearth in Kharanos",
    npc = "Innkeeper Belm", x = 0.4738, y = 0.5252, pin = "npc",
    hubName = "Kharanos", bind = "Kharanos",
    text = "Innkeeper Belm is inside the distillery. Set your hearth there.",
    minutes = 1,
})

add({
    id = "A-dunmorogh-priest-5625", order = 110, cluster = "kharanos",
    kind = "accept", title = "Garments of the Light", questID = 5625,
    classQuest = true, classes = { Priest = true }, races = { Dwarf = true },
    npc = "Maxan Anvol", x = 0.4734, y = 0.5219, pin = "npc", hubName = "Kharanos",
    text = "Maxan Anvol is in the distillery. Heal Mountaineer Dolf, then fortify him.",
    xp = 360, minutes = 1,
})

add({
    id = "A-dunmorogh-priest-5625b", order = 111, cluster = "kharanos",
    kind = "objective", title = "Mountaineer Dolf", questName = "Garments of the Light",
    questID = 5625, objective = 1,
    classQuest = true, classes = { Priest = true }, races = { Dwarf = true },
    requiresQuest = { 5625 }, requiresState = "accepted",
    text = "Mountaineer Dolf is just outside Kharanos. Lesser Heal, then Power Word: Fortitude.",
    x = 0.4581, y = 0.5457, pin = "approx", minutes = 3,
})

add({
    id = "A-dunmorogh-priest-5625c", order = 112, cluster = "kharanos",
    kind = "turnin", title = "Garments of the Light", questName = "Garments of the Light", questID = 5625,
    classQuest = true, classes = { Priest = true }, races = { Dwarf = true },
    npc = "Maxan Anvol", x = 0.4734, y = 0.5219, pin = "npc", hubName = "Kharanos",
    requiresQuest = { 5625 }, requiresState = "accepted",
    text = "Back to Maxan Anvol.",
    xp = 360, minutes = 2,
})

local def = {
    routeName = "Dun Morogh priority route",
    stub = false,
    steps = steps,
}

QS.Registry.races.Alliance = QS.Registry.races.Alliance or {}
QS.Registry.races.Alliance.Dwarf = def
QS.Registry.races.Alliance.Gnome = def
