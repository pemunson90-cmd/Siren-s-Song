# Siren's Song · current checkpoint

**[Download the current Android build](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335/artifacts/12165339461)** · [Install/update guide](PLAYTEST_ANDROID.md)

Promoted development baseline **f1ea536**, runtime **92625ac**, verified 19 October 2026. Native zoom, drag pan and FIT pass on cover and unfolded landscape layouts without accidental orders or pause changes. Ordinary first-mission camera/extraction completion and saved campaign restoration also pass. Physical Fold7 and complete native campaign validation remain open.

## What improved

- **Touch chart navigation:** 1–4× zoom, +/−/FIT and drag pan help inspect small craft and routes. Short single-touch release plots a route; navigation gestures preserve order intent and tactical pause.
- **Clearer command priorities:** threat information has reserved space; MORE ORDERS discloses secondary commands. The extra disclosure tap is an accepted tradeoff, with physical comfort still unverified.
- **Cold Foundry has a distinct encounter:** industrial terrain, two different optical discoveries, an explained carrier response and recoverable extraction. Its independent review supports that bounded gain.
- **Native audio and progress:** valid PCM loop endpoints survive sustained Android travel, and the recovered/unlocked campaign survives a cold process restart. The development certificate matches earlier builds for compatible updates.

## See actual Android output

![Cover chart after native zoom and swipe](validation/android-39205478335/cover-panned.png)

[Unfolded pan](validation/android-39205478335/inner-panned.png) · [Optical camera feed](validation/android-39205478335/inner-camera-exposure.png) · [Successful debrief](validation/android-39205478335/inner-mission-completed.png) · [Restarted campaign archive](validation/android-39205478335/inner-campaign-restored.png)

[Desktop navigation clip](validation/production/touch/navigation.mp4) · [Unfolded secondary controls](validation/production/touch/inner-advanced.png). The clip uses synthetic Godot input; it does not establish Android OS pinch or physical finger comfort.

Cold Foundry: [desktop encounter clip with mixed audio](validation/production/foundry/response-live.mp4) · [furnace discovery](validation/production/foundry/furnace.png) · [departure record](validation/production/foundry/archive_cradle.png). These are desktop evidence, not native Foundry completion or Samsung screenshots.

## What the checkpoint proves

[Run 39205478335](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335) passed **8 parser guards + 88 core + 225 runtime checks**, strict native error checks, numerical OS +/−/swipe/FIT assertions on both profiles, input/orders/pause, background/resume, process death/restoration, ordinary Shelf Signal completion and completed-campaign cold restoration. [Raw evidence, continuity, signing and hash](validation/android-39205478335/README.md).

The [fresh independent regression hunt](reviews/2026-10-19-touch-regressions.md) reproduced no consequential new regression. The [whole-game critic](reviews/2026-10-19-whole-game-review.md) inspected broader campaign experience and identified the next opportunities. [Previous verified baseline 93b8631](validation/android-39202066103/README.md) remains retained. Test counts and emulator timings do not establish phone performance or experience quality.

## Experiments kept visible

- The [first touch run](validation/android-39204224960/README.md) completed gestures and the mission but lost Android services at final restart. The controlled same-game retry passed; the prior initiating cause remains unknown.
- Earlier exposed/rushed Foundry strategies failed; a staged finite-defense route succeeded. [Comparisons and failed attempts](validation/production/foundry/README.md).
- A narrow authored passage could not fit the navigation grid and was widened; movement and sight share the factory footprint.
- The Foundry critic found a scripted decoy redundant in its controlled comparison. We retain that result without claiming a demonstrated diversion benefit. [Review](reviews/2026-10-19-cold-foundry-critique.md).

## Weaknesses and next work

**New confirmed baseline defect: eight of thirteen Sirens stall at unreachable patrol goals.** An independent 600-second-per-mission probe reproduces this without player input. [External audit and independent verification](reviews/external-2026-10-19/README.md). The lead is prioritizing liveness and fresh strategy comparisons before further balance promotion. Existing native touch/completion evidence remains valid for its exact tested build; old balance outcomes describe the stalled-patrol world.

The retained finale experiment targets **distinctive finale evidence and meaningful Quietus return/attention**, preserving viable remote and fallback choices. [Cycle brief](design/FINALE_CYCLE.md). This is proposed work, not a new verified feature. The whole-game review also identifies contextual camera-readiness/loadout teaching as useful.

Zoom can crop edge labels; some encounter labels overlap. MORE ORDERS adds a tap. Logical button dimensions do not prove physical comfort. [Computed native target sizes](reviews/external-2026-10-19/target-sizing.md) are approximately 4.3 mm cover / 5.7 mm inner for the smaller controls using nominal Samsung specs; responsive sizing needs correction and physical verification. Physical Fold7 hinge/cutout/rotation, OS multi-touch pinch, real device performance/heat, subjective audio, newcomer comprehension and all six missions on installed Android remain open.

## Follow the work

[Workbench](WORKBENCH.md) · [Continuation](CONTINUATION.md) · [Baseline and experiments](BASELINE_AND_EXPERIMENTS.md) · [Source authority](SOURCE_AUTHORITY.md) · [Model/usage record](MODEL_USAGE.md)

The Gauntlet continues until the user chooses to stop. Explore freely; this page is a reference, not a recurring feedback or approval gate.
