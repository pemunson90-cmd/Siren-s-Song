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

First coherent step: [PR96](https://github.com/pemunson90-cmd/Siren-s-Song/pull/96), branch claude/lane-arch2-campaign-flow last pushed3afb12f966efc2646c9b148ddf7de5aafe68c5c5, tree8e1270dfb99c2d6861f4d506e81bdba95171bdaf, contains actual integrationb03dd69. Nineteen campaign/menu functions move to flow/campaign_flow.gd with original main signatures/one-line forwarders retained, main1106->950. Every moved body plus complete main restoration verified mechanically, numbers/text/callbacks/deferred ordering unchanged. Baseline/after core818/runtime665(includes campaign_ui_scenarios)/dispatch13/archive8/Canvas route-map70 all0 and clean, identical core outcome lines. Extra early-reward Canvas40 and FIX2 menu24 all0. No test edits, new save fields, rules or Simulation changes. Initial import name collision/host qualification corrected before publication; current import clean. Independent exact-head review requested from /root/review_integration, PR draft, own CI pending. Handoff remains CLAIMED through all separate ARCH2 PRs. While PR96 runs, prepare photo_review on its own branch based on published3afb12f; before its PR/merge reconcile actual integration and run its own exact-head CI.

Pat stop order23Oct2026 Eastern (24OctUTC): finish PR96 only, save remaining steps, refresh stale documentation and prepare Windows desktop handover for Pat/future Codex/Claude Code, then STOP. Do not start metrics, feature-contract implementation or025 in this cloud session. PR96 exact3afb12f independently APPROVED by /root/review_integration with no findings, full original-main reconstruction and personal Canvas reward40/0, verdict relayed in PR body; ready. Exact CI40043994511 guidance success/game-smoke running.

Preserved second-step preparation: branch claude/lane-arch2-photo-review last pushed52ba7d502b3e449180a4883eb570a2c80a9b94f5, tree002047d39ee8eb8212683d2eb9fbd7f8a95914f9, parent3afb12f. Nine photo/archive functions, main950->864, original main entry points retained. Mechanical body/full-main restoration proof accounts for host qualification and one explicit String annotation preserving original inference. Clean import2, core818/runtime665/dispatch13/recap8/captureUI9/archive-parent2/Canvas cold-review218 all0; exact core outcome lines match. No test edits or save/rule/story changes. No PR yet and not merged; future desktop continuation must first reconcile actual integration, update prepared RESUME, obtain independent review and own exact-head hosted checks. Metrics and the feature registry have NOT been implemented.

Documentation handover is being prepared separately on claude/desktop-handoff-20261023 based on published3afb12f, to return as a docs-only PR after PR96 lands. This preserves PR96's tested head. All code is pushed; local raw logs/parity proofs/screenshots/pressure evidence require a separate transfer, not just Git clone. Final exact refs and next desktop commands will be recorded before stopping.023 stays CLAIMED, partially complete; do not falsely mark DONE or take025.
