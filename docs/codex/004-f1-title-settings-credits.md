# Handoff 004: finish the title screen, settings and credits, open the pull request

Status: DONE
Claimed at: 2026-10-22 00:01:18 UTC
Claimed by: codex
Finished at: 2026-10-22 superseded: PR 61 (F1) already open and being merged by Claude. Do NOT work on this.

Precondition: run `git log -1 --format=%cr origin/claude/lane-f1-frontend`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes, same rule, after you open the pull request into claude/integration.

## Task (plain language)
A title screen with Continue, New Campaign, Settings and Credits; a settings screen (master, music and effects volume, text size, high contrast, reduced motion, haptics) saved separately from game saves; a credits screen that shows the audio credit text from game/src/audio/soundscape.gd (ATTRIBUTION). Incompatible saves show a plain message, never a crash. The original boot path must still work as a fallback. The work is on the branch (commit 0c59a95); a revert commit follows a bad snapshot, the net tree equals 0c59a95. Verify it still matches, run every scenario, fix failures, register any new tests in .github/workflows/gauntlet-pr-checks.yml, then open the pull request.

## Base and branch
Work on the existing branch `claude/lane-f1-frontend`. First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
New files under game/src/presentation/frontend/, minimal hook lines in game/src/main.gd, a settings persistence file under game/src/persistence/, new tests.

## Files you must not touch
campaign, equipment, simulation, audio logic, fitting and briefing screens, story text.

## What done looks like
Title, settings, credits work; full-size touch targets; works at cover and inner screen shapes; all scenarios ok; pull request open.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, then open a pull request into claude/integration. Wait for GitHub's checks.

## Completion
(Codex fills this in.)
