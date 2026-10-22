# Handoff 017 (PRIORITY): land PRs 69, 70 and 71 in order

Status: DONE
Claimed at: 2026-10-22 18:18:27 UTC
Claimed by: codex
Finished at: 2026-10-22 20:18:10 UTC

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
All three PRs merged in the requested order, with both required checks green on each final head and mergeability verified:

- [69 Priced Shots](https://github.com/pemunson90-cmd/Siren-s-Song/pull/69): head `f4a9f5db82af9029a9749923033bc49aa40f85c5`, [CI 39831039898](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39831039898), merge `8b6c2d1177ed0e22667279142af7706b068400e5`.
- [70 SWEEP1](https://github.com/pemunson90-cmd/Siren-s-Song/pull/70): head `3d7da2dae70943de81994780aeded52fc71592de`, [CI 39840361328](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39840361328), merge `567f0b270cb479fecdb081df8ad9ffffdd2dceb3`.
- [71 controls](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71): head `f71370cab344b1dba21817a0ccd72906133b0fa4`, [CI 39844515618](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39844515618), merge `dd9494ba139fdf23b92f5599d1aadcd487e2c637`.

The Well hunter's dormant post is now reachable clear water at (1480, 860), outside the quiet capture approaches. The matched active-sensing fixture follows that relocated post. The front/back optics fixtures retain only the actor under study, keeping every image and path assertion while excluding the second sweeper that interrupted the long exposure. No sensing, lock, beam, collision, damage or hull rule was changed beyond the approved SWEEP1 work. Both the photography prompts and once-only warning pause survive the integration. The requested spec sentence describes the V7-senses sweeper; CONTINUATION now points to the next handoffs.

Validation: merged integration has exactly the tested controls-head tree. Import is clean; core 817, runtime 665, ring UI 212, fleet UI 78, route touch 46, onboarding 30, warning pause 15, pricing UI 11 and photo UI 9 checks all pass. The SWEEP1 pass also checked sweeper 52, pricing 64, lock warning 27 plus UI 14, opening journeys 49, opening touch 406, photo capture 52, study-save 45 and discovery 25, all zero failures. After the original red core run, all 84 current CI suites were exercised locally across the integration; the affected suites and initially failing fixtures were rechecked successfully. No tests were skipped, loosened or deleted.

Strict bare-Quietus proof reuses the Well journey with basic 100 oxygen, both drones inactive and no fitted modules: 13 checks passed; recovery at 127.32 seconds, full hull and 45.12 oxygen, with every finite tool unused. The ordinary touch journey also completes on both logical Fold shapes. Physical Fold ergonomics, headphone audio and human enjoyment remain unverified.

Handoff 013 and its board row are DONE in commit `036e215`. No APK or production/main change. SWEEP1's multiple legacy hooks remain documented in its module header for the planned ARCH1 cleanup in 019. Next: 014, then numeric order through the eligible OPEN queue.
