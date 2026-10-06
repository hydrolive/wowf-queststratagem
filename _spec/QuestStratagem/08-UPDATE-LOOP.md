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
6. Update `MEMORY.md` world-facts and the decision log with the date.
7. Bump TOC version.

## Prompt stub for the next session

```
Read QuestStratagem/MEMORY.md and 08-UPDATE-LOOP.md.
Patch only the Forever overlay and BiS tables.
Source: <urls>.
Do not invent quest IDs.
Do not add an AI or Ask button.
Write a short changelog at the top of Overlay.lua.
```

## Player-facing version line

Large window footer, muted: `Data classic-1.12 + forever-2026-10-05`. So a bad route can be blamed on a data version.
