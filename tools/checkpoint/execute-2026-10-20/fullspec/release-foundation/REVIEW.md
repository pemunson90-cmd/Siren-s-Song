APPROVE — independent integration review of PR47

Reviewer: /root/release_integration_review, sole independent integration reviewer; requested Sol6.1 Medium (backend telemetry unavailable).
Reviewed final head: a6b6701459989d9cb50c0c62993dd8ed51057f11
Production base: ce157219271cbc4447393070c829e370ae20c2a9
No unresolved integration blockers found. Root must obtain passing NEW exact-head game-smoke CI before merge; this source review does not attest CI success.

Entire composed release-foundation diff was reviewed at1ec29a2; repair delta reviewed at60b3559fd998eecbc19b6c94c323b6e57ca96e26. Final a6b6701 changes only three documentation files from60b3559; game/scripts/workflows are byte-identical to the independently retested repair. Original review is preserved in REVIEW.initial-1ec29a2.md.

All three original findings are resolved:
- Wake command_controls now exposes PLAY OLD LOOP on measured hardware. Original actual-window cover/inner touch/mouse suite independently passes37/0, exit0: cancel, short drag, drag-off, pinch, emulated release, deliberate one-use playback, safe targets, pause and queued-route preservation. Captured cover menu visually inspected; playback replaces generic CAMERA.
- Identity-bound source3/4/5/8/9 aliases reject before registration rather than creating save-invalid operations. Original independent alias/helper probe adapted to require rejection passes25/0, exit0. Other accepted aliases retain valid fresh snapshots; five injected mismatched helper payloads and five missing required payloads reject.
- Plant configuration and runtime saves share WorldRegion.valid_dimensions. Original off-grid2401×2400 and over-limit6040×2400 probes independently confirm registration rejection, exit0.

Independent repair verification: operation_catalog199/0 and Wake state31/0, both exit0. Catalog suite exercises genuine changed geography, normal movement, local power, powered restoration, actual acoustic receipt, opened collision, physical extraction and checksummed current/completed saves; legitimate authored extension remains usable. It also covers ALL/ANY prerequisites, unearned recovery rejection, immutable replay facts/history and content-derived limits. Shipping registry remains exactly0–13; higher IDs exist only in tests.

Earlier independent checks on unchanged relevant gameplay: Wake ordinary-guard journeys58/0, witness49/0, concealed harbour77/0 (actual occupied-pod loss/enclosure refusal/binary reload/rescue), campaign equipment save10/0. Original concealed-pod enclosure repair remains preserved. Existing boundary16/0 and guidance8/0 tests passed during initial review. Final guidance structural checker and full base→head diff whitespace check pass.

Semantic guidance reviewed against candidate AGENTS.md, USER_DIRECTIVES.md and approved full-release scope. Active entrypoints prioritize approved release expansion, lean one-builder/one-reviewer execution and no human-play gate. Final docs remove stale next-milestone/current-hearing/current deferrals, explicitly require eight enemy roles, release profiles/export and production evidence presentation. Parity distinguishes temporary implementation from release obligations. CRITIC_BRIEF explicitly retains all material whole-game deficiencies before ranking the next improvement. Historical rough-only prose is identified as superseded provenance. CONTINUATION33/WORKBENCH27 lines remain concise. No additional governance framework introduced.

Exact independent rerun commands, cwd /workspace/Siren-s-Song-local-controls:
  XDG_DATA_HOME=<independent-repair/xdg-SUITE> /usr/local/bin/godot --headless --path game --script res://tests/<SUITE>.gd
    SUITE=operation_catalog_tests,wake_crossing_tests (separate processes).
  XDG_DATA_HOME=<independent-repair/xdg-probes> /usr/local/bin/godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/release-foundation/independent-repair/probes.gd
  XDG_DATA_HOME=<independent-repair/xdg-config_probe> /usr/local/bin/godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/release-foundation/independent-repair/config_probe.gd
  /workspace/Siren-s-Song-gauntlet-archives/recovery-20261020/runtime/root/usr/bin/Xvfb :533 -screen 0 2520x1968x24 -nolisten tcp -ac
  DISPLAY=:533 XDG_DATA_HOME=/workspace/work/gauntlet-fullspec-20261020/release-foundation/independent-repair/xdg-ui /usr/local/bin/godot --path game --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/wake_crossing_ui_tests.gd -- --capture-dir=/workspace/work/gauntlet-fullspec-20261020/release-foundation/independent-repair/wake-captures
  python3 scripts/toolchain/check-gauntlet-guidance.py
  git diff --check ce157219271cbc4447393070c829e370ae20c2a9 HEAD
Reruns used shared Godot4.6.3, isolated XDG; Python subprocess harness captured actual child exit codes. Raw repair logs/probes/captures: independent-repair/. Original independent evidence: independent/.

Material limits retained: inherited density817/12 and builder's ending ObjectDB exit warning are unresolved; no broad-suite rerun, blind-play preference, physical Android/audio certification or full-release completion claim. Alias admission restriction is deliberate; this review does not claim every permitted legacy alias reproduces all original campaign semantics. Approved28-core/12-optional content, depth/sonar, modes and production quality remain ongoing release work.

All reviewer-owned Godot processes ended and reviewer-owned Xvfb:533 stopped. Exact final source remains unchanged and tracked clean. No source/profile/signer/other-tree mutations, PR actions or APKs. Read/test ownership RELEASED to root for final exact-head CI and integration.
