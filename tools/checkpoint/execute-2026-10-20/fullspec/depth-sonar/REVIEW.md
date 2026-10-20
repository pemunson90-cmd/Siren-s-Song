# Independent accumulated integration review — HOLD

Reviewer: /root/release_integration_review, sole independent integration reviewer in this newly restored session. Requested routing gpt-6.1-sol / medium; backend routing/effort telemetry unavailable. Review date: 20 October 2026.

Reviewed head: `25b64e792decfd5ba0adfac542a5af828974c4e5` (`gauntlet/release/depth-sonar`). Production base: `fb4cf10542ba61fb47d4b71a95b0ea0448d302bf`. Accumulated scope: 52 changed files, opening operations0–5 and shared depth/sonar/stealth, presentation, persistence and physical-work consequences. Source tree: `/workspace/Siren-s-Song-play-frozen`.

Read current production AGENTS/USER_DIRECTIVES, then milestone guidance, living specification, source authority, architecture and V7 parity; reconciled latest content priority and complete-milestone requirement. Read CURRENT_HANDOFF, REPORT and REVIEW_HANDOFF. The latter is an explicitly relayed prior HOLD; missing original evidence is not represented as recovered or as my own earlier work. I own this fresh source assessment and the commands/probes below. Tracked implementation remained read-only.

## Blocking finding

**P2 — actual torpedo impact permanently disables a sweeper and invalidates current saves.** `game/src/simulation/sonar_sweeper.gd:9–10` tests `pin_time > 0` but only decrements `stun`. Unlike ordinary threats in simulation.gd, it never advances the eight-second pin clock. Physical projectile impact sets both to8. The next sweeper update lowers stun while pin remains8, violating valid_snapshot's `stun >= pin_time` invariant. After stun expires, pin remains8 and the early return permanently prevents normal AI. This occurs on the newly authored Well DEEP sweeper, through normal command admission and actual projectile movement/impact.

Independent self-contained reproduction: start operation4; stage Quietus at(1280,820), DEEP, facing east; retain the authored sweeper at(1380,820), DEEP; disable peers to isolate receipt; refresh legitimate observations; command knock target0; advance real fixed simulation ticks. Log:

```
target=[{key:0,pos:(1380,820),tag:S1}] launch=true
after2s pin=8.0 stun=6.45000000000001 mode=DISRUPTED valid=false projectiles=0
after12s pin=8.0 stun=0.0 mode=DISRUPTED valid=false
```

Evidence: `independent/sweeper_snare_probe.gd` and `.log`. This probe does not assign pin/stun or bypass physical projectile impact. Its staged mission access is not an earned campaign claim. Player consequence: a legitimate finite countermeasure permanently suppresses the new role, and an otherwise ordinary active save cannot restore. Repair required on same milestone branch: preserve bounded snare lifetime and ordinary/EMP disruption semantics for sweepers; verify actual impact, a valid partial-pin snapshot/restore, expiry/resumed AI, and longer EMP overlapping pin. Also keep physical pin presentation consistent with the retained mechanic. Do not weaken snapshot validation to admit broken clocks.

## Prior blocker / earlier repair dispositions

- Prior same-band torpedo rejection/cross-band spend: **repair verified at reviewed head**. Preview iterates acquired contacts and cached band/transition only; _knock_band uses own occupied bands and geometry without reading live Sirens. Launch rechecks legitimate current acquisition, shared physical projectile band, range, stun and clear3m corridor before spending. Fresh depth95/0 includes SHALLOW/DEEP optical, hidden-roster/position/band/stun invariance, allied observation, both target transition bands, launcher transition, terrain and no-spend cases. The newly found lifetime defect above is a downstream physical-impact/persistence failure, not a rejection of the targeting repair.
- Prior Blackwater selection interruption: **repair verified**. Recovery context/tick use working craft and custody-local Depth.clear; the fresh95/0 reproduces deep buffer recovery with Quietus versus MIDDLE peer selected, and movement/route/loss/depth/transition/cover/custody interruptions. Analogous module/witness/plant repair source inspected and exercised in that focused suite. Actual work remains interruptible.
- Pending-return information leak: **repair verified** by source and fresh opening72/0. Public feedback exposes emitter-owned nominal listening time and received rows; matched hidden queues yield identical feedback/context for emitters and nonemitters while authoritative pending packets still save/restore.
- Repeated depth-toggle beam immunity: **repair verified** in fresh opening72/0, including repeated stationary changes and overlap-band attacks. No transition command resets beam lock.
- Unsafe INSERT: **repair verified** by source and fresh actual headless viewport input44/0 on both target layouts. INSERT duplicates the preceding accepted operator point; it no longer invents an80m step/chord through unknown or blocked water. This does not resolve general craft-handle/FIT usability.

## Accumulated interfaces and additional risk assessment

Inspected authored0–5 operation/configuration progression, per-band geometry/navigation/charts, physical4s transitions and independent craft routes; pressure/motion sensing, acquired-depth pursuit/reports, delayed emission-time sonar/terrain, bearing/triangulation uncertainty, sweeper receipt/strike and local peer reports; presentation/audio permitted evidence; command admission, salvage/custody/extraction, and snapshot reconstruction/validation. New factories use existing catalog/config seams. Baseline MIDDLE work/recovery and independent fleet fallbacks remain represented in source and existing campaign evidence. Fresh95/0 includes registered-operation roundtrips, in-flight echoes/transitions, deep wreck recovery and settled-depth extraction.

A concrete residual selected-geometry seam remains in `module_recovery.gd:87`: recovery classifies MIDDLE drones using sim.line_clear(), whose band follows selection. An independent scan over all registered authored recovery corridors and valid MIDDLE points within65m (10m grid offsets) found **no authored opposing-band obstruction mismatch**. Thus no current player consequence was established and this is **not an additional integration blocker**. Retain as a content-authoring/custody risk if future recovery mouths diverge by depth; local physical recovery should eventually use the recovering craft's band. Evidence: independent/recovery_probe.gd/.log. This bounded scan does not prove continuous geometric equivalence.

No additional blocker established in this review. I did not replay the full source-known rendered journeys or broad regression/performance: prior report already supplies those and no new uncertainty justified repeating them before the confirmed lifetime repair. Existing reported full0–5 finishability remains builder evidence, not independent blind play/balance approval. Existing Well33.6hull tool-free route, first-use balance, FIT/craft-selection/toolbar friction, dense small inner sonar axes, inherited density817/12, ObjectDB exit warning, native lifecycle/performance, headphone audio, physical Fold ergonomics and human enjoyment remain unresolved. Full28/12 content, four further enemy roles, wider fleet/economy/progression/presentation/modes remain unfinished. Approval here would only concern accumulated integration, not complete-release acceptance.

## Fresh commands / outcomes

Godot4.6.3, bash login=false, working directory source tree above. All XDG data is external; original profiles/signer untouched.

```
XDG_DATA_HOME=/workspace/work/depth-independent-depth_sonar_tests-xdg godot --headless --path game --script res://tests/depth_sonar_tests.gd
XDG_DATA_HOME=/workspace/work/depth-independent-opening_depth_tests-xdg godot --headless --path game --script res://tests/opening_depth_tests.gd
XDG_DATA_HOME=/workspace/work/depth-independent-route_program_ui_tests-xdg godot --headless --path game --script res://tests/route_program_ui_tests.gd
XDG_DATA_HOME=/workspace/work/depth-independent-xdg godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/depth-sonar/independent/recovery_probe.gd
XDG_DATA_HOME=/workspace/work/depth-independent-xdg godot --headless --path game --script /workspace/work/gauntlet-fullspec-20261020/depth-sonar/independent/sweeper_snare_probe.gd
```

Fresh results: depth95/0; opening72/0; route viewport input44/0 (both layouts, headless; inherited ObjectDB exit warning); authored recovery scan NO AUTHORED MISMATCH; sweeper actual-impact probe confirms invalid snapshots at2s and12s/permanent pin. All processes exit0; the diagnostic probe prints semantic failure rather than using its exit status as acceptance. Raw logs are in independent/ with matching suite names. No native/render-quality claim and no APK. No broad replay/profile repeat.

Release: all reviewer-owned Godot processes exited; no Xvfb started. Source HEAD remains25b64e7; `git status --porcelain --untracked-files=no` empty. Generated untracked UID files preserved. **Read-only source released to root for same-builder repair. HOLD until P2 sweeper pin/save defect is repaired and independently rechecked on the exact new head.** Root owns builder reactivation, final-head CI and protected PR integration.
