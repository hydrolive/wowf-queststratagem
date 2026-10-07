# QuestStratagem data model

## Keys

A spine is selected by:

```
faction  Alliance | Horde
race     Human, Dwarf, Gnome, NightElf, HighOrder,
         Orc, Undead, Tauren, Troll, Windshaper
class    Warrior, Paladin, Hunter, Rogue, Priest,
         Shaman, Mage, Warlock, Druid
spec     tree name, or Unknown
```

File split: one spine per faction × race × class is too many files. Store:

- `Data/Classic/Alliance/<Race>.lua` shared steps
- class forks as tagged steps inside the same file (`classes = { Hunter = true }`)
- `Data/Forever/Overlay.lua` patches by quest id or by insert-after step id

Spec does not fork the zone path unless `specFork = true` on a step (warlock demon quests, hunter tame, druid bear, paladin/undead class quests). Spec always filters `bis` and `rewardChoice`.

## Step record

```lua
{
  id = "A-human-elwynn-0042",   -- stable string
  cluster = "elwynn-goldshire", -- pull siblings before leaving
  order = 42,                   -- author order inside the spine
  kind = "accept",              -- accept | objective | turnin | travel | train | hearth | fly | dungeon | note | kills | boss | talent | vendor | craft | proftrain | bank | auction
                                -- live-only: boss | talent | vendor | craft | proftrain | bank | auction
  title = "Kobold Candles",
  text = "Northshire, the mine; kill kobolds for candles.",
  zone = "Elwynn Forest",
  mapID = 1429,                 -- UiMapID if known, else nil
  x = 0.42, y = 0.68,           -- 0-1, nil if unknown
  npc = "Marshal McBride",
  npcID = 197,
  questID = 7,                  -- nil if not a quest step; NEVER invent
  objective = 1,                -- which objective, for objective steps
  requires = { "A-human-elwynn-0041" }, -- step ids
  requiresQuest = { 7 },        -- must be accepted or turned in, see requiresState
  requiresState = "accepted",   -- accepted | turnedin | not_turnedin
  exclusive = { 15 },           -- do not offer if any of these turned in
  classes = { Warrior = true, Paladin = true }, -- nil = all
  races = nil,                  -- nil = all races on this spine
  minLevel = 1,
  maxLevel = 6,                 -- skip if player already above and quest unavailable
  xp = 250,                     -- expected XP, for the clock
  minutes = 4,                  -- expected minutes at guide pace
  source = "wowhead-classic",   -- citation key
  confidence = "verified",      -- verified | reported | stub
  dungeon = nil,                -- or { id = "deadmines", entrance = {...}, quests = { } }
  rewardChoice = {              -- optional, spec keyed
    Shadow = { itemID = 0, name = "..." },
  },
  bis = {                       -- optional, also allowed via Bis tables
    Shadow = { slot = "wand", itemID = 0, name = "...", how = "reward" },
  },
}
```

`questID = 0` is forbidden. Unknown Forever quests use `questID = nil`, `confidence = "stub"`, and a text step. Resume cannot auto-complete a stub from the log; the player uses Next.

Live steps (hearth without a quest id, talent, vendor, craft, proftrain, bank, auction, boss) are built in `Live.lua` at refresh time. Do not copy them into the race files. Fields they use:

- `extraGoals` — gather lines appended after quest goals. Shape `{ name = "Gather Peacebloom", have = 0, need = 20 }`. They do not finish the step.
- `goalHeader` — yellow goals title when the step is not an accept or an objective.
- `goals` — same row shape. A trainer spell omits `need`, so the count cell stays empty.
- `hearthUse` — this hearth step means travel to the bind, not set a new one. `bind` is the `GetBindLocation()` string.
- `boss` — display name. Kill credit keys `bossDown` by this string. No `x`/`y` until a real interior pin exists.
- `talentName`, `talentRank`, `unspentAt`
- `profession`, `product` (omit when the craft has no item, never 0), `productAt`, `rankAt`, `maxAt`
- `wantSell`, `wantRepair`

A quest hearth such as 2158 still uses `kind = "hearth"` plus `questID`. That step completes only when the quest is turned in. The no-quest hearth completes from bind location or arrival. Full behavior is in MEMORY.md under "Live guide".

## Chain rules

- A chain is an ordered list of step ids sharing a `chain` string.
- Breadcrumb quests are steps with `exclusive` set to the real quest, so either path counts.
- Class quests (level 10 tame, voidwalker, bear form) are inserted when `classQuests` is on and level is in range, at the trainer or the quest giver, not at the end of the zone.
- Precursor rule lives in the router, not as duplicated steps: if step S requires quest Q turned in, and Q is not turned in, inject Q’s accept → objectives → turnin before S, using Q’s own steps.

## Cluster rule (authoring)

Steps that share a `cluster` and are available at the same hub get a `hub = true` accept batch. Example: Crossroads, Barrens. The router surfaces one “pick up all” step listing NPC names, then a grind loop, then a turn-in batch. Authors may also pre-bake that batch as one step of kind `accept` with `questIDs = { ... }`.

## Overlay

```lua
{
  op = "insert_after",          -- insert_after | replace | disable
  anchor = "A-human-elwynn-0042",
  step = { ... },
  source = "foreverdb-2026-10-02",
  confidence = "reported",
}
```

`disable` is how a Forever change removes a Classic quest that no longer exists. Until confirmed, do not disable Classic steps.

## Coverage matrix (must exist as rows, even if stub)

Alliance races: Human, Dwarf, Gnome, NightElf, HighOrder.
Horde races: Orc, Undead, Tauren, Troll, Windshaper.

Classes per race follow Forever (not Classic-only):

- Human: Warrior Paladin Rogue Priest Mage Warlock Hunter
- Dwarf: Warrior Paladin Hunter Rogue Priest Shaman
- Gnome: Warrior Rogue Mage Warlock Priest
- NightElf: Warrior Hunter Rogue Priest Druid
- HighOrder: Warrior Hunter Rogue Druid Mage
- Orc: Warrior Hunter Rogue Shaman Warlock Mage
- Undead: Warrior Rogue Priest Mage Warlock Paladin
- Tauren: Warrior Hunter Shaman Druid
- Troll: Warrior Hunter Rogue Priest Shaman Mage Warlock
- Windshaper: Warrior Hunter Rogue Druid Shaman

Starting zone by race: Elwynn, Dun Morogh, Dun Morogh (Gnome), Teldrassil, Zephras Isle, Durotar, Tirisfal, Mulgore, Durotar (Troll), Zephras Isle.

Level 1 through the first town is authored for every race above. Human is Elwynn. Dwarf and Gnome share Coldridge through the Kharanos hearth. Night Elf is Shadowglen through Dolanaar. Orc and Troll share Durotar. Undead is Deathknell through Brill. Tauren is Camp Narache through the Bloodhoof hearth, and a Tauren Hunter opens on quest 747. HighOrder and Windshaper stay Zephras notes with no quest id. A class with no Classic starter quest (Human Hunter, Undead Paladin, Dwarf Shaman, Gnome Priest, and the same kind of note already on the Orc and Troll spine) gets that note, not an invented id. A race that still has no spine falls back to Human or Orc and says so. The road after the first town is not authored.

Zone bands to cover for the 1–60 goal (Classic spine):

- Alliance 1–12 starter → 10–20 Westfall / Loch Modan / Darkshore → 15–25 Redridge / Darkshore coast → 20–30 Duskwood / Wetlands / Ashenvale / Stonetalon → 30–40 Stranglethorn / Desolace / Arathi / Thousand Needles → 40–50 Tanaris / Feralas / Hinterlands / Searing Gorge → 50–60 Ungoro / Felwood / Winterspring / WPL / EPL / Burning Steppes / Silithus.
- Horde mirror: starter → Barrens / Silverpine → Stonetalon / Hillsbrad → Thousand Needles / Ashenvale → Stranglethorn / Desolace / Arathi → same 40–60 contested set, plus Badlands and Swamp of Sorrows.

Forever zone inserts, stub until sourced: Zephras Isle 1–12 (Skyborne only), new quests in starter zones and Wetlands and Desolace from level 5, Mount Hyjal, Shen’dralas, Riverglades at their published bands.

## IDs

Classic quest IDs must match Wowhead Classic. If a step’s id cannot be cited, the step does not ship in `confidence = "verified"`.
