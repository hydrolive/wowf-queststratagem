# Phases and acceptance

## Phase A — shell

Grok Build produces a loadable addon with fake steps (three accepts, one objective, one turn-in).

Acceptance:

- Frame loads, moves, saves position.
- Right-click cycles large, medium, small. Arrow visible in all three.
- Large shows status, last leg, route name, n/n, segment bar, title, distance line, body, goals, Next, Back.
- No Ask button. No network.
- `/qs next` and `/qs back` move the fake index.
- Config shows detected faction, race, class, and three spec buttons.

## Phase B — spine through 20

Real Classic steps for every race starter and the 10–20 zone, class quests included.

Acceptance:

- Human and Orc first steps differ.
- Accepting the pointed quest advances the accept step.
- Turning it in advances the turn-in step.
- Reload at mid-quest resumes on the objective, not the giver.
- A quest in `turnedIn` is never the current accept target.
- Cluster batch at the first inn: one pickup listing every available hub quest.

## Phase C — 20–60 and BiS

Classic contested route, dungeon windows, BiS rows for all 27 specs at 40–59 and 60, thinner at low levels.

Acceptance:

- Deadmines (Alliance) and WC (Horde) appear as pickup → entrance → note → turn-in.
- A spec with a known reward shows a BiS goals row on that turn-in.
- Goal line shows hours. Tracked time survives reload.
- Next skips a dungeon and does not return to it after reload.

## Phase D — Forever overlay

Stubs for Zephras Isle and nine dungeons. Verified rows only where a public page names the quest ID.

Acceptance:

- Skyborne route starts on Zephras Isle text steps.
- Non-Skyborne routes do not.
- `/qs where` prints confidence.
- Footer shows data version.

## Out of phase

Hardcore variant, profession routing, raid attunement, localization beyond enUS.
