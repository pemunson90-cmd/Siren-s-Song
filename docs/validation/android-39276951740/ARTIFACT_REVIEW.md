# Native7feb milestone: bounded resume evidence, failed gallery scroll, rotated signer

**Do not promote this APK as a successful native milestone or compatible update.** The completed native log fails at the Blackwater gallery-navigation capture. The APK verifies cryptographically but has a different development certificate. The useful scoped result is that both actual same-resume final frames are readable paused missions, independently of later cold restore.

## Exact source and failure

Run [39276951740](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39276951740), job118143668785, source **7febd8d6e4f6227b14f9b27f97428b34e25fb6bb**, tag `gauntlet/milestone/2026-10-19-navigation-well-resume`. Automatic push event15:19:29UTC,19October2026. Native step begins15:22:31UTC. [Completed job log](job.log) records:

- Cover and inner resume capture brackets pass, ordinary Shelf record/extract/save and fixture Well response pass; genuine Shelf archive restored at15:36:00UTC.
- Cover Blackwater request earned15:37:24UTC, paused cold restore verified15:37:43UTC.
- **15:38:22UTC:** `Fresh stable menu state around screenshot missing: cover blackwater-evidence-scroll-1`.
- Failure cleanup starts immediately; native process exits1 at15:38:31UTC. This is **not a25-minute timeout**. Artifacts finalize15:39:01–08UTC and job cleanup ends15:39:09UTC.

The jobs/run APIs intermittently omitted steps, timed out or continued reporting in_progress after these completed logs/artifacts existed. Historical monitor files retain the actual responses; those observations are superseded for the native outcome by the explicit process failure. No successful native result is inferred from stale status or uploaded artifacts.

## Cause supported by actual pixels and metrics

[Last accepted scroll0](screenshots/cover-menu-blackwater-evidence-scroll-0.webp) shows the menu bottom: loadout/settings. The **auxiliary** [failed scroll1 geometry probe](screenshots/cover-menu-blackwater-evidence-scroll-1-geometry-probe.webp) shows the same bottom and highlighted loadout button; it is not a final gallery screenshot. No scroll1 final, gallery final or inner Blackwater frame exists.

[Extracted latest metrics/targets](failure-metrics-summary.json) show the first swipe moves scroll_vertical0→1254, newest complete metrics_count114. The evidence target moves from logical y1173 to **−81**, above scroll viewport y46..674. The parser still proposes another upward swipe `[1328,823,1328,304]`. At the bottom this produces no new scroll report; count remains114. The pending report correctly says `fresh complete atomic metrics after previous input`, then strict capture fails. No SS_LOADOUT event was found in that failed log; the highlighted control is not evidence that equipment changed.

Next minimal diagnostic: replay the menu parser with this exact count114/layout and target-above-viewport trace; inspect overshoot/direction handling. No longer sleep, weakened freshness or silently accepted probe is justified. Root owns any subsequent tooling correction. This evidence task changes no source and launches no rerun.

## Downloaded bytes and signing

All four existing artifacts were retrieved through the supported GitHub download connector and its returned FileService download URL, streamed through normal proxy/CA. No signed URLs were printed/persisted, FileService IDs were not passed to Sediment, and no network control was bypassed. Raw ZIPs/extracted files stay ignored under `work/android-39276951740/` in this evidence worktree.

| Artifact | ID | ZIP bytes | Verified SHA256 |
| --- | --- | ---: | --- |
| APK |12199462789|69176591|`fb5448f3584e5af60cc3690890784d507399eeca0dae24d8c2779786bacbf734`|
| Cover |12199657624|19213120|`535ad1ec2497e3d8863606f1f3681537c1268c46386c52bd4ed80d4e5688d28b`|
| Inner |12200112281|28383377|`fdbe75227f7dcd24510195643a55002ce340ba0cba25b451dc8d02e36c626b20`|
| Runtime |12199822566|220235187|`3702235d00bf09c00442d89df0bc06d2b8dacf713f91903e4f7e3f587438771a`|

[Official metadata](artifacts.json) sourceSHA/sizes/digests and all ZIP CRCs match local bytes; safe extraction has36cover/34inner/578runtime/3APK entries. [Byte verification](download-verification.json). APK **69,573,419bytes**, SHA256 **`37e57f1c9e3cdeaeb8c71043e752ca95a85892d61fd33cc0d5b967cfa57fd4df`**, matches the archived hash.

[Local apksigner](downloaded-apk-signature.txt) verifies v2/v3, one RSA2048 development signer, certificate SHA256 **`8be2830c5090cf60ee4363870fb4e33e27e777144f71c887263c68db4fc91782`**. It differs from preserved **32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c**. Do not label this APK update-compatible with those builds. No over-install/uninstall or private-key retrieval was attempted.

The job log explicitly reports signing-cache miss and new RSA/self-signed certificate generation at15:20:38UTC. [Root's read-only gh cache metadata](signing-cache-metadata-root-gh.json) records new tag-scoped cache9169344382 versus preserved production cache9141003475. That metadata is attributed to root; this worker independently verified the resulting APK certificate. The public connector rejected the cache-list endpoint; no repeated endpoint workaround or key download followed. Root owns the separate future trigger/ref correction; it is not credited to this7feb APK.

## Actual visual scope and retained gains

[PNG inventory](png-inventory.json) hashes all70 cover/inner PNGs: **44final-labelled,2explicitly unverified immediate,24geometry probes**. Three contact sheets inspect all46 nonprobe views for overall identity;21 selected originals were opened individually at full image view, including the failure probe. These21 have retained lossless WebPs with identical decoded RGBA pixels. The contact sheets are reduced overview images, not fine-text or pixel-equality proof. This avoids duplicating the entire previous run's visual archive.

| Actual view | Observation and limit |
| --- | --- |
| [Cover immediate](screenshots/cover-resume-immediate.webp),[final same-resume](screenshots/cover-resume.webp); [inner immediate](screenshots/inner-resume-immediate.webp),[final same-resume](screenshots/inner-resume.webp) | All4 show readable paused Shelf missions. Both final candidates pass attempt0 actual RGB nonblank guard, fresh foreground/postdraw state and matching semantic/geometry bracket. **Immediate frames were already readable**, so this run does not reproduce black→recovery or isolate a causal latency benefit of the guard. It supports correct final same-resume presentation in this run only, not universal lifecycle repair. |
| [Cover cold restore](screenshots/cover-restored-gameplay.webp),[inner cold restore](screenshots/inner-restored-gameplay.webp),[inner optical exposure](screenshots/inner-camera-exposure.webp) | Correct paused mission/restoration footer and actual OPTICAL/DRONE A00%/EXPOSING states. They are separate from same-resume proof. |
| [Cover primary](screenshots/cover-touch-targets-primary-initial.webp),[inner primary](screenshots/inner-touch-targets-primary-initial.webp),[cover secondary](screenshots/cover-touch-targets-secondary-initial.webp),[inner secondary](screenshots/inner-touch-targets-secondary-initial.webp) | Selected Quietus bow chevron is visible; complete controls/route intent remain readable. No consequential control clipping/overlap observed in these states. The launch cluster places the chevron near DroneB; no human interpretation/ergonomic verdict follows. |
| [Cover settings](screenshots/cover-menu-settings.webp),[inner settings](screenshots/inner-menu-settings.webp),[cover loadout](screenshots/cover-menu-scroll-0.webp),[inner loadout](screenshots/inner-menu-scroll-0.webp) | Correct screens and readable comparison; cover effects/mute require scroll and fixed BACK remains visible. Action-target images are not proof of post-tap mute/volume values. |
| [Well plan](screenshots/inner-role-lure-planned.webp),[return](screenshots/inner-role-return.webp) | New PATTERN ARRAY/PROFILE APERTURE/RETURN ARCHIVE labels,15s decoy and selected Quietus cue visible. Native protocol exercises hunter response/return, **not signature acquisition, camera illustration or optional record gallery**. Those features are not natively accepted from these frames. |
| [Cover receiving](screenshots/cover-blackwater-receiving.webp) | Actual HYDROPHONES/QUIET RECEPTION and full settling hint; REQUEST RELAY00%,S1PATROL→DRONEA/BEAM2.6s and finite DISRUPT row visible. No inner reception/gallery claim after the later failure. |
| [Shelf debrief](screenshots/inner-mission-completed.webp) | ARCHIVE RECOVERED,17s/100%hull/119%life support; campaign cold-restore logs pass. This is not full campaign/finale acceptance. |

Godot postdraw is app-render evidence, not Android compositor acknowledgment. Nonuniform pixels do not establish scene semantics; actual views above were inspected separately. Emulated420dpi/Pixel7/API36/swangle/x86_64 is not physical Fold7, performance, listening or newcomer acceptance.

## Persistence and remaining gates

[Native evidence verification](native-evidence-verification.json) independently confirms6successful semantic/geometry capture brackets (resume2,restore2,optical1,cover receiving1),17stable menu brackets and the separate pending count114 failure. Four downloaded binary comparisons pass: untouched fixture injection on cover, earned request versus paused cold restore, genuine primary restoration and genuine `.bak` restoration. Raw compact archive files are retained in `blackwater/`. Original `.tmp` was absent per strict helper; cleanup removal succeeded, but no independent remote post-cleanup stat is captured. Root-level Well raw backups are outside the workflow whitelist; that earlier restoration has its strict helpercmp/log proof.

Default pre-native checks pass **293core/308runtime/38loadout/45navigation/9Well-save-shape/1057density/7menu/15scroll/68transport**, plus Python10role/9transport/30menu/20capture/9resume/17Blackwater/8view/27geometry and archive mock ([summaries](test-summaries.log)). Native strict final error scan and full Blackwater sequence are **not reached**; an empty runtime-errors.txt does not convert this failed run to a clean final gate.

Preserve [20de inspected artifacts](../android-39266427532/README.md),0afe/f1ea fallbacks and the historical black resume originals. Completion preflight fetched149069b25ebf646bff27a986cdd11698e5e969d8; all four full cached governing files, the living spec and v7 parity ledger were read/applied. The living spec is byte-unchanged from89c7889, read during monitoring. Source and evidence here remain exact7feb. No source/tooling/governing edit, rerun, dispatch, push or adoption-only critic. Root is sole evidence integration reviewer. Explicit Sol6.1 routing; actual backend/token/cost telemetry unavailable. Worker completion releases this scope; Gauntlet continues.
