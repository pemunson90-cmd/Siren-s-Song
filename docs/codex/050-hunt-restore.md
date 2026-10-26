# Handoff 050: HUNT RESTORE, V7 global Hunt pressure made visible

Status: DONE
Claimed at: 2026-10-26 01:41:36 UTC
Claimed by: codex
Finished at: 2026-10-26 23:48:35 UTC

Precondition: handoff 023 is DONE or paused by Pat (it holds main.gd and HUD files), and the design PR for docs/design/HUNT_RESTORE.md is merged into claude/integration. If roadmap Phase G (AI state trace) has landed, log hunt stage changes through it; if not, build without it. Source of truth: docs/design/HUNT_RESTORE.md (read it fully; section 8 lists numbers Pat may still adjust, build them from the table so changes are one-line edits). Pat, 24 Oct: "we also need to restore the hunt mechanism from v7 parity". AI-DESIGNED details, Pat to ratify.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Never change the 4 s lock window, beam, collision, damage or hull rules. Do not commit generated .uid files that integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
The Hunt meter already exists (game/src/simulation/recon_consequences.gd) but only changes a hidden per-Siren multiplier. Make the global Hunt scale how far Sirens notice a craft, as V7 did, and make it visible and audible.
1. New module game/src/simulation/hunt_pressure/ with hunt_table.gd (all numbers, a static enabled flag, revert note) and hunt_pressure.gd (pure functions). One seam: HuntPressure.observe(sim, dt) called once after Recon.tick in simulation.gd, plus one changed line in Recon.readiness: the larger of the existing local value and the guard's hunt_scale. Stamp hunt_scale only on patroller, sentinel, hunter and sweeper. Use the V7 stage table 1.0, 1.15, 1.3, 1.5, 1.7, capped by the per-op table in the design doc (ops ids 0 to 2: 1.00, 3 to 5: 1.15, 6 to 13: 1.30, 14 to 21: 1.50, 22 to 29: 1.70).
2. Action table per the design doc: decoy and survey change from 4 to 0, add +6 when any Siren starts seeing a craft after none did; everything else unchanged. No graze, no hull damage, no goals or reports given to Sirens.
3. Meter in presentation/hunt_meter.gd: chip "HUNT · STAGE x1.30" with five pips, word plus pips (not color alone), at least 48 dp tall, visible in basic and advanced HUD, clear of the warnings stack, tap to explain in pause. Verify both Fold7 shapes and 960x432.
4. Sound: a stage-up cue (at most one per 3 s) and ambience offset +0, +1.6, +2.9, +4.1, +5.1 dB by stage, capped at +3 dB on ops 0 to 5. Update the soundscape comment that says Hunt is never read.
5. Optional validated save field mission.hunt_pressure {revision, stage, seen}; absent means inactive (old saves and in-progress ops unchanged). Register the validator beside the others in persistence/save_checks.gd. Confirm saved Siren validators accept a hunt_scale key or exclude it from snapshots.
6. Flag off gives exactly today's behavior.
Tests (new suite, append to tests/suites.txt): determinism and save/restore replay; each action adds its table amount; decay, delay and floor; cap per op; excluded roles unscaled; max rule with a local floor; lock/beam/damage identical flag on and off; old save loads unchanged; corrupt field rejected; meter by real touch; ops 1 to 5 journeys still win bare with identical results; photo price tests rebased only above stage 0.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-hunt-restore

## Files you may edit
The new hunt_pressure module and its tests, presentation/hunt_meter.gd, the one readiness line, the one observe call, the soundscape read of the stage, the save-check registration, one HUD anchor call.

## Files you must not touch
Lock, beam, damage, hull, collision rules, sensors outside readiness, patrol goals and routes, contact reports, listening network, story text, opening balance.

## What done looks like
Hunt raises Siren notice radius by the V7 stage factor within caps, shown on the HUD in every mode, audible on stage rise, off-switchable, old saves untouched, tests green, CI green on the exact head.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
Sight-only Hunt, readable meter/help, stage audio and compatible optional saves merged in PR https://github.com/pemunson90-cmd/Siren-s-Song/pull/147.
Landed ec19ecb42f1cde826e286d23ef073e44e68e5bda; lane a468bf8dea5e5839b9b0bae957dffc5b7980d071 retained, tree verified.
Windows import/core836/0, Hunt UI232/0, density1084/0, transport80/0, View32/0; exact-head guidance/game-smoke green40413750559.
Phone play deferred; historical failures retained in PR runs/git. Both old five-control fixtures now require all six actual actions.
Outside narrow seams: metrics_transport_tests and view_controls_menu_tests strengthened for Hunt; protected mechanics unchanged. Ownership released; next051.