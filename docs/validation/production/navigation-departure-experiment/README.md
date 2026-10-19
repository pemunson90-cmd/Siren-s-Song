# Player-craft near-wall departure · isolated challenger

Experimental and not integrated. Review actual paired clips first in root-owned `../navigation-departure-motion/` (root is encoding the released raw takes). The product delta is only `game/src/simulation/simulation.gd`, supplied as `navigation-departure.patch` plus exact frozen source `simulation.gd`. No shared game, tool, UI, governing document, branch, or loadout file was changed.

## Observed problem and bounded response

The parent investigation's actual16s departure-stop clip and trace show a valid three-segment home route with24m clearance. Quietus starts stationary at(1353.052,618.3444), heading0.23394rad, but nonzero thrust during the near180° turn curves into the basalt below. At49.5s the existing12m collision safeguard clears the route. This is a steering arc leaving a safe planned segment, not evidence of an obstructed AStar path.

The challenger reserves local room while a player craft makes an existing sharp turn (>0.3rad). The conservative circular envelope is:

`12m hull + target thrust speed × remaining angle / 1.8rad/s + current speed² / (2 × 42m/s²)`.

If that envelope intersects terrain or the world boundary, target thrust becomes zero until the turn has enough room. Existing acceleration gradually brakes velocity; the existing rotation continues. This is a local clearance heuristic, not an exact swept-hull prediction or universal collision proof. It may withhold thrust for nearby terrain behind the craft too. No repeated future simulation, persistent controller state, teleport, projection, obstacle/mission exception, new clearance, acceleration, speed, turn rate, resource rule, or sensing change is introduced.

A new optional `_move(..., player_craft=false)` argument is enabled only at the player-unit caller. The Siren caller and default movement path are unchanged. Existing12m collision checking and route-clear stop remain necessary when momentum cannot be arrested in available room. Existing24m routing, near-wall recovery, explicit PASS/STOP, holds, queueing and emergency replacement remain intact.

Original v7 `updateSub`295–309 was read directly. It retains gradual turning and a35% thrust floor, then projects penetrations out of circular obstacles and quarters speed. Production retains its own inertia and genuine collision stop; this experiment deliberately does not copy v7 projection or imply a physically clear route was blocked. The intent is more reliable assisted control while retaining maneuvering character.

## Matched outcomes, gain and cost

`earned-departure.bin` is the unchanged baseline's actual snapshot after ordinary forward-order solo Blackwater recovery, south140m vantages,4.5s holds and finite observed-lock EMP policy. Both drones are explicitly lost at setup; no player pose, resource, enemy or target is forced afterward. This is a naive scripted tactic, not earned campaign progression or an optimal-policy claim.

Both matched replays restore that same existing snapshot using the normal validator. Their restored snapshot digest is identically `54ebaf9d4d74848a0d7cd49b623860a544cd237d5bb1dbe7814b414a3247bc54`.

| Same-state ordinary return | Accepted a178 baseline | Challenger |
|---|---|---|
| Initial time / tools / hull | 47.4s / EMP0,decoy3,survey2 /100 | identical |
| Result | terrain stop49.5s; route cleared | home78.7s; mission won |
| Final hull / tools | 100 /0,3,2 | 100 /0,3,2 |
| First movement after route | 0.0167s | 1.1167s |
| First4s y range | 618.344–648.604 | 618.344–623.141 |

The tangible gain is that the accepted route survives the turn and returns with its records. The visible cost is about1.1s rotating before translating. This is not a promise of safety against enemies or immunity to bad momentum. Headless `matched-*.log` proves the eventual extraction; the16s clips show departure and continued travel, not the whole return or win.

A separate complete ordinary setup+return on each source reaches the baseline's records47.4s versus challenger47.5s, then challenger wins78.8s/100hull/zeroEMP remaining. That0.1s prior approach difference is why the saved-state matched comparison is retained separately. No hull tuning was done to force an old golden result.

Both90° turn directions,180° reversals, quiet Quietus/drone motion and8m/s residual momentum remain viable in generic rectangular-wall fixtures. These wall fixtures are test-only geometry, not changes to campaign terrain. They do not establish all possible departures. In the unavoidable counterexample,78m/s momentum with only18m hull room still stops at0.3s near(513.025,350), route empty and hull outside terrain; preserved in `green-final.log`. No noclip or guaranteed route retention is claimed.

## RED / GREEN and regression boundaries

- `red.log`: initial33 checks/1 expected behavior failure before implementation, exact ordinary return stop. Initial fixture errors were corrected first and retained separately in `red-fixture-errors.log` (custom geometry was not fully restored; queue flags were initially mistaken for actual queue commands). Those are harness errors, not product findings.
- `green-first.log`: initial33/0 after minimal implementation.
- `red-expanded.log` / `green.log`:41/1 baseline and41/0 challenger after adding both reversal directions and open-water comparisons.
- Final `red-final.log` / `green-final.log`:45/5 baseline and45/0 challenger after explicitly measuring gradual braking with residual velocity, limited1.8rad/s rotation, and retaining the unavoidable-stop state. The four added baseline failures describe the missing anticipatory brake, not new source changes between green runs.
- The real existing isolated project core suite `existing-core.log`:293/0. It includes campaign, persistence, waypoint, attention, threat, role and chapter checks. No density/runtime/Android full-suite claim; fresh independent regression and experience review remain required before promotion. No broad rerun after unchanged source.
- Open-water movement digest, four quiet/cruise Quietus/drone traces: `cacac27b54a6a5129176a3966a3b4a150e01500cbbe73178ee63cc1476ff9e3e`, identical on both sources.
- Equivalent180-step enemy-call movement digest: `bfd8f334de7583807e4ff26071b39c370df5992ace0679bd262c8ce75d2bb520`, identical on both sources. This is exact for those inputs; no claim that enemies encounter identical situations after a player changes position.
- Pause snapshots, existing restore and future maneuver equality, emergency replacement while queued, ordinary queued PASS/final STOP and final physical hull clearance pass. Test controller calls real existing commands and movement, not a second imitation model.

## Actual footage and retained failures

Final raw captures were released read-only for root encoding:

- `work/navigation-departure-experiment/frames-baseline/`
- `work/navigation-departure-experiment/frames-challenger/`
- `work/navigation-departure-experiment/frames-idle/`

Each has240 full1280×720 PNGs and chronology; raw engine logs are sibling `capture-{baseline,challenger,idle}.log`. Root owns durable encoded footage/frame selection/probes under `../navigation-departure-motion/`; no duplicate encodes here.

The corrected common `capture.gd` first starts mission2 normally, restores the same baseline-earned snapshot, then issues a single ordinary home-route command before frame0 for both departure takes. No tactical commands occur within either16s clip. The standalone idle take issues no route or other tactical command at all after restore; simulation time/oxygen/AI continue16s. No new actor positions or hidden observation are exposed. Visible contacts may remain old echoes or expire; unseen enemy activity is unknown to the player. The idle footer retains the existing historical 'Mission restored · paused for review' message even though the REAL TIME header and advancing simulation establish that it is unpaused; this is qualified stale copy, not proof of frozen AI.

Normal2× zoom and own-position-following pan are applied programmatically with the existing camera API, identically on both sources. This keeps the departing craft in view without changing routes or world state. It is not OS camera/touch input. Root's prior fixed-view failure clip remains preserved in the parent investigation.

`weak-capture/` retains the earlier controller, each raw log/chronology and final frame. Those encounters were mechanically valid but the fixture restored simulation without setting the UI mission index, producing an incorrect '01 Blackwater' header. That controller also used a fixed close camera so the moving craft eventually left view. It was corrected before final evidence; weak full raw sequences remain in ignored work. No product source was altered to fix the fixture. Original final source frames were visually checked during capture; encoded playback inspection belongs with root's motion release.

Godot4.6.3 Compatibility/OpenGL3; software Mesa llvmpipe, Dummy audio;1280×720 desktop15fps fixed capture cadence. V-Sync-not-supported is a renderer limitation. No native Android performance,420dpi layout, physical Fold7, human control comfort, full campaign/native, audio quality or shipped-reference motion victory is claimed. The reference comparison for assisted navigation is pending suitable matched footage and independent judgment.

## Cost measurement

`benchmark.gd` measures five batches of2000 complete simulation ticks per condition with all three player craft, fixed repeated inputs and no Sirens; it includes sensor/clock overhead. Median microseconds/tick on this desktop:

| Synthetic condition | Baseline | Challenger | Difference |
|---|---:|---:|---:|
| aligned/open | 205.735 | 188.048 | -17.687 |
| sharp/open | 212.205 | 228.864 | +16.659 |
| sharp/near | 222.355 | 257.527 | +35.172 |

Aligned-time improvement is measurement variance, not an optimization claim. The meaningful work addition is at most one extra `blocked` scan for each routed player craft making a sharp turn in each60Hz tick. The sharp fixtures suggest tens of microseconds total added CPU on this machine, not future-simulation cost. Sequential batch scheduling and varying sensor work limit precision; this is not a render/frame-rate or Android budget certification. Raw five-sample logs are retained.

## Exact isolation and reproduction

Both copies were made via `git archive a178825fc4885f9f3ab191315302925ab0cdac87 game` (137 tracked files, no import cache). `baseline-source.json` records all hashes; `source-freeze.json` verifies the baseline remains unchanged and other136 original files are identical. Generated import caches/UID files are excluded from the candidate patch.

- Baseline simulation SHA256: `f69be61072eaaa4c36a24932d7ec705a65f5389fb4f4283e045c7a5a58ef1884`
- Challenger simulation: `d1bad2ca17fa28c1f8faa3ce2a7e4d1c91cf5ba2ad79df98c4bcb0d193431641`
- Patch: `1c60a983482c2b3dc5d2ed0ad260426f7e9c3a62a3bf4e6d602ad16d5d179834`

From repository root, on an imported isolated copy:

```sh
TOOLCHAIN_CACHE="$PWD/work/toolchain" GAME_DIR="$PWD/work/navigation-departure-experiment/challenger/game" XDG_DATA_HOME="$PWD/work/navigation-departure-experiment/reproduce-userdata" scripts/toolchain/headless.sh --script "$PWD/docs/validation/production/navigation-departure-experiment/verify_departure.gd"
```

`matched.gd` and `response.gd` accept the absolute `earned-departure.bin` path after `--`. `capture.gd` accepts `--fixture=<binary> --folder=<scratch>` and optional `--idle`; use existing display.sh/Godot1280x720 fixed15fps with isolated userdata. No toolchain changes are required.

Brainstorming/TDD/isolation/debugging/verification principles were applied; the explicit autonomous bounded assignment supersedes routine approval gates and requested isolated archives supersede branch/worktree creation. No nested worker or premium escalation. Requested Sol6.1/high; actual backend/cost telemetry unknown. Root owns review, integration and publication; this checkpoint is an experimental release, not the end of the Gauntlet.
