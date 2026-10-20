CHANGES REQUIRED — independent integration review

Reviewer: /root/release_integration_review (sole independent reviewer; requested Sol6.1 Medium, backend telemetry unavailable).
Base: ce157219271cbc4447393070c829e370ae20c2a9
Head: 1ec29a297f8a1542ab5d22fc5f8c5588ad0ed816
Scope: entire composed diff, including Wake, preserved concealed-pod repair, catalog/configuration/persistence seams, tests/CI and live guidance. Read candidate AGENTS.md, USER_DIRECTIVES.md and approved CURRENT_GAME_SPEC; release expansion supersedes historical rough-only restrictions.

1. P1: Wake's consequential playback action is unreachable through the UI.
   game/src/presentation/mission_hud.gd:235–239 returns generic object actions for wake_repeater; extra.wake_playback is created/refreshed but never included in command_controls(). The measured repeater shows CAMERA instead of PLAY OLD LOOP. Actual-window touch/mouse checks at cover and inner sizes: 37 checks / 20 failures. Hidden-button test taps also alter pause/route state; these derivative failures do not establish that the guarded button itself mishandles gestures. Add its proper local control branch and rerun the real-window suite, including cancel/drag/pinch/emulated release and deliberate playback.
   Evidence: independent/wake-ui.log; independent/wake-captures/2520-local-orders.png (visually inspected), plus inner capture.

2. P2: Catalog admits reusable factory aliases that cannot save immediately after normal launch.
   operation_catalog.gd:41–79 validates sample payloads under the source identity, then rewrites m.id without checking remaining identity-bound runtime/validator behavior. For each source 3,4,5,8,9: clone Catalog.definition(source), set id=200+source, register_definition returns true, Sim.start succeeds, Sim.valid_snapshot(snapshot) returns false. Remaining guards include Foundry/thermal, well, contact reports, Shelf and Wake. Other aliases tested (0,1,2,6,7,10,11,12,13) have valid fresh snapshots, but that alone does not establish complete aliased gameplay. Either support a declared alias consistently through physical behavior/persistence or reject it during admission. Do not ship a registered save-invalid operation.
   Exact executable reproduction: independent/probes.gd and probes.log (25 assertions, 5 failures; helper injection/removal rejection assertions all pass).

3. P2: Authored plant accepts geography outside runtime save constraints.
   plant_operation.gd:10 checks minimum dimensions/finite values but omits WorldRegion.valid's 40m grid and 6000m maximum. With otherwise valid config, world_size=(2401,2400) and (6040,2400) each register successfully and launch normally, but their fresh snapshots fail validation. Reject these before registration or make supported runtime constraints consistent. These are independent of the alias failures.
   Exact executable reproduction: independent/config_probe.gd and config-probe.log.

Independent passing evidence: operation_catalog 192/0 (includes changed-geography physical routing/power/restoration/acoustic receipt/shutter/extraction/checksummed save and ALL/ANY/prerequisite/replay checks); Wake state 31/0; Wake ordinary-guard journeys 58/0; witness evacuation 49/0; concealed harbour 77/0 (includes actual lost occupied pod, refused enclosing screen, binary reload and rescue); campaign equipment save 10/0. New probes confirm initial shipped registry exactly 0–13 and five cross-operation helper-payload injections plus five required-payload deletions reject. No synthetic IDs are shipped. The new plant is a real changed-world seam, subject to admission repairs above.

Wake's simulation produces a finite real local sound and ordinary stale reports; source-known solo outside recovery and timed distributed recovery both pass. This does not excuse its missing player control. Current-save and original enclosure safeguards inspected and affected suites pass. Guidance changes semantically align active entrypoints with the approved full release; USER_DIRECTIVES is in existing boundary/checker fixtures. Boundary tests16/0, guidance tests8/0, structural checker and full diff whitespace check pass. No new framework added.

Commands (cwd /workspace/Siren-s-Song-local-controls; executable /usr/local/bin/godot -> /opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64):
  XDG_DATA_HOME=<external independent/xdg-SUITE> /usr/local/bin/godot --headless --path game --script res://tests/<SUITE>.gd
  SUITE: operation_catalog_tests, wake_crossing_tests, wake_crossing_journey_tests, witness_evacuation_tests, concealed_harbour_tests, campaign_equipment_save_tests.
  XDG_DATA_HOME=<external independent/xdg-probes> /usr/local/bin/godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/release-foundation/independent/probes.gd
  XDG_DATA_HOME=<external independent/xdg-config> /usr/local/bin/godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/release-foundation/independent/config_probe.gd
  /workspace/Siren-s-Song-gauntlet-archives/recovery-20261020/runtime/root/usr/bin/Xvfb :533 -screen 0 2520x1968x24 -nolisten tcp -ac
  DISPLAY=:533 XDG_DATA_HOME=/workspace/work/gauntlet-fullspec-20261020/release-foundation/independent/xdg-ui /usr/local/bin/godot --path game --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/wake_crossing_ui_tests.gd -- --capture-dir=/workspace/work/gauntlet-fullspec-20261020/release-foundation/independent/wake-captures
  python3 scripts/toolchain/test-gauntlet-boundary.py
  python3 scripts/toolchain/test-check-gauntlet-guidance.py
  python3 scripts/toolchain/check-gauntlet-guidance.py
  git diff --check ce157219 HEAD
Raw logs and reproduction files are in independent/. Suite counters above are actual output; log-display shell wrappers do not preserve child exit codes. Initial supplied executable spelling /usr/local/bin/godot4.6.3 did not exist; corrected to shared Godot4.6.3 executable before tests.

Limits: inherited density817/12 remains unresolved; builder's ending ObjectDB warning not claimed fixed. No broad-suite repetition, APK, blind-play preference or physical Android/headphone quality claim. Entire release program remains unfinished as the guidance states. Root must obtain fixes, re-review changed exact head and NEW exact-head game-smoke CI before merge.

Ownership: no source edits, PR/merge actions, APKs, signer/profile changes, or other-tree interactions. Source remains exact reviewed head and tracked clean. All reviewer-owned Godot processes ended; reviewer-owned Xvfb :533 stopped. Read/test ownership RELEASED to root.
