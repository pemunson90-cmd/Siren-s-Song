# Acoustic feedback challenger · local, awaiting independent review

Game baseline aa022cc / inspected native b809501 is preserved. Parent docs-only HEAD11151d3 has the same baseline game. Challenger is the uncommitted four-file product delta in [source-sha256.txt](source-sha256.txt), verified by the strict gate below. [Design and actual v7 comparison](DESIGN.md) records rationale, exclusions and tradeoffs. This is desktop Godot4.6.3 Compatibility/software-GL evidence; native challenger, physical Fold7 and human audio acceptance remain open.

## Inspect actual output first

- [Baseline20s](clips/baseline-cover.mp4) and [challenger20s](clips/challenger-cover.mp4): identical actual engine GUI pointer trace;2520×1080/420dpi with recorded136px cover inset. MP4s are half-size1260×540 at15fps, silent. Last input release is frame181 (12.07s); remainder through20s has no player input. Commands: cruise/route, disclosure, decoy, drone selection/route/second decoy, Quietus selection/BACK ORDERS/silent/hold, pause/resume, route replacement. [Exact accepted-input/state comparison](baseline-challenger-trace-comparison.txt) matches every input, order result, pause state and final time/hull/outcome/noise record. Both end at18.9167 simulated seconds, hull100%, no mission outcome; first decoy expired, second has2.0667s remaining. No balance gain is claimed.
- [Standalone18s no-input expiry](clips/idle-expiry.mp4): ordinary DECOY and RESUME before recorded frame0, then absolutely no commands/pointers during270 frames.1280×720, normal desktop96dpi; half-size video640×360/15fps, silent. The15s transmission visibly expires; final elapsed18.05s/hull100%, noises empty. Hidden enemy reactions remain unproven. [Transmitting](idle-transmitting.png) → [expired](idle-expired.png), [raw log](idle-expiry.log).
- Full-resolution same-frame [baseline](baseline-cover.png) / [challenger](challenger-cover.png) show independent countdown after SILENT/HOLD overwrite the launch log. [First decoy expired](challenger-first-expired.png) retains the other countdown even after another route message.
- [Actual camera, cover inset](camera-cover.png), [log](camera-cover.log): ordinary drone route→camera plus decoy/sonar. Exposing Drone A at14.5 simulated seconds/hull100%, current observed patroller INVESTIGATE. Four-row active-tool state stays above the optical inset and below zoom controls.
- [Actual fresh threat, inner](threat-inner.png), [log](threat-inner.log): ordinary cruise route and sonar every4s before first observed lock, paused at26.6s/hull100%;2×zoom, observed BEAM3.8s. Three-row instrument, threat strip, zoom and decoy number remain separate. This is a visible planning state, not proof the decoy breaks the active chase.
- [Retained loss, inner](retained-loss-inner.png), [log](retained-loss-inner.log): unsounded ordinary cruise route loses Quietus at27.1s with current contacts empty. The lost/debrief image does not prove enemy truth was visible. No sensing nerf or fixture teleport recovers the loss.

No external-game visual/noise comparison or quality verdict is asserted by this builder evidence. Parent's separately owned reviewer can use the official reference footage; blinding is not claimed.

## RED → GREEN and retained mistakes

- [core-red.log](core-red.log):245checks/6 expected missing-feedback failures. Decoy persistence after messages, restore/multiple lifetimes, actual motion, own-source whitelist and sensor-visible environmental responses failed as assertions, without parser errors. Expiry/pause/immutability/uncertainty checks are coupled to those positive preconditions.
- [ui-red.log](ui-red.log):235/4 expected missing-instrument/copy failures. [ui-green.log](ui-green.log):235/0 after implementation.
- [core-first-green-fixture-failure.log](core-first-green-fixture-failure.log):245/1. Fixture still had active SURVEY, which intentionally makes all sources sensor-visible under existing rules. Reset recon/sonar for the passive-visibility assertion; no sensing change.
- [compact-red.log](compact-red.log):237/1 expected idle-tool-row footprint failure. Conditional active-tool row removes the unnecessary fourth row; [final-full-green.log](final-full-green.log) passes245core /237runtime /1057density /7menu /15scroll /65transport, all zero failures, plus native archive/parser guards. Earlier [full-green.log](full-green.log) is245/235 with the initial fixed four-row rendering. Final product hashes are the source authority for this evidence. Tooling-owned screenshot tests were being finalized concurrently and are separately verified by that owner/parent.
- [Rejected replay](rejected-hidden-page-replay.log): initial capture clicked stale hidden primary-control positions after disclosing secondary orders; actual SURVEY orders expose the error. Final baseline and challenger add actual BACK ORDERS input and match exactly. Raw rejected frames remain work/acoustic-feedback/baseline-cover/; no successful SILENT/HOLD claim is assigned to that take.
- [Rejected1280px/420dpi capture](rejected-small-420dpi.png): artificially tiny physical window at phone density crowds/clips existing controls/header and the new cue. Not a native-size phone fixture or a successful small-screen claim. The idle clip was rerendered using honest normal desktop density, without a product change. Broader extreme-window behavior remains outside the primary native sizes; do not hide this limitation.

Actual GL captures can emit unsupported-VSync warnings. Some forced-exit context/rejected captures emit generic ObjectDB leak warnings; exact logs retain them. Final paired GUI takes and the final strict test gate have no engine errors. These captures do not establish leak-free device operation or sustained performance.

## Reproduce

All intermediate frames/copies are in locally ignored work/acoustic-feedback/. Durable output is this folder. Test command:

```sh
TOOLCHAIN_CACHE=/workspace/Siren-s-Song-gauntlet/work/toolchain scripts/toolchain/test.sh
```

Use existing scripts/toolchain/display.sh and a live DISPLAY. This execution's99 server became defunct after its owning exec ended; subsequent captures used fresh100–108 displays, no tooling source changes. Example challenger replay (XDG_DATA_HOME keeps capture saves local):

```sh
DISPLAY=:108 XDG_DATA_HOME="$PWD/work/acoustic-feedback/userdata" LIBGL_ALWAYS_SOFTWARE=1 godot --path game --rendering-method gl_compatibility --audio-driver Dummy --resolution 2520x1080 --fixed-fps 15 --script res://tests/capture_acoustic.gd -- --clip-dir="$PWD/work/acoustic-feedback/replay" --safe-inset-x=136
```

Standalone idle uses `--resolution 1280x720 --fixed-fps 15` plus `--idle --desktop --clip-frames=270`. Context script is `res://tests/capture_acoustic_context.gd`, with `--context=camera` or `--context=threat`, `--image-path=...` and optional cover inset.

Baseline uses a32MB local game copy in work/acoustic-feedback/baseline-game/ with main.gd, simulation.gd and ocean_view.gd restored byte-for-byte from aa022cc using git show; the same capture script is copied into it. All other production assets/code are unchanged baseline bytes. The active checkout is never reset and no worktree is created. Encode captured half-size frames with `ffmpeg -framerate 15 -i %04d.png -c:v libx264 -pix_fmt yuv420p -crf 24 output.mp4`.

Requested implementation model gpt-6.1-sol/high; actual backend/cost unknown. No nested delegation, no commit/push by implementation owner. Independent review and publication belong to parent. Exact staged file ownership is reported separately; unrelated importer-generated UID files must remain untouched.
