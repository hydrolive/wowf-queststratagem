# QuestStratagem UI spec

Reference screenshots supplied 2026-10-05 (Bones). Match hierarchy and density. Do not copy the skull mark, the word Bones, or the Ask button.

## Frame

- Name: `QuestStratagemFrame`. Parent: UIParent. Movable, clamped.
- Left-drag on the title bar moves. Position saved.
- Backdrop: dark stone, 1px gold edge, 4px corner. Classic-safe: `Interface\DialogFrame` pieces or a solid `0.10, 0.09, 0.08` fill plus gold `0.78, 0.62, 0.28` border. No retail-only atlas required.
- No medallion and no ring on the window. The minimap button still uses the compass.
- Title text: `Stratagem` in gold, centered. Small size hides the title.
- Close (X) hides the frame. Minimap button, `/qs`, or `/stratagem` shows it. Minus is not a separate mode; right-click is the size cycle. A small size-cycle button may sit where Bones puts minus, for discoverability, and does the same thing as right-click.

## Size cycle

Right-click anywhere on the frame cycles. Saved per character.

| Size | Approx | Contents |
|---|---|---|
| Large | 460 × 340, plus 16px for each objective past five, up to twelve rows | Full panel |
| Medium | 460 × 64 | Arrow, step title, distance, segment bar |
| Small | 168 × 52 | Arrow and distance only |

All three include the arrow. Font sizes do not jump so hard that the arrow moves between sizes; pin the arrow to the left padding.

The current step is also a pin on the map. Use the Blizzard user waypoint when `C_Map.SetUserWaypoint` is allowed on that map, and super-track it. TomTom is the fallback, with its crazy arrow left off. A step with no coordinates removes the pin this addon placed.

## Large (screenshot 1)

Top block:

- Window title: `Stratagem`.
- Status word: `Ready`, `Walking`, `In range`, `Turn in`, `Area`, `Dungeon`, `Hearth`, `Talent`, `Train`, `Craft`, `Sell`, `Repair`, `Bank`, `Auction`, `Boss`, `Kills`, `Already done`, `BiS still missing`, `Review`, `Done`. `Done` is a stored step you are reviewing that is already finished.
- Subline: `Last leg: 40 min · +1,076 XP` using the previous completed step’s duration and XP delta.
- Right side, stacked: `Next` and `Back` as small red-brown buttons. `Path` sits on the Next row. Not Ask. Back is hidden when this character has no earlier step. Medium and Small hide Next, Back, and Path. `/qs back` still does nothing when Back is hidden.

Path opens a list anchored to the left of the window. The bar is a percent of the road to 60. The end of level 27 is about halfway, so a character there reads about 50% when their finished quests are in line with the road still ahead. It does not read `27/60`. The list is one row per quest: finished quests the client can name, then the step on screen, then the camps and dungeons still ahead. The same quest is not repeated for accept, objective, and turn-in. A finished row has the ready-check icon. The step on screen is gold and the list opens scrolled so a few finished rows sit above it. Those rows are recent turn-ins, stored steps, and quests that have left the log. Starter quests stay further up. When the next even level is close, the next row after the current camp is the class trainer, and the arrow stays on the camp until that camp is finished. A finished quest with no name yet is counted and not shown as a number. The wheel and the slider move through the rest. Deferred steps stay off the list.

Divider.

Route row:

- Yellow line names the step on screen, e.g. `Orgrimmar · Borstan` while that turn-in is showing. It changes with Back and Next. Up to two earlier steps that are already finished follow it, each prefixed with the ready-check icon. A travel step uses its title (`Fly to Orgrimmar`). The step title under the arrow gets the same icon when you are reviewing a finished step.
- Right: the level percent (`50%`) while a level plan is showing, or `1/7` on the demo route. No Reroute button and no skip mark on this row.

Segment bar: while a level plan exists, the slices are this level's XP. Gold width equals `UnitXP` / `UnitXPMax`. The remaining width is the quests, dungeon bosses, and kill chunks that finish the level. The first unfinished slice is bright. At most 16 slices. The route index is the percent (`50%`), so a character halfway from 27 to 28 shows a bar about half full. The demo route has no level plan and keeps the cluster bar: N segments for the current cluster, filled segments done, current segment bright.

Step block:

- Arrow texture, 28px, rotated to bearing.
- `1. Ectoplasms` — step title.
- `192 yd · ahead · approx.` — yards, bearing word, confidence word.
- Body, two lines max: zone, where, what drops. Example: `Lushwater Oasis, around the pond; the oozes drop Wailing Essence.`

Goals block:

- Yellow header = active quest name (`Smart Drinks`), or the live step's `goalHeader` (`Hearth`, `Talent`, `Train`, `Craft`, `Vendor`, `Bank`, `Auction`, `Boss`).
- One row per objective: bullet, name, `0/6` right-aligned. Spell names on a trainer step have an empty count.
- If the step is an accept: header `Pick up`, row is `NPC name · Zone`.
- Objective steps that carry their own `goals` show those rows instead of the quest-log text.
- Gather lines are `extraGoals`, drawn after the quest rows and before BiS. Example: `Gather Peacebloom` and `0/20`. They do not replace the quest objectives. Five rows fit in the base window. Each further row adds 16px to the large window, up to twelve. Past that, the last row reads `+N more in /qs where`.
- A ready turn-in with several rewards adds a gold row naming the piece closest to the spec. The row starts with that item's icon. Mouseover opens the item tooltip. The same icon treatment applies to a BiS row that has an item id. If that choice is a gear upgrade, the next row is `Equip` and the item name, `0/1` until it is worn, then `1/1`. A vendor sale does not add that row. Finishing a quest objective plays a sound: the ring pickup file, then the quest-complete interface file if the first one does not play.
- If a reward or drop is BiS: extra row, gold, `BiS chest: Robe of the Magi — choose this reward` or `BiS weapon: Ironfoe — drop, Emperor Thaurissan`.
- A boss step's goal is the boss name, `0/1`. That row is not a quest and not a BiS row.

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

`/qs config` or the Options button on the large frame. Options is where the spec is chosen. The three buttons are that class's talent trees.

- Faction: detected, locked unless override (debug).
- Race: detected.
- Class: detected.
- Spec: three radio buttons from the class talent trees. Required before the route leaves the starter zone. Guess from spent talent points if ≥10 points sit in one tree; still show confirm.
- Pace: `Guide`, `Steady`, `First run`. Scales the time-to-next-level guess (and the demo 72h line). It does not change which steps are chosen.
- Toggles: dungeon detours, BiS callouts, class quests, profession steps (on by default; a 0.1.0 save is turned on once). Profession steps cover gather lines, craft reminders, and trainer steps. Hearth, talents, sell/repair, bank, auction, and boss kills stay on when it is off.
- Clean Quest Log. The button reads `Clean Quest Log`, and the line under it reads `Removes X Quests`. X is how many quests in the log this route will not do. Hover lists those names. One click abandons them. A quest stays if a route step that is not grey names its id or title. It also stays when the current area names it, or Stratagem has a place for that title, and the quest is still in color. Grey quests and quests the route never names are the ones removed. Demo mode does not abandon anything. Next still does not abandon.
- Reset route / clear skips.

## Empty and error states

- No route for this combo: `No stratagem for High Order Mage yet. Classic spine will be used.` and load the nearest race spine.
- Coordinates missing: still show the text step; arrow hidden; distance reads `—`.
- Player in instance: if the step has interior coordinates, the arrow uses them. This build stores none. The arrow hides. A boss step's distance line is `Inside · {boss name}`. Any other indoor step reads `Inside · follow BiS / quest`.
