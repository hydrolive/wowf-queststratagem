-- Undead Deathknell through the Brill hearth, about level 1-6.
-- Quest ids are the Classic set (363, 364, 376, 3901, 3902, 380, 381,
-- 382, 383, 8, 6395, scrolls 3095-3099, warlock 1470).
-- Coordinates are the published Deathknell and Brill pins.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Tirisfal Glades"
    row.mapID = row.mapID or 1420
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "horde-tirisfal"
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

local MORDO = { x = 0.3022, y = 0.7165, npc = "Undertaker Mordo", hubName = "Deathknell" }
local SARVIS = { x = 0.3084, y = 0.6620, npc = "Shadow Priest Sarvis", hubName = "Deathknell" }
local ELRETH = { x = 0.3086, y = 0.6605, npc = "Novice Elreth", hubName = "Deathknell" }
local VENYA = { x = 0.3098, y = 0.6641, npc = "Venya Marthand", hubName = "Deathknell" }
local SALTAIN = { x = 0.3161, y = 0.6562, npc = "Deathguard Saltain", hubName = "Deathknell" }
local ARREN = { x = 0.3215, y = 0.6601, npc = "Executor Arren", hubName = "Deathknell" }

add(pin(MORDO, {
    id = "H-tirisfal-0001", order = 1, cluster = "crypt", starter = true,
    kind = "accept", title = "Rude Awakening", questID = 363,
    text = "You wake in the crypt. Undertaker Mordo sends you to the chapel.",
    xp = 40, minutes = 1, minLevel = 1,
}))

add(pin(SARVIS, {
    id = "H-tirisfal-0002", order = 2, cluster = "chapel", starter = true,
    kind = "turnin", title = "Rude Awakening", questName = "Rude Awakening", questID = 363,
    requiresQuest = { 363 }, requiresState = "accepted",
    text = "Follow the road down to the chapel. Shadow Priest Sarvis is inside.",
    xp = 40, minutes = 2,
}))

add(pin(SARVIS, {
    id = "H-tirisfal-0003", order = 3, cluster = "chapel", starter = true,
    kind = "accept", title = "The Mindless Ones", questID = 364,
    requiresQuest = { 363 }, requiresState = "turnedin",
    text = "Mindless Zombies and Wretched Ghouls just outside the chapel. Eight of each.",
    xp = 170, minutes = 1,
}))

add(pin(ELRETH, {
    id = "H-tirisfal-0004", order = 4, cluster = "chapel", starter = true,
    kind = "accept", title = "The Damned", questID = 376,
    text = "Novice Elreth stands with Sarvis. Scavenger paws and duskbat wings, 6 of each.",
    xp = 170, minutes = 1,
}))

add(pin(VENYA, {
    id = "H-tirisfal-warlock-1470", order = 5, cluster = "chapel", starter = true,
    kind = "accept", title = "Piercing the Veil", questID = 1470,
    classQuest = true, classes = { Warlock = true },
    text = "Venya Marthand is in the chapel. She wants Rattlecage skulls.",
    xp = 250, minutes = 1,
}))

add({
    id = "H-tirisfal-0006", order = 6, cluster = "graveyard", starter = true,
    kind = "objective", title = "Mindless Zombies and Wretched Ghouls", questName = "The Mindless Ones",
    questID = 364, requiresQuest = { 364 }, requiresState = "accepted",
    text = "Both wander the graveyard north of the chapel. Kill 8 of each.",
    x = 0.3329, y = 0.6496, pin = "approx", minutes = 5,
})

add({
    id = "H-tirisfal-warlock-skulls", order = 7, cluster = "graveyard", starter = true,
    kind = "objective", title = "Rattlecage Skulls", questName = "Piercing the Veil",
    questID = 1470, objective = 1,
    classQuest = true, classes = { Warlock = true },
    requiresQuest = { 1470 }, requiresState = "accepted",
    text = "Rattlecage Skeletons north of town. Bring 3 skulls to Venya.",
    x = 0.3301, y = 0.6301, pin = "approx", minutes = 4,
})

add(pin(VENYA, {
    id = "H-tirisfal-warlock-1470b", order = 8, cluster = "chapel", starter = true,
    kind = "turnin", title = "Piercing the Veil", questName = "Piercing the Veil", questID = 1470,
    classQuest = true, classes = { Warlock = true },
    requiresQuest = { 1470 }, requiresState = "accepted",
    text = "Skulls back to Venya Marthand. Summon your imp.",
    xp = 250, minutes = 2,
}))

add(pin(SARVIS, {
    id = "H-tirisfal-0009", order = 9, cluster = "chapel", starter = true,
    kind = "turnin", title = "The Mindless Ones", questName = "The Mindless Ones", questID = 364,
    requiresQuest = { 364 }, requiresState = "accepted",
    text = "Back to Shadow Priest Sarvis. He has your class scroll.",
    xp = 170, minutes = 2,
}))

local letters = {
    { id = "3095", questID = 3095, class = "Warrior", title = "Simple Scroll", npc = "Dannal Stern", x = 0.3268, y = 0.6556 },
    { id = "3096", questID = 3096, class = "Rogue", title = "Encrypted Scroll", npc = "David Trias", x = 0.3253, y = 0.6565 },
    { id = "3097", questID = 3097, class = "Priest", title = "Hallowed Scroll", npc = "Dark Cleric Duesten", x = 0.3111, y = 0.6602 },
    { id = "3098", questID = 3098, class = "Mage", title = "Glyphic Scroll", npc = "Isabella", x = 0.3094, y = 0.6606 },
    { id = "3099", questID = 3099, class = "Warlock", title = "Tainted Scroll", npc = "Maximillion", x = 0.3091, y = 0.6634 },
}

for i = 1, #letters do
    local letter = letters[i]
    local classes = {}
    classes[letter.class] = true
    add(pin(SARVIS, {
        id = "H-tirisfal-letter-" .. letter.id,
        order = 10 + i, cluster = "chapel", starter = true,
        kind = "accept", title = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { Undead = true },
        requiresQuest = { 364 }, requiresState = "turnedin",
        text = "Read it and speak to " .. letter.npc .. " in Deathknell.",
        xp = 40, minutes = 1,
    }))
    add({
        id = "H-tirisfal-train-" .. letter.id,
        order = 20 + i, cluster = "chapel", starter = true,
        kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { Undead = true },
        npc = letter.npc, x = letter.x, y = letter.y, pin = "npc",
        hubName = "Deathknell",
        requiresQuest = { letter.questID }, requiresState = "accepted",
        text = letter.npc .. " is in Deathknell. Train your first ranks.",
        xp = 40, minutes = 1,
    })
end

add({
    id = "H-tirisfal-paladin",
    order = 26, cluster = "chapel", starter = true,
    kind = "note", title = "Undead Paladin",
    classQuest = true, classes = { Paladin = true }, races = { Undead = true },
    always = true, confidence = "stub",
    npc = "Shadow Priest Sarvis", x = 0.3084, y = 0.6620, pin = "npc",
    text = "Classic has no Undead paladin scroll. Train in the chapel when Forever publishes the quest. Next leaves this note.",
    minutes = 2, source = "design-2026-10-06",
})

add(pin(SARVIS, {
    id = "H-tirisfal-0030", order = 30, cluster = "chapel", starter = true,
    kind = "accept", title = "Rattling the Rattlecages", questID = 3901,
    requiresQuest = { 364 }, requiresState = "turnedin",
    text = "Twelve Rattlecage Skeletons in the graveyard north of town.",
    xp = 250, minutes = 1,
}))

add({
    id = "H-tirisfal-0031", order = 31, cluster = "north-road", starter = true,
    kind = "objective", title = "Scavenger Paws and Duskbat Wings", questName = "The Damned",
    questID = 376, requiresQuest = { 376 }, requiresState = "accepted",
    text = "Young Scavengers and Duskbats are along the road north of Deathknell.",
    x = 0.3432, y = 0.5679, pin = "approx", minutes = 6,
})

add({
    id = "H-tirisfal-0032", order = 32, cluster = "graveyard", starter = true,
    kind = "objective", title = "Rattlecage Skeletons", questName = "Rattling the Rattlecages",
    questID = 3901, objective = 1,
    requiresQuest = { 3901 }, requiresState = "accepted",
    text = "The skeletons pace the north side of the graveyard.",
    x = 0.3301, y = 0.6301, pin = "approx", minutes = 5,
})

add(pin(SARVIS, {
    id = "H-tirisfal-0033", order = 33, cluster = "chapel", starter = true,
    kind = "turnin", title = "Rattling the Rattlecages", questName = "Rattling the Rattlecages",
    questID = 3901, requiresQuest = { 3901 }, requiresState = "accepted",
    text = "Back to Shadow Priest Sarvis.",
    xp = 250, minutes = 2,
}))

add(pin(ELRETH, {
    id = "H-tirisfal-0034", order = 34, cluster = "chapel", starter = true,
    kind = "turnin", title = "The Damned", questName = "The Damned", questID = 376,
    requiresQuest = { 376 }, requiresState = "accepted",
    text = "Paws and wings back to Novice Elreth.",
    xp = 170, minutes = 1,
}))

add(pin(ELRETH, {
    id = "H-tirisfal-0035", order = 35, cluster = "chapel", starter = true,
    kind = "accept", title = "Marla's Last Wish", questID = 6395,
    requiresQuest = { 376 }, requiresState = "turnedin",
    text = "Samuel Fipps is in the field north of town. Bury his remains at Marla's grave.",
    xp = 450, minutes = 1,
}))

add(pin(SALTAIN, {
    id = "H-tirisfal-0036", order = 36, cluster = "town", starter = true,
    kind = "accept", title = "Scavenging Deathknell", questID = 3902,
    text = "Deathguard Saltain wants 6 Scavenged Goods from the crates around town.",
    xp = 320, minutes = 1,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0037", order = 37, cluster = "town", starter = true,
    kind = "accept", title = "Night Web's Hollow", questID = 380,
    text = "Executor Arren wants the mine northwest of town cleared of spiders.",
    xp = 360, minutes = 1,
}))

add({
    id = "H-tirisfal-0038", order = 38, cluster = "town", starter = true,
    kind = "objective", title = "Scavenged Goods", questName = "Scavenging Deathknell",
    questID = 3902, objective = 1,
    requiresQuest = { 3902 }, requiresState = "accepted",
    text = "Equipment boxes sit around the Deathknell yards.",
    x = 0.3134, y = 0.6244, pin = "approx", minutes = 4,
})

add({
    id = "H-tirisfal-0039", order = 39, cluster = "mine", starter = true,
    kind = "objective", title = "Night Web Spiders", questName = "Night Web's Hollow",
    questID = 380, requiresQuest = { 380 }, requiresState = "accepted",
    text = "Ten young spiders outside the mine, then eight Night Web Spiders inside.",
    x = 0.2468, y = 0.5954, pin = "approx", minutes = 8,
})

add(pin(SALTAIN, {
    id = "H-tirisfal-0040", order = 40, cluster = "town", starter = true,
    kind = "turnin", title = "Scavenging Deathknell", questName = "Scavenging Deathknell",
    questID = 3902, requiresQuest = { 3902 }, requiresState = "accepted",
    text = "Crates back to Deathguard Saltain.",
    xp = 320, minutes = 2,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0041", order = 41, cluster = "town", starter = true,
    kind = "turnin", title = "Night Web's Hollow", questName = "Night Web's Hollow", questID = 380,
    requiresQuest = { 380 }, requiresState = "accepted",
    text = "Back to Executor Arren.",
    xp = 360, minutes = 2,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0042", order = 42, cluster = "town", starter = true,
    kind = "accept", title = "The Scarlet Crusade", questID = 381,
    requiresQuest = { 380 }, requiresState = "turnedin",
    text = "Scarlet initiates and converts at the camp east of Deathknell. Twelve armbands.",
    xp = 360, minutes = 1,
}))

add({
    id = "H-tirisfal-0043", order = 43, cluster = "scarlet", starter = true,
    kind = "objective", title = "Scarlet Armbands", questName = "The Scarlet Crusade",
    questID = 381, objective = 1,
    requiresQuest = { 381 }, requiresState = "accepted",
    text = "The Scarlet camp is east of Deathknell. Leave Meven Korgal for the next step.",
    x = 0.3693, y = 0.6816, pin = "approx", minutes = 6,
})

add({
    id = "H-tirisfal-0044", order = 44, cluster = "scarlet", starter = true,
    kind = "objective", title = "Samuel's Remains", questName = "Marla's Last Wish",
    questID = 6395, objective = 1,
    requiresQuest = { 6395 }, requiresState = "accepted",
    text = "Kill Samuel Fipps near 36.7, 61.7. Bury the remains at Marla's grave in town.",
    x = 0.3117, y = 0.6508, pin = "approx", minutes = 5,
})

add(pin(ELRETH, {
    id = "H-tirisfal-0045", order = 45, cluster = "chapel", starter = true,
    kind = "turnin", title = "Marla's Last Wish", questName = "Marla's Last Wish", questID = 6395,
    requiresQuest = { 6395 }, requiresState = "accepted",
    text = "Back to Novice Elreth.",
    xp = 450, minutes = 2,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0046", order = 46, cluster = "town", starter = true,
    kind = "turnin", title = "The Scarlet Crusade", questName = "The Scarlet Crusade", questID = 381,
    requiresQuest = { 381 }, requiresState = "accepted",
    text = "Armbands back to Executor Arren.",
    xp = 360, minutes = 2,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0047", order = 47, cluster = "town", starter = true,
    kind = "accept", title = "The Red Messenger", questID = 382,
    requiresQuest = { 381 }, requiresState = "turnedin",
    text = "Meven Korgal is in the same Scarlet camp. Bring his documents.",
    xp = 675, minutes = 1,
}))

add({
    id = "H-tirisfal-0048", order = 48, cluster = "scarlet", starter = true,
    kind = "objective", title = "Scarlet Crusade Documents", questName = "The Red Messenger",
    questID = 382, objective = 1,
    requiresQuest = { 382 }, requiresState = "accepted",
    text = "Meven Korgal stands in the Scarlet camp.",
    x = 0.3650, y = 0.6882, pin = "approx", minutes = 4,
})

add(pin(ARREN, {
    id = "H-tirisfal-0049", order = 49, cluster = "town", starter = true,
    kind = "turnin", title = "The Red Messenger", questName = "The Red Messenger", questID = 382,
    requiresQuest = { 382 }, requiresState = "accepted",
    text = "Documents back to Executor Arren.",
    xp = 675, minutes = 3,
}))

add(pin(ARREN, {
    id = "H-tirisfal-0050", order = 50, cluster = "town", starter = true,
    kind = "accept", title = "Vital Intelligence", questID = 383,
    requiresQuest = { 382 }, requiresState = "turnedin",
    text = "He sends you to Executor Zygand in Brill.",
    xp = 340, minutes = 1,
}))

add({
    id = "H-tirisfal-0051", order = 51, cluster = "road",
    kind = "accept", title = "A Rogue's Deal", questID = 8,
    npc = "Calvin Montague", x = 0.3824, y = 0.5677, pin = "npc", hubName = "the road to Brill",
    text = "Calvin Montague is on the road north of Deathknell. He sends a package to the Brill inn.",
    xp = 110, minutes = 2,
})

add({
    id = "H-tirisfal-0052", order = 52, cluster = "brill",
    kind = "turnin", title = "Vital Intelligence", questName = "Vital Intelligence", questID = 383,
    npc = "Executor Zygand", x = 0.6059, y = 0.5177, pin = "npc", hubName = "Brill",
    requiresQuest = { 383 }, requiresState = "accepted",
    text = "Brill. Executor Zygand is in the town square.",
    xp = 340, minutes = 6,
})

add({
    id = "H-tirisfal-0053", order = 53, cluster = "brill",
    kind = "hearth", title = "A Rogue's Deal", questName = "A Rogue's Deal", questID = 8,
    npc = "Innkeeper Renee", x = 0.6171, y = 0.5206, pin = "npc", hubName = "Brill",
    requiresQuest = { 8 }, requiresState = "accepted",
    text = "Brill inn. Set your hearth with Renee.",
    xp = 110, minutes = 2,
})

local def = {
    routeName = "Tirisfal priority route",
    stub = false,
    steps = steps,
}

QS.Registry.races.Horde = QS.Registry.races.Horde or {}
QS.Registry.races.Horde.Undead = def
