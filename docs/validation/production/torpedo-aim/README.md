# Torpedo contact aiming

Base `79c9b5a90cccf31dd3aceba12256eac8df89771a`; branch `gauntlet/feature/torpedo-contact-aiming` reuses the released clearance worktree. Root is sole reviewer/integrator. Requested Sol6.1/high; backend/cost unknown. Latest boundary356d217 reports no changed governing bytes.

Actual baseline pointer events on **both420dpi layouts** reproduce a consequential mistake: two fresh eligible contacts at `(710,750)` / `(712,750)`, tapping the rendered S1 glyph center launches at **S2**, spending one round. See `baseline.log`, `baseline-*.png` and `baseline-probe.gd`. These are explicit open-water presentation fixtures with real Sirens, actual0.4s AI/sensor observation, paused afterward; not earned campaign encounters. v7's actual pointer branch236–239 chose a near Siren under the tap and immediately pinned; production keeps its physical projectile/current launch validation and improves this input ambiguity rather than copying its hidden-target query.

The challenger adds armed-only minimum48dp **S# / FIRE** callouts with leaders to cached eligible positions. Key order is deterministic. Placement avoids the top zoom strip, instrument/contact readouts, actual optical inset, known own craft, observed Siren silhouettes/beam area, briefed objectives/labels and planned route lines. No permanent rows, modal, chart/control/font reduction. A bounded inset grid is a fallback; if no full-size location exists the layout omits that callout rather than shrinking it. Unambiguous body taps remain; overlapping body hit areas refuse to spend and direct the player to an explicit FIRE box.

Press binds the displayed key, not a nearest live position at release. Release checks the same key is still a fresh eligible on-screen observation, then the **unchanged Simulation command** checks actual Quietus sight/range/stun and spends on valid launch. Cached positions only; no live Siren query in guides. Cancellation, selected-unit or planner transitions suppress the original armed gesture instead of creating a hidden route. Existing emulated-mouse and drag/pinch handling remain.

The first placement draft obscured an archive marker and a Siren wing; `clutter-red.log` retains that failure. Known visual-area guards fixed it. `ambiguous-body-red.log` retains the still-wrong original glyph tap before its refusal was added; `edge-red.log` retains an inset-band edge omission. Final actual Compatibility input checks **65/0** cover both native-density profiles, key choice with mouse and touch, minimum size/nonoverlap, moving observed bodies, cache-only geometry, stale/range/pin/cover rejection, canceled/select/planner gestures, drag navigation, actual optical inset and offscreen suppression. Existing torpedo input30/0 and touch-navigation20/0 pass. No simulation/fullsuite/APK replay for this presentation-only change.

`challenger-cover.png` and `challenger-inner.png` preserve distinct callouts, original type, urgent beam priority and known objectives. Cost: temporary boxes/leaders occupy chart water while armed and can reflow as observed geometry or instrument rows change. Identity is stable during the press; positions are not promised fixed forever. Clustered world labels remain clustered; this change supplies an explicit aim alternative, not a world-label overhaul. Physical Fold7 comfort, sustained native performance and human targeting remain open.

## Actual interaction

`interaction.mp4`: actual2520×1080 cover-density Compatibility/llvmpipe,136px left inset,16.000s/192frames at12fps, silent Dummy audio. Automated genuine engine mouse/touch events, not OS/human input. World stays **tactically paused** at elapsed0.4 throughout; this is targeting/stock evidence, not flight or escape evidence. No reset/free stock mid-clip. At+2s mouse arms; +5s S1 mouse release creates projectile target0/stock1; +8s rearms; +11s S2 touch release creates target1/stock0. Final two known projectile keys `[0,1]`, no route. `interaction.json`, decoded six-frame contact sheet, ffprobe and engine log retained. Trace values are sampled immediately after event dispatch. At most two preexisting torpedo entities, no new simulation state.

The clip predates the later ambiguous-body refusal and visible-edge inset guard; it uses explicit central callouts, so those changed paths are not executed and its pixels/input path remain representative. Final stills use the final central placement; final65-check GL run additionally verifies the refusal and edge fix. No extra recapture matrix for unexecuted paths. Original raw192PNGs remain ignored under `work/torpedo-aim/raw/`.

Reproduce focused input: `godot --headless --path game --script res://tests/torpedo_aim_ui_tests.gd`. Actual GL variant adds `--rendering-method gl_compatibility --audio-driver Dummy`; optional `-- --capture-dir=<existing directory>` saves the paired views. Prior-input guard: `res://tests/knockdown_ui_scenarios.gd`; small `touch-guard.gd` runs the existing20 navigation assertions. `capture-interaction.gd` retains exact event controller. Caller must isolate XDG_DATA_HOME to avoid changing genuine archives.

Only four source/test files, exact final SHA256:

- `game/src/main.gd`: `4885b7a36bba1068a752c82aee0e089898b870daa75598fda3ff118e42800763`
- `game/src/presentation/ocean_view.gd`: `4b8f23c0c808e86f2c02f91420fc2de06891ebefd047dabbfa68809e951a9c45`
- `game/src/presentation/torpedo_aim.gd`: `7d3bc9fbeaf77f6ef3316f9c9363a2940cc8286e67bbac28a29c31caa5a66d6a`
- `game/tests/torpedo_aim_ui_tests.gd`: `eddcfaa3a1ebe22e4e6287cff8270e8e80d0a0383e089c7f1163e80459f90637`

MP4 SHA256: `3c2c6a5b3ac79ae3b829c3357854e0e7d96d04eb93f02e15838be58a2078bf1b`. Physics/campaign/persistence/tooling/workflow diff against the base is empty. Navigation owns the independent medium/world layer; no changes there.
