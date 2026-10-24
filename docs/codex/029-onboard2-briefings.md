# Handoff 029: ONBOARD2, short briefings for ops 4 to 29 with a field manual page

Status: DONE
Claimed at: 2026-10-24 10:55:27 UTC (6:55 AM Eastern)
Claimed by: codex
Finished at: 2026-10-24 13:19:19 UTC (9:19 AM Eastern)

Precondition: handoff 017 DONE (it is).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
ONBOARD1 shortened the op 1 briefing to a goal plus one danger line, with the full rules behind an optional FIELD MANUAL button (ops 1 to 3); ops 4 and up still have long briefings. Apply the same pattern to ops 4 to 29 with the existing onboarding machinery: briefing text becomes a goal plus one danger line plus the Priced Shots photo-problems line; long rules move to the field manual page. Keep everything touch-first and readable at large text size on both Fold7 shapes. All text is 1 to 2 line placeholders; do not write new story; keep existing facts accurate (do not drop a rule the player needs, move it to the manual). Add data rows, not new engines.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-onboard2

## Files you must not touch
Operation logic, rules, story text beyond shortening, photo and sweeper modules.

## What done looks like
Every op 4 to 29 briefing fits above the fold at large text on both shapes (screenshot three in Completion); the manual page holds the removed text; tests pass.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Addendum from cold review 3 (24 Oct, Claude)
docs/design/COLD_REVIEW_3.md finding F7: briefings for ops 7 to 30 were measured by the critic at 12.2 to 15.3 screens tall (not independently re-measured); the brief paragraph alone runs 540 to 1,522 characters for ids 6 to 29 (independent check: id 27 is 540, id 6 is 703, id 12 is 1,522). OnboardingText.GOALS covers ops 1 to 6 only and MAX_OPERATION is 4. Scope of this handoff therefore includes: a GOAL / DANGER / NEW THIS DIVE (one line) set for every operation 7 to 30; the full text kept in the FIELD MANUAL; the Fittings block folded by default in the briefing. Same limits as above: placeholder length, no story changes.

## Completion
Done029. PR123 https://github.com/pemunson90-cmd/Siren-s-Song/pull/123 merged
at 9:19 AM Eastern on24October2026. Actual merge
dfaf5435a75364b82c57f5567fde7eb673e505a8, parentsa524613 and053c1ae, verified
on the live integration ref and GitHub merged=true. Branchclaude/lane-onboard2,
last pushed head053c1ae5c9715b8d2ecfe2374a64f8cd70a1333e. Published game tree
dec553a44e0af82a962772c03c2be996dd63e70b. No branches deleted.

Own exact-head guidance120873518425 and game-smoke120873518630 both SUCCESS
in run40094401838. Fresh containment, mergeability and identical prepared/source
trees were checked immediately before non-force merge-commit publication.
Independent /root/review_photo APPROVE exact053c1ae, no findings; unchanged
production matches prior approved34dbc13 againsta524613. Relayed approval and
review provenance are in PR123; reviewer ran no tests, no formal GitHub approval
claim. Public claim87ceedf preceded implementation; first WIPa824a5d within30min.

Optional concise mechanical rows cover internal3..29, with original contextual
briefs and local-order paragraphs retained in FIELD MANUAL. Existing photo text
and first-three flow/hints are unchanged. Preparation starts folded and retains
expansion during selection/manual return, then resets on a fresh visit. Four
footer controls remain visible; resize-signal width adapter, no per-frame loop.
One flow-file seam, no new save fields, operation logic, photo-module changes,
rule changes or story. Table switch restores the original presentation.

Clean import; core833/0; data57/0; original onboarding30/0; FIX2menu24/0;
native GPU UI782/0 including six capture-write checks. All27operations at150%
text on both420dpi shapes; touch expansion/selection/manual/Back, paused launch,
Android Back and live shape switch. Later equivalent UI776/0 excludes captures.

Initial hosted40091651801 failed old scrolling test setup: it assumed preparation
was expanded. Added real touch to open the fold, retained all50prior assertions;
focused regression52/0. All151later CI ranks73..223 ran locally:150pass and one
Linux-env launcher failure at192. Separate native Windows launcher invoked the
unchanged child branches in fresh isolated data folders:9/0per shape, launcher2/0,
exit0/errors0. Original failure retained, not relabeled passing. Reviewer verified
the equivalence and qualification; hosted Linux parent independently passed in
final green run. No test skipped, loosened or deleted; no full local matrix ran.

Evidence archivea74bd80e96c2fa8c08c24e3348b0a86f9e355035,
evidence/029-windows-20261024 and head-053c1ae-followup. Includes314follow-up
files/4010482bytes plus prior packet, manifest hashes verified, development
failures and original truncated hosted failure log qualified. Six images below
show unchanged production at34dbc13. Controlled technical fixtures only; no
physical-phone, fresh-player or headphone acceptance claim. No APK.

Outside ownership: only existing flow integration, old scrolling-test setup,
suite registration and operational RESUME correction. No rule ownership touched.
Recommended next030: precondition017DONE, no duplicate PR/branch found, claimed
publicly in this same board transaction before implementation.

Three representative operations (internal6/12/25, displayed7/13/26), both shapes:
- The Divergence: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-06-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-06-2184x1968.png).
- The Concealed Record: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-12-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-12-2184x1968.png).
- Last Shift: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-25-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-25-2184x1968.png).
