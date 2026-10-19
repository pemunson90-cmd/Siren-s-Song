# First density native attempt: incomplete

Source `bc95b4de13b3140bcde07e35a30c82a81887b82c`, game `6de9e10`, [run 39222413584](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39222413584), job 117960593053.

The strict local suites and APK build passed. Android installed and launched the APK. At 08:27:58 UTC the first measured cover-menu swipe ran; at 08:28:25 the unchanged freshness gate failed: `Fresh actual menu metrics missing: cover scroll-0`. Subsequent menu, HUD, ordinary completion, role and lifecycle gates were not reached. No app crash is established by this failure.

Actual initial Android metrics report density 420, window 2520×1080 and viewport 1680×720. Fully exposed mission rows have 98 logical-pixel hit height: 147 physical pixels / 2.625 pixels per dp = 56 dp. This is initial-menu evidence only. Clipped mission 4 is reported honestly at 39 logical pixels; it is not counted as a full target.

The new first-input menu path bypassed the existing SystemUI introduction check in `locate_target`. This ordering gap is confirmed in source. Whether an overlay actually intercepted this failed swipe remains unverified: artifact byte/pixel access is still blocked at `sdmntpreastus2.oaiusercontent.com`. No signed URL is retained. The correction runs the same exact accessibility-based recognizer before menu input and logs absent/present/dismissed outcomes; no blind dismissal, game change or relaxed scroll gate is used.

`native-excerpt.log` retains original job lines, including actual Android metrics. `artifacts.json` retains permanent artifact IDs, archive digests and links, not direct APK byte verification. Next: one same-game corrected-precondition native run with all gates intact. Retrieve these existing artifacts only after supported host readiness changes; do not rerun CI for download access.
