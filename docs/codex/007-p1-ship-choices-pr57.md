# Handoff 007: fix the three failing checks on the ship choices pull request

Status: DONE
Claimed at:
Claimed by:
Finished at: 2026-10-21 22:53 UTC

Precondition: run `git log -1 --format=%cr origin/claude/lane-p1-fittings`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes. After you push, once GitHub's `guidance` and `game-smoke` are both green on the exact head and the pull request is mergeable, merge it into `claude/integration` with a merge commit, then mark DONE.

## Task (plain language)
Pull request #57 adds hull and drone chassis choice with typed mounts and budgets. GitHub's game-smoke fails. Known problems: (1) depth_policy_ui_tests (and possibly opening_depth_policy_ui_tests) hang until the time limit. First check whether they hang on origin/claude/integration too (use a separate worktree); if only on this branch, find what the ship-choices change stalls (candidates: the hull speed multiplier, endurance or life-support factors, the default loadout shape in main.gd, depth_bands.gd). (2) briefing_scroll_fitting_ui_tests has 4 failures: the new 'hull and drone frames' section or the new REPLACES row wording moved or renamed the equipment rows the test taps. Prefer keeping equipment rows where they were (frames section after them) over editing the test. (3) campaign_instruments_ui_tests is already fixed in commit b4b82c4; confirm. Also give rows that swap an item in a distinct label so a player cannot swap by accident.

## Base and branch
Work on the existing branch `claude/lane-p1-fittings` (pull request #57). First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
game/src/equipment/*, game/src/campaign/glass_research.gd, game/src/campaign/fleet_inventory.gd, the fitting and briefing screens, the specific tests above, and the one-line swaps already in other files.

## Files you must not touch
Combat rules, story text, operation tables.

## What done looks like
Pull request #57 green on both checks; old saves still load; a standard launch plays as before.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, and the existing pull request updates itself. Wait for GitHub's checks.

## Completion
Pull request #57 was merged into claude/integration by another party (merge commit on integration) before this handoff was started. Nothing left to do. Closed by Claude.
