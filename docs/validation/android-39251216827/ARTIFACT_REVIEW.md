# Native artifact review — 39251216827

**Verdict: scoped native gate passes.** Downloaded camera and both restored-dive final images show their intended states. Four archive integrity checks, APK identity/signing, existing strict CI/native functional gates and inspected both-layout final views pass. No consequential control clipping or overlap was found. Native unobscured observed-contact teaching remains unproven; internal hunter diagnostics do not substitute for those pixels.

## Identity and byte evidence

[Run39251216827](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39251216827), job118055197456, succeeds on exact head **0afe5fce83c575995b718c5e3d6b152bd7282df2** on `gauntlet/production`, same reviewed game/tooling source as5eb571f20f43d62810685713118f37147d0121e4. [Completed run](completed-run.json) and [jobs](completed-jobs.json) preserve identity/status. Later local governing-only e8653b5 was not this run's source.

The supported GitHub `download_workflow_artifact` connector returned File Service references. Each returned download URL was consumed through the normal proxy/CA, without printing or saving the signed URL, Sediment misuse or control bypass. Four original ZIPs/extracted PNGs remain in ignored `work/android-39251216827/`. No dispatch, rerun or cancellation occurred. The fifth capabilities artifact is metadata/permanent-link only here, not a claimed local download.

| Downloaded artifact | ZIP bytes | SHA-256 | Checks |
| --- | ---: | --- | --- |
| APK12186710188 | 69,006,297 | `299866ac16bf0d36bc040c8df5250909bc7dc57fb68203b846af886eec2f608d` | metadata size/digest, CRC pass;3 entries |
| Cover12186745091 | 13,949,030 | `a52657a80b95e86da84a22784f0b0b22eee25b8b9c4b71e15ab425b3c13ad011` | metadata size/digest, CRC pass;27 entries |
| Inner12186515494 | 25,637,466 | `c0e592341950be50871efe798a650d44a92694d684c294f66bfe5a19566d2977` | metadata size/digest, CRC pass;32 entries |
| Runtime12186585382 | 71,926,234 | `af45014196c8c8f13c970ec46cb9145b84e41dbd5ccedbb14a2e12758cfb6415` | metadata size/digest, CRC pass;401 entries |

Extracted APK: **69,399,012 bytes**, SHA-256 **`c8b63d1bddee778a19a3a707702e9fd70dc80b3eeb2422c288f77984121fbb4f`**, matching archived SHA file and CI. Local build-tools36.0.0 `apksigner verify --verbose --print-certs` exits0: v2/v3 true, one RSA2048 Android Debug signer, stable certificate **`32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`**. See [actual signature output](downloaded-apk-signature.txt), [CI signing/cache excerpts](signing-and-cache.log), separate parent [byte recomputation](parent-byte-verification.json) and [signature](parent-signature-verification.txt). This is development signing. Official Godot4.6.3/signing cache hits are recorded.

## Actual final images

All **59 original PNGs** are inventoried by hash/dimensions in [download-verification.json](download-verification.json): **18 cover +23 inner final-labelled images**, plus18 geometry probes. Seven contact sheets were inspected for all41 finals, followed by individual full-image inspection of critical captures, cover secondary commands/scrolled Settings, inner Settings, debrief/archive and camera/restore probes. Native dimensions are2520×1080 cover and2184×1968 inner, except the OS-rotation resume image; exact dimensions remain in the manifest. **20 key finals and3 explicitly non-final probes** are retained as lossless WebP, each verified identical in decoded RGBA pixels/dimensions, without crop, annotation, rescale or recoloring. Contact sheets are ignored review aids, not pixel proof.

| Final frame | Direct observation |
| --- | --- |
| [Inner camera exposure](screenshots/inner-camera-exposure.webp) | OPTICAL / DRONE A inset, Signal Spire00%, DRONE A EXPOSING, CAMERA2s pulse row and tactical pause coexist. No consequential control overlap. Prior ROUTE/no-inset mismatch is absent. |
| [Cover restored](screenshots/cover-restored-gameplay.webp), [inner restored](screenshots/inner-restored-gameplay.webp) | Actual paused Quietus dives with retained route and “Mission restored · paused for review” footers; prior inner preceding-menu mismatch is absent. |
| [Cover primary](screenshots/cover-touch-targets-primary-initial.webp), [secondary](screenshots/cover-touch-targets-secondary-initial.webp), [restored page](screenshots/cover-touch-targets-primary-restored.webp) | Readable commands/pause/unit controls, clear BACK ORDERS, intact chart. Narrow landscape instrument still requires gaze travel; physical thumb/fold ergonomics are not established. |
| [Inner primary](screenshots/inner-touch-targets-primary-initial.webp), [secondary](screenshots/inner-touch-targets-secondary-initial.webp) | Readable lower grid, route/pause state and command pages. Camera image has four emission/status rows with no contact row; simultaneous multi-contact stress is not shown. |
| [Cover Settings](screenshots/cover-menu-settings.webp), [effects/mute/BACK](screenshots/cover-menu-settings-mute.webp), [returned menu](screenshots/cover-menu-returned.webp) | Correct requested screen identities. Effects and MUTE: OFF reachable after one measured OS scroll; sticky BACK separate/usable. Partial text at body scroll edges is expected viewport clipping. |
| [Inner Settings](screenshots/inner-menu-settings.webp), [returned menu](screenshots/inner-menu-returned.webp) | Effects/mute and sticky BACK visible; operations scroll exposes bottom entry. Large unused Settings body remains a visual cost, not failed reachability. |
| [Shelf debrief](screenshots/inner-mission-completed.webp), [cold-restored campaign](screenshots/inner-campaign-restored.webp) | ARCHIVE RECOVERED,00:17/Hull100%/Life support119%, then Shelf RECOVERED / Split AVAILABLE. S1 PATROL · INVE… is partly visible behind overlays; unobscured S# readability/fresh-to-old timing cannot be accepted from these images. |
| [Well lure](screenshots/inner-role-lure-planned.webp), [return](screenshots/inner-role-return.webp) | Actual15s decoy glyph/status then DECOYS none. No hunter directly visible. Fixture role telemetry does not establish movement pixels or hidden causal certainty. |

The3 intended captures have complete fresh pre/post reports with matching semantic state and screenshot geometry, `phase=post_draw`, and no metric/frame regression:

| Capture | Pre/post metric count | Drawn frame | State | Minimum nonexempt target |
| --- | --- | --- | --- | --- |
| Cover restored | 32 /32 | 13 /13 | mission0, paused, selected0, capture−1, HUD true, menu false, optical false | 56dp |
| Inner restored | 62 /62 | 11 /11 | mission0, paused, selected0, capture−1, HUD true, menu false, optical false | 56.55dp |
| Inner camera | 71 /71 | 202 /202 | mission0, paused, selected1, capture1, HUD true, menu false, optical true | 56.55dp |

All3 full pre/post reports equal after excluding only monotonic metric count/drawn-frame identities; actual identities are equal here. All15 menu pre/post pairs are canonically equal excluding metric count. Settings remain music0.5/effects0.8/mute false. Native420dpi DisplayMetrics and `wm density` agree; cover chart612.76×331.43dp, inner750.96×416.80dp, safe areas and both-page targets pass48dp checks. [Retained reports](downloaded-metrics/ui-metrics-capture-inner-camera-exposure.json) preserve full geometry. Static dimensions substantiate geometry, not screenshot identity alone.

**Rendering limit:** Godot `frame_post_draw` is app-render evidence, not Android presented-frame/compositor acknowledgment. Actual downloaded PNG inspection supplies this run's pixel verdict. The [camera probe](capture-probes/inner-camera-exposure-geometry-probe.webp) and both restored-dive probes happen to depict intended states here but remain non-final. Other unbracketed image classes have observed-image verdicts, not a universal synchronization guarantee.

## Exact functional scope and incidental failures

[Complete received job text](job.log) preserves638,366 characters /638,368 UTF-8 bytes. [Progress](progress.log), [engine events](godot-events.txt), [test excerpts](test-summaries.log) and44 parsed [metric reports](downloaded-metrics/ui-metrics-inner-primary-initial.json) retain supporting evidence.

- Strict CI:257 core,298 runtime,1057 density,7 menu,15 scroll,68 metric transport, all0 failures; Python10 role/9 transport/30 menu/**20 capture**/8 view/27 geometry plus archive mock pass. Headless/desktop campaign outcomes are not native full-campaign acceptance.
- Native entry12:23:52, install12:24:11; both viewport launches, measured OS taps/orders/pause, both command pages, target geometry, zoom/pan/FIT without unintended orders, OS menu scroll/Settings/sticky BACK, background/resume, process death/archive entry pass. OS pinch remains unverified.
- State brackets pass cover restore12:26:43, inner restore12:28:41, camera12:29:48. Ordinary-command Shelf record secures12:30:02, extraction wins12:30:03, campaign saves12:30:04, cold campaign restore12:30:14. Actual debrief/archive images agree.
- Fixture-assisted fresh Well entry12:30:15, observer readiness12:31:12, lure capture12:31:29, return marker12:32:58, genuine Shelf archive byte restoration12:33:12. [Role summary](role-response.json):6 observations; PATROL,DORMANT,INVESTIGATE,SEARCH,RETURN,DORMANT; maximum observed home distance232.134771m (transition-sampled lower bound), simulated return49.2s, final home error14.182572m. [Archive hashes](role-archive-hashes.txt) verify genuine save restoration. This is not earned Well progression.
- Native smoke passes12:33:18; [runtime-error scan](runtime-errors.txt) empty. Audio lifecycle/settings state checks pass; no subjective listening was performed.

Incidental failures remain visible: pre-emulator local-test adb daemon connection refusal12:21:08; native logcat read12:24:25 returns255, retains partial output, then bounded retry succeeds. Neither defeats final strict/native gates. No game/runtime or artifact-retrieval failure was observed. [Emulator fingerprint](fingerprint.txt) is Android16 x86_64, not Samsung hardware.

## Comparison, criticism and release

Compared with39244955064, named camera/restored-dive mismatches are resolved by actual pixels and strict brackets. Compared with39229219785, both-layout input/archive/numerical gates and readable command pages remain intact; newer decoy glyph/summary is visible. No expanded native teaching-quality acceptance follows for S# rows partially behind overlays. Reviewed desktop contact exercises remain separate evidence. Future meaningful gameplay CI can add an ordinary unobscured fresh→old contact sequence and contact/emission/camera coexistence; this completed run warrants no retrieval rerun.

Gaze transfer, contact-memory semantics for newcomers, cover density and empty Settings space remain experience costs. Static emulator images and internal role timing do not establish tactile comfort, human reaction time, blind-reference superiority, moving-contact legibility, physical Fold7 behavior, performance, sound quality, earned campaign progression or native finale quality. Imported originals, inspected9dac and f1ea536 fallback remain preserved. Experimental finale ancestry is unpromoted; only gain-specific promotion is supported.

Evidence scope is complete/released to parent; no source/governing edits, commit or push. Parent independently checked bytes/signature and the same3 critical full PNGs. Reviewer route is explicit `gpt-6.1-sol` / high; actual backend/token/cost telemetry unavailable. Parent continues the authorized production loop; bounded artifact completion is not a program stop.
