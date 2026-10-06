# Phases and acceptance

## Phase A — shell

Shipped in 0.1.0 and still in 0.1.1. Loadable addon. Demo route is five fake steps (`/qs demo`). Human Elwynn and Orc/Troll Durotar are real Classic chains through about level 6, which is ahead of the original fake-step stop.

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

- Deadmines (Alliance) and WC (Horde) appear as entrance, then one step per boss. Pickup and turn-in appear once those quest ids are cited. A BiS row still attaches to the quest or the drop, not to the boss step.
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

## Phase E — town, talents, professions, bosses

Started in 0.1.1. The level plan shipped in 0.1.2. Design, the shipped behavior, and the leftover list are in MEMORY.md under "Live guide", "Level plan", "Implemented in 0.1.1", "Implemented in 0.1.2", and "Still todo".

Acceptance when this phase is finished:

- Arriving at a new hub offers Set hearth, and does not duplicate a quest hearth already in the next steps (2158, 2161).
- A turn-in back in the bound town offers the hearthstone, with cooldown text when it is down.
- An unspent talent point names the next talent for the confirmed or assumed spec.
- In a city the arrow points at the profession trainer and the goals list the spells for that rank. Away from a city, the trainer step appears when the skill is about to cap.
- With the materials in the bags, one craft step appears. Gathering professions add `Gather {node} 0/20` on quest steps in that zone.
- Three or fewer free slots, or durability under 25%, offers sell and repair.
- A major city lists bank items and auction items as separate steps.
- Inside a dungeon each boss is its own goal step, not a quest and not a BiS check. The distance line shows the boss name.
- A later session can tell shipped behavior from remaining work by reading MEMORY.md alone.

Not done yet: interior boss pins, trainer pins outside Stormwind and Orgrimmar, verified reagent counts, the rest of the 1–60 quest spine (0.1.2 plans those levels as one dungeon plus kills, and says the quest ids are missing), and an in-game login. See Still todo.

## Out of phase

Hardcore variant, raid attunement, localization beyond enUS. Profession routing left this list in 0.1.1 and lives in Phase E.
