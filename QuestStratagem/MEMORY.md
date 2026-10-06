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
2. Next action is always one of: pick up from a named NPC in a named zone, go to an objective, turn in, train, set hearth, fly, or enter a dungeon.
3. Every size of the window has the arrow.
4. Right-click cycles Large → Medium → Small → Large.
5. Next and Back are manual. Accept, objective complete, and turn-in still auto-advance.
6. On load, rebuild the frontier from the quest log and completed-quest flags. Never send the player to a quest already turned in.
7. Path is zone-cluster optimized: pull precursors before leaving a hub if a later step returns there.
8. Dungeon steps exist only when quest XP, a quest chain, or a BiS item justifies them. Forever dungeon mob XP is reduced; dungeon quest XP is raised.
9. If a quest reward or boss drop is BiS for the confirmed spec, the goals block says so and names the item. The goal is the item, not “finish the dungeon.”
10. Time goal is an estimate to 60. Actual tracked time sits beside it.
11. Target is the fastest reasonable 1–60 on WoW Forever, not a tourism route and not a dungeon grind.
12. Data is versioned. Classic IDs are the spine. Forever-only quests are overlays with a confidence flag.

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
