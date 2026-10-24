# Handoff 009: rebuild the sweeper on V7 senses

Status: DONE
Claimed at: 2026-10-22 16:20 UTC
Claimed by: claude (Pat approved Claude taking 009, 22 Oct; Codex skip this one)
Finished at: 2026-10-22 19:49:48 UTC

Precondition: handoff 010 must be DONE and merged (010 replaces blocked 005). If it is not, skip this one and take the next OPEN handoff.
Codex may merge: yes, after green guidance and game-smoke on the exact head.

## Task (plain language)
Pat decided (21 Oct): V7 Sirens have no sonar. The sweeper role must notice Quietus only by what V7 Sirens use: proximity plus line of sight, hearing throttle noise (scaled by speed squared), and hearing Quietus pings and loud tools. Remove its own emitted sweep, delayed echoes and echo-armed strike. Keep the role distinct: it patrols a lane, investigates the last heard spot (stale position, not live tracking), searches, and attacks only through the normal Siren route (line-of-sight detection, lock build, then beam per handoff 005). Differentiate it from the patroller by a wider hearing radius and slower, longer investigation, so quiet play and decoys beat it. The old design is saved at branch `claude/future-siren-active-sonar-sweeper` and described in docs/FUTURE_OPTIONS.md; do not delete the branch. Rename the role string only if all tests and saves tolerate it; otherwise keep id "sweeper".

## Base and branch
Branch `claude/lane-t2-sweeper` from fresh `origin/claude/integration`.

## Files you may edit
game/src/simulation/sonar_sweeper.gd (or a renamed file), its wiring in simulation.gd, sweeper tests, operation rosters only if a sweeper becomes unfinishable (report first). Update docs/FUTURE_OPTIONS.md if details change.

## Files you must not touch
Story text, other enemy roles, detection rules for non-sweepers, the V7 reference.

## What done looks like
No Siren emits sonar. Sweepers react to V7 senses only. Bare-Quietus journeys for ops 0 to 29 still finish (report any that do not). Save validation accepts the new sweeper state and rejects old-shape state cleanly. Focused test added and registered in the workflow. Audit finding 5 disappears because the mechanism is gone.

## Checks
Import, core tests, every CI scenario ok (`bash docs/codex/run_ci_scenarios.sh`). Rerun timeouts alone.

## Return
Push branch, open PR into claude/integration, wait for checks.

## Completion

### Verified completion reconciliation, 24 October 2026

Merged by Claude and already recorded under DONE017 on the board. The CLAIMED header was stale. No new senses or sweeper changes.

PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/70
Actual merge: 567f0b270cb479fecdb081df8ad9ffffdd2dceb3. GitHub reports merged=true, and ancestry was checked against fetched integration6e69116dd117254a867569868d9a87338a02131b. This status correction claims no new tests, review or phone acceptance. Original work and any earlier limits are preserved below.

### Historical task notes
(Codex fills this in.)
