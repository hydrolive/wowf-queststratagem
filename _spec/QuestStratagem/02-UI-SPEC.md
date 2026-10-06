# QuestStratagem UI spec

Reference screenshots supplied 2026-10-05 (Bones). Match hierarchy and density. Do not copy the skull mark, the word Bones, or the Ask button.

## Frame

- Name: `QuestStratagemFrame`. Parent: UIParent. Movable, clamped.
- Left-drag on the title bar moves. Position saved.
- Backdrop: dark stone, 1px gold edge, 4px corner. Classic-safe: `Interface\DialogFrame` pieces or a solid `0.10, 0.09, 0.08` fill plus gold `0.78, 0.62, 0.28` border. No retail-only atlas required.
- Icon: 36px compass/arrow medallion overlapping the top-left corner, gold ring. Not a skull.
- Title text: `QuestStratagem` in gold, centered. Small size may hide the title bar text but keeps the icon.
- Close (X) hides the frame. Minimap button or `/qs` shows it. Minus is not a separate mode; right-click is the size cycle. A small size-cycle button may sit where Bones puts minus, for discoverability, and does the same thing as right-click.

## Size cycle

Right-click anywhere on the frame cycles. Saved per character.

| Size | Approx | Contents |
|---|---|---|
| Large | 460 × 340 | Full panel |
| Medium | 460 × 64 | Arrow, step title, distance, segment bar |
| Small | 168 × 52 | Arrow and distance only |

All three include the arrow. Font sizes do not jump so hard that the arrow moves between sizes; pin the arrow to the left padding.

## Large (screenshot 1)

Top block:

- Status word: `Ready`, `Walking`, `In range`, `Turn in`, `Dungeon`.
- Subline: `Last leg: 40 min · +1,076 XP` using the previous completed step’s duration and XP delta.
- Right side, stacked: `Next` and `Back` as small red-brown buttons. Not Ask.

Divider.

Route row:

- Yellow route name, e.g. `Barrens priority route`.
- Right: `1/7`, a reroute button (recomputes frontier), an X that clears the manual skip on the current step (does not abandon the quest).

Segment bar: N segments for the current cluster (not the whole 1–60). Filled segments are done. Current segment is bright.

Step block:

- Arrow texture, 28px, rotated to bearing.
- `1. Ectoplasms` — step title.
- `192 yd · ahead · approx.` — yards, bearing word, confidence word.
- Body, two lines max: zone, where, what drops. Example: `Lushwater Oasis, around the pond; the oozes drop Wailing Essence.`

Goals block:

- Yellow header = active quest name (`Smart Drinks`).
- One row per objective: bullet, name, `0/6` right-aligned.
- If the step is an accept: header `Pick up`, row is `NPC name · Zone`.
- If a reward or drop is BiS: extra row, gold, `BiS chest: Robe of the Magi — choose this reward` or `BiS weapon: Ironfoe — drop, Emperor Thaurissan`.

## Medium (screenshot 2)

Single bar. Arrow, yellow step or quest title, distance on the right (`192 yd`), thin segment bar under the text. No body, no goals, no Next/Back (still bound to `/qs next` and `/qs back`).

## Small (screenshot 3)

Arrow and `194 yd` only. Tooltip on hover shows step title and zone so the tiny frame is still usable.

## Arrow

- Texture points up at rotation 0.
- Bearing = player facing vs vector to target, via HereBeDragons `GetWorldVector` or equivalent.
- Distance in yards, rounded. Under 8 yd: `here`.
- Bearing words, 45° buckets: `ahead`, `ahead-right`, `right`, `behind-right`, `behind`, `behind-left`, `left`, `ahead-left`.
- Confidence: `exact` if we have a coordinate; `approx` if the point is a zone centroid or a Questie-optional pin; `npc` if it is a named NPC with a known spawn.
- Update on `OnUpdate` at 0.1s. Do not allocate tables in that path.

## Color

- Gold title and section headers: `#FFD100`.
- Body: `#E6E0D4`.
- Muted: `#A8A090`.
- BiS row: `#F0C75E`.
- Danger (elite, red quest): `#E05050`.
- Progress fill: `#F0D060`. Empty segment: `#3A342C`.

## Config popout

`/qs config` or a gear on the large frame.

- Faction: detected, locked unless override (debug).
- Race: detected.
- Class: detected.
- Spec: three radio buttons from the class talent trees. Required before the route leaves the starter zone. Guess from spent talent points if ≥10 points sit in one tree; still show confirm.
- Pace: `Guide` (default 72h), `Steady` (110h), `First run` (180h). Changes the goal line only.
- Toggles: dungeon detours, BiS callouts, class quests, profession steps (off by default).
- Reset route / clear skips.

## Empty and error states

- No route for this combo: `No stratagem for High Order Mage yet. Classic spine will be used.` and load the nearest race spine.
- Coordinates missing: still show the text step; arrow hidden; distance reads `—`.
- Player in instance: arrow aims at the in-dungeon objective if we have a pin, else text `Inside · follow BiS / quest`.
