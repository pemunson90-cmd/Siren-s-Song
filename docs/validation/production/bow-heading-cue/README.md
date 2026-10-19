# Selected Quietus bow cue · isolated presentation challenger

Experimental; no source promotion is claimed. Inspect the actual [paired movies](motion/) and same-state cover/inner images before this rationale. Baseline is exact6ab8fb0, already containing the reviewed steering improvement. Both versions steer, take damage and lose identically. This comparison adds only a current-heading mark.

## Inspect actual pixels

- `baseline-cover/emergency-030.png` versus `challenger-cover/emergency-030.png`, and the equivalent inner pair: the bow points northwest while the accepted route points west. The new open chevron is separated from the hull; the cyan dashed line remains the desired route.
- `challenger-{desktop,cover,inner}/emergency-{000,015,030,045,060}.png`: near-aligned original heading, emergency reversal and subsequent alignment. The mark does not portray drift or a predicted safe path.
- `departure-positive-015.png`: the opposite-sign ordinary Blackwater turn, matched on desktop/cover/inner. The mark sits close to QUIETUS text and overlays a small patch of basalt; the name is still drawn above it. That proximity is retained for clutter judgment, not hidden by a favorable turn.
- `quietus-turn-fit.png` and `quietus-turn-4x.png` in those folders: actual same saved turn at1×/FIT and4×. `pan-away-4x.png`: ordinary camera panning clips off-screen content normally; no pinned/phantom edge arrow appears.
- `drone-south-{fit,4x}.png`: the final cue is absent from selected drones. Those images and pan-away images are pixel-identical across versions in all three profiles.
- Four16s movies: baseline/challenger departure plus baseline/challenger emergency without EMP. Seven full frames, decoded1fps sheets, raw-frame hashes, chronology and ffprobe metadata accompany each. Frames0,15,30,45,60 support direct turn comparison.

The static comparison uses the previous ordinary emergency's one-EMP first4s for a clear turn view. Its native-size images are desktop420dpi fixtures, not Android runtime screenshots. The emergency movies instead reuse the retained no-EMP policy to preserve visible beam activity and loss. Those are deliberately separate takes, not a claim a tool-free cue improves survival.

## Small final change

Only `game/src/presentation/ocean_view.gd` changes. A short, open pale-cyan chevron sits beyond selected Quietus's bow with a dark outline. Its direction derives from the already known current owned `u.angle`; position derives from owned position and the existing66-world-unit half-length of the rendered hull. Applicability is selected Quietus, available own craft, active dive. No enemy/contact/route/velocity information enters its geometry. Selection/availability/outcome only determine whether it is shown.

The local screen-sized shape is drawn inside the existing own-craft pass, before observed enemies, lock arcs and firing beams. Thus existing actionable threat marks retain drawing priority. It is not a vision cone, hearing footprint, velocity vector, predicted trajectory, safe-clearance indication, route arrow or touch target. There is no new asset, control, hit rectangle, simulation, save field, noise, resource, AI or other UI change.

The cue stays visible for selected Quietus during the active dive, including aligned/stationary states. This differs from the critic's provisional misalignment-only suggestion: the smallest candidate keeps a stable heading reference rather than toggling on a route-angle threshold. The corresponding cost is occupancy when route/body already agree; aligned images and movies retain that cost for review. No conditional alternative is claimed tested.

The initial all-owned-craft version was rejected after actual south-facing drone/FIT captures put the large readable mark into the crowded DRONE A / EXTRACTION area, close to the destination ring. `rejected-all-craft/` retains that source, patch, preliminary13/0 geometry check and actual counterexamples. Final drone labels/art are unchanged; no drone gain is claimed.

## Size and occupancy

The existing density-adjusted feedback-font size provides the cue's logical length. Screen length stays fixed as the chart zooms1×–4×; bow placement follows the hull. Light stroke is0.15length, dark outline0.27length, empty bow gap0.55length; open wings span0.72length. Actual rendered fixture metrics:

| Profile | Physical/logical scale | Cue length physical pixels | Approx dp | Light stroke dp | Bow gap dp |
|---|---:|---:|---:|---:|---:|
| Desktop1280×720/95dpi | 1.0 | 14 | 23.58 | 3.54 | 12.97 |
| Cover2520×1080/420dpi, left136 | 1.5 | 33 | 12.57 | 1.89 | 6.91 |
| Inner2184×1968/420dpi | 1.70625 | 32.42 | 12.35 | 1.85 | 6.79 |

Desktop dp is a conversion of fallback monitor density, not a phone target; its actual14px mark is what was inspected. Inner vertical stretch differs slightly from horizontal due integer viewport sizing; table uses horizontal scale. The reference's12–16dp suggestion was a starting point, not an acceptance rule or a48dp touch target.

I inspected actual cover/inner turn, FIT and4× frames. The open shape leaves hull/terrain visible, but its strokes occupy real pixels and can overlay a small patch of stone or cross an aligned route dash. At4× it is small relative to the enlarged hull; at FIT it is more prominent relative to the hull. Those are explicit tradeoffs. It has no screen-edge substitute if the bow is clipped or panned away. It must earn that occupancy in independent review; geometry checks do not prove human glance comprehension or eliminate confusion with an order marker.

`static-verification.json` records all30 matched snapshot hashes, actual size conversions and changed-pixel bounding boxes. Every baseline/challenger state matches; `positive-verification.json` adds three same-state opposite-turn captures. Nine non-applicable selected-drone/pan-away views are byte-for-byte identical screenshots. Main control metrics and other original source are unchanged.

## Matched motion and retained outcomes

Both copies are archived6ab8fb0eb18180d9e4cb2a732c2873552ea9b727. In particular, both contain simulation SHA256 `d1bad2ca17fa28c1f8faa3ce2a7e4d1c91cf5ba2ad79df98c4bcb0d193431641`. “Baseline” here is the reviewed steering baseline, not the old pre-steering basalt-stop build.

`departure.gd` is the unchanged released departure controller. Both versions restore the same baseline-earned Blackwater solo save, issue the same ordinary home route before frame0, and then receive zero tactical commands during16s. Ordinary2× zoom/own-position following pan matches the released controller. The craft turns and leaves the rock in both; the first turn has the opposite angular sign from the emergency, so both signed heading changes are visible. Current-heading cue does not change turn/brake time, world observations or travel.

`emergency.gd` is the unchanged released emergency controller. Both restore the same ordinary Listening Well6.9s save, continue the original route for the first second, then emergency-route west at movie+1s/elapsed7.9s. No EMP is spent; stock remains3. Both clear terrain, are hit, lose at elapsed15.633s/movie+8.733s and enter the real SIGNAL LOST debrief. No further tactical/camera input occurs. The existing fixed2× framing shows terrain, route and legitimately observed hunter; it is still chosen programmatically rather than by a human gesture.

The entire paired observed chronology/commands dictionaries match for each scenario, not only final health. `motion-verification.json` records this. Movies show visible motion/heading and retained loss; they establish no new campaign, survival or steering gain. The no-input departure is an advancing world, with aging contact memories rather than continuously visible enemies. Both movies' camera assistance/framing limits remain the same as their original released controllers. No hidden diagnostic actor position is treated as player knowledge.

## Confirmed failures and targeted checks

- `red.log`: missing selected-heading geometry fails on unchanged baseline before implementation.
- Preliminary all-craft helper checks pass13/0 but actual rendering rejects drone/FIT clutter. Passing geometry was not visual acceptance.
- `narrowing-render-red/`: narrowing first left a selected-drone caller trying to draw an empty polyline. Actual engine ERROR logs/source are retained. The caller now matches Quietus-only applicability and guards empty geometry; final real drone renders are clean/pixel-identical.
- `rejected-post-loss-tick/`: the first emergency movie left a floating bow mark outside the opaque loss panel after Quietus was destroyed. Actual movie/contact sheet/full frame/source freeze are retained. `post-loss-red.log` fails9/1 before the correction; final applicability hides the mark when the dive outcome is concluded. No loss outcome was changed or hidden.
- Final `green.log`:9 meaningful checks/0 failures: heading through both turn directions/zoom, physical bow separation, screen-size invariance, independence from opposite desired route/drift/contact state, read-only simulation snapshot, selected unavailable/drone applicability, no active-dive context and concluded-dive suppression. These check the real geometry used by rendering; they are not a second physics model.
- Final actual capture logs contain no SCRIPT ERROR / ERROR. Targeted checks/rendered fixtures are appropriate for this small presentation change; no broad unchanged simulation/Android suite was repeated. Independent experience review remains required.

The precise mechanical/render failures are retained so the final result is reviewable; they are not presented as baseline game defects. The final cue is suppressed after either won/lost outcome, while the original debrief/loss remains intact. The final emergency debrief frames are byte-identical across versions.

## Relevant original and reference

I read actual immutable v7 `drawSub`415 onward: heading rotates a pointed green hull, a stern/propeller shape and a bright cruise bow lamp. It has no separate chart heading chevron. Production retains its original textured Quietus silhouette; this cue adds an explicit instrument mark rather than replacing art or copying v7's color/physics.

The independent [Door Kickers comparison](../../../reviews/2026-10-19-route-intent-reference-comparison.md) verified the official promotional17.5–27.5s room section, where body/weapon facing fields and remaining dotted route share one local view. I inspected its credited21s analytical frame after reading that review. This candidate addresses local orientation with an original small ship cue, not an infantry facing cone, sensor guarantee, borrowed art or movement rule. No new external-footage review/current store recommendation or shipped-game win is claimed.

## Exact source and reproduction

`source.json` records all139 archived baseline files. `source-freeze.json` verifies baseline unchanged and other138 original files identical between copies. `OWNED_FILES.txt` contains the sole product path; `bow-heading-cue.patch` applies only that isolated presentation file. No shared source, governance, tools, CI, branch, commits or pushes were changed by this worker. Root owns integration/publication.

Both source copies use their own import/userdata caches under ignored `work/bow-heading-cue/`. Full240PNG sequences remain ignored there. Controllers, exact source copy, patch, raw logs, media probes/frame hashes and checksums are retained here. Reproduce focused checks with the existing toolchain:

```sh
TOOLCHAIN_CACHE="$PWD/work/toolchain" GAME_DIR="$PWD/work/bow-heading-cue/challenger/game" XDG_DATA_HOME="$PWD/work/bow-heading-cue/reproduce-userdata" scripts/toolchain/headless.sh --script "$PWD/docs/validation/production/bow-heading-cue/verify_heading.gd"
```

`capture_static.gd -- --folder=<scratch> --profile=desktop|cover|inner` uses the existing density_main fixture for420dpi and the recorded136px left inset on cover. Use1280×720,2520×1080 or2184×1968 actual windows respectively. Movie controllers accept the same original absolute fixture/folder arguments; emergency uses `--take=noemp`. Existing display.sh/Godot fixed15fps/Dummy audio and retained adapted encoder pattern suffice; no shipped tooling change.

Godot4.6.3 Compatibility/OpenGL3, Mesa llvmpipe software renderer, Dummy audio; four16.000s/240frame/15fps silent desktop movies. Blocking capture is sampling, not native/realtime performance certification. Unsupported V-Sync warnings remain. No physical Fold7/Android gesture/latency/thermal, human newcomer comprehension, normal-speed listening or audio-quality acceptance is established. Requested Sol6.1/high, actual backend/cost unknown; no nested workers or premium escalation. User-authorized autonomy supersedes routine skill approval pauses, and prescribed archives provide isolation without branch changes. The checkpoint feeds independent review and the next Gauntlet task; it is not overall termination.
