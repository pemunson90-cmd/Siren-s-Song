# Item 144: ALL STOP shows its restart cost before you press it

Goal (player): The ALL STOP button and its engage message state both costs up front: the oxygen spent and the 6 s limited-thrust restart (for example ALL STOP / 1.0% O2 · 6s restart), so the choice to go dead quiet is made knowing it costs time to get moving again.
Why now: Critic 123 C10 (verified in source: all_stop_table.gd:37-45 and all_stop.gd:96-97 show only the oxygen cost; the restart delay appears only after a restart begins).
Class: text
Areas: sim.allstop
Files: game/src/simulation/all_stop/all_stop_table.gd (TEXT only), game/src/simulation/all_stop/all_stop.gd (format arguments only), game/tests/all_stop_text_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none (RESTART_SECONDS, oxygen costs and noise values are read, never changed)

## Acceptance test (fails before, passes after)
all_stop_text_tests: the button label for an engine-on Quietus contains the oxygen cost and the restart seconds taken from RESTART_SECONDS; the engage message names the restart seconds; changing nothing else. Fails today (no restart seconds before restart).

## Do not
Change any ALL STOP value or behaviour. Exceed the button's existing two lines.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
text: string diff before -> after, test counts.

## Builder notes
Branch item/144-all-stop-cost from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
