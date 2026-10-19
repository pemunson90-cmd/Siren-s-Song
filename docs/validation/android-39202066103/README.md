# Native completion checkpoint

[Successful run 39202066103](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39202066103), job `117896952083`, exact source `93b86310d91054feaef437ce659135aaab970b88`. Production audio fix: `cb8c6f9`; Foundry game/content source: `322d23c`. Godot 4.6.3 Compatibility, API 36 x86_64 emulator with KVM and ANGLE software rendering. [Device fingerprint](fingerprint.txt).

[Download the signed APK artifact](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39202066103/artifacts/12164418637). [APK SHA256](sirens-song-debug.apk.sha256): `4be4f056a65def993dca34170c2b02fb8e4342a1adac3baa01abcdecc42dcb4e`. [Certificate SHA256](apk-signature.txt): `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`, unchanged from earlier playtests. Both exact download/signing cache keys restored successfully.

Hosted checks: 88 core and 176 runtime, zero failures. The native strict fatal/engine/script/parse gate passes; independent scan of the downloaded final native log also finds zero matches. [Original deduplicated Godot event lines](godot-events.txt) and [timestamped fixture stages](progress.txt) are retained without rewriting.

Native input verifies cover 2520×1080 and inner 2184×1968 layouts, mission selection/entry, drone/sub selection, route placement, pause/resume, Home/resume, explicit background process death, cold restart and paused archive entry. WindowManager landscape locks hold through live resize. The UIAutomator intro inspection ran; no immersive introduction appeared in this boot, so its conditional acknowledgement branch remains locally tested rather than demonstrated here.

The fresh ordinary-command Shelf Signal sequence then routes Drone A to camera range. Actual engine unpause at 05:03:28.521 and camera readiness at 05:03:58.834 give over 30 seconds of continuous active audio without the former eight-second boundary crash. CAMERA starts while paused, then ordinary resume secures the objective at 05:04:20.911 and wins extraction at 05:04:20.924. Quietus remains at the initial extraction ring. The archive saves `completed=[0] unlocked=1`; a new process restores this at 05:04:29.894 with simulation time 18.27 seconds.

Inspected original Android screenshots:

- [Camera exposure](inner-camera-exposure.png): Signal Spire optical feed, Drone A EXPOSING, pause and controls visible.
- [Successful debrief](inner-mission-completed.png): ARCHIVE RECOVERED, dive 00:18, hull 100%, life support 118% with endurance loadout.
- [Cold-restarted campaign](inner-campaign-restored.png): Shelf Signal RECOVERED and Split Channel AVAILABLE.

No obvious bounds clipping appears in these inspected states. This checkpoint verifies the audio fix and one ordinary native mission completion, not the complete native campaign, every saved field, subjective audio quality, physical Fold7 behavior, performance, thermal behavior, or user acceptance. Desktop and software-emulated timings must not be presented as Samsung performance measurements.
