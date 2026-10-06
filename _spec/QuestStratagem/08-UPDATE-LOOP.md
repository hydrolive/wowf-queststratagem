# Update loop

Use this when a later Grok session is told “patch QuestStratagem for the new Forever quests.”

## When

- Beta cap rises (20 → 30 already happened 2026-10-01).
- Launch 2026-11-04.
- Any patch that adds zones, quests, or dungeon loot.
- A player report that a step points at a completed or removed quest.

## Research order

1. Read `MEMORY.md` and the decision log. Do not reopen offline-vs-AI.
2. Public sources only: Wowhead Forever, ForeverDB, Warcraft Wiki, Blizzard posted notes. No private dumps, no paid guide text.
3. For each new quest record: name, questID, giver, zone, level, faction, prerequisite, reward items. If questID is not on a public page, the row stays a stub.
4. Diff against `Data/Forever/Overlay.lua`. Prefer `insert_after` and `disable` over editing Classic spines.
5. BiS: if a Forever PvE list names an item for a spec, add a row with `confidence = "reported"` and the URL in the file header.
6. Live tables live in `Data/Services.lua` (inns, trainers, spells, crafts, herbs, ore, skins, bosses, talent orders) and the behavior lives in `Live.lua`. Patch those files for a profession or boss correction. Do not paste live steps into the race spines. Interior boss coordinates stay absent until a source gives them.
7. Update `MEMORY.md`: the Live guide section if behavior changed, world-facts, the decision log, and the Still todo list. Move a finished todo into Implemented. Keep the footer string `Data classic-1.12 + forever-2026-10-05` unless the quest data version itself changes.
8. Bump TOC version. Copy `MEMORY.md` into the addon folder.

## Prompt stub for the next session

```
Read QuestStratagem/MEMORY.md and 08-UPDATE-LOOP.md.
Implemented, design, and remaining work are under Live guide, Implemented, and Still todo.
Patch the Forever overlay, BiS tables, or Data/Services.lua and Live.lua as the source requires.
Source: <urls>.
Do not invent quest IDs. Do not invent interior boss pins.
Do not add an AI or Ask button.
Write a short changelog at the top of Overlay.lua.
Copy MEMORY.md into the addon. Do not change the footer data string unless the quest data version changed.
```

## Player-facing version line

Large window footer, muted: `Data classic-1.12 + forever-2026-10-05`. So a bad route can be blamed on a data version.
