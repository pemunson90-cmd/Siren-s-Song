# Handoff 027: CAMPAIGN M3b, final pair of operations and the photo-wall ending

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoffs 020 and 025 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, and the 22 Oct "Campaign and ending answers" entry). Self-contained modules, one narrow seam, numbers in data tables, optional validated save fields, revert note in each module header. No em dashes. All new text is 1 to 2 line placeholders. Do not change combat, beam, collision, damage, hull or Siren sight/hearing rules.

## Task (plain language)
Pat decided: the true ending moves to after op 25 with a final pair of operations after Iron Choir's core; ops 12 and 13 stay the fork; the ending is an annotated wall of the player's best film first.
1. Read docs/design/DESIGN_CAMPAIGN_DEPTH.md section 4 on branch codex/handoffs. Add two final operations (ids after the current last) as rows in the operation catalog with their own small encounter files, reusing existing systems (photography problems at Siren structures, the depth bands, the new film and trade systems); briefings 1 to 2 lines. They unlock after op 25's recovery and are finishable with bare Quietus. Core jobs finishable bare; bonus photos optional.
2. Add a new module campaign/endings_photo.gd that, after the final pair, selects an ending variant from the existing four endings' conditions plus the player's photo intel keys and the Glass/Iron choice facts, and presents an annotated wall of the player's best archive frames (use the existing archive viewer's frame renderer; captions are the finding names, no new story). Keep the existing ending flow at ops 12 and 13 working as the fork; do not remove any existing ending. If the final pair is not completed, the existing behavior must be unchanged.
3. Old saves load; new save fields are optional and validated; removing the module leaves saves valid.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/ending-m3b

## Files you must not touch
Story text beyond placeholders, combat and detection rules, existing operations' tables (read only).

## What done looks like
Both new ops playable from a fixture, the photo wall shows on a fixture save with several archive frames, existing endings still reachable, tests beside the modules registered in the workflow, CI green.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
