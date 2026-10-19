# Target sizing · measured pixels and computed physical estimates

Accepted runtime 92625ac/f1ea536; [actual passing Android frames](../../validation/android-39205478335/README.md). This is an independent arithmetic/source check, not a physical Fold7 measurement or human comfort study.

## Evidence and assumptions

- Actual retained cover PNG is **2520×1080**, native `SS_TARGET` logical viewport **1680×720**. Uniform scale is **1.5**. Actual inner PNG is **2184×1968**, native logical viewport printed as **1280×1153** (integer-rounded); exact width-derived scale is **1.70625**, yielding logical height 1153.4066. Do not treat the rounded viewport height as a different intended y scale.
- Exact baseline layout sets pause/order/zoom control height 48 logical. Independent [headless geometry probe](target-geometry-probe.gd), after importing the untouched scratch project, reports actual pause/CAMERA/zoom sizes 48 logical and **unit selectors 56 logical**, because their two-line text/theme minimum exceeds 48. [Raw output](target-geometry.log). The external audit's “all buttons 48” statement is inaccurate. This probe verifies size, not Android safe-area position; raw native target positions remain authoritative for input.
- PNG column checks through native + button bodies find 68 flat-fill rows cover / 77 inner, plus border/antialias rows, consistent with approximately 72/82 total pixels. Unit button flat-fill rows 80/91 are consistent with 84/96 total pixels. Visible body alone does not define the hit region; source/Control geometry supplies the hit rectangle. No expanded hit delegate is implemented in the inspected baseline; a future larger invisible hit region would require its own check.
- Samsung's published Fold7 page states **6.5in, 2520×1080 cover** and **8.0in, 2184×1968 inner**. The public page was independently fetched via Exa on 19 October 2026 after direct Python HTTP was blocked by the session proxy 403. [Retained extracted source text](display-and-guideline-sources.txt). Computed uniform panel ppi assumes these nominal full-rectangle diagonals; rounded corners/cutouts/active area or device scaling can change actual use. We did not measure a phone or its selected display mode.

## Calculation

`ppi = sqrt(width_px² + height_px²) / nominal_diagonal_in`; `physical_mm = logical_height × canvas_scale / ppi × 25.4`.

| Profile | Computed panel ppi | 48logical pixels → native pixels | Estimated height | 56logical unit selector → pixels / estimated height |
| --- | ---: | ---: | ---: | ---: |
| Cover |421.797|72.0|**4.336mm**|84.0 /5.058mm|
| Inner |367.485|81.9|**5.661mm**|95.55 /6.604mm|

The arithmetic confirms a substantial physical-size concern, especially cover controls. These are **computed estimates** from retained pixel geometry and nominal Samsung specs, not observed finger accuracy. Larger selectors still do not make the smaller command/zoom targets comfortable.

## dp and guideline correction

Google's official Android Accessibility guidance **recommends** touch targets of at least48×48dp, with 8dp separation, and describes approximately 9mm /7–10mm physical targets. It also explicitly distinguishes visible icons from larger touch regions. It is guidance, not a universal platform-enforced minimum. External audit F5's language “Android physical minimum” is too absolute.

`dp = physical_pixels ×160 / Android_densityDpi`. Panel ppi is **not** Android's configured densityDpi. The emulator fixture explicitly sets **420dpi** with `adb shell wm density 420`. Thus 48 logical is **27.43 emulator dp cover / 31.20 emulator dp inner**; 56 logical selectors are 32.0 /36.4dp. The inner emulator's same 420 density does not match the nominal physical panel ppi, and neither profile is Samsung's actual configured density. No physical Fold7 `wm density` has been read, so exact physical-device dp compliance remains unverified.

At the ideal 160 pixels/in convention, 48dp mathematically converts to 7.62mm; Google's approximately 9mm is usability guidance, not an exact ppi calibration. Converting these rendered controls using panel ppi gives physical estimates, **not** actual Android dp. Keep those quantities separate.

The concern is independently verified; the exact fix/design is not ratified by the upload. Preserve current accepted behavior as comparison while the lead assesses a physical-size-aware responsive layout and gesture/order safeguards. A future gate should inspect actual hit dimensions under native display/density/safe-area states, plus physical comfort, rather than merely asserting `size.y>=48` in logical coordinates.

## Reproduce the arithmetic

```python
from math import hypot
for width, height, diagonal, scale in [(2520,1080,6.5,1.5),(2184,1968,8.0,2184/1280)]:
    ppi=hypot(width,height)/diagonal
    for logical in [48,56]:
        pixels=logical*scale
        print(ppi,logical,pixels,pixels/ppi*25.4,pixels*160/420)
```

Sources: [Samsung Fold7 specifications](https://www.samsung.com/sa_en/support/mobile-devices/what-is-the-display-size-resolution-of-galaxy-flip-7-galaxy-fold-7/), [Google Android touch target guidance](https://support.google.com/accessibility/android/answer/7101858?hl=en). Physical Fold7 density, reachability, hinge/cutout transitions, finger comfort and OS pinch remain unverified.

## Contract supplied to the production lead

For a future native size gate, report final post-theme `get_global_rect()` hit sizes together with full logical viewport, physical window and safe-area sizes. Pair those markers with actual PNG dimensions and `adb shell wm density`; distinguish physical/override density values. Compute uniform canvas scale from unrounded full window/viewport metadata when available; rounded markers carry uncertainty. At emulator density 420, a 48 dp hit height requires **84 logical cover /73.846 logical inner** for these current transforms. This is a computation for the fixture, not a prescribed layout or known Samsung density. Assert expanded hit rectangles separately if added, and preserve nonoverlap, responsive layout, tactical pause and zero accidental orders. Physical device comfort remains its own check.
