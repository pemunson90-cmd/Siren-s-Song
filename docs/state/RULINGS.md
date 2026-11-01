# RULINGS (Pat's words only, verbatim and dated; append-only)

Workflow v2 single source for rulings. Newest at the bottom of section 2. Rulings before 29 Oct 2026 remain in docs/USER_DIRECTIVES.md on claude/integration (verbatim, dated) until migration step 10 copies them here.

## 1. Intent card (DRAFT, UNRATIFIED until Pat answers question 3)

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

## 2. Rulings

- 2026-10-31 00:00 ET (chat) [workflow]: Q "Let Claude build game items directly when Codex is out or slower, one bounded session per item, two sessions alive at most, no fan-outs? I recommend yes." A "Yes to question 1, start the migration".
- 2026-10-31 15:06 ET (chat) [branches]: Q "Make main the only promotion target, tagged at each milestone, and freeze gauntlet/production (kept, never deleted)? I recommend yes." A "Yes and then ill reset and restart".

## 3. Rulings 29 to 30 Oct 2026 (copied unchanged from docs/codex/PAT_RULINGS_2026-10-29.md)


Claude asked each question in a multiple-choice widget with its recommendation listed first. Pat's selections, verbatim as chosen (question text, then answer):

1. "In Ironman mode, should a drone or module lost in a dive be gone for good?" = "Yes, Ironman only (Recommended)" (QUESTIONS_FOR_PAT 14)
2. "Add one more story fork in arc 5, so earlier play picks which later ops you get?" = "Yes, one fork (Recommended)" (2)
3. "Should sonar only show a rough Siren type until you see or photograph it? (Changes Siren sense display, your call.)" = "Yes (Recommended)" (9)
4. "Show each Siren's wariness level as a mark on the chart?" = "Later" (8, deferred)
5. "Should hunter and sentinel Sirens each get their own hearing, search and attention, so each type needs a different plan? (Siren senses, your call.)" = "Yes (Recommended)" (6)
6. "On ops with 2+ patrolling Sirens, should they radio each other with a visible charge-up you can interrupt? (Protected, your call.)" = "Yes, 2+ patrollers (Recommended)" (7)
7. "Should the thermal layer cover only one depth band, so picking a depth decides who can hear you? (Protected, your call.)" = "Yes (Recommended)" (10)
8. "Should expedition seeds also shuffle Siren start positions and patrol timing (never their senses)?" = "Yes (Recommended)" (12)
9. "Add a small set of custom economy values (repair cost, income, starting stock) behind an ADVANCED toggle?" = "Yes, small set (Recommended)" (15)
10. "Allow switching to an easier preset mid-campaign (not in Ironman), marked in the ledger?" = "Yes (Recommended)" (16)
11. "Add tactical aids such as auto-pause when a Siren first notices you, as an Accessible option off by default?" = "Yes (Recommended)" (11)
12. "Change the Sorley rescue reward from supplies to pilotage charts?" = "Yes, charts (Recommended)"
13. "Should the Sorley rescue count as one vote toward which ending you get?" = "No, keep it separate (Recommended)"
14. "On SURVIVAL, add extra pressure inside dives (for example a harsher oxygen or Hunt pace)?" = "Later, after audit (Recommended)"
15. "Give each hull and chassis a distinct silhouette so you can tell them apart at a glance? (Art, your call.)" = "Yes (Recommended)" (17)
16. "Give each Siren role its own sound, heard only once sonar has earned it?" = "Yes (Recommended)" (20)
17. "Add a little ambient sea life, in colours that never look like contacts and never on sonar? (Art, your call.)" = "Yes, limited (Recommended)" (19)
18. "Add a mirrored HUD option for one-handed play?" = "Yes (Recommended)" (21)
19. "Use a placeholder title art, icon and splash built from the Quietus silhouette until you supply art?" = "Yes, placeholder (Recommended)" (18, 22)
20. "The spec says 28 core ops but the game has 29. Keep 29?" = "Yes, keep 29 (Recommended)" (23)

Earlier the same morning (~08:10 ET): diver ascent "For now* Yes*" (handoff 102, done), then "Survivor depth change is fine."

Operating effect: items 3, 5, 6 and 7 are Pat-authorized changes to protected Siren senses and sensing presentation. Only the change named is authorized; silent sight 180 m, cruise sight 290 m, the lock warning and the beam stay as they are unless a handoff says otherwise. Every exact number in the handoffs is AI-DESIGNED for Pat to ratify. Each implementing PR copies its ruling line verbatim into docs/USER_DIRECTIVES.md on integration and marks the QUESTIONS_FOR_PAT item ruled.


## Efficiency rulings (Claude S7 widget, ~17:30 ET)
Context: Codex sessions have a 475k-token window; today about 1.84B input tokens: the 091 critic session 413M (365k context), the AI queue runner 98M (polling), fresh per-handoff sessions 35-55M each.
1. "Split each Codex task into short sessions (build, then test and PR, then merge) that hand off through notes?" = "Yes (Recommended)"
2. "Ask Codex root to checkpoint the whole-game critic and continue it in fresh sessions, region by region?" = "Yes (Recommended)"
3. "Replace the AI queue runner with a plain script, with Claude doing the PR checks?" = "Yes (Recommended)"

## Follow-up (Claude S7 chat, ~17:50 ET)
Claude proposed: lower reasoning for the measuring phase; compact test output; and asked "Should extra tools cost cargo in Career and Expedition too (today campaign only)? I recommend yes." Pat: "Yes to all, and then tell me clearly when you're ready to be cleared and reset with siren start".

## 2026-10-29T18:48:40-0400 (Claude S8, widget, after the 091 audit)

Q: "Can Codex draw new photo images that clearly show each subject (the people, the bore, the damage) in the game's current art style, without changing how exposure or photo grades work? This touches art direction, which is your call."
Pat: "Yes (Recommended)" (option text: "Fixes the audit's top finding. Same style and palette, same photo rules; the images become placeholders you can replace later.")

## 2026-10-29T20:35:53-0400 (Claude S8, widget)

Q: "Start the next gauntlet loop (Promotion 4, then a fresh blind critic) after the five audit fixes (116, 118-121) land, about 4 hours, rather than now?"
Pat: "After the fixes (Recommended)". Pat had said: "it seems like we're slowing down and getting close to being ready to launch the next gauntlet loop on the game".

## 2026-10-30T12:09:01-04:00 (Claude S10, chat)

Q: "Should Codex add an authored campaign ending plus more varied late-campaign evidence (F7/F8/F14), with story lines as 1-2 line AI-designed placeholders you can replace? I recommend yes."
Pat: "Yes". Queued as 125 (BOARD row 122). Ending conditions stay protected.

## 2026-10-30T12:53:27-04:00 (Claude S10, chat)

Pat asked for a real gauntlet stop: evaluate the whole game, find every weak point, one comprehensive plan, then fan out. Claude asked: "Should I freeze new building after 125 merges and ask root to run the remaining critic regions in parallel (late arcs with the ending, and side modes)? The full verdict would land today, then I'd write one complete improvement plan and run it across both lanes. I recommend yes."
Pat: "Yes, freeze and run the critic in parallel".

## 2026-10-30T12:57:49-04:00 (Claude S10, chat): gauntlet priorities

Pat: "The storyline is the least important besides how it affects branching paths. The main point of the gauntlet loop right now is gameplay, graphics, ux, ui, bugs, features. The whole point is that we have a complete game. We review it, figure out where it's lacking especially in comparison to other AAA releases, and then we plan out the upgrades, and then we execute."

## 2026-10-30T13:04:53-04:00 (Claude S10, chat): reference-judged plan and workflow gauntlet

Q: "Should I build the improvement plan this way: each piece judged blind against named reference games, keeping only changes that win? I recommend yes. You can swap any of those references for games you'd rather we match." (Pieces: chart and touch controls, HUD and UI, graphics, audio, Siren combat, mission variety, progression and fittings, side modes. Proposed references: Cold Waters, FTL, Into the Breach, Highfleet, Barotrauma, Mini Motorways.)
Pat: "Approved. At every major milestone you should stop and evaluate our progress, find areas where we can tighten up our workflow or improve, find our weakest areas, and essentially run a mini gauntlet loop against our own workflow".

## 2026-10-30T19:18:37-04:00 (Claude S11, chat): controls are autopilot; travel shortcuts test-only

Pat: "I honestly just don't like the controls. It basically means you can complete almost every mission while half of your maneuvering is just clicking a button and watching autopilot. That defeats the whole purpose of the entire waypoint mode and the pause planning selection stuff. There should be controls for depth, interacting with nearby interactable objects, movement controls and recover drones."
Q: "Should I drop the one-press travel shortcuts and make planned waypoints plus an in-reach job menu the way you move? I recommend yes, and stripping the route-target part out of 126 before it merges."
Pat: "They are fine for testing but they will absolutely have to be stripped for release play".
Applied: 126 merges with its shortcuts (testing); 127 RELEASE CONTROLS gates every one-press travel order behind dev state and adds in-reach jobs, depth pair, recall.

## 2026-10-30T19:21:49-04:00 (Claude S11, chat): movement risk and edge assist

Pat on D9 (straight legs instead of auto-path): "You should still be able to crash. But there should be moderate autopilot for edges and stuff so you're not just getting stuck grinding on things if you fuck up. I don't know figure it out it still got to be a game like there still has to be some challenge and risk to it."
Applied in 127: straight legs, rock legs allowed with warning, crash damage unchanged, edge slide/hold assist.

## 2026-10-31T21:27:54-04:00 (Claude S12, chat): minimum tests, fastest path

Pat: "From now on you should always and this needs to be hard locked either in your claude.md or any of the startup instructions etc wherever it's useful without being redundant, you should always be using the absolute minimum number of required tests and you should always be aiming to get them as quickly done as possible. This doesn't mean take shortcuts, this doesn't mean modify CI to pass on a red, this means taking the most efficient and shortest pass on every single task. We should be working at the speed of professional game Dev with compute, not tired intern half-assing the next task to say they did it"
Applied (D36): builders run locally only import, core, the suites their diff touches or adds, the canaries and check-suites; the full matrix runs once, in parallel, in CI (which lists every failure in one run since 136), never in local lanes. No suite already green on the same head is rerun. The PR goes ready as soon as phase A is done so CI runs while evidence and review happen. Never loosen, skip or delete a test, and never edit CI to pass on red.
