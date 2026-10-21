# Handoff 006: fix the failing check on the story text pull request

Status: CLAIMED
Claimed at:
Claimed by: claude agent (21 Oct)
Finished at:

Precondition: run `git log -1 --format=%cr origin/claude/lane-s3-rewrite`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes. After you push, once GitHub's `guidance` and `game-smoke` are both green on the exact head and the pull request is mergeable, merge it into `claude/integration` with a merge commit, then mark DONE.

## Task (plain language)
GitHub's game-smoke failed on pull request #56. First failure: wake_crossing_tests, 'later live factory account selectively recognizes the actually spent old loop'. The story text change replaced the old 'Keeper's last loop' wording and that test (or the recognition logic) still depends on it. Fix narrowly: keep the recognition working with the new wording, preferably by making the test check the mechanic, not the old phrase. CI stops at the first failure, so run the whole scenario list and fix every string-assertion break. Story rule: the aliens were here first, the factory is their base, never aliens fleeing humans.

## Base and branch
Work on the existing branch `claude/lane-s3-rewrite` (pull request #56). First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
Strings in game/src/campaign/*.gd and the tests that assert them.

## Files you must not touch
Logic, geometry, combat. No em dashes.

## What done looks like
Pull request #56 green on both checks.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, and the existing pull request updates itself. Wait for GitHub's checks.

## Completion
(Codex fills this in.)
