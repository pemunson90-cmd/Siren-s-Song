# Contact/instrument clearance

Base `9e9f6092c5ac6789da3ee95dedb94cb3f0e9f007`. Separate `gauntlet/feature/contact-instrument-clearance`; root is the single integration reviewer. Requested Sol6.1/high; actual backend/cost telemetry unknown. Current policy refresh adopted dca18e0; completion fetched206e6ff with no governing byte changes.

Composed cover failure: five acoustic rows place third observed row at y332–360, over the optical inset starting338. Baseline cover image shows that row hidden. Combine the terrain qualification and enemy-reception uncertainty into one line; keep all three contact rows, urgent beam first, stock/timers, fonts, controls and optical size. Legacy acoustic copy stays unchanged. Backgrounds fit each line individually so the longer qualification does not obscure extra charted water beside the shorter lines. The first full-width backing draft dimmed the known Pattern Array label; the final paired views retain it.

Focused `observed-only.gd` runs the existing observed-contact and acoustic UI scenarios: RED61/1 (observed-only run, exact cover overlap), then GREEN68/0 after adding the7 existing acoustic assertions to the focused wrapper. The row-count-only acoustic assertion now checks the actual terrain qualification; existing uncertainty, pause, finite timer and no-safety-claim guards remain. Acoustic footprint6/0. No sim/main/route/control changes, broad suite or native build.

Commands from this worktree:

```
XDG_DATA_HOME=$PWD/work/contact-clearance/userdata godot --headless --path game --script ../docs/validation/production/contact-clearance/observed-only.gd
godot --headless --path game --script res://tests/acoustic_footprint_tests.gd
DISPLAY=:293 XDG_DATA_HOME=$PWD/work/contact-clearance/userdata godot --path game --rendering-method gl_compatibility --audio-driver Dummy --script ../docs/validation/production/contact-clearance/capture.gd -- --folder=$PWD/work/contact-clearance/recheck
```

Six actual baseline/challenger PNGs: desktop1280×720, cover2520×1080/420dpi with136px left inset, inner2184×1968/420dpi. Presentation fixture sets a real own camera station and invokes CAMERA/SONAR, with three authored cached contacts (one fresh beam, two historical); it is deliberately a layout stress fixture, not earned gameplay/sensor evidence. Godot4.6.3 Compatibility/llvmpipe, no physical Fold7 comfort claim. Raw engine/layout measurements retained in the two render logs. Initial scratch headless wrapper omitted the1280×720 startup declaration and produced font glyph errors from its64×64 default; corrected before the retained RED. Stale Xorg180/184 setup failed; final actual renders used291/293 without changing other servers.

| Profile | Font, unchanged | Third row bottom → after | Optical top | Long qualification width / chart width |
|---|---|---|---|---|
| Cover |22 logical px |360→333 |338 |789 /1072.33 |
| Inner |19 |325→301 |399 |684 /1228 |
| Desktop |14 |246→227 |338 |510 /852 |

The final line consumes more horizontal space than the former separate rows; it fits each tested chart, while the per-line backing bounds the added occlusion to that line. World glyphs can still overlap when the deliberately authored contact positions cluster; this task changes only the instrument/readout clearance.

Exact changed source/test SHA256:

- `game/src/presentation/acoustic_feedback.gd`: `0075cd282d856bb2853fa408856e7ef1fde9d9892e377b417c95479b97d9c875`
- `game/src/presentation/ocean_view.gd`: `022a956497cc533cab8bb9e4f628504424b9d73220c6ef61c7fff8e697fc4582`
- `game/tests/acoustic_ui_scenarios.gd`: `ec3737142adfc35a7093a7a8aa6a98c51a22a308763991f963152584515b2be6`
