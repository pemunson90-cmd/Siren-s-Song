# Native touch promotion evidence · 19 October 2026

[Passing run 39205478335](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335), job **117907255561**, exact source **f1ea536636293ca8b9a2744eea865b6bdfe88e2d**. Production runtime is unchanged from **92625acdf55a6e45c55903a7943aef994ba334a7**; prior verified baseline **93b8631** remains retained. This controlled retry adds diagnostics, not a speculative game/backend fix.

## Observed passing scope

- Eight CLI evidence guards, **88 core / 225 runtime checks**, zero failures/errors; signed APK export/install.
- Actual Android **2520×1080 cover / 2184×1968 inner**: +1.4×, −1×, +1.4×, +1.96×; an OS touchscreen swipe pans at unchanged zoom to world center.x **875.1025 / 899.4498**, y480. FIT returns to 1× and (800,480). The navigation sequence produces zero new route/order or pause events. Raw `view-check-*.txt` and events are retained here.
- Both profiles: ordinary selection/route/pause, Home/resume, confirmed background process death, new-process archive restoration and mission entry.
- Fresh ordinary Shelf Signal: Drone A route → camera readiness → CAMERA → objective recorded → extraction won → save → Home/process death → new-process completed-campaign restoration. [Events](godot-events.txt) show active resume **05:44:18.010** through camera readiness **05:44:47.255**, crossing multiple real audio loop boundaries. Win **05:45:11.341**; save `completed=[0] unlocked=1`; new PID 6800 restore **05:45:22.139**. These are host/log timestamps, not phone or real-time simulation performance claims.
- Full strict fatal/Godot/script/parse gate passes; the downloaded final log independently scanned with zero matches using the same expression from `android-smoke.sh`. Raw full logs remain in [native evidence artifact](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335/artifacts/12166016163) (4,896,511 bytes). CI also scans retained intermediate reads; no gate was weakened.

## Actual pixels inspected

[Cover pan](cover-panned.png), [inner pan](inner-panned.png), [camera exposure](inner-camera-exposure.png), [successful debrief](inner-mission-completed.png), [restored campaign](inner-campaign-restored.png) are unmodified Android PNGs. Commands reflow below the inner chart; the camera feed and recovered/unlocked archive are visible. Zoom crops world content; the Signal Spire edge label can clip. Screenshots do not establish physical finger comfort or all-content readability.

## Runtime continuity and signing

The three `runtime-state-*.txt` snapshots preserve the same kernel boot ID **da9312b0-60ce-4314-aaa1-f07b0d3d3ef5**, system_server PID **654**, boot-completed=1, and available window/activity services before and after the final restart. Guest MemAvailable is **1,160,512 / 1,010,524 / 973,204 KiB**. [Pre-restart app memory](app-memory-before-completed-restart.txt): total PSS 167812 KiB, RSS 257156 KiB, swap PSS 236 KiB. These isolated emulator samples establish neither a leak trend nor Fold7 performance.

Both exact toolchain and signing caches restored successfully. [Public certificate](apk-signature.txt) SHA256 **32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c** matches the earlier baseline; private key is not retained here. [APK checksum](sirens-song-debug.apk.sha256): **e3c8fa1b838a1fb561cb118b5e6470c680d344a75c979b9dc6ed456f62c396d6**. [Installable development APK](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39205478335/artifacts/12165339461).

## Limits retained

The [preceding guest/runtime interruption](../android-39204224960/README.md) did not recur, but its initiating cause remains unknown. This pass does not retroactively explain or fix it. Native OS multi-touch pinch, physical Fold7 hinge/cutout/rotation/comfort, subjective audio, device performance/heat and the complete installed-Android campaign remain unverified. Synthetic Godot pinch/cancellation checks are separate evidence. The emulator is API36 x86_64 with ANGLE software rendering, not Samsung firmware/hardware.

Requested audit model: explicit `gpt-6.1-sol`; actual backend/model usage and cost telemetry unavailable. No nested agents.
