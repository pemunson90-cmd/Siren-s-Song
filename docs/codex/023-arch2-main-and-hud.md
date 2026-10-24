# Handoff 023: ARCH2, split main.gd and give HUD/ocean view one contract

Status: CLAIMED
Claimed at: 2026-10-24 00:08:00 UTC
Claimed by: codex
Finished at:

Precondition: handoffs 019 and 016 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/ARCH_AUDIT_1.md steps 5 and 6 on branch codex/handoffs. Step 5: extract main.gd into presentation/flow/campaign_flow.gd, photo_review.gd and ui_metrics.gd with no behavior change. Step 6: give the existing *_view.gd files one shared three-function contract and have mission_hud.gd and ocean_view.gd loop over them instead of naming each feature, one feature per PR. Prove each PR behavior-preserving (identical core check counts plus the named UI suites). Each as its own small PR. Write the final conventions into docs/CONVENTIONS.md if 019 did not.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-arch2-*

## Files you must not touch
Rules and numbers (move verbatim), story text.

## What done looks like
main.gd and the two draw files shrink with identical behavior; CI green on each PR.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Claimed after021/PR95 merged b03dd691a4775bbc07abfa1e87f4938ead653342 and DONE021 plus BOARD published b169abc. Preconditions016 and019 are DONE. Read ARCH_AUDIT_1 steps5/6, current standing rules and PLAN_SNAPSHOT. Next branch claude/lane-arch2-campaign-flow from freshly fetched integration, establish named check baselines, then mechanical extraction with one main file per PR and one presentation feature per later PR. No code pushed yet; record branch and last pushed SHA after first coherent WIP. Preserve all rules, numbers, text, saves and original forwarded entry points.
