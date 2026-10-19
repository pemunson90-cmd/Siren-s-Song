# Touch challenger regression gate — 19 October 2026

**Result: no consequential newly broken behavior reproduced in this bounded review.** Candidate `92625ac` preserves the tested tactical command behavior of verified baseline `93b8631` while adding useful presentation zoom/pan and a clearer primary-order layout. This result supports continuing the challenger assessment; it does not establish Android gesture behavior, human comfort, user acceptance or completion of the persistent Gauntlet. Keep the verified baseline until the separate native assessment settles.

Requested reviewer routing: `gpt-6.1-sol`, high reasoning, fresh context. Actual backend identity, tokens and cost are unavailable. No nested agents, code/asset changes, commits, pushes or player-save writes were made. The only repository write by this reviewer is this report. Temporary probes and isolated save/artifact directories are under `/tmp`.

## Evidence inspected before builder explanation

- Actual candidate `docs/validation/production/touch/{cover-fit,cover-zoom,inner-fit,inner-zoom,inner-advanced}.png`.
- Actual `touch/navigation.mp4` frames extracted at 0.7, 3.0, 5.0 and 6.7 seconds: local zoom, pan, restored overview, and expanded/collapsed orders. This is rendered game output driven by synthetic Godot events, not OS touch footage.
- Baseline `production/foundry/cradle.png` and `production/foundry/inner-response.png`, plus native `android-39202066103` camera-exposure, mission-completed and campaign-restored images.
- Selected factory-approach reference, governing authority/policy/continuation/baseline documents, exact baseline-to-candidate diff, `main.gd`, `chart_camera.gd`, `input/map_gesture.gd`, `ocean_view.gd`, and the touch/interface/runtime scenarios. Simulation, campaign and audio source diffs are empty.

The candidate fit view retains the factory approach and both observed threats. Local zoom makes craft and nearby geometry materially easier to inspect. The fixed threat rows separate the target/countdown text that crowded the baseline cradle. Cover and unfolded captures retain immediate pause, unit selection, camera and EXTRACT access; the unfolded advanced capture exposes the secondary controls. These visible gains do not prove finger comfort or discoverability.

## Checks that survived

Independently executed:

```sh
XDG_DATA_HOME=/tmp/sirens-hunter-xdg \
ARTIFACT_DIR=/tmp/sirens-hunter-checks scripts/toolchain/test.sh
```

Observed exit 0: **8 parser checks, 88 core checks and 225 runtime checks, zero failures or script errors**. Full output: `/tmp/sirens-hunter-full-tests.log`. The actual-pointer campaign scenarios still progress through all six missions. Existing focused scenarios cover anchored transforms, queued touch/mouse duplication, pan/pinch, outside release, application suspension, layout cancellation, third-finger release, OS cancellation and HUD second-finger cancellation. Counts describe coverage, not friendliness.

Additional temporary probe `/tmp/sirens-touch-hunter.gd` passed **52 candidate assertions**; its shared scenarios passed **18 baseline assertions** against a clean `git archive 93b8631 game` under `/tmp/sirens-hunter-baseline`. No shared save directory was used. Logs: `/tmp/sirens-touch-hunter-{candidate2,baseline2}.log`. Probe SHA-256: `f7d036dce183e84b0bf3b8b11ded231ff221b05bee7989d1c6263a70711b7f52`.

At cover `2520×1080` and unfolded `2184×1968` window sizes, the extra probes checked:

- Queue a route, add a contact condition, navigate/clamp/FIT: the queue, endpoint and condition remain intact. Start a chart touch, deliver the HUD touch and explicit GUI mouse stream to EXTRACT, then lift the chart finger: emergency replacement clears the queue/condition, selects cruise thrust and retains the extraction endpoint.
- Establish an ordinary Shelf Signal drone camera exposure, select Quietus through pointer input, then zoom/pan: the paused simulation snapshot and independent exposure remain unchanged, and the drone optical inset disappears for the sub. A sub emergency preserves the drone exposure. Selected-drone loss restores Quietus and clears stale queue mode.
- Issue the intended endpoint `(320,800)` with root offsets `(0,0)` and `(60,22)`, at fit/baseline and candidate anchored zoom. Candidate non-emulated synthetic mouse queues once; a real-touch-shaped event sequence followed by emulated mouse events adds exactly one further waypoint.
- Drag across the plus button without clicking it or issuing an order. Change the actual root window size while a touch is pending: no route or stuck gesture remains. Verify world/screen inverse agreement through 1×, 1.4×, 2.8× and 4× zoom, pan and both viewport aspects.

These are synthetic viewport/command observations. The explicit emulated GUI stream in the emergency probe is not a claim that a second physical finger activates a native Button.

## Rejected false positive and limits

The first exploratory harness produced four failed button assertions in **both** builds. It injected raw `ScreenTouch` events with `Viewport.push_input` and expected ordinary Godot Buttons to receive a synthesized mouse stream. Neither build logged the expected GUI orders. Keeping raw chart events and explicitly supplying the GUI mouse events made the comparison pass. This establishes a probe-boundary limitation rather than a newly caused game regression; no source fix is recommended from those failures. Initial logs remain at `/tmp/sirens-touch-hunter-{candidate,baseline}.log`.

The extra disclosure tap for survey/decoy/conditions/STOP-PASS and cropped distant content while zoomed are explicit challenger tradeoffs. FIT restores the overview. Small overview craft, optical-inset occlusion and remaining edge-label cropping are inherited weaknesses or further usability opportunities, not confirmed consequential regressions from this comparison. No unrelated feature addition or speculative fix is requested by this gate.

Native baseline evidence does not certify this candidate. Candidate native run `39204224960` is being assessed separately; this reviewer did not poll it or claim its outcome. OS plus/minus/swipe/FIT, real OS pinch, physical Fold7 safe areas/folding/finger comfort, sustained device performance and human listening remain distinct evidence. The synthetic root-offset check does not certify Samsung safe-area behavior.

**Smallest warranted fix: none identified by this gate.** Continue the native assessment and subsequent bounded experience work under the user-terminated Gauntlet mandate.
