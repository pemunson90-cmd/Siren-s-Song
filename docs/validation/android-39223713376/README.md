# Corrected-precondition attempt: scroll still unresolved

Exact source `a7aa65c94610ffdea127533399f9dbf163b2a92e`; game unchanged from `6de9e10`. [Run 39223713376](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39223713376), job 117964805524.

The strict local suites and signed APK build passed. Native install and launch passed. At 08:38:37 UTC the exact accessibility recognizer reported `known Android immersive intro absent`; the first measured cover-menu swipe ran at 08:38:40, followed by `Fresh actual menu metrics missing: cover scroll-0` at 08:39:11. Thus the previous ordering gap was corrected, but the known immersive introduction does not explain this attempt. No fresh post-swipe scroll offset or downstream native gate passed. No app crash is established.

Initial actual Android geometry again reports 56 dp fully exposed mission rows at density 420. That partial observation is not a menu-scrolling, HUD, role, lifecycle or full density pass. Retained excerpts preserve original timestamps and atomic records; artifacts metadata preserves permanent IDs and archive digests. Exact SystemUI XML is included by the existing runtime-evidence artifact upload, but its bytes remain uninspected here.

Direct artifact/pixel/APK access remains pending supported readiness for `sdmntpreastus2.oaiusercontent.com`; no retry or access workaround was attempted. Next: diagnose the actual Android scroll/event path with the production owner before any further native retry. Keep all freshness/offset/geometry gates intact; do not substitute desktop wheel success for OS touch success.
