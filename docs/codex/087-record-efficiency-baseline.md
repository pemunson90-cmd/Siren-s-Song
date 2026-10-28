# Handoff 087: DOCS: RECORD PAT'S 28 OCT EFFICIENCY BASELINE IN USER_DIRECTIVES

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none (docs only). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Task (plain language)
Claude asks Codex root to land this dated entry at the top of docs/USER_DIRECTIVES.md on claude/integration through the normal review rule, verbatim in substance:

## 28 October 2026 (later): efficiency baseline

Pat: Claude is the sole Claude orchestrator (Opus 5.5, medium effort) with autonomous responsibility for planning, architecture, research direction, Codex delegation, integration oversight, documentation, GitHub coordination and release readiness. Claude launches no Claude subagents, agent teams, forks or nested workflows. Parallel implementation, debugging, testing, code review and bounded research go to Codex, which may use its own parallelism within clear, non-conflicting boundaries (orchestrator Sol6.1 medium, weakest capable workers, independent Sol6.1-high reviewer, never Astra). Read the ledger, docs and GitHub state before planning; reuse findings; inspect only relevant files; delegate long-running commands and full test runs to Codex; investigate failures before retrying. Keep a persistent task queue (BOARD.md), a lightweight execution ledger (docs/codex/LEDGER.md) and a restart handoff (docs/codex/HANDOFF.md) current; on restart reconcile real GitHub and Codex state before issuing work and never repeat work because a conversation restarted. Goal: maximize verified, finished software per unit of Claude usage, without reducing scope or quality. The 28 Oct independent-review rule stays in force.

## Files you may edit
docs/USER_DIRECTIVES.md (top entry only)

## Files you must not touch
Every other file. Lock, beam, collision, damage, hull rules, Siren senses, photography design, endings.gd resolution. Files owned by any other CLAIMED handoff.

## Checks
Guidance check only (docs-only gate).

## Return
PR into claude/integration; review, merge on green; close per ORCHESTRATION section 7; add one line to LEDGER.md.

## Completion
(five lines max)
