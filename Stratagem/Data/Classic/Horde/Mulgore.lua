-- Tauren Camp Narache through the Bloodhoof hearth, about level 1-6.
-- Quest ids are the Classic set (747, 752, 753, 750, 755, 757, 780,
-- 3376, 781, 763, 1656, notes 3091-3094, shaman 1519-1521).
-- Coordinates are the published Camp Narache and Bloodhoof pins.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Mulgore"
    row.mapID = row.mapID or 1412
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "horde-mulgore"
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

local GRULL = { x = 0.4492, y = 0.7712, npc = "Grull Hawkwind", hubName = "Camp Narache" }
local CHIEF = { x = 0.4418, y = 0.7607, npc = "Chief Hawkwind", hubName = "Camp Narache" }
local MOTHER = { x = 0.5003, y = 0.8116, npc = "Greatmother Hawkwind", hubName = "Camp Narache" }
local SEER = { x = 0.4258, y = 0.9218, npc = "Seer Graytongue", hubName = "Red Cloud Mesa" }
local BRAVE = { x = 0.4467, y = 0.7668, npc = "Brave Windfeather", hubName = "Camp Narache" }
local RAVEN = { x = 0.4473, y = 0.7618, npc = "Seer Ravenfeather", hubName = "Camp Narache" }

add(pin(GRULL, {
    id = "H-mulgore-0001", order = 1, cluster = "narache", starter = true,
    kind = "accept", title = "The Hunt Begins", questID = 747,
    text = "Grull stands in Camp Narache. He wants plainstrider meat and feathers.",
    xp = 170, minutes = 1, minLevel = 1,
}))

add({
    id = "H-mulgore-0002", order = 2, cluster = "mesa-birds", starter = true,
    kind = "objective", title = "Plainstrider Meat and Feathers", questName = "The Hunt Begins",
    questID = 747, requiresQuest = { 747 }, requiresState = "accepted",
    text = "Plainstriders are east and south of camp. Bring back 7 meat and 7 feathers.",
    x = 0.4736, y = 0.8305, pin = "approx", minutes = 5,
})

add(pin(GRULL, {
    id = "H-mulgore-0003", order = 3, cluster = "narache", starter = true,
    kind = "turnin", title = "The Hunt Begins", questName = "The Hunt Begins", questID = 747,
    requiresQuest = { 747 }, requiresState = "accepted",
    text = "Meat and feathers back to Grull. He has your class note.",
    xp = 170, minutes = 2,
}))

local letters = {
    { id = "3091", questID = 3091, class = "Warrior", title = "Simple Note", npc = "Harutt Thunderhorn", x = 0.4402, y = 0.7614 },
    { id = "3092", questID = 3092, class = "Hunter", title = "Etched Note", npc = "Lanka Farshot", x = 0.4426, y = 0.7570 },
    { id = "3093", questID = 3093, class = "Shaman", title = "Rune-Inscribed Note", npc = "Meela Dawnstrider", x = 0.4501, y = 0.7595 },
    { id = "3094", questID = 3094, class = "Druid", title = "Verdant Note", npc = "Gart Mistrunner", x = 0.4509, y = 0.7593 },
}

for i = 1, #letters do
    local letter = letters[i]
    local classes = {}
    classes[letter.class] = true
    add(pin(GRULL, {
        id = "H-mulgore-letter-" .. letter.id,
        order = 10 + i, cluster = "narache", starter = true,
        kind = "accept", title = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { Tauren = true },
        requiresQuest = { 747 }, requiresState = "turnedin",
        text = "Read it and speak to " .. letter.npc .. " in Camp Narache.",
        xp = 40, minutes = 1,
    }))
    add({
        id = "H-mulgore-train-" .. letter.id,
        order = 20 + i, cluster = "narache", starter = true,
        kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
        classQuest = true, classes = classes, races = { Tauren = true },
        npc = letter.npc, x = letter.x, y = letter.y, pin = "npc",
        hubName = "Camp Narache",
        requiresQuest = { letter.questID }, requiresState = "accepted",
        text = letter.npc .. " is in Camp Narache. Train your first ranks.",
        xp = 40, minutes = 1,
    })
end

add(pin(GRULL, {
    id = "H-mulgore-0030", order = 30, cluster = "narache", starter = true,
    kind = "accept", title = "The Hunt Continues", questID = 750,
    requiresQuest = { 747 }, requiresState = "turnedin",
    text = "Mountain cougars on the south end of the mesa. He wants 10 pelts.",
    xp = 250, minutes = 1,
}))

add(pin(CHIEF, {
    id = "H-mulgore-0031", order = 31, cluster = "narache", starter = true,
    kind = "accept", title = "A Humble Task", questID = 752,
    text = "Chief Hawkwind is in the tent. He sends you to Greatmother Hawkwind.",
    xp = 40, minutes = 1,
}))

add(pin(MOTHER, {
    id = "H-mulgore-0032", order = 32, cluster = "well", starter = true,
    kind = "turnin", title = "A Humble Task", questName = "A Humble Task", questID = 752,
    requiresQuest = { 752 }, requiresState = "accepted",
    text = "Greatmother Hawkwind is east of camp, by the well.",
    xp = 40, minutes = 2,
}))

add(pin(MOTHER, {
    id = "H-mulgore-0033", order = 33, cluster = "well", starter = true,
    kind = "accept", title = "A Humble Task", questID = 753, questName = "A Humble Task",
    requiresQuest = { 752 }, requiresState = "turnedin",
    text = "She wants the water pitcher from the well behind her.",
    xp = 170, minutes = 1,
}))

add({
    id = "H-mulgore-0034", order = 34, cluster = "well", starter = true,
    kind = "objective", title = "Water Pitcher", questName = "A Humble Task",
    questID = 753, objective = 1,
    requiresQuest = { 753 }, requiresState = "accepted",
    text = "The pitcher is on the well just behind Greatmother Hawkwind.",
    x = 0.5022, y = 0.8137, pin = "approx", minutes = 1,
})

add(pin(CHIEF, {
    id = "H-mulgore-0035", order = 35, cluster = "narache", starter = true,
    kind = "turnin", title = "A Humble Task", questName = "A Humble Task", questID = 753,
    requiresQuest = { 753 }, requiresState = "accepted",
    text = "Pitcher back to Chief Hawkwind.",
    xp = 170, minutes = 2,
}))

add(pin(CHIEF, {
    id = "H-mulgore-0036", order = 36, cluster = "narache", starter = true,
    kind = "accept", title = "Rites of the Earthmother", questID = 755,
    requiresQuest = { 753 }, requiresState = "turnedin",
    text = "He sends you to Seer Graytongue, at the south end of the mesa.",
    xp = 85, minutes = 1,
}))

add({
    id = "H-mulgore-0037", order = 37, cluster = "mesa-south", starter = true,
    kind = "objective", title = "Mountain Cougar Pelts", questName = "The Hunt Continues",
    questID = 750, objective = 1,
    requiresQuest = { 750 }, requiresState = "accepted",
    text = "Mountain cougars are on the way south to Seer Graytongue.",
    x = 0.4460, y = 0.9086, pin = "approx", minutes = 6,
})

add(pin(SEER, {
    id = "H-mulgore-0038", order = 38, cluster = "mesa-south", starter = true,
    kind = "turnin", title = "Rites of the Earthmother", questName = "Rites of the Earthmother",
    questID = 755, requiresQuest = { 755 }, requiresState = "accepted",
    text = "Seer Graytongue is at the south edge of Red Cloud Mesa.",
    xp = 85, minutes = 3,
}))

add(pin(SEER, {
    id = "H-mulgore-0039", order = 39, cluster = "mesa-south", starter = true,
    kind = "accept", title = "Rite of Strength", questID = 757,
    requiresQuest = { 755 }, requiresState = "turnedin",
    text = "Bristleback quilboars in Brambleblade Ravine. He wants 12 belts.",
    xp = 450, minutes = 1,
}))

add(pin(GRULL, {
    id = "H-mulgore-0040", order = 40, cluster = "narache", starter = true,
    kind = "turnin", title = "The Hunt Continues", questName = "The Hunt Continues",
    questID = 750, requiresQuest = { 750 }, requiresState = "accepted",
    text = "Pelts back to Grull.",
    xp = 250, minutes = 3,
}))

add(pin(GRULL, {
    id = "H-mulgore-0041", order = 41, cluster = "narache", starter = true,
    kind = "accept", title = "The Battleboars", questID = 780,
    requiresQuest = { 750 }, requiresState = "turnedin",
    text = "Battleboars east of camp. Snouts and flanks, 8 of each.",
    xp = 450, minutes = 1,
}))

add(pin(BRAVE, {
    id = "H-mulgore-0042", order = 42, cluster = "narache", starter = true,
    kind = "accept", title = "Break Sharptusk!", questID = 3376,
    text = "Brave Windfeather patrols the camp. Chief Sharptusk Thornmantle is in the ravine.",
    xp = 675, minutes = 1,
}))

add(pin(RAVEN, {
    id = "H-mulgore-shaman-1519", order = 43, cluster = "narache", starter = true,
    kind = "accept", title = "Call of Earth", questID = 1519,
    classQuest = true, classes = { Shaman = true },
    text = "Seer Ravenfeather wants two Ritual Salves from Bristleback Shamans.",
    xp = 250, minutes = 1,
}))

add({
    id = "H-mulgore-0044", order = 44, cluster = "boars", starter = true,
    kind = "objective", title = "Battleboar Snouts and Flanks", questName = "The Battleboars",
    questID = 780, requiresQuest = { 780 }, requiresState = "accepted",
    text = "Battleboars are east of Camp Narache, before the ravine.",
    x = 0.5599, y = 0.8546, pin = "approx", minutes = 6,
})

add({
    id = "H-mulgore-0045", order = 45, cluster = "ravine", starter = true,
    kind = "objective", title = "Chief Sharptusk Thornmantle", questName = "Break Sharptusk!",
    questID = 3376, objective = 1,
    requiresQuest = { 3376 }, requiresState = "accepted",
    text = "His hut is in Brambleblade Ravine. Bring the head back.",
    x = 0.6471, y = 0.7767, pin = "approx", minutes = 5,
})

add({
    id = "H-mulgore-0046", order = 46, cluster = "ravine", starter = true,
    kind = "accept", title = "Attack on Camp Narache", questID = 781,
    text = "The Dirt-stained Map is on the ground in the ravine cave. Use it.",
    x = 0.6324, y = 0.8270, pin = "approx", minutes = 1,
})

add({
    id = "H-mulgore-0047", order = 47, cluster = "ravine", starter = true,
    kind = "objective", title = "Bristleback Belts", questName = "Rite of Strength",
    questID = 757, objective = 1,
    requiresQuest = { 757 }, requiresState = "accepted",
    text = "Bristleback quilboars in the ravine. Collect 12 belts.",
    x = 0.6393, y = 0.7834, pin = "approx", minutes = 8,
})

add({
    id = "H-mulgore-shaman-salve", order = 48, cluster = "ravine", starter = true,
    kind = "objective", title = "Ritual Salve", questName = "Call of Earth",
    questID = 1519, objective = 1,
    classQuest = true, classes = { Shaman = true },
    requiresQuest = { 1519 }, requiresState = "accepted",
    text = "Bristleback Shamans in the ravine carry the salve.",
    x = 0.6386, y = 0.8014, pin = "approx", minutes = 4,
})

add(pin(GRULL, {
    id = "H-mulgore-0049", order = 49, cluster = "narache", starter = true,
    kind = "turnin", title = "The Battleboars", questName = "The Battleboars", questID = 780,
    requiresQuest = { 780 }, requiresState = "accepted",
    text = "Snouts and flanks back to Grull.",
    xp = 450, minutes = 2,
}))

add(pin(BRAVE, {
    id = "H-mulgore-0050", order = 50, cluster = "narache", starter = true,
    kind = "turnin", title = "Break Sharptusk!", questName = "Break Sharptusk!", questID = 3376,
    requiresQuest = { 3376 }, requiresState = "accepted",
    text = "Head back to Brave Windfeather. She walks the camp.",
    xp = 675, minutes = 2,
}))

add(pin(RAVEN, {
    id = "H-mulgore-shaman-1519b", order = 51, cluster = "narache", starter = true,
    kind = "turnin", title = "Call of Earth", questName = "Call of Earth", questID = 1519,
    classQuest = true, classes = { Shaman = true },
    requiresQuest = { 1519 }, requiresState = "accepted",
    text = "Salves back to Seer Ravenfeather.",
    xp = 250, minutes = 1,
}))

add(pin(RAVEN, {
    id = "H-mulgore-shaman-1520", order = 52, cluster = "narache", starter = true,
    kind = "accept", title = "Call of Earth", questID = 1520, questName = "Call of Earth",
    classQuest = true, classes = { Shaman = true },
    requiresQuest = { 1519 }, requiresState = "turnedin",
    text = "She gives you an Earth Sapta. Use it at the rock southeast of camp.",
    xp = 40, minutes = 1,
}))

add({
    id = "H-mulgore-shaman-1520b", order = 53, cluster = "rock", starter = true,
    kind = "turnin", title = "Call of Earth", questName = "Call of Earth", questID = 1520,
    classQuest = true, classes = { Shaman = true },
    npc = "Minor Manifestation of Earth", x = 0.5374, y = 0.8015, pin = "npc",
    requiresQuest = { 1520 }, requiresState = "accepted",
    text = "Use the Earth Sapta at the rock, then speak to the manifestation.",
    xp = 40, minutes = 4,
})

add({
    id = "H-mulgore-shaman-1521", order = 54, cluster = "rock", starter = true,
    kind = "accept", title = "Call of Earth", questID = 1521, questName = "Call of Earth",
    classQuest = true, classes = { Shaman = true },
    npc = "Minor Manifestation of Earth", x = 0.5374, y = 0.8015, pin = "npc",
    requiresQuest = { 1520 }, requiresState = "turnedin",
    text = "The manifestation sends you back to Seer Ravenfeather.",
    xp = 450, minutes = 1,
})

add(pin(RAVEN, {
    id = "H-mulgore-shaman-1521b", order = 55, cluster = "narache", starter = true,
    kind = "turnin", title = "Call of Earth", questName = "Call of Earth", questID = 1521,
    classQuest = true, classes = { Shaman = true },
    requiresQuest = { 1521 }, requiresState = "accepted",
    text = "Back to Seer Ravenfeather.",
    xp = 450, minutes = 3,
}))

add(pin(CHIEF, {
    id = "H-mulgore-0056", order = 56, cluster = "narache", starter = true,
    kind = "turnin", title = "Attack on Camp Narache", questName = "Attack on Camp Narache",
    questID = 781, requiresQuest = { 781 }, requiresState = "accepted",
    text = "The map turns in to Chief Hawkwind.",
    xp = 360, minutes = 1,
}))

add(pin(CHIEF, {
    id = "H-mulgore-0057", order = 57, cluster = "narache", starter = true,
    kind = "turnin", title = "Rite of Strength", questName = "Rite of Strength", questID = 757,
    requiresQuest = { 757 }, requiresState = "accepted",
    text = "Belts back to Chief Hawkwind.",
    xp = 450, minutes = 1,
}))

add(pin(CHIEF, {
    id = "H-mulgore-0058", order = 58, cluster = "narache", starter = true,
    kind = "accept", title = "Rites of the Earthmother", questID = 763,
    requiresQuest = { 757 }, requiresState = "turnedin",
    text = "Take the totem to Baine Bloodhoof in Bloodhoof Village.",
    xp = 340, minutes = 1,
}))

add({
    id = "H-mulgore-0059", order = 59, cluster = "mesa-exit",
    kind = "accept", title = "A Task Unfinished", questID = 1656,
    npc = "Antur Fallow", x = 0.3851, y = 0.8154, pin = "npc", hubName = "the mesa road",
    text = "Antur Fallow is on the road down from Red Cloud Mesa. He sends a bundle to the Bloodhoof inn.",
    xp = 230, minutes = 1,
})

add({
    id = "H-mulgore-0060", order = 60, cluster = "bloodhoof",
    kind = "turnin", title = "Rites of the Earthmother", questName = "Rites of the Earthmother",
    questID = 763, npc = "Baine Bloodhoof", x = 0.4751, y = 0.6016, pin = "npc",
    hubName = "Bloodhoof Village",
    requiresQuest = { 763 }, requiresState = "accepted",
    text = "Bloodhoof Village. Baine is in the main tent.",
    xp = 340, minutes = 6,
})

add({
    id = "H-mulgore-0061", order = 61, cluster = "bloodhoof",
    kind = "hearth", title = "A Task Unfinished", questName = "A Task Unfinished", questID = 1656,
    npc = "Innkeeper Kauth", x = 0.4663, y = 0.6109, pin = "npc",
    hubName = "Bloodhoof Village",
    requiresQuest = { 1656 }, requiresState = "accepted",
    text = "Bloodhoof inn. Set your hearth with Kauth.",
    xp = 230, minutes = 2,
})

local def = {
    routeName = "Mulgore priority route",
    stub = false,
    steps = steps,
}

QS.Registry.races.Horde = QS.Registry.races.Horde or {}
QS.Registry.races.Horde.Tauren = def
