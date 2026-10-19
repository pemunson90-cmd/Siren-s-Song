# Actual programmed-route evidence

Inspect `baseline.mp4`, `programmed.mp4`, `idle.mp4`, their1fps contact sheets and editor images before the [implementation interpretation](../../../reviews/2026-10-19-programmed-waypoints.md). Unblinded identifiable sources; source/identity blinding is not claimed. All images are actual Godot4.6.3 Compatibility software-GL rendering. Desktop1280×720 movies are each16s/15fps/240 frames; editor desktop,2520×1080 cover420dpi and2184×1968 inner420dpi use the recorded136px cover inset and are desktop density fixtures, not native/physical proofs. Audio driver Dummy; no listening or performance inference.

Baseline is exact `a2178b1a3debfaaabcd2f1eb23bc62c92065dbe7` game archive in ignored `work/baseline/game`. Programmed source is frozen in `source-freeze.json`; only route programming/editor/wiring differs. Same initial ordinary fresh Shelf Signal snapshot SHA256 `a711ec4c8bd6f34cc84cd1970b078889e1895d89054acfff15da66086155b706` across all three. No terrain/AI/resource/velocity/position edits, no hidden Siren state used for decisions or sensor bypass. Idle receives zero route/mode/selection orders and the real simulation advances. Movement setup uses ordinary route/queue/STOP commands for Quietus and both drones. Programmed incoming modes are established before frame0; baseline starts manual cruise.

Actual pointer selection occurs at+1s DroneA, +5s Quietus, +6s DroneB, +8s Quietus in both movement takes. Baseline also presses the ordinary SILENT/CRUISE button at+5/+8s; programmed has no live propulsion input. The delayed baseline models returning attention late, not an expert/manual optimum or human usability study. Both stop at B and settle at C. Fixed ordinary2× camera is centered on own route before frame0; no pan/zoom during clip, no OS-input claim. Controller clocks simulation explicitly at1/15s per captured frame; movie playback is not wall-clock performance evidence.

| Observed event/cost | Old manual delayed fixture | Programmed |
| --- | --- | --- |
| Silent command | +5.067s sample, after B | +2.4s sample near A; still75.2 speed |
| B near rest / next leg | +4.733s | +5.267s |
| Final settle | +9.333s | +9.0s |
| Sampled time speed>50 |2.53s|3.33s|
| Final hull / outcome |100 / ongoing|100 / ongoing|

Silent intent does not instantly erase momentum/noise. Programmed is not lower-total-exposure in this fixture. Idle ends+16s/hull100; no route. Chronologies retain every rendered frame's own state, inputs and observed contacts. `baseline-075.png` and `programmed-{035,078,134}.png` provide full-resolution event views. Legacy departure/emergency losses and prior verified Door Kickers narrow linkage reference remain in their original folders, not replaced by these unengaged runs.

Reproduce from the assigned worktree (display319 was the owned dummy Xorg):

```bash
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/route_program_tests.gd
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/route_program_ui_tests.gd
DISPLAY=:319 LIBGL_ALWAYS_SOFTWARE=1 godot --path game --rendering-method gl_compatibility --audio-driver Dummy --resolution 1280x720 --fixed-fps 15 --script "$PWD/docs/validation/production/programmed-waypoints/capture_program_motion.gd" -- --folder="$PWD/work/replay-programmed"
```

Use the same controller against `--path work/baseline/game` for manual, plus `--idle` for idle. Isolate `XDG_DATA_HOME` per run; controllers use capture mode and do not load/write player saves. Encode `%04d.png` at15fps with ffmpeg/libx264/CRF20/yuv420p. `capture_editor.gd` takes `--out=...`, optional `--density` and `--drone`; native-sized windows use matching `--resolution`. It opens an actual paused panel after ordinary planning commands. Preview shows only selected own route and chart-memory cells; no hidden contacts.

Focused results: model36/0, pointer/touch editor44/0, departure45/0 (open-water/enemy trajectory hashes retained), simulation293/0, runtime316/0. `checks.txt` holds exact summaries. Full raw test/import/render logs and source/rejected frames stay ignored locally under `/workspace/Siren-s-Song-programmed-waypoints/work`; no full suite/APK or duplicate critic was required. The cover list intentionally scrolls at full touch size; selected row is brought into view. FIXED96 drone image corroborates explicit propulsion limitation. Further drone speed modes are pending a separate evidenced design.
