-- Live guide tables: hearths, talents, professions, bosses, town.
-- Pins that are not copied from the starter routes are approximate (pin = approx).
-- Recipe reagent counts are the usual Classic path, confidence reported.
-- No Forever quest ids.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem

local S = {
    inns = {},
    cities = {},
    trainers = {},
    spells = {},
    crafts = {},
    herbs = {},
    ore = {},
    skins = {},
    bosses = {},
    talents = {},
}
QS.Services = S

local function ranks(rows)
    local out = {}
    for i = 1, #rows do
        local name, n = rows[i][1], rows[i][2]
        for _ = 1, n do
            out[#out + 1] = name
        end
    end
    return out
end

local function talent(spec, rows)
    S.talents[spec] = ranks(rows)
end

-- Leveling orders for Classic 1.12. Each name is skipped at runtime if that
-- talent is not on this client. Remaining points fall through to a generic line.
talent("Arms", {
    { "Deflection", 5 }, { "Tactical Mastery", 5 }, { "Improved Charge", 2 },
    { "Anger Management", 1 }, { "Deep Wounds", 3 }, { "Impale", 2 },
    { "Two-Handed Weapon Specialization", 5 }, { "Improved Heroic Strike", 3 },
    { "Sweeping Strikes", 1 }, { "Sword Specialization", 3 }, { "Mortal Strike", 1 },
    { "Cruelty", 5 }, { "Improved Battle Shout", 5 }, { "Enrage", 5 }, { "Unbridled Wrath", 5 },
})
talent("Fury", {
    { "Cruelty", 5 }, { "Improved Battle Shout", 5 }, { "Enrage", 5 },
    { "Dual Wield Specialization", 5 }, { "Unbridled Wrath", 5 }, { "Flurry", 5 },
    { "Bloodthirst", 1 }, { "Death Wish", 1 }, { "Improved Execute", 2 },
    { "Booming Voice", 5 }, { "Improved Demoralizing Shout", 5 }, { "Improved Cleave", 3 },
    { "Piercing Howl", 1 }, { "Blood Craze", 3 },
})
talent("Protection", {
    { "Shield Specialization", 5 }, { "Anticipation", 5 }, { "Toughness", 5 },
    { "Improved Shield Block", 3 }, { "Last Stand", 1 }, { "Defiance", 5 },
    { "Improved Sunder Armor", 3 }, { "Concussion Blow", 1 }, { "Shield Slam", 1 },
    { "Improved Bloodrage", 2 }, { "Improved Taunt", 2 }, { "Improved Revenge", 3 },
    { "Deflection", 5 },
})
talent("Retribution", {
    { "Benediction", 5 }, { "Improved Judgement", 2 }, { "Improved Seal of the Crusader", 3 },
    { "Conviction", 5 }, { "Seal of Command", 1 }, { "Pursuit of Justice", 2 },
    { "Improved Retribution Aura", 2 }, { "Two-Handed Weapon Specialization", 3 },
    { "Sanctity Aura", 1 }, { "Vengeance", 5 }, { "Repentance", 1 },
    { "Deflection", 5 }, { "Precision", 3 }, { "Guardian's Favor", 2 },
})
talent("Holy", {
    { "Divine Intellect", 5 }, { "Spiritual Focus", 5 }, { "Improved Lay on Hands", 2 },
    { "Healing Light", 3 }, { "Illumination", 5 }, { "Improved Blessing of Wisdom", 2 },
    { "Divine Favor", 1 }, { "Holy Power", 5 }, { "Holy Shock", 1 },
    { "Consecration", 1 },
})
S.talents.PaladinProtection = ranks({
    { "Improved Devotion Aura", 5 }, { "Redoubt", 5 }, { "Precision", 3 },
    { "Guardian's Favor", 2 }, { "Toughness", 5 }, { "Blessing of Sanctuary", 1 },
    { "Reckoning", 5 }, { "One-Handed Weapon Specialization", 5 }, { "Holy Shield", 1 },
    { "Improved Righteous Fury", 3 }, { "Shield Specialization", 3 }, { "Anticipation", 5 },
})

talent("BeastMastery", {
    { "Improved Aspect of the Hawk", 5 }, { "Endurance Training", 5 }, { "Thick Hide", 3 },
    { "Unleashed Fury", 5 }, { "Ferocity", 5 }, { "Bestial Discipline", 2 },
    { "Frenzy", 5 }, { "Intimidation", 1 }, { "Bestial Wrath", 1 },
    { "Improved Revive Pet", 2 }, { "Pathfinding", 2 }, { "Spirit Bond", 2 },
    { "Efficiency", 5 }, { "Lethal Shots", 5 }, { "Aimed Shot", 1 }, { "Mortal Shots", 2 },
})
talent("Marksmanship", {
    { "Lethal Shots", 5 }, { "Efficiency", 5 }, { "Aimed Shot", 1 },
    { "Improved Hunter's Mark", 5 }, { "Mortal Shots", 5 }, { "Hawk Eye", 3 },
    { "Barrage", 3 }, { "Trueshot Aura", 1 }, { "Ranged Weapon Specialization", 5 },
    { "Improved Aspect of the Hawk", 5 }, { "Endurance Training", 5 },
})
talent("Survival", {
    { "Monster Slaying", 3 }, { "Humanoid Slaying", 3 }, { "Deflection", 5 },
    { "Savage Strikes", 2 }, { "Improved Wing Clip", 3 }, { "Survivalist", 5 },
    { "Surefooted", 3 }, { "Deterrence", 1 }, { "Killer Instinct", 3 },
    { "Wyvern Sting", 1 }, { "Lightning Reflexes", 5 }, { "Trap Mastery", 2 },
    { "Improved Aspect of the Hawk", 5 },
})
talent("Assassination", {
    { "Malice", 5 }, { "Ruthlessness", 3 }, { "Murder", 2 },
    { "Improved Slice and Dice", 3 }, { "Relentless Strikes", 1 }, { "Lethality", 5 },
    { "Vile Poisons", 5 }, { "Cold Blood", 1 }, { "Seal Fate", 5 },
    { "Vigor", 1 }, { "Improved Poisons", 5 }, { "Precision", 5 },
})
talent("Combat", {
    { "Improved Sinister Strike", 2 }, { "Improved Gouge", 3 }, { "Precision", 5 },
    { "Improved Backstab", 3 }, { "Dual Wield Specialization", 5 }, { "Blade Flurry", 1 },
    { "Sword Specialization", 5 }, { "Aggression", 3 }, { "Adrenaline Rush", 1 },
    { "Weapon Expertise", 2 }, { "Malice", 5 }, { "Ruthlessness", 3 },
    { "Lethality", 5 }, { "Improved Slice and Dice", 3 },
})
talent("Subtlety", {
    { "Master of Deception", 5 }, { "Opportunity", 5 }, { "Camouflage", 5 },
    { "Initiative", 3 }, { "Ghostly Strike", 1 }, { "Setup", 3 },
    { "Serrated Blades", 3 }, { "Hemorrhage", 1 }, { "Deadliness", 5 },
    { "Premeditation", 1 }, { "Malice", 5 }, { "Improved Ambush", 3 },
})
talent("Discipline", {
    { "Wand Specialization", 5 }, { "Martyrdom", 2 }, { "Improved Power Word: Shield", 3 },
    { "Improved Power Word: Fortitude", 2 }, { "Mental Agility", 5 }, { "Inner Focus", 1 },
    { "Meditation", 3 }, { "Mental Strength", 5 }, { "Divine Spirit", 1 },
    { "Force of Will", 5 }, { "Power Infusion", 1 }, { "Silent Resolve", 5 },
})
S.talents.PriestHoly = ranks({
    { "Holy Specialization", 5 }, { "Divine Fury", 5 }, { "Inspiration", 3 },
    { "Holy Nova", 1 }, { "Searing Light", 2 }, { "Improved Healing", 3 },
    { "Spiritual Guidance", 5 }, { "Spiritual Healing", 5 }, { "Spirit of Redemption", 1 },
    { "Improved Renew", 3 }, { "Mental Agility", 5 },
})
talent("Shadow", {
    { "Spirit Tap", 5 }, { "Shadow Focus", 5 }, { "Shadow Affinity", 3 },
    { "Mind Flay", 1 }, { "Improved Mind Blast", 5 }, { "Shadow Weaving", 5 },
    { "Vampiric Embrace", 1 }, { "Darkness", 5 }, { "Shadowform", 1 },
    { "Improved Shadow Word: Pain", 2 }, { "Shadow Reach", 3 }, { "Silence", 1 },
    { "Improved Psychic Scream", 2 }, { "Blackout", 5 },
})
talent("Elemental", {
    { "Convection", 5 }, { "Concussion", 5 }, { "Call of Flame", 3 },
    { "Elemental Focus", 1 }, { "Reverberation", 5 }, { "Call of Thunder", 5 },
    { "Elemental Fury", 1 }, { "Lightning Mastery", 5 }, { "Elemental Mastery", 1 },
    { "Storm Reach", 2 }, { "Eye of the Storm", 3 }, { "Elemental Devastation", 3 },
})
talent("Enhancement", {
    { "Shield Specialization", 5 }, { "Thundering Strikes", 5 }, { "Improved Ghost Wolf", 2 },
    { "Two-Handed Axes and Maces", 1 }, { "Flurry", 5 }, { "Parry", 1 },
    { "Elemental Weapons", 3 }, { "Weapon Mastery", 5 }, { "Stormstrike", 1 },
    { "Anticipation", 5 }, { "Toughness", 5 }, { "Improved Lightning Shield", 3 },
})
S.talents.ShamanRestoration = ranks({
    { "Improved Healing Wave", 5 }, { "Tidal Focus", 5 }, { "Nature's Guidance", 3 },
    { "Totemic Focus", 5 }, { "Healing Focus", 5 }, { "Restorative Totems", 5 },
    { "Nature's Swiftness", 1 }, { "Purification", 5 }, { "Mana Tide Totem", 1 },
    { "Tidal Mastery", 5 }, { "Healing Way", 3 },
})
talent("Arcane", {
    { "Arcane Focus", 5 }, { "Improved Arcane Missiles", 5 }, { "Arcane Concentration", 5 },
    { "Arcane Impact", 3 }, { "Arcane Meditation", 3 }, { "Presence of Mind", 1 },
    { "Arcane Mind", 5 }, { "Arcane Instability", 3 }, { "Arcane Power", 1 },
    { "Improved Counterspell", 2 }, { "Evocation", 1 },
})
talent("Fire", {
    { "Improved Fireball", 5 }, { "Ignite", 5 }, { "Incinerate", 2 },
    { "Improved Fire Blast", 3 }, { "Impact", 5 }, { "Pyroblast", 1 },
    { "Critical Mass", 3 }, { "Blast Wave", 1 }, { "Fire Power", 5 },
    { "Combustion", 1 }, { "Burning Soul", 2 },
})
talent("Frost", {
    { "Improved Frostbolt", 5 }, { "Elemental Precision", 3 }, { "Ice Shards", 5 },
    { "Frostbite", 3 }, { "Improved Frost Nova", 2 }, { "Permafrost", 3 },
    { "Piercing Ice", 3 }, { "Cold Snap", 1 }, { "Frost Channeling", 3 },
    { "Shatter", 5 }, { "Ice Barrier", 1 }, { "Winter's Chill", 5 },
    { "Ice Block", 1 },
})
talent("Affliction", {
    { "Suppression", 5 }, { "Improved Corruption", 5 }, { "Improved Drain Life", 5 },
    { "Improved Life Tap", 2 }, { "Soul Siphon", 2 }, { "Improved Curse of Agony", 3 },
    { "Fel Concentration", 5 }, { "Amplify Curse", 1 }, { "Nightfall", 2 },
    { "Shadow Mastery", 5 }, { "Siphon Life", 1 }, { "Curse of Exhaustion", 1 },
})
talent("Demonology", {
    { "Improved Healthstone", 2 }, { "Demonic Embrace", 5 }, { "Improved Voidwalker", 3 },
    { "Fel Intellect", 5 }, { "Fel Domination", 1 }, { "Fel Stamina", 5 },
    { "Master Summoner", 2 }, { "Unholy Power", 5 }, { "Demonic Sacrifice", 1 },
    { "Master Demonologist", 5 }, { "Soul Link", 1 }, { "Improved Imp", 3 },
})
talent("Destruction", {
    { "Improved Shadow Bolt", 5 }, { "Cataclysm", 5 }, { "Bane", 5 },
    { "Devastation", 5 }, { "Shadowburn", 1 }, { "Destructive Reach", 2 },
    { "Improved Immolate", 5 }, { "Ruin", 1 }, { "Conflagrate", 1 },
    { "Emberstorm", 5 }, { "Intensity", 2 },
})
talent("Balance", {
    { "Improved Wrath", 5 }, { "Improved Moonfire", 5 }, { "Nature's Grasp", 1 },
    { "Improved Nature's Grasp", 4 }, { "Improved Thorns", 3 }, { "Moonglow", 3 },
    { "Nature's Reach", 2 }, { "Vengeance", 5 }, { "Insect Swarm", 1 },
    { "Moonfury", 5 }, { "Hurricane", 1 }, { "Improved Starfire", 5 },
})
talent("Feral", {
    { "Ferocity", 5 }, { "Feral Aggression", 5 }, { "Feral Instinct", 5 },
    { "Thick Hide", 5 }, { "Feral Swiftness", 2 }, { "Sharpened Claws", 3 },
    { "Predatory Strikes", 3 }, { "Blood Frenzy", 2 }, { "Primal Fury", 2 },
    { "Savage Fury", 2 }, { "Faerie Fire (Feral)", 1 }, { "Heart of the Wild", 5 },
    { "Leader of the Pack", 1 },
})
S.talents.DruidRestoration = ranks({
    { "Improved Mark of the Wild", 5 }, { "Furor", 5 }, { "Nature's Focus", 5 },
    { "Improved Healing Touch", 5 }, { "Improved Regrowth", 5 }, { "Nature's Swiftness", 1 },
    { "Gift of Nature", 5 }, { "Improved Rejuvenation", 3 }, { "Swiftmend", 1 },
    { "Reflection", 3 },
})

S.classTalent = {
    PALADIN = { Protection = "PaladinProtection", Holy = "Holy" },
    PRIEST = { Holy = "PriestHoly" },
    SHAMAN = { Restoration = "ShamanRestoration" },
    DRUID = { Restoration = "DruidRestoration" },
}

local function inn(row)
    S.inns[#S.inns + 1] = row
end

inn({ zone = "Elwynn Forest", bind = "Goldshire", hub = "Goldshire", cluster = "goldshire", minLevel = 4, npc = "Innkeeper Farley", mapID = 1429, x = 0.438, y = 0.658, pin = "npc" })
inn({ zone = "Durotar", bind = "Razor Hill", hub = "Razor Hill", cluster = "razorhill", minLevel = 5, npc = "Innkeeper Grosk", mapID = 1411, x = 0.515, y = 0.416, pin = "npc" })
inn({ zone = "Stormwind City", bind = "Stormwind City", hub = "Stormwind", cluster = "stormwind", minLevel = 5, npc = "Innkeeper Allison", mapID = 1453, x = 0.526, y = 0.658 })
inn({ zone = "Ironforge", bind = "Ironforge", hub = "Ironforge", cluster = "ironforge", minLevel = 5, npc = "Innkeeper Firebrew", mapID = 1455, x = 0.182, y = 0.514 })
inn({ zone = "Darnassus", bind = "Darnassus", hub = "Darnassus", cluster = "darnassus", minLevel = 5, npc = "Innkeeper Saelienne", mapID = 1457, x = 0.674, y = 0.156 })
inn({ zone = "Orgrimmar", bind = "Orgrimmar", hub = "Orgrimmar", cluster = "orgrimmar", minLevel = 5, npc = "Innkeeper Gryshka", mapID = 1454, x = 0.540, y = 0.684 })
inn({ zone = "Thunder Bluff", bind = "Thunder Bluff", hub = "Thunder Bluff", cluster = "thunderbluff", minLevel = 5, npc = "Innkeeper Pala", mapID = 1456, x = 0.457, y = 0.646 })
inn({ zone = "Undercity", bind = "Undercity", hub = "Undercity", cluster = "undercity", minLevel = 5, npc = "Innkeeper Norman", mapID = 1458, x = 0.677, y = 0.377 })
inn({ zone = "Westfall", bind = "Sentinel Hill", hub = "Sentinel Hill", cluster = "sentinel", minLevel = 10, npc = "Innkeeper Heather", mapID = 1436, x = 0.565, y = 0.474 })
inn({ zone = "The Barrens", bind = "The Crossroads", hub = "Crossroads", cluster = "crossroads", minLevel = 10, npc = "Innkeeper Boorand Plainswind", mapID = 1413, x = 0.520, y = 0.298 })
inn({ zone = "The Barrens", bind = "Ratchet", hub = "Ratchet", cluster = "ratchet", minLevel = 12, npc = "Innkeeper Wiley", mapID = 1413, x = 0.620, y = 0.395 })
inn({ zone = "Loch Modan", bind = "Thelsamar", hub = "Thelsamar", cluster = "thelsamar", minLevel = 10, npc = "Innkeeper Hearthstove", mapID = 1432, x = 0.357, y = 0.485 })
inn({ zone = "Darkshore", bind = "Auberdine", hub = "Auberdine", cluster = "auberdine", minLevel = 10, npc = "Innkeeper Shaussiy", mapID = 1439, x = 0.370, y = 0.444 })
inn({ zone = "Redridge Mountains", bind = "Lakeshire", hub = "Lakeshire", cluster = "lakeshire", minLevel = 15, npc = "Innkeeper Brianna", mapID = 1433, x = 0.270, y = 0.446 })
inn({ zone = "Silverpine Forest", bind = "The Sepulcher", hub = "Sepulcher", cluster = "sepulcher", minLevel = 10, npc = "Innkeeper Bates", mapID = 1421, x = 0.431, y = 0.414 })
inn({ zone = "Tirisfal Glades", bind = "Brill", hub = "Brill", cluster = "brill", minLevel = 5, npc = "Innkeeper Renee", mapID = 1420, x = 0.618, y = 0.522 })
inn({ zone = "Mulgore", bind = "Bloodhoof Village", hub = "Bloodhoof", cluster = "bloodhoof", minLevel = 5, npc = "Innkeeper Kauth", mapID = 1412, x = 0.467, y = 0.610 })
inn({ zone = "Dun Morogh", bind = "Kharanos", hub = "Kharanos", cluster = "kharanos", minLevel = 5, npc = "Innkeeper Belm", mapID = 1426, x = 0.473, y = 0.524 })
inn({ zone = "Teldrassil", bind = "Dolanaar", hub = "Dolanaar", cluster = "dolanaar", minLevel = 5, npc = "Innkeeper Keldamyr", mapID = 1438, x = 0.557, y = 0.597 })

-- Capitals and neutral AH towns. Bank and auction steps appear here.
local function city(name, faction, mapID, x, y)
    S.cities[name] = { faction = faction, mapID = mapID, x = x, y = y }
end

city("Stormwind City", "Alliance", 1453, 0.526, 0.658)
city("Ironforge", "Alliance", 1455, 0.308, 0.662)
city("Darnassus", "Alliance", 1457, 0.674, 0.156)
city("Orgrimmar", "Horde", 1454, 0.540, 0.684)
city("Thunder Bluff", "Horde", 1456, 0.457, 0.646)
city("Undercity", "Horde", 1458, 0.677, 0.377)
city("Booty Bay", nil, 1434, 0.266, 0.763)
city("Gadgetzan", nil, 1446, 0.516, 0.287)
city("Everlook", nil, 1452, 0.614, 0.387)

-- A trainer step is created only when this table has a row for that city.
-- Missing rows do not point at the inn. Thunder Bluff alchemy is Bena's hut
-- on the middle rise, reported at 46.6, 33.2.
local function trainer(cityName, prof, npc, x, y, where)
    local mapID = S.cities[cityName] and S.cities[cityName].mapID
    S.trainers[cityName] = S.trainers[cityName] or {}
    S.trainers[cityName][prof] = { npc = npc, x = x, y = y, mapID = mapID, where = where }
end

trainer("Stormwind City", "Alchemy", "Lilyssia Nightbreeze", 0.464, 0.794, "Mage Quarter")
trainer("Stormwind City", "Herbalism", "Tannysa", 0.446, 0.772, "Mage Quarter")
trainer("Stormwind City", "Blacksmithing", "Therum Deepforge", 0.637, 0.369, "Dwarven District")
trainer("Stormwind City", "Mining", "Gelman Stonehand", 0.590, 0.378, "Dwarven District")
trainer("Stormwind City", "Engineering", "Lilliam Sparkspindle", 0.548, 0.082, "Dwarven District")
trainer("Stormwind City", "Skinning", "Maris Granger", 0.672, 0.494, "Old Town")
trainer("Stormwind City", "Leatherworking", "Simon Tanner", 0.672, 0.494, "Old Town")
trainer("Stormwind City", "Tailoring", "Georgio Bolero", 0.435, 0.738, "Mage Quarter")
trainer("Stormwind City", "Enchanting", "Lucan Cordell", 0.430, 0.642, "Trade District")
trainer("Stormwind City", "Cooking", "Stephen Ryback", 0.756, 0.371, "Dwarven District")
trainer("Stormwind City", "First Aid", "Shaina Fuller", 0.426, 0.259, "Cathedral Square")
trainer("Stormwind City", "Fishing", "Arnold Leland", 0.458, 0.584, "the Canals")

trainer("Orgrimmar", "Alchemy", "Yelmak", 0.558, 0.331, "the Drag")
trainer("Orgrimmar", "Herbalism", "Jandi", 0.555, 0.394, "the Drag")
trainer("Orgrimmar", "Mining", "Makaru", 0.730, 0.264, "Valley of Honor")
trainer("Orgrimmar", "Blacksmithing", "Snarl", 0.758, 0.344, "Valley of Honor")
trainer("Orgrimmar", "Engineering", "Roxxik", 0.760, 0.248, "Valley of Honor")
trainer("Orgrimmar", "Skinning", "Thuwd", 0.630, 0.452, "the Drag")
trainer("Orgrimmar", "Leatherworking", "Kamari", 0.628, 0.444, "the Drag")
trainer("Orgrimmar", "Tailoring", "Magar", 0.630, 0.496, "the Drag")
trainer("Orgrimmar", "Enchanting", "Godan", 0.534, 0.384, "the Drag")
trainer("Orgrimmar", "Cooking", "Zamja", 0.574, 0.536, "Valley of Spirits")
trainer("Orgrimmar", "First Aid", "Arnok", 0.341, 0.844, "Valley of Spirits")
trainer("Orgrimmar", "Fishing", "Lumak", 0.699, 0.294, "Valley of Honor")

trainer("Thunder Bluff", "Alchemy", "Bena Winterhoof", 0.466, 0.332, "Bena's Alchemy on the middle rise")

local function spells(prof, bracket, list)
    S.spells[prof] = S.spells[prof] or {}
    S.spells[prof][bracket] = list
end

spells("Alchemy", 75, { "Minor Healing Potion", "Elixir of Lion's Strength", "Elixir of Minor Fortitude", "Minor Rejuvenation Potion" })
spells("Alchemy", 150, { "Lesser Healing Potion", "Healing Potion", "Lesser Mana Potion", "Elixir of Wisdom" })
spells("Alchemy", 225, { "Greater Healing Potion", "Mana Potion", "Elixir of Agility", "Elixir of Greater Defense" })
spells("Alchemy", 300, { "Superior Healing Potion", "Major Healing Potion", "Elixir of the Mongoose", "Greater Arcane Elixir" })
spells("Blacksmithing", 75, { "Rough Sharpening Stone", "Rough Grinding Stone", "Copper Bracers", "Copper Chain Belt" })
spells("Blacksmithing", 150, { "Coarse Sharpening Stone", "Iron Buckle", "Green Iron Bracers" })
spells("Blacksmithing", 225, { "Steel Weapon Chain", "Golden Scale Bracers", "Solid Grinding Stone" })
spells("Blacksmithing", 300, { "Thorium Bracers", "Imperial Plate Bracers", "Dense Sharpening Stone" })
spells("Engineering", 75, { "Rough Blasting Powder", "Rough Dynamite", "Copper Tube", "Handful of Copper Bolts" })
spells("Engineering", 150, { "Coarse Blasting Powder", "Bronze Tube", "Iron Grenade", "Target Dummy" })
spells("Engineering", 225, { "Solid Blasting Powder", "Mithril Tube", "Hi-Explosive Bomb", "Mithril Casing" })
spells("Engineering", 300, { "Dense Blasting Powder", "Thorium Widget", "Thorium Tube" })
spells("Enchanting", 75, { "Runed Copper Rod", "Enchant Bracer - Minor Health", "Enchant Bracer - Minor Deflection" })
spells("Enchanting", 150, { "Runed Silver Rod", "Enchant Bracer - Minor Strength", "Enchant Bracer - Lesser Stamina" })
spells("Enchanting", 225, { "Runed Golden Rod", "Enchant Bracer - Strength", "Enchant Chest - Greater Health" })
spells("Enchanting", 300, { "Runed Truesilver Rod", "Enchant Bracer - Greater Stamina", "Enchant Chest - Major Health" })
spells("Leatherworking", 75, { "Light Armor Kit", "Handstitched Leather Boots", "Handstitched Leather Belt" })
spells("Leatherworking", 150, { "Medium Armor Kit", "Dark Leather Boots", "Hillman's Leather Gloves" })
spells("Leatherworking", 225, { "Heavy Armor Kit", "Nightscape Headband", "Turtle Scale Breastplate" })
spells("Leatherworking", 300, { "Rugged Armor Kit", "Wicked Leather Bracers", "Wicked Leather Headband" })
spells("Tailoring", 75, { "Bolt of Linen Cloth", "Brown Linen Robe", "Linen Belt", "Linen Bag" })
spells("Tailoring", 150, { "Bolt of Woolen Cloth", "Bolt of Silk Cloth", "Gray Woolen Shirt", "Azure Silk Pants" })
spells("Tailoring", 225, { "Bolt of Mageweave", "Crimson Silk Vest", "Black Mageweave Boots" })
spells("Tailoring", 300, { "Bolt of Runecloth", "Runecloth Belt", "Runecloth Gloves", "Runecloth Bag" })
spells("Cooking", 75, { "Charred Wolf Meat", "Roasted Boar Meat", "Herb Baked Egg", "Spiced Wolf Meat" })
spells("Cooking", 150, { "Smoked Sagefish", "Cooked Crab Claw", "Curiously Tasty Omelet" })
spells("Cooking", 225, { "Monster Omelet", "Tender Wolf Steak", "Spotted Yellowtail" })
spells("Cooking", 300, { "Lobster Stew", "Mightfish Steak", "Grilled Squid" })
spells("First Aid", 75, { "Linen Bandage", "Heavy Linen Bandage" })
spells("First Aid", 150, { "Wool Bandage", "Heavy Wool Bandage", "Silk Bandage" })
spells("First Aid", 225, { "Heavy Silk Bandage", "Mageweave Bandage" })
spells("First Aid", 300, { "Heavy Mageweave Bandage", "Runecloth Bandage", "Heavy Runecloth Bandage" })
spells("Fishing", 75, { "Apprentice Fishing" })
spells("Fishing", 150, { "Journeyman Fishing" })
spells("Fishing", 225, { "Expert Fishing" })
spells("Fishing", 300, { "Artisan Fishing" })
spells("Herbalism", 75, { "Apprentice Herbalism" })
spells("Herbalism", 150, { "Journeyman Herbalism" })
spells("Herbalism", 225, { "Expert Herbalism" })
spells("Herbalism", 300, { "Artisan Herbalism" })
spells("Mining", 75, { "Apprentice Mining", "Smelt Copper" })
spells("Mining", 150, { "Journeyman Mining", "Smelt Tin", "Smelt Bronze", "Smelt Silver" })
spells("Mining", 225, { "Expert Mining", "Smelt Iron", "Smelt Gold", "Smelt Steel" })
spells("Mining", 300, { "Artisan Mining", "Smelt Mithril", "Smelt Truesilver", "Smelt Thorium" })
spells("Skinning", 75, { "Apprentice Skinning" })
spells("Skinning", 150, { "Journeyman Skinning" })
spells("Skinning", 225, { "Expert Skinning" })
spells("Skinning", 300, { "Artisan Skinning" })

local function craft(prof, row)
    S.crafts[prof] = S.crafts[prof] or {}
    local list = S.crafts[prof]
    list[#list + 1] = row
end

-- untilSkill is the skill at which this recipe stops being the one to spam.
craft("Alchemy", { skill = 1, untilSkill = 60, name = "Minor Healing Potion", product = 118, reagents = { { 2447, "Peacebloom", 1 }, { 765, "Silverleaf", 1 } } })
craft("Alchemy", { skill = 55, untilSkill = 110, name = "Lesser Healing Potion", product = 858, reagents = { { 118, "Minor Healing Potion", 1 }, { 2450, "Briarthorn", 1 } } })
craft("Alchemy", { skill = 110, untilSkill = 140, name = "Healing Potion", product = 929, reagents = { { 2453, "Bruiseweed", 1 }, { 2450, "Briarthorn", 1 } } })
craft("Alchemy", { skill = 155, untilSkill = 185, name = "Greater Healing Potion", product = 1710, reagents = { { 3357, "Liferoot", 1 }, { 3356, "Kingsblood", 1 } } })
craft("Alchemy", { skill = 215, untilSkill = 265, name = "Superior Healing Potion", product = 3928, reagents = { { 8838, "Sungrass", 1 }, { 3358, "Khadgar's Whisker", 1 } } })
craft("Alchemy", { skill = 275, untilSkill = 300, name = "Major Healing Potion", product = 13446, reagents = { { 13464, "Golden Sansam", 2 }, { 13465, "Mountain Silversage", 1 } } })

craft("Tailoring", { skill = 1, untilSkill = 45, name = "Bolt of Linen Cloth", product = 2996, reagents = { { 2589, "Linen Cloth", 2 } } })
craft("Tailoring", { skill = 45, untilSkill = 70, name = "Linen Belt", product = 7026, reagents = { { 2996, "Bolt of Linen Cloth", 3 }, { 2320, "Coarse Thread", 1 } } })
craft("Tailoring", { skill = 65, untilSkill = 105, name = "Bolt of Woolen Cloth", product = 2997, reagents = { { 2592, "Wool Cloth", 3 } } })
craft("Tailoring", { skill = 125, untilSkill = 145, name = "Bolt of Silk Cloth", product = 4305, reagents = { { 4306, "Silk Cloth", 4 } } })
craft("Tailoring", { skill = 175, untilSkill = 185, name = "Bolt of Mageweave", product = 4339, reagents = { { 4338, "Mageweave Cloth", 5 } } })
craft("Tailoring", { skill = 250, untilSkill = 260, name = "Bolt of Runecloth", product = 14048, reagents = { { 14047, "Runecloth", 5 } } })
craft("Tailoring", { skill = 260, untilSkill = 280, name = "Runecloth Belt", product = 13856, reagents = { { 14048, "Bolt of Runecloth", 3 }, { 14341, "Rune Thread", 1 } } })

craft("Leatherworking", { skill = 1, untilSkill = 30, name = "Light Armor Kit", product = 2304, reagents = { { 2318, "Light Leather", 1 } } })
craft("Leatherworking", { skill = 30, untilSkill = 55, name = "Handstitched Leather Belt", product = 4237, reagents = { { 2318, "Light Leather", 6 }, { 2320, "Coarse Thread", 1 } } })
craft("Leatherworking", { skill = 100, untilSkill = 130, name = "Medium Armor Kit", product = 2313, reagents = { { 2319, "Medium Leather", 4 }, { 2321, "Fine Thread", 1 } } })
craft("Leatherworking", { skill = 150, untilSkill = 180, name = "Heavy Armor Kit", product = 4265, reagents = { { 4234, "Heavy Leather", 5 }, { 2321, "Fine Thread", 1 } } })
craft("Leatherworking", { skill = 200, untilSkill = 230, name = "Thick Armor Kit", product = 8173, reagents = { { 4304, "Thick Leather", 5 }, { 4291, "Silken Thread", 1 } } })
craft("Leatherworking", { skill = 250, untilSkill = 300, name = "Rugged Armor Kit", product = 15564, reagents = { { 8170, "Rugged Leather", 5 } } })

craft("Blacksmithing", { skill = 1, untilSkill = 25, name = "Rough Sharpening Stone", product = 2862, reagents = { { 2835, "Rough Stone", 1 } } })
craft("Blacksmithing", { skill = 25, untilSkill = 65, name = "Rough Grinding Stone", product = 3470, reagents = { { 2835, "Rough Stone", 2 } } })
craft("Blacksmithing", { skill = 65, untilSkill = 90, name = "Coarse Sharpening Stone", product = 2863, reagents = { { 2836, "Coarse Stone", 1 } } })
craft("Blacksmithing", { skill = 125, untilSkill = 150, name = "Heavy Grinding Stone", product = 3486, reagents = { { 2838, "Heavy Stone", 3 } } })
craft("Blacksmithing", { skill = 200, untilSkill = 225, name = "Solid Grinding Stone", product = 7966, reagents = { { 7912, "Solid Stone", 4 } } })
craft("Blacksmithing", { skill = 250, untilSkill = 300, name = "Dense Sharpening Stone", product = 12404, reagents = { { 12365, "Dense Stone", 1 } } })

craft("Engineering", { skill = 1, untilSkill = 30, name = "Rough Blasting Powder", product = 4357, reagents = { { 2835, "Rough Stone", 1 } } })
craft("Engineering", { skill = 30, untilSkill = 50, name = "Handful of Copper Bolts", product = 4359, reagents = { { 2840, "Copper Bar", 1 } } })
craft("Engineering", { skill = 50, untilSkill = 75, name = "Rough Dynamite", product = 4358, reagents = { { 4357, "Rough Blasting Powder", 2 }, { 2589, "Linen Cloth", 1 } } })
craft("Engineering", { skill = 75, untilSkill = 110, name = "Coarse Blasting Powder", product = 4364, reagents = { { 2836, "Coarse Stone", 1 } } })
craft("Engineering", { skill = 125, untilSkill = 175, name = "Heavy Blasting Powder", product = 4377, reagents = { { 2838, "Heavy Stone", 1 } } })
craft("Engineering", { skill = 175, untilSkill = 225, name = "Solid Blasting Powder", product = 10505, reagents = { { 7912, "Solid Stone", 2 } } })
craft("Engineering", { skill = 225, untilSkill = 300, name = "Dense Blasting Powder", product = 15992, reagents = { { 12365, "Dense Stone", 2 } } })

craft("Enchanting", { skill = 1, untilSkill = 70, name = "Enchant Bracer - Minor Health", reagents = { { 10940, "Strange Dust", 1 } } })
craft("First Aid", { skill = 1, untilSkill = 40, name = "Linen Bandage", product = 1251, reagents = { { 2589, "Linen Cloth", 1 } } })
craft("First Aid", { skill = 40, untilSkill = 80, name = "Heavy Linen Bandage", product = 2581, reagents = { { 2589, "Linen Cloth", 2 } } })
craft("First Aid", { skill = 80, untilSkill = 115, name = "Wool Bandage", product = 3530, reagents = { { 2592, "Wool Cloth", 1 } } })
craft("First Aid", { skill = 115, untilSkill = 150, name = "Heavy Wool Bandage", product = 3531, reagents = { { 2592, "Wool Cloth", 2 } } })
craft("First Aid", { skill = 150, untilSkill = 180, name = "Silk Bandage", product = 6450, reagents = { { 4306, "Silk Cloth", 1 } } })
craft("First Aid", { skill = 180, untilSkill = 210, name = "Mageweave Bandage", product = 8544, reagents = { { 4338, "Mageweave Cloth", 1 } } })
craft("First Aid", { skill = 240, untilSkill = 300, name = "Runecloth Bandage", product = 14529, reagents = { { 14047, "Runecloth", 1 } } })
craft("Cooking", { skill = 1, untilSkill = 40, name = "Charred Wolf Meat", product = 2679, reagents = { { 2672, "Stringy Wolf Meat", 1 } }, station = "fire" })
craft("Cooking", { skill = 1, untilSkill = 40, name = "Roasted Boar Meat", product = 2681, reagents = { { 769, "Chunk of Boar Meat", 1 } }, station = "fire" })
craft("Cooking", { skill = 25, untilSkill = 60, name = "Herb Baked Egg", product = 6888, reagents = { { 6889, "Small Egg", 1 }, { 2678, "Mild Spices", 1 } }, station = "fire" })
craft("Cooking", { skill = 50, untilSkill = 90, name = "Smoked Bear Meat", product = 6890, reagents = { { 3173, "Bear Meat", 1 } }, station = "fire" })

-- product 0 means the craft is an enchant: completion is a skill-up, not an item.

local function nodes(bucket, zone, list)
    S[bucket][zone] = list
end

local PEACE = { id = 2447, name = "Peacebloom", skill = 1 }
local SILVER = { id = 765, name = "Silverleaf", skill = 1 }
local EARTH = { id = 2449, name = "Earthroot", skill = 15 }
local MAGE = { id = 785, name = "Mageroyal", skill = 50 }
local BRIAR = { id = 2450, name = "Briarthorn", skill = 70 }
local BRUISE = { id = 2453, name = "Bruiseweed", skill = 100 }
local KELP = { id = 3820, name = "Stranglekelp", skill = 85 }
local STEEL = { id = 3355, name = "Wild Steelbloom", skill = 115 }
local MOSS = { id = 3369, name = "Grave Moss", skill = 120 }
local KINGS = { id = 3356, name = "Kingsblood", skill = 125 }
local LIFE = { id = 3357, name = "Liferoot", skill = 150 }
local FADE = { id = 3818, name = "Fadeleaf", skill = 160 }
local GOLD = { id = 3821, name = "Goldthorn", skill = 170 }
local WHISK = { id = 3358, name = "Khadgar's Whisker", skill = 185 }
local WINTER = { id = 3819, name = "Wintersbite", skill = 195 }
local FIRE = { id = 4625, name = "Firebloom", skill = 205 }
local LOTUS = { id = 8831, name = "Purple Lotus", skill = 210 }
local SUN = { id = 8838, name = "Sungrass", skill = 230 }
local BLIND = { id = 8839, name = "Blindweed", skill = 235 }
local GROMS = { id = 8846, name = "Gromsblood", skill = 250 }
local SANSAM = { id = 13464, name = "Golden Sansam", skill = 260 }
local DREAM = { id = 13463, name = "Dreamfoil", skill = 270 }
local SAGE = { id = 13465, name = "Mountain Silversage", skill = 280 }
local PLAGUE = { id = 13466, name = "Plaguebloom", skill = 285 }
local ICE = { id = 13467, name = "Icecap", skill = 290 }

nodes("herbs", "Elwynn Forest", { PEACE, SILVER, EARTH })
nodes("herbs", "Durotar", { PEACE, SILVER, EARTH })
nodes("herbs", "Teldrassil", { PEACE, SILVER, EARTH })
nodes("herbs", "Mulgore", { PEACE, SILVER, EARTH })
nodes("herbs", "Tirisfal Glades", { PEACE, SILVER, EARTH })
nodes("herbs", "Dun Morogh", { SILVER, EARTH })
nodes("herbs", "Westfall", { EARTH, MAGE, KELP })
nodes("herbs", "The Barrens", { EARTH, MAGE, BRIAR, KELP })
nodes("herbs", "Silverpine Forest", { MAGE, BRIAR, BRUISE })
nodes("herbs", "Loch Modan", { MAGE, BRIAR, BRUISE })
nodes("herbs", "Darkshore", { MAGE, BRIAR, BRUISE, KELP })
nodes("herbs", "Redridge Mountains", { BRIAR, BRUISE, STEEL })
nodes("herbs", "Duskwood", { MOSS, KINGS, FADE })
nodes("herbs", "Wetlands", { KINGS, LIFE, STEEL })
nodes("herbs", "Ashenvale", { KINGS, LIFE, STEEL })
nodes("herbs", "Stonetalon Mountains", { KINGS, LIFE, STEEL })
nodes("herbs", "Hillsbrad Foothills", { KINGS, BRUISE, GOLD })
nodes("herbs", "Thousand Needles", { GOLD, WHISK })
nodes("herbs", "Arathi Highlands", { GOLD, FADE, WHISK })
nodes("herbs", "Stranglethorn Vale", { KINGS, LIFE, FADE, GOLD, WHISK, LOTUS })
nodes("herbs", "Desolace", { GOLD, WHISK, GROMS })
nodes("herbs", "Swamp of Sorrows", { BLIND, FADE, GOLD, WHISK })
nodes("herbs", "Alterac Mountains", { GOLD, WHISK, WINTER })
nodes("herbs", "Badlands", { FIRE, WHISK })
nodes("herbs", "Tanaris", { FIRE, LOTUS, SUN })
nodes("herbs", "Feralas", { SUN, GOLD, WHISK, DREAM })
nodes("herbs", "The Hinterlands", { SUN, GOLD, WHISK, DREAM })
nodes("herbs", "Azshara", { SUN, DREAM, SAGE })
nodes("herbs", "Felwood", { GROMS, DREAM, PLAGUE, SAGE })
nodes("herbs", "Un'Goro Crater", { SANSAM, DREAM, SAGE })
nodes("herbs", "Western Plaguelands", { PLAGUE, SANSAM, SAGE })
nodes("herbs", "Eastern Plaguelands", { PLAGUE, SANSAM, SAGE })
nodes("herbs", "Winterspring", { ICE, SAGE, DREAM })
nodes("herbs", "Burning Steppes", { FIRE, SAGE })
nodes("herbs", "Silithus", { SANSAM, DREAM, SAGE })
nodes("herbs", "Blasted Lands", { FIRE, GROMS })

local COPPER = { id = 2770, name = "Copper Ore", skill = 1 }
local TIN = { id = 2771, name = "Tin Ore", skill = 65 }
local SILV = { id = 2775, name = "Silver Ore", skill = 75 }
local IRON = { id = 2772, name = "Iron Ore", skill = 125 }
local GOLDEN = { id = 2776, name = "Gold Ore", skill = 155 }
local MITH = { id = 3858, name = "Mithril Ore", skill = 175 }
local TRUE = { id = 7911, name = "Truesilver Ore", skill = 230 }
local THOR = { id = 10620, name = "Thorium Ore", skill = 245 }

nodes("ore", "Elwynn Forest", { COPPER })
nodes("ore", "Durotar", { COPPER })
nodes("ore", "Dun Morogh", { COPPER, TIN })
nodes("ore", "Teldrassil", { COPPER })
nodes("ore", "Mulgore", { COPPER })
nodes("ore", "Tirisfal Glades", { COPPER })
nodes("ore", "Westfall", { COPPER, TIN })
nodes("ore", "The Barrens", { COPPER, TIN, SILV })
nodes("ore", "Darkshore", { COPPER, TIN })
nodes("ore", "Loch Modan", { COPPER, TIN, SILV })
nodes("ore", "Silverpine Forest", { COPPER, TIN })
nodes("ore", "Redridge Mountains", { TIN, SILV, IRON })
nodes("ore", "Ashenvale", { COPPER, TIN, IRON })
nodes("ore", "Stonetalon Mountains", { COPPER, TIN, IRON })
nodes("ore", "Hillsbrad Foothills", { IRON, GOLDEN })
nodes("ore", "Thousand Needles", { IRON, GOLDEN })
nodes("ore", "Arathi Highlands", { IRON, GOLDEN, MITH })
nodes("ore", "Desolace", { IRON, GOLDEN, MITH })
nodes("ore", "Stranglethorn Vale", { IRON, GOLDEN, MITH, TRUE })
nodes("ore", "Swamp of Sorrows", { IRON, MITH })
nodes("ore", "Badlands", { IRON, GOLDEN, MITH })
nodes("ore", "Tanaris", { MITH, TRUE })
nodes("ore", "Feralas", { MITH, TRUE })
nodes("ore", "The Hinterlands", { MITH, TRUE, THOR })
nodes("ore", "Azshara", { MITH, TRUE, THOR })
nodes("ore", "Felwood", { MITH, TRUE, THOR })
nodes("ore", "Un'Goro Crater", { MITH, TRUE, THOR })
nodes("ore", "Western Plaguelands", { MITH, TRUE, THOR })
nodes("ore", "Eastern Plaguelands", { THOR, TRUE })
nodes("ore", "Winterspring", { THOR, TRUE })
nodes("ore", "Burning Steppes", { THOR, TRUE })
nodes("ore", "Silithus", { THOR, TRUE })
nodes("ore", "Searing Gorge", { MITH, THOR, TRUE })

S.skins = {
    { id = 2934, name = "Ruined Leather Scraps", skill = 1, untilSkill = 25 },
    { id = 2318, name = "Light Leather", skill = 1, untilSkill = 75 },
    { id = 2319, name = "Medium Leather", skill = 50, untilSkill = 125 },
    { id = 4234, name = "Heavy Leather", skill = 100, untilSkill = 175 },
    { id = 4304, name = "Thick Leather", skill = 150, untilSkill = 250 },
    { id = 8170, name = "Rugged Leather", skill = 200, untilSkill = 300 },
}

local function bosses(id, list)
    local rows = {}
    for i = 1, #list do
        rows[#rows + 1] = { name = list[i] }
    end
    S.bosses[id] = rows
end

bosses("rfc", { "Oggleflint", "Taragaman the Hungerer", "Jergosh the Invoker", "Bazzalan" })
bosses("deadmines", { "Rhahk'Zor", "Sneed's Shredder", "Sneed", "Gilnid", "Mr. Smite", "Captain Greenskin", "Edwin VanCleef" })
bosses("wailingcaverns", { "Lady Anacondra", "Lord Cobrahn", "Kresh", "Lord Pythas", "Skum", "Lord Serpentis", "Verdan the Everliving", "Mutanus the Devourer" })
bosses("sfk", { "Rethilgore", "Razorclaw the Butcher", "Baron Silverlaine", "Commander Springvale", "Odo the Blindwatcher", "Fenrus the Devourer", "Archmage Arugal" })
bosses("bfd", { "Ghamoo-ra", "Lady Sarevess", "Gelihast", "Lorgus Jett", "Old Serra'kis", "Twilight Lord Kelris", "Aku'mai" })
bosses("stockades", { "Targorr the Dread", "Kam Deepfury", "Hamhock", "Bazil Thredd" })
bosses("gnomeregan", { "Grubbis", "Viscous Fallout", "Electrocutioner 6000", "Crowd Pummeler 9-60", "Mekgineer Thermaplugg" })
bosses("rfk", { "Roogug", "Aggem Thorncurse", "Death Speaker Jargba", "Overlord Ramtusk", "Agathelos the Raging", "Charlga Razorflank" })
bosses("sm", { "Interrogator Vishas", "Bloodmage Thalnos", "Herod", "Doan", "High Inquisitor Whitemane" })
bosses("rfd", { "Tuten'kash", "Mordresh Fire Eye", "Glutton", "Amnennar the Coldbringer" })
bosses("uldaman", { "Revelosh", "Ironaya", "Ancient Stone Keeper", "Galgann Firehammer", "Grimlok", "Archaedas" })
bosses("zf", { "Theka the Martyr", "Antu'sul", "Witch Doctor Zum'rah", "Hydromancer Velratha", "Gahz'rilla", "Chief Ukorz Sandscalp" })
bosses("maraudon", { "Noxxion", "Razorlash", "Lord Vyletongue", "Celebras the Cursed", "Landslide", "Rotgrip", "Princess Theradras" })
bosses("st", { "Jammal'an the Prophet", "Avatar of Hakkar", "Shade of Eranikus" })
bosses("brd", { "High Interrogator Gerstahn", "Lord Roccor", "Bael'Gar", "Lord Incendius", "Fineous Darkvire", "General Angerforge", "Golem Lord Argelmach", "Ambassador Flamelash", "Emperor Dagran Thaurissan" })
bosses("lbrs", { "Highlord Omokk", "Shadow Hunter Vosh'gajin", "War Master Voone", "Mother Smolderweb", "Quartermaster Zigris", "Overlord Wyrmthalak" })
bosses("diremaul", { "Tendris Warpwood", "Alzzin the Wildshaper", "Guard Mol'dar", "King Gordok", "Prince Tortheldrin" })
bosses("scholo", { "Kirtonos the Herald", "Jandice Barov", "Rattlegore", "Ras Frostwhisper", "Darkmaster Gandling" })
bosses("strat", { "Timmy the Cruel", "Balnazzar", "Baron Rivendare" })

S.bossNames = {}
for _, list in pairs(S.bosses) do
    for i = 1, #list do
        S.bossNames[list[i].name] = true
    end
end

local INSIDE = {
    rfc = "Ragefire Chasm",
    deadmines = "The Deadmines",
    wailingcaverns = "Wailing Caverns",
    sfk = "Shadowfang Keep",
    bfd = "Blackfathom Deeps",
    stockades = "The Stockade",
    gnomeregan = "Gnomeregan",
    rfk = "Razorfen Kraul",
    sm = "Scarlet Monastery",
    rfd = "Razorfen Downs",
    uldaman = "Uldaman",
    zf = "Zul'Farrak",
    maraudon = "Maraudon",
    st = "The Temple of Atal'Hakkar",
    brd = "Blackrock Depths",
    lbrs = "Lower Blackrock Spire",
    diremaul = "Dire Maul",
    scholo = "Scholomance",
    strat = "Stratholme",
}

if QS.Registry and QS.Registry.dungeons then
    for i = 1, #QS.Registry.dungeons do
        local row = QS.Registry.dungeons[i]
        if INSIDE[row.id] then
            row.insideZone = INSIDE[row.id]
        end
    end
end

