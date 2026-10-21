# Handoff 008: fix the failing render error on the Glass Reach pull request

Status: DONE
Claimed at:
Claimed by:
Finished at: 2026-10-21 22:53 UTC

Precondition: run `git log -1 --format=%cr origin/claude/lane-c1-glass`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes. After you push, once GitHub's `guidance` and `game-smoke` are both green on the exact head and the pull request is mergeable, merge it into `claude/integration` with a merge commit, then mark DONE.

## Task (plain language)
UPDATE: the render fix is already pushed (commit 7a5c4ee: ocean_view.gd `_rock` now accepts polygon rocks; a Claude worker ran all 66 scenarios ok locally). So your job is mainly to check GitHub's checks on the new head, fix anything that still fails, and merge when green. Under heavy load `opening_depth_policy_ui_tests` can take over 9 minutes; if it is the only failure, rerun it alone before treating it as real.

Original description:
Pull request #55 gives Glass Reach operations 14 to 21 their own terrain, work sites and rosters. GitHub's game-smoke fails with hundreds of: SCRIPT ERROR: Invalid type in function '_rock' in base 'Control (ocean_view.gd)'. Cannot convert argument 1 from PackedVector2Array to Rect2. The new terrain data hands the renderer polygons where it expects rectangles. Prefer fixing the data you emit so it matches what the renderer already accepts (see how other authored regions such as Confluence or Split Channel pass terrain); if the only sound fix is a small change in game/src/presentation/ocean_view.gd, keep it minimal and say so. A partial uncommitted fix to ocean_view.gd may exist in the Claude worker's snapshot commit on the branch. Also note a known weakness for later: all eight Glass Reach operations share one core objective.

## Base and branch
Work on the existing branch `claude/lane-c1-glass` (pull request #55). First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
game/src/campaign/glass_reach_operations.gd, game/src/simulation/glass_reach_work.gd, game/src/campaign/encounters/*, a minimal fix in game/src/presentation/ocean_view.gd if truly needed.

## Files you must not touch
Story text, combat, equipment.

## What done looks like
Pull request #55 green on both checks, no script errors in any scenario.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, and the existing pull request updates itself. Wait for GitHub's checks.

## Completion
Pull request #55 was merged into claude/integration by another party (merge commit on integration) before this handoff was started. Nothing left to do. Closed by Claude.
