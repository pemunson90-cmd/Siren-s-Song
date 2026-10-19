# Campaign quality scout evidence

Independent [report](../../../reviews/2026-10-19-campaign-quality-scout.md). Exact accepted source52bedd664b2d50d428e4d92a379b89b115c4d79f, isolated using `git archive`, all117 tracked game files byte-verified in [provenance.json](provenance.json). Shared live product and player saves untouched. Requested gpt-6.1-sol/high/fresh context; actual backend/token/cost unknown.

[Approach16s](blackwater-approach-16s.mp4) / [sequence](blackwater-approach-moments.jpg) / [trace](blackwater-approach.log): ordinary mission2/survey, Drone A route(760,410), SONAR at6s, CAMERA at11.33s, finite disruptor only for fresh observed Drone A lock, at least1s between attempted responses. Record secured; Quietus100%; both disruptors spent. Full [optical frame](blackwater-optical.png).

[No input16s](blackwater-noinput-16s.mp4) / [sequence](blackwater-noinput-moments.jpg) / [trace](blackwater-noinput.log): prepare ordinary route plus one finite observed-lock disruption for11s; command CAMERA immediately before frame0. No commands throughout capture. Record completes around4s; visible renewed beam around10s and real Drone A loss around14s. Quietus100%, Drone B and one disruption remain. [Threat frame](blackwater-lock.png). This is not a forced failure or whole-mission defeat. Generic ObjectDB teardown warning retained in raw log.

[Order probe](blackwater-order-probe.log) retains first→second and reversed attempts, both ending with Drone A loss and fallback still available. This earlier coarse policy can spend disruption twice on a sensor update; it is an inefficient counterexample, not accepted balance/optimal play. [Driver](order_probe.gd).

Godot4.6.3 Compatibility/software GL,1280×720/96dpi desktop, fixed15fps; MP4s640×360, silent. [Capture driver](capture.gd) uses normal simulation advance/commands and actual main-scene rendering. It disables automatic main advancement to avoid double stepping, refreshes each frame, and captures240 frames; no production state overrides. Imported assets/production source are unchanged. It is not OS touch/native/physical evidence or human listening. Main-scene automatic observation diagnostics are not run by this driver; no diagnostic-only observation enters the player HUD.

Reproduce by copying the two retained critic scripts into an isolated exact52 game snapshot's tests folder. Use an unused live dummy Xorg display and an isolated XDG directory:

```sh
DISPLAY=:132 XDG_DATA_HOME="$PWD/work/campaign-quality-scout/userdata" LIBGL_ALWAYS_SOFTWARE=1 \
  godot --path work/campaign-quality-scout/baseline/game --rendering-method gl_compatibility \
  --audio-driver Dummy --resolution 1280x720 --fixed-fps 15 \
  --script res://tests/campaign_scout_capture.gd -- --folder="$PWD/work/campaign-quality-scout/approach"
```

Add `--scenario=idle` and a different folder for no-input. Encode `%04d.png` at15fps with libx264/yuv420p. Source evidence paths/scripts and raw traces are authoritative for commands. Fresh local Xorg132 was closed after capture; do not assume it remains live. No broad regression panel was needed for a read-only scout.

[Barotrauma26–40s decoded sequence](barotrauma-26-40s-moments.jpg) has relative timestamps: add26s. Only around36.5–38.5s shows its sonar console; this curated trailer is unsuitable for a sustained sonar/dread comparison. Full source/provenance and explicit pending verdict are in the report. No blind comparison, availability recommendation, imitation or subjective audio claim.
