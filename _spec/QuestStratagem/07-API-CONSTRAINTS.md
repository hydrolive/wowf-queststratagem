# API constraints and legal

## Client

WoW Forever beta build reported as `1.60.1.70170` (ForeverDB, 2026-10-02). Treat the API as Classic Era / Classic anniversary lineage, not retail. Probe every modern call.

```lua
local function Has(fn)
  return type(fn) == "function"
end
-- prefer, in order:
-- quest id from log: select(8, GetQuestLogTitle(i)) on classic
-- C_QuestLog.GetInfo(i).questID if present
-- completed: GetQuestsCompleted() if present
-- else C_QuestLog.IsQuestFlaggedCompleted(id)
-- else our turnedIn mirror only
-- position: C_Map.GetBestMapForUnit + GetPlayerMapPosition, or classic GetPlayerMapPosition after SetMapToCurrentZone
```

Ship `Api.lua` with these probes and a `/qs api` dump so a later session can see what the live client actually has.

## Arrow math

Embed HereBeDragons-2.0. Use world coordinates so yards work across zone lines. Facing from `GetPlayerFacing()`. If the library returns nil (instance, no map), hide the arrow and keep the text.

Optional: if TomTom is loaded, also set a TomTom waypoint. Not required.

Optional: if Questie is loaded, fill a missing `x,y` from Questie’s DB at runtime. Not required. Do not vendor Questie (GPL, and huge).

## Events that must not be required

`QUEST_TURNED_IN` may be missing on older clients. Also watch `QUEST_FINISHED` and a questID leaving the log while `IsQuestComplete` was true. Record the id in `turnedIn`.

## Legal and content

- Do not copy RestedXP guide text, Bones art, or Wowhead page HTML into the addon.
- Quest names, NPC names, and numeric IDs are game data. Short original directions are fine (“around the pond”).
- Cite sources in the data file header, not in the player-facing panel.
- This pack is a design for an addon the user will build. It is not a Blizzard product and must not claim to be official.

## Performance

- No `OnUpdate` allocations.
- Route rebuild on quest events, debounced 0.2s.
- Data files must stay data. No pairs-over-everything scans per frame.
