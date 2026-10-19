# Near-terrain departure: independent experience review

**Recommendation: promote the scoped steering challenger for integration/native validation, subject to the separate regression disposition.** The matched departure becomes dependable without an instant heading change, instantaneous speed change, free escape or extra tactical knowledge. No consequential new experience defect is confirmed in these clips. This is desktop evidence, not Android or whole-game acceptance; worker release does not end the Gauntlet.

Requested routing: `gpt-6.1-sol`, high, fresh independent context. Actual backend/token/cost telemetry is unavailable. Scope is understandable, reliable player-craft departure/route following beside terrain, retaining maneuvering weight, uncertainty and finite time cost. No shared source, assets, saves, governing docs, tooling, CI or branch were changed; root remains sole pusher.

## Artifact-first observations

Before reading the producer README, patch, chronology or movement source, I inspected all three actual [decoded 1fps sequences](../validation/production/navigation-departure-motion/) and then six full-size frames across the takes. My provisional observation, sent to root before builder interpretation: baseline rotates beside the same rock and remains there for the rest of 16s; challenger first rotates, then visibly clears the rock and proceeds left along the dashed route while terrain scrolls past. Idle stays beside the rock while the world remains in REAL TIME.

I independently decoded the first three seconds of each departure movie at 4fps into [baseline](../validation/production/navigation-departure-experience/baseline-first-3s.jpg) and [challenger](../validation/production/navigation-departure-experience/challenger-first-3s.jpg) temporal sheets. This review uses successive decoded frames/full frames, not physical interaction or a human normal-speed playback/comfort test. It establishes the visible steering sequence; it does not certify perceived smoothness or input latency.

| Actual clip / time | Observed experience |
|---|---|
| [Baseline](../validation/production/navigation-departure-motion/baseline.mp4), 0–2s | Turns gradually while drifting down toward basalt. By the 2s frame the route has disappeared and the footer says “Autopilot stopped at unsafe terrain. Replot in open water.” |
| Baseline, 2–15.93s | Craft remains beside the rock; status is READY. The submitted home intent has been lost. This is a real baseline loss, retained rather than hidden by the successful challenger. |
| [Challenger](../validation/production/navigation-departure-motion/challenger.mp4), 0–2s | The same gradual turn is visible, initially without translation; by 2s the craft is departing left and the dashed route remains. It reads as maneuvering before travel, rather than a snapped heading. |
| Challenger, 2–15.93s | Continued travel along the planned segment; by the last frame the hull turns toward the next route bend. No visible teleport or disappearance/reappearance. This movie does not show extraction. |
| [Idle](../validation/production/navigation-departure-motion/idle.mp4), 0–15.93s | No craft departure. Remembered contacts age/disappear; oxygen falls from 97% to 96%. This is an active world observation, not proof of continuously visible patrol activity: live enemies are outside the view/sensors. The stale “paused for review” footer contradicts REAL TIME and is a qualified harness artifact, not a challenger product finding. |

All clips are recognizable and were labeled before inspection: **nonblind**. There was no concealed identity or later unblinding. No suitable matched Door Kickers route-steering footage is verified locally; that external comparison remains **pending**. Existing Mark of the Ninja footage is not a matched submarine-steering reference. No shipped-game victory or current store/play recommendation follows.

## Gain and retained costs

The important gain is preservation of the player's already accepted route through its initial turn. A home order near a charted rock no longer creates an avoidable drift into that rock and requires a new order. The route line and ROUTE status remain a useful connection between intent and motion. The baseline's explicit stop is preferable to an invisible collision, but the challenger avoids this particular interruption in the first place.

After artifact observation I checked the chronology: both departure takes restore the same state at elapsed47.4s, position(1353.052,618.3444), heading0.233938rad, both records aboard, hull100 and EMP0. The ordinary home-route command occurs before frame0; no tactical commands occur during either movie. Challenger's measured first movement is1.1167s in the producer's full response trace; sampled movie state is still stationary at+1s, moving at about37m/s at+2s and42m/s at+3s. This matches the visible turn-and-accelerate gain. The baseline has cleared its route by sampled+2s. Eventual78.7s extraction is secondary producer replay evidence, not something seen in this16s movie or a quality score.

The cost is real: roughly1.1s turning before translation, continued rotation at1.8rad/s, finite acceleration/braking, subsequent time spent traversing the route, and exposure to an advancing uncertain world. This is a useful maneuvering cost here, not the previously rejected mandatory waiting cadence: the craft visibly changes heading to satisfy the route. The circular room heuristic can also withhold thrust because of nearby terrain behind the craft; this capture does not establish that every such delay feels appropriate. Existing unavoidable momentum/collision stops must remain possible and readable.

Camera/gaze costs remain explicit. Both movies use normal2× zoom plus programmatic own-position following pan each frame. The following view makes the departure easy to track and lowers manual camera work, but is not proof that a player can keep the route, terrain ahead, threat memories and right-side controls in view through real pan/zoom gestures. Much of the upcoming route lies off the left edge; the full destination cannot be judged from this close view. Those are limits/inherited presentation costs, not a confirmed new steering regression. Stale contacts remain stale, and “Enemy perception unknown” does not promise safety; the controller grants no new observations.

## Relevant original and exact source

I read the immutable original v7 `updateSub`, lines295–309, after the artifact observations. Its heading changes gradually; forward thrust retains a35% floor while misaligned; penetration into circular obstacles is projected outward and speed quartered. Production already uses genuine collision-stop/route clearing with its own vector inertia. The challenger deliberately adds anticipatory thrust withholding before a tight arc while preserving rotation/braking and that physical stop. V7's obstacle pushout is a reference behavior, not permission for noclip or free repositioning. This is a documented assisted-control departure from v7's thrust floor, supported by the inspected baseline loss and visible challenger gain.

Exact baseline: `a178825fc4885f9f3ab191315302925ab0cdac87`; isolated challenger changes only `game/src/simulation/simulation.gd`, SHA256 `d1bad2ca17fa28c1f8faa3ce2a7e4d1c91cf5ba2ad79df98c4bcb0d193431641`. [Frozen source/patch](../validation/production/navigation-departure-experiment/source-freeze.json); [motion source/fixture](../validation/production/navigation-departure-motion/source-freeze.json). Shared current loadout/hint edits are outside this comparison. Independently checked `git show` baseline bytes against SHA256 `f69be61072eaaa4c36a24932d7ec705a65f5389fb4f4283e045c7a5a58ef1884`, patch and snapshot file hashes against the freeze, and original v7 MD5 against its manifest. All matched. Identical restored-state digest across baseline/challenger/idle: `54ebaf9d4d74848a0d7cd49b623860a544cd237d5bb1dbe7814b414a3247bc54`.

Backend: Command-Library desktop Godot4.6.3 official, Compatibility, Mesa llvmpipe softwareGL, fallback95dpi;1280×720,15fps,240frames,16.000s per silent clip. Producer uses a baseline-earned ordinary solo approach snapshot with explicit both-drones-lost setup and finite existing EMP policy, not private player data or earned-campaign proof. Capture starts mission3 normally before restore. No source/dev-only pose adjustment occurs after restore. Logs' unsupported V-Sync and exit leak warning do not establish an input/steering defect; no performance certification is inferred.

Independent media checks: `ffprobe -v error -show_entries stream=width,height,r_frame_rate,nb_frames:format=duration -of json <clip>` confirmed those dimensions/cadence/duration for all three. Movie SHA256s: baseline `16dcdd0d4dbf1314464f8cf82eb047d05db3e09e30050fccb382fd2decb0fa60`; challenger `60c4c8e396621b909b3b7a373ec9836b6836e0f419c768e725f6ec7795cdea07`; idle `b378d4064f7cc923d0cb216cc643035aba5d28beec343c844ff5af01baea079c`.

Review decode command, from repository root (substitute `baseline` for the other sheet):

```sh
ffmpeg -hide_banner -loglevel error -i docs/validation/production/navigation-departure-motion/challenger.mp4 -vf 'fps=4,crop=852:580:26:112,scale=426:290,tile=4x3' -frames:v 1 docs/validation/production/navigation-departure-experience/challenger-first-3s.jpg
```

For runtime reproduction use existing `capture.gd` with the frozen isolated source, `--fixture=<absolute earned-departure.bin> --folder=<scratch>` and optional `--idle`, then the retained `encode_clips.py`; see producer's [exact commands](../validation/production/navigation-departure-experiment/README.md). This review did not rerun broad simulation/AI/archive tests; those belong to the separately assigned hunter.

## Next bounded priority and remaining evidence

After scoped integration, inspect an actual cover/unfolded native near-terrain emergency route replacement with an on-screen legitimately observed threat and nonzero incoming momentum. Preserve a losing attempt and compare it to the current baseline: can the player see deliberate turning, predict its cost, keep terrain/threat in view and replace intent without fighting camera gestures? This is the most useful next steering-experience check; do not erase the turn cost or retune enemy sensing merely to obtain a win. Root's current UI/native work continues independently.

No confirmed new consequential issue/repro is filed from these16s clips. Native touch/gesture/camera behavior, real Fold7 comfort, sustained thermal/frame performance, human control comprehension/audio and matched external steering comparison remain unverified. This recommendation covers the demonstrated local gain and its documented cost, not universal collision safety, native promotion or user acceptance.
