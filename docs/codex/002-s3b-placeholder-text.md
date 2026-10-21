# Handoff 002: remove old plot leftovers, apply renames, keep text as placeholders

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: run `git log -1 --format=%cr origin/claude/lane-s3b-text`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes, same rule, after you open the pull request into claude/integration.

## Task (plain language)
Strings only. Remove leftover text that contradicts the plot (the rejected evacuation or human-fleet premise, or aliens fleeing humans). The aliens were here first, the factory is their base, and Quietus is a recon mission. Apply the three bible renames (Lantern Anchorage to Lantern Lock, Last Carrier to Last Boat Out, Keeper's Cache to Range Locker) and neutralize strings in simulation and view code that name the old premise. Mission briefings stay short placeholders. A Claude worker started this; a WIP snapshot is on the branch.

## Base and branch
Work on the existing branch `claude/lane-s3b-text`. First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
Strings in game/src/campaign/*.gd, game/src/simulation/*.gd and game/src/presentation/*.gd; tests that assert those strings (edit narrowly and say which).

## Files you must not touch
Logic, geometry, rosters, new long story text. No em dashes in any text.

## What done looks like
No old-premise wording remains in the listed areas; renames applied; no logic or geometry changes; all scenarios ok.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, then open a pull request into claude/integration. Wait for GitHub's checks.

## Completion
(Codex fills this in.)
