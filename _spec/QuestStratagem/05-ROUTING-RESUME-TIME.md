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
9. Hand the list to Resume. Pull forward, then `Level.Apply` (skipped for the demo route).
10. After the level plan, `Live.Apply` may copy steps to attach `extraGoals` and insert the town, talent, profession, and bag block.
11. `Area.Apply` then puts the quest-log area at the front and drops profession train steps for that rebuild. Demo mode skips Live and Area. Detail is in MEMORY.md, "Live guide", "Level plan", and "Area focus". Choose the index after that.

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

- Player level is inside the dungeon’s `min`–`max` (or within 1 below min).
- Faction matches, when the row has a faction.
- `dungeonDetours` is on, and this dungeon id is not skipped.
- The row has at least one quest id, or a boss list. Classic rows currently have empty quest lists and a boss list, so the window still inserts.

Shape:

1. `accept` at the giver, only when quest ids exist.
2. `travel` to the entrance. `completeOnZone` is the instance zone name. Entrance coordinates are reported, so `pin` is `approx`.
3. One `boss` step per name in the kill order. Each goal is that boss name, `0/1`. These steps have no quest id and are not BiS.
4. If there is no boss list, one `dungeon` note instead.
5. `turnin` outside, only when quest ids exist.

The block is inserted before the first step with `minLevel` at least the dungeon minimum. Starter steps sit at level 1, so a high dungeon appends at the end. A level 5 does not receive Ragefire.

While the player's zone equals `insideZone`, unfinished boss steps for that instance are pulled to the frontier even if detours are off or the level is outside the band. A dungeon this level deferred still surfaces that way once the player is standing inside it.

Skipping a boss is Next. Kill credit is the hostile-death chat line, when the name matches. There is no interior pin in this data version, so the arrow hides and the distance line names the boss.

When the level plan has no in-band quest left, only one of those dungeon windows stays active. The others are marked `levelDefer`. The closest midpoint wins. Horde level 27 keeps Razorfen Kraul and defers Blackfathom Deeps. Kill steps then fill the rest of the XP bar at that level's hub. They are not invented quests. The step text says the quest ids are not authored. While in-band quests remain, no kill step is inserted and dungeons are not deferred. Forever dungeon stubs stay out unless `includeStubs` is on. The nine Forever dungeons wait on public quest ids.

## Resume

On load and on quest events:

1. Read quest log. Classic: `GetNumQuestLogEntries` / `GetQuestLogTitle` (questID is a return). If `C_QuestLog.GetNumQuestLogEntries` exists, use it.
2. Completed set = our `turnedIn` mirror, union client completed if the probe works (`GetQuestsCompleted` or `C_QuestLog.IsQuestFlaggedCompleted`).
3. A step is done if:
   - `levelDefer` is set (another dungeon, or the unauthored next-band note, while this level has no in-band quest)
   - grey: player level minus content level is greater than the green range. Starter quests stay visible through the range. See MEMORY.md, "Level plan"
   - kills: the player has dinged past `atLevel`, or `UnitXP` has reached `xpMark` on that level. The last chunk has no mark and finishes on ding
   - area: every quest id on the step has left the log
   - accept: questID in log or in completed. A step with a quest name and no id is done when the log shows that title
   - flight: the taxi map has recorded that node, or the zone name, since this character opened a flight master. Opening the map is the only way to know a path is already learned. `kind` `fly` is still the old "enter the zone" step. Do not use it for learning a flight path
   - weapon, armor, dual, and opportunity: not auto-done. Next dismisses that reminder. These do not go grey because of the zone's starter level
   - objective: completed flag, or log objective done
   - turnin: questID in completed (log presence does not count)
   - travel/fly/note: done only by Next, or by entering the target zone if `completeOnZone` set
   - dungeon: done if all attached questIDs are completed; `bisRequired` also needs the item. With no quest ids, Next is the way out
   - hearth with no quest id: set-hearth is done when `GetBindLocation()` equals `bind`. Use-hearth is done when the player is in that zone
   - hearth or turn-in or class `train` with a quest id: done only when that quest is completed. Log presence does not count
   - talent: unspent dropped below `unspentAt`, or the named talent's rank reached `talentRank`
   - vendor: still open while a requested sell has 3 or fewer free slots, or a requested repair is under 25% durability
   - boss: `bossDown[name]`
   - craft: product count rose above `productAt` when a product id exists, or skill rank rose above `rankAt`
   - proftrain: skill max rose above `maxAt`
   - bank and auction: not auto-done. Next dismisses that inventory snapshot
4. First not-done, not-skipped step is the index.
5. If Back set `manualStepId`, honor that step until an auto-complete moves the frontier past it. A grey or `levelDefer` manual hold is cleared and the frontier is used. A finished quest that is still in color can still show `Already done`.
6. Off-route quests in the log: if they match any step in the next two clusters, pull those steps forward. Otherwise ignore them. Do not abandon.
7. If the frontier is past every step at this level band and the player is under 60, show the next band’s first travel step.

Never point at an NPC for a quest in the completed set. If the only remaining step in a chain is a turn-in and the quest is already complete in the log, point at the turn-in NPC.

## Next and Back

- The character stores the last 20 steps (`history`), including a step that auto-advanced because the quest left the log. The first rebuild after login does not invent a previous step. If Elder Knowledge, quest 95664, is already complete and the history is empty, one snapshot of the Bashana Runetotem turn-in is stored.
- Next, while you are on the live step: mark the current step id skipped, remember it, and advance. An area step also skips the travel step for that same area. Does not abandon.
- Back: show the previous stored step, even when that id is no longer in the built route. Status reads `Review`. The button is hidden when you are on the live step and the history is empty, or when you are already on the oldest stored step.
- Next while reviewing walks toward the live step. It does not skip the quest you are actually on. The last Next in the history returns to that live step.

## Clock

- Actual: sum of time while the frame is loaded and the player is logged in, persisted every 30s and on logout. This is not `/played` (addons cannot read `/played` reliably). Label it `Tracked`, not `/played`.
- Leg: time and XP from step start to step complete. XP from `UnitXP` delta plus `GetXPExhaustion` ignored. Level-up crosses add `UnitXPMax` of the old level.
- Goal: `72 * 3600 * classMod * paceMod` seconds.
  - pace: guide 1.0, steady 1.5, first 2.5
  - classMod starting point (leveling pace, not raid): Hunter 0.90, Warlock 0.95, Mage 0.95, Druid 1.00, Rogue 1.00, Paladin 1.05, Shaman 1.05, Priest 1.10, Warrior 1.15
- Display on the large header while a level plan exists: `L28 in 42m · 12,400/24,800`. That is the next level, a guess of the remaining quest, dungeon, and kill time on this bar, and `UnitXP` / `UnitXPMax`. Under an hour the guess is minutes. At 60 the line is `L60 · xp/xpMax`. The tooltip says the guess is scaled by class and pace.
- The 72h-to-60 goal line (`Goal 79h · Tracked … · L27` for a priest on guide pace) is only the demo route, which has no level plan. Pace and class still scale the level guess: guide 1.0, steady 1.5, first 2.5, and the class mods above.
- Last leg line: `Last leg: 40 min · +1,076 XP`
- Demo tooltip: remaining expected minutes on not-done steps. Level-plan tooltip: the same guess as the header.

These modifiers are planning numbers, not measured Forever rates. Replace them when the clock has real samples; do not pretend they are precise.
