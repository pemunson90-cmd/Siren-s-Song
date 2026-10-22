# Handoff 020: CAMPAIGN M1, photography rows for ops 6 to 29

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 018 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally, because CI stops at its first failure. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Every feature is a self-contained module with one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules beyond what these handoffs say Pat approved. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/DESIGN_CAMPAIGN_DEPTH.md on branch codex/handoffs. Build ONLY milestone M1: new photo subjects and matching returned-film effects as data rows in campaign/photo_ops.gd and campaign/photo_intel.gd for ops 6 to 13 (tender hull door side, relay post blink gap, Siren structure patrol edge), Glass Reach 14 to 21 (listener buoy blind side, strain-vane crack, latch seen from the shallow band) and Iron Choir 22 to 29 (lock shutter lamp order, ballast bus cable, four optional tight shots on 26 to 29). No new camera engine, no annotation tool, no new save objective types (that is what broke op 3). Core jobs stay finishable with bare Quietus; bonus photos are optional and pay off through intel marks and later charts. Use the Priced Shots and depth-band systems already merged. Pat answered: film never gates a route (informative only); Siren studies may shift timing on core ops only small and readable; person findings are human survivors, shown as marks only with no new story text.
NOT in this handoff and waiting for Pat: moving the true ending to after op 25, keeping ops 12 and 13 as the fork, the ending as a scene or photo wall, any new narrative text.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/campaign-m1

## What done looks like
Each band has at least two photo problems that matter; bare-Quietus fixtures for the five authored ops still finish; the pressure probe does not get worse.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
