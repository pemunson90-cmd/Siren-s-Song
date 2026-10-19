# Independent directed acoustic regression evidence

Review source `08eca2515425f127c073f3ba2f11e6bf3bee766c`, comparison `11151d3` (same baseline game as inspected `b809501`/`aa022cc`). Product and tooling SHA256 manifests in the parent acoustic folder and `docs/validation/android-39229219785/capture-timing-fix/` were independently checked before and after probes. See [verdict](../../../../reviews/2026-10-19-acoustic-feedback-regressions.md).

`baseline-provenance.json` records all47 tracked non-test baseline game files and their exact SHA256: the existing `work/acoustic-feedback/baseline-game/` copy matches `git show 11151d3:game/...` for every file. Initial verification accidentally appended a second `game/` path and found missing paths; correcting the verifier's path produced47/47 exact matches. No baseline game mutation followed.

## Reproduce directed comparison

Use Godot4.6.3. Isolated `XDG_DATA_HOME` paths below are scratch, never player archives. Scripts are review fixtures outside game source and are loaded through an absolute script path.

```sh
repo=/workspace/Siren-s-Song-gauntlet
probe="$repo/docs/validation/production/acoustic-feedback/regression/directed_probe.gd"
XDG_DATA_HOME="$repo/work/acoustic-regression-data/baseline" godot --headless --path "$repo/work/acoustic-feedback/baseline-game" --script "$probe"
XDG_DATA_HOME="$repo/work/acoustic-regression-data/candidate" godot --headless --path "$repo/game" --script "$probe"
```

To reconstruct a missing baseline copy without resetting another checkout, `git archive 11151d3 game | tar -x -C <empty scratch directory>`; then pass its `game/` to `--path`. All assets are unnecessary for the simulation-only probe but the existing complete baseline copy was independently verified.

`baseline-directed.log`, `candidate-directed.log`, `directed-summary.json`: all396 `COMMAND`/`TRACE`/`END` records match exactly. TRACE hashes include snapshot, events, message, accumulator, sensor clock, queue and waypoint mode. Each of six missions receives the same45s ordinary-command attempt, paused query interval and restore transition. Candidate queries17 snapshots per tick and actively mutates/clears every returned dictionary/array; retained simulation remains equal. Baseline12 checks/0 failures, candidate16459/0. Counts reflect repeated isolation assertions, not new experience coverage. Mission1 hull52.9%, mission3 loss at35.1333s are preserved in both versions. The candidate-only suffix checks three independently timed restored decoys, full expiry, actually hidden factory response and unknown-source exclusion, and existing SURVEY visibility.

## Shell adversaries

```sh
python3 docs/validation/production/acoustic-feedback/regression/shell_adversarial.py
```

Four independent cases call the existing fixture's real shell helper and Python checker, mocking only ADB/log transport: malformed postcapture state, incomplete newest chunk, decreasing snapshot count, and requested target appearing between the two state observations. All four pass. Invalid/pending state never publishes a final PNG; target transition requires a matching fresh pair. `shell-first-fixture-failure.log` preserves the initial misuse of a clipped full hit rectangle, which the real gate correctly rejected. The corrected fixture changes a valid control's action before requested-target arrival. This is test-fixture repair, no production correction.

## Actual UI stress capture

```sh
DISPLAY=:110 TOOLCHAIN_CACHE="$PWD/work/toolchain" scripts/toolchain/display.sh
DISPLAY=:110 XDG_DATA_HOME="$PWD/work/acoustic-regression-data/ui-fixed" LIBGL_ALWAYS_SOFTWARE=1 godot --path game --rendering-method gl_compatibility --audio-driver Dummy --resolution 2520x1080 --script "$PWD/docs/validation/production/acoustic-feedback/regression/ui_probe.gd" -- "$PWD/docs/validation/production/acoustic-feedback/regression"
```

Run display startup and capture within the same live execution cell: this environment kills the detached Xorg after its owning cell ends. The script scans18 ordinary cruise-route scenarios (six missions × three destinations, up to45s each), sonar every4s. It retains the largest fresh observed threat sample and the largest naturally camera-ready threat sample, then restores those ordinary-derived snapshots paused for rendering; no positions/enemy/contact fixtures are synthesized. It adds ordinary DECOY/SONAR commands for instrument coexistence. The PNGs are scripted paused render fixtures restored from those ordinary-derived states, distinct from the live scan itself. Samples are diagnostic, unsafe deliberate attempts, not recommended tactics or campaign completions.

Fresh per-profile UI instances after window resizing avoid stale fixture offsets; cover2520×1080 with136px inset, inner2184×1968 with full safe rect, both420dpi desktop fixtures and2×chart zoom. `ui-probe.log` records exact dimensions/rows. The first reuse-across-resize fixture erroneously measured/layouted before resize settlement and retained stale cover offsets; its visibly invalid inner image and log remain `rejected-resize-inner.png`/`rejected-resize.log`, with no product defect or acceptance attributed to that capture. The corrected fresh-instance captures are authoritative.

The scan observed3 fresh threat rows at most and2 coexisting with camera readiness. Authoritative `cover-coexistence.png`/`inner-coexistence.png` show2 threats, acquisition,4 instrument rows and2×zoom without overlap. `cover-max-threats.png`/`inner-max-threats.png` show all3 observed threat rows. Cover instrument/threat stack ends at305logicalpx for2 rows versus optical top338; inner ends282 versus399. Three-row stack ends335/312 respectively; no optical view is active in those samples.

No native challenger installation, physical Fold7, compositor presentation acknowledgment, human audio or sustained-performance result is asserted. The already-final integrated full gate was read, not rerun.
