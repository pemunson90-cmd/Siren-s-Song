# Listening Well baseline · late-campaign scout

Exact source20de5cd2f7aaabd96790cfbe67840e22c07c66fe. [Independent report](../../../reviews/2026-10-19-late-campaign-opportunity.md). [Provenance](provenance.json) verifies all138 tracked game files; only own critic drivers were added to the isolated game copy.

- [First-record20s](well-first-record-20s.mp4), [moments](first-record-moments.jpg), [trace](active.log): ordinary Drone A route to800,390, fresh observed-lock finite disruption, then four-second camera. Same rendered continuation reaches both other briefed records and legitimately wins45.38s/100%, both drones alive,3EMP spent, Quietus never routed, no Well evidence retained.
- [First](first-optical.png) / [second](second-optical.png) actual optical panels repeat the Foundry facade. [Earned debrief](earned-debrief.png) supplies the engine-note revelation without a retained comparison artifact.
- [No-input20s](well-noinput-20s.mp4), [moments](noinput-moments.jpg), [trace](idle.log): ordinary approach/two finite observed-lock disruptions, then CAMERA immediately before frame0. No commands during all300frames. Record secured around4s; fresh threats after disruption ends, real Drone A loss around16s; submarine intact, Drone B and one pulse remain. [Loss frame](noinput-loss.png).
- [Command alternatives](ordinary-well-probe.log): unprotected loss before a record; protected remote completion with a real Drone A loss under a different schedule. `initial-probe.log` is retained; outer outcome early-return refinement did not change that result. Neither trace is mislabeled as the distinct rendered both-drone win.

Godot4.6.3 Compatibility/softwareGL,2520×1080/420dpi fixture,136px cover inset. Videos1260×540,15fps,300frames,20.000s,silent; decoded contact sheets inspected at one-second intervals alongside full optical/debrief frames. No physical/native/audio/human-pacing claim. Direct mission selection is a chapter fixture; no actual campaign unlock sequence is claimed. All travel/capture/extraction outcomes are ordinary production commands with untouched initial simulation state.

[Capture driver](capture.gd) disables automatic main advancement to avoid double stepping, advances production simulation at1/60s, retains normal player presentation/observation diagnostics, and logs commands. `--idle` prepares the no-input take. [Headless driver](probe.gd) uses0.1s command sampling; this accounts for a different timing schedule and outcome. Both use isolated XDG data, no player saves. Shared source, active navigation/native work and CI untouched.

Reproduce using the retained scripts in an isolated `git archive20de5cd` game copy, import it with Godot4.6.3 and copy each script into that copy's tests directory. Start an unused checked display;220 from this capture was closed afterward. Then:

```sh
DISPLAY=:220 XDG_DATA_HOME="$PWD/work/late-campaign-opportunity/userdata" LIBGL_ALWAYS_SOFTWARE=1 \
  godot --path work/late-campaign-opportunity/baseline/game --rendering-method gl_compatibility \
  --audio-driver Dummy --resolution 2520x1080 --fixed-fps 15 \
  --script res://tests/late_scout_capture.gd -- --folder="$PWD/work/late-campaign-opportunity/active"
```

Add `--idle` with a separate output folder for the unattended take. Encode `%04d.png` at15fps using libx264/yuv420p. Final logs retain VSync/backend or short-exit ObjectDB warnings where emitted. No broad game suite was rerun for this read-only scout. Requested gpt-6.1-sol/high; backend/token/cost unknown.
