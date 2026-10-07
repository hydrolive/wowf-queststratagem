-- Night Elf Shadowglen through the Dolanaar hearth, about level 1-6.
-- Quest ids are the Classic set (456, 457, 4495, 3519, 458, 459, 3521,
-- 3522, 916, 917, 920, 921, 928, 2159, sigils 3116-3120).
-- Coordinates are the published Shadowglen and Dolanaar pins.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Teldrassil"
    row.mapID = row.mapID or 1438
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "alliance-teldrassil"
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

local ILTH = { x = 0.5870, y = 0.4427, npc = "Conservator Ilthalaine", hubName = "Shadowglen" }
local DIRANIA = { x = 0.6090, y = 0.4196, npc = "Dirania Silvershine", hubName = "Shadowglen" }
local MELITHAR = { x = 0.5992, y = 0.4247, npc = "Melithar Staghelm", hubName = "Shadowglen" }
local IVERRON = { x = 0.5459, y = 0.3299, npc = "Iverron", hubName = "Shadowglen" }
local TARIN = { x = 0.5790, y = 0.4510, npc = "Tarindrella", hubName = "Shadowglen" }
local GIL = { x = 0.5781, y = 0.4165, npc = "Gilshalan Windwalker", hubName = "Shadowglen" }
local TENARON = { x = 0.5906, y = 0.3945, npc = "Tenaron Stormgrip", hubName = "Aldrassil" }

add(pin(ILTH, {
    id = "A-teldrassil-0001", order = 1, cluster = "glen", starter = true,
    kind = "accept", title = "The Balance of Nature", questID = 456,
    text = "Conservator Ilthalaine is at the start of Shadowglen. Young nightsabers and young thistle boars.",
    xp = 170, minutes = 1, minLevel = 1,
}))

add({
    id = "A-teldrassil-0002", order = 2, cluster = "glen-beasts", starter = true,
    kind = "objective", title = "Young Nightsabers and Boars", questName = "The Balance of Nature",
    questID = 456, requiresQuest = { 456 }, requiresState = "accepted",
    text = "Kill 7 Young Nightsabers and 4 Young Thistle Boars around the glen.",
    x = 0.6200, y = 0.4260, pin = "approx", minutes = 5,
})

add(pin(DIRANIA, {
    id = "A-teldrassil-0003", order = 3, cluster = "glen", starter = true,
    kind = "accept", title = "A Good Friend", questID = 4495,
    text = "Dirania Silvershine asks you to check on Iverron, north in the glen.",
    xp = 40, minutes = 1,
}))

add(pin(MELITHAR, {
    id = "A-teldrassil-0004", order = 4, cluster = "glen", starter = true,
    kind = "accept", title = "The Woodland Protector", questID = 458,
    text = "Melithar Staghelm sends you to Tarindrella, just south.",
    xp = 40, minutes = 1,
}))

add(pin(ILTH, {
    id = "A-teldrassil-0005", order = 5, cluster = "glen", starter = true,
    kind = "turnin", title = "The Balance of Nature", questName = "The Balance of Nature", questID = 456,
    requiresQuest = { 456 }, requiresState = "accepted",
    text = "Back to Conservator Ilthalaine. He has your class sigil.",
    xp = 170, minutes = 2,
}))

add(pin(ILTH, {
    id = "A-teldrassil-0006", order = 6, cluster = "glen", starter = true,
    kind = "accept", title = "The Balance of Nature", questID = 457,
    requiresQuest = { 456 }, requiresState = "turnedin",
    text = "Now the larger beasts. 7 Mangy Nightsabers and 7 Thistle Boars, north of the tree.",
    xp = 250, minutes = 1,
}))

local letters = {
    { id = "3116", questID = 3116, class = "Warrior", title = "Simple Sigil", npc = "Alyissia", x = 0.5964, y = 0.3844 },
    { id = "3117", questID = 3117, class = "Hunter", title = "Etched Sigil", npc = "Ayanna Everstride", x = 0.5866, y = 0.4045 },
    { id = "3118", questID = 3118, class = "Rogue", title = "Encrypted Sigil", npc = "Frahun Shadewhisper", x = 0.5959, y = 0.3869 },
    { id = "3119", questID = 3119, class = "Priest", title = "Hallowed Sigil", npc = "Shanda", x = 0.5917, y = 0.4044 },
    { id = "3120", questID = 3120, class = "Druid", title = "Verdant Sigil", npc = "Mardant Strongoak", x = 0.5863, y = 0.4029 },
}

for i = 1, #letters do
    local letter = letters[i]
    local classes = {}
    classes[letter.class] = true
    add(pin(ILTH, {
        id = "A-teldrassil-letter-" .. letter.id,
        order = 10 + i, cluster = "glen", starter = true,
        kind = "accept", title = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { NightElf = true },
        requiresQuest = { 456 }, requiresState = "turnedin",
        text = "Read it and speak to " .. letter.npc .. " in Aldrassil.",
        xp = 40, minutes = 1,
    }))
    add({
        id = "A-teldrassil-train-" .. letter.id,
        order = 20 + i, cluster = "tree", starter = true,
        kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { NightElf = true },
        npc = letter.npc, x = letter.x, y = letter.y, pin = "npc",
        hubName = "Aldrassil",
        requiresQuest = { letter.questID }, requiresState = "accepted",
        text = letter.npc .. " is in the Aldrassil tree. Train your first ranks.",
        xp = 40, minutes = 2,
    })
end

add({
    id = "A-teldrassil-0030", order = 30, cluster = "glen-north", starter = true,
    kind = "objective", title = "Mangy Nightsabers and Thistle Boars", questName = "The Balance of Nature",
    questID = 457, requiresQuest = { 457 }, requiresState = "accepted",
    text = "The larger cats and boars are north, toward Iverron.",
    x = 0.5980, y = 0.3410, pin = "approx", minutes = 6,
})

add(pin(IVERRON, {
    id = "A-teldrassil-0031", order = 31, cluster = "glen-north", starter = true,
    kind = "turnin", title = "A Good Friend", questName = "A Good Friend", questID = 4495,
    requiresQuest = { 4495 }, requiresState = "accepted",
    text = "Iverron is poisoned, at the north end of Shadowglen.",
    xp = 40, minutes = 3,
}))

add(pin(IVERRON, {
    id = "A-teldrassil-0032", order = 32, cluster = "glen-north", starter = true,
    kind = "accept", title = "A Friend in Need", questID = 3519,
    requiresQuest = { 4495 }, requiresState = "turnedin",
    text = "He asks you to tell Dirania.",
    xp = 40, minutes = 1,
}))

add(pin(TARIN, {
    id = "A-teldrassil-0033", order = 33, cluster = "glen", starter = true,
    kind = "turnin", title = "The Woodland Protector", questName = "The Woodland Protector", questID = 458,
    requiresQuest = { 458 }, requiresState = "accepted",
    text = "Tarindrella is just south of Ilthalaine.",
    xp = 40, minutes = 2,
}))

add(pin(TARIN, {
    id = "A-teldrassil-0034", order = 34, cluster = "glen", starter = true,
    kind = "accept", title = "The Woodland Protector", questID = 459,
    requiresQuest = { 458 }, requiresState = "turnedin",
    text = "Grell and grellkin south of the glen carry fel moss. She wants 8.",
    xp = 250, minutes = 1,
}))

add(pin(ILTH, {
    id = "A-teldrassil-0035", order = 35, cluster = "glen", starter = true,
    kind = "turnin", title = "The Balance of Nature", questName = "The Balance of Nature", questID = 457,
    requiresQuest = { 457 }, requiresState = "accepted",
    text = "The second hunt turns in to Conservator Ilthalaine.",
    xp = 250, minutes = 2,
}))

add(pin(DIRANIA, {
    id = "A-teldrassil-0036", order = 36, cluster = "glen", starter = true,
    kind = "turnin", title = "A Friend in Need", questName = "A Friend in Need", questID = 3519,
    requiresQuest = { 3519 }, requiresState = "accepted",
    text = "Tell Dirania what happened to Iverron.",
    xp = 40, minutes = 2,
}))

add(pin(DIRANIA, {
    id = "A-teldrassil-0037", order = 37, cluster = "glen", starter = true,
    kind = "accept", title = "Iverron's Antidote", questID = 3521,
    requiresQuest = { 3519 }, requiresState = "turnedin",
    text = "Hyacinth mushrooms from grells, moonpetal lilies, and one webwood ichor.",
    xp = 450, minutes = 1,
}))

add(pin(GIL, {
    id = "A-teldrassil-0038", order = 38, cluster = "glen", starter = true,
    kind = "accept", title = "Webwood Venom", questID = 916,
    text = "Gilshalan Windwalker wants 10 Webwood Venom Sacs from the spiders north of here.",
    xp = 360, minutes = 1,
}))

add({
    id = "A-teldrassil-0039", order = 39, cluster = "lilies", starter = true,
    kind = "objective", title = "Moonpetal Lilies", questName = "Iverron's Antidote",
    questID = 3521, objective = 2,
    requiresQuest = { 3521 }, requiresState = "accepted",
    text = "The lilies grow on the ground north of Aldrassil. This is only the lilies.",
    x = 0.5795, y = 0.3820, pin = "approx", minutes = 3,
})

add({
    id = "A-teldrassil-0040", order = 40, cluster = "cave", starter = true,
    kind = "objective", title = "Webwood Venom Sacs", questName = "Webwood Venom",
    questID = 916, objective = 1,
    requiresQuest = { 916 }, requiresState = "accepted",
    text = "Webwood spiders north of Shadowglen. Ten venom sacs.",
    x = 0.5680, y = 0.3170, pin = "approx", minutes = 5,
})

add({
    id = "A-teldrassil-0040b", order = 41, cluster = "cave", starter = true,
    kind = "objective", title = "Webwood Ichor", questName = "Iverron's Antidote",
    questID = 3521, objective = 3,
    requiresQuest = { 3521 }, requiresState = "accepted",
    text = "The same spiders. One Webwood Ichor for the antidote.",
    x = 0.5680, y = 0.3170, pin = "approx", minutes = 2,
})

add({
    id = "A-teldrassil-0041", order = 42, cluster = "grells", starter = true,
    kind = "objective", title = "Fel Moss", questName = "The Woodland Protector",
    questID = 459, objective = 1,
    requiresQuest = { 459 }, requiresState = "accepted",
    text = "Grell and grellkin south of Shadowglen. Eight Fel Moss.",
    x = 0.5500, y = 0.4370, pin = "approx", minutes = 4,
})

add({
    id = "A-teldrassil-0041b", order = 43, cluster = "grells", starter = true,
    kind = "objective", title = "Hyacinth Mushrooms", questName = "Iverron's Antidote",
    questID = 3521, objective = 1,
    requiresQuest = { 3521 }, requiresState = "accepted",
    text = "The same grells drop Hyacinth Mushrooms. Seven for the antidote.",
    x = 0.5500, y = 0.4370, pin = "approx", minutes = 3,
})

add(pin(TARIN, {
    id = "A-teldrassil-0042", order = 42, cluster = "glen", starter = true,
    kind = "turnin", title = "The Woodland Protector", questName = "The Woodland Protector", questID = 459,
    requiresQuest = { 459 }, requiresState = "accepted",
    text = "Fel moss back to Tarindrella.",
    xp = 250, minutes = 2,
}))

add(pin(DIRANIA, {
    id = "A-teldrassil-0043", order = 43, cluster = "glen", starter = true,
    kind = "turnin", title = "Iverron's Antidote", questName = "Iverron's Antidote", questID = 3521,
    requiresQuest = { 3521 }, requiresState = "accepted",
    text = "The ingredients back to Dirania.",
    xp = 450, minutes = 2,
}))

add(pin(DIRANIA, {
    id = "A-teldrassil-0044", order = 44, cluster = "glen", starter = true,
    kind = "accept", title = "Iverron's Antidote", questID = 3522,
    requiresQuest = { 3521 }, requiresState = "turnedin",
    text = "She brews it. Take the antidote back to Iverron.",
    xp = 250, minutes = 1,
}))

add(pin(GIL, {
    id = "A-teldrassil-0045", order = 45, cluster = "glen", starter = true,
    kind = "turnin", title = "Webwood Venom", questName = "Webwood Venom", questID = 916,
    requiresQuest = { 916 }, requiresState = "accepted",
    text = "Sacs back to Gilshalan Windwalker.",
    xp = 360, minutes = 2,
}))

add(pin(GIL, {
    id = "A-teldrassil-0046", order = 46, cluster = "glen", starter = true,
    kind = "accept", title = "Webwood Egg", questID = 917,
    requiresQuest = { 916 }, requiresState = "turnedin",
    text = "A Webwood Egg is at the back of the same cave.",
    xp = 450, minutes = 1,
}))

add(pin(IVERRON, {
    id = "A-teldrassil-0047", order = 47, cluster = "glen-north", starter = true,
    kind = "turnin", title = "Iverron's Antidote", questName = "Iverron's Antidote", questID = 3522,
    requiresQuest = { 3522 }, requiresState = "accepted",
    text = "Antidote back to Iverron.",
    xp = 250, minutes = 3,
}))

add({
    id = "A-teldrassil-0048", order = 48, cluster = "cave", starter = true,
    kind = "objective", title = "Webwood Egg", questName = "Webwood Egg",
    questID = 917, objective = 1,
    requiresQuest = { 917 }, requiresState = "accepted",
    text = "The egg is on the ground at the back of Shadowthread Cave.",
    x = 0.5700, y = 0.2640, pin = "approx", minutes = 5,
})

add(pin(GIL, {
    id = "A-teldrassil-0049", order = 49, cluster = "glen", starter = true,
    kind = "turnin", title = "Webwood Egg", questName = "Webwood Egg", questID = 917,
    requiresQuest = { 917 }, requiresState = "accepted",
    text = "Egg back to Gilshalan.",
    xp = 450, minutes = 3,
}))

add(pin(GIL, {
    id = "A-teldrassil-0050", order = 50, cluster = "glen", starter = true,
    kind = "accept", title = "Tenaron's Summons", questID = 920,
    requiresQuest = { 917 }, requiresState = "turnedin",
    text = "Tenaron Stormgrip is at the top of the Aldrassil tree.",
    xp = 40, minutes = 1,
}))

add(pin(TENARON, {
    id = "A-teldrassil-0051", order = 51, cluster = "tree", starter = true,
    kind = "turnin", title = "Tenaron's Summons", questName = "Tenaron's Summons", questID = 920,
    requiresQuest = { 920 }, requiresState = "accepted",
    text = "Climb Aldrassil. Tenaron is at the top.",
    xp = 40, minutes = 2,
}))

add(pin(TENARON, {
    id = "A-teldrassil-0052", order = 52, cluster = "tree", starter = true,
    kind = "accept", title = "Crown of the Earth", questID = 921,
    requiresQuest = { 920 }, requiresState = "turnedin",
    text = "Fill the Crystal Phial at the moonwell north of Aldrassil.",
    xp = 250, minutes = 1,
}))

add({
    id = "A-teldrassil-0053", order = 53, cluster = "well", starter = true,
    kind = "objective", title = "Filled Crystal Phial", questName = "Crown of the Earth",
    questID = 921, objective = 1,
    requiresQuest = { 921 }, requiresState = "accepted",
    text = "Use the Crystal Phial at the moonwell.",
    x = 0.5990, y = 0.3300, pin = "approx", minutes = 3,
})

add(pin(TENARON, {
    id = "A-teldrassil-0054", order = 54, cluster = "tree", starter = true,
    kind = "turnin", title = "Crown of the Earth", questName = "Crown of the Earth", questID = 921,
    requiresQuest = { 921 }, requiresState = "accepted",
    text = "Filled phial back to Tenaron.",
    xp = 250, minutes = 2,
}))

add(pin(TENARON, {
    id = "A-teldrassil-0055", order = 55, cluster = "tree", starter = true,
    kind = "accept", title = "Crown of the Earth", questID = 928,
    requiresQuest = { 921 }, requiresState = "turnedin",
    text = "He sends the phial to Corithras Moonrage in Dolanaar.",
    xp = 340, minutes = 1,
}))

add({
    id = "A-teldrassil-0056", order = 56, cluster = "road",
    kind = "accept", title = "Dolanaar Delivery", questID = 2159,
    npc = "Porthannius", x = 0.6116, y = 0.4764, pin = "npc", hubName = "the road to Dolanaar",
    text = "Porthannius is on the road out of Shadowglen. The delivery goes to the Dolanaar inn.",
    xp = 110, minutes = 1,
})

add({
    id = "A-teldrassil-0057", order = 57, cluster = "dolanaar",
    kind = "hearth", title = "Dolanaar Delivery", questName = "Dolanaar Delivery", questID = 2159,
    npc = "Innkeeper Keldamyr", x = 0.5562, y = 0.5979, pin = "npc", hubName = "Dolanaar",
    requiresQuest = { 2159 }, requiresState = "accepted",
    text = "Dolanaar inn. Set your hearth with Keldamyr.",
    xp = 110, minutes = 5,
})

add({
    id = "A-teldrassil-0058", order = 58, cluster = "dolanaar",
    kind = "turnin", title = "Crown of the Earth", questName = "Crown of the Earth", questID = 928,
    npc = "Corithras Moonrage", x = 0.5614, y = 0.6171, pin = "npc", hubName = "Dolanaar",
    requiresQuest = { 928 }, requiresState = "accepted",
    text = "Corithras Moonrage is in Dolanaar, south of the inn.",
    xp = 340, minutes = 2,
})

local def = {
    routeName = "Teldrassil priority route",
    stub = false,
    steps = steps,
}

QS.Registry.races.Alliance = QS.Registry.races.Alliance or {}
QS.Registry.races.Alliance.NightElf = def
