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
(Codex fills this in.)
