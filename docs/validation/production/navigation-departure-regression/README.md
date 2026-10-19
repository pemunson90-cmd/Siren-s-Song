# Near-wall departure · independent regression evidence

[Verdict](../../../reviews/2026-10-19-navigation-departure-regressions.md): no consequential new regression confirmed for frozen simulationd1bad2ca against pinneda178825. Scope supports bounded integration/meaningful combined native validation, not physical/Android/whole-game acceptance. Root continues the persistent Gauntlet.

- `source-manifest.json`: all137 tracked game files independently reconstructed from `git archive a178825 game`; only simulation.gd replaced by the producer's exact frozen source. Shared game changes are excluded. `reviewed-source.patch` is the exact8-line bounded product delta.
- `adversarial.gd`, `baseline-adversarial.json/.log`, `challenger-adversarial.json/.log`, `comparison.json`:16 valid corridor/world-edge/long PASS-STOP cases, no baseline-success→candidate-failure, no hull penetration/nonempty-route stall; three inherited corridor stops remain. Both versions additionally record/reject the initial bad emergency destination inside the wall, explicitly excluded from the16 valid cases.
- `emergency-restore.gd`, `baseline-emergency-restore.log`, `challenger-emergency-restore.log`: corrected clear emergency destination during a turn, queue/contact-hold clearance, actual archive round trip, long pause and equal future kinematics. Accepted baseline reproduces terrain stop/exit1; candidate reaches9.2s/exit0. Raw outcomes remain; no assertion was weakened.
- The integrated30s stationary-player/ordinary decoy trace digest is identical on both versions. Both accepted legacy archive fixtures restore existing mission dictionaries identically. Synthetic wall cases remove Sirens to isolate steering; the separate integrated encounter retains actual mission3 AI and ordinary emitter inputs.
- `inspection.json`: source/media hashes and full-interval sampled movie inspection. Original clips/images/logs remain under sibling `navigation-corner-investigation/`, `navigation-departure-motion/` and `navigation-departure-experiment/`; no duplicate encodes or broad suite were run.

Reproduce from repository root after creating the pinned isolated copies (no imports needed for these simulation-only probes):

```sh
timeout 70s env XDG_DATA_HOME="$PWD/work/navigation-departure-regression/reproduce-user" godot --headless --path "$PWD/work/navigation-departure-regression/challenger/game" --script "$PWD/docs/validation/production/navigation-departure-regression/adversarial.gd" -- --out="$PWD/work/navigation-departure-regression/reproduced.json"
# Substitute emergency-restore.gd for the actual archive/replacement probe.
```

The reviewer owns only this directory, the report and `work/navigation-departure-regression/`. No source/save/assets/governing/tooling/CI/commit/push changes or nested agents. Requested Sol6.1/high; actual backend/cost unavailable. Final manifest/checksums identify every retained result; physical/compositor/native/thermal/feel limits remain explicit.
