# QuestStratagem architecture

Classic-lineage addon. Lua 5.1. No external libraries required except an embedded HereBeDragons-2.0 (BSD) for yards and facing. If embedding is rejected, ship a zone-local fallback: `GetPlayerMapPosition` distance is wrong across zones, so cross-zone steps then show the flight master or the zone name without yards.

## TOC

```
## Interface: 11507
## Title: QuestStratagem
## Notes: Offline 1-60 stratagem for WoW Forever. Arrow, chains, BiS.
## Author: QuestStratagem
## Version: 0.1.0
## SavedVariables: QuestStratagemDB
## SavedVariablesPerCharacter: QuestStratagemCharDB
## OptionalDeps: Questie, TomTom

Embeds.xml
Core.lua
Config.lua
Arrow.lua
UI.lua
Router.lua
Resume.lua
Clock.lua
Bis.lua
Data\Index.lua
Data\Classic\Alliance.lua
Data\Classic\Horde.lua
Data\Forever\Overlay.lua
Data\Bis\Index.lua
```

Interface number is a placeholder. On first Forever install, set it from any working Forever addon TOC. Wrong interface only warns; it does not break Lua.

## Saved variables

`QuestStratagemCharDB`:

- `size` = `large|medium|small`
- `point, relative, x, y` frame position
- `spec` talent tree name
- `specConfirmed` bool
- `pace` = `guide|steady|first`
- `skips` = `{ [stepId] = true }`
- `manualIndex` optional override
- `turnedIn` = `{ [questId] = time() }` mirror, in case the client cannot answer completed flags
- `legStart` time and xp at current step start
- `lastLeg` = `{ seconds, xp }`
- `totalSeconds` addon-tracked
- `dungeonDetours`, `bisCallouts`, `classQuests` bools
- `routeKey` last built key

`QuestStratagemDB`: global clock defaults, debug flag. No account-wide route. Routes are per character.

## Events

- `ADDON_LOADED` — init DB, build route
- `PLAYER_LOGIN` / `PLAYER_LEVEL_UP` — rebuild frontier
- `QUEST_ACCEPTED`, `QUEST_TURNED_IN` or `QUEST_FINISHED`, `QUEST_LOG_UPDATE` — auto-advance
- `QUEST_REMOVED` — if current accept step’s quest left the log without turn-in, do not advance
- `ZONE_CHANGED_NEW_AREA` — refresh arrow target
- `PLAYER_ENTERING_WORLD` — instance check
- `CHARACTER_POINTS_CHANGED` — spec guess, never silent-switch a confirmed spec

## Modules

- `Core` — namespace `QuestStratagem`, print, slash.
- `Config` — detect faction/race/class, spec UI.
- `Data` — returns the step array for a key. No logic.
- `Router` — cluster pull, precursor injection, dungeon windows, BiS annotations.
- `Resume` — scan log + completed flags, choose index.
- `Arrow` — bearing, yards, words.
- `UI` — three layouts, one frame.
- `Clock` — goal vs actual, leg XP.
- `Bis` — lookup by spec + step.

## Slash

- `/qs` toggle
- `/qs size`
- `/qs next` `/qs back`
- `/qs config`
- `/qs where` print step id, quest id, zone
- `/qs reset` clears skips and manual index, re-resumes

## Load order

Data files register into `QuestStratagem.Registry` and return. `Router.Build(char)` runs after all data files. Overlays apply after Classic spines.

## What not to do

- Do not `SendAddonMessage` to a server.
- Do not vendor Questie.
- Do not auto-accept (`SelectGossipAvailableQuest` loops) in v1. Point only.
- Do not store talent strings from other players.
