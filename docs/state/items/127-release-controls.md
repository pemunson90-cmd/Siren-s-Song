# Item 127: Release controls, pilot by hand

Goal (player): In release play you move by placing legs while paused, change depth, work what is in reach and recall drones. One-press travel exists only behind the dev state.
Why now: Pat 2026-10-30 19:18 and 19:21 (RULINGS.md section 3). Full spec: docs/codex/127-release-controls.md.
Class: sim
Areas: sim.orders, hud.orders, debug.dev_state
Files: game/src/simulation/orders/**, game/src/presentation/mission_hud.gd (order availability only), game/src/debug/dev_state.gd, help text, their tests, and route installation (D28): game/src/main.gd, game/src/presentation/ocean_view.gd, game/src/simulation/simulation.gd, module_recovery*.gd, campaign_flow.gd, truthful_commands.gd, order_guard.gd, save_checks.gd, game/src/simulation/hand_pilot/**
Serial zones touched: mission_hud.gd, ocean_view.gd, simulation.gd, main.gd
Depends on: 126
Protected rules touched: none

## Acceptance test (fails before, passes after)
release_controls_tests (R1): no travel shortcut visible with dev off, all present with dev on, static TRAVEL_SHORTCUTS guard. hand_pilot_journeys (R2): ops 2,16,17,18,21,22,30 finish by hand on STANDARD and ACCESSIBLE, bare, Quietus SILENT. crash_possible_tests (R4) skeleton.

Size (D28): source under about 400 lines; mechanical test adaptations to the dev state do not count.

## Do not
Change beam, lock, senses, collision/hull/damage, job ranges. Plan paths around terrain for the player. Add a second dev flag.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
R2 table; screenshots of craft wheel, in-reach job page, drone RECALL, refused leg, both shapes 100/150%. An op that cannot be finished by hand is reported, not tuned away.

## Builder notes
Branch item/127-release-controls from origin/claude/integration. Preferred provider: codex then claude:opus.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
