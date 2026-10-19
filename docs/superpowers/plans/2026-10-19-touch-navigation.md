# Touch navigation implementation plan

> **For agentic workers:** Use superpowers:executing-plans inline as the production owner. User has authorized autonomous routine design/implementation; no repeated approval or premium-review gate. New critics inherit docs/AGENT_BRIEF.md.

**Goal:** Let a phone player inspect and navigate the chart without accidentally commanding a route.
**Architecture:** Presentation-only chart camera plus a small gesture recognizer feed the existing command boundary. Simulation, observations and persistence remain authoritative. Existing world_scale/world_offset diagnostics stay compatible.
**Tech stack:** Godot4.6.3 Compatibility/GDScript, native Control/InputEvent, current toolchain.
**Spec:** `docs/superpowers/specs/2026-10-19-touch-navigation.md`.

## Constraints and baseline

Preserve verified93b8631/native39202066103 and evidence index. Zoom range1–4; initial/FIT overview; world1600×960 remains simulation space, not a fixed UI/screen requirement. No perception/resource/time changes from camera gestures. Full-window logical native targets remain mapped by actual camera. Fit-to-task routing and persistent evidence workflow in AGENTS are binding.

## Review focus

1. Touch-generated mouse duplication must produce one order, including queue mode.
2. Drag/pinch/release outside the map, third finger and lifecycle/layout cancellation must produce zero orders.
3. Tap after pan/zoom must reach the intended world point, with route intent and pause preserved.
4. Camera inset/controls must not steal escape routes or become inaccessible on either Fold surface.
5. Crowded objective/threat labels and equal-weight controls require actual visual assessment, not only rectangle bounds.

## Task1 — Chart camera and gesture-safe orders

Files: create `game/src/presentation/chart_camera.gd`, `game/src/input/map_gesture.gd`, `game/tests/touch_navigation_scenarios.gd`; modify ocean_view.gd/main.gd/runtime_tests.gd.
Interfaces: ChartCamera.configure(size), fit(), zoom_at(factor,anchor), pan(delta), to_world(point), to_screen(point), scale, offset, zoom. MapGesture.feed(kind,index,position) returns gesture action dictionary; cancel()/active() clear/report touch state. Existing ocean.map_position and world_scale/world_offset consume camera state.

- [x] Write failing runtime assertions: visible +/−/FIT controls; anchor retained under zoom; roundtrip after pan; drag and pinch emit no route; queued real touch plus emulated mouse produces exactly one endpoint; transformed tap maps correctly; outside/lifecycle cancellation preserves snapshot.
- [x] Run runtime entry point and retain expected RED, not parser errors.
- [x] Implement camera clamping/anchoring and recognizer; root starts map gestures through GUI and tracks active moves/releases globally. Ignore emulated mouse on map, keep button behavior. Add48px zoom controls and concise hint; reset camera on new mission, cancel gestures on menu/layout/suspend.
- [x] Run focused tests and full `scripts/toolchain/test.sh`; preserve all campaign/PCM regressions. Commit runnable change.

## Task2 — Phone comprehension at useful scale

Files: ocean_view.gd/main.gd; gesture tests; `game/tests/capture_touch.gd` and retained evidence.

- [ ] Inspect actual overview/zoomed Foundry danger and optical states at2520×1080 and2184×1968. Compare baseline frames first.
- [ ] Reduce label obstruction and improve primary/advanced action hierarchy where evidence supports it; retain target/countdown, pause, station/queue/STOP/PASS and emergency access. Add targeted regression before behavioral UI changes.
- [ ] Capture ordinary transformed tap routes, pan/FIT recovery and actual threat/optical views. Record gains/tradeoffs and rejected experiments, not only test counts.
- [ ] Run full suite and commit candidate, coordinate sole push/native completion with tooling after previous run settles.

## Task3 — Independent regression and promotion

- [ ] After deterministic comparisons, commission a separate bounded Sol regression hunter against baseline93b8631 and actual challenger output; allow no meaningful findings. Confirm consequential regressions before speculative additions.
- [ ] Fresh integrated criticism as warranted across whole-game experience, with images-first and model/source policy inherited; do not substitute additional difficulty for clarity.
- [ ] Native +/-/transformed target taps and ordinary camera completion/lifecycle gate; inspect actual pixels. Physical Fold7 comfort remains open.
- [ ] Update baseline/challenger promotion, dashboard, workbench, continuation and model evidence; preserve rejected work and begin next highest-value cycle. No milestone ends the Gauntlet.

Self-review: camera/gesture interfaces, native target contract, cancellation/duplication failure classes and actual visual/Android gates are assigned above. Implementation choices are within the user's explicit touch direction and standing autonomy grant, not a claim that the user approved every UI detail.
