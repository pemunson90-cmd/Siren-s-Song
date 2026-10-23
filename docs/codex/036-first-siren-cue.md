# Handoff 036: FIRST-SIREN CUE (Pat approved 23 Oct, decision D1)

Status: CLAIMED
Claimed at: 2026-10-23 19:21:32 UTC
Claimed by: codex
Finished at:

Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (see the 23 Oct entry D1 to D5). Touch-first (48 dp, Android Back), modular: one self-contained module, one narrow seam, numbers and the on/off switch in a data table, optional validated save fields, a revert note in the module header. Push WIP every 30 minutes. No em dashes.
Precondition: 035 DONE or at least its PR open (both touch warning UI; avoid overlap).

## Task (plain language)
Full cold review: in op 3 an unseen patrol locked onto a craft from beside the relay and the player had about 4 s to react; the lock banner was the first sign of danger. Add a cue BEFORE the first lock in ops 1 to 3 only: when a Siren first notices any of the player's craft (the same internal moment the existing code uses to start investigating or to start the lock), show a short warning mark with the bearing toward it and play a soft distinct warning sound, once per Siren per dive. Use existing signals only.
Hard limits: do NOT change Siren sight or hearing ranges, detection rules, lock duration (4 s), the beam, collision or damage. The cue is presentation of an existing event; it must not make the Siren notice sooner or later. The 035 and FIX1 warning pause behavior stays as is. Ops 4 and later: switch off in the table, behavior identical to today.
Module: game/src/presentation/first_siren_cue/ (name your choice) with data table (ops enabled, cue duration, audio id) and an enabled flag. Tests: cue fires once per Siren in ops 1 to 3, does not fire in op 4+, does not alter the simulation state hash across a scripted dive (cue on vs off give identical sim state), real-touch visible at both Fold7 shapes, audio event logged.

## Base and branch
Base: origin/claude/integration. Branch: claude/first-siren-cue

## Completion

Claimed while final019 PR92 runs its own gate. All remaining019 PRs are now open in order;036 preparation is isolated from photo orders. Merge92 before036, then reconcile actual newest integration into036 and obtain exact-head review/CI.035 is DONE, so this handoff's precondition is met. Approved D1 supplies the design; no new rule, story or pillar decision is needed.
