# Independent regression evidence

Verdict: [no consequential new regression confirmed](../../../../reviews/2026-10-19-observed-contact-regressions.md) against9dacbb4→exact5eb571f. This evidence supplements the separate experience review and root's existing strict integrated gate; it does not repeat that broad suite or establish native/compositor/physical acceptance.

- `source-context.json`, `source-sha256.txt`, `freeze-verification.json`, `tracked-delta.patch`: source identity and full16-file committed game/tool delta, plus immutable original v7 hash. The live and isolated candidate source match committed5eb571f.
- `paired-replay.gd`, `baseline-replay.jsonl`, `candidate-replay.jsonl`, `paired-result.json`, corresponding `.log`: same ordinary-command script against git-archived9dacbb4 and copied candidate.518 records equal, including binary full-snapshot SHA256, command acceptance, events/tick clocks/route mode. Only the intentional launch-message string is normalized. No forced enemy pose, outcome, resource or sensor change. All six starts are tested, not six full completions. Well lock loss is retained unchanged.
- `contact-adversarial.gd`, `contact-adversarial.log`:13 focused cached-observation age/memory/own-target/cover/value-isolation/priority assertions.
- `occupancy-fixture.gd`, `three-contact-{cover,inner}.png`, corresponding logs: actual Godot4.6.3 X11/OpenGL Compatibility/llvmpipe renders, forced420dpi density subclass, cover recorded136px inset and inner full window. Three forced cached contacts coexist with four own-emission lines and ordinary drone-camera context. Fixture contacts are explicitly synthetic presentation stress; no native or naturally occurring three-contact encounter claim. Original full-resolution PNGs are retained.
- `capture-adversarial.py`, `.json`:8 extra probes using actual CLI/helper with mocked ADB/log transport and PNG headers. No fake screenshot pixel claim.
- `headless-state.log`, `headless-verification.log`: actual isolated production scene with the existing tooling capture-state fixture; exits0/drawn0/layout_only. Headless process-frame visibility is not post-draw evidence.
- `rejected-isolated-cache-setup.log`: first isolated copy excluded `.godot` imports, causing resource loads to fail and the fixture to time out; existing generated imports were then copied without source changes. `rejected-probe-indentation.log`: reviewer scratch-driver indentation error, corrected only in scratch. `rejected-dying-display.log`: reused Xorg died during startup; successful independent renders started fresh display138 in the same command. All are setup/probe failures, not product RED.

Reproduction from repository root:

```sh
# Isolate git-archived baseline and a source copy first; normal userdata stays untouched.
# Copy paired-replay.gd into each isolated game's tests/regression_replay.gd.
timeout 90s env XDG_DATA_HOME="$PWD/work/observed-contact-regression/userdata-baseline" godot --headless --path "$PWD/work/observed-contact-regression/baseline/game" --script res://tests/regression_replay.gd -- --out="$PWD/work/observed-contact-regression/baseline-replay.jsonl"
# Repeat the identical driver for candidate/game and a different userdata/output path.
python3 docs/validation/production/observed-contact-feedback/regression/capture-adversarial.py
```

The actual occupancy run used `--resolution 2520x1080` / `--resolution 2184x1968`, `--display-driver x11 --rendering-method gl_compatibility --audio-driver Dummy`, isolated userdata and `--context=camera --safe-inset-x=136` / `0`. Pass `--image-path=<absolute PNG>`; use a live display started in the same execution command. The initial copied game needs generated imported resources for presentation; these are scratch/cache, not reviewed product changes. `paired-replay.gd` and contact checks need no texture imports.

Requested Sol6.1/high; actual backend/token/cost unavailable. Reviewer owns only this evidence directory and its review document. No source/save mutation, commit/push, nested agents or premium escalation. Bounded completion releases this scope while root continues the Gauntlet.
