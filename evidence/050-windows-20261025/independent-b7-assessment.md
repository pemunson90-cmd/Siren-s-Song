BLOCK / HOLD. Independent non-author review by /root/save043_architect of PR147, exact HEAD b7addca49c997772d8704afbda33ff6485d42b40 against base 0fb3873e4c0650560d57d19c89b106ae3803747c. The requested local suites passed, but the hosted run has an outstanding UI blocker; this head is NOT accepted.

All 21 changed files were reviewed, including six guidance/design documents, optional state validation, all sight/action/tick seams, audio, trace, meter, tests and registration. The historical proposal is retained verbatim under its historical heading. Current authority is sight-only, reversible tuning; earlier hearing/shared-readiness/guard-stamp proposals are superseded.

The two preliminary P2 findings are resolved in this exact head: the single observer at simulation.gd:815 commits completed sight/photo changes before subsequent paused input can clear them, and hunt_pressure.gd:21-24 derives the correct pending public stage cause. Both real Sim.advance regressions execute in hunt_pressure_integration_tests, which independently passed66/0. Root's original66/2 reproduction remains in ../integration-edge-red-1.log and ../preliminary-review-findings.md; it was not overwritten or counted as reviewer acceptance.

Save/replay review: fresh starts initialize the optional field; restore does not initialize absent legacy state. Required revision/stage/seen and optional cause/cue_at/pending/stage_cause are validated through SaveChecks, independently of the feature switch. Legacy actions retain their original amounts; a disabled feature writes no new field and leaves stored owned metadata intact. No guard hunt_scale or new external save file is introduced. Current codec disk roundtrip, malformed fields and forward replay were actually exercised. This is not a claim of exhaustive corrupt-input fuzzing or a new save schema migration.

Protected-boundary proof: independent explicit-UTF8 comparison found _heard_arrival, _move, _hull_contacts, _advance_projectiles, _visual_pursuit, shared Recon.readiness and lock-audio bodies unchanged. _threats is identical after normalizing only the two authorized sight-factor replacements. The third sight use is contact_visible; the photo chart uses the same sight helper. There is no direct global hearing/speed bonus or change to four-second lock, beam, damage, hull, routes or reports. Earlier visual acquisition can naturally trigger an earlier normal response. Source evidence: protected-source-proof.json and source_audit.py.

Scope interpretation, explicitly accepted for this narrow review: +6 acquisition pressure reads actual ordinary craft lock/beam states. Separate interceptor/warden visual windups and listening buoy/relay systems remain unchanged; this review does not claim all-eight-role acquisition edges. Eligible sight roles are patroller/sentinel/hunter/sweeper (including legacy unspecified ordinary guards). Global and local terms combine by max, with only the global term capped; final-pair IDs30/31 retain1.00. This conservative boundary is not a blocker under the current sight-only scope.

Audio and trace: actual generated cue dispatch, three-second rate limit, mute, tactical pause and suspension assertions pass. Generation uses its existing local deterministic noise, not Simulation RNG. Public ambience offsets use the table, including the early cap. Attached AI trace remains bounded and read-only, with no new runtime attachment. Headless Dummy-audio checks establish lifecycle/state behavior, not headphone quality.

Evidence root (absolute): C:/Users/Archi/Documents/Codex/2026-10-24/you-are-codex-the-implementation-worker/050-evidence/independent-b7addc

run.ps1 actually executed the commands in results.json. Each Godot process used verified Windows Godot4.6.3, a full absolute project path, and its own fresh full absolute APPDATA/LOCALAPPDATA root. The shared common.ps1 helper was used; its launch-window option was changed in memory to hidden, with no helper/source edit. binary.json records SHA5126089297513044E32CB11D91CAEE4FCF4EE4A41D62EA26644BF583290D6AD809D739ED593B6C975EF3FCAAAA95AF5622822ADEF794E4AD894E6AD87563A8C44BC. Native rendering was gl_compatibility on NVIDIA RTX2080Ti; audio driver Dummy. Registry-selected fourteen row suites ran individually; no full local matrix.

Actual results:29 Godot processes including import,2,451 assertions, zero failures, all exit0, no script/runtime/resource-leak errors. Sum of measured process durations561.553 seconds. Each row below links by filename within the absolute evidence root; results.json contains full absolute command, log and userdata paths for every process. logs-manifest.json records raw-log bytes/SHA256; verified-summary.json was produced by a separate final reread of every log.

| Suite / corresponding .log | Checks | Failures | Exit | Seconds |
|---|---:|---:|---:|---:|
| import.log | import | 0 | 0 | 7.502 |
| run_tests.log | 836 | 0 | 0 | 136.426 |
| hunt_pressure_tests.log | 88 | 0 | 0 | 0.543 |
| hunt_pressure_integration_tests.log | 66 | 0 | 0 | 9.187 |
| hunt_meter_ui_tests.log | 218 | 0 | 0 | 16.765 |
| hunt_meter_ui_native.log | 235 | 0 | 0 | 23.815 |
| recon_consequences_tests.log | 15 | 0 | 0 | 2.649 |
| acoustic_hearing_tests.log | 21 | 0 | 0 | 1.811 |
| sweeper_tests.log | 52 | 0 | 0 | 6.589 |
| sweeper_patrol_tests.log | 56 | 0 | 0 | 49.02 |
| photo_pricing_tests.log | 64 | 0 | 0 | 3.217 |
| photo_audio_tests.log | 47 | 0 | 0 | 2.652 |
| ai_trace_tests.log | 23 | 0 | 0 | 16.65 |
| opening_depth_journeys.log | 49 | 0 | 0 | 77.293 |
| opening_flag_off.log | 49 | 0 | 0 | 74.549 |
| photo_row_tender_door_journey_tests.log | 50 | 0 | 0 | 8.684 |
| photo_row_relay_blink_journey_tests.log | 57 | 0 | 0 | 11.434 |
| photo_row_structure_edge_journey_tests.log | 67 | 0 | 0 | 22.755 |
| photo_row_buoy_blind_journey_tests.log | 46 | 0 | 0 | 8.965 |
| photo_row_vane_crack_journey_tests.log | 37 | 0 | 0 | 7.081 |
| photo_row_keel_mark_journey_tests.log | 43 | 0 | 0 | 9.384 |
| photo_row_boat_keel_journey_tests.log | 38 | 0 | 0 | 8.875 |
| photo_row_locker_latch_journey_tests.log | 53 | 0 | 0 | 9.668 |
| photo_row_shutter_order_journey_tests.log | 33 | 0 | 0 | 4.597 |
| photo_row_bus_cable_journey_tests.log | 43 | 0 | 0 | 10.275 |
| photo_row_spindle_wear_journey_tests.log | 39 | 0 | 0 | 6.696 |
| photo_row_slide_mark_journey_tests.log | 41 | 0 | 0 | 7.792 |
| photo_row_bell_name_journey_tests.log | 45 | 0 | 0 | 9.666 |
| photo_row_feed_room_journey_tests.log | 40 | 0 | 0 | 7.013 |

Opening ON/OFF: both unchanged opening journeys passed49/0. All five printed rows match exactly in opening-comparison.json, including outcome/time/hull/O2/tools and four rows' survivor arrays. Split's print omits survivor arrays; its unchanged assertion confirms all craft alive in both runs. Every case won with hull100 and no finite tool spent. This is five source-known policies, not proof of all possible opening choices.

All fourteen photo-row journeys passed632/0 with live Sirens and their unchanged finite policies. These establish the named row capture/retreat paths, not full-operation extraction, a complete campaign, blind play or all-stage balance. Relay retains its existing three-EMP disruption loadout and authored long exposure.

Native UI: hunt_meter_ui_native.log passed235/0 and generated17 PNGs:5 at2520x1080,8 at2184x1968,4 at960x432. captures-manifest.json lists exact dimensions/bytes/SHA256. Tests use150% text and420dpi fixtures, real engine-routed touch/Back/scroll paths, and snapshot preservation. Nine PNGs were directly viewed, including both Fold help layouts, both compact-help scroll endpoints, compact basic/advanced, LOCKDOWN, basic cover and simultaneous lock-banner/advanced view. Hunt controls/help and the sampled warning separation are usable. The existing unrelated960 basic/radial clipping is visible and explicitly remains a baseline limitation; this verdict does not claim whole-HUD960 repair or zero overlap of all preexisting overlays. The stage4 pulse is table-bounded to1Hz and at least0.85 alpha, with pause-clock stability tested.

Additional actual checks: registry.log reports280 registered suites, zero errors/warnings; guidance.log passes; guidance-tests.log reports10 tests passing; diff-check.log passes. Existing shipped tests were not edited or weakened. The new-test calibration history remains in root evidence; no failure was discarded by this reviewer. This final independent run had no failed suite.

Final source proof: head-before.log, per-process head guards, head-after-runs.log and head-final.log all identify b7addca49c997772d8704afbda33ff6485d42b40. The final tracked diff for game/src, game/tests, docs and scripts is empty, and no staged diff exists. status-before.log/status-after.log contain only expected generated UID/import metadata/cache state; none was staged or deleted. The reviewer wrote only external evidence files and did not author shipped source/docs/tests, commit, push, or post a PR approval.

Limits: focused desktop checks only; no Android/APK/phone, human comfort, headphone review, exhaustive campaign balance, full matrix or all possible warning/layout combinations. Source-known journey and controlled display/geometry fixtures are identified as such. Hosted guidance/game-smoke are separate merge gates and are not certified by the focused local results. Root may relay this review with its non-author provenance, not present it as a formal GitHub approval posted by the reviewer.

Outstanding hosted blocker (root report received immediately after local runs completed): exact-head hosted run40261655770 failed the unchanged route_telemetry_touch_tests with46 checks/1 failure: "visible craft opens its own context in place without resetting manual view". Root preserved the full archive at C:/Users/Archi/Documents/Codex/2026-10-24/you-are-codex-the-implementation-worker/050-evidence/hosted-b7-failure.zip. Possible Hunt-chip overlap of a projected craft is under investigation by the owning UI worker; this reviewer has not independently reproduced or established that cause. The actual failure blocks acceptance regardless of the2451 passing focused local checks. All reviewer processes completed before the notification; no further launches are running or authorized until the corrected frozen head. Root will fix within meter placement and request exact-head recheck. No final PASS for b7 is issued.
