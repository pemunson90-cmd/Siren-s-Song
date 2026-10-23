# Handoff 016: one test list, and fix or retire stale tests

Status: DONE
Claimed at: 2026-10-22 23:33:48 UTC
Claimed by: codex
Finished at: 2026-10-23 00:57:56 UTC

Precondition: handoff 015 must be DONE or BLOCKED. Then run `gh`-free check: use the GitHub tools to list open pull requests. If any open PR edits scripts/toolchain/test.sh or .github/workflows/gauntlet-pr-checks.yml, do not start; set Status BLOCKED with a one-line reason and tell Pat (Claude will release you when those merge).
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): Claude's builders may be editing camera/photo code (photo_pricing folders), the sweeper (sonar_sweeper.gd), and later depth-band photo code. This handoff touches the test runner and tests only, so it should not collide; do not edit those source files.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add.

## Task (plain language)
Pat wants the code modular and easy to work on. An architecture audit found the test runner repeats the same run-and-check block six times plus a 142-line scenario list in scripts/toolchain/test.sh, so every lane that adds a test edits the same lines and collides. Also, tests exist that are not in the CI list, and at least one fails on claude/integration (radial_hud_tests has 3 failures and drone_drive_ui_tests times out locally on integration itself, both reported by Claude's DEPTH1 builder and neither in CI's list: include them in step 2; also archive_recap_ui_tests, "existing final warning", which looks for story text that was rewritten out of the game).
Do these in order, as one behavior-preserving PR:
1. Add one suite list file (for example game/tests/suites.txt, one suite per line, with a short comment header explaining the format) and make scripts/toolchain/test.sh and the GitHub workflow read it instead of repeating the block. A new test then means adding one line in one file. The set of suites that run, and their order, must stay identical. Prove it: record the suite names and the "CHECKS N FAILURES 0" totals from the core suite before and after, and compare the full list of names the old runner executed with the new one (a dry-run print is enough; do not run the full scenario list locally).
2. List every test file under game/tests that is not in the CI list. For each, say in your Completion section: runs and passes (then register it), fails because it asserts removed or rewritten text or behavior (then update it to the current behavior, never loosen it to pass), or is obsolete (then report it; do not delete without saying why).
3. Fix archive_recap_ui_tests so it asserts the current behavior, and register it if it then passes and runs in reasonable time.
4. Write a short docs/TESTING.md (under 30 lines): how to add a test, where the list lives, the rule "core suite must end CHECKS N FAILURES 0", and "a Godot resources-still-in-use line fails CI".

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-test-registry

## Files you may edit
scripts/toolchain/test.sh, .github/workflows/gauntlet-pr-checks.yml (only to read the list), game/tests/suites.txt (new), existing test files that are stale, docs/TESTING.md (new).

## Files you must not touch
Game source under game/src, any rule or content, the photo_pricing and sonar_sweeper files.

## What done looks like
The same suites run in the same order as before (proven), the list lives in one file, stale tests are fixed or reported, CI is green.

## Checks
Import, core tests ending CHECKS N FAILURES 0, and GitHub's guidance and game-smoke green on the exact head.

## Return
Pull request into claude/integration; merge it yourself per the Codex-may-merge line once green. Then mark DONE.

## Completion
DONE. PR76 merged into claude/integration: https://github.com/pemunson90-cmd/Siren-s-Song/pull/76.
Lane branch: `claude/lane-test-registry`. Last pushed lane SHA: `6564bb4e47a5ea6ff56ba57d16657b960d625e6b`.

PR74 merged and Pat explicitly released 016. GitHub tools listed only PR75 open when claiming; its filenames exclude the test runner and workflow. The lane contains merged NAV1 integration `07eb8905d2cc70babe92e87a26dbddf3750bb0ab`.

One registry replaces duplicated local and CI lists and repeated execution blocks. Historical orders were different, so each row has local and CI ranks. Exact old flattened prefixes match before and after, including the four local density guards: local 146 names, SHA256 `7762d0c0cedfe24966ac7ee468921a49a203992a70e505acf2f08259ab569aa2`; CI 89 names, SHA256 `790ace7031bf51e00dd3ec2f5f2d4f2ae43269bdf0ae5179b04188dc2705a7f4`. Names and original ranks remain recoverable in suites.txt. All original names and relative order retained; 94 missing standalone suites appended to CI. After registering the four NAV1 regressions, the CI profile contains 189 suites and local 168, retaining their original profile membership and relative orders before appending the audited additions. Import clean; core before, after and final all CHECKS 817 FAILURES 0.

The full inventory below accounts for all 160 GDScripts absent from original CI: 94 standalone suites, 38 reusable helpers, 6 scene/host subclasses, 20 capture/diagnostic utilities and 2 renderer-only regressions. No file deleted, no assertion skipped, no game source edited. No full scenario list run locally: only the unregistered-suite audit, core and affected repairs. All 94 originally unregistered standalone suites now pass, including route-program 35/0 on this lane after NAV1 integration. Four added NAV1 harnesses also pass: focused7/0, follow84/0, default probe24/0, touch/Android-back17/0. The NAV1 measurement module is a helper. The post-NAV1 inventory covers165 files:100 standalone harnesses (98 headless and2 renderer),39 helpers,6 hosts and20 tools. Both renderer suites are now verified and registered.

Fixed stale assumptions: current recap story and two-bearing ending; unavailable fittings remain visible but disabled; imported audio measured through real playback gain with old headroom bounds retained; isolated startup then ordinary saving; public photo marker coordinates; depth-band torpedo fixtures; same-tick one-hit beam outcomes; MIDDLE/local plant controls; explicit recovery departure; current PHOTO/fleet captions; real touch scroll to each setting; current VIEW menu; floating order-control avoidance; explicit route marker and touch confirmation. Journey controllers now defend during actual exposure and confirm departure rather than expecting obsolete passive survival. Parallel Confluence uses the existing disruption loadout, spends two of three EMPs, and wins with the sampler drone alive. These are source-known test controllers, not blind player-quality claims.

Requested suites: radial_hud_tests 58/0, drone_drive_ui_tests 38/0, archive_recap_ui_tests 8/0; archive recap model 14/0. Camera follow now 94/0 through ScreenTouch and platform-style emulated mouse, including tutorial GOT IT and explicit REPLACE ROUTE. Android touch remains primary. Actual device gestures/rendered images are not claimed.

Runner contract checked with eight controlled process probes: valid core summary accepted; zero-exit script error, resources-still-in-use, ObjectDB leak, wrong summary prefix, zero count, nonzero failures and nonzero process exit rejected. Strict original summary gates preserved and leak gates strengthened. docs/TESTING.md is under 30 lines. A user-local Xvfb binary enabled Compatibility software rendering without system installation. Planner renderer5/0 and Well renderer14/0 both passed through the registry runner. The optional fifth registry field `render` selects Xvfb/software GL; GitHub Ubuntu24.04 already supplies Xvfb/xauth. Original suite orders are unchanged. The Well fixture now explicitly supplies a valid legacy-shaped record for old illustration checks, freezes the presentation clock and invalidates its cached view model, then verifies current PHOTO1 rendering separately, including hidden-Siren invariance. No photo behavior was changed.

Final gate: guidance and game-smoke both succeeded on exact head `6564bb4e47a5ea6ff56ba57d16657b960d625e6b`, run39877500024. PR76 merged with merge commit `6229d09f9188376edee0d9672f4a761c648a8061`. Fresh integration07eb890 ancestry and mergeability verified immediately before merge. DONE and BOARD updated in the same commit. Full CI ran all189 suites, including both renderers. No source or assertion failure was observed; the complete run used nearly the existing35-minute budget. Future added coverage may need more job time. Next is the board's034 PRIORITY after016, then eligible numeric OPEN handoffs;018 remains Claude-owned.

### Inventory of every GDScript absent from the original CI list

| File under game/tests | Classification and evidence |
| --- | --- |
| `acoustic_footprint_tests.gd` | Runs and passes, 6/0; registered. Evidence: 016-audit-acoustic_footprint_tests.log. |
| `acoustic_hearing_tests.gd` | Runs and passes, 21/0; registered. Evidence: 016-audit-acoustic_hearing_tests.log. |
| `acoustic_path_affected_tests.gd` | Runs and passes, 53/0; registered. Evidence: 016-audit-acoustic_path_affected_tests.log. |
| `acoustic_path_tests.gd` | Runs and passes, 20/0; registered. Evidence: 016-audit-acoustic_path_tests.log. |
| `acoustic_path_ui_tests.gd` | Runs and passes, 7/0; registered. Evidence: 016-audit-acoustic_path_ui_tests.log. |
| `acoustic_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by acoustic_path_affected_tests, run_tests. |
| `acoustic_ui_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests, acoustic_path_ui_tests. |
| `archive_recap_fixtures.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by archive_recap_ui_tests. |
| `archive_recap_tests.gd` | Runs and passes, 14/0; registered. Evidence: 016-archive-model-final.log. |
| `archive_recap_ui_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-archive_recap_ui_tests.log. |
| `attention_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `audio_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `authored_plant_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by operation_catalog_scenarios. |
| `beam_emission_tests.gd` | Runs and passes, 11/0; registered. Evidence: 016-audit-beam_emission_tests.log. |
| `blackwater_courier_tests.gd` | Runs and passes, 35/0; registered. Evidence: 016-audit-blackwater_courier_tests.log. |
| `blackwater_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests, blackwater_tests. |
| `blackwater_tests.gd` | Runs and passes, 33/0; registered. Evidence: 016-audit-blackwater_tests.log. |
| `blackwater_ui_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by blackwater_ui_tests, runtime_tests, order_task_ui_scenarios. |
| `blackwater_ui_tests.gd` | Runs and passes, 10/0; registered. Evidence: 016-audit-blackwater_ui_tests.log. |
| `campaign_capture_progress_tests.gd` | Runs and passes, 11/0; registered. Evidence: 016-audit-campaign_capture_progress_tests.log. |
| `campaign_debrief_view_tests.gd` | Runs and passes, 7/0; registered. Evidence: 016-final-campaign_debrief_view_tests.log. |
| `campaign_endings_tests.gd` | Runs and passes, 48/0; registered. Evidence: 016-audit-campaign_endings_tests.log. |
| `campaign_instruments_tests.gd` | Runs and passes, 31/0; registered. Evidence: 016-fixed-campaign_instruments_tests.log. |
| `campaign_main_dispatch_tests.gd` | Runs and passes, 13/0; registered. Evidence: 016-latest-campaign_main_dispatch_tests.log. |
| `campaign_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by capture_campaign, challenges_journey_tests, capture_observed_contact_lock, campaign_ui_scenarios, run_tests, expanded_region_journeys, capture_siren_roles, navigation_departure_tests. |
| `campaign_ui_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests. |
| `capture_acoustic.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_acoustic_context.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_audio.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_audio_loops.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_blackwater.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_blackwater_motion.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_campaign.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_density.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_density_interaction.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_feedback_tests.gd` | Runs and passes, 6/0; registered. Evidence: 016-audit-capture_feedback_tests.log. |
| `capture_finale.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_foundry.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_observed_contact_lock.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_photo.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_return.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_siren_roles.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_touch.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `capture_touch_movie.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `challenges_journey_tests.gd` | Runs and passes, 9/0; registered. Evidence: 016-audit-challenges_journey_tests.log. |
| `challenges_tests.gd` | Runs and passes, 178/0; registered. Evidence: 016-audit-challenges_tests.log. |
| `challenges_ui_tests.gd` | Runs and passes, 86/0; registered. Evidence: 016-audit-challenges_ui_tests.log. |
| `concealed_fixture.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by witness_evacuation_tests, resolution_hook_tests, witness_evacuation_ui_tests, campaign_endings_tests. |
| `confluence_command_plan.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by confluence_parallel_tests, confluence_completion_tests. |
| `confluence_completion_tests.gd` | Runs and passes, 4/0; registered. Evidence: 016-audit-confluence_completion_tests.log. |
| `confluence_operation_tests.gd` | Runs and passes, 27/0; registered. Evidence: 016-audit-confluence_operation_tests.log. |
| `confluence_parallel_tests.gd` | Runs and passes, 4/0; registered. Evidence: 016-journey-confluence_parallel_tests.log. |
| `confluence_presentation_tests.gd` | Runs and passes, 15/0; registered. Evidence: 016-audit-confluence_presentation_tests.log. |
| `confluence_resolution_ui_tests.gd` | Runs and passes, 12/0; registered. Evidence: 016-audit-confluence_resolution_ui_tests.log. |
| `core_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `craft_upgrade_sim_tests.gd` | Runs and passes, 10/0; registered. Evidence: 016-audit-craft_upgrade_sim_tests.log. |
| `craft_upgrades_tests.gd` | Runs and passes, 11/0; registered. Evidence: 016-audit-craft_upgrades_tests.log. |
| `current_chart_seam_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-current_chart_seam_tests.log. |
| `current_propulsion_tests.gd` | Runs and passes, 4/0; registered. Evidence: 016-audit-current_propulsion_tests.log. |
| `decoy_aim_ui_tests.gd` | Runs and passes, 17/0; registered. Evidence: 016-audit-decoy_aim_ui_tests.log. |
| `decoy_deployment_tests.gd` | Runs and passes, 14/0; registered. Evidence: 016-audit-decoy_deployment_tests.log. |
| `density_main.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `density_menu_scenarios.gd` | Runs and passes, 7/0; registered. Evidence: 016-audit-density_menu_scenarios.log. |
| `density_scenarios.gd` | Runs and passes, 850/0; registered. Evidence: 016-corrected-density_scenarios.log. |
| `density_scroll_scenarios.gd` | Runs and passes, 15/0; registered. Evidence: 016-rerun-density_scroll_scenarios.log. |
| `depth_repair_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by depth_sonar_scenarios. |
| `depth_sonar_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by depth_sonar_tests, runtime_tests, run_tests, sonar_zero_bearing_tests. |
| `divergence_save_tests.gd` | Runs and passes, 12/0; registered. Evidence: 016-audit-divergence_save_tests.log. |
| `divergence_tests.gd` | Runs and passes, 14/0; registered. Evidence: 016-audit-divergence_tests.log. |
| `drone_drive_tests.gd` | Runs and passes, 23/0; registered. Evidence: 016-audit-drone_drive_tests.log. |
| `drone_drive_ui_tests.gd` | Runs and passes, 38/0; registered. Evidence: 016-audit-drone_drive_ui_tests.log. |
| `drone_operations_tests.gd` | Runs and passes, 29/0; registered. Evidence: 016-diagnostic-drone_operations_tests.log. |
| `drone_operations_ui_tests.gd` | Runs and passes, 20/0; registered. Evidence: 016-audit-drone_operations_ui_tests.log. |
| `earned_equipment_tests.gd` | Runs and passes, 12/0; registered. Evidence: 016-audit-earned_equipment_tests.log. |
| `expanded_region_journeys.gd` | Runs and passes, 4/0; registered. Evidence: 016-journey-expanded_region_journeys.log. |
| `expanded_region_tests.gd` | Runs and passes, 22/0; registered. Evidence: 016-audit-expanded_region_tests.log. |
| `expedition_instruments_ui_tests.gd` | Runs and passes, 47/0; registered. Evidence: 016-audit-expedition_instruments_ui_tests.log. |
| `expedition_menu_tests.gd` | Runs and passes, 11/0; registered. Evidence: 016-audit-expedition_menu_tests.log. |
| `extraction_survival_tests.gd` | Runs and passes, 69/0; registered. Evidence: 016-repair-extraction_survival_tests.log. |
| `field_sampler_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-field_sampler_tests.log. |
| `finale_command_plan.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by campaign_scenarios, blackwater_scenarios, capture_finale, campaign_ui_scenarios, finale_ui_scenarios. |
| `finale_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `finale_ui_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests, order_task_ui_scenarios. |
| `fit_label_main.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `fit_label_scenarios.gd` | Runs and passes, 60/0; registered. Evidence: 016-diagnostic-fit_label_scenarios.log. |
| `foundry_command_plan.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by capture_touch_movie, probe_foundry, capture_touch, foundry_scenarios, capture_foundry. |
| `foundry_departure_tests.gd` | Runs and passes, 25/0; registered. Evidence: 016-audit-foundry_departure_tests.log. |
| `foundry_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `frontend_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `frontend_stub_host.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `independent_capture_tests.gd` | Runs and passes, 22/0; registered. Evidence: 016-audit-independent_capture_tests.log. |
| `independent_capture_ui_tests.gd` | Runs and passes, 36/0; registered. Evidence: 016-repair-independent_capture_ui_tests.log. |
| `interface_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests. |
| `knockdown_scenarios.gd` | Runs and passes, 59/0; registered. Evidence: 016-corrected-knockdown_scenarios.log. |
| `knockdown_ui_scenarios.gd` | Runs and passes, 30/0; registered. Evidence: 016-rerun-knockdown_ui_scenarios.log. |
| `known_water_observation_tests.gd` | Runs and passes, 7/0; registered. Evidence: 016-audit-known_water_observation_tests.log. |
| `listening_well_command_plan.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by campaign_scenarios, campaign_ui_scenarios. |
| `loadout_ui_tests.gd` | Runs and passes, 38/0; registered. Evidence: 016-corrected-loadout_ui_tests.log. |
| `lock_warning_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `lock_warning_tests.gd` | Runs and passes, 27/0; registered. Evidence: 016-audit-lock_warning_tests.log. |
| `lock_warning_ui_tests.gd` | Runs and passes, 14/0; registered. Evidence: 016-audit-lock_warning_ui_tests.log. |
| `metrics_transport_tests.gd` | Runs and passes, 77/0; registered. Evidence: 016-repair-metrics_transport_tests.log. |
| `navigation_departure_tests.gd` | Runs and passes, 45/0; registered. Evidence: 016-journey-navigation_departure_tests.log. |
| `observed_contact_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by acoustic_path_affected_tests, run_tests. |
| `observed_contact_ui_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests. |
| `opening_depth_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by opening_depth_tests, runtime_tests, run_tests. |
| `operation_catalog_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by operation_catalog_tests, runtime_tests, run_tests. |
| `operation_emission_feedback_tests.gd` | Runs and passes, 26/0; registered. Evidence: 016-audit-operation_emission_feedback_tests.log. |
| `operation_endurance_tests.gd` | Runs and passes, 10/0; registered. Evidence: 016-audit-operation_endurance_tests.log. |
| `order_row_main.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `order_row_scenarios.gd` | Runs and passes, 250/0; registered. Evidence: 016-repair-order_row_scenarios.log. |
| `order_task_ui_scenarios.gd` | Runs and passes, 14/0; registered. Evidence: 016-audit-order_task_ui_scenarios.log. |
| `patient_play.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by opening_depth_policy_ui_tests, opening_depth_journeys. |
| `patrol_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `performance_measurements.gd` | Runs and passes, 2/0; registered. Evidence: 016-audit-performance_measurements.log. |
| `persistence_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `planner_chart_render_tests.gd` | Runs and passes5/0 with Compatibility software GL under Xvfb; registered with render backend. Evidence016-registry-planner-render.log. |
| `planner_metrics_tests.gd` | Runs and passes, 38/0; registered. Evidence: 016-audit-planner_metrics_tests.log. |
| `planner_navigation_ui_tests.gd` | Runs and passes, 34/0; registered. Evidence: 016-audit-planner_navigation_ui_tests.log. |
| `planner_space_ui_tests.gd` | Runs and passes, 54/0; registered. Evidence: 016-audit-planner_space_ui_tests.log. |
| `playfield_hud_tests.gd` | Runs and passes, 94/0; registered. Evidence: 016-follow-complete.log. |
| `polygon_bound_tests.gd` | Runs and passes, 10/0; registered. Evidence: 016-audit-polygon_bound_tests.log. |
| `post_tutorial_roster_tests.gd` | Runs and passes, 59/0; registered. Evidence: 016-audit-post_tutorial_roster_tests.log. |
| `probe_foundry.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `probe_native_roles.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |
| `radial_hud_tests.gd` | Runs and passes, 58/0; registered. Evidence: 016-audit-radial_hud_tests.log. |
| `received_audio_retry_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-received_audio_retry_tests.log. |
| `recon_consequences_tests.gd` | Runs and passes, 15/0; registered. Evidence: 016-audit-recon_consequences_tests.log. |
| `recon_grade_main_tests.gd` | Runs and passes, 6/0; registered. Evidence: 016-audit-recon_grade_main_tests.log. |
| `resolution_content_tests.gd` | Runs and passes, 44/0; registered. Evidence: 016-audit-resolution_content_tests.log. |
| `resolution_controls_ui_tests.gd` | Runs and passes, 32/0; registered. Evidence: 016-audit-resolution_controls_ui_tests.log. |
| `resolution_geometry_tests.gd` | Runs and passes, 23/0; registered. Evidence: 016-audit-resolution_geometry_tests.log. |
| `resolution_hook_tests.gd` | Runs and passes, 19/0; registered. Evidence: 016-audit-resolution_hook_tests.log. |
| `resolution_instruments_tests.gd` | Runs and passes, 9/0; registered. Evidence: 016-audit-resolution_instruments_tests.log. |
| `resolution_operations_tests.gd` | Runs and passes, 18/0; registered. Evidence: 016-audit-resolution_operations_tests.log. |
| `resume_metrics_main.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `route_program_tests.gd` | Runs and passes 35/0 after NAV1 fixture integration; registered. Evidence: 016-nav-route_program_tests.log. |
| `route_program_ui_tests.gd` | Runs and passes, 44/0; registered. Evidence: 016-audit-route_program_ui_tests.log. |
| `save_feedback_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests. |
| `siren_role_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by acoustic_path_affected_tests, run_tests. |
| `split_channel_command_plan.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by capture_return, expanded_region_journeys, split_channel_scenarios. |
| `split_channel_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `sweeper_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by sweeper_tests, runtime_tests, run_tests. |
| `t_pressure_probes.gd` | Host/scene fixture subclass, not a standalone suite; preserved and exercised by its owning registered harness. |
| `tactics_composition_tests.gd` | Runs and passes, 17/0; registered. Evidence: 016-corrected-tactics_composition_tests.log. |
| `targeting_feedback_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-targeting_feedback_tests.log. |
| `terminal_tick_tests.gd` | Runs and passes, 73/0; registered. Evidence: 016-corrected-terminal_tick_tests.log. |
| `thermal_lee_tests.gd` | Runs and passes, 22/0; registered. Evidence: 016-audit-thermal_lee_tests.log. |
| `thermal_transmission_tests.gd` | Runs and passes, 12/0; registered. Evidence: 016-audit-thermal_transmission_tests.log. |
| `thermal_ui_tests.gd` | Runs and passes, 8/0; registered. Evidence: 016-audit-thermal_ui_tests.log. |
| `torpedo_aim_ui_tests.gd` | Runs and passes, 65/0; registered. Evidence: 016-audit-torpedo_aim_ui_tests.log. |
| `touch_navigation_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by runtime_tests. |
| `v7_earned_region_tests.gd` | Runs and passes, 10/0; registered. Evidence: 016-audit-v7_earned_region_tests.log. |
| `v7_earned_view_tests.gd` | Runs and passes, 4/0; registered. Evidence: 016-audit-v7_earned_view_tests.log. |
| `v7_terrain_chart_tests.gd` | Runs and passes, 14/0; registered. Evidence: 016-audit-v7_terrain_chart_tests.log. |
| `view_controls_menu_tests.gd` | Runs and passes, 32/0; registered. Evidence: 016-audit-view_controls_menu_tests.log. |
| `waypoint_scenarios.gd` | Reusable fixture/controller, not a standalone harness. Preserved; referenced by run_tests. |
| `well_camera_feed_render_tests.gd` | Stale animated/current-vs-legacy fixture repaired, all old checks retained plus current PHOTO1 checks. Runs and passes14/0 under Xvfb; registered with render backend. Evidence016-registry-well-render.log. |
| `well_signature_save_shape_tests.gd` | Runs and passes, 9/0; registered. Evidence: 016-audit-well_signature_save_shape_tests.log. |
| `x2_pressure_probes.gd` | Capture/diagnostic tool without a CHECKS harness; preserved, not a headless pass/fail suite. |

### NAV1 files added after the original inventory

| File under game/tests | Classification and evidence |
| --- | --- |
| `nav_clearance_measure.gd` | Reusable RefCounted geometry helper used by the registered clearance harness and probes; not standalone. |
| `nav_clearance_tests.gd` | Runs and passes7/0; registered. Evidence016-nav-nav_clearance_tests.log. |
| `nav_following_probe.gd` | Runs and passes84/0; registered. Evidence016-nav-nav_following_probe.log. |
| `nav_clearance_probe.gd` | Short default runs and passes24/0; registered. Evidence016-nav-nav_clearance_probe.log. |
| `nav_clearance_ui_tests.gd` | Runs and passes17/0 with actual injected touch and Android Back notification; registered. Evidence016-nav-nav_clearance_ui_tests.log. |
