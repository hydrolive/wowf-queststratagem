-- Human Elwynn, about level 1-6.
-- Quest ids: Wowhead Classic (783, 7, 15, 21, 18, 6, 5261, 33, 3903, 54,
-- 3100-3105, and the Goldshire follow-ups below). Coordinates are the
-- published Northshire / Goldshire pins, so the arrow says npc or approx.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local steps = {}
local function add(row)
    row.zone = row.zone or "Elwynn Forest"
    row.mapID = row.mapID or 1429
    row.source = row.source or "wowhead-classic"
    row.confidence = row.confidence or "verified"
    row.chain = row.chain or "human-elwynn"
    if not row.pin then
        row.pin = row.npc and "npc" or "approx"
    end
    steps[#steps + 1] = row
end

local WILLEM = { x = 0.4817, y = 0.4294, npc = "Deputy Willem", npcID = 823, hubName = "Northshire Abbey" }
local MCBRIDE = { x = 0.4892, y = 0.4161, npc = "Marshal McBride", npcID = 197, hubName = "Northshire Abbey" }
local EAGAN = { x = 0.4894, y = 0.4016, npc = "Eagan Peltskinner", hubName = "Northshire Abbey" }

local function pin(base, extra)
    for k, v in pairs(base) do
        if extra[k] == nil then
            extra[k] = v
        end
    end
    return extra
end

add(pin(WILLEM, {
    id = "A-human-elwynn-0001", order = 1, cluster = "ns-door", starter = true,
    kind = "accept", title = "A Threat Within", questID = 783,
    text = "Outside the abbey door. He sends you in to Marshal McBride.",
    xp = 40, minutes = 1, minLevel = 1,
}))

add(pin(WILLEM, {
    id = "A-human-elwynn-0002", order = 2, cluster = "ns-door", starter = true,
    kind = "accept", title = "Eagan Peltskinner", questID = 5261,
    text = "Same deputy. Eagan is just north of the door, by the wolves.",
    xp = 85, minutes = 1, minLevel = 1,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0003", order = 3, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "A Threat Within", questName = "A Threat Within", questID = 783,
    requiresQuest = { 783 }, requiresState = "accepted",
    text = "Inside the abbey, at the end of the hall.",
    xp = 40, minutes = 1,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0004", order = 4, cluster = "ns-abbey", starter = true,
    kind = "accept", title = "Kobold Camp Cleanup", questID = 7,
    requiresQuest = { 783 }, requiresState = "turnedin",
    text = "McBride's first kill order. The camp is north of the abbey.",
    xp = 170, minutes = 1, minLevel = 1,
}))

add(pin(EAGAN, {
    id = "A-human-elwynn-0005", order = 5, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Eagan Peltskinner", questName = "Eagan Peltskinner", questID = 5261,
    requiresQuest = { 5261 }, requiresState = "accepted",
    text = "North of the abbey door.",
    xp = 85, minutes = 1,
}))

add(pin(EAGAN, {
    id = "A-human-elwynn-0006", order = 6, cluster = "ns-abbey", starter = true,
    kind = "accept", title = "Wolves Across the Border", questID = 33,
    requiresQuest = { 5261 }, requiresState = "turnedin",
    text = "He wants tough wolf meat from the wolves beside him.",
    xp = 170, minutes = 1,
}))

add({
    id = "A-human-elwynn-0007", order = 7, cluster = "ns-camp", starter = true,
    kind = "objective", title = "Kobold Vermin", questName = "Kobold Camp Cleanup",
    questID = 7, objective = 1,
    requiresQuest = { 7 }, requiresState = "accepted",
    text = "Camp north of the abbey. Kill kobold vermin. Workers do not count.",
    x = 0.493, y = 0.352, pin = "approx", xp = 0, minutes = 4,
})

add({
    id = "A-human-elwynn-0008", order = 8, cluster = "ns-camp", starter = true,
    kind = "objective", title = "Tough Wolf Meat", questName = "Wolves Across the Border",
    questID = 33, objective = 1,
    requiresQuest = { 33 }, requiresState = "accepted",
    text = "Wolves between Eagan and the kobold camp.",
    x = 0.488, y = 0.378, pin = "approx", xp = 0, minutes = 3,
})

add(pin(EAGAN, {
    id = "A-human-elwynn-0009", order = 9, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Wolves Across the Border", questName = "Wolves Across the Border",
    questID = 33, requiresQuest = { 33 }, requiresState = "accepted",
    text = "Back to Eagan with the meat.",
    xp = 170, minutes = 1,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0010", order = 10, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Kobold Camp Cleanup", questName = "Kobold Camp Cleanup",
    questID = 7, requiresQuest = { 7 }, requiresState = "accepted",
    text = "Back to McBride. He hands you the next kobold order and your class letter.",
    xp = 170, minutes = 1,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0011", order = 11, cluster = "ns-abbey", starter = true,
    kind = "accept", title = "Investigate Echo Ridge", questID = 15,
    requiresQuest = { 7 }, requiresState = "turnedin",
    text = "Kobold workers in Echo Ridge Mine, north end of the valley.",
    xp = 250, minutes = 1,
}))

local letters = {
    { id = "0012", questID = 3100, class = "Warrior", title = "Simple Letter", npc = "Llane Beshere", x = 0.502, y = 0.422 },
    { id = "0013", questID = 3101, class = "Paladin", title = "Consecrated Letter", npc = "Brother Sammuel", x = 0.504, y = 0.421 },
    { id = "0014", questID = 3102, class = "Rogue", title = "Encrypted Letter", npc = "Jorik Kerridan", x = 0.503, y = 0.399 },
    { id = "0015", questID = 3103, class = "Priest", title = "Hallowed Letter", npc = "Priestess Anetta", x = 0.498, y = 0.395 },
    { id = "0016", questID = 3104, class = "Mage", title = "Glyphic Letter", npc = "Khelden Bremen", x = 0.497, y = 0.395 },
    { id = "0017", questID = 3105, class = "Warlock", title = "Tainted Letter", npc = "Drusilla La Salle", x = 0.499, y = 0.426 },
}
for i = 1, #letters do
    local letter = letters[i]
    local classSet = {}
    classSet[letter.class] = true
    add(pin(MCBRIDE, {
        id = "A-human-elwynn-" .. letter.id,
        order = 11 + i, cluster = "ns-abbey", starter = true,
        kind = "accept", title = letter.title, questID = letter.questID,
        classQuest = true, classes = classSet,
        requiresQuest = { 7 }, requiresState = "turnedin",
        text = "Read it and speak to " .. letter.npc .. ".",
        xp = 40, minutes = 1,
    }))
    add({
        id = "A-human-elwynn-" .. letter.id .. "b",
        order = 18 + i, cluster = "ns-abbey", starter = true,
        kind = "train", title = letter.title, questName = letter.title, questID = letter.questID,
        classQuest = true, classes = classSet,
        npc = letter.npc, x = letter.x, y = letter.y, pin = "npc",
        requiresQuest = { letter.questID }, requiresState = "accepted",
        text = "Train your first ranks, then get back outside.",
        xp = 40, minutes = 1, hubName = "Northshire Abbey",
    })
end

add({
    id = "A-human-elwynn-hunter",
    order = 30, cluster = "ns-abbey", starter = true,
    kind = "note", title = "Human Hunter",
    classQuest = true, classes = { Hunter = true },
    always = true, confidence = "stub",
    npc = "Marshal McBride", x = 0.4892, y = 0.4161, pin = "npc",
    text = "Classic has no Human hunter letter. Train when Forever publishes the quest. Next leaves this note.",
    minutes = 2, xp = 0, source = "design-2026-10-05",
})

add(pin(WILLEM, {
    id = "A-human-elwynn-0031", order = 31, cluster = "ns-door", starter = true,
    kind = "accept", title = "Brotherhood of Thieves", questID = 18,
    requiresQuest = { 783 }, requiresState = "turnedin",
    text = "Defias in the vineyard east of the abbey. They carry red bandanas.",
    xp = 360, minutes = 1,
}))

add(pin(WILLEM, {
    id = "A-human-elwynn-0032", order = 32, cluster = "ns-door", starter = true,
    kind = "accept", title = "Milly Osworth", questID = 3903, noBatch = true,
    text = "Willem points you at Milly in the vineyard.",
    xp = 40, minutes = 1,
}))

add({
    id = "A-human-elwynn-0033", order = 33, cluster = "ns-vine", starter = true,
    kind = "turnin", title = "Milly Osworth", questName = "Milly Osworth", questID = 3903,
    npc = "Milly Osworth", x = 0.541, y = 0.486, pin = "npc",
    requiresQuest = { 3903 }, requiresState = "accepted",
    text = "Milly is in the Northshire vineyard.",
    xp = 40, minutes = 2,
})

add({
    id = "A-human-elwynn-0034", order = 34, cluster = "ns-vine", starter = true,
    kind = "accept", title = "Milly's Harvest", questID = 3904,
    npc = "Milly Osworth", x = 0.541, y = 0.486, pin = "npc", hubName = "Northshire Vineyard",
    requiresQuest = { 3903 }, requiresState = "turnedin",
    text = "Grape crates in the garden around her.",
    xp = 180, minutes = 1,
})

add({
    id = "A-human-elwynn-0035", order = 35, cluster = "ns-vine", starter = true,
    kind = "objective", title = "Harvest the Grapes", questName = "Milly's Harvest",
    questID = 3904, objective = 1,
    requiresQuest = { 3904 }, requiresState = "accepted",
    text = "Crates in the vineyard around Milly.",
    x = 0.540, y = 0.490, pin = "approx", minutes = 3,
})

add({
    id = "A-human-elwynn-0036", order = 36, cluster = "ns-vine", starter = true,
    kind = "objective", title = "Red Burlap Bandanas", questName = "Brotherhood of Thieves",
    questID = 18, objective = 1,
    requiresQuest = { 18 }, requiresState = "accepted",
    text = "Defias thieves in the same vineyard.",
    x = 0.545, y = 0.468, pin = "approx", minutes = 5,
})

add({
    id = "A-human-elwynn-0037", order = 37, cluster = "ns-vine", starter = true,
    kind = "turnin", title = "Milly's Harvest", questName = "Milly's Harvest", questID = 3904,
    npc = "Milly Osworth", x = 0.541, y = 0.486, pin = "npc",
    requiresQuest = { 3904 }, requiresState = "accepted",
    text = "Back to Milly.",
    xp = 180, minutes = 1,
})

add({
    id = "A-human-elwynn-0038", order = 38, cluster = "ns-vine", starter = true,
    kind = "accept", title = "Grape Manifest", questID = 3905,
    npc = "Milly Osworth", x = 0.541, y = 0.486, pin = "npc",
    requiresQuest = { 3904 }, requiresState = "turnedin",
    text = "She sends the manifest to Brother Neals in the abbey.",
    xp = 360, minutes = 1,
})

add({
    id = "A-human-elwynn-0039", order = 39, cluster = "ns-mine", starter = true,
    kind = "objective", title = "Kobold Workers", questName = "Investigate Echo Ridge",
    questID = 15, objective = 1,
    requiresQuest = { 15 }, requiresState = "accepted",
    text = "Echo Ridge Mine at the north end of the valley. Workers are inside.",
    x = 0.482, y = 0.308, pin = "approx", minutes = 5,
})

add(pin(WILLEM, {
    id = "A-human-elwynn-0040", order = 40, cluster = "ns-door", starter = true,
    kind = "turnin", title = "Brotherhood of Thieves", questName = "Brotherhood of Thieves",
    questID = 18, requiresQuest = { 18 }, requiresState = "accepted",
    text = "Bandanas back to Deputy Willem.",
    xp = 360, minutes = 2,
}))

add(pin(WILLEM, {
    id = "A-human-elwynn-0041", order = 41, cluster = "ns-door", starter = true,
    kind = "accept", title = "Bounty on Garrick Padfoot", questID = 6,
    requiresQuest = { 18 }, requiresState = "turnedin",
    text = "Garrick is at the far side of the vineyard.",
    xp = 340, minutes = 1,
}))

add({
    id = "A-human-elwynn-0042", order = 42, cluster = "ns-vine", starter = true,
    kind = "objective", title = "Garrick Padfoot", questName = "Bounty on Garrick Padfoot",
    questID = 6, objective = 1,
    requiresQuest = { 6 }, requiresState = "accepted",
    text = "East end of the vineyard. Take his head.",
    x = 0.575, y = 0.483, pin = "approx", minutes = 4,
})

add(pin(WILLEM, {
    id = "A-human-elwynn-0043", order = 43, cluster = "ns-door", starter = true,
    kind = "turnin", title = "Bounty on Garrick Padfoot", questName = "Bounty on Garrick Padfoot",
    questID = 6, requiresQuest = { 6 }, requiresState = "accepted",
    text = "Head back to Deputy Willem.",
    xp = 340, minutes = 2,
}))

add({
    id = "A-human-elwynn-0044", order = 44, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Grape Manifest", questName = "Grape Manifest", questID = 3905,
    npc = "Brother Neals", x = 0.496, y = 0.402, pin = "npc",
    requiresQuest = { 3905 }, requiresState = "accepted",
    text = "Brother Neals is inside the abbey.",
    xp = 360, minutes = 2,
})

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0045", order = 45, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Investigate Echo Ridge", questName = "Investigate Echo Ridge",
    questID = 15, requiresQuest = { 15 }, requiresState = "accepted",
    text = "Workers done. McBride sends you back for the laborers.",
    xp = 250, minutes = 2,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0046", order = 46, cluster = "ns-abbey", starter = true,
    kind = "accept", title = "Skirmish at Echo Ridge", questID = 21,
    requiresQuest = { 15 }, requiresState = "turnedin",
    text = "Kobold laborers, deeper in the same mine.",
    xp = 450, minutes = 1,
}))

add({
    id = "A-human-elwynn-0047", order = 47, cluster = "ns-mine", starter = true,
    kind = "objective", title = "Kobold Laborers", questName = "Skirmish at Echo Ridge",
    questID = 21, objective = 1,
    requiresQuest = { 21 }, requiresState = "accepted",
    text = "Deeper in Echo Ridge Mine.",
    x = 0.478, y = 0.292, pin = "approx", minutes = 6,
})

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0048", order = 48, cluster = "ns-abbey", starter = true,
    kind = "turnin", title = "Skirmish at Echo Ridge", questName = "Skirmish at Echo Ridge",
    questID = 21, requiresQuest = { 21 }, requiresState = "accepted",
    text = "Last Northshire turn-in. He sends you to Goldshire.",
    xp = 450, minutes = 2,
}))

add(pin(MCBRIDE, {
    id = "A-human-elwynn-0049", order = 49, cluster = "ns-abbey", starter = true,
    kind = "accept", title = "Report to Goldshire", questID = 54,
    requiresQuest = { 21 }, requiresState = "turnedin",
    text = "Marshal Dughan, in Goldshire.",
    xp = 230, minutes = 1,
}))

add({
    id = "A-human-elwynn-0050", order = 50, cluster = "goldshire-road",
    kind = "accept", title = "Rest and Relaxation", questID = 2158,
    npc = "Falkhaan Isenstrider", x = 0.456, y = 0.477, pin = "npc",
    hubName = "the Goldshire road",
    text = "On the road south of Northshire. He sends you to the inn.",
    xp = 25, minutes = 1,
})

add({
    id = "A-human-elwynn-0051", order = 51, cluster = "goldshire",
    kind = "turnin", title = "Report to Goldshire", questName = "Report to Goldshire", questID = 54,
    npc = "Marshal Dughan", x = 0.421, y = 0.659, pin = "npc",
    requiresQuest = { 54 }, requiresState = "accepted",
    text = "Dughan is outside the Goldshire inn.",
    xp = 230, minutes = 3,
})

add({
    id = "A-human-elwynn-0052", order = 52, cluster = "goldshire",
    kind = "hearth", title = "Rest and Relaxation", questName = "Rest and Relaxation", questID = 2158,
    npc = "Innkeeper Farley", x = 0.438, y = 0.658, pin = "npc",
    requiresQuest = { 2158 }, requiresState = "accepted",
    text = "Set your hearth with Innkeeper Farley.",
    xp = 110, minutes = 1,
})

add({
    id = "A-human-elwynn-0053", order = 53, cluster = "goldshire",
    kind = "accept", title = "Kobold Candles", questID = 60,
    npc = "William Pestle", x = 0.433, y = 0.657, pin = "npc", hubName = "Goldshire",
    text = "Large candles from the kobolds at Fargodeep Mine.",
    xp = 230, minutes = 1,
})

add({
    id = "A-human-elwynn-0055", order = 55, cluster = "goldshire",
    kind = "accept", title = "Gold Dust Exchange", questID = 47,
    npc = "Remy \"Two Times\"", x = 0.421, y = 0.673, pin = "npc", hubName = "Goldshire",
    text = "Gold dust off the same kobolds. Remy stands south of the square.",
    xp = 250, minutes = 1,
})

add({
    id = "A-human-elwynn-0054", order = 54, cluster = "goldshire",
    kind = "accept", title = "The Fargodeep Mine", questID = 62, noBatch = true,
    npc = "Marshal Dughan", x = 0.421, y = 0.659, pin = "npc", hubName = "Goldshire",
    requiresQuest = { 54 }, requiresState = "turnedin",
    text = "Scout the mine south of Goldshire.",
    xp = 250, minutes = 1,
})

add({
    id = "A-human-elwynn-0056", order = 56, cluster = "fargodeep",
    kind = "objective", title = "Large Candles", questName = "Kobold Candles",
    questID = 60, objective = 1,
    requiresQuest = { 60 }, requiresState = "accepted",
    text = "Kobolds outside and inside Fargodeep Mine, south of Goldshire.",
    x = 0.400, y = 0.815, pin = "approx", minutes = 8,
})

add({
    id = "A-human-elwynn-0057", order = 57, cluster = "fargodeep",
    kind = "objective", title = "Scout the Mine", questName = "The Fargodeep Mine",
    questID = 62, objective = 1,
    requiresQuest = { 62 }, requiresState = "accepted",
    text = "Walk into the mine until the scout credit completes.",
    x = 0.389, y = 0.823, pin = "approx", minutes = 3,
})

add({
    id = "A-human-elwynn-0058", order = 58, cluster = "fargodeep",
    kind = "objective", title = "Gold Dust", questName = "Gold Dust Exchange",
    questID = 47, objective = 1,
    requiresQuest = { 47 }, requiresState = "accepted",
    text = "Same kobolds. Loot the dust.",
    x = 0.405, y = 0.820, pin = "approx", minutes = 6,
})

add({
    id = "A-human-elwynn-0059", order = 59, cluster = "goldshire",
    kind = "turnin", title = "Kobold Candles", questName = "Kobold Candles", questID = 60,
    npc = "William Pestle", x = 0.433, y = 0.657, pin = "npc",
    requiresQuest = { 60 }, requiresState = "accepted",
    text = "Candles back to William, inside the inn.",
    xp = 230, minutes = 3,
})

add({
    id = "A-human-elwynn-0060", order = 60, cluster = "goldshire",
    kind = "turnin", title = "The Fargodeep Mine", questName = "The Fargodeep Mine", questID = 62,
    npc = "Marshal Dughan", x = 0.421, y = 0.659, pin = "npc",
    requiresQuest = { 62 }, requiresState = "accepted",
    text = "Report the mine to Marshal Dughan.",
    xp = 250, minutes = 1,
})

add({
    id = "A-human-elwynn-0061", order = 61, cluster = "goldshire",
    kind = "turnin", title = "Gold Dust Exchange", questName = "Gold Dust Exchange", questID = 47,
    npc = "Remy \"Two Times\"", x = 0.421, y = 0.673, pin = "npc",
    requiresQuest = { 47 }, requiresState = "accepted",
    text = "Dust back to Remy.",
    xp = 250, minutes = 1,
})

QS.Registry.races.Alliance = QS.Registry.races.Alliance or {}
QS.Registry.races.Alliance.Human = {
    routeName = "Elwynn priority route",
    stub = false,
    steps = steps,
}
