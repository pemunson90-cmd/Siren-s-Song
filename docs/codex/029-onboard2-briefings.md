# Handoff 029: ONBOARD2, short briefings for ops 4 to 29 with a field manual page

Status: CLAIMED
Claimed at: 2026-10-24 10:55:27 UTC (6:55 AM Eastern)
Claimed by: codex
Finished at:

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

## Completion
Codex claimed029 at 2026-10-24 10:55:27 UTC (6:55 AM Eastern) before implementation.
Precondition017 is DONE. Actual integration is a524613 after verified027 merge.
No existing local/remote claude/lane-onboard2 branch or open PR duplicate was
found; the branch is created from that integration tip. No029 code changes yet.
Read handoff plus F7 addendum and existing onboarding/flow/folding machinery.
Scope: concise factual GOAL/DANGER/NEW THIS DIVE rows, retain the priced-photo
line, move all long instructions to FIELD MANUAL and fold fittings initially.
No operation logic, photo modules, rules or new story. Large-text cover/inner
checks and three captures, independent review and own final-head hosted checks
follow. Read-ahead notes and existing-brief export are local scratch only.

## Addendum from cold review 3 (24 Oct, Claude)
docs/design/COLD_REVIEW_3.md finding F7: briefings for ops 7 to 30 were measured by the critic at 12.2 to 15.3 screens tall (not independently re-measured); the brief paragraph alone runs 540 to 1,522 characters for ids 6 to 29 (independent check: id 27 is 540, id 6 is 703, id 12 is 1,522). OnboardingText.GOALS covers ops 1 to 6 only and MAX_OPERATION is 4. Scope of this handoff therefore includes: a GOAL / DANGER / NEW THIS DIVE (one line) set for every operation 7 to 30; the full text kept in the FIELD MANUAL; the Fittings block folded by default in the briefing. Same limits as above: placeholder length, no story changes.

24 Oct, 8:02 AM Eastern: PR123 is ready for review, current head
34dbc13b826aaeb6ed69b0fa37f2c8117a881a8c, basea524613,
game tree0cd231162cac28502dcf445edcf7c66893f27b7c. First WIPa824a5d
was pushed within30minutes. Final import clean, core833/0, data57/0,
native GPU UI782/0 (all27 affected operations at150% text on both shapes),
original onboarding30/0 and FIX2 menu24/0. Real controls cover fitting selection,
retained expansion/manual return, fresh visit reset, paused launch, Android Back
and switching the same display shape. No active-dive snapshot changes from
preparation. No full local scenario list or physical-device acceptance claim.

One flow-file seam selects mechanical data rows and a resize-signal-only width
adapter. Enter, Manual, Fittings and Back stay pinned. Original contextual briefs
and all local-order instructions remain in the manual. Existing photo text,
first three briefings/hints and all operation/photo/rule/save meanings are kept.
No new saved fields, no story. Table switch restores the old presentation.
Independent /root/review_photo APPROVE exact34dbc13 againsta524613, no findings;
source/docs/logs/six native images inspected, no tests run by reviewer.
Own run40091651801: guidance green, game-smoke running as of7:54 AM Eastern.
Still CLAIMED; no merge until both own exact-head gates and fresh integration
containment/mergeability checks, then actual merge verification before done029.
Raw evidence and hashes: archiveffa5ad0f80b86519da33b5e63a3cb6a53749907b,
evidence/029-windows-20261024. Development failures remain separately qualified.

Three representative operations (internal6/12/25, displayed7/13/26), both shapes:
- The Divergence: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-06-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-06-2184x1968.png).
- The Concealed Record: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-12-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-12-2184x1968.png).
- Last Shift: [cover](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-25-2520x1080.png) / [inner](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/ffa5ad0f80b86519da33b5e63a3cb6a53749907b/evidence/029-windows-20261024/captures/brief-25-2184x1968.png).
