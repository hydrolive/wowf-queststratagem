# QuestStratagem — context memory

Last updated: 2026-10-05. This file is the resume point. Read it before changing the addon, the data, or the prompt.

## What this is

QuestStratagem (slash: `/qs`) is an offline World of Warcraft addon for **WoW Forever**. It is a precomputed leveling stratagem, not an AI companion.

Visual reference only: Tommy Geoco’s Bones panel (`@designertom`, post `2106872113843875996`, 2026-10-04, neverquestalone.com). That addon reads the quest log, prioritizes, draws a route, and has an Ask button backed by a user-supplied AI key. QuestStratagem keeps the arrow, distance, route progress, and goals panel. It drops Ask, the network, and any model call.

Strategic reference: RestedXP Guides (step lists, class tags, accept/complete/turnin, sticky steps, dungeon detours, time tracker). QuestStratagem does not parse RXP text at runtime. It ships its own graph and advances itself from the quest log.

## Player

David Kimball (`@cyberdyneceo`). Horde priest healer is the recent live spec context (raiding, resto shaman professions also in play). The addon must not assume that character. Faction, race, class, and spec are confirmed in config and stored per character.

## Product rules that do not drift

1. Offline. No HTTP, no AI key, no Ask button, no companion chat.
2. Next action is one of: pick up from a named NPC in a named zone, go to an objective, turn in, train a class skill, set or use the hearth, fly, enter a dungeon, spend the next talent point, train a profession, craft, sell or repair, bank, auction, or kill a named boss.
3. Every size of the window has the arrow.
4. Right-click cycles Large → Medium → Small → Large.
5. Next and Back are manual. Accept, objective complete, and turn-in still auto-advance.
6. On load, rebuild the frontier from the quest log and completed-quest flags. Never send the player to a quest already turned in.
7. Path is zone-cluster optimized: pull precursors before leaving a hub if a later step returns there.
8. A dungeon is on the route when quest XP, a quest chain, or a BiS item justifies it, or when the player is walking a named boss order. Boss steps are kills. They are not quests and they are not BiS checks. Forever dungeon mob XP is reduced; dungeon quest XP is raised. Do not add a grind-for-XP loop.
9. If a quest reward or boss drop is BiS for the confirmed spec, the goals block says so and names the item. The goal is the item, not “finish the dungeon.”
10. Time goal is an estimate to 60. Actual tracked time sits beside it.
11. Target is the fastest reasonable 1–60 on WoW Forever, not a tourism route and not a dungeon grind.
12. Data is versioned. Classic IDs are the spine. Forever-only quests are overlays with a confidence flag.
13. Town and profession guidance is part of the route. Set the hearth at a new hub. Hearth back when turn-ins are in the bound town. Name the next talent for the spec when a point is unspent. With profession steps on, point at the profession trainer and list the spells for that rank, remind a craft when the materials are in the bags, and keep a gather line on quest steps so gathering stays level with the route. Full bags get sell and repair. A city with a bank lists what to bank and what to auction.

## World facts locked 2026-10-05

- WoW Forever: official Classic-plus. Launch 4 Nov 2026, 15:00 PST. Cap 60, not raised. No flying, no level scaling. XP to 60 unchanged from Classic (~4,084,700 to finish 59). Dungeon kill XP down, dungeon quest XP up.
- Beta client around `1.60.1.70170`. Beta cap raised 20 → 30 on 1 Oct 2026. Beta does not carry to launch.
- New zones: Zephras Isle (Skyborne 1–12), Mount Hyjal, Shen’dralas, The Riverglades.
- New race: Skyborne. High Order = Alliance (Mage, not Shaman). Windshaper = Horde (Shaman, not Mage). Both: Warrior, Hunter, Rogue, Druid. Paid unlock.
- New race/class combos: Dwarf Shaman, Gnome Priest, Human Hunter, Orc Mage, Troll Warlock, Undead Paladin.
- Nine new dungeons (ranges differ by a couple levels across sources; store both and prefer in-game): Hall of Thanes 13–18 Ironforge; Ruins of Lordaeron 15–20 Tirisfal; Excavation Site: Wetlands 24–31; City of Dalaran 28–33 Alterac; The Drowned City 35–40 Stranglethorn; Krol’dok Stronghold 40–45 Riverglades; Alcaz Prison 48–53 Dustwallow; Blackmaw Hold 55–60 Azshara; Shaper’s Terrace 58–60 Un’Goro.
- Raids from 9 Dec 2026: Barrow Deeps (10), Hyjal Summit (20), plus Onyxia 40. Out of scope for 1–60 routing except as a level-60 note.
- 1,000+ new quests announced. Public databases are incomplete. Do not invent quest IDs.

## Time budget used for the goal line

Classic experienced questing ~100–120 hours /played. Optimized solo ~65–78 hours (record-class ~78h real time). First-timer 150–240h. QuestStratagem default goal is the optimized-guide band: **72 hours to 60**, scaled by class pace modifiers, shown against actual addon-tracked time. Not a promise.

## Docs map

| File | Role |
|---|---|
| `00-GOALS-AND-PLAN.md` | Why, success, phases, non-goals |
| `01-ULTIMATE-BUILD-PROMPT.md` | Paste into Grok Build |
| `02-UI-SPEC.md` | Three sizes, copy, arrow |
| `03-ARCHITECTURE.md` | TOC, files, events, saved vars |
| `04-DATA-MODEL.md` | Chains, keys, step schema |
| `05-ROUTING-RESUME-TIME.md` | Optimizer, resume, clocks |
| `06-BIS-DUNGEONS.md` | Spec loot and dungeon windows |
| `07-API-CONSTRAINTS.md` | Classic-lineage API, legal |
| `08-UPDATE-LOOP.md` | How later Grok sessions patch data |
| `09-PHASES.md` | Build order and acceptance |

## Live guide (design)

Live steps are rebuilt on every route refresh in `Live.lua`. They are not written into the race files. The router still owns the quest graph. Rebuild order: `Router.Build`, quest snapshot, `Resume.PullForward`, `Live.Apply`, `Resume.Choose`, BiS annotate, clock, UI.

`Live.Apply` copies a step only when it attaches gather lines (`extraGoals`). Shared Orc/Troll tables are not mutated. `/qs demo` skips Live entirely.

Inserted at the first open step, in this order, so the first one is what the player sees:

1. Talent, when a point is unspent.
2. Sell or repair, when free bag slots are 3 or fewer, or average durability is under 25%.
3. Set hearth, then use hearth.
4. Up to four profession trainers.
5. One craft reminder.
6. Bank, then auction, when the player is in a city.

Inside a dungeon, that dungeon's unfinished boss steps are pulled in front of this block.

Gather, craft, and trainer steps honor the Profession steps toggle. It defaults on. Hearth, talent, vendor, bank, auction, and bosses stay on when the toggle is off.

Next writes `skips[id]`. A live step returns when its id changes, or when the code clears that skip (unspent talents changed, the craft recipe changed, bags recovered, the bind is already set).

### Hearth

Set hearth when the frontier step's hub or cluster matches an inn, or the player is standing in that inn's subzone; the player meets the inn's minimum level; `GetBindLocation()` is not already that bind; and the next 15 steps do not already contain an open quest hearth in that zone. That keeps Goldshire from doubling quest 2158 and Razor Hill from doubling 2161. Northshire's hub does not match Goldshire.

Use hearth when the frontier is a turn-in, or a hearth step that still has a quest id, the bound inn is in that step's zone, and the player is in another zone. The arrow points at the inn. If the hearthstone is on cooldown, the body shows the remaining seconds. The step completes when the player is in the inn's zone. Being in the quest log does not complete a use-hearth step.

Innkeeper Farley and Innkeeper Grosk use the starter-quest coordinates (`pin = npc`). Every other inn coordinate is reported (`pin = approx`).

### Talents

From level 10, with at least one unspent point, the step names the next talent in the leveling order for the active spec. Orders live in `Data/Services.lua`. A talent name the client does not have is skipped. If the next name is locked, the text says that tree needs more points, and a later available talent in the order is preferred. If the order is used up, the step says to spend the rest in that spec.

Colliding tree names are split: Paladin Protection, Priest Holy, Shaman Restoration, Druid Restoration. Warrior Protection and Paladin Holy keep the plain keys.

The step completes when unspent points drop, or that talent's rank reaches the recommended rank. Next hides it until the unspent count changes.

These orders are reported Classic leveling paths. They are not a sim and they are not adjusted for Forever.

### Profession trainer

Tracked skills: Herbalism, Mining, Skinning, Alchemy, Blacksmithing, Engineering, Enchanting, Leatherworking, Tailoring, Cooking, First Aid, Fishing. Defense and weapon skills are ignored.

In a city, up to four of those get a step. Stormwind and Orgrimmar have a trainer pin. Other cities point at a reported center and the text says to ask a guard. Goals are the spell names for the current cap bracket: 75, 150, 225, or 300. Those lists are the leveling set, not the whole catalog.

Away from a city, a trainer step appears only when rank is within 5 of the cap and the cap is still under 300. The arrow then points at Stormwind for Alliance or Orgrimmar for Horde.

A skill at 300/300 is silent. Next dismisses that city, profession, and bracket until the cap changes.

### Craft

One reminder. Check Alchemy, Blacksmithing, Engineering, Enchanting, Leatherworking, Tailoring, First Aid, then Cooking. Take the first recipe whose rank is still under `untilSkill`, within 25 skill of the recipe, and whose reagents are all in the bags for at least one craft. Goals are each reagent `have/need`, then `Craft {name} 0/N`, capped at the points left in that band. Cooking adds "Stand at a fire."

Enchant Bracer - Minor Health stores no product item id. Completing it is the skill rank moving. Item id 0 is forbidden.

Next hides that reminder until the recommended recipe changes.

Reagent counts are the usual Classic spam path. They were not re-checked against a spell database.

### Gather

On accept, objective, turn-in, travel, train, hearth, fly, dungeon, and note steps, when the zone is not a city, up to three extra goals are drawn after the quest goals. They do not replace objective text and they do not finish the step.

Herbalism and Mining use nodes in that zone whose skill sits between rank − 50 and rank + 25, keeping the two highest. Skinning is not tied to the zone: the leather whose skill band contains the current rank (scraps, light, medium, heavy, thick, rugged). The line is `Gather Peacebloom` with count `0/20`. Have is the bag count, capped at 20. The same 20 is what the bank step leaves in the bags.

Herb and ore rows cover the old-world zones used while leveling. A zone with no row adds no gather line for that skill.

### Sell, repair, bank, auction

Sell or repair when free slots are 3 or fewer, or durability is under 25%. The arrow goes to the inn for the current zone, otherwise the faction capital. The Barrens fallback is the first inn in that zone (Crossroads). Goals name up to four grey items, plus Repair when durability is low. The step leaves the route once the bags have more than 3 free slots and durability is back above 25%.

Bank and auction appear in Stormwind, Ironforge, Darnassus, Orgrimmar, Thunder Bluff, Undercity, Booty Bay, Gadgetzan, and Everlook. Booty Bay matches the subzone. Ratchet has an inn and does not get these steps.

Bank a stack over 20 when the item class is Trade Goods, Recipe, Reagent, or Consumable. Auction green-or-better weapons and armor that are not known to be soulbound. If the client does not report bound, the item is listed, and the text says to leave anything soulbound out. Quest items, keys, and the hearthstone are skipped. Next dismisses that snapshot (the first five item ids and counts). A different snapshot shows again.

Item class names are the English client strings.

### Bosses

Kind `boss`. Not a quest. Not `bisRequired`. Goal header `Boss`. One goal: the boss name, `0/1`. Id `boss-{dungeonId}-{index}`.

The dungeon window inserts when detours are on, level is inside the band or one under the minimum, faction matches, and the dungeon has quests or a boss list. Classic rows have empty quest lists, so the window is the entrance plus one step per boss. Accept and turn-in are added only when quest ids exist. The window goes before the first step whose `minLevel` is at least the dungeon minimum, otherwise at the end of the route. A level 5 does not get Ragefire Chasm.

When the player zone equals that dungeon's `insideZone`, unfinished boss steps for that instance move to the front even if detours are off or the level is outside the band.

Kill credit listens to `CHAT_MSG_COMBAT_HOSTILE_DEATH` for `{name} dies.` or `slain {name}!`. Anything else needs Next.

No interior coordinate is stored. The arrow hides in an instance. The distance line reads `Inside · {boss}`. A wrong pin is worse than no pin.

Lists are shortened reported kill orders. Deadmines includes Sneed's Shredder, then Sneed. Scarlet Monastery is one short list, not four wings.

## Level plan

`Level.Apply` runs after pull-forward and before `Live.Apply`. Demo mode skips it. The header is no longer the 72h-to-60 line while a level plan exists. It reads `L28 in 42m · 12,400/24,800` (next level, a guess of the time left on this bar, then `UnitXP` / `UnitXPMax`). At 60 it reads `L60 · xp/xpMax`. Hovering that line says the number is a guess. Class and pace still scale it. The old `Goal 79h` line remains only when there is no level plan (the demo route).

A step is skipped when it is grey: player level minus content level is greater than `GetQuestGreenRange()`, or the fallback when that function is missing. The fallback is 5 through level 10, then scales to 12 at 60. Level 27 is 7. Content level is `questLevel`, else `atLevel`, else the dungeon band midpoint, else `minLevel`, else `maxLevel`, else a starter-zone level (Durotar and the other starter zones are 6). Missing content level is not grey. Kills, talents, vendors, crafts, trainers, bank, auction, and a hearth with no quest id are never grey. A level 6 character still sees a level-1 starter quest (difference 5 is not greater than 5). A level 27 character skips Sting of the Scorpid (quest 789, Durotar, content 6) even when the completion API is empty.

`QueryQuestsCompleted` runs on login and entering the world when the client has it. `QUEST_QUERY_COMPLETE` rebuilds. Turn-in tracking from 0.1.1 is unchanged.

The bar is this level's XP, not the cluster count. The gold width is the XP already earned. The rest is split into the work that finishes the bar: one slice per in-band quest, up to eight dungeon bosses, then kill chunks. The first unfinished slice is bright. At most 16 slices. The route index reads the percent, matching the XP bar. XP ticks move the bar and a kill goal without a full rebuild. Crossing a kill mark or dinging rebuilds.

In-band means an accept, objective, or turn-in that is not done, not grey, and whose content level is at most player level + 3. While any of those exist, the route name stays, dungeons are not deferred, and no kill step is inserted in front of the chain. If those quests do not fill the remaining XP, the bar adds a slice named `Kills beside the quests` with no step, so the arrow stays on the quest. A real level 4 in Durotar still follows Durotar.

When nothing in band is left, the route name becomes `Level 27 · Thousand Needles`. One dungeon stays: among the windows actually inserted, not cleared, not grey by midpoint, inside the level band, the closest midpoint wins, and a higher minimum breaks a tie. At Horde 27 that is Razorfen Kraul (24–32, midpoint 28). Blackfathom Deeps (midpoint 24) is deferred, and so is the "next band is not authored" step. Other dungeon steps get `levelDefer`, which resume treats as done. The door text says mobs in the level's zone finish the bar. If less than 20% of the level remains, the dungeon is skipped and only kills fill the bar. Bosses already in `bossDown` count as cleared.

Kill steps are new tables, ids `dyn-kills-{level}-{n}`, kind `kills`. They are inserted after the chosen dungeon. Each chunk is about 10% of the level, one to four steps. A chunk finishes when `UnitXP` reaches its mark, or on ding for the last chunk. The arrow points at a reported hub with `pin = "approx"`. The text says quest ids for that band are not in the guide, grey quests are skipped, and this finishes the bar. Horde hubs: 1–12 The Crossroads, 13–22 Camp Taurajo, 25–28 Freewind Post (the note says Hillsbrad is the other road), 29–36 Grom'gol, 37–44 Gadgetzan, 45–52 Marshal's Refuge, 53–60 Everlook. Alliance: 1–12 Sentinel Hill, 13–20 Thelsamar, 21–28 Darkshire, 29–36 Booty Bay, then the same Tanaris and Un'Goro hubs, 53–60 Light's Hope Chapel. Those coordinates are approximate.

Planning numbers, not measured Forever rates: a same-level kill is `45 + 5 * level` XP (180 at 27) and about 22 seconds. A quest slice defaults to 8 minutes, scaled if it is clipped. A boss slice is about 4 minutes. The dungeon is about 35% of the level's XP, capped by what is left.

Back onto a grey or deferred step does not stick. Resume clears that manual hold and returns to the frontier. Back onto a finished quest that is still in color still shows `Already done`.

Standing inside an instance still pulls that instance's unfinished bosses forward, including a dungeon this level deferred. Those fresh boss steps are not deferred.

## Implemented in 0.1.1

Shipped in the addon at version 0.1.1, Interface 16001, taken from a working Forever addon. The footer string is unchanged: `Data classic-1.12 + forever-2026-10-05`.

- Phase A shell: three sizes, arrow, config, resume, clock, `/qs` commands, no Ask, no network.
- Human Elwynn and shared Orc/Troll Durotar through about level 6, with cited Classic quest ids. Other races are keys. Skyborne is text-only on Zephras Isle. No invented Forever quest ids.
- Live guide above: hearth, talent, trainer, craft, gather lines, sell/repair, bank, auction, boss steps.
- `professionSteps` defaults on. The first load of 0.1.1 sets `liveRev = 1` and turns profession steps on for a character saved by 0.1.0. After that, turning the toggle off sticks.
- Boss windows insert from the boss list even though dungeon quest id lists are still empty.
- Lua files for this pass were parsed as Lua 5.1. Nobody logged the addon into the Forever client during this pass. `/qs api` prints bind location, free slots, and skill lines so the next login can confirm them.

## Implemented in 0.1.2

Shipped in the addon at version 0.1.2, Interface 16001. The footer string is unchanged: `Data classic-1.12 + forever-2026-10-05`.

- Level plan above. Grey steps drop out, including Sting of the Scorpid at level 27 when the client has not reported it complete. The header estimates time to the next level. The bar matches `UnitXP` / `UnitXPMax`.
- Login calls `QueryQuestsCompleted` when that function exists, and `QUEST_QUERY_COMPLETE` rebuilds. `/qs api` also prints `GetQuestGreenRange`.
- A level with no authored in-band quest keeps one dungeon and kill steps at that level's hub. It does not invent Thousand Needles, Barrens, or Hillsbrad quest ids.
- Lua files for this pass were parsed as Lua 5.1, and the level-27 path was executed outside the client with stubbed unit functions. Nobody logged the addon into the Forever client during this pass.

## Still todo

- Interior boss coordinates, so the arrow can point at each boss. Do not invent them.
- Full optional boss lists, and Scarlet Monastery as separate wings.
- Trainer pins for capitals other than Stormwind and Orgrimmar, and for towns that are not capitals.
- Confirm inn coordinates other than Farley and Grosk. Confirm `GetBindLocation()` strings (`Stormwind City` versus `Trade District`, and the same for other cities). If `/qs api` prints a different bind string, the set-hearth step will not complete.
- Re-check recipe reagent counts and the spell lists against a public spell page.
- Dungeon entrance coordinates are reported. Confirm them before calling a pin exact.
- English-only item class and death-message matching. Localization is open.
- Classic `GetContainerItemInfo` may not return bound. Unbound-unknown greens then show on the auction step, with the soulbound warning.
- Author the 1–60 quest spine. Barrens, Silverpine, Thousand Needles, Hillsbrad, and the rest are not in this data version. Until they are, a level with no in-band quest shows one dungeon plus kill steps, and the step says the quest ids are missing. Zone hub coordinates on those kill steps are approximate.
- Gather quotas are a flat 20, not tuned per herb.
- Talent orders are reported, not simulated, and not Forever-adjusted.
- Warlock route can stall before Sen'jin because quest 805 requires 794, and 792 is omitted for warlocks. Known, not fixed.
- In-game pass: load at level 27 and confirm Valley of Trials is gone, the header is time to 28, and the bar sits near the current XP. Also load a level 1–6 character and confirm the starter chain is still there. Set hearth in Goldshire, spend a talent, train, craft, fill bags, and walk a boss step. This session did not log in.
- The green-range fallback is approximate when `GetQuestGreenRange` is missing. The level ETA is a guess from the planning numbers above, not measured kill times.
- Forever dungeon quest ids, when a public page names them. Until then those dungeons stay stubs and do not insert. Classic dungeon quest id lists are still empty; the window is the boss order.

## Open gaps (do not paper over)

- Forever quest IDs, NPC IDs, and coordinates for new zones are not stable.
- Excavation Site level band is 24–29 in one source and 26–31 in another.
- Spec is not an API. Talent points can suggest it; the player confirms.
- `IsQuestFlaggedCompleted` / `C_QuestLog` may or may not exist on the Forever client. Probe at load; fall back to quest-log scan plus our own turn-in log.
- Interface version in the TOC must be taken from a working Forever addon, not guessed forever.

## Decision log

- 2026-10-05: Offline only. Bones is layout reference, not a dependency.
- 2026-10-05: Classic graph is v1 spine; Forever content is `overlay` records with `confidence`.
- 2026-10-05: One route per faction × race × class, with spec as a filter on class quests, reward choice, and BiS — not a fully separate 1–60 for every spec unless a class quest forks the zone path.
- 2026-10-05: Right-click cycles size. No Ask. Next/Back always available in Large.
- 2026-10-05: Live town, talent, profession, bag, and boss steps are rebuilt in `Live.lua`. They are not baked into the race files. Demo mode does not run Live.
- 2026-10-05: A boss step names the kill. It is not a quest and not a BiS check. Interior coordinates are not invented. The distance line names the boss and the arrow stays hidden.
- 2026-10-05: Profession steps default on. `liveRev` flips a 0.1.0 character to on once, then a manual toggle sticks.
- 2026-10-05: TOC Interface is 16001, from a working Forever addon. The footer string stays `Data classic-1.12 + forever-2026-10-05`.
- 2026-10-05: HereBeDragons is used only when another addon already loaded it. It is not vendored.
- 2026-10-05: A level is the plan boundary. Grey quests drop out. The header estimates time to the next level, and the bar matches this level's XP. Missing mid-level quest ids stay missing; the step is a dungeon plus kills.
