# Routing, resume, and the clock

## Build

`Router.Build(char)`:

1. Load spine for faction + race + class.
2. Apply Forever overlays with `confidence ~= stub` unless config `includeStubs` (default off).
3. Drop steps whose `classes` / `races` miss.
4. Drop steps whose `exclusive` quest is turned in.
5. Inject class-quest chains at their minLevel anchor.
6. Inject dungeon windows (see `06-BIS-DUNGEONS.md`).
7. Run precursor injection.
8. Run cluster batching.
9. Hand the list to Resume.

## Precursor injection

Walk the list. For each step with `requiresQuest` not satisfied:

- Find the chain that grants that quest (accept step with that questID).
- If missing from the current list, pull it and its objective and turnin steps.
- Insert them immediately before the dependent step, stable-sorted by `order`.
- Cap depth at 8 to avoid loops. Log a debug line if the cap hits.

This is what “if a chain leads you to an area, do the precursors so the path is optimized” means. Combined with clusters: when any inserted step shares a cluster with steps already scheduled in the next 15 steps, move the whole cluster accept-batch up to the first visit.

## Cluster batching

Group consecutive available accepts in the same `cluster` into one pickup step:

- Title: `Pick up at The Crossroads`
- Text: NPC names and quest names, one per line in the goals block
- Completes when all listed questIDs are in the log or already turned in
- Then objectives, nearest-first re-sort inside the cluster only
- Then one turn-in step

Do not re-sort across clusters. Author order is the travel order.

## Dungeon windows

Insert when all are true:

- Player level is inside the dungeon’s `min`–`max` (or within 1 below min, as a “pick up quests” step).
- At least one dungeon quest is available for this faction, or a BiS item for this spec drops inside.
- `dungeonDetours` is on.
- The step is not already skipped.

Shape:

1. `accept` dungeon quests at the named giver, with zone.
2. `travel` to entrance, with coordinates, distance arrow.
3. `dungeon` note: bosses in order, quest objectives, BiS rows.
4. `turnin` outside.

If the player is solo and the dungeon is not soloable, the text says `group` and the clock adds the dungeon’s group minutes. Skipping is one Next, remembered.

Forever bias: do not insert “grind this dungeon for XP.” Insert for quest XP and BiS only. Classic dungeons used this way: RFC, WC, DM (both), Stockades, SFK, BFD, Gnomer, RFK, SM library/armory/cath, RFD, Uldaman, ZF, Mara, ST, BRD, LBRS, Scholo, Strat, DM (Dire Maul). Plus the nine Forever dungeons when their quest IDs exist.

## Resume

On load and on quest events:

1. Read quest log. Classic: `GetNumQuestLogEntries` / `GetQuestLogTitle` (questID is a return). If `C_QuestLog.GetNumQuestLogEntries` exists, use it.
2. Completed set = our `turnedIn` mirror, union client completed if the probe works (`GetQuestsCompleted` or `C_QuestLog.IsQuestFlaggedCompleted`).
3. A step is done if:
   - accept: questID in log or in completed
   - objective: completed flag, or log objective done
   - turnin: questID in completed (log presence does not count)
   - travel/note: done only by Next, or by entering the target zone if `completeOnZone` set
   - dungeon: done if all attached questIDs completed, or Next
4. First not-done, not-skipped step is the index.
5. If `manualIndex` is set by Next/Back, honor it until an auto-complete moves the frontier past it.
6. Off-route quests in the log: if they match any step in the next two clusters, pull those steps forward. Otherwise ignore them. Do not abandon.
7. If the frontier is past every step at this level band and the player is under 60, show the next band’s first travel step.

Never point at an NPC for a quest in the completed set. If the only remaining step in a chain is a turn-in and the quest is already complete in the log, point at the turn-in NPC.

## Next and Back

- Next: mark current step id skipped, advance. Does not abandon.
- Back: clear skip on previous step, set manual index there. If that quest is already turned in, Back still shows it but the status reads `Already done` and the next auto event will hop forward again unless the player is reading it.
- X on the route row clears the skip on the current step only.

## Clock

- Actual: sum of time while the frame is loaded and the player is logged in, persisted every 30s and on logout. This is not `/played` (addons cannot read `/played` reliably). Label it `Tracked`, not `/played`.
- Leg: time and XP from step start to step complete. XP from `UnitXP` delta plus `GetXPExhaustion` ignored. Level-up crosses add `UnitXPMax` of the old level.
- Goal: `72 * 3600 * classMod * paceMod` seconds.
  - pace: guide 1.0, steady 1.5, first 2.5
  - classMod starting point (leveling pace, not raid): Hunter 0.90, Warlock 0.95, Mage 0.95, Druid 1.00, Rogue 1.00, Paladin 1.05, Shaman 1.05, Priest 1.10, Warrior 1.15
- Display on large header: `Goal 68h · Tracked 6h 12m · L14`
- Last leg line: `Last leg: 40 min · +1,076 XP`
- ETA from remaining expected minutes on not-done steps, shown in the tooltip of the goal line.

These modifiers are planning numbers, not measured Forever rates. Replace them when the clock has real samples; do not pretend they are precise.
