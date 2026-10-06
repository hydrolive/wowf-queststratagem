# QuestStratagem architecture

Classic-lineage addon. Lua 5.1. No vendored libraries. If HereBeDragons-2.0 is already loaded through LibStub, the arrow uses it. Otherwise the arrow uses `UnitPosition` or `C_Map` on the same map. Do not vendor Questie.

The planning TOC below the shipped list used Interface 11507 and a single Alliance file. That placeholder is retired. The running addon uses Interface 16001, copied from a working Forever addon.

## Shipped TOC (0.1.2)

```
## Interface: 16001
## Title: QuestStratagem
## Notes: Offline 1-60 stratagem for WoW Forever. Arrow, chains, BiS.
## Author: QuestStratagem
## Version: 0.1.2
## SavedVariables: QuestStratagemDB
## SavedVariablesPerCharacter: QuestStratagemCharDB
## OptionalDeps: Questie, TomTom

Api.lua
Core.lua
Config.lua
Arrow.lua
Clock.lua
Bis.lua
Data\Index.lua
Data\Services.lua
Data\Demo.lua
Data\Classic\Alliance\Human.lua
Data\Classic\Alliance\Stubs.lua
Data\Classic\Horde\Durotar.lua
Data\Classic\Horde\Stubs.lua
Data\Forever\Skyborne.lua
Data\Forever\Overlay.lua
Data\Bis\Index.lua
Router.lua
Resume.lua
Level.lua
Live.lua
UI.lua
```

`Data\Index.lua` loads before `Data\Services.lua` because Services writes `insideZone` onto the dungeon rows. `Live.lua` loads after `Resume.lua`. UI is last. `UI:Init` runs from Core after the saved variables exist, not at file load.

Footer in the large window stays the data version from `QS.DATA_VERSION`: `Data classic-1.12 + forever-2026-10-05`. Do not change that string when the TOC version moves.

## Saved variables

`QuestStratagemCharDB`:

- `size` = `large|medium|small`
- `point, relative, x, y` frame position
- `spec` talent tree name, `specConfirmed` bool
- `pace` = `guide|steady|first`
- `skips` = `{ [stepId] = true }`
- `manualStepId`, `manualFrontierId` — Back's hold. Not a numeric index.
- `turnedIn` = `{ [questId] = time() }`
- `legStart`, `lastLeg` = `{ seconds, xp }`, `totalSeconds`
- `dungeonDetours`, `bisCallouts`, `classQuests` bools, default true
- `professionSteps` bool, default true. Gather, craft, and trainer only.
- `liveRev` number. Missing on a 0.1.0 save. Init reads it before filling defaults, then sets it to 1 and forces `professionSteps` on. Later toggles stick.
- `bossDown` = `{ [bossName] = true }`
- `talentUnspent` last seen unspent count, so a new point clears the talent skip
- `craftSig` the recipe currently recommended, so Next hides one recipe and the next recipe still appears
- `routeKey`, `demo`, `shown`, `minimapAngle`
- `factionOverride`, `raceOverride`, `classOverride` — debug cycle only. Do not override `classFile`; spec buttons read the real class.

`QuestStratagemDB`: `debug` only. No account-wide route.

## Events

Registered with `pcall`, so a missing event name does not stop the addon.

- `ADDON_LOADED` — init DB
- `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD` — login, rebuild
- `PLAYER_LEVEL_UP`, `QUEST_ACCEPTED`, `QUEST_TURNED_IN`, `QUEST_FINISHED`, `QUEST_LOG_UPDATE` — rebuild
- `QUEST_REMOVED` — a leave without turn-in must not advance. A complete quest leaving the log is recorded as a turn-in.
- `ZONE_CHANGED_NEW_AREA`, `ZONE_CHANGED`, `ZONE_CHANGED_INDOORS` — rebuild, so hearth and city steps notice
- `CHARACTER_POINTS_CHANGED`, `PLAYER_TALENT_UPDATE` — spec guess, then rebuild. Never silent-switch a confirmed spec.
- `BAG_UPDATE`, `SKILL_LINES_CHANGED`, `UPDATE_INVENTORY_DURABILITY` — rebuild. Bag updates are debounced 0.2s.
- `MERCHANT_CLOSED`, `BANKFRAME_CLOSED`, `AUCTION_HOUSE_CLOSED`, `TRAINER_CLOSED`, `GOSSIP_CLOSED` — rebuild
- `CHAT_MSG_COMBAT_HOSTILE_DEATH` — if the name is in the boss table, mark `bossDown` and rebuild
- `PLAYER_XP_UPDATE` — clock sample only
- OnUpdate every 2s: if the current step is a boss or a `dyn-` step and Resume says it is done, rebuild. Covers a hearth bind and a talent spend that fired no event.

## Modules

- `Core` — namespace `QuestStratagem`, DB, slash, events, rebuild.
- `Api` — quest log, map, bags, skills, talents, bind, durability, place. `/qs api` prints the probe.
- `Config` — faction, race, class, spec guess, debug cycle.
- `Data` — registries. `Services.lua` holds inns, cities, trainers, spells, crafts, herbs, ore, skins, bosses, talent orders. No quest ids.
- `Router` — spine, stubs, precursors, cluster batch, dungeon windows.
- `Resume` — done rules, frontier, Next, Back.
- `Live` — hearth, talent, trainer, craft, gather lines, vendor, bank, auction, boss surfacing. See MEMORY.md "Live guide".
- `Arrow` — bearing and yards. Instance mode hides the arrow.
- `UI` — one frame, three sizes.
- `Clock` — goal versus tracked time.
- `Bis` — rows on the current step. Not the boss kill list.

## Slash

- `/qs` toggle
- `/qs next` `/qs back`
- `/qs config`
- `/qs where`
- `/qs reset` clears skips and the manual hold. It does not clear `turnedIn` or `bossDown`.
- `/qs api`
- `/qs size`
- `/qs demo` toggles the fake route and skips Live
- `/qs debug` toggles the config override cycle

## Rebuild

1. `Router.Build`
2. `Api.Snapshot`
3. `Resume.PullForward`
4. `Live.Apply` unless demo
5. `Resume.Choose`
6. `Bis.Annotate`
7. Clock and UI

## What not to do

- Do not `SendAddonMessage`.
- Do not HTTP, and do not add Ask.
- Do not vendor Questie or HereBeDragons.
- Do not auto-accept.
- Do not invent Forever quest ids or item id 0.
- Do not invent interior dungeon coordinates.
- Do not mutate the shared step tables while annotating gather lines.
