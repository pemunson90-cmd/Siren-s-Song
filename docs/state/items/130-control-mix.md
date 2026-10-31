# Item 130: R5 control-mix telemetry (dev state only)

Goal (player): Indirect: the share of movement done by one-press travel is a number in every critic run and nightly.
Why now: RULING_TESTS.md R5; DIAGNOSIS cause 1.
Class: sim
Areas: sim.orders, debug.dev_state
Files: game/src/simulation/orders/**, game/src/debug/**, game/tests/control_mix_tests.gd
Serial zones touched: none
Depends on: 127
Protected rules touched: none

## Acceptance test (fails before, passes after)
control_mix_tests: counters zero for one-press kinds with dev off; non-zero in a dev run that uses them; voyage physics unchanged.

## Do not
Change any order behaviour or save shape outside dev.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
Test counts and one voyage hash line.

## Builder notes
Branch item/130-control-mix from origin/claude/integration. Preferred provider: claude:opus then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
