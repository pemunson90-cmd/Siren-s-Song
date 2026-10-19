# FIT label layout

Desktop FIT now stays on one line at the existing font size. Its measured label plus normal theme padding needs 50px; the previous fixed 48px width wrapped it to 72px tall. The zoom row expands 2px leftward, keeping its right edge, gaps and 48px height. Both 420dpi fixtures retain their existing geometry. No chart area, zoom/pan behavior, commands, simulation or save changes.

Base: e762eeb2feb0b021329fecf63a2b1b76164c32a2. Only product file changed: `game/src/main.gd`. Main SHA256 before `fd5d9273199473c34b888ed5305371c151d1fa7b675afdb61f6aafb01ea66334`, after `9f9ce4041ea33b266b9b7ff169fd6d4594bfbbb64145c5aac46af5670266b018`. Root is the single integration reviewer; source review accepted before this checkpoint. Requested routing Sol6.1/high; backend/effort/cost telemetry unknown. Current 7febd8d boundary instructions retain the e286ade compact contract. Skills were unavailable; no nested workers.

Focused command: `TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/fit_label_scenarios.gd`. Isolated userdata was set under this worktree's ignored `work/fit-label-layout/userdata`.

- [RED](red.log): 60 checks/2 failures, engine exit 1. Desktop FIT fails single-line width and row height; remaining geometry and actual FIT-click checks pass.
- [GREEN](green.log): 60 checks/0 failures, engine exit 0. Tests measure text with the actual engine font/style, preserve font/touch minima, bound the row within the chart/safe area, detect overlaps, and click FIT after zoom/pan while comparing the entire paused simulation snapshot.
- Actual Compatibility/llvmpipe/Dummy-audio renders use the same test with `--capture-dir=<absolute-directory>`, desktop 1280×720/95dpi, cover 2520×1080/420dpi with recorded 136px left inset, inner 2184×1968/420dpi. [Render RED](render-red.log) exits 1 as expected; [render GREEN](render-green.log) exits 0. No engine errors; llvmpipe reports unsupported V-Sync. Baseline source was temporarily restored from the pinned commit in this isolated worktree for the first render, then the candidate restored with an EXIT trap. No other worktree changed.

| Profile | Before | After |
| --- | --- | --- |
| Desktop | [FI/T,48×72](baseline/desktop.png) | [FIT,50×48](challenger/desktop.png) |
| Cover | [98×98 logical](baseline/cover.png) | [unchanged](challenger/cover.png) |
| Inner | [87×87 logical](baseline/inner.png) | [unchanged](challenger/inner.png) |

Inspected all views. Desktop changed pixels are bounded to the zoom row (716,120)–(870,192). Cover pair is pixel-identical. Inner FIT crops are pixel-identical; faint animated water lines differ with real rendering time. These are desktop density fixtures, not new Android/physical-device acceptance. The first multi-profile fixture carried cover offsets into inner; creating a fresh scene per profile corrected the fixture before the retained paired renders. A stale Xorg also caused an intermediate setup failure; the final pair shares one live server. No gameplay fix was inferred from either setup issue.

Original v7's canvas camera does not implement this zoom/FIT row; this change preserves production's accepted zoom controls. No assets added. No videos, full suite or APK were warranted for this layout-only correction.

Next concrete opportunity: at the same small desktop profile, unchanged MORE ORDERS expands 64px into the DRONE B row and some other two-line actions exceed their 48px row. Address row sizing independently, retaining font/touch minima and chart controls; do not fold it into this reviewed FIT delta.
