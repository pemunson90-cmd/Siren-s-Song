# Current-source observed response · footage-only probe

[Play the actual16s clip](current-hunter-response.mp4), then inspect the [six-frame chronology](chronology.jpg). Source **9dacbb4a6ac5a7851c368ad060805048bd541056**; no product, capture script, toolchain or gameplay changes. This is an evidence probe before designing teaching, not a new critic verdict or promoted gameplay change.

## What is actually visible

| Clip time | Player-view observation |
| --- | --- |
| [0.4s](01-0.4s.png) | Fresh rendered **HUNTER · INVESTIGATE** beside Quietus; decoy15s; hull100%. |
| [2.4s](02-2.4s.png) | Same fresh hunter has visibly moved down toward the archive/decoy area; decoy13s. Its label crosses the archive label. |
| [3.2s](03-3.2s.png) | Live hunter silhouette/label has become **LAST SEEN / ECHO ·0s** at its last observed location; decoy12s. Sensor-loss transition is bracketed by2.4–3.2s. This is stale evidence, not its continuing current position. |
| [8.2s](04-8.2s.png) | A separately labelled fresh **PATROL · INVESTIGATE** enters above Quietus; prior echo is about5s old; decoy7s. Do not mistake this patroller for the hunter returning. |
| [14.8s](05-14.8s.png) | Decoy1s; old echo about12s plus another recent last-seen mark. Overlapping archive/echo labels limit easy actor tracking. |
| [15.8s](06-15.8s.png) | **DECOYS · none**, decoy glyph gone; old echo13s and another echo1s remain. Hull100%, no debrief. The finite transmission ended around15s; disappearance of the emission is not evidence of safety. |

The entire interval was additionally decoded/sampled at1fps; the six retained frames were accurately sought from the final encoded clip at the times shown. [Inspection table](inspection.tsv), [media/decoder facts](media-probe.json), [hashes](evidence-sha256.txt), [verification](verification.txt). This is sampled decoded playback, not a claim of watching every source frame at real-time cadence or judging audio quality.

**Bounded conclusion:** this current ordinary scene contains the required observable chain: own transmission → a currently observed investigating hunter → lost observation/aging echo → finite transmission expiry. It supports teaching the distinction using existing observations. It does **not** establish an omniscient causal statement that this particular decoy was heard, a successful lasting diversion, hidden SEARCH/RETURN/home location, or a winning route. A second currently visible actor matters. The clip does not provide the active-visual-lock counterexample; that remains separate evidence before a full teaching sequence is claimed.

A concrete copy limitation is retained: after expiry, the persistent cue correctly says none while the historical bottom log still reads “Decoy transmitting ·15seconds.” That log was issued at launch, not refreshed now. No copy or UI fix is made in this probe.

## Setup, provenance and exact reproduction

Used installed, unchanged `game/tests/capture_siren_roles.gd --stage=hunter_response`: start a fresh mission4; its ordinary move helper routes Quietus to(600,600), waits until settled, then ordinary DECOY at(800,850). Setup ends at simulation12.6s. The helper can use ordinary disruption if it observes lock>1s, but this take still shows its initial two charges. No route/tool/pointer commands occur during the16-second recording. This is fresh-mission setup, **not earned Well progression, Android OS input, native-device comfort or human play**. No sensor override, survey, forced pose or hidden-contact rendering is introduced.

```sh
DISPLAY=:120 XDG_DATA_HOME="$PWD/work/observed-response-probe/userdata" \
TOOLCHAIN_CACHE="$PWD/work/toolchain" CAPTURE_FRAMES=240 CAPTURE_FPS=15 \
CAPTURE_RESOLUTION=1280x720 CAPTURE_DIR="$PWD/work/observed-response-probe/current" \
scripts/toolchain/capture.sh --script res://tests/capture_siren_roles.gd -- --stage=hunter_response
```

The actual capture/encoded view is1280×720, Godot4.6.3 Compatibility/OpenGL3 on Mesa llvmpipe software rendering; fixed15fps,240frames/16s. PNG sequence and PCM mixer WAV remain in ignored `work/observed-response-probe/current/`. H264/AAC MP4 preserves1280×720/15fps, with captured mixer audio; no human listening or Android/performance conclusion follows. Encode used matching `-framerate 15` and the sequence plus its WAV. Actual raw invocation/output is in [capture.log](capture.log). It retains unsupported VSync and generic ObjectDB exit warnings. The raw inherited script/diagnostics also print **hidden role state/positions**; those lines are not player observations and are excluded from the chronology/conclusion above.

The first display109 attempt failed before capture because its old X server/socket was unusable; [failure retained](rejected-display109.log). Fresh120 worked without a toolchain edit. No failed gameplay setup or loss was discarded; this take remained at100% hull through its inspected final frame, which does not predict later safety.

Historical [occluded-lure-response.mp4](../../siren-roles/clips/occluded-lure-response.mp4) uses the same setup at frozen ec2aa08 /472b86bd role physics,1280×720/30fps/16s. Its [provenance](../../siren-roles/clips/README.md) distinguishes later false-autopilot-message correction, native diagnostics and presentation changes. Decoded historical1fps samples show the same broad hunter→echo/later-patroller progression; density/HUD and timing sampling differ. This is a source-qualified historical comparison, not a pixel-identical current baseline or new physical proof. [Historical media facts](historical-probe.json) and both clip/source hashes are retained.

Actual original v7 and MANIFEST were read before this probe: v7 sentinel/hunter/patroller branches each test current sight **before** lure; hunter otherwise uses remembered investigation then returns home. Its7s decoy and direct movement differ from production15s/terrain-safe search. No radius, sensing, duration, physics or AI is copied/retuned. Current code is unchanged and the clip cannot override the sight-over-lure caveat.

Requested model gpt-6.1-sol/high; actual backend/usage/cost unknown. No nested agents, no new critic, no commit/push, no broad test rerun. Ownership is only this observed-response-probe directory plus ignored scratch. Governing documentation/native artifacts remain with parent/tooling.
