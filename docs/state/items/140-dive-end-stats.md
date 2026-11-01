# Item 140: Every dive end shows time, hull and oxygen

Goal (player): Whether the dive was recovered, lost, or ended on an expedition, the debrief shows one line: dive time, hull and life support at the end. Today only the classic recovered path shows it.
Why now: Critic 123 C41 (verified high on the code path; campaign_flow.gd:206-250: the stats line sits only in the won branch; the expedition branch returns before it and the loss branch never prints it).
Class: ui
Areas: campaign.flow
Files: game/src/presentation/flow/campaign_flow.gd (debrief only), game/src/presentation/runs/expedition_session.gd (results stats line only), game/tests/dive_end_stats_ui_tests.gd
Serial zones touched: none
Depends on: 127
Protected rules touched: none

## Acceptance test (fails before, passes after)
dive_end_stats_ui_tests: drive debrief for a won classic op, a lost classic op and a finished expedition run; each shows exactly one line matching Dive time MM:SS / Hull N% / Life support N% with the sim's values. Fails today on the lost and expedition cases.

## Do not
Change outcomes, rewards, saves or any other debrief text. Show the line twice on any path.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: the three debrief control lists before and after, test counts.

## Builder notes
Branch item/140-dive-end-stats from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
