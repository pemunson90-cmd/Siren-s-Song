# Handoff 028: PRIORITY fallback: land Claude's DEPTH1 PR 74 if Claude is gone

Status: DONE
Claimed at:
Claimed by:
Finished at: 2026-10-22 23:30 UTC (not needed; Claude merged PR 74)

Precondition: use the GitHub tools to list open pull requests. If PR 74 (branch claude/depth1) is already merged, mark this DONE with one line and move on. If it is open AND the last commit on claude/depth1 is more than 90 minutes old, take over; otherwise skip this handoff for now and do other OPEN work.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
PR 74 is the DEPTH1 milestone (handoff 018, claimed by Claude): depth-band photos (photo_depth), findings displays (photo_rules), ALL STOP (all_stop). Claude's builder may be gone. Finish it: merge origin/claude/integration into claude/depth1 (merge commit only, never rebase or force-push), resolve conflicts keeping both sides, run import, the core suite and photo_depth, photo_rules, all_stop, photo_pricing, onboarding, sweeper and runtime suites, push, wait for green guidance and game-smoke on the exact head (after a failure also run later CI-list tests locally), then merge. Afterwards mark handoff 018 DONE in its file and the board, and tell Pat that 016, 019 and 020 are unblocked. Read the PR description for the design, revert notes and honest caveats.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/claude/depth1 (existing)

## Files you must not touch
Rules and numbers (the design is approved), story text.

## What done looks like
PR 74 merged with green checks on its exact head; 018 marked DONE.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)
