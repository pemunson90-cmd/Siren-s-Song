# Handoff 019: ARCH1, behavior-preserving cleanup of the shared choke points

Status: CLAIMED
Claimed at: 2026-10-23 03:35:16 UTC
Claimed by: codex
Finished at:

Precondition: handoff 018 must be DONE (so the refactor does not collide with it) and handoff 016 DONE (the test list file exists).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally, because CI stops at its first failure. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Every feature is a self-contained module with one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules beyond what these handoffs say Pat approved. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/ARCH_AUDIT_1.md on branch codex/handoffs. Do steps 2, 3 and 4 of its ARCH1 plan, each as its own small pull request, each provably behavior-preserving: (2) one save-check registry (a save_checks list that features register into) plus the enemy-type list moved out of simulation.gd; (3) one shared "cancel_released" helper replacing the five hand-copied versions; (4) extract player orders out of simulation.gd command() into game/src/simulation/orders/ files behind one lookup table, one family per PR: weapons, then sensors, then route and drive, photo last. Prove each step: run the core suite before and after and show identical check counts, run the targeted suites named in the audit for that step, and let GitHub game-smoke run the rest. No renames, no rewrites of physics or sonar math, no changes to mission content rows, no new test layers. Pause new orders while an extraction PR is open (nobody else should be adding orders; if someone is, wait).
Steps 5 and 6 (main.gd extractions, HUD/ocean-view contract) are NOT in this handoff; they wait for a later one.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branches: claude/arch1-save-checks, claude/arch1-cancel-helper, claude/arch1-orders-weapons, and so on.

## Files you must not touch
Game rules and numbers (move them verbatim), mission content, story text.

## What done looks like
Each step merged with identical behavior (same check counts, CI green). Record the conventions note from the audit as docs/CONVENTIONS.md (under 30 lines).

## Return
PRs into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

In progress, not DONE. Step 2 merged in PR81: https://github.com/pemunson90-cmd/Siren-s-Song/pull/81
- claude/arch1-save-checks: c7c5cfd9e97d0ea1e6bb04b924a0e1ac4ae69948; exact-head CI39896278323 guidance/game-smoke green; merged4e89cc37bac9d55fc160c1a4e0e6797bee4f1ff8.
- Step 3 PR83: https://github.com/pemunson90-cmd/Siren-s-Song/pull/83; claude/arch1-cancel-helper pushedfaff74e4189fb095ce2ecf23cd1af4d534c090d7; CI39898572326 pending.
- Prepared dependent lane claude/arch1-orders-weapons: 5893121.
- Prepared dependent lane claude/arch1-orders-sensors: 3427ef0.
- Prepared dependent lane claude/arch1-orders-route: 1474ba3.
- Prepared dependent lane claude/arch1-orders-photo: f25c5eb.
All lanes pushed. Each dependent step must merge fresh integration and open its own PR only after its parent has merged; exact-head guidance/game-smoke and mergeability remain mandatory. No force pushes, APK, main or production changes.

Godot4.6.3 import clean; core817/0 before and after every prepared step. Save checks: Well9/0, equipment10/0, divergence12/0, sweeper52/0. Cancellation: delivery63/0, witness UI108/0, module55/0 plus UI37/0 and runtime22/0, recipient69/0, Glass42/0+14/0+40/0+9/0+UI28/0, journey70/0; industry47/0, chain49/0, depth112/0. Weapons: combat17/0, knock59/0, decoy14/0, UI30/0. Sensors: depth112/0 and delivery63/0. Route: drone23/0, program35/0, all-stop31/0; real touch/UI route44/0, drone38/0, all-stop12/0, telemetry46/0. Photo: capture52/0, study save45/0, pricing64/0, depth49/0, rules49/0, UI9/0+11/0+4/0, departure45/0. Final injected-touch cold-review218/0 includes Android Back at cover/inner; headless locally, hosted CI owns rendered coverage. No physical-device claim.

Source comparisons preserve original order bodies after resolving receivers/constants and expanding the shared leg-mode helper; all41 keys registered exactly once. Original guard ordering, early returns and cleanup are retained. No game rules, save shapes, inputs, mission rows or test assertions changed. New modules have revert notes; CONVENTIONS is under30 lines. Independent reviewer /root/review_arch1 (fresh context, requested gpt-6.1-sol Medium) approved sourcef25c5eb6a66212d589b94e134087f29b11410aef against7089470: no Critical/Important/Minor findings, declined-to-judge[]. Relayed verdict is recorded in PR81 and PR83; CI gates remain separate. One first import in the separate baseline worktree hit a Godot threaded-import crash; clean reimport and affected baseline tests subsequently passed. No tests were loosened or skipped.

Resume: git fetch origin; inspect PR83 exact-head checks; if green and mergeable with current integration as ancestor, merge with a merge commit. Then merge fresh integration into claude/arch1-orders-weapons, open its own PR and continue through the dependent branches above. This task remains CLAIMED until every required step has merged. Mark DONE and update BOARD in one final commit only then.
