# Independent non-author review: PASS for local exact-head scope

Reviewer: `/root/save043_architect`, independent non-author. HEAD `39d855151534dc81a277e34367341c8711e320cf`; tree `59584924554d285b33337ee8f38b7b88bd8002da`; base `0fb3873e4c0650560d57d19c89b106ae3803747c`. Head checked before, per process, and after. No source/docs/test edits, commits, staging, push or PR comments. Generated `.import`, `.gd.uid` and Python cache files remain unstaged.

Actual requested execution: 37 processes including import, 2895 checks, 0 failures, all exits 0 and no strict runtime/script/leak errors. Additional external refresh probe: 152 checks, 0 failures. Combined 3047 checks. Main serial elapsed sum 588.627s; targeted serial sum 72.624s (overlapped main); extra probe 19.494s.

No unresolved P1/P2 finding within reviewed scope. The original b7 hosted route-touch failure remains preserved and blocked for that head. Its unchanged route_telemetry_touch_tests now passes 46/0 at this exact head. New card placement reserves the full public own-craft touch/pick footprint; after moving off a craft it defers a HUD refresh to repair stale Fleet handle classification. Manual camera native captures and UI regression pass. External 150% same-host cover/inner/cover probe ran 48 refresh trials, bounded to at most 3 refresh calls each, with unchanged camera and dive snapshot and no card/own-craft footprint overlap. No camera mutation or hidden-enemy geometry was introduced.

The two preliminary timing/cause defects are resolved by observing once at the end of the completed simulation tick and deriving pending action cause for the read-only view; integration passes 66/0. Protected-rule source proof preserves hearing, movement, collision/damage/projectiles, visual pursuit, shared Recon.readiness, lock audio and threat formulas apart from authorized sight multipliers. Existing tests remain unchanged. Save opt-in/absence/revert/validation, photo price sight mirror, bounded read-only trace and audio dispatch/rate/pause/mute/suspend were reviewed.

Scope boundary: +6 acquisition edge reads ordinary craft lock/beam state. Interceptor/warden windups and listening buoy/relay systems remain unchanged; this is not an all-eight-role acquisition-edge claim. Eligible sight pressure is reversible; final operation caps 30/31 remain 1.0.

Opening ON/OFF: all five printed outcome/time/hull/oxygen/tool rows match exactly. Four print all three survivors alive; Split verifies survivors by assertion rather than printing them. Both runs pass 49 checks. All 14 unchanged photo journeys pass 632 checks.

Evidence: all-results.json contains exact command, isolated absolute userdata root, duration, exit, count and raw log path for every process. logs-manifest.json records raw log hashes. complete-summary.json, opening-comparison.json, protected-source-proof.json and source-final-proof.json retain independently checked facts. All logs and evidence reside under this folder.

Native captures: 21 PNGs with SHA256, byte sizes and dimensions in captures-manifest.json: 4 at 960x432, 10 at 2184x1968, 7 at 2520x1080. Visually inspected both Fold manual before/after pairs, compact basic/help/scrolled-help, advanced lock warning and inner-screen lockdown.

Additional checks: registry 280 suites with zero errors/warnings; guidance checker and its 10 regression tests pass; git diff --check passes. Native UI uses Godot 4.6.3 Compatibility, verified Windows binary, Dummy audio.

Limits: targeted local review only, no complete 280-suite matrix, APK, phone, headphone listening or blind/full-campaign acceptance. Existing unrelated 960x432 basic/radial HUD clipping remains baseline and is not claimed repaired. Native captures and assertions cover Hunt controls/help/Back/48dp and 150% text across three requested desktop shapes; they do not certify every possible UI composition. Hosted final gates are separate and must be checked by the parent before merge.

| Actual suite | Checks | Exit | Seconds |
|---|---:|---:|---:|
| import | 0 | 0 | 7.566 |
| run_tests | 836 | 0 | 136.115 |
| route_telemetry_touch_tests | 46 | 0 | 11.449 |
| hunt_pressure_tests | 88 | 0 | 0.521 |
| hunt_pressure_integration_tests | 66 | 0 | 9.373 |
| hunt_meter_ui_tests | 226 | 0 | 22.227 |
| hunt_meter_ui_native | 247 | 0 | 32.784 |
| recon_consequences_tests | 15 | 0 | 2.653 |
| acoustic_hearing_tests | 21 | 0 | 1.815 |
| sweeper_tests | 52 | 0 | 6.583 |
| sweeper_patrol_tests | 56 | 0 | 49.015 |
| photo_pricing_tests | 64 | 0 | 3.300 |
| photo_audio_tests | 47 | 0 | 2.741 |
| ai_trace_tests | 23 | 0 | 16.820 |
| opening_depth_journeys | 49 | 0 | 79.071 |
| opening_flag_off | 49 | 0 | 74.648 |
| photo_row_tender_door_journey_tests | 50 | 0 | 8.783 |
| photo_row_relay_blink_journey_tests | 57 | 0 | 11.453 |
| photo_row_structure_edge_journey_tests | 67 | 0 | 22.828 |
| photo_row_buoy_blind_journey_tests | 46 | 0 | 9.067 |
| photo_row_vane_crack_journey_tests | 37 | 0 | 7.008 |
| photo_row_keel_mark_journey_tests | 43 | 0 | 9.446 |
| photo_row_boat_keel_journey_tests | 38 | 0 | 8.996 |
| photo_row_locker_latch_journey_tests | 53 | 0 | 9.555 |
| photo_row_shutter_order_journey_tests | 33 | 0 | 4.585 |
| photo_row_bus_cable_journey_tests | 43 | 0 | 10.396 |
| photo_row_spindle_wear_journey_tests | 39 | 0 | 6.719 |
| photo_row_slide_mark_journey_tests | 41 | 0 | 7.798 |
| photo_row_bell_name_journey_tests | 45 | 0 | 8.494 |
| photo_row_feed_room_journey_tests | 40 | 0 | 6.818 |
| radial_hud_tests | 58 | 0 | 13.619 |
| playfield_hud_tests | 110 | 0 | 12.416 |
| fleet_instruments_ui_tests | 78 | 0 | 10.780 |
| expedition_instruments_ui_tests | 47 | 0 | 8.556 |
| campaign_instruments_ui_tests | 52 | 0 | 21.026 |
| lock_warning_ui_tests | 14 | 0 | 5.988 |
| map_gesture_tests | 19 | 0 | 0.239 |
| external_refresh_native | 152 | 0 | 19.494 |
