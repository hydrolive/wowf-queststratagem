# BiS and dungeon goals

## Rule

A BiS callout is a goal row, not a separate guide. When the current step can award or drop an item that is best for the confirmed spec at that level band, the large window says so.

Copy patterns:

- `BiS wand: Gravestone Scepter — choose this reward`
- `BiS weapon: Ironfoe — drop, Emperor Thaurissan, BRD`
- `BiS chest: Robe of the Archmage — crafted, not this quest`

If the item is a drop, the dungeon step does not complete on quest turn-in alone when `bisRequired` is set. It completes on turn-in plus (item in bags or equipped or Next). Loot cannot be forced. Status becomes `BiS still missing`.

Boss kill steps are a different record. Kind `boss`, goal text is the boss name, and `bisRequired` is not set. Walking past Rhahk'Zor is not a BiS check. BiS rows still attach to the quest or the drop that actually awards the item. Do not merge those two ideas.

Talent point advice is also not a BiS row. The leveling order in `Data/Services.lua` is a reported Classic spend, one name per point, for the trees listed under "Spec trees to cover". Class-colliding keys are Paladin Protection, Priest Holy, Shaman Restoration, and Druid Restoration. Treat the orders as reported until someone cites a Forever guide.

## Tables

`Data/Bis/<Class>.lua`, keyed by spec tree, then level band `1-19`, `20-39`, `40-59`, `60`.

```lua
{
  slot = "weapon",
  itemID = 11684,          -- 0 if unknown; name still required
  name = "Ironfoe",
  how = "drop",            -- drop | reward | crafted | quest
  where = "BRD Emperor",
  questID = nil,
  dungeon = "brd",
  source = "wowhead-classic",
  confidence = "verified",
}
```

Forever talent changes mean Classic pre-raid BiS is a starting table, not gospel. Mark Forever rows `reported` until a cited guide exists. Wowhead Forever PvE tabs (mentioned by ForeverDB for level 30) are the preferred later source.

## Spec trees to cover

Warrior Arms Fury Protection. Paladin Holy Protection Retribution. Hunter BeastMastery Marksmanship Survival. Rogue Assassination Combat Subtlety. Priest Discipline Holy Shadow. Shaman Elemental Enhancement Restoration. Mage Arcane Fire Frost. Warlock Affliction Demonology Destruction. Druid Balance Feral Restoration.

Leveling default if the player has not confirmed: the damage tree (Arms, Ret, BM, Combat, Shadow, Enhancement, Frost, Affliction, Feral). Say so in the header: `Spec assumed: Shadow`.

## Dungeon insert table (planning)

Use the tighter band when sources disagree. Entrance coordinates are Classic-known except Forever rows.

| Dungeon | Band | Faction notes | Why it enters the route |
|---|---|---|---|
| Ragefire Chasm | 13–18 | Horde, Orgrimmar | Quest XP, early weapon |
| Hall of Thanes | 13–18 | Under Ironforge, Alliance-leaning | Forever, stub quests |
| Ruins of Lordaeron | 15–20 | Tirisfal, Horde-leaning | Forever, stub quests |
| Deadmines | 16–22 | Alliance, Westfall | Quest chain + caster/melee rewards |
| Wailing Caverns | 17–24 | Barrens | Druid quest, weapons |
| Shadowfang Keep | 20–30 | Silverpine | Weapons, caster offhands |
| Blackfathom Deeps | 24–32 | Ashenvale | Quest XP |
| Stockades | 24–32 | Alliance, Stormwind | Fast quests |
| Gnomeregan | 29–38 | Dun Morogh | Quest chain. Finder lists it from 29. |
| Excavation Site | 26–33 | Wetlands | Forever, stub. Finder lists 26–33. |
| Razorfen Kraul | 29–38 | Barrens | Quest. Finder lists it from 29. |
| City of Dalaran | 28–33 | Alterac | Forever, stub |
| Scarlet Monastery | 30–42 | Tirisfal | Library/armory/cath quests, BiS pieces |
| Razorfen Downs | 35–45 | Barrens | Quest |
| The Drowned City | 35–40 | Stranglethorn coast | Forever, stub |
| Uldaman | 38–46 | Badlands | Quest chain |
| Zul'Farrak | 42–50 | Tanaris | Quest, weapons |
| Krol’dok Stronghold | 40–45 | Riverglades | Forever, stub |
| Maraudon | 42–52 | Desolace | Quest, nature staff |
| Sunken Temple | 48–56 | Swamp of Sorrows | Quest chain |
| Alcaz Prison | 48–53 | Dustwallow | Forever, stub |
| Blackrock Depths | 52–60 | Burning Steppes / Searing Gorge | Quest chain, Ironfoe and other BiS |
| Blackmaw Hold | 55–60 | Azshara | Forever, stub |
| Lower BRS | 55–60 | Blackrock | Quest, BiS |
| Dire Maul | 56–60 | Feralas | Quest, class books |
| Scholomance / Stratholme | 58–60 | WPL / EPL | Quest, pre-raid BiS |
| Shaper’s Terrace | 58–60 | Un’Goro | Forever, stub |

Raid BiS (MC, Ony, BWL, ZG, AQ, Naxx, Barrow Deeps, Hyjal Summit) is a level-60 note only. Do not route into raids during 1–59.

## Reward choice

On turn-in steps, if `rewardChoice[spec]` is set, that named item wins. If that item is also BiS, prefix `BiS`.

Options has Auto pick reward. It is on unless turned off. While it is on, the turn-in takes the BiS piece, the clear upgrade, or the highest vendor price. While it is off, the dialog stays open so the player picks the item. The goal row still names the recommendation.

When the quest log or the turn-in dialog lists several choices and the route did not name one, compare them to the equipped item in that slot. Spec stat weights score the reward and the equipped piece. Item level stands in when the client has not returned stats, and that guess stays on the goal row while the reward dialog stays open. A listed BiS name or item id wins outright. A clear upgrade, scored from stats, is the recommendation and the turn-in takes it. That winner adds an Equip objective for the same item, done when a worn slot has that item id or name. A downgrade, or a tie, stays on the goal row. If nothing is an upgrade, including a piece your class cannot wear, the turn-in takes the choice with the highest vendor sell price and the row says so. That sale does not add Equip. If every sell price is 0 or not cached yet, the dialog stays open. The row shows the item icon. Mouseover is the item tooltip. Cloth on a plate class, and the other class armor mismatches, are not recommended as gear.
