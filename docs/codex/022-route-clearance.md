# Handoff 022: NAV1, planned courses stop clipping rock corners

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 017 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
The first cold review saw plotted routes pass through rock corners, causing hull strikes of 3% to 13% in ops 1, 4 and 5 (software render ran about 16 fps so coarse steps may have contributed; verify with the headless sim first at fixed steps). Reproduce with a headless scenario at fixed time steps: plan the same routes and measure the minimum distance between the path and terrain versus the hull radius. If the planner really allows paths that clip, fix it by planning with hull-size clearance and show the clearance margin on the route preview (a faint band or warning colour). Do NOT change the collision damage rule or numbers. If the clipping is only low frame rate, report that and add a regression test pinning the clearance, no gameplay change.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-nav-clearance

## Files you must not touch
Collision damage numbers and hull rules, Siren rules, story text.

## What done looks like
Either a proven planner clearance fix with a preview indicator, or a report plus pinned test showing none was needed; bare-Quietus fixtures and route tests still pass.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, test results, unverified items, files outside ownership needed, recommended next.)
