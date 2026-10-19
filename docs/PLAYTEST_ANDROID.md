# Galaxy Z Fold7 playtest

[Current checkpoint, screenshots and progress](PHONE_DASHBOARD.md)

**Previously inspected development fallback: [f1ea536 APK](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335/artifacts/12165339461), runtime92625ac.** Actual +/−/FIT and single-pointer drag pan pass on cover/unfolded landscape without accidental orders or pause changes. Sustained Android audio, ordinary Shelf Signal camera/objective/extraction completion and campaign save/kill/restart restoration pass. The earlier unexplained Android-runtime interruption did not recur; its cause remains unknown. Physical Fold7 behavior, Android OS pinch, the complete native campaign, subjective audio quality and performance remain separate checks. This is a development playtest, not release readiness. [Raw native evidence](validation/android-39205478335/README.md).

**Latest tested A candidate: [6388113 APK](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39216492480/artifacts/12169589920).** Its full existing native gate and one fixture-assisted Well hunter route/decoy/search/return pass, including restoration of the genuine Shelf campaign archive. Direct APK-byte and screenshot inspection is pending blocked artifact delivery. The build also includes earlier finale-experiment ancestry; native finale/full-campaign validation is still open. This is a bounded development checkpoint, not release readiness or a new request to test. [Exact evidence and limits](validation/android-39216492480/README.md).

The candidate build log reports APK SHA-256 `c7efabdd5a01acbb7c336ddeaadb12cac2309645522c27ec8fce52589cc31993` and the same development certificate as the fallback. Those are CI build/signature observations; local recomputation from candidate APK bytes remains pending. Normal updates preserve legacy active mission content; start a fresh dive to receive new role assignments.

**Density UI challenger, full native gate incomplete:** source **744ad3e** enlarges controls/text, keeps briefing and Settings BACK visible, and preserves route intent across command pages. Actual cover Operations/Settings swipes, unchanged audio settings, sticky BACK and zoom/pan/FIT pass, but truncated diagnostic JSON blocks the HUD geometry gate and all later native assertions. [Exact partial result](validation/android-39227185627/README.md) · [Local screenshots/clip and review](validation/production/density/README.md). The linked 6388113 APK does **not** include these later UI changes. Complete metric transport, downstream gates, direct artifact/pixel inspection and physical Fold7 comfort remain open.

## Install or update

1. Open [Android validation runs for the production branch](https://github.com/pemunson90-cmd/Siren-s-Song/actions/workflows/android-validation.yml?query=branch%3Agauntlet%2Fproduction). Use the validated run identified in [WORKBENCH.md](WORKBENCH.md), rather than automatically choosing the newest artifact.
2. Download its **sirens-song-debug-apk** artifact. Sign into GitHub if required. Extract the ZIP in Samsung My Files; it contains `sirens-song-debug.apk`, its checksum, and public signing-certificate evidence.
3. Tap the APK in My Files. If Android asks, allow My Files to install this application, then finish installation. Launch **Siren's Song** in landscape.
4. For updates, compare the **certificate SHA-256 digest** line in `apk-signature.txt` with the previous build's certificate. The same certificate permits an update that retains local data. A cache miss can create a different development key; local builds and CI builds also use different keys unless explicitly coordinated. If Android rejects an update, report the message before uninstalling: uninstalling removes local campaign saves.

The private signing key is not included. These APKs use development signing; store/release signing remains separate.

The validated f1ea536 APK SHA-256 is `e3c8fa1b838a1fb561cb118b5e6470c680d344a75c979b9dc6ed456f62c396d6`. Its certificate SHA-256 is `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`, matching earlier playtests. Cache restoration and this certificate match were both observed. Future cache eviction can still change development signing identity.

## Three-minute check after installation

1. **Cover screen, landscape.** Choose **01 Shelf Signal**, then **ENTER WATER · START PAUSED**. Check that the title, status, map, and buttons fit around the camera cutout. While paused, use **+ / −**, drag the chart, then tap **FIT**. Navigation should preserve existing routes and pause. A short water tap plots a route; oxygen, hull and simulation time should remain still while paused. Pinch is implemented and covered by synthetic runtime tests, but actual Android OS multi-touch remains unverified.
2. **Queue and emergency replacement.** Select **DRONE A**, tap open water, tap **REPLACE** to turn **+ QUEUE ON**, then tap another open-water point. Optionally tap **HOLD**. Secondary conditional controls are behind **MORE ORDERS**. Select **QUIETUS**: queue mode should clear, and the next water tap should replace Quietus's route. Tap **HOLD**, then **EXTRACT**. This emergency order should replace the route, clear the hold/queue state, and return Quietus toward extraction. Select Quietus first: EXTRACT acts on the selected craft.
3. **Unfold and rotate.** Unfold while the mission remains paused. Commands should reflow below the map and remain tappable. Rotate the phone and return to landscape; check that no controls or status text disappear. Fold back to the cover display and check the same route/state.
4. **Resume and restore.** Resume for a few seconds, then pause. Press Home, wait briefly, and return through Recents: the dive should be paused with its orders intact. Close the app from Recents, reopen it, and choose **RESUME ACTIVE MISSION**. Check that the same mission, craft positions, routes, and resources return. This manual check complements the emulator's explicit process-kill test.

After these checks, Shelf Signal's first objective is to send a drone near the gold **SIGNAL SPIRE**, pause, use **CAMERA**, then resume for the exposure. Quietus can remain at extraction for this introductory mission. Switching attention to Quietus should leave the drone's exposure task understandable.

## Useful feedback

Send the build/run identifier, whether the phone was folded or unfolded, and the last few actions before a problem. A screenshot is especially useful for clipping or cutout issues. Note any lost orders/progress, unclear pause/camera state, or moment that required frantic tapping. Also identify the next part of the experience you most want improved.

Emulator resizing does not reproduce Samsung firmware, a physical hinge, device audio, heat, or touch ergonomics. Fold7 hands-on observations remain a separate source of evidence.
