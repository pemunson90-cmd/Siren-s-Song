# Order rows respect their labels

Base 641ebd4ee6272523e3a8cf56972f569b9d534921. Product change: `main.gd` layout only, SHA256 `687e0ddf2fac169aa122d8da285fffd5a5e2183542fbf918db21c697da77f33b`. Root is the sole integration reviewer; awaiting final committed-source review. Requested Sol6.1/high, backend/effort/cost telemetry unknown. Current 7feb policy uses focused verification; no broad suite or APK for this change.

Fixed planning used 48px rows although Godot actually required 64px for MORE/BACK ORDERS, 56px for unit labels and 60px for two-line tools at desktop 1280×720/95dpi. Rows now use actual Button minima at their assigned widths/fonts. Both pages reserve the same order-row height. A coalesced minimum-size notification checks whether row heights changed before relayout. Stable refresh preserves active chart drags without repeated layout reports; real reflow cancels a drag only if chart bounds change. Direct window/layout calls keep their previous cancellation behavior.

[RED](red.log): 170 checks/44 failures, exit 1. [GREEN](green.log): 170/0, exit 0. Five profiles (desktop, 420dpi cover with 136px recorded inset, 420dpi inner, 1024×768/95dpi, 1440×900/95dpi), seven task/stock states, both order pages. Actual MORE→DRONE B→BACK clicks are compared with the whole expected Simulation snapshot; drag/release produces no order. Dynamic task cases are presentation fixtures, not earned mission outcomes. Affected existing FIT checks pass 60/0, [log](fit-green.log).

Run with isolated userdata: `TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/headless.sh --script res://tests/order_row_scenarios.gd`. Godot 4.6.3 Compatibility/llvmpipe/Dummy-audio actual renders use the same driver plus `--capture-dir=<absolute-directory>`: [render RED](render-red.log), [render GREEN](render-green.log), 34/0 final render checks. Exact base main was temporarily restored in this isolated worktree for the paired baseline, then candidate restored with an EXIT trap. No other worktree changed. No engine errors; software GL reports unsupported V-Sync.

| Actual view | Before | After |
| --- | --- | --- |
| Desktop primary | [overlaps](baseline/desktop.png) | [separate rows](challenger/desktop.png) |
| Cover primary | [normal](baseline/cover.png) | [same normal geometry](challenger/cover.png) |
| Inner primary | [normal](baseline/inner.png) | [same normal geometry](challenger/inner.png) |
| Cover EXPOSING fixture | [unit spills into SONAR](baseline/cover-exposing.png) | [row contains status](challenger/cover-exposing.png) |

Actual desktop pixels are inspected: unchanged type, separated actions, full controls, unchanged chart rectangle. Normal cover/inner row geometry stays unchanged. The cover EXPOSING fixture explicitly sets the paused unit task to inspect real three-line text; it does not claim legitimate receiver reception at that pose. The word still wraps as EXPOSIN/G, now contained; no clipping or smaller type hides it. Extra control height is the cost: narrow desktop layouts give up 48 logical pixels of chart height; wide desktop uses previously empty side-panel space. Original v7 has no production order-row layout; this preserves the accepted touch controls and all simulation/command/save behavior. No new assets or UI system.

Next opportunity: assess the long EXPOSING task wording at cover width, or advance higher-value mission/sensory work; do not treat this bounded layout checkpoint as overall program completion.
