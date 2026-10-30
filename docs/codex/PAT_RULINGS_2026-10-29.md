# Pat rulings, 29 Oct 2026 (Claude S6 question widget, ~09:30 to 09:45 ET)

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
