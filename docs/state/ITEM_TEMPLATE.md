# Item template (40 lines max)

One file per item at `docs/state/items/NNN-slug.md`. The orchestrator writes it; the builder reads it and nothing else beyond the files it names. A player-facing goal plus an acceptance test, not an essay. If it does not fit in 40 lines, split it.

```
# Item NNN: <short title>

Goal (player): <two lines: what the player can now do, see or feel>
Why now: <one line: the critic finding, metric or ruling that ranks it>
Class: text | ui | sim | protected
Areas: <ownership areas from docs/state/areas.json, e.g. hud.wording, sim.orders>
Files: <globs the builder may edit; tests and docs for those files are implied>
  (If the item adds a step to an existing flow, such as a confirm or a new screen, also list the existing test fixtures that drive that flow: grep game/tests for the control. Items 142 and 143 each burned their phase B cap on this.)
Serial zones touched: none | main.gd | mission_hud.gd | ocean_view.gd | simulation.gd
Depends on: <item numbers that must be merged first, or none>
Protected rules touched: none | <ruling line verbatim with date>

## Acceptance test (fails before, passes after)
<suite name or harness command, and the exact assertion or number it must show>

## Do not
<two or three lines: what this item must not change>

## Evidence (per class cap in PROCESS.md section 5)
<the specific screens, ops or constants the PR must show>

## Builder notes
Branch item/NNN-slug from origin/claude/integration. Preferred provider: codex | claude:sonnet | claude:opus.
Checks before push: import, core, select-suites.py output, canary set.
```

## Example A: a sim item (127 rewritten)

```
# Item 127: Release controls, pilot by hand

Goal (player): In release play you move craft by placing legs while paused, change depth, work what is in reach and recall drones. No one-press travel exists outside the dev state.
Why now: Pat 2026-10-30 19:18: "half of your maneuvering is just clicking a button and watching autopilot ... they will absolutely have to be stripped for release play".
Class: sim
Areas: sim.orders, hud.orders, debug.dev_state
Files: game/src/simulation/orders/**, game/src/presentation/mission_hud.gd (order availability only), game/src/debug/dev_state.gd, game/src/presentation/help/**, their tests
Serial zones touched: mission_hud.gd
Depends on: 126
Protected rules touched: none (collision, hull and damage unchanged; crashing must remain possible)

## Acceptance test
release_controls_tests.gd: with dev off, no HUD page exposes route_here, glass_route, choir_route, recovery autopilot or object-tap auto-route; with dev on, all are present. hand_pilot_journeys.gd: ops 2, 16, 17, 18, 21, 22, 30 (the 127 handoff's list) finish on STANDARD and ACCESSIBLE using only leg, depth, work-in-reach and recall orders, Quietus SILENT, bare racks; table of time, Hunt peak, locks, hull, oxygen, legs, collisions, stuck-holds, drones recovered. crash_possible_tests.gd: one deliberate rock collision per shape still costs hull.

## Do not
Change beam, lock timing, senses, damage, work ranges or durations. Plan a path around terrain for the player. Add a second dev flag.

## Evidence
Both tables above; screenshots of craft wheel, in-reach job page, drone wheel with RECALL, a refused leg with its reason, both shapes at 100% and 150%. If any op cannot be finished by hand, stop and report it as a design finding, do not paper over it.

## Builder notes
Branch item/127-release-controls. Preferred provider: claude:opus (Codex out until about 3 Nov).
```

## Example B: a text item

```
# Item 131: Name the real exit on withdraw buttons

Goal (player): The withdraw button names the recovery mouth that actually exists on this op, with its distance, never a fixed "AT SOUTH".
Why now: critic 123 G2-F06 and Trench 3; source mission_hud.gd:111 hard-codes the string.
Class: text
Areas: hud.wording
Files: game/src/presentation/truthful_commands.gd, game/tests/truthful_commands_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test
truthful_commands_tests.gd: for ops 15, 16, 17 and 20 the withdraw caption equals the nearest extraction corridor's public name plus distance, under 24 characters.

## Do not
Change which exits exist or route logic.

## Evidence
String diff; one screenshot of the radial on op 17 at 100%, inner shape.

## Builder notes
Branch item/131-exit-names. Preferred provider: codex, else claude:sonnet.
```
