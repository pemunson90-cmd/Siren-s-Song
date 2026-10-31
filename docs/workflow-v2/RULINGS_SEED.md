# RULINGS.md seed (format and the intent card draft)

`docs/state/RULINGS.md` is append-only and holds only Pat's words, verbatim and dated, one ruling per entry, plus the intent card. It replaces PAT_RULINGS_2026-10-29.md, the Pat lines in USER_DIRECTIVES.md and the ruled items in QUESTIONS_FOR_PAT.md, which migration step 2 copies in unchanged. Nothing AI-designed goes in this file; implementation notes belong in the item or the PR.

## Entry format

```
- 2026-10-30 19:18 ET (chat) [controls]: "I honestly just don't like the controls. It basically means you can complete almost every mission while half of your maneuvering is just clicking a button and watching autopilot. ... There should be controls for depth, interacting with nearby interactable objects, movement controls and recover drones."
- 2026-10-30 19:18 ET (chat) [controls]: Q "drop the one-press travel shortcuts and make planned waypoints plus an in-reach job menu the way you move?" A "They are fine for testing but they will absolutely have to be stripped for release play".
- 2026-10-30 19:21 ET (chat) [movement risk]: "You should still be able to crash. But there should be moderate autopilot for edges and stuff so you're not just getting stuck grinding on things ... it still got to be a game like there still has to be some challenge and risk to it."
```

Qualifiers such as "for now" are kept verbatim and the entry is tagged `[provisional]`.

## Intent card (DRAFT, UNRATIFIED, 10 lines; question 3 asks Pat to ratify it)

```
INTENT CARD (what the player does, what must stay hard)
1. The player pilots by hand: places legs while paused, changes depth, works what is in reach, recalls drones, chooses when to be loud.
2. There is no one-press travel in release play. Shortcuts exist only behind the dev state for tests.
3. Crashing is possible and costs hull. A light edge assist stops grinding; it never plans a path for you.
4. Noise and exposure draw the Sirens. Being seen or heard has a cost you can read on screen.
5. The bare fleet can finish required ops on ACCESSIBLE and STANDARD, but as a skill feat with worse results, not as the easy path.
6. Planning, drones, tools and fittings change outcomes on every preset. An op that plays the same either way is a defect.
7. The game tells the truth: every action says what it does, every grey action says why, every exit is named for what exists.
8. The board does not move under your finger. A tap does one predictable thing.
9. Photography and recovered evidence are the point of going down there; they must be worth seeing and interpreting.
10. Story is 1 to 2 line placeholders, no em dashes, until Pat writes it; branching matters, prose does not.
```

Sources for each line: 1 to 3 Pat 2026-10-30 19:18 and 19:21; 4 and 5 Pat 2026-10-28 12:25 and 12:30; 6 Pat 2026-10-28 (fleet must matter) and HANDOFF intent section; 7 and 8 critic 123 consensus and PLAN_DRAFT_1 ranks 1 and 2 (AI-ranked, so Pat should confirm); 9 the spec's photographic pillar and Cold Review 4 F1; 10 standing rule. Lines 7 to 9 are the ones Pat has not said in his own words; the card is marked UNRATIFIED until he does.
