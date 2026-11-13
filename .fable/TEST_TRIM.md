# Test suite trim: proposed keep and retire list

Status: PROPOSED, 2026-11-12. Nothing has been moved. Pat approves or changes this list first. Retired suites move to `_scrap-20261111/tests-retired/`; nothing is deleted, and any suite can be put back by moving its file and its line in `game/tests/suites.txt`.

## Why

- There are 394 registered suites. One full pass costs about 123 minutes of machine time on GitHub, before set-up. Pat's GitHub Actions allowance for the month is spent (12 November 2026), so testing is local.
- On 12 November one changed default broke 137 suites. Sorting them out found one real defect. The defect that would have cost the player (Career charging for a drone never launched) was caught by no suite.
- Many suites pin one past fix, one mission route or one screen size, and nothing was ever retired.

## The proposal: three groups

| Group | Suites | Machine time | When it runs |
|---|---|---|---|
| Everyday set | 39 | about 20 minutes | Locally before any merge of size |
| Module guards | 99 | about 28 minutes in total, but only the few that match run | Only when the source file they guard is changed (the existing suite selector picks them) |
| Retired | 252 | about 71 minutes saved per full pass | Not run; kept in the scrap folder |
| Measurement tools | 4 | not gates | Run by hand when measuring |

How the list was made: the everyday set was chosen by hand (rules, saves, each side mode, one journey per mission arc, the dive screen and menus). The module guards were chosen by a script: after the everyday set, it kept the cheapest suites until every source file that any suite names is still named by a kept suite (271 files before, 271 after). Everything else is retired. This is a count of what each suite loads, not proof of what it checks: a retired suite may hold a check no kept suite repeats. That is the risk being accepted.

## Everyday set (39)

- **Rules and registries:** `run_tests`, `protected_rules_tests`, `names_registry_tests`, `parity_rules_tests`, `drone_bay_tests`, `control_mix_tests`, `crash_possible_tests`, `legacy_observe_equivalence_tests`, `chart_cache_tests`, `combat_rules_tests`
- **Saves and resume:** `save_profiles_tests`, `save_profiles_transfer_tests`, `mode_resume_tests`, `drone_drive_tests`, `campaign_equipment_save_tests`
- **Side modes:** `career_tests`, `expedition_runs_tests`, `expedition_session_tests`, `run_records_tests`, `challenges_tests`, `challenges_ui_tests`, `rider_tests`
- **Whole-campaign play:** `hand_pilot_journeys`, `runtime_tests`, `opening_depth_journeys`, `glass_reach_journeys`, `iron_choir_journeys`, `calder_trench_journey_tests`, `final_pair_journey_tests`
- **Dive screen and controls:** `playfield_hud_tests`, `radial_hud_tests`, `planning_order_flow_ui_tests`, `release_controls_tests`, `truthful_commands_tests`, `tactical_aids_tests`, `debug_console_tests`, `menu_reach_ui_tests`, `loadout_ui_tests`, `player_names_tests`

Three of these need a screen (`tactical_aids_tests`, `debug_console_tests`, `menu_reach_ui_tests`); they have run correctly on this PC without one.

## Module guards (99)

| Suite | Seconds | Kept because it is the cheapest suite that loads |
|---|---|---|
| `order_table_tests` | 1 | simulation/orders/feature_orders, simulation/orders/order_table, simulation/orders/photo_orders |
| `operation_meta_parity_tests` | 1 | audio/region_audio_table, campaign/endurance_budgets, campaign/operation_meta |
| `photo_pricing_tests` | 1 | campaign/onboarding_text, presentation/photo_pricing/photo_pricing_hints, simulation/photo_pricing/photo_pricing |
| `photo_rules_tests` | 2 | photo_depth/band_photo, photo_rules/known_lane, photo_rules/loop_clock |
| `presentation_pass_tests` | 2 | audio/photo_audio/photo_wave, audio/siren_role_cues, presentation/art/art_table |
| `thermal_band_tests` | 1 | simulation/acoustic_network, simulation/drone_operations, simulation/shelf_habitat |
| `fix2_state_tests` | 1 | presentation/loss_summary, simulation/observed_stun, simulation/photo_context |
| `work_sites_tests` | 1 | campaign/encounters/final_marks, campaign/encounters/final_survey, campaign/encounters/work_sites |
| `settings_depth_tests` | 1 | input/map_gesture, presentation/accessibility/cue_observer, presentation/frontend/settings_depth |
| `ledger_tests` | 1 | campaign/ledger/ledger, campaign/ledger/ledger_table, presentation/ledger/ledger_view |
| `economy_campaign_sim_tests` | 1 | campaign/economy_table, campaign/fleet_inventory, campaign/glass_research |
| `confluence_presentation_tests` | 1 | presentation/confluence_resolution, presentation/confluence_world |
| `campaign_instruments_tests` | 1 | presentation/equipment_context, presentation/receiver_scene |
| `thermal_transmission_tests` | 1 | simulation/acoustic_paths, simulation/thermal_front |
| `early_reward_tests` | 1 | campaign/early_reward/early_reward, campaign/early_reward/reward_table |
| `sonar_identity_tests` | 1 | presentation/first_siren_cue/notice_tracker, simulation/contact_identity |
| `hunt_pressure_tests` | 1 | simulation/hunt_pressure/hunt_pressure, simulation/recon_consequences |
| `crew_tests` | 2 | campaign/crew/crew, campaign/crew/crew_table, campaign/voices/voices_table |
| `field_tools_tests` | 1 | equipment/craft_upgrades, simulation/field_tool_effects |
| `all_stop_text_tests` | 1 | simulation/all_stop/all_stop, simulation/all_stop/all_stop_table |
| `text_spacing_tests` | 1 | equipment/chassis, equipment/hulls |
| `finale_provisional_tests` | 2 | campaign/endings_photo, presentation/finale/finale, presentation/finale/finale_table |
| `photo_pay_ui_tests` | 3 | campaign/photo_intel, presentation/archive/archive_view, presentation/photo_pay/pay_table |
| `current_motion_tests` | 1 | simulation/current_field |
| `resolution_content_tests` | 1 | campaign/resolution_missions |
| `resolution_instruments_tests` | 1 | presentation/operation_instruments |
| `acoustic_footprint_tests` | 1 | presentation/acoustic_feedback |
| `photo_depth_tests` | 2 | photo_depth/band_hint, photo_depth/band_table |
| `archive_recap_tests` | 1 | campaign/archive_recap |
| `photo_trench_geometry_tests` (screen) | 1 | presentation/photo_subjects |
| `grade_on_secure_tests` | 1 | photo_grade/grade_on_secure |
| `photo_audio_tests` | 1 | audio/photo_audio/photo_cue_table |
| `event_cue_tests` | 2 | audio/event_cues/event_cue_table, presentation/accessibility/cue_table |
| `onboard2_tests` | 2 | campaign/onboarding2/briefing_rows, presentation/tool_help/tool_help |
| `goal_bearing_cache_tests` | 1 | presentation/goal_bearing/goal_bearing |
| `art_tests` | 1 | presentation/art/art_tests |
| `first_siren_cue_ext_tests` | 2 | presentation/first_siren_cue/cue_archive, presentation/first_siren_cue/cue_table |
| `status_text_tests` | 2 | presentation/status_text/status_table, presentation/status_text/status_text |
| `economy_tests` | 2 | presentation/economy_panel, presentation/flow/campaign_flow |
| `threat_read_tests` | 2 | presentation/threat_read/threat_read, presentation/threat_read/threat_read_table |
| `turn_safe_navigation_tests` | 3 | simulation/polygon_containment, simulation/route_program |
| `voices_tests` | 3 | campaign/sorley_rescue, campaign/voices/voices |
| `save2_fork_tests` | 3 | persistence/save_states/save2_table, persistence/save_states/save2_transaction |
| `death_cause_tests` | 3 | presentation/death_cause/cause_log, presentation/death_cause/cause_table |
| `operation_endurance_tests` | 2 | simulation/operation_endurance |
| `v7_earned_view_tests` | 2 | presentation/route_program_preview |
| `audit_photo_evidence_tests` | 4 | presentation/photo_scene, presentation/photo_view |
| `a11y_cues_tests` | 2 | presentation/accessibility/cue_tests |
| `craft_upgrade_sim_tests` | 3 | simulation/world_region |
| `campaign_debrief_view_tests` | 3 | presentation/expedition_operations |
| `landmark_ui_tests` (screen) | 6 | presentation/landmarks/landmark_data, presentation/landmarks/landmark_view |
| `hunt_pressure_integration_tests` | 6 | diagnostics/ai_trace, diagnostics/ai_trace_table |
| `photo_range_caption_tests` | 3 | presentation/photo_shutter/range_caption |
| `photo_shutter_ui_tests` | 11 | campaign/photo_ops, presentation/photo_shutter/shutter, presentation/photo_shutter/shutter_table |
| `concealed_harbour_tests` | 4 | simulation/concealed_harbour |
| `quality_tests` | 4 | presentation/quality/quality_tests |
| `seeded_siren_patrol_tests` | 4 | campaign/runs/seeded_siren_patrol |
| `ironman_losses_tests` | 10 | campaign/ironman_losses, presentation/module_recovery_view |
| `optional_cache_tests` | 11 | presentation/optional_cache_view, simulation/optional_cache |
| `back_exit_tests` | 6 | presentation/back_exit/back_exit_confirm |
| `nav_clearance_ui_tests` | 7 | presentation/route_clearance/hull_band |
| `metrics_transport_tests` | 8 | diagnostics/metrics_transport |
| `economy_options_tests` | 8 | campaign/economy_options |
| `iron_layouts_tests` | 0 | campaign/encounters/iron_layouts, campaign/encounters/roster |
| `module_recovery_ui_tests` | 11 | presentation/fleet_instruments |
| `rendezvous_transport_tests` | 13 | simulation/rendezvous_transport |
| `warning_recipient_tests` | 13 | presentation/warning_recipient_view |
| `blackwater_delivery_ui_tests` | 13 | presentation/blackwater_delivery_view |
| `fit_surface_ui_tests` | 26 | presentation/fit_surface/fit_surface, presentation/fit_surface/fit_surface_table |
| `briefing_truth_tests` | 13 | campaign/shelf_signal_operation |
| `wake_crossing_ui_tests` | 15 | presentation/wake_crossing_view |
| `arc_boundary_ui_tests` (screen) | 48 | campaign/arcs/arc_recap, campaign/arcs/arc_table, presentation/arcs/arc_card |
| `tool_racks_tests` (screen) | 19 | presentation/tool_racks_view |
| `cadence_correlator_tests` | 0 | equipment/cadence_correlator |
| `field_sampler_tests` | 0 | equipment/field_sampler |
| `consequence_lines_tests` | 0 | presentation/consequence_lines |
| `terrain_tests` | 0 | campaign/encounters/terrain |
| `choir_rules_tests` | 0 | campaign/encounters/choir_rules |
| `photo_window_rules_tests` | 0 | photo_rules/photo_rules |
| `ops_home_ui_tests` (screen) | 0 | presentation/ops_home/ops_home_table |
| `stable_board_ui_tests` (screen) | 0 | presentation/industrial_view |
| `optional_thread_journey_tests` | 0 | campaign/encounters/optional_layouts |
| `archive_views_ui_tests` (screen) | 95 | persistence/save_checks, presentation/archive/archive_table, presentation/archive/voice_feed |
| `rendezvous_ui_tests` | 24 | presentation/rendezvous_view |
| `torpedo_aim_ui_tests` | 24 | presentation/torpedo_aim |
| `onboarding_tests` | 24 | presentation/research/research_view |
| `life_support_ui_tests` | 24 | presentation/life_support_chip |
| `quality_ui_tests` (screen) | 53 | presentation/quality/quality_governor, presentation/quality/quality_runtime |
| `fleet_ring_ui_tests` | 28 | presentation/fleet_ring |
| `industrial_jobs_tests` | 32 | simulation/industrial_jobs |
| `sweeper_patrol_tests` | 33 | campaign/sweeper_patrols |
| `concealed_harbour_ui_tests` | 36 | presentation/concealed_harbour_view |
| `carry_tests` | 82 | campaign/carry/carry, campaign/carry/carry_table |
| `audit_navigation_tests` (screen) | 109 | presentation/current_branch, presentation/launch_summary |
| `launch_clearance_tests` | 63 | simulation/module_recovery |
| `audit_readability_ui_tests` (screen) | 131 | presentation/hunt_meter, presentation/public_copy |
| `hunt_meter_ui_tests` (screen) | 135 | presentation/hunt_meter/meter_table |
| `save_profiles_ui_tests` (screen) | 212 | persistence/profiles/profile_ui_tests |
| `save2_ui_tests` (screen) | 224 | persistence/save_states/save2_ui |

## Retired (252), by family

| Family | Count | Seconds | Suites |
|---|---|---|---|
| photo | 20 | 148 | `photo_capture_tests`, `photo_capture_ui_tests`, `photo_discovery_tests`, `photo_pricing_ui_tests`, `photo_row_bell_name_journey_tests`, `photo_row_boat_keel_journey_tests`, `photo_row_buoy_blind_journey_tests`, `photo_row_bus_cable_journey_tests`, `photo_row_feed_room_journey_tests`, `photo_row_keel_mark_journey_tests`, `photo_row_locker_latch_journey_tests`, `photo_row_relay_blink_journey_tests`, `photo_row_shutter_order_journey_tests`, `photo_row_slide_mark_journey_tests`, `photo_row_spindle_wear_journey_tests`, `photo_row_structure_edge_journey_tests`, `photo_row_tender_door_journey_tests`, `photo_row_vane_crack_journey_tests`, `photo_rules_ui_tests`, `photo_study_save_tests` |
| fix2 | 9 | 168 | `fix2_camera_ui_tests`, `fix2_feedback_ui_tests`, `fix2_frontend_ui_tests`, `fix2_menu_ui_tests`, `fix2_optional_recovery_tests`, `fix2_photo_routing_tests`, `fix2_save_tests`, `fix2_save_ui_tests`, `fix2_study_ui_tests` |
| glass | 7 | 367 | `glass_earned_chart_tests`, `glass_fleet_pairs_tests`, `glass_network_tests`, `glass_reach_tests`, `glass_reach_ui_tests`, `glass_research_tests`, `glass_work_tests` |
| warning | 7 | 183 | `warning_chain_audio_tests`, `warning_chain_journey_tests`, `warning_chain_tests`, `warning_chain_ui_tests`, `warning_chain_world_ui_tests`, `warning_recipient_journey_tests`, `warning_recipient_ui_tests` |
| campaign | 6 | 63 | `campaign_capture_progress_tests`, `campaign_consequence_tests`, `campaign_endings_tests`, `campaign_instruments_ui_tests`, `campaign_main_dispatch_tests`, `campaign_photo_rows_tests` |
| opening | 6 | 34 | `opening_depth_policy_cover_ui_tests`, `opening_depth_policy_inner_ui_tests`, `opening_depth_policy_ui_tests`, `opening_depth_tests`, `opening_depth_ui_tests`, `opening_fleet_tests` |
| route | 5 | 115 | `route_map_tests`, `route_map_ui_tests`, `route_program_tests`, `route_program_ui_tests`, `route_telemetry_touch_tests` |
| blackwater | 5 | 51 | `blackwater_courier_tests`, `blackwater_delivery_runtime_ui_tests`, `blackwater_delivery_tests`, `blackwater_tests`, `blackwater_ui_tests` |
| acoustic | 5 | 16 | `acoustic_hearing_tests`, `acoustic_path_affected_tests`, `acoustic_path_cull_tests`, `acoustic_path_tests`, `acoustic_path_ui_tests` |
| challenges | 5 | 72 | `challenges_completions_iron_tests`, `challenges_completions_opening_tests`, `challenges_completions_reach_tests`, `challenges_journey_tests`, `challenges_route_pars_tests` |
| audit | 5 | 192 | `audit_artifact_cargo_tests`, `audit_findings_provenance_tests`, `audit_optics_touch_tests`, `audit_photo_integrity_tests`, `audit_photo_ui_tests` |
| depth | 4 | 188 | `depth_policy_journeys`, `depth_policy_ui_tests`, `depth_sonar_tests`, `depth_sonar_ui_tests` |
| confluence | 4 | 55 | `confluence_completion_tests`, `confluence_operation_tests`, `confluence_parallel_tests`, `confluence_resolution_ui_tests` |
| resolution | 4 | 39 | `resolution_controls_ui_tests`, `resolution_geometry_tests`, `resolution_hook_tests`, `resolution_operations_tests` |
| planner | 4 | 43 | `planner_chart_render_tests`, `planner_metrics_tests`, `planner_navigation_ui_tests`, `planner_space_ui_tests` |
| ops | 4 | 20 | `ops_home_cover_ui_tests`, `ops_home_desktop_ui_tests`, `ops_home_inner_ui_tests`, `ops_title_control_tests` |
| status | 4 | 0 | `status_text_cover_ui_tests`, `status_text_inner_ui_tests`, `status_text_table_ui_tests`, `status_text_ui_tests` |
| density | 3 | 49 | `density_menu_scenarios`, `density_scenarios`, `density_scroll_scenarios` |
| iron | 3 | 22 | `iron_choir_tests`, `iron_choir_ui_tests`, `iron_research_tests` |
| shelf | 3 | 28 | `shelf_habitat_journey_tests`, `shelf_habitat_tests`, `shelf_habitat_ui_tests` |
| module | 3 | 26 | `module_inventory_main_tests`, `module_recovery_runtime_ui_tests`, `module_recovery_tests` |
| drone | 3 | 28 | `drone_drive_ui_tests`, `drone_operations_tests`, `drone_operations_ui_tests` |
| witness | 3 | 111 | `witness_evacuation_journey_tests`, `witness_evacuation_tests`, `witness_evacuation_ui_tests` |
| thermal | 3 | 33 | `thermal_lee_tests`, `thermal_operation_tests`, `thermal_ui_tests` |
| first | 3 | 73 | `first_siren_cue_ext_ui_tests`, `first_siren_cue_tests`, `first_siren_cue_ui_tests` |
| early | 3 | 82 | `early_reward2_tests`, `early_reward2_ui_tests`, `early_reward_ui_tests` |
| stable | 3 | 0 | `stable_board_cover_mirror_ui_tests`, `stable_board_inner_mirror_ui_tests`, `stable_board_inner_normal_ui_tests` |
| well | 2 | 7 | `well_camera_feed_render_tests`, `well_signature_save_shape_tests` |
| recon | 2 | 7 | `recon_consequences_tests`, `recon_grade_main_tests` |
| current | 2 | 3 | `current_chart_seam_tests`, `current_propulsion_tests` |
| v7 | 2 | 2 | `v7_earned_region_tests`, `v7_terrain_chart_tests` |
| divergence | 2 | 4 | `divergence_save_tests`, `divergence_tests` |
| expedition | 2 | 15 | `expedition_instruments_ui_tests`, `expedition_menu_tests` |
| operation | 2 | 15 | `operation_catalog_tests`, `operation_emission_feedback_tests` |
| wake | 2 | 15 | `wake_crossing_journey_tests`, `wake_crossing_tests` |
| earned | 2 | 4 | `earned_course_continuity_tests`, `earned_equipment_tests` |
| independent | 2 | 22 | `independent_capture_tests`, `independent_capture_ui_tests` |
| expanded | 2 | 7 | `expanded_region_journeys`, `expanded_region_tests` |
| contact | 2 | 12 | `contact_reports_tests`, `contact_reports_ui_tests` |
| siren | 2 | 11 | `siren_radio_tests`, `siren_warning_pause_tests` |
| recovery | 2 | 66 | `recovery_manifest_ui_tests`, `recovery_route_ui_tests` |
| decoy | 2 | 8 | `decoy_aim_ui_tests`, `decoy_deployment_tests` |
| knockdown | 2 | 34 | `knockdown_scenarios`, `knockdown_ui_scenarios` |
| sonar | 2 | 12 | `sonar_feedback_cache_tests`, `sonar_zero_bearing_tests` |
| rules | 2 | 19 | `rules_sonar_cost_tests`, `rules_witness_menu_tests` |
| all | 2 | 14 | `all_stop_tests`, `all_stop_ui_tests` |
| lock | 2 | 9 | `lock_warning_tests`, `lock_warning_ui_tests` |
| order | 2 | 58 | `order_row_scenarios`, `order_task_ui_scenarios` |
| cold | 2 | 97 | `cold_review_archive_tests`, `cold_review_ui_tests` |
| endings | 2 | 21 | `endings_photo_tests`, `endings_photo_ui_tests` |
| settings | 2 | 73 | `settings_depth_ui_tests`, `settings_lifecycle_ui_tests` |
| calder | 2 | 97 | `calder_fleet_journey_tests`, `calder_silent_journey_tests` |
| sorley | 2 | 3 | `sorley_pilotage_tests`, `sorley_rescue_tests` |
| runs | 2 | 139 | `runs_offer_tests`, `runs_offer_ui_tests` |
| dive | 2 | 36 | `dive_end_polish_ui_tests`, `dive_end_stats_ui_tests` |
| navigation | 1 | 5 | `navigation_departure_tests` |
| targeting | 1 | 6 | `targeting_feedback_tests` |
| beam | 1 | 1 | `beam_emission_tests` |
| craft | 1 | 1 | `craft_upgrades_tests` |
| late | 1 | 5 | `late_ending_tests` |
| post | 1 | 6 | `post_tutorial_roster_tests` |
| polygon | 1 | 1 | `polygon_bound_tests` |
| survivor | 1 | 3 | `survivor_ascent_tests` |
| sweeper | 1 | 3 | `sweeper_tests` |
| role | 1 | 3 | `role_senses_tests` |
| choir | 1 | 15 | `choir_fork_tests` |
| industrial | 1 | 6 | `industrial_threats_tests` |
| onward | 1 | 1 | `onward_mission_tests` |
| capture | 1 | 1 | `capture_feedback_tests` |
| radio | 1 | 42 | `radio_operation_tests` |
| concealed | 1 | 39 | `concealed_harbour_journey_tests` |
| fleet | 1 | 18 | `fleet_instruments_ui_tests` |
| view | 1 | 13 | `view_controls_menu_tests` |
| received | 1 | 1 | `received_audio_retry_tests` |
| foundry | 1 | 3 | `foundry_departure_tests` |
| terminal | 1 | 1 | `terminal_tick_tests` |
| extraction | 1 | 7 | `extraction_survival_tests` |
| tactics | 1 | 8 | `tactics_composition_tests` |
| briefing | 1 | 18 | `briefing_scroll_fitting_ui_tests` |
| collision | 1 | 1 | `collision_boundaries_tests` |
| t | 1 | 2 | `t_pressure_tuning_tests` |
| ordinary | 1 | 2 | `ordinary_beam_industrial_tests` |
| loadout | 1 | 11 | `loadout_frames_tests` |
| archive | 1 | 6 | `archive_recap_ui_tests` |
| fit | 1 | 15 | `fit_label_scenarios` |
| known | 1 | 1 | `known_water_observation_tests` |
| work | 1 | 25 | `work_task_recipient_tests` |
| nav | 1 | 1 | `nav_clearance_tests` |
| pr | 1 | 23 | `pr_audit_layout_tests` |
| landmark | 1 | 5 | `landmark_tests` |
| onboard2 | 1 | 318 | `onboard2_ui_tests` |
| consequence | 1 | 64 | `consequence_lines_ui_tests` |
| a11y | 1 | 72 | `a11y_cues_ui_tests` |
| ai | 1 | 7 | `ai_trace_tests` |
| roster | 1 | 0 | `roster_tests` |
| map | 1 | 1 | `map_gesture_tests` |
| finale | 1 | 193 | `finale_provisional_ui_tests` |
| authored | 1 | 1 | `authored_closure_tests` |
| save2 | 1 | 2 | `save2_storage_tests` |
| ironman | 1 | 2 | `ironman_integrity_tests` |
| death | 1 | 22 | `death_cause_ui_tests` |
| hunt | 1 | 0 | `hunt_cap_coverage_tests` |
| regional | 1 | 1 | `regional_settings_tests` |
| frame | 1 | 1 | `frame_cap_settings_tests` |
| optional | 1 | 0 | `optional_cache_journey_tests` |
| economy | 1 | 2 | `economy_save_tests` |
| mode | 1 | 0 | `mode_tool_cargo_tests` |
| rider | 1 | 54 | `rider_ui_tests` |
| prep | 1 | 10 | `prep_decision_first_ui_tests` |
| own | 1 | 1 | `own_craft_leg_warning_tests` |
| bare | 1 | 72 | `bare_contact_tests` |
| launch | 1 | 18 | `launch_guard_ui_tests` |
| release | 1 | 1 | `release_build_gate_tests` |
| never | 1 | 10 | `never_disabled_tests` |
| threat | 1 | 6 | `threat_read_ui_tests` |
| hud | 1 | 55 | `hud_chips_ui_tests` |
| debrief | 1 | 42 | `debrief_reach_ui_tests` |

## Measurement tools (4, kept, not gates)

`performance_measurements`, `nav_following_probe`, `nav_clearance_probe`, `art_render_measurements`
