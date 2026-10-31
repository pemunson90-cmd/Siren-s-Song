# Tests that encode Pat's rulings (canary set)

Drafted 2026-10-30. These suites run before every push and on every PR. They exist so that a design decision Pat made cannot regress without a red check, and so that "finishable" means finishable the way the game is meant to be played. None of them may be skipped, loosened or deleted. A change to what they assert needs Pat's ruling line in the commit message and the `protected` evidence class.

| Id | Suite | Ruling it encodes | Can start |
|---|---|---|---|
| R1 | `release_controls_tests.gd` | travel shortcuts test-only (Pat 2026-10-30 19:18) | after item 127 |
| R2 | `hand_pilot_journeys.gd` | finishability measured by hand piloting; "it still has to be a game" (2026-10-30 19:21) | after 127 |
| R3 | `protected_rules_tests.gd` | the protected list (HANDOFF intent section; Pat's call only) | now |
| R4 | `crash_possible_tests.gd` | "You should still be able to crash" (2026-10-30 19:21) | after 127's edge assist, skeleton now |
| R5 | control-mix telemetry (dev state only) and `control_mix_tests.gd` | the autopilot smell must be visible in numbers | now |

## R1 release_controls_tests.gd

- Enumerates every HUD page for every craft on a staged op with every object kind present (site, wreck, plant, habitat, salvage, recovery mouth). With dev state off (`dev_state.gd` `marked()` false), asserts that none of the one-press travel keys is visible or enabled: `route_here`, `glass_route`, `choir_route`, recovery-chooser autopilot, WITHDRAW or HOME autopilot, object-tap auto-route. With dev on, asserts they are present. Same for the chart tap: an object tap with dev off never installs a route.
- Static guard: every `_order("route", ...)` or `_order("emergency", ...)` call in `game/src/presentation/**` must be registered in one table `TRAVEL_SHORTCUTS` (name, key, dev-only flag). The test greps the source tree and fails on an unregistered call, so a new shortcut cannot appear by accident.
- Must not: create a second dev flag; hide the planned-leg, depth, in-reach job or recall controls.

## R2 hand_pilot_journeys.gd

A deterministic policy that plays like a careful human with release controls only, built on `glass_fleet_voyage.gd`'s `FleetRun` pattern (its `command` whitelist is the right shape; today it allows `route`, which compiles legs through the pathfinder).

- Whitelist: the release leg order (whatever 127 names it), `depth`, the in-reach job orders (`camera`, `glass_action`, `choir_action`, work orders), `recall`, `select`, `hold`, `silent`. Any other order fails the run. After each leg order the harness asserts `unit.route` equals the goals it placed (no pathfinder corners inserted).
- Knowledge: the policy may read only `terrain_chart` cells the fleet has measured and contacts it has received. It never reads hidden Siren positions or unmeasured rock. A reviewer-visible assertion checks the policy's reads.
- Per op and preset (STANDARD, ACCESSIBLE; SURVIVAL reported, not gated): recovered yes/no, time, Hunt peak, received lock episodes, hull, oxygen, legs placed, collisions, stuck-holds, drones recovered, Quietus SILENT throughout, bare racks. Printed as `HANDPILOT ` JSON rows plus `HANDPILOT CHECKS N FAILURES 0`.
- Gate: every core op finishes by hand on STANDARD and ACCESSIBLE with bare racks. The "fleet must matter" bar (Pat 28 Oct) is reported from the same run: bare meets the Sirens (Hunt 20 or more, or a lock) in about three quarters of ops; an equipped variant of the same policy is clearly better in time, lock or hull. If an op cannot be finished by hand, the suite fails and the PR says so: that is a design finding for Pat, not something to tune away in the harness.
- Nightly: the same suite over every core op and side modes writes `metrics.json` (PROCESS.md section 6).

## R3 protected_rules_tests.gd

- A golden file `game/tests/fixtures/protected_golden.json` pins: silent sight 180 m, cruise sight 290 m, lock warning 4.0 s and its interruptibility flag, beam lethality (one-shot kill rule), the collision and hull damage table, the sweeper's V7 patrol parameters, photo exposure and grading tables, the ending-condition table, and the hearing values per role.
- The test reads the live constants from `tuning.gd`, the role tables, `photo_rules/` and `endings.gd` and compares. Any difference fails with the constant's name and both values.
- Changing the golden needs a commit message containing `RULING:` and the dated line from `docs/state/RULINGS.md`; the reviewer checklist checks for it. The test does not read the commit message; people do.

## R4 crash_possible_tests.gd

- Both shapes: a leg plotted straight into measured rock at cruise speed produces a collision event and a hull loss within the existing damage table. With the edge assist on, the first impact still costs hull; the assist then slides the craft along the wall or holds it, and a stuck craft reports a hold reason instead of repeated impacts (collisions per 10 s at most 1 after the first).
- The assist never changes the installed leg's end point and never routes around an obstacle: assert the route goals are unchanged after a slide.

## R5 control-mix telemetry

- In dev state only, the simulation records per order kind the movement distance it caused: one-press travel, planned legs, emergency, recall. `control_mix_tests.gd` asserts the counters are zero for one-press kinds when dev is off (because the orders do not exist) and non-zero in a dev run that uses them.
- Critic kits and the nightly read the counters and report the share of distance under one-press orders per op. The brief tells critics the number is reported; it does not tell them what to prefer.

## Where they live

Registered in `game/tests/suites.txt` with the next ranks and listed in `scripts/toolchain/canaries.txt`. R2 nightly mode is selected by an environment variable (`HANDPILOT_SCOPE=all`), the PR mode runs the seven ops the 127 handoff names (2, 16, 17, 18, 21, 22, 30) to stay inside the 15-minute budget.
