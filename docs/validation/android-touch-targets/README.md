# Native touch-target gate · integration contract

Prepared against Godot **4.6.3.stable.official.7d41c59c4**. This measures actual hit geometry at configured Android density. **48 dp is an accessibility recommendation, not an enforced physical minimum.** No panel-ppi/mm estimate, synthetic gesture, or emulator result certifies Fold7 comfort.

## Exact Android density API

Official `4.6.3-stable` source follows `DisplayServerAndroid::screen_get_dpi()` → JNI `get_screen_dpi()` → Java `getScreenDPI()`, returning `Resources.getDisplayMetrics().densityDpi`, not xdpi/ydpi. Use `DisplayServer.screen_get_dpi() / 160.0` for dp-to-physical-pixel conversion on this backend. `screen_get_scale()` calls a bucketed density function and additionally clamps it to screen-size ratios; it is unsuitable for exact dp. At density 420 its bucket is 2.0 rather than the exact 2.625.

[Official URLs/full-source hashes](official-source-provenance.json), [Java excerpt](GodotIO.java.excerpt.txt), [JNI excerpt](java_godot_io_wrapper.cpp.excerpt.txt), [C++ excerpt](display_server_android.cpp.excerpt.txt). These are source semantics, not a claim that the pending game metrics have run on Android.

## Agreed game-owned emission

After settled layout or a chart transform, emit one atomic line `SS_UI_METRICS <JSON>` with:

- `schema:1`, `screen`: actual internal screen name; mission `orders_page:"primary"|"secondary"` must match the explicitly requested page.
- `viewport:[width,height]`: precise full-window logical floats, including safe-area offsets; not the inset root Control size and not rounded target-marker coordinates. Godot legitimately reports integer-valued floats such as 1280×1153 for the inner viewport; never substitute a fabricated fractional height to make axis scales equal.
- `window:[width,height]`: physical app-window pixels; must match the adb screenshot dimensions for this fullscreen suite.
- `safe_rect:[x,y,width,height]`: physical safe region clipped to the app window. No nominal notch assumption.
- `density_dpi`: raw `DisplayServer.screen_get_dpi()`; `density_source:"android_display_metrics_density_dpi"` on Android. Desktop diagnostics must use a distinct honest source.
- `chart_rect:[x,y,width,height]`: full-window logical chart rect on mission screens; null on screens without a chart.
- `controls`: every currently visible interactive button/slider, each with unique `action`, full-window logical `visual_rect` and **actual effective** `hit_rect`, plus optional boolean `clipped` (default false). Actual geometry means post-theme size and input clipping/expansion, not requested minimum size. Both arrays are `[x,y,width,height]`.

For scroll menus, report partially exposed rows as `clipped:true` with the actual hit intersection. The gate measures/reports these rows but exempts them from size only when the hit region is genuinely reduced within the visual rectangle, the screen is not mission, and the action is not required/sticky. Main HUD, zoom and required/sticky controls must be fully exposed and meet the recommendation. Scroll/chart container surfaces are separate from child controls because their containment overlaps are intentional; this button/slider overlap gate does not claim to validate all scroll/gesture hit testing.

The production lead owns emission and UI layout. Tooling owns parsing, native capture and evidence. No game code was edited for this preparation.

## Executable check

```sh
python3 scripts/toolchain/android-ui-metrics.py \
  artifacts/android-smoke/ui-metrics-cover.txt \
  artifacts/android-smoke/cover-touch-targets.png \
  --density artifacts/android-smoke/density-cover.txt --screen mission
```

The log must contain a complete new snapshot after the last `SS_SCREEN`, `SS_MISSION_SELECT` or `SS_VIEW` boundary. The checker uses the latest complete line, rejects malformed/stale/mismatched evidence, verifies the exact current Godot floor-before-stretch project model and actual PNG size, using separate X/Y scales, and compares game density against independent raw `adb shell wm density` output (override takes precedence over physical density). It reports hit rectangles in logical and native pixels, both dimensions in dp, chart dp area, and actionable failures. Overlapping button hit regions, unsafe bounds, missing required controls or either unexempt hit dimension below 48 dp fail.

The default primary-page required mission actions are `pause,sub,droneA,droneB,ping,camera,silent,queue,hold,emp,home,menu,more_orders,zoom_out,zoom_in,fit`. If a future interface intentionally changes disclosure/pagination, coordinate an explicit action-visibility contract before changing this list; do not omit inconvenient controls silently.

Other screens use their actual name and explicit sticky action list, for example `--screen settings --required-actions music,effects,mute,back`. `--orders-page secondary` selects the explicit secondary set: `pause,sub,droneA,droneB,zoom_out,zoom_in,fit,more_orders,camera,emp,home,recon,decoy,contact_hold,wait_drone,waypoint_mode`. A primary/secondary snapshot mismatch fails; no size, bounds or overlap rule is relaxed.

Those example identifiers must match the final runtime contract; they are not yet game implementations. An explicit `--required-actions ''` measures a scroll menu with no designated sticky action; it still validates every reported nonclipped control. Settings/sliders, briefing, debrief, ending, evidence and modal scope require actual captures and agreed actions before any whole-interface claim. The prepared automatic hook measures the primary HUD, taps MORE to require fresh secondary targets, measures secondary controls, then returns to primary before the unchanged route/completion checks. Settings, scroll menus and modal/end screens remain supported manual measurements pending actual runtime action contracts and captures.

## One-run integration and current status

`VERIFY_TOUCH_TARGETS=1 scripts/toolchain/android-smoke.sh` adds the gate after real zoom/swipe/FIT on **both existing profiles and primary/secondary command pages**, using the same APK/emulator boot. It retains `density-*.txt`, atomic logs, JSON reports, failure stderr and actual screenshots. It does not replace or weaken ordinary input, zero-accidental-order, lifecycle, sustained-audio, Shelf Signal completion, campaign restore or strict error checks. Workflow artifact paths include this evidence.

**The prepared next workflow enables the hook only with the matching density candidate.** The previously tested `6388113` runtime did not have this gate; the new source still requires final combined local-suite/critic checks before exact coordinated publication and an actual hosted run. No native target-size pass is claimed by local parser tests. Later distinct mission coverage can share that run once its entry state/hooks are agreed; no additional six-job matrix is planned.

Local verification: 23 real CLI cases cover the actual integer-quantized inner transform, rejection of fabricated fractional viewports, the baseline 48-logical undersize, effective density override, source mismatch, stale/screen/page mismatch, secondary action completeness, a required positive mission chart, missing actions, overlap, safe containment, actual hit versus visual size, clipped menu exemptions and invalid density/geometry. Initial RED was followed by GREEN; adding source/screen provenance guards separately reproduced two false passes before correction. Existing 8 navigation-parser checks also pass. Synthetic fixture PNG headers are not real screenshots.

## Responsive fit constraints for the builder

At the fixture's independently observed density 420, full cover **2520×1080** is **960×411.43 dp**; inner **2184×1968** is **832×749.71 dp**. Safe insets further reduce usable area. Current canvas transforms require about **84 logical cover / 73.820 logical inner** for a 48 dp hit height, not 48 logical. Calculate this from actual window/viewport/density, not a device name or nominal ppi.

Seven simultaneous control rows at 48 dp consume 336 dp **before** gaps, headers and status. Six 8 dp gaps add 48 dp, leaving only about 27 dp in the full cover height for everything else. The old two-column sidebar cannot simply be enlarged without a responsive disclosure/pagination/scroll or composition decision. A three-way unit row also needs at least 144 dp width before gaps. The inner viewport has more vertical room but less horizontal room; chart area must remain positive and meaningful rather than being squeezed out to satisfy button dimensions. The checker reports residual chart area and bounds, without inventing a minimum comfortable map size.

Physical Fold7 density/display settings, OS pinch, reachability, rotation/fold transitions and subjective comfort still need real-device evidence. Requested tooling model: explicit `gpt-6.1-sol`; actual backend/usage/cost telemetry unavailable. No nested agents, push or CI trigger.

## Prepared ordinary OS menu path

The density-gated smoke now additionally prepares Settings/BACK coverage on the same cover/inner boot, before the existing mission input sequence. `android-menu.py` ignores `SS_TARGET` for menu reachability: it requires a fresh atomic metrics snapshot matched to PNG/window, effective OS density, the unchanged hit-size/safe/nonoverlap gates, actual clipped hit rectangles, plus `scroll_rect` and `scroll_vertical`. The scroll rectangle is the clipped full-window-logical ScrollContainer **body**, excluding the sticky footer. The game emits fresh metrics after scrollbar movement settles; a prior-input metrics-count boundary prevents accepting the old snapshot.

For an omitted or clipped Settings row, real `adb shell input swipe` runs inside that measured body (at most eight attempts), and each attempt must advance the actual offset. Only a fully exposed Settings hit center is tapped. The Settings snapshot must expose a full-size sticky BACK hit region; its measured center is tapped, then fresh operations metrics and unchanged mission/order/pause event counts are required. If Settings fits initially, the report explicitly records zero scroll gestures instead of claiming a scroll demonstration. No volume slider or mute interaction is fabricated. Partial menu rows retain the existing narrowly scoped clipping exemption, while the tapped Settings and sticky BACK cannot use it.

The next corrected-source contract also includes read-only `settings_values:{music,effects,mute}` on every snapshot. The helper preserves the initial values through Operations scroll, Settings entry, body scroll and BACK. It requires effects and mute to become fully exposed, using at most four fresh-offset-proven swipes per target. Settings swipes begin in a measured empty gap outside all clipped control hit rectangles; no safe origin means failure. These controls are inspected, never activated. A fully exposed initial inner layout records zero body swipes honestly. This covers gap-origin reachability without accidental changes, not slider-origin gesture arbitration or physical-phone comfort. The two retained first-swipe failures are [39222413584](../android-39222413584/README.md) and [39223713376](../android-39223713376/README.md); the latter explicitly observed the known SystemUI intro absent. No successful Android scroll is implied by this preparation.

This remains **prepared, unexecuted native coverage** until a coherent density candidate passes local whole-suite checks and the flag is deliberately enabled. The density flag is enabled only in the unpublished matching candidate; no current native target-size pass is claimed. Eleven CLI guards exercise actual-hit mapping, clipped/missing controls despite an apparently valid SS_TARGET, stale snapshots, wrong window/screen, undersize and out-of-safe scroll geometry. Synthetic PNG headers are parser fixtures, not screenshots. Headless-desktop ScreenTouch drags did not scroll; the matching Godot backend requires touchscreen availability for this mouse-drag path. Desktop wheel/pointer checks therefore do not establish this ordinary Android OS swipe route.

## Exact engine quantization contract

The [source and measured-transform record](quantized-viewport/README.md) replaces the earlier uniform-scale assumption with Godot 4.6.3's actual floor-before-stretch model for this project. The native CLI has no fixture-provenance override. A separate local capture auditor may evaluate unchanged `test_android_density_fixture` pairs with an explicitly nonnative result; it cannot establish Android density, OS input or a native gate pass. Strict `density-checks.sh` now runs the actual game geometry/menu suites with successful-summary and error gates as part of `test.sh`.
