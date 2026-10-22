# Handoff 017 (PRIORITY): land PRs 69, 70 and 71 in order

Status: OPEN
Claimed at:
Claimed by:
Finished at:

PRIORITY: take this BEFORE 014, 015 and 016 if any of PRs 69, 70 or 71 is still open. Claude's builders for 69 and 70 may be gone; their branches are pushed, and you are authorised to finish them. Push merge commits only (never rebase or force-push).
Precondition: none.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally, because CI stops at its first failure. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Every feature is a self-contained module with one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules beyond what these handoffs say Pat approved. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Three pull requests into claude/integration are waiting. Land them in this order, one at a time, re-checking after each.
1. PR 69 "Priced shots" (branch claude/priced1; film, reach rings, light prices, timing windows, all in new photo_pricing folders). If its checks are green on the exact head and it merges cleanly with current integration, merge it. If integration moved since the last green run, merge origin/claude/integration into the branch, run import and the core suite plus the photo_pricing, lock_warning, onboarding and runtime tests, push, and wait for green on the new exact head.
2. PR 70 "SWEEP1" (branch claude/lane-t2-sweeper; sweeper rebuilt on V7 senses, plus a once-only first-warning pause in ops 1 to 3). Known issue: the Well (op 4) bare-Quietus journey fails because the camera shutter now wakes the dormant hunter 296 m away. Pat/Claude decision: fix with a DATA change only to the op 4 roster (move the hunter's dormant post, or lengthen its first-hearing delay slightly) so a quiet bare-Quietus capture of the southern archive works; do not touch hearing, lock or beam rules. Tests that must pass: opening_depth_journeys, opening_depth_policy_ui_tests, the sweeper tests, siren_warning_pause_tests. Also change the one sentence in docs/CURRENT_GAME_SPEC.md that still says "active-sonar sweeper" to describe the V7-senses sweeper. Merge integration into the branch after PR 69 lands (onboarding_hints.gd may need a conflict resolution; keep both sides' hooks). Merge when green on the exact head.
3. PR 71 "controls friction" (your own handoff 013): merge when green; if integration moved, merge it in and recheck.
After each merge, update the integration copy of docs/CONTINUATION.md only if it names the PR as in flight (one line).

## What done looks like
PRs 69, 70 and 71 merged, integration's core suite ends CHECKS N FAILURES 0, and the Well (op 4) is finishable with bare Quietus.

## Return
Mark DONE in this file and in docs/codex/BOARD.md with the three PR links.

## Completion
(Codex fills this in.)
