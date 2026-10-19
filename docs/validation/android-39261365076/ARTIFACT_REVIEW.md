# Failed native candidate — exact scope and preserved evidence

**Overall verdict: FAIL at Blackwater tooling entry; no chapter/native promotion.** Run39261365076/job118089566933 binds exact sourcea178825fc4885f9f3ab191315302925ab0cdac87. All four uploaded archive integrity checks and local APK signing verify. Earlier ordinary Shelf and fixture Well paths reach their success markers; Blackwater fails before fixture generation completes. No receiver/gallery, ordinary chapter input or chapter save-restoration acceptance can be inferred from the earlier gates.

## Causal failure, not a timeout

The [completed jobs API](completed-jobs.json) records native step17 from13:38:00 to13:51:49 UTC, conclusion failure. Its configured limit is15minutes; the job did not reach that limit. [Native progress](progress.log) records ordinary Shelf completion/cold restore, then fixture-assisted Well response and genuine Shelf archive restoration at13:51:36. [Private Blackwater progress](blackwater/progress.txt) contains only its start marker at13:51:36.

[Redirected fixture-generation output](blackwater/fixture-generation.txt) is decisive:

```text
ERROR: Attempt to open script 'res://scripts/toolchain/native-blackwater-fixture.gd' resulted in error 'File not found'.
ERROR: Can't load script: scripts/toolchain/native-blackwater-fixture.gd
```

The helper was sourced via a repository-relative `BASH_SOURCE` path; its dirname remained relative. Godot's `--path game` interprets that relative `--script` below the project root. Existing absolute-path tests missed this actual invocation. This is a tooling defect before app fixture injection, not an observed Blackwater gameplay defect. The private artifact directory contains only `progress.txt` and `fixture-generation.txt`: no fixture/backup/install/route/earned archive or capture files exist. Thus all four requested Blackwater finals are **absent**; settling-hint clipping/readability cannot be judged from this run.

The worker supplied a separately authorized one-line canonical dirname correction, with actual relative-source/real-Godot RED→GREEN and later intentional launch-failure archive cleanup tests. [Exact source/evidence](../production/native-blackwater-tooling/fix-relative-entry/README.md) identifies that local correction. It is not credited to this APK or substituted into a178's evidence. Root's later local loadout and settling-hint copy work is also outside this run.

## Exact artifacts and signing

The supported GitHub artifact-download connector returned File Service references; each returned download URL was consumed through normal proxy/CA without printing/saving it. No Sediment misuse, alternate network route, dispatch, cancellation or rerun occurred. Original ZIPs/extracted originals remain in ignored `work/android-39261365076/`; [API metadata](artifacts.json) binds all four to exacta178. The capabilities fifth artifact is metadata/permanent-link only here.

| Artifact | ZIP bytes | SHA-256 | Verification |
| --- | ---: | --- | --- |
| APK12191858677 | 69,153,796 | `e08fd390f192aefa94f390b73377df3a6d58817eb309bd8c2cad2a5fbcd7e082` | metadata size/digest, CRC pass;3 entries |
| Cover12191318695 | 13,003,127 | `4e1472af2802c63e245622dbb1107194839b9d98f715711d0174fc36f406591a` | metadata size/digest, CRC pass;27 entries |
| Inner12191808644 | 25,625,809 | `16d5c214883152db8dde664b2320e5d60fab33693cf25a8e178ef18201e19433` | metadata size/digest, CRC pass;32 entries |
| Runtime12191289302 | 80,678,594 | `be8197ea80efc3a7f6a6dcf3912125ee40f6f108914aaeaa36d25b74e57e49a7` | metadata size/digest, CRC pass;405 entries |

Extracted APK:69,547,946bytes, SHA-256 **`3b8026807a2aac9d8e77480f5819ecd84445ed53d5e1bbd35859f6075229b304`**, matching its archived SHA file. Local build-tools36.0.0 `apksigner verify --verbose --print-certs` exits0; v2/v3 true, one RSA2048 Android Debug signer, stable certificate **`32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`**. [Actual output](downloaded-apk-signature.txt) and [CI signing/cache excerpts](signing-and-cache.log) retain verification. This is development signing, not release/store acceptance.

## Actual downloaded images

All **59 original screenshot PNGs** are inventoried in [download-verification.json](download-verification.json):41 final-labelled images (18cover/23inner),18 geometry probes, **zero Blackwater frames**. Seven contact sheets were inspected, followed by full-image inspection of camera/restored states, the black immediate-resume frame and final cleanup display.21 selected finals plus cleanup display are retained as lossless WebP with verified identical RGBA pixels/dimensions. No crop, rescale, annotation or recoloring is used. Original hashes cover every unretained view too.

- [Inner camera exposure](screenshots/inner-camera-exposure.webp) actually shows OPTICAL / DRONE A, Signal Spire00%, EXPOSING and CAMERA2s. [Cover restored](screenshots/cover-restored-gameplay.webp) and [inner restored](screenshots/inner-restored-gameplay.webp) actually show paused dives and restoration footers. These specific identities remain correct, with complete fresh post-draw pre/post reports and native48dp geometry.
- Primary/secondary commands, operations/Settings scroll, effects/mute/sticky BACK and returned menus remain readable in both sampled layouts. Ordinary body text clipping at scroll edges remains expected; no new unusable required control was observed in these visible states. Physical thumb comfort is not established.
- **[Immediate cover-resume](screenshots/cover-resume.webp) is entirely black:**2520×1080, RGB extrema0..0 for all channels, exactly one RGB color. It is an unbracketed `shot()` after resume. Later restored gameplay is visible; this single capture establishes neither resumed pixels nor a persistent black-screen game regression. Retain it as a capture/lifecycle evidence gap, not an accepted final presentation. The prior inspected run's equivalent resume image was rotated, so this class already lacked strong presentation proof.
- [Shelf debrief](screenshots/inner-mission-completed.webp) shows ARCHIVE RECOVERED,00:18/Hull100%/Life support118%; [campaign restore](screenshots/inner-campaign-restored.webp) shows Shelf RECOVERED / Split AVAILABLE. A partial S1 PATROL · INVE… row remains behind overlays; unobscured native contact teaching is not established.
- [Well lure](screenshots/inner-role-lure-planned.webp) and [return](screenshots/inner-role-return.webp) show15s decoy/glyph then DECOYS none. No hunter is directly visible; diagnostic transitions are not a movement-pixel or hidden-causality claim.
- [Final cleanup display](screenshots/final-display.webp) shows the genuine Shelf recovered/Split available operations menu, consistent with failure before chapter injection. It is a cleanup observation, not an earned Blackwater gallery.

All15 retained menu pre/post reports are canonically equal excluding metric count; settings remain music0.5/effects0.8/mute false. All3 named camera/restored full pre/post reports are semantically equal excluding monotonic count/drawn-frame identity, with no regression; exact identities/geometry remain in the manifest and44 [parsed reports](downloaded-metrics/ui-metrics-capture-inner-camera-exposure.json). Godot post-draw is app-render evidence, **not compositor acknowledgment**. The entirely black unbracketed resume frame illustrates why this limit is retained.

## Passed earlier scope and unavailable claims

[Received job text](job.log) preserves659,287 characters; [test summaries](test-summaries.log) derive actual CI counts:293core/308runtime/1057density/7menu/15scroll/68transport, all0 failures, plus10role/9transport/30menu/20capture/16Blackwater/8view/27geometry parser tests and archive mock. These local/headless counts are not native chapter coverage; the path-sensitive native entry was not covered by those16 tests.

Ordinary native earlier-scope markers include camera readiness/record acquisition, extraction/campaign save13:47:34, cold restore13:47:49, fixture Well observer13:49:03, return13:51:20 and genuine archive restoration13:51:36. [Role summary](role-response.json):6 observations, PATROL/DORMANT/INVESTIGATE/SEARCH/RETURN/DORMANT, maximum observed home distance232.918628m (transition-sampled lower bound), simulated return49.35s, final home error13.741329m. This is fixture-assisted Well, not earned progression.

The Well helper's passed source-enforced binary comparisons and [archive hashes](role-archive-hashes.txt) support its restored-genuine marker. Top-level original/restored `.save` files are not in this run's runtime upload whitelist, so this reviewer cannot independently compare those raw primary/backup/tmp bytes. Blackwater never activates its private backup/injection transaction. Final display and exact failpoint corroborate that narrower statement; no nonexistent Blackwater cleanup proof is invented.

The [runtime error file](runtime-errors.txt) may be empty from earlier marker checks; it does not negate the fatal host-Godot fixture log or turn the failed job into a pass. The final post-Blackwater strict scan was never reached. Earlier shader/cache/platform warnings are not silently classified as product crashes. One live downloadable-log request returned404 BlobNotFound while the job was active ([retained response](live-log-unavailable.json)); completed log retrieval succeeded normally.

No new chapter frame, native reply recovery, chapter cold-save verification, earned Well/full-campaign/finale, physical Fold7, OS pinch, performance, subjective listening or human comprehension acceptance follows. Existing inspected0afe5fc/run39251216827 and older fallbacks remain untouched. Preserve this failure and its APK as evidence; parent owns the meaningful next combined source and native run, without rerunning CI merely for retrieval.

Requested routing explicit `gpt-6.1-sol`/high; actual backend/token/cost telemetry unavailable. Artifact evidence and separate scoped tooling correction are released; no game/workflow edits, build, CI dispatch/rerun, commit or push by this worker. Root continues the production loop.
