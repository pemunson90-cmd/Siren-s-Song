# Code base audit: how tangled, how inefficient, and what to do

Status: COMPLETE (2026-11-12, phase 8, WP-18). No code was changed by the audit. The fixes in section 3 wait for Pat's yes or no.

Evidence levels: sizes and counts were measured by scripts on head `aa0833c7` plus the loadout rename. Run-time findings come from reading the code paths; nothing was timed. Dead-code numbers are lower bounds (names built from strings were not traced).

## 1. Plain answer

**Is it a tangled mess?** Partly. The game is not full of dead or abandoned code: every source file is used, and only two small functions are called by nothing. The tangle is concentrated in four places:

1. **Two hub files hold everything together.** `simulation.gd` (1,539 lines, 116 functions) runs the dive. `main.gd` (929 lines, 87 functions, 79 variables) holds the screen, input, saving and menus. 154 of the 362 source files reach directly into the simulation's insides and 86 reach into Main's, including 60 of Main's private parts. A change to either hub can break files far away from it.
2. **The tests describe an older game than the one you play.** Your rules (drones launch from Quietus, discovered charts, EMP rules, factory sensors, quieter drones) are switched on only for player dives. 225 test files start a dive, and one of them turns those rules on. The rest test the older behavior. Two suites failed today only because they still expected the word DISRUPT and drones already in the water.
3. **The same names and numbers are written out in many files.** Siren role names appear as text in 51 files (205 places). Noise names such as ACTIVE SONAR are in 7 files. The three craft, the three loadouts (in two different orders) and the depth band names are each copied into several files. Adding a Siren type or a tool means finding every copy.
4. **The code is written very densely.** Lines average 66 characters, 250 lines are over 300 characters and the longest is 1,454. Many statements share one line. That makes the code slow to read and easy to break, for a person or an agent.

Smaller tangles: Career, Expedition and Challenges are three near-copies of the same session, save and menu code. 22 feature switches are permanently on and their "off" side is never tested. 318 test files each carry their own copy of the same checking helper.

**Is it inefficient?** In places. No timing had ever been recorded, so the audit ran the existing simulation probe once (section 4.5, on this desktop, not a phone). The simulation is light on 37 of the 42 operations (about 1 millisecond per step, where 16.7 is the limit for smooth play). The five exceptions are opening operations 0, 2, 3, 4 and 5, the first things a new player sees: their sensing pulse takes about 18 milliseconds on the desktop, seven times a second, which on a phone would very likely be a visible stutter. The cause is an older sensing routine that only those operations still use. Drawing has not been timed (that probe needs a real screen). From reading the code:

- **While time is paused the game is cheap.** It already limits itself to about ten screen updates a second.
- **While time is running the screen does far more work than it needs.** Every frame it rebuilds the whole HUD text, redraws every charted map square one by one, and makes fresh copies of the same data several times (the objective list about five times a frame, the chart on every draw). On a phone this is the most likely cause of heat, battery drain and dropped frames.
- **The simulation itself is mostly fine.** A few values are recalculated for every Siren and every craft sixty times a second when once would do. The one heavy part is how Sirens hear around rock, which is gameplay and should not be touched without exact before-and-after tests.
- **The autosave** runs every 5 seconds of play on the main thread and checks its work three times. That may cause a small regular hitch. Unmeasured.

**What this costs you.** Changes take longer and break more often than they should (today's small rename touched 8 files and broke 2 test suites that were already out of date). Tests pass while the game you play can still be broken. Battery and smoothness on the phone are probably worse than they need to be.

## 2. What the audit did not find

- No unused source files. No large dead functions (2 orphan functions, 29 lines; 9 functions used only by tests, 23 lines).
- No loading of files during play, no sorting every tick.
- Most per-operation modules switch themselves off outside their operation.

## 3. Fixes, ranked, each a yes or no for Pat

Size: S (under a day of agent work), M (one to two days), L (several days, in steps). Risk is the chance of changing how the game plays by accident.

| No. | Fix | What you get | Size | Risk | Recommendation |
| --- | --- | --- | --- | --- | --- |
| A1 | Finish the baseline: the simulation probe was run by the audit (section 4.5); still to do are the drawing probe (needs a screen: one GitHub run or the phone) and a run with your player rules switched on | Every later speed claim is a measurement | S | None | Yes, first |
| A2 | Stop rebuilding screen data many times a frame: build the objective list, chart view, camera read-out and contact list once per simulation step and reuse them; update HUD text about ten times a second instead of every frame | Less heat and battery use, smoother play. No rule change | M | Low (display only; HUD text may lag by a tenth of a second) | Yes |
| A3 | Draw the charted map from a stored picture that is rebuilt only when the chart changes, instead of one square at a time every frame | Same as A2; the largest single drawing saving | S to M | Low (display only) | Yes |
| A4 | Simulation housekeeping with identical results: stop the opening operations (0, 2, 3, 4, 5) re-testing every unseen map cell on every sensing pulse (the measured stutter); calculate each craft's noise and the Hunt sight scale once per step, stop copying the whole chart on every sensor pulse, skip rock faces that are already charted | Lower processor use on busy operations. Proven identical by before-and-after tests | M | Medium (touches the simulation; guarded by exact-match tests and the protected-rules check) | Yes, after A1 |
| A5 | Make your rules the only rules: drones aboard and the parity rules become the default for every dive, the older path is retired, and tests are updated or moved to scrap with a list | Tests describe the game you play. One rule set instead of two | L | Medium (many tests change; no change to player dives) | Yes |
| A6 | One home for shared names: Siren roles, noise names, craft, loadouts, depth bands and Hunt stage names each defined once and referenced everywhere | Adding a Siren type, tool or loadout touches one table. Renames like DISRUPTION to EMP become one line | M | Low | Yes |
| A7 | One shared base for Career, Expedition and Challenges sessions, saves and menus | A fix in one mode reaches all three | M | Medium (save and resume code) | Yes, after A5 |
| A8 | Split the two hub files in steps: move the step driver out of the accessibility module, then input routing, saving and app lifecycle out of Main into their own files, then give other files a small set of named doors into the simulation instead of reaching inside | Changes stop breaking distant files. The largest long-term gain and the largest job | L | High if rushed; done as small steps each with its own check | Yes, after A5 and A6, one step at a time |
| A9 | One shared checking helper for the tests, and move the 7 test files that sit inside the game source into the tests folder | Less repeated test code; test files no longer sit beside game code | M (mechanical) | Low | Later, low value |
| A10 | Autosave: measure it; if it causes a hitch, save every 15 seconds and check the written file once instead of twice | Removes a possible regular stutter | S | Low (you ruled saves are minor priority) | Yes to measuring; the change only if A1 shows a hitch |
| A11 | Remove the "off" side of the 22 permanently-on switches | Slightly less code | M | Low | No. Leave them; they cost little and removing them gains little |
| A12 | Break up the very long lines across the code base | Easier reading | L | Low but touches every file | No as its own job. Do it only in files another fix already opens |

Suggested order if all are approved: A1, A3, A2, A4, A6, A5, A7, A8. A9 and A10 fit anywhere.

Not proposed: changing how Sirens hear around rock (the heaviest simulation cost found). It is gameplay. It is revisited only if A1 shows it dominates.

## 4. Measurements

### 4.1 Size and shape (script, `game/src` and `game/tests`)

| Measure | Value |
| --- | --- |
| Source files, lines, characters | 362 files, 33,346 lines, 2.19 million characters (66 per line) |
| Test files, lines | 470 files, 36,439 lines (1.1 times the source); 391 registered suites |
| Lines over 300 characters; over 1,000; longest | 250; 6; 1,454 |
| Functions; over 80 lines; over 4,000 characters | 2,845; 16; 54 |
| Folders under `game/src`; files of 30 lines or fewer | 71; 100 |
| Files that use `sim.<member>`; uses; distinct members; private members | 154; 3,770; 176; 20 |
| Files that use `host.<member>` (Main); uses; distinct members; private members | 86; 2,484; 173; 60 |

Largest files (characters, lines): `simulation/simulation.gd` 98,125 / 1,539; `presentation/mission_hud.gd` 60,577 / 835; `main.gd` 57,842 / 929; `presentation/photo_subjects.gd` 56,703 / 977; `presentation/ocean_view.gd` 53,790 / 870; `simulation/photo_capture.gd` 27,602 / 449; `presentation/photo_scene.gd` 26,846 / 413; `presentation/flow/campaign_flow.gd` 25,030 / 345.

Largest functions (lines, characters): `ocean_view.gd` `_draw` 225 / 14,449; `mission_hud.gd` `refresh` 155 / 12,327; `tutorial_missions.gd` `make` 101 / 10,460; `mission_hud.gd` `setup` 74 / 8,902; `simulation.gd` `valid_snapshot` 107 / 8,867; `fleet_instruments.gd` `refresh` 108 / 8,329; `simulation.gd` `_camera_context_base` 78 / 7,145; `simulation.gd` `_tick` 97 / 6,298.

Files that load the most other files: `simulation.gd` 64, `main.gd` 62, `campaign_flow.gd` 37, `mission_hud.gd` 36, `save_checks.gd` 35, `ocean_view.gd` 32. Files loaded by the most others: `equipment_catalog.gd` 39, `operation_catalog.gd` 31, `frontend_settings.gd` 21, `economy.gd` 20, `tool_racks.gd` 20, `field_tools.gd` 20.

### 4.2 Two rule sets (root, grep)

`main.gd:272-273` sets `drones_aboard` and `parity_rules` for every player dive. 28 source lines read those flags. 225 test files start a simulation; 1 test file mentions either flag. A second, older pairing has the same shape: `simulation.gd:744` holds legacy Hunt weights (decoy 4, survey 4) and `hunt_pressure/hunt_table.gd:14` holds the active ones (decoy 0, survey 0); the legacy numbers apply only when Hunt pressure is not active for the operation.

Stale tests found today: `loadout_ui_tests` (14 failures) and `truthful_commands_tests` (7 failures) expected DISRUPT wording and three craft in the water. `player_names_tests` (135 failures) still treated the word EMP as an internal id. All three were updated with the loadout rename. Other suites that were not rerun since phase 7 may hold more; 72 Main-driven test files touch drones.

**Sizing run for fix A5 (root, 2026-11-12, not committed):** with both flags defaulting to on, the core suite reached 810 of its 850 checks, reported 28 failures and stopped on a script error (`Invalid access to property or key '0' on a base object of type 'Dictionary'`). Failing checks include drone-station cases, sonar reserve cost (operations 1 to 5), and several end-to-end recoveries ("routed physical recovery completes changed-world operation", "finale completes via covered solo routes"). Each failure is either a test of the older rules or a sign that an operation is harder or unfinishable under the player rules; A5 has to sort them one by one. The other 390 suites were not run this way. Log: `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-p8-a5probe-144032\run_tests.log`.

### 4.3 Duplication (delegated script measurement, spot-checked by root)

| What is repeated | Count |
| --- | --- |
| Siren role names as text | 51 files, 205 places (patroller 36 files, hunter 30, sentinel 30, relay 21, sweeper 20, buoy 20, warden 17, interceptor 16) |
| Noise names (ACTIVE SONAR, DISRUPTION, KNOCKDOWN, RECON UPLINK) | 7 files, 7 to 11 places each |
| Craft id list `quietus, drone_a, drone_b` | 10 places in 7 files; craft display names 7 places in 6 files; `Q, A, B` 9 places in 6 files |
| Loadout list | 3 places in one order, 1 in another (`run_table.gd:6`), plus one table per tool in `field_tools.gd` |
| Depth band names | 4 files |
| Numbers 240, 330 and 0.65 in `simulation.gd` | 4, 1 and 3 places; none defined in `simulation/tuning.gd` (26 lines) |
| Career, Expedition, Challenge near-copies | 31 same-named function pairs over 80 percent alike; largest `restore` and `persist` in `career_archive.gd` and `run_archive.gd` (about 1,900 characters each), `_ready`, `_persist_state`, `_return`, `freeze_campaign` across the three session files |
| Test helper `check` | defined in 318 test files (969 lines), 24 distinct bodies, 144 identical; `settle` in 75 files, `finish` 51, `tick` 43, `tap` 42 |
| Permanently-on switches | 22 of 22 never set false in code or tests; 36 gated branches; about 178 "revert" comment lines |
| Unreferenced manual tools in `game/tests` | 20 files, 598 lines (`capture_*`, probes); not dead, used by hand |
| Test code inside `game/src` | 7 files, 1,049 lines |

### 4.4 Run-time cost (delegated reading of the code paths; estimates, not timings)

How the loop is built: the simulation runs a fixed step 60 times a second; a heavier sensing block runs every 0.15 s. While time runs, `main._process` calls `_refresh` and the HUD `refresh` every frame and the chart redraws every frame. While paused, both drop to a 0.1 s heartbeat. Autosave every 5 s of unpaused play.

| Rank | Where | What happens | How often | Fix | Risk to results |
| --- | --- | --- | --- | --- | --- |
| 1 | `simulation.gd:304` `observable_sites`, called from `ocean_view.gd` and `mission_hud.gd` | Deep copy of every objective, about five times a frame | Per frame | A2 | Low |
| 2 | `ocean_view.gd:348`, `terrain_chart.gd:65` | The chart's cell lists and surface segments are copied on every draw | Per frame | A2 (cache on the chart's `generation` counter) | None |
| 3 | `presentation/art/region_renderer.gd:32-38` | One rectangle per charted cell and two lines per rock segment drawn every frame, no culling | Per frame | A3 | None |
| 4 | `main.gd:393` `_refresh`, `mission_hud.gd:582` `refresh` | Full HUD recompute: camera context three times, acoustic rows, contact entries, layout, about 30 labels | Per frame | A2 | None |
| 5 | `simulation.gd:638` `camera_context` | Filters and loops all objectives; called at least three times a frame | Per frame | A2 | Low |
| 6 | `simulation.gd:1250` `_heard_arrival`, `acoustic_paths.gd:46` | Hearing paths around rock for each Siren against each craft and noise; path search when the direct line is blocked | Per step | Not proposed | High |
| 7 | `simulation.gd:235` `_terrain_observe` | Copies the whole chart twice at each sensor pulse | 6.7 times a second | A4 | Medium (save data must stay correct) |
| 8 | `terrain_chart.gd:96` `_first_surfaces` | Re-tests rock faces that are already charted | 6.7 times a second per craft | A4 | Low |
| 9 | `terrain_chart.gd:75` `observe` | Retries unresolved cells around each craft | 6.7 times a second per craft | A4 | Moderate |
| 10 | `main.gd:382`, `save_store.gd:70-96` | Autosave: snapshot, validate, encode, hash, write, read back twice, on the main thread | Every 5 s | A10 | None to play |
| 11 | `hunt_pressure.gd` `sight`, from `simulation.gd:1174` | Builds an 8-key table per Siren per craft per step; the value depends only on the Hunt stage | Per step | A4 | None |
| 12 | `recon_consequences.gd:12` | Copies the reconnaissance state every step | Per step | A4 | Low |
| 13 | `simulation.gd:1258`, `423` | `motion_radius(units.find(u))` per craft per Siren per step; same answer for every Siren | Per step | A4 | None |
| 14 | `ocean_view.gd:276` `contact_entries` | Rebuilt and sorted four or more times a frame | Per frame | A2 | None |
| 15 | `audio/soundscape.gd:158` | `recon_feedback` called twice a frame, once more by the HUD | Per frame | A2 | None |

Existing probes (not run by the audit): `game/tests/performance_measurements.gd` prints step times for operations 19 and 29 with no pass or fail threshold; `game/tests/art_render_measurements.gd` prints draw cost. The only enforced budget is `presentation/quality/quality_table.gd`: a two-second frame average above 33 ms for ten seconds suggests LOW EFFECTS to the player.

### 4.5 Simulation timing, measured (root, 2026-11-12)

`game/tests/performance_measurements.gd` with `--seconds=60 --operations=3,19,29,34 --profile`, headless on the development desktop, 3,600 steps per operation, craft idle, started the way the tests start a dive (without the player launch flags). Evidence level: scripted measurement on a desktop. Phone cost is not measured. The limit for smooth play is 16,667 microseconds per step.

| Operation | Mean step (microseconds) | Worst step | Movement | Siren threats | Sensing (observe) | Chart observe |
| --- | --- | --- | --- | --- | --- | --- |
| 3 | 2,783 | 24,519 | 963,355 | 1,285,377 | 7,242,382 | 3,311 |
| 19 | 1,211 | 3,697 | 1,179,676 | 2,227,335 | 225,333 | 3,555 |
| 29 | 872 | 2,268 | 976,037 | 1,402,850 | 141,738 | 3,220 |
| 34 | 1,104 | 2,900 | 1,374,008 | 1,768,852 | 301,155 | 3,242 |

The four right-hand columns are total microseconds over the 60 simulated seconds. Reading: on operations 19, 29 and 34 the simulation uses 5 to 7 percent of a desktop frame, and Siren threats (which include hearing) are the largest part. On operation 3 sensing takes 72 percent of all simulation time: about 400 pulses at about 18 milliseconds each, and the worst step (24.5 ms) is already longer than one frame on a desktop. The cause is not traced yet; the run-time reading (rank 25 in 4.4) names an older fog loop over every map cell that runs when an operation has no depth charts, which fits. Log: `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-p8-perf-133123\performance_measurements.log`.

**All 42 operations, 15 simulated seconds each (same probe, same desktop, same day):**

| Group | Operations | Mean step (microseconds) | Worst step | Sensing share |
| --- | --- | --- | --- | --- |
| Slow | 0, 2, 3, 4, 5 | 2,607 to 3,063 | 20,868 to 23,559 | 1.74 to 1.89 seconds of sensing in 15 (about 17 to 19 ms per pulse) |
| Normal | 1 and 6 to 41 | 567 to 1,876 (highest: 16, then 20 and 32) | 1,197 to 7,200 (highest: 8, then 16) | 0.03 to 0.23 seconds in 15 |

The slow group is exactly the opening operations a new player meets first (operation 1 is the exception). They take the older sensing path in `Simulation._observe`: with no depth charts, every sensor pulse re-tests every map cell that is not yet known to be water, and cells that can never be seen are re-tested forever. Later operations use the newer chart and skip that loop. Fix A4 covers it (remember cells already tested from the same craft positions, or move these operations onto the newer chart); results must stay identical. Log: `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-p8-perfall-133257\performance_measurements.log`.

**Fixed the same day (WP-19).** The pulse now skips cells outside every craft's reach. Same probe, same desktop, 15 simulated seconds, identical save hashes before and after: operation 0 mean 2,607 to 797 and worst 20,868 to 2,525; operation 2 mean 3,063 to 1,095 and worst 23,559 to 2,641; operation 3 mean 2,754 to 935 and worst 23,017 to 3,622; operation 4 mean 2,932 to 1,169 and worst 22,031 to 3,103; operation 5 mean 3,031 to 1,242 and worst 22,938 to 4,147 (microseconds). The core test run also fell from about 180 to 110 seconds.

## 5. Method

- Size and shape: root, one Python script over `game/src` and `game/tests`.
- Duplication and dead code: one read-only Sonnet agent with scripts (function bodies hashed, same-named functions compared, references searched by path and by name).
- Run-time cost: one read-only Sonnet agent reading `_tick`, the draw functions and `_process` and every function they call.
- Root added the two-rule-set finding and checked the Hunt weight tables, the flag sites and the stale tests.
