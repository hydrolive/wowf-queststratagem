# QuestStratagem — ultimate Grok Build prompt

Paste this whole file into Grok Build. The sibling markdown in this folder is the spec. If a sibling and this prompt disagree, the sibling wins, except the product rules in MEMORY.md which win over everything.

---

Build an offline World of Warcraft addon named QuestStratagem for WoW Forever (Classic-lineage client, level cap 60, launch 4 Nov 2026). It is a precomputed leveling stratagem with a direction arrow. It is not an AI companion. Do not add an Ask button, a chat box, an API key, or any HTTP.

Visual reference is the Bones panel (three sizes: full info, title+distance+bar, arrow+distance only). All three sizes show the arrow. Right-click cycles size. Match `02-UI-SPEC.md`. Original compass icon, title `QuestStratagem`, Next and Back instead of Ask.

Behavior:

- Next action is pick up (zone + NPC name), objective, turn in, travel, train, fly, hearth, or dungeon entrance. Distance in yards and a bearing word (`ahead`, `left`, `behind`, …).
- Aware of faction, race, class, and confirmed spec. Auto-detect faction, race, and class. Spec is a config confirm; guess from talent points but do not switch silently after confirm.
- Quest chains with precursor injection and hub clustering, per `05-ROUTING-RESUME-TIME.md`. If a later step needs a quest, schedule that quest before leaving the hub.
- On load, resume from the quest log and completed flags. Never point at a quest already turned in. Off-route accepted quests get pulled forward only if they sit in the next clusters.
- Next and Back skip or rewind a step and remember the skip. Accept, objective complete, and turn-in auto-advance.
- Dungeon steps only for quest XP or BiS, not mob grind. Pickup, then arrow to the entrance, then a goals block naming the BiS drop or reward. See `06-BIS-DUNGEONS.md`.
- Header goal vs tracked time. Default goal 72h to 60 times class and pace modifiers. Tracked time is addon time, labeled Tracked, not /played.

Data:

- Follow `04-DATA-MODEL.md`. Classic quest IDs only when you can cite them. Never invent a Forever quest ID. Unknown Forever content is `confidence = "stub"` and off unless included.
- Seed Phase A with fake steps so the UI loads. Seed Phase B starters for Human Elwynn and Orc/Troll Durotar through level 6 with real Classic quest IDs if you know them, otherwise structured stubs that say so.
- Cover the race/class matrix in `04-DATA-MODEL.md` as keys even when the body is a stub pointing at the nearest starter spine.
- BiS tables for all 27 specs may start as the well-known Classic pre-raid pieces with `source` set and `itemID` only when known. Zero is forbidden; omit the id instead.

Code:

- Layout per `03-ARCHITECTURE.md` and API probes per `07-API-CONSTRAINTS.md`. Lua 5.1. SavedVariables per character. Embed or vendor a minimal distance helper; do not require TomTom or Questie.
- Slash: `/qs`, `/qs next`, `/qs back`, `/qs config`, `/qs where`, `/qs reset`, `/qs api`.
- No auto-accept, no protected-action spam, no SendAddonMessage.

Docs to leave in the addon folder:

- Copy or adapt this pack’s MEMORY.md into `QuestStratagem/MEMORY.md` in the addon so the next session still has the rules.
- Changelog at top of `Overlay.lua`.

Stop condition for this build pass: Phase A acceptance in `09-PHASES.md`, plus the data schema and one real Classic starter chain (Human or Orc) long enough to show accept → objective → turn-in resume. Do not pretend the 1–60 database is complete. Footer must show the data version.

---

## How to resume later

1. Open this folder.
2. Read `MEMORY.md`.
3. Paste `08-UPDATE-LOOP.md`’s stub plus any new URLs.
4. Do not re-litigate offline mode.
