# QuestStratagem — goals and plan

Date: 2026-10-05. Owner intent: an ultimate Grok Build prompt plus memory so a later session can change the addon without re-deriving the design.

## Goal

Ship a WoW Forever addon that always shows the next efficient leveling action, with a direction arrow and a distance, for the player’s faction, race, class, and confirmed spec. It must survive a reload mid-quest, refuse to re-send completed quests, pull precursors before a zone is left, insert dungeon runs when they are the fast or BiS path, and show estimated time to 60 against time actually spent.

The player should not look quests up. They should walk to the arrow.

## What “done” means for the prompt pack

This folder is the done state of the planning request. Grok Build (or a later Grok session) is done with a phase when the acceptance list in `09-PHASES.md` passes.

## Success for the addon

- Large, medium, and small windows match the information hierarchy in the attached screenshots. All three show the arrow. Right-click cycles them.
- A brand-new Human warrior and a brand-new Orc shaman get different step 1 (different NPC, zone, and chain).
- A level 18 Night Elf hunter who has already turned in the Darkshore chain does not get sent back to Dolanaar for a quest the completed-flag says is done.
- Accepting the pointed-at quest advances off the “pick up” step without pressing Next.
- Turning it in advances off the “turn in” step.
- Next skips a step and Back returns to it. Skip is remembered.
- Barrens-style cluster: if three quests share a camp, the route accepts all three before the first grind loop.
- At a dungeon window, the step names the entrance, the quests to hold, and any BiS drop or reward.
- Goals block on the large window shows objective counts and, when relevant, “BiS: item name — choose this reward / loot this boss.”
- Header shows goal hours vs actual hours, and last segment time plus XP.
- No network permission, no chat frame, no model call.
- Data for unknown Forever quests is absent and marked, not fabricated.

## Non-goals

- AI companion, voice, or “ask about this quest.”
- Retail dragonriding, Warbands, or modern map APIs assumed present.
- Parsing RestedXP or Questie at runtime as a requirement.
- Raid routing, gold farming routes, hardcore death-skip variants (hooks may exist; content does not ship in v1).
- Automating accept/turn-in. The player clicks the NPC. The addon only points.
- Copying Bones art, name, or the Ask button.

## Plan

1. Lock design in this folder (this request).
2. Grok Build phase A: addon shell, three frames, arrow math, config, saved variables, fake route so the UI can be judged in-game.
3. Phase B: Classic spine for both factions, all races, class forks through level 20. Resume and auto-advance.
4. Phase C: 20–60 Classic spine, dungeon windows, BiS tables for the three specs of each class.
5. Phase D: Forever overlay file. Only rows with a public source. Zephras Isle and new dungeons as stubs until IDs exist.
6. Recurring: `08-UPDATE-LOOP.md` after each beta or launch patch.

## Risks

| Risk | Mitigation |
|---|---|
| Forever quest IDs unpublished | Confidence flag; never invent IDs; Classic spine still levels |
| API mismatch on 1.60 client | Probe table in `07-API-CONSTRAINTS.md` |
| Route too long to hand-author | Generate Classic steps from a cited dump; hand-fix hubs |
| BiS shifts after talent rework | BiS version field; spec confirm on every login until locked |
| Looking like a Bones clone | Original name, compass icon, no Ask, gold/stone frame is genre-standard |

## Estimate policy

Default goal: 72:00 to 60 for a guide-following damage spec, modifiers in `05-ROUTING-RESUME-TIME.md`. Display as “Goal 72h · Actual 6h 12m · Level 14”. Do not hide the actual if the player is slower.
