# QuestStratagem

Offline 1–60 stratagem addon for WoW Forever. Arrow, distance, chains, resume, BiS. No AI.

Planning pack dated 2026-10-05. The addon source is `Stratagem/` at version 0.1.25. What is designed, what is shipped, and what is left are in `MEMORY.md` under Live guide, Level plan, Area focus, Implemented in 0.1.1 through Implemented in 0.1.25, and Still todo.

## Read first

1. `MEMORY.md` — rules that do not drift, world facts, gaps.
2. `00-GOALS-AND-PLAN.md` — success and non-goals.
3. `01-ULTIMATE-BUILD-PROMPT.md` — paste this into Grok Build.

## Spec

| File | Contents |
|---|---|
| `02-UI-SPEC.md` | Large / medium / small, matching the three screenshots |
| `03-ARCHITECTURE.md` | TOC, modules, saved vars, slash |
| `04-DATA-MODEL.md` | Step schema, race/class matrix, overlays |
| `05-ROUTING-RESUME-TIME.md` | Precursors, clusters, resume, time to next level |
| `06-BIS-DUNGEONS.md` | Spec loot rows, dungeon windows |
| `07-API-CONSTRAINTS.md` | Classic-lineage probes |
| `08-UPDATE-LOOP.md` | How to patch data after a Forever build |
| `09-PHASES.md` | A shell (shipped), B to 20, C to 60, D overlay, E town and professions |

## Reference

Bones (`@designertom`, 2026-10-04) is the layout reference: route name, step index, segment bar, arrow, yards, bearing, goals with counts. QuestStratagem removes Ask and the network.

RestedXP is the strategy reference: ordered steps, class tags, dungeon detours, time. Not a runtime dependency.

WoW Forever facts used here: cap 60 permanent, launch 4 Nov 2026, 1,000+ new quests not fully public, beta cap 30 as of 2 Oct 2026. Classic IDs are the spine. Forever rows need a source.

## Next action

Read `MEMORY.md` before the next session. Phase A is shipped. Phase E (hearth, talents, professions, bosses) is started in 0.1.1. The level plan is in 0.1.2. Remaining work is Still todo. After each beta patch, follow `08-UPDATE-LOOP.md`.
