# Item 141: Legs warn when they pass through your own craft

Goal (player): While placing legs, a leg that passes within hull clearance of another of your craft (parked drone, Quietus, a drone on its own leg end) turns red like a rock leg and names the craft (for example PASSES DRONE B), so you do not ram your own fleet by accident. You may still place it.
Why now: Critic 123 C06 (routes and recovery crowd parked craft, collisions, no warning; verified high). Split from 133. Builds on 127 rock-leg warnings (HandPilot.warnings, release_controls.gd:68-83).
Class: ui
Areas: hud.legs
Files: game/src/simulation/hand_pilot/hand_pilot.gd (warnings() only), game/src/presentation/release_controls.gd (warning text only), game/tests/own_craft_leg_warning_tests.gd
Serial zones touched: none
Depends on: 127
Protected rules touched: none (collision, hull, damage and COLLISION_HULL_CLEARANCE are read, never changed; no path planning)

## Acceptance test (fails before, passes after)
own_craft_leg_warning_tests: with drone B parked on a straight leg's line, HandPilot.warnings for the Quietus returns a warning for that leg naming DRONE B; moving the leg 40 m clear returns none; a leg crossing rock still returns its rock warning; placing the warned leg is still allowed. Fails today (no own-craft warning).

## Do not
Change collision, damage, clearance or movement. Steer or block the leg. Warn about Sirens or other non-fleet bodies.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: test counts; one PNG of a warned leg if a render backend exists.

## Builder notes
Branch item/141-own-craft-legs from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
