# Physical knockdown torpedo · experimental feature packet

Feature branch `gauntlet/feature/targeted-knockdown`, base `bd8f1a5a4065fe71f8753e73eae15b19ef188b71`. Current policy adopted at boundary `dced64ffc1dddd9e93f13a029cc44b5e7daa93cd`. Root integrates after the one designated reviewer; this packet is not a native/whole-game acceptance claim.

Quietus gains two finite torpedoes on a **fresh** dive. MORE ORDERS → TORPEDO → tap a fresh S# inside 150m with Quietus sight. CANCEL, another order, unit switch, menu/lifecycle or leaving the page exits targeting. Invalid taps stay in targeting and never plot routes/spend a round. Old active saves missing `knock` retain their exact stock and cannot fire. No stock is added on restore.

A valid launch spends a round immediately. The own physical projectile starts on Quietus's position/heading, steers independently at 3rad/s, travels 180m/s, and expires after 3s. Its launch is audible (650m event); motor emits short 430m events every 0.2s. The target's acquired position updates only through Quietus's actual passive reach and clear sight; after sight breaks it holds the last acquired point. Swept terrain/structure collision ends the shot. A physical Siren impact alone starts the eight-second snare: beam interrupted, world position held, original cable wrap and silhouette shrink/depth fade/recovery. No x/y descent teleport or enemy nerf. Radial EMP retains 340m/12s and affects multiple Sirens; snare/depth and EMP clocks compose separately.

150m is the tested initial current-scale choice, not a claim of settled balance. The late shot demonstrates a genuine heading/travel cost. Original v7's actual `doKnock`/pointer/stun branches supplied two rounds, 150 range, 8s instant pin and descending tone. The newer user direction replaces its instant effect with flight/impact. Its omniscient target overlay/global Hunt spikes were not copied: own emissions and struck-target local suspicion provide pressure within current sensing architecture. Original authored drawing/PCM; no external art assets.

## Actual footage, controls and outcomes

All four [motion clips](motion/) are actual Godot4.6.3 Compatibility/llvmpipe player views, 1280×720, 15fps, 240 frames/16.000s each, silent Dummy audio. PNGs were rendered after each 1/15s simulation advance; offline capture cadence is not a realtime performance measurement. Fixed ordinary 2× zoom and one initial own-position pan, no later camera rescue. Commands use the ordinary Simulation API, not human/OS touches. No injected actors, locks, safety, hull or tools in these motion takes.

`prepare.gd` starts mission4 (Listening Well), disruption equipment, toggles SILENT to CRUISE, routes to `(820,520)`, advances 6.9s. The resulting genuine current-source snapshot has incoming momentum, a fresh S2 lock and full initial finite tools. Each take restores this exact same binary state (hash in `source.json`), and reissues/asserts the identical existing route solely to replace restore narration. **No-input means no new commands during the clip; the accepted route continues moving Quietus.** The common restored-snapshot hash is `9d8ac2b8d8f3d566406010593a003a07f03e46c87a60fe87be0688b51a946db9` (controller's SHA256 of hex-encoded serialized snapshot, distinct from binary file SHA256).

| Take | New commands after restored start | Outcome |
|---|---|---|
| `idle.mp4` | None; standalone no-input world continuation | Loses at mission14.767s, clip+7.867s; knock2/EMP3 |
| `torpedo.mp4` | +1.0s one valid S2 launch; original route continues | Impact about+1.6s; observed descent, eight-second pin and recovery; loses at19.433s/+12.533s; knock1/EMP3 |
| `emp.mp4` | +1.0s EMP; original route continues | Observed disruption; loses at19.433s/+12.533s; knock2/EMP2 |
| `late_miss.mp4` | +1.0s emergency west `(420,580)`, +2.6s valid S2 launch | Independent steering misses/expires, no refund, loses15.633s/+8.733s; knock1/EMP3 |

The first three are a matched weapon/no-input comparison; the late take changes route and firing time and is a retained failed tactic, not that same causal comparison. After loss the remaining frames honestly show the debrief and stopped simulation clock. Contact JSON uses observed cache only; own projectile state is known weapon telemetry. Engine diagnostic logs may contain internal role telemetry and are not player-facing knowledge.

Decoded contact sheets and eight full torpedo frames accompany the MP4s. Torpedo sheet frame order:0,17,24,36,100,140,146,239. Flight sheet covers every frame15–24. The wrapping/depth shrink is visible; late recovery occurs around frame140, before fresh locking resumes. Hull can drop while S2 is visibly pinned: player view does not establish the other damage source, and a one-target snare promises no protection from other threats. Historical footer is not a live countdown. The late-miss final take explicitly reports its own run ending/shot spent.

Earlier **headless ordinary-command** emergency probes are retained in `probe-ordinary.gd/.log` and `probe-late.gd/.log`: same setup, emergency at+1s; no-tool loses, torpedo+1s finishes the 16s interval hull67.3%, EMP+1s85.3%. These show a possible reposition window, not extraction, a human tactic, or rendered footage. Later shot timings were retained, not tuned toward guaranteed survival. The full-rendered unchanged-route takes show that spending a tool alone does not solve the encounter.

## UI, verification and limits

Six [UI views](ui/) use genuine engine mouse clicks on TORPEDO/observed contact at desktop, cover2520×1080/420dpi with136px left inset, and inner2184×1968/420dpi. These **presentation fixtures** position Quietus and two real Sirens in open water, advance actual AI0.4s for a fresh beam, then pause; they are not earned campaign motion. Targeting explains noisy flight/impact8s and visible cancellation; the launched views show stock1. Enemy beam is drawn above muted own targeting guidance. Camera primary remains, duplicate secondary CAMERA is replaced, no extra row/touch reduction. Actual images show the target/ship/objective area can be busy when contacts overlap; no human-device comfort claim.

- `core-red.log`: missing feature; `projectile-red.log`: superseded instant effect fails physical contract. `superseded-instant-green.log` is historical, explicitly rejected by newer user direction.
- Final `core-green.log`:59/0. Covers physical travel/impact/miss/terrain/sight break, only-one target, EMP distinction, finite ammo, invalid/stale/drone targets, in-flight/partial-pin pause and binary save/restore, malformed new state, accepted legacy archives with no free charges, bounded PCM.
- `expiry-feedback-red.log`: real missed-shot footer defect caught before minimal correction. `expiry-save-red.log` preserves a separate post-pin save rejection corrected without tightening legacy negative expired stun clocks. `pin-clock-red.log` retains clock-composition failure.
- Final genuine input/GL `ui-render.log`:30/0; `ui-stale-red.log` retains rejected fresh-cache/live-position tap incorrectly leaving targeting before correction.
- Affected existing runtime316/0 and density1057/0 retained. No broad suite, native build, physical-device or subjective audio verification here.

`source.json` records exact final source/media hashes and narrowly qualified copy-only capture differences. New simulation work is bounded to at most two three-second projectiles; no full future simulation/new manager. Final source files are those eight entries plus the own new test UID. Root must reconcile secondary PROGRAM slot, acoustic helper/whitelist and campaign debrief hunks with their separate owners.

For a native milestone, earn the same fresh setup rather than editing a genuine user archive. Scripted fixture may call `start(4,"disruption")`, `silent`, route820520, advance69×0.1s, pause; selectQuietus, MORE ORDERS, TORPEDO, tap the real fresh S2 screen target, then resume. That starts a valid150m shot with two fresh rounds and actual sight. Save a separate fixture archive or use existing genuine-backup tooling, never replace the user's archive. Existing legacy role fixture has no `knock` key and correctly cannot exercise launch. Capture about0.7s flight, then8s observed wrap/shrink/recovery; a non-emergency unchanged route retains the documented loss.
