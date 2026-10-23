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

CLAIMED, not DONE. Data branch claude/campaign-m1 pushed5b6fc9c59058a24e4eec11d813da4b3676002c4f. Draft PR85: https://github.com/pemunson90-cmd/Siren-s-Song/pull/85. Wait for035 PR86 merge, finish019, then merge fresh integration into this data lane and get exact-head CI before merging020.

Fourteen optional subjects/keys and16 returned-film marks in the two assigned data modules. Long lamp observations use existing optional objective shape; other subjects use existing hidden data. Records require their informative feature. Two SHALLOW, two DEEP, four tight shots, and a physically clear tele-lens standoff trade are covered. Existing plant's three objectives stay intact; its film hint comes from8, with another subject on19. Marks do not change terrain, enemies, routes or core work. No new kind, engine or narrative. Revert removes application calls/effects but retains subject/key registrations for recovered-film save compatibility.

Dependency035 owns common camera routing and optional-recovery compatibility, so no extra020 source ownership is needed. The unused data-lane selector helper was removed. In /workspace/siren-m1-verify (temporary detached combination of reviewed035272eea9 plus latest data), import clean and347/0: navigable banded viewpoints, held exposure/film spend, recovered intel, current saves, public PHOTO entry and all visible marker types. Independent reviewer /root/review_m1 (fresh context, requested gpt-6.1-sol Medium) conditionally approves5b6fc9c vs4e89cc3 with035272eea9: no outstanding Critical/Important/Minor. Eight invisible note-kind marks were caught, corrected to supported static post markers, and regression tested RED347/8 then GREEN347/0. Historical observations do not animate live clocks. Reviewer personally reproduced347/0 and matched reviewed data/test files. Actual normal-merge head still needs review recheck and CI.

Focused combined journeys pass: Shelf33,WarningChain35,Concealed43,Witness32,Recipient59,Glass70,Iron108. Photo discovery25,study-save45,pricing64,rules49 pass. Earlier data-only core817/0, opening49/0 and opening touch-policy410/0 passed;035 core818/0 includes an additional Settings target check. Final merged data lane core remains required.

Pressure: original baseline/data64rows exactly matched, including existing29wins,10losses,5route rejections,16work rejections,4timeouts. Those failures are not wins. New matched probes on reviewed035 versus035+M1 are running in /workspace/m1-pressure-fix2-before and -after; default probe also covers0/3/5, so76rows expected. First50 completed pairs match every tracked metric. Original probe spins at899.999999999s; same external /workspace/m1-pressure-bounded.gd applies the inherited tick epsilon boundary to record timeout, without changing simulation state, routes or defensive policy. Raw logs, per-case files and original unbounded partial output remain outside Git. Do not claim final pressure until all76 finish.

Resume035's exact-head CI39904552528 first; then019's four small PRs; then merge fresh integration into claude/campaign-m1, preserve both suite registrations (M1 rank182/203), recheck reviewed source and green gates. Temporary combined tree is validation only, not a merge candidate. NoAPK or physical-device claim.
