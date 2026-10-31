# Item 135: Prep screens put the decision first (package 5, part 1)

Goal (player): Fittings opens on the craft loadout (hull, drone frames, modules) before racks, stock and archive links; the Career board opens on the contracts you can take before management buttons and the recovered/lost history.
Why now: Critic 123 C26 (fittings_menu.gd:11-19) and C32 (career_board.gd:26-30), both verified high. C41 (dive-end stats) moved out: it lives in campaign_flow.gd, which item 127 owns (D28).
Class: ui
Areas: equipment, career.ui
Files: game/src/presentation/fittings_menu.gd, game/src/presentation/career/career_board.gd, game/tests/prep_decision_first_ui_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
prep_decision_first_ui_tests: on Fittings the first interactive control after BACK is a loadout or module control; on the Career board (no active contract) the first contract button comes before SUPPLIES / RESEARCH, FLEET / FITTINGS and the history text. Every control present before is still present (same ids).

## Do not
Change prices, economy, entitlements or which controls exist. Hide anything; only reorder and, if needed, group under a heading.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: before/after control order lists for both screens, test counts; PNGs at 100% if the render backend is available.

## Builder notes
Branch item/135-prep-results from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
