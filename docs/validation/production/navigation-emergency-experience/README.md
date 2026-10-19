# Near-terrain emergency replacement · desktop experience probe

Evidence only: no new product feature or shared source change. Inspect the five actual [16s clips](motion/) before the interpretation below. All use the same initial save, authored encounter, camera and command timing; EMP takes are a separate causal comparison. This extends the reviewed steering experiment into a real visible-threat encounter, not native or human acceptance.

## Actual clips

| Clip | Commands during16s | Observed result |
|---|---|---|
| [Baseline with one EMP](motion/baseline-emp.mp4) | +1s emergency west, then one disruption | Turns into the north basalt; route clears by sampled+4s. Later visible patrol beam damages the stopped craft; final hull27.4. |
| [Challenger with one EMP](motion/challenger-emp.mp4) | Identical | Brakes/turns without clearing the route, then reaches the west point. Final hull85.3, not safe or extracted. |
| [Baseline without EMP](motion/baseline-noemp.mp4) | +1s emergency west | Terrain stop, firing hunter, actual SIGNAL LOST debrief at elapsed15.633s (+8.733s). |
| [Challenger without EMP](motion/challenger-noemp.mp4) | Identical | Clears terrain and reaches the west point, but the visible hunter keeps firing. Same loss time and real debrief. Steering is not protection. |
| [Standalone no-input world](motion/idle.mp4) | None | Original cruise approach continues; visible hunter resolves its beam and Quietus is lost at elapsed14.767s (+7.867s). No protective commands or new route. |

Each file is1280×720,15fps,240frames,16.000s, silent. Each accompanying folder contains six full source frames, a decoded1fps sheet, chronology, all240 raw-frame SHA256s and ffprobe metadata. I inspected all five decoded chronological sheets plus full initial/threat/turn/end/debrief frames. This is successive decoded-frame inspection, not a human normal-speed input/comfort test. Clips are identifiable and labeled: nonblind. Matched Door Kickers reference footage/independent verdict is root-owned and pending; no shipped-game victory or play recommendation is claimed.

The pair demonstrates more dependable accepted intent in a tactically consequential location. One finite disruption buys time on both sources; only the challenger uses that time to reach the intended point instead of remaining caught at the rock. Neither pair proves an optimal escape or mission success: no records are collected, the challenger still takes damage and the endpoint remains within an active pursuit. No enemy, health, tool stock or sensor rule was changed to create the difference.

## Ordinary, observed setup

Both sources start the same ordinary fresh mission4 (chapter05, The Listening Well), disruption loadout, all three craft alive at their normal positions. The controller toggles SILENT to cruise and issues route(820,520), then advances normally without tools. At elapsed6.9s the baseline snapshot is retained as `clip-initial.bin`:

- Quietus(571.2907,622.4368), velocity(72.12212,-29.7052), heading−0.3907rad, hull100.
- EMP3, decoy3, survey2; both default drones remain alive at home, unused.
- Actual observed S2 hunter contact: LOCKING0.783s, age0.05s, position(770.243,651.6971). This is the ordinary passive observation, not an injected/cached contact.

The movie restores that exact save through the normal validator and reissues the existing route once before frame0. An assertion confirms the resulting route is identical; this ordinary continuation command clears the historical restore footer without inventing a message. All five restored-state digests equal `0af173dd9d6dfe8d814e41fe7a2424cf9de05dc8b26134a67dfae1e6ba59a601`; initial player state and initial command are exactly equal.

The first second shows the incoming approach and legitimate visible threat. At elapsed7.9s/frame15, paired takes issue ordinary `emergency` to(420,580); the EMP pair immediately issues one ordinary `emp` at the same timestamp. At that point Quietus is near(643.4123,592.7318) with78m/s incoming speed and the fresh hunter lock around1.78s. Both sources receive exactly the same event and spend the same charge. `paired-verification.json` checks equal initial states/commands and stocks: EMP2 only for EMP takes; EMP3 otherwise; decoy3/survey2 unchanged. No scripted second protection, free stun, forced pose, resource refill, friendly enemy seed or post-loss reset occurs.

These are direct ordinary simulation commands, not OS taps, chart gestures or human reflexes. The scripted response at+1s is not a measured reaction-time result. Normal `_debrief()` is called on a loss, so the actual SIGNAL LOST screen appears and simulation elapsed time stops. The remaining movie frames retain that loss; encoded16s does not imply16s of living world after destruction.

Selection used only fresh observed contacts, own speed and charted terrain proximity. `discovery.log` retains four earlier approaches that failed to produce a nearby moving visible threat; the fifth ordinary approach qualifies. No scenario uses hidden Siren coordinates to steer or choose tools. Existing read-only `SS_ROLE` raw diagnostics and the deterministic binary save necessarily contain simulation truth; those are developer reproduction data, not player observation or evidence that an unseen enemy was perceived. Player claims and chronology use the normal sensor contacts. This is a fresh-mission fixture, not an earned campaign playthrough or a private save.

## Causal limits and retained failed tactics

`probe-{baseline,challenger}.log` retains the immediate7.9s emergency with three ordinary destinations, with/without one EMP. `probe-delayed-*.log` retains the same original save with a one-second later replacement at8.9s. That delay makes the west emergency collide even on the challenger: existing momentum cannot be arrested in the remaining space. It is a useful physical limit, not a new regression or a reason to erase collision stops. Southward alternatives also retain losses/damage; no endpoint is marketed as universally safe.

`probe-clip-*.log` starts the actual6.9s clip save, advances1s, then runs16s after the emergency. Its total horizon is17s after that save, one second longer than the16s movies. Thus its west/EMP final hull9.4 versus67.3 differs from the movies'27.4 versus85.3. These horizons must not be conflated. Without EMP, both routes lose, while idle loses earlier; better route following does not remove the need to plan distance, cover, tools and the next order.

At sampled+15s the challenger has only an aging last-seen disrupted hunter contact, not proof the hunter remains stunned. The final full frame legitimately observes its renewed lock; hull has fallen to85%. The player-facing observations do not by themselves identify every source of damage before reacquisition. No hidden diagnostic attacker identity or enemy causal certainty is inferred here. The old disruption-event footer persists after its12s effect window; that is historical copy, not a remaining-effect timer.

## Camera, gaze and remaining comprehension burden

All takes use the ordinary existing2× zoom and one initial own-position pan, then a fixed camera throughout. There is no automatic following or within-clip camera intervention. Initial frame000 shows Quietus, its original point, the north basalt edge, the on-screen hunter/lock arc, the fresh countdown strip and right-side controls. The emergency's west point and the subsequent craft travel stay inside this view; no extra pan is required for this deliberately local maneuver.

This is a more demanding visible decision than the previous empty-threat departure. The player must connect the upper-left threat countdown, the craft's changing heading/momentum and nearby terrain, the relocated west route marker, and the right-side DISRUPT control. The route line/ROUTE status persist during the challenger maneuver and disappear with the baseline stop. Actual full frames make those different outcomes inspectable. The brief braking/turning remains physically costly; no instant heading or velocity change appears.

The same close view excludes the full home route, other sectors and some idle-drone context. Later enemies/halos can approach the zoom-control edge. This fixture's fixed framing reduces camera work compared with an unconstrained player, despite having no auto-follow; it does not establish that human pan/zoom and emergency input remain comfortable under pressure. No actual touch latency, accidental orders, eye tracking,420dpi/native Fold7 cover/inner layout or OS gesture performance was tested. Those are the next useful evidence gaps, not reasons to claim a new UI feature from this probe.

My bounded interpretation: the reviewed steering gain remains useful and readable here through preserved intent and visible turn/brake motion, while tactical survival still requires finite resources and follow-up. Independent experience review should judge that reading against the actual clips and suitable reference section. No further production change is proposed or implemented by this evidence release.

## Source, backend and reproduction

Both138-file copies were created with `git archive 20de5cd2f7aaabd96790cfbe67840e22c07c66fe game`. `source.json` records every original file and verifies baseline bytes remain unchanged. Challenger changes only simulation.gd to the previously reviewed exact steering source:

- Baseline simulation SHA256 `f69be61072eaaa4c36a24932d7ec705a65f5389fb4f4283e045c7a5a58ef1884`.
- Challenger simulation SHA256 `d1bad2ca17fa28c1f8faa3ce2a7e4d1c91cf5ba2ad79df98c4bcb0d193431641`.
- All other137 original files are identical between these copies. Imported caches/derived UID files are excluded. No source from root's concurrent local integration was mixed into the pair.

Relevant original v7 `updateSub`295–309 was read for the preceding reviewed change: gradual turning with a35% thrust floor plus penetration projection contrasts with production's gradual vector braking/turning and genuine collision stop. This probe changes neither reviewed source nor that documented departure. Existing sensor boundaries and ordinary disruption340m/12s effect,650m audible emission remain unchanged.

Desktop Godot4.6.3 Compatibility/OpenGL3; Mesa llvmpipe software renderer,95dpi fallback, Dummy audio,1280×720 windows. Fixed15Hz simulation/encoding plus blocking PNG capture is a reproducible sampling cadence, not a real-time frame-rate measurement. Unsupported V-Sync warnings are retained; final logs contain no SCRIPT ERROR / ERROR. No new performance benchmark or broad suite was run for this footage-only assignment; the already reviewed source's synthetic cost and integration gates remain separately qualified. No Android, sustained thermal, subjective audio, full campaign or human acceptance claim.

Controllers, actual baseline binary snapshots, raw logs, paired verification and media hashes are retained here. Complete raw240PNG sequences stay ignored under `work/navigation-emergency-experience/frames-*`. From repository root, with imported isolated copies:

```sh
TOOLCHAIN_CACHE="$PWD/work/toolchain" GAME_DIR="$PWD/work/navigation-emergency-experience/baseline/game" XDG_DATA_HOME="$PWD/work/navigation-emergency-experience/reproduce-userdata" scripts/toolchain/headless.sh --script "$PWD/docs/validation/production/navigation-emergency-experience/prepare.gd"
```

`prepare.gd` writes the ordinary6.9s snapshot in task scratch; `capture.gd` accepts absolute `--fixture=<clip-initial.bin> --folder=<scratch> --take=emp|noemp|idle`. Start a checked existing-display.sh backend, use the selected isolated project,1280×720, `--fixed-fps 15 --audio-driver Dummy`, and the capture script. `encode_clips.py` is the retained existing encoder pattern adapted only to this evidence path; it verifies dimensions/cadence/240frames/16s and records hashes. It is not a shared toolchain/CI change.

Requested Sol6.1/high; actual backend/cost telemetry unknown. No nested agents, new product code, commits, pushes or shared source/governance changes. Root owns publication and independent review. This bounded release continues the Gauntlet and does not set an overall completion point.
