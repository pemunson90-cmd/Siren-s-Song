# Isolated Android resume capture contract

Source base: `20de5cd2f7aaabd96790cfbe67840e22c07c66fe`. This is an uncommitted, isolated patch, not the APK in active run39266427532. Root owns integration/publication; no shared game/tooling source was edited by this task. Explicit Sol6.1/high routing; actual backend/cost telemetry unavailable.

## Observed failure and proposed boundary

Run39261365076's actual `cover-resume.png` is2520×1080,13,037bytes, uniformly black. The byte-identical original is included as a regression fixture in the patch; its provenance/hash is in `source-manifest.json`. Existing `launch()` allows previous screen/layout counts for a running process; subsequent resume capture is an immediate unbracketed screencap. Later cold-restored gameplay was readable, but that does not establish same-resume recovery.

The patch retains the first PNG as `*-resume-immediate.png`, explicitly unverified. It then uses existing strict capture bracketing for `*-resume.png`, requiring a fresh foreground marker followed by the newest complete actual post-draw report, pausedmission0/subselected/noactivecamera, existing48dp/nativegeometry, and unchanged pre/post semantic state. Old, missing, incomplete, headless-only, or wrong requested-state reports retry; malformed latest evidence stays fatal. The new foreground hook is guarded against notifications before readiness/HUD setup. Existing postdraw/headless behavior is reused unchanged.

A real Godot Image decoder checks the candidate's actual RGB data. Uniform black or any uniform RGB image is rejected, retained as `*-resume-rejected-N.png`, and retried within the existing10attempt/1s retry bound. Invalid PNG/decoder failure is fatal; exit0 without the explicit nonblank marker is also fatal. No control input, route, clock, device reset, or cold restart is added. Other callers have unchanged default behavior.

RGB variation proves only a nonuniform image. App postdraw does not acknowledge Android composition or establish pixel semantics. A later nonblank candidate on the same resume would support capture latency; ten blank candidates still fail with originals preserved. Neither outcome can be claimed from these local tests. The active20de native run does not contain this patch, and its actual resume image must be reviewed independently.

## Verification

- `protocol-decoder-red.log`:9expected failures with old parser/missing decoder; GREEN9/9 in `protocol-decoder-green-first.log`. Includes actual native black PNG, invalidPNG, uniformwhite, nonuniformpositive, old/missing/incomplete/latest malformed reports, retained black candidate→nonblankfinal and bounded allblackfailure. ADB is mocked; actual Godot decoding is real.
- `real-gl-red.log`: fresh pausedmission, early+ordinary foreground callbacks, actual X11/llvmpipeGL; zero fresh reports, resultfalse. `real-gl-green.log`:2postdraw reports,31drawnframes, pausedmission unchanged, resulttrue. `display-setup-failed.log` is a separate stale-display setup failure, not the behavioral RED; fresh displays401/402 were used for valid RED/GREEN.
- `headless-green.log`: early callbacks are harmless;2layout_only reports, zero drawnframes, pausedmission unchanged; no postdrawclaim/hang. RealGL/headless scripts use bounded teardown.
- Existing capture20/20, Blackwater17/17, genuinearchive binarybackup/absenttmp/writefailure mock all pass. Runtime308checks/0failures; changed Bash scripts pass `bash -n`. No unchanged broadgame-suite repeat.
- `source.patch` includes10owned files listed in `OWNED_FILES.txt`, including the native black regression fixture and one test.sh invocation. `source-manifest.json` records every before/afterSHA256. `patch-apply-check.log` records successful application check against a fresh exact20dearchive. Root must review/integrate after its local navigation commit; this task did not alter that source.

No native/physical/fullcampaign/humanlistening acceptance or compositor guarantee is inferred. Existing native run remains the primary artifact evidence task.
