# Handoff 037: EARLY MODULE REWARD (Pat approved 23 Oct, decision D2)

Status: CLAIMED
Claimed at: 2026-10-23 19:43:52 UTC
Claimed by: codex
Finished at:

Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (see the 23 Oct entry D1 to D5). Touch-first (48 dp, Android Back), modular: one self-contained module, one narrow seam, numbers and the on/off switch in a data table, optional validated save fields, a revert note in the module header. Push WIP every 30 minutes. No em dashes.
Precondition: none.

## Task (plain language)
Full cold review: Fittings are empty through ops 1 to 3 and nothing is spendable, so the early loop has no reward. Grant one free fitting module after op 1 completes (use op 2 only if op 1 cannot hold it). Choose from existing modules the one that best teaches a decision with a visible effect on op 2 or 3 and costs nothing the opening cannot afford (read docs on modules in the code; prefer a mount that changes how you photograph or hide, not a combat rule). Show it in the debrief as a plain "NEW FITTING" line, then make it appear in Fittings ready to equip with a one-line explanation. Do not rebalance ops 0 to 5 or change oxygen, hull or any combat/detection rule. Optional-only gating from the Priced Shots design must still hold (ops finishable bare).
Module: self-contained grant table (op, module id, enabled flag) plus the debrief line; save a granted-flag in an optional validated save field so it grants once. Revert: flag off stops new grants; existing saves keep what they got.
Tests: grant occurs once after op 1, persists through save and reload, Fittings shows it at both Fold7 shapes by real touch, ops 0 to 5 opening journeys still win with the same hull, flag off gives today's behavior.

## Base and branch
Base: origin/claude/integration. Branch: claude/early-module-reward

## Completion

Isolated D2 preparation after036 preparation/re-review, while92/93 hosted gates run. Base is actual integration70b1f18; merge92 then93 before037, reconcile their actual integration and obtain final independent review/exact-head CI. No precondition is unmet. Design is already approved by D2; choose an existing photographic/hiding module from code without changing rules.
