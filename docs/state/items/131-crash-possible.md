# Item 131: R4 crash possible with edge assist

Goal (player): Indirect: crashing stays possible and costly; the assist stops grinding without planning paths.
Why now: Pat 2026-10-30 19:21; RULING_TESTS.md R4.
Class: sim
Areas: sim.orders
Files: game/tests/crash_possible_tests.gd, game/tests/suites.txt
Serial zones touched: none
Depends on: 127
Protected rules touched: none

## Acceptance test (fails before, passes after)
crash_possible_tests green after 127 on both shapes.

## Do not
Change damage values.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
Test counts, 20 lines.

## Builder notes
Branch item/131-crash-possible from origin/claude/integration. Preferred provider: claude:opus then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
