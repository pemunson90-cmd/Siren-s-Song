# Handoff 020: CAMPAIGN M1, photography rows for ops 6 to 29

Status: CLAIMED
Claimed at: 2026-10-23 04:09:09 UTC
Claimed by: codex
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

WIP, not DONE. Branch claude/campaign-m1 pushed0de16ceb34a234471a1f9feb392b5412c993c39d. Draft PR85: https://github.com/pemunson90-cmd/Siren-s-Song/pull/85

Fourteen optional subjects and returned-film marks are implemented in the two assigned data modules. Two long lamp observations use the existing optional objective shape; other subjects use existing hidden-photo data. New records require their informative feature. Two shallow and two deep subjects, four tight shots and a physically clear tele-lens standoff trade are covered. Operation10 keeps its strict three-objective plant shape and receives operation8 film knowledge; the additional subject is on19. Marks do not change terrain, enemies, routes or core work. No new objective kind or narrative.

Validation: clean import, core before/after817/0. All14 subject details resolve from navigable water and produce usable held-exposure film through the existing camera APIs, preserving film spend and save validity. The isolated suite303/0 passed. Adding public PHOTO-entry checks exposes two failures: operation7 always returns the tender receiver, and operation8 always returns the shelter account. Current suite317 checks,2 failures. The small optional selector helper is prepared in photo_ops.gd, but its one simulation.gd hook is unapplied because README ownership rules forbid out-of-scope edits. Pat was asked asynchronously whether to extend020 to that selector hook; approval is pending. Preserve ready mission jobs and active exposures. Do not merge red or mark DONE.

Pressure:64/64 current-baseline rows exactly match after in outcome/time/hull/oxygen/losses/locks/beam/industrial hull/tools/accepted orders/position/save validity. Both have29 wins,10 losses,5 controller route rejections,16 work rejections,4 budget timeouts. These existing failures are not wins. Original probe spun at899.999999999s; an external wrapper applies the inherited tick loop's existing epsilon boundary to report budget_timeout without changing any simulation state or route/defensive policy. Both runs use the same wrapper; probe source is unchanged. Raw outputs are outside Git at /workspace/m1-pressure-before, /workspace/m1-pressure-after, with comparison JSON and the original unbounded partial output preserved. Existing named journeys are still running; opening49/0 and opening cover/inner policy410/0 passed.

Local proposal: /workspace/m1-selector-proposal.patch (git apply --check passed, not applied). If Pat approves, apply it, prove both PHOTO-entry regressions green, preserve ready receiver/active exposure behavior with focused tests, finish the remaining bare journeys, and get exact-head CI before merge. Keep019 integration priority and merge fresh integration before final submission. No APK, main or production changes. No physical-device claim.
