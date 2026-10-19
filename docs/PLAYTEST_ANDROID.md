# Galaxy Z Fold7 playtest

**Cover-screen Android rendering is verified; full gameplay/lifecycle validation is pending.** The early [c96c3bf playtest APK](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39197089036/artifacts/12162671131) renders operations/briefing but logs a menu-lifecycle error on first mission entry, and its native smoke did not finish. It is available for targeted hands-on feedback with those known gaps. This is a development playtest, not a release-readiness claim.

## Install or update

1. Open [Android validation runs for the production branch](https://github.com/pemunson90-cmd/Siren-s-Song/actions/workflows/android-validation.yml?query=branch%3Agauntlet%2Fproduction). Use the validated run identified in [WORKBENCH.md](WORKBENCH.md), rather than automatically choosing the newest artifact.
2. Download its **sirens-song-debug-apk** artifact. Sign into GitHub if required. Extract the ZIP in Samsung My Files; it contains `sirens-song-debug.apk`, its checksum, and public signing-certificate evidence.
3. Tap the APK in My Files. If Android asks, allow My Files to install this application, then finish installation. Launch **Siren's Song** in landscape.
4. For updates, compare the **certificate SHA-256 digest** line in `apk-signature.txt` with the previous build's certificate. The same certificate permits an update that retains local data. A cache miss can create a different development key; local builds and CI builds also use different keys unless explicitly coordinated. If Android rejects an update, report the message before uninstalling: uninstalling removes local campaign saves.

The private signing key is not included. These APKs use development signing; store/release signing remains separate.

## Three-minute check after installation

1. **Cover screen, landscape.** Choose **01 Shelf Signal**, then **ENTER WATER · START PAUSED**. Check that the title, status, map, and buttons fit around the camera cutout. While paused, plot a route and watch that oxygen, hull, and simulation time remain still.
2. **Queue and emergency replacement.** Select **DRONE A**, tap open water, tap **REPLACE** to turn **+ QUEUE ON**, then tap another open-water point. Optionally tap **HOLD**. Select **QUIETUS**: queue mode should clear, and the next water tap should replace Quietus's route. Tap **HOLD**, then **EXTRACT**. This emergency order should replace the route, clear the hold/queue state, and return Quietus toward extraction. Select Quietus first: EXTRACT acts on the selected craft.
3. **Unfold and rotate.** Unfold while the mission remains paused. Commands should reflow below the map and remain tappable. Rotate the phone and return to landscape; check that no controls or status text disappear. Fold back to the cover display and check the same route/state.
4. **Resume and restore.** Resume for a few seconds, then pause. Press Home, wait briefly, and return through Recents: the dive should be paused with its orders intact. Close the app from Recents, reopen it, and choose **RESUME ACTIVE MISSION**. Check that the same mission, craft positions, routes, and resources return. This manual check complements the emulator's explicit process-kill test.

After these checks, Shelf Signal's first objective is to send a drone near the gold **SIGNAL SPIRE**, pause, use **CAMERA**, then resume for the exposure. Quietus can remain at extraction for this introductory mission. Switching attention to Quietus should leave the drone's exposure task understandable.

## Useful feedback

Send the build/run identifier, whether the phone was folded or unfolded, and the last few actions before a problem. A screenshot is especially useful for clipping or cutout issues. Note any lost orders/progress, unclear pause/camera state, or moment that required frantic tapping. Also identify the next part of the experience you most want improved.

Emulator resizing does not reproduce Samsung firmware, a physical hinge, device audio, heat, or touch ergonomics. Fold7 hands-on observations remain a separate source of evidence.
