# ARCH_AUDIT_1: structure audit (read only), base 522b665

Numbers come from origin/claude/integration. "Edits" = commits touching a file since 15 Oct (624 commits total).

## 1. Top structural problems, worst first

**1. simulation.gd is the single choke point.** 1577 lines, 102 KB, 111 functions, 35 preloaded feature modules, touched by 89 of 624 commits. 41 lines are over 200 characters wide, so one edit changes a whole dense line and two builders collide even when they touch different features. Inside it, `command()` runs about 156 lines: one long list of orders (route, ping, emp, knock, decoy, camera, salvage...). Every new order is added here. The orders for route, silent, drone drive and ping carry the same "set the route mode" loop copy-pasted twice.
Cost: any two lanes that add an order or a feature hook conflict in the same function.
Smallest fix: extract the plain orders into `game/src/simulation/orders/` (one small file per order family: `route_orders.gd`, `sensor_orders.gd`, `weapon_orders.gd`, `photo_orders.gd`). `command()` keeps the guards at the top and then looks the order up in one table `{ "ping": SensorOrders, ... }` and calls it. Feature orders (choir, glass, chain, delivery) already delegate with one line each, so they just move into the table.

**2. Save checking is scattered and in places duplicated.** `Simulation.valid_snapshot()` calls about 15 feature `valid()` functions (30 simulation files and 7 campaign files each define their own), but also holds inline checks (rock shapes, objectives, the hard-coded measured reference `[0.8,1.6,0.8]`, a fixed list of enemy types at line 1508). `save_store.gd` then repeats equipment and evidence rules inline. The mission id and the required mission keys are checked twice in `valid_snapshot`.
Cost: adding a save field means finding the right one of several places; a missed one means old saves load wrongly or reject.
Fix: a tiny registry `game/src/persistence/save_checks.gd` listing `[Depth, Sonar, ModuleRecovery, ...]`, with `valid_snapshot` looping over it. Inline checks move into the module that owns the data. Enemy types become a const in one `enemy_types.gd`, read by both the checker and the sweeper.

**3. main.gd mixes menu, campaign flow, HUD plumbing and metrics.** 1046 lines, 71 KB, 75 functions, 66 commits. It contains campaign logic (`_new_campaign`, `_campaign_pristine`, `_sync_craft_upgrades`), photo review (`_merge_shots`, `_shot_report`, `_evidence_gallery`), and phone-metrics output (`_emit_ui_metrics`).
Fix: move in three steps into `game/src/presentation/flow/`: `campaign_flow.gd`, `photo_review.gd`, `ui_metrics.gd`. Main keeps one-line forwarders so nothing else changes.

**4. Presentation files each know every feature by name.** `mission_hud.gd` (627 lines, 45 commits, 27 references to specific features such as Delivery, Witness, Glass, Choir) and `ocean_view.gd` (677 lines, 54 commits, 16). Each new mission type means edits in both, and the Codex HUD and controls lanes live in exactly these files.
Fix: each feature already has a `*_view.gd` (blackwater, concealed harbour, module recovery). Give them a shared three-function contract (`applies(sim)`, `build_panel(hud)`, `draw(view)`) and have HUD and ocean view loop over a list. Move features across one at a time.

**5. The test runner is a hand-edited list in two places.** `scripts/toolchain/test.sh` (215 lines, 83 edits) repeats the same six-line run-and-check-summary block six times and then holds a 142-line pipe-separated list of scenarios. `run_tests.gd` (17 edits) and `runtime_tests.gd` (19 edits) each preload their own list. Every lane that adds a test edits these shared files, so they collide constantly even though tests are unrelated.
Fix: a loop over a plain list file `game/tests/suites.txt` (one suite per line, so merges are clean, one line each) replacing the six repeated blocks. Behavior is the same commands.

**6. Tuning numbers sit inside conditionals.** About 31 numeric thresholds in simulation.gd comparisons alone, for example EMP radius 340, recon radius 1100, noise radii 650/1100/520, drone thrust 42 vs 96, decoy 15 s, knock 150 m. Meanwhile `equipment_catalog.gd`, `endurance_budgets.gd` and `depth_bands.gd` are good data tables.
Fix: `game/src/simulation/tuning.gd`, a file of named consts grouped by order (`EMP_RADIUS`, `RECON_NOISE_RADIUS`, ...). Do it only for numbers inside orders being extracted in step 1.

**7. Copy-pasted "cancel when player releases hold" logic.** `cancel_released` is written separately in witness_evacuation, blackwater_delivery, glass_reach_work, module_recovery and warning_chain, differing only by where the job is stored. `command()` ends with six hand-written calls to them.
Fix: one `JobRelease.cancel(sim, unit)` that walks a list of job modules. Each module exposes `release_if_unheld(sim, unit)`.

**8. Naming and folder drift.** Campaign mixes `*_missions.gd` (tutorial, divergence, onward, resolution) with `*_operations.gd` (glass, iron, opening) for the same idea; simulation has `glass_reach_work` vs campaign `glass_reach_operations`; tests mix `_scenarios` (37), `_tests` (157) and `_ui_tests` (41) plus `capture_*` helpers in the same flat folder of 232 files. Do not mass rename; just stop new drift (section 4).

## 2. Pattern to copy

`game/src/campaign/operation_catalog.gd` (126 lines). Each mission is one table row: id, factory file, config, behavior tags, prerequisites. New content is one row plus its own file, not an edit to engine code. Second best: `sonar_sweeper.gd` (60 lines, three touch points in simulation.gd: advance, valid, the enemy-type list), and the `equipment_catalog.gd` data table. The sweeper's remaining weak spot is that enemy-type list at simulation.gd line 1508, which step 2 below removes.

## 3. Proposed ARCH1 milestone (each step is its own PR, behavior preserving)

Proof for every step: `scripts/toolchain/test.sh` (it runs run_tests.gd, runtime_tests.gd, loadout_ui_tests, navigation_departure_tests, well_signature_save_shape_tests, the scenario list and density checks). Targeted fast checks per step are named below. Counts "CHECKS n FAILURES 0" must be identical before and after.

1. Test list file: replace the six repeated blocks and the scenario list in test.sh with a loop over `game/tests/suites.txt`. Prove: log shows the same suites and the same total check counts.
2. Enemy types const plus save-check registry (problems 2). Prove: persistence_scenarios (in run_tests), well_signature_save_shape_tests, campaign_equipment_save_tests, divergence_save_tests, sweeper_scenarios.
3. `JobRelease` (problem 7). Prove: blackwater_delivery_tests, witness_evacuation_ui_tests, module recovery tests, warning_recipient_tests, glass scenarios.
4. Orders extraction, one family per PR, simplest first: weapons (emp, knock, decoy), then sensors (ping, recon), then route and drive. Include tuning consts for those. Prove: combat_rules_tests, knockdown_scenarios, decoy_deployment_tests, acoustic_scenarios, waypoint_scenarios, drone_drive_tests.
5. main.gd extractions (problem 3), one file per PR. Prove: runtime_tests, campaign_main_dispatch_tests, archive_recap_ui_tests, campaign_ui_scenarios.
6. HUD and ocean view feature contract (problem 4), one feature per PR, last, because Codex lanes live there. Prove: runtime_tests, the *_ui_tests for that feature, density checks.

**Do not refactor now:** the 14 to 29 mission content rows, Android and toolchain scripts, the long tail of per-feature test files (leave them in place), the physics and sonar math, and the dense one-line code style (do not reformat; it would touch every line and cause conflicts everywhere). No file renames in ARCH1.

## 4. Conventions note for builders

- New simulation feature: one file in `game/src/simulation/<feature>.gd` with static `applies`, `tick`, `valid`, `command`. Its only hooks into simulation.gd are one line each in tick, save check and (if it has an order) the order table.
- New order: add to the order table in its family file under `simulation/orders/`; never grow `command()` itself.
- New mission: one row in operation_catalog plus a factory file in `campaign/`, named `<region>_operations.gd` (use "operations", not "missions", from now on).
- Tunable numbers: named const in `simulation/tuning.gd` (or the feature's own data table), never a bare number in an `if`.
- Save fields: add the field inside your feature's own dictionary key, write a `valid()` in your module, register it in `save_checks.gd`. Never edit `save_store.gd` for simulation data. Bump `VERSION` only for shape changes, and keep old versions loadable.
- Presentation: one `*_view.gd` per feature implementing the shared contract; do not add feature names to mission_hud.gd or ocean_view.gd.
- Tests: `<feature>_tests.gd` (logic) and `<feature>_ui_tests.gd` (screens); add one line to `suites.txt`, never edit shared runners.
- Keep new lines under about 140 characters.

## 5. Risks

- SWEEP1 touches sonar_sweeper.gd and the lines near simulation.gd 1204 and 1503/1508. Do ARCH1 step 2 only after SWEEP1 merges, or leave the enemy-type list alone until then.
- PRICED1: the photo_pricing folders do not exist on this base yet. Do not touch photo_capture.gd, photo_ops.gd or photo_intel.gd, and add the photo order family (step 4) last, after PRICED1 lands.
- Codex HUD/controls and lock-warning readability lanes edit mission_hud.gd, ocean_view.gd and main.gd; steps 5 and 6 should wait for those to merge, or start with files they do not touch (ui_metrics, photo_review).
- Step 1 (suites.txt) conflicts with any lane adding a test line to test.sh; announce it, merge fast, and ask lanes to rebase.
- The command() extraction changes shared lines that almost every lane touches: freeze new orders for the one day each family PR is open.
