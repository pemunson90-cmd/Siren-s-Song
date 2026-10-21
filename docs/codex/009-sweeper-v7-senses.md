# Handoff 009: rebuild the sweeper on V7 senses

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 005 must be DONE (and merged). If it is not, skip this one and take the next OPEN handoff.
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
(Codex fills this in.)
