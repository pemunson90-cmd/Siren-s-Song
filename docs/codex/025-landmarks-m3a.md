# Handoff 025: CAMPAIGN M3a, landmarks for thin operations

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 020 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/DESIGN_CAMPAIGN_DEPTH.md section 5. For ops 6 to 29, add 3 to 5 authored landmarks per op using data only (terrain shapes, structure rectangles, thermal fronts, lamp glow) so ops stop opening on four rocks and black water, and so the new photo subjects from handoff 020 have places to sit. Keep sonar and sight rules, clearance and bare-Quietus fixtures intact (landmarks must not make any op unfinishable; check the five authored fixtures and the pressure probe). Not in this handoff: the ending layer and any moving of the ending (waiting on Pat).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-landmarks

## Files you must not touch
Endings, story text, rules, op logic.

## What done looks like
Each op has its landmarks, fixtures still finish, probe not worse, screenshots of three representative ops attached in the Completion section.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, test results, unverified items, files outside ownership needed, recommended next.)
