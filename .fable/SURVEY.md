# Survey: Siren's Song at base cabd5bd5

Status: IN PROGRESS (2026-11-11, Phase 1). Sections 1 to 6 are complete. Section 7 (ranked weaknesses) is provisional until the three blind critics report and `.fable/COLD_REVIEW_6.md` is written.

Sources: a read-only explorer read the code (it ran no tests; items marked "inferred" were not executed), the root session read the governing documents, the specification, the rulings and the CI workflows. Paths are relative to `game/` unless they start with `docs/`, `scripts/` or `.github/`.

## 1. Size and shape

- `src/`: 346 scripts, 31,987 lines, about 2.17 MB. Lines are dense: 104 lines exceed 400 characters and many chain statements with semicolons, so line counts understate the code.
- `tests/`: 453 scripts, 34,245 lines. 374 suites are registered in `tests/suites.txt`.
- One scene, `scenes/main.tscn` (a `Control` with `src/main.gd`). All interface is built in code. No `class_name` anywhere: 1,253 `preload` references and about 50 runtime `load` calls. No autoloads and no input map in `project.godot`.
- Indentation is mixed: 115 files use tabs, 218 use single spaces.

| Folder | Files / lines | Purpose |
| --- | --- | --- |
| `src/main.gd` | 1 / 902 | Host object: builds the interface, routes input, saves, handles lifecycle. Other modules call its private methods 579 times across 45 files. |
| `src/simulation/` | 60 / 7,179 | Deterministic dive simulation. `simulation.gd` is 1,517 lines. |
| `src/campaign/` | 86 / 5,228 | Operation registry and factories, encounters, economy, endings, Expedition, Career, Challenges, ledger. |
| `src/presentation/` | 141 / 13,834 | Chart, HUD, menus, photo rendering, frontend, accessibility. `photo_subjects.gd` 977, `ocean_view.gd` 866, `mission_hud.gd` 811. |
| `src/persistence/` | 20 / 2,144 | Archive store, save validation, snapshots, profiles, settings. |
| `src/equipment/` | 8 / 599 | Fitting catalog (24 items), field tools (8), tool racks. |
| `src/audio/` | 9 / 659 | Soundscape, event cues, photo audio, role signatures, region beds. |
| `src/debug/` | 5 / 556 | Developer console, overlay, developer-state taint, control-mix count. |
| `src/photo_rules/`, `photo_depth/`, `photo_grade/` | 12 / 707 | Photo windows, depth-band trade-offs, grade on secure. |
| `src/diagnostics/`, `src/input/` | 4 / 179 | AI trace recorder; map gesture state machine. |

## 2. Entry points and runtime

- `main._ready()` builds `OceanView`, the HUD (`MissionHUD`, `CaptionView`, `LockWarning`), the menu panel, `RouteProgramPanel`, `Soundscape`, then starts operation 0 paused so a mission always exists, loads the archive, shows the campaign and the title frontend. The developer console is installed only in debug builds (`main.gd:180`).
- Challenge, Expedition and Career each instantiate a second `main.tscn`, replace its script with a subclass of `main.gd` (`frontend/challenge_session.gd`, `runs/expedition_session.gd`, `career/career_session.gd`) and add it under the campaign host, which is frozen meanwhile.
- The simulation is advanced from `main._process` through `presentation/accessibility/tactical_aids.gd` (`advance`), which then calls the developer console or `sim.advance`. An accessibility module owning the tick is unexpected.

## 3. Simulation core

- `Simulation` is a `RefCounted`. `advance(dt)` uses a fixed step of 1/60 s with an accumulator and stops while paused or once an outcome is set. There is no random number generator in the simulation; determinism rests on the fixed step and on insertion order. Seeded randomness exists only in `campaign/runs/*` (Expedition selection, offers, Siren patrol starts) and `campaign/career/riders.gd`. Expedition "generation" selects and parameterises authored operations; it does not generate maps.
- Sirens: eight roles in `simulation/enemy_types.gd`. Tuning for patroller, hunter, sentinel and sweeper is in `sweeper_senses.gd`; buoy and relay are in `acoustic_network.gd`; interceptor and warden in `industrial_threats.gd`. Sight is 180 when the target runs silent and 290 otherwise, scaled by Hunt pressure and readiness, gated by depth. Lock grows while the target stays seen; at 4 seconds the beam destroys Quietus or the drone. EMP stuns for 12 seconds, the torpedo pins for 8.
- Sonar and sound: `advanced_sonar.gd`, `contact_reports.gd`, `contact_identity.gd`, `depth_bands.gd`, `thermal_front.gd`, `acoustic_paths.gd`, `current_field.gd`.
- Movement: release play uses `hand_pilot/hand_pilot.gd` (straight legs, edge assist, recall). Hull damage is `(impact - 12) x 0.45`, capped at 35, with a one second cooldown.
- Orders: `orders/order_table.gd` maps 55 orders to six families; `Simulation.command` dispatches through it.
- Snapshot, restore and a 100-line `valid_snapshot` validator are in `simulation.gd` (lines 1333 to 1453), partly delegating to `persistence/save_checks.gd`.
- `tests/protected_rules_tests.gd` pins the protected constants against `tests/fixtures/protected_golden.json`.

## 4. Content definitions and expansion cost

| Content | Where | Data-driven? |
| --- | --- | --- |
| Operations (IDs 0 to 41) | Registry in `campaign/operation_catalog.gd`; factories in `shelf_signal_operation`, `opening_depth_operations`, `divergence_missions`, `onward_missions`, `resolution_missions`, `glass_reach_operations`, `iron_choir_operations`, `final_pair_operations`, `calder_trench_operations`, `optional_operations`, `sorley_operation`, plus `encounters/*` | Hybrid. Registry rows are data; geometry, Sirens and objectives are code. `Catalog.make` passes every operation through about 12 modules. |
| Regions | No first-class concept. `presentation/art/region_table.gd` maps hard-coded ID ranges to style keys; `audio/region_audio_table.gd` uses the same keys | Hard-coded in logic. |
| Routes and branches | `route` and `required_facts` in the registry, `campaign_consequences.gd`, `route_map/route_graph.gd` (hard-codes `id<6`, `id==6`), `route_graph_table.gd`, `arcs/choir_fork.gd`, fork targets in `save2_table.gd` | Mostly tables, with ID checks in logic. |
| Endings | `campaign/endings.gd` (four families, late votes, resolves after operation 34), `presentation/finale/*`, `ledger/*` | Table plus logic. |
| Expedition, Career, Challenges | `campaign/runs/*`, `campaign/career/*`, `campaign/challenges/*` | Data tables plus seeded selection. |
| Economy and presets | `campaign/economy_table.gd`, `economy.gd`, `economy_options.gd` | Data table. |
| Fittings and tools | `equipment/equipment_catalog.gd` (24 items), `field_tools.gd` (8 tools), grants in `craft_upgrades.gd`, `early_reward/reward_table.gd`, `glass_research.gd` | Rows are data; effects are keyed by item ID in code. |
| Hunt caps, endurance | `simulation/hunt_pressure/hunt_table.gd` (array indexed by operation ID), `campaign/endurance_budgets.gd` | Arrays indexed by ID. |

Sites to touch today:

- **New operation:** 6 to 10 at minimum: factory, registry row, `hunt_table.CAPS` (must be appended), `region_table` ID ranges and audio bed, `route_graph_table.POSITIONS`, and optionally fork targets, landmarks, photo rows, pricing, rules, endurance, launch layout. Some operation IDs are hard-coded in `main.gd` (lines 389, 830, 861) and `campaign_flow.gd` (273 to 281). 57 sites compare a mission ID to a literal.
- **New Siren role:** 10 to 30 files. Role name literals appear in 30 non-test files.
- **New fitting:** 2 to 8 files, depending on its effect.
- **New region:** 3 to 5 files plus an audio bed.

This is the expansion-readiness gap: the specification asks for reusable operation, encounter, equipment and consequence definitions, and the code still keys much behavior on literal IDs.

## 5. Persistence, interface, audio, tests

- **Archive:** `persistence/save_store.gd`: magic, SHA-256, length, then `var_to_bytes`. Version 2 (1 and 2 accepted). Writes go to a temporary file, are read back, the primary rotates to `.bak`. No versioned migration chain; fields migrate lazily. Snapshots (three manual, four fork) with a transaction journal in `save_states/*`. Three profiles with copy, clear, export and import in `profiles/*`. Settings in `user://settings.json`.
- **Input:** `main._input` passes each event through the developer console, the optical feed, contact touch, HUD pointer ownership, fleet handles, the advanced-orders popup, then the map gesture (`input/map_gesture.gd`: tap, pan, pinch).
- **Android:** `main._notification` pauses and saves on focus-out and on back; `_android_back` walks the open surfaces; double back within 2.5 s exits from the menu only. `quit_on_go_back` is false.
- **Developer shortcuts:** `presentation/release_controls.gd` lists eight travel shortcuts, six of them developer-only, allowed only when `DevState.marked(host)`. Each call site carries a `# TRAVEL:<key>` tag that a test checks.
- **Audio:** `audio/soundscape.gd` builds the buses, drains `sim.events` every frame and plays cues; role signatures, event cues and region beds have their own tables.
- **Tests:** flat folder; 301 files define their own `check` helper, there is no shared assertion library. Seven test files live under `src/` behind one-line wrappers in `tests/`. 18 `capture_*.gd` scripts and three probe scripts are manual tools that nothing references. `scripts/toolchain/test.sh` requires the strict `CHECKS N FAILURES 0` line per suite.
- **CI:** see `.fable/CI_INVENTORY.md`.

## 6. Defects and risks found

| ID | Finding | Evidence | Level |
| --- | --- | --- | --- |
| S-01 | **Possible progress loss.** With an unreadable save, the title promises "The original files are untouched". Focus-out and back both call `_save_archive()` because a mission always exists, and `save_store.save()` removes an unreadable primary and writes a fresh empty campaign; a second save rotates that over the old `.bak`. Two focus-out events at the title could destroy both unreadable files before they are preserved. No test covers unreadable state plus focus-out. | `main.gd:745-759`, `save_store.gd:77-83`, `frontend.gd:43-62` | Read from code; not reproduced. Verify with a test first. |
| S-02 | A developer-tainted profile imported into a release build re-enables the developer-only travel shortcuts, because the gate is save taint, not build type. | `debug/dev_state.gd:5-10,41-47` | Inferred from code. |
| S-03 | Exported builds likely include `tests/` and the seven test files under `src/`: both export presets use `all_resources` with no exclude filter. | `export_presets.cfg` | Inferred; check the APK contents. |
| S-04 | 27 `print("SS_...")` diagnostics run in every build. | `main.gd:853-877` and others | Read from code. |
| S-05 | Dead null guards on a typed Dictionary (`sim.mission==null`), while the real empty-mission case is unguarded in `_refresh`. | `main.gd:669,746,374` | Read from code. |
| S-06 | Duplicated data: default tool stock in `simulation.gd:103,141-144` and `equipment/field_tools.gd`; the local-work order list in `simulation.gd:516` and `main.gd:27`; unit names in four places; Quietus identified by display name in `_hull_strike`. Loadout order differs between `run_table.gd` and `field_tools.gd`. | paths as listed | Read from code. |
| S-07 | Music, effects and mute settings are stored both in the campaign archive and in `settings.json`. | `main.gd:644,723`, `frontend_settings.gd:31-33` | Read from code. |
| S-08 | `tests/protected_rules_tests.gd` and its fixture name `docs/state/RULINGS.md` and `RULING_TESTS.md`, which exist only on `codex/handoffs`. | test file and fixture | Read from code. |
| S-09 | Repository hygiene: 441 tracked scripts have no tracked `.gd.uid` file (359 do), three title `.import` files are untracked, there is no `.gitattributes`, and a Godot import on Windows leaves 43 tracked `.import` files modified by line endings. | `git status` after import | Observed. |
| S-10 | `docs/MODULES.md` is 253 source commits behind and has no rows for Career, Ironman losses, the operation catalog, most per-operation simulation modules, release controls, truthful commands and hand piloting. | explorer comparison | Read from files. |
| S-11 | Thirteen documentation contradictions, including the APK prohibition that Pat lifted on 1 Nov. | `.fable/DOC_INVENTORY.md` | Read from files. |
| S-12 | CI gaps: the nightly has never run; 17 tool self-tests are not in CI; the affected-suite selection almost always falls back to the full 50 minute matrix. | `.fable/CI_INVENTORY.md` | Observed in run history. |
| S-13 | The critic kit was unversioned and too slow to meet its coverage contract: the 5 to 8 Nov Critic 6 took 98 segments to reach the second operation. | tool cache `critic6-cabd-20261105` | Read from its ledgers. |

Code-quality observations without a single defect: two god objects (`main.gd`, `simulation.gd`), 118 `set_meta` calls with 45 keys as hidden state, 38 feature switches and 167 "revert" comments kept so features can be turned off, seven `TODO` markers (six on Glass Reach recovery corridors, one for the creator credit line, which is Pat's).

## 7. Ranked weaknesses and opportunities (provisional)

Ranked by Pat's priorities (gameplay, graphics, interface, bugs, features above story). Critic findings will reorder the gameplay rows.

1. **Progress-loss risk S-01.** Pat ruled on 2026-11-11 that save files are minor priority while the game is unfinished, so this is P2 backlog, not P0. It stays listed first here only because it is the one defect that could lose data.
2. **Governance and documentation sprawl** (S-10, S-11): stale banners, contradictory rules, status on another branch. P0.
3. **Repository hygiene** (S-09) and **CI and harness gaps** (S-12, S-13). P0.
4. **Photo payoff:** value favors distance and tools over photo quality (STATE.md plan item, COLD_REVIEW_4 F1 and F15). P1.
5. **Late-operation variety and the branching route graph:** forks mostly change approaches inside operations, not which operations you get; 29 of 41 operations were classed as waypoint runs on 28 Oct before the pressure fixes. P1, and it depends on rank 6.
6. **Expansion readiness:** operation, region, role and fitting definitions keyed on literal IDs (section 4). P1: data-driven tables and guides for adding an operation, a Siren role, a fitting and a region.
7. **Received content:** ARRIVALS opens instructions instead of the received content (COLD_REVIEW_5 rank 9, no later item). P1.
8. **Fitting allocation** (COLD_REVIEW_5 rank 10, partly addressed by items 135 and 138). P1 or P2 after the critics.
9. **Release hygiene:** S-02, S-03, S-04. P1.
10. **Code duplication and dead guards** (S-05, S-06, S-07). P1 small packages or P2.
11. **Look and sound:** read-only comparison only; art is Pat's call and audio has never been assessed. P2 backlog and decisions.
