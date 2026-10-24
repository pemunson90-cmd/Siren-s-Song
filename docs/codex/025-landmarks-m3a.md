# Handoff 025: CAMPAIGN M3a, landmarks for thin operations

Status: CLAIMED
Claimed at: 2026-10-24 05:48:56 UTC (1:48 AM Eastern)
Claimed by: codex
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
Codex claimed025 on24 October2026, 1:48 AM Eastern, after023 DONE in2df2e6b.
Precondition020 is DONE atddc3361 and contained in current integration8c13f5b.
Read assigned DESIGN_CAMPAIGN_DEPTH section5 and current standing rules.
Planned code branch claude/lane-landmarks from freshly fetched integration.
No existing remote/local branch or open landmark PR found; no implementation
or pushed code yet. Claim posted before implementation so Claude does not duplicate.
Scope:3 to5 authored landmarks per op6 to29, existing terrain/structure/thermal/
lamp tools, five authored fixtures and pressure probe preserved, three representative
screenshots. No ending/story/rule/op-logic changes or new art direction.
Design approach follows the already approved data-only handoff and standing user
order: no further design-approval gate. A short implementation plan follows
inspection of directly relevant source; use the same designated independent
reviewer and own exact-head guidance/game-smoke before merge.

2026-10-24 2:42 AM Eastern recovery checkpoint: source branch
claude/lane-landmarks pushed3c2af9536487b3a793c56f89e5925142c06e27f6,
draft PR121 https://github.com/pemunson90-cmd/Siren-s-Song/pull/121.
Plan8b1adba and existing integration8c13f5b are contained. Active Codex claim;
Claude do not duplicate. Native import/data468/0/projection90/0 pass. Earlier
prototype core818/0 is not final-head proof. First visual draft rejected as too
weak; localized motifs and actual photo depths are now being inspected. A clip
triangulation edge case was repaired; native recapture still required. Preserve
raw rejected captures and the lost Quietus capture, do not present them as wins.
External epsilon-bounded pressure baseline complete, identical candidate running;
no tracked probe/test loosening or game-state edits. Five fixtures, final targeted
checks, three accepted captures and independent exact review/CI remain before
ready/merge. Generated imports/UIDs excluded.025 remains CLAIMED, not DONE.

2026-10-24 07:04:30 UTC (3:04 AM Eastern) final preparation checkpoint:
claude/lane-landmarks last pushed6ffab7289e41bbf4b96304a1c6768def99f7fc1c,
PR121 is ready. Integration8c13f5be841ab71ad41b5a4dd1ea3c030b370e8c is
contained. Accepted game tree d7159cb0319f783b9e9a0f2a2da7a72ebf6090f7 equals
validated0cf00531; final commit only reconciles RESUME and plan.
Native import/core818/0, runtime665/0, density883/0, data468/0, projection92/0,
five authored depth journeys49/0, all five won. Core retains six bare-craft
fallbacks. Epsilon-bounded external pressure:76 paired full records and1105
commands identical;31wins16losses25controller findings4timeouts per side,
all snapshots valid. No tracked probe, gameplay or test assertions loosened.
Independent /root/review_photo APPROVE exact6ffab72 against8c13f5b, no remaining
findings. Source/docs/evidence/ancestry/hashes verified; reviewer ran no tests.
Verdict relayed with provenance in PR121. Own exact40072498877 guidance SUCCESS,
game-smoke still running. Do not merge until both succeed, fresh current-tip
containment and mergeability.025 remains CLAIMED; no further source work needed
unless a check or live-base change requires repair. After verified merge, mark
DONE025 and BOARD in one commit, then claim next eligible026.

Immutable evidence archive:
https://github.com/pemunson90-cmd/Siren-s-Song/tree/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024

Three accepted native operations, actual source-known routes with finite defense;
modest accents, no wholesale silhouette overhaul or phone/human acceptance.
Rejected drafts, renderer errors and lost early08 capture are retained as such.

![Operation08 after](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_08_after.png)

[Operation08 before](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_08_before.png)

![Operation14 after](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_14_after.png)

[Operation14 before](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_14_before.png)

![Operation28 after](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_28_after.png)

[Operation28 before](https://raw.githubusercontent.com/pemunson90-cmd/Siren-s-Song/7e44ec9f8617936401d7e27877e6bce3f8eb5bbe/evidence/025-windows-20261024/landmarks-captures/op_28_before.png)
