# Measured integer viewport and native checker contract

This resolves a checker error, not an Android pass. Requested model: explicit Sol 6.1; actual backend/usage/cost telemetry unavailable. No nested agents or game edits. Current immutable geometry/menu comparison source is `6ce6cc0bb926caad225e18a667579821020dd0cf`. The subsequent queue-intent feedback correction remains separately source-labeled by the production lead.

## Root cause and exact acceptance rule

The settled inner capture reports actual full-window logical viewport **1280×1153**, physical window/PNG **2184×1968**, and root screen/final transforms **X 1.70625, Y 1.706852** at displayed precision. [Actual diagnostic](actual-inner-transform.txt). Logical coordinates must remain those the engine actually exposes; replacing 1153 with 1153.406593… would fabricate a different control canvas.

Official Godot 4.6.3 [Window source](https://github.com/godotengine/godot/blob/4.6.3-stable/scene/main/window.cpp#L1232) computes the expanded viewport, **floors it**, then supplies that override in canvas-items mode. [Viewport source](https://github.com/godotengine/godot/blob/4.6.3-stable/scene/main/viewport.cpp#L1202) returns the actual override in its visible rect. Retrieved file URLs/SHA-256 values are retained in [engine-source.json](engine-source.json), with numbered excerpts beside it. The current project is 1280×720, `canvas_items`, `expand`, content factor 1; its exact project hash is in [source-checkpoint.json](source-checkpoint.json).

For physical PNG/window `W×H`, this project's expected logical viewport is exactly:

```text
if W * 720 >= H * 1280: [floor(720 * W / H), 720]
otherwise:              [1280, floor(1280 * H / W)]
```

The checker computes this with integer division, compares the reported viewport exactly, and then uses **separate actual scales** `W / logical_width`, `H / logical_height` for hit rectangles, safe bounds and dp. No loose anisotropy percentage or arbitrary one-pixel tolerance is added. Cover maps to `(1.5,1.5)`; inner maps to `(1.70625,1.706851691240243)`. Future deliberate changes to content size/factor/stretch require a measured contract revision; this check fails closed rather than guessing a transform.

The old strict uniformity check rejected real engine output and accepted an invented fractional inner viewport. [RED](parser-red.log) reproduces all three relevant failures; [GREEN](parser-green.log) has **23 / 0**, accepting actual taller/wider axis flooring while rejecting wrong integer quantization, fabricated fractional coordinates and local fixture provenance through the native CLI. Existing size, clipping, required-action, overlap, safe-area, actual PNG, OS-density, screen/page and freshness gates remain intact.

## Local game and actual-capture evidence

The strict new `density-checks.sh` entrypoint is part of `test.sh`. It treats process failure, Godot/script errors and missing successful summaries as failures. Running only these new suites in a **git-archive isolated 6ce6cc0 game** passes **685 geometry / 7 menu checks**, zero failures. [Geometry log](geometry-6ce6cc0.log) · [Menu log](menu-6ce6cc0.log). A first shared-tree attempt overlapped the lead's subsequent queue-intent RED test; its transient 693/2 result is not attributed to the immutable checkpoint. Later final feedback-source suites are separate.

`audit-local-density.py` reads settled same-frame `layout.json` / actual `full.png` pairs **without changing their `test_android_density_fixture` provenance**. Its explicit local-only evaluator reports `native_measurement:false`; the native CLI has no override flag and still rejects those files as Android evidence. Ten accepted cover/inner primary, secondary, briefing, operations and Settings pairs pass the measured geometry contract; the retained rejected briefing-overflow pair correctly fails with no visible controls. The audit binds input hashes to distinguish regenerated captures. All 33 input PNG/JSON/log blobs were compared byte-for-byte with immutable artifact checkpoint `6de9e10`; that checkpoint includes the later queue-intent feedback fix, whereas the separately isolated suites above use 6ce6cc0. The same actual menu parser evaluates these records through an explicit local-only function argument: both operations layouts correctly require scrolling to Settings, and both Settings/briefing BACK actions map to fully exposed measured hits. Neither native CLI offers a fixture override. Partially clipped scroll rows retain only the existing clipping exemption; fully exposed controls and sticky actions keep every size/safe/nonoverlap requirement. Offscreen omitted Settings controls are not claimed as measured.

Direct visual inspection included cover primary, cover briefing, cover Settings and inner primary frames: sticky briefing/Settings footer actions are fully framed, and the mission chart retains a distinct area above/beside the enlarged controls. These are local renders at a density fixture, not Android screenshots or proof of finger comfort. Actual Android `screen_get_dpi`/`wm density`, OS scrolling to Settings, native reachability and all existing gameplay/lifecycle/audio/role gates still require the coherent native run. External shipped-game motion and current native artifact-byte inspection remain pending their separate access limits.
