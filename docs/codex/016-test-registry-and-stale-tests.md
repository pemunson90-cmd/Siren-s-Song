# Handoff 016: one test list, and fix or retire stale tests

Status: BLOCKED
Claimed at:
Claimed by:
Finished at: 2026-10-22 23:02:08 UTC

Precondition: handoff 015 must be DONE or BLOCKED. Then run `gh`-free check: use the GitHub tools to list open pull requests. If any open PR edits scripts/toolchain/test.sh or .github/workflows/gauntlet-pr-checks.yml, do not start; set Status BLOCKED with a one-line reason and tell Pat (Claude will release you when those merge).
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): Claude's builders may be editing camera/photo code (photo_pricing folders), the sweeper (sonar_sweeper.gd), and later depth-band photo code. This handoff touches the test runner and tests only, so it should not collide; do not edit those source files.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add.

## Task (plain language)
Pat wants the code modular and easy to work on. An architecture audit found the test runner repeats the same run-and-check block six times plus a 142-line scenario list in scripts/toolchain/test.sh, so every lane that adds a test edits the same lines and collides. Also, tests exist that are not in the CI list, and at least one fails on claude/integration (radial_hud_tests has 3 failures and drone_drive_ui_tests times out locally on integration itself, both reported by Claude's DEPTH1 builder and neither in CI's list: include them in step 2; also archive_recap_ui_tests, "existing final warning", which looks for story text that was rewritten out of the game).
Do these in order, as one behavior-preserving PR:
1. Add one suite list file (for example game/tests/suites.txt, one suite per line, with a short comment header explaining the format) and make scripts/toolchain/test.sh and the GitHub workflow read it instead of repeating the block. A new test then means adding one line in one file. The set of suites that run, and their order, must stay identical. Prove it: record the suite names and the "CHECKS N FAILURES 0" totals from the core suite before and after, and compare the full list of names the old runner executed with the new one (a dry-run print is enough; do not run the full scenario list locally).
2. List every test file under game/tests that is not in the CI list. For each, say in your Completion section: runs and passes (then register it), fails because it asserts removed or rewritten text or behavior (then update it to the current behavior, never loosen it to pass), or is obsolete (then report it; do not delete without saying why).
3. Fix archive_recap_ui_tests so it asserts the current behavior, and register it if it then passes and runs in reasonable time.
4. Write a short docs/TESTING.md (under 30 lines): how to add a test, where the list lives, the rule "core suite must end CHECKS N FAILURES 0", and "a Godot resources-still-in-use line fails CI".

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-test-registry

## Files you may edit
scripts/toolchain/test.sh, .github/workflows/gauntlet-pr-checks.yml (only to read the list), game/tests/suites.txt (new), existing test files that are stale, docs/TESTING.md (new).

## Files you must not touch
Game source under game/src, any rule or content, the photo_pricing and sonar_sweeper files.

## What done looks like
The same suites run in the same order as before (proven), the list lives in one file, stale tests are fixed or reported, CI is green.

## Checks
Import, core tests ending CHECKS N FAILURES 0, and GitHub's guidance and game-smoke green on the exact head.

## Return
Pull request into claude/integration; merge it yourself per the Codex-may-merge line once green. Then mark DONE.

## Completion
Blocked before starting: open Claude PR #74 edits `.github/workflows/gauntlet-pr-checks.yml`, so the explicit precondition forbids starting this handoff.

Verified with GitHub tools: searched all open repository PRs and listed PR74 changed filenames. PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/74. No `gh` used. No source, runner or workflow changes made for 016; no tests run for this unstarted task.

Lane branch: `claude/lane-test-registry` was not created. Last pushed lane SHA: none (blocked before implementation). Handoff 015 is DONE, PR73 merged at `7db3a9fc7a5584953114e4233344832c3ee63060`.

Resume only after overlapping PR74 merges and Claude releases 016, then branch from fresh integration. Preserve original suite order, audit unregistered files and fix the stale archive recap test per this brief. Include the newly passing suites from 014 (`challenges_tests`, `challenges_ui_tests`, `challenges_journey_tests`) and 015 (`performance_measurements`, short default; `known_water_observation_tests`).

018 remains claimed by Claude and was not touched. Per README Keep going, stop at this BLOCKED handoff and report to Pat.
