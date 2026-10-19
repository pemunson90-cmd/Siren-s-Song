# Baseline evidence — 19 October 2026

This is an initial campaign baseline, not completion of the persistent Gauntlet. Actual game framebuffer images are retained here; source raw outputs are under ignored `build/captures/`.

- `baseline-field.png`: 1280×720, mission 4 after scripted ordinary route commands,33 seconds of production simulation, finite disruption on observed contacts, then active ping and pause.
- `baseline-cover.png`:2520×1080 native-size desktop framebuffer, initial planning state, logical1680×720.
- `baseline-inner.png`:2184×1968 native-size desktop framebuffer, field state, logical1280×1153, controls beneath map.
- `baseline-briefing.png`:1280×720 mission briefing.
- Captures precede minor clipping/header cleanup; fresh outputs follow in later cycles. The map/physics are interactive; the assets are separate terrain material, craft and structures, never a pasted concept scene.

Commands: `CAPTURE_FRAMES=6 CAPTURE_RESOLUTION=2184x1968 CAPTURE_DIR=/absolute/path scripts/toolchain/capture.sh -- --scenario=field`. `full.png` comes directly from the actual viewport texture. Godot MovieMaker sequences stay1280×720 and crop other aspects; do not use those sequences for phone-layout assessment.

Validation on this baseline: `scripts/toolchain/test.sh` →50 checks, zero failures; `scripts/toolchain/headless.sh --script res://tests/runtime_tests.gd` →137 checks, zero failures. Tests include fixed-step/pause/LOS/acoustic/stun, route replacement/clearance, save round-trip/corrupt-backup, sound signal/headroom, actual synthetic pointer input and viewport bounds at4 sizes. Scenario check count includes route waypoints and can change with geometry.

Six fallback campaign victories used ordinary route/camera/EMP/extraction commands, both drones unavailable, finite resources, observed contact reactions only. Mission1:64.5s/hull100%;2:88.2s/100%;3:72.9s/49%;4:86.2s/100%;5:86.8s/100%;6:83.9s/100%. These are accelerated deterministic solvability checks, not evidence of human pacing, meaningful drone incentives, or campaign depth.

Remaining evidence gaps: Android current-game runtime under hosted emulator, physical Galaxy Z Fold7 touch/folding/safe-area/performance validation, human sound listening, sustained human gameplay. Forced short desktop shutdown emits AudioStreamWAV/playback ObjectDB leak warning; source/audio cleanup attempted, leak still reproducible and unresolved. Rendering and all tests contain no script errors.

## Current cycle 2 evidence

- `cycle2-optical.png`: actual successful mid-acquisition DroneA optical view (49%); station-owned inset, persistent independent task.
- `cycle2-beam.png`: actual observed emitter→Quietus beam,96% hull; ordinary route then hold while intentionally exposed. Correct target identity, fresh lock and physical ray sprite.
- `cycle2-split.png`: connected channel/relay/uplink proving ground, Quietus selected while drone exposes; its map remains clear.

Current validation53core+142runtime, zero failures. Core includes all-mission fallback, camera station continuity, dead-command rejection, fresh target lock, fast drone navigation, standoff, relay prerequisites/sub-only uplink. Runtime includes true pointer events, briefing preservation/paused-plan resume, optical station ownership and safe-area conversion. Exact current top status and remaining gaps are in WORKBENCH, replacing any historical baseline inference above.
