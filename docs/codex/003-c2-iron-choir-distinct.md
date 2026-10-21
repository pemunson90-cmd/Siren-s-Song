# Handoff 003: make Iron Choir operations 22 to 29 each play differently

Status: CLAIMED
Claimed at:
Claimed by: claude agent (21 Oct)
Finished at:

Precondition: run `git log -1 --format=%cr origin/claude/lane-c2-iron`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes, same rule, after you open the pull request into claude/integration.

## Task (plain language)
Each Iron Choir operation (core 22 to 25, optional 26 to 29) should have its own layout, objective structure and thing the player does (for example a sequence of lock work, a timed freight intercept, an escort tow, a two-site split), not only different terrain. Use the encounter helper files introduced for Glass Reach under game/src/campaign/encounters/. Text stays one or two lines. A WIP snapshot is on the branch (stacked on the Glass Reach branch, so wait for handoff 008 to land or merge claude/lane-c1-glass in).

## Base and branch
Work on the existing branch `claude/lane-c2-iron`. First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
game/src/campaign/iron_choir_operations.gd, game/src/simulation/industrial_jobs.gd, new files under game/src/campaign/encounters/, Iron Choir tests.

## Files you must not touch
Threat logic in simulation.gd, industrial_threats.gd, sonar_sweeper.gd; Story text, combat and detection rules (another handoff owns combat), campaign operation tables unless named above.

## What done looks like
Operations 22 to 29 are visibly distinct, each bare-Quietus journey still finishes, shipping operation IDs 0 to 29 unchanged, all scenarios ok.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, then open a pull request into claude/integration. Wait for GitHub's checks.

## Completion
(Codex fills this in.)
