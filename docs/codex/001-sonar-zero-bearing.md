# Handoff 001: fix the sonar save bug when an enemy sits exactly on Quietus

Status: OPEN
Claimed at:
Claimed by:
Finished at:

## Task (plain language)
Your own lane T report found a bug: if Quietus sits still for a long time, an interceptor can end up exactly on top of it. The game then stores a sonar direction of zero length, and the save check (`Sonar.valid`) refuses that moment, so an active game cannot be saved or restored. It already existed before your change (reproduced on the old code, `BASELINE_COINCIDENT_BEARING rows=1 sonar_valid=false`). Fix it so the game stays savable. Do not change how sonar works for the player: the same bearing rules apply everywhere except this exact overlap case.

## Base and branch
Base: origin/claude/integration (fetch fresh; it moves often). Create branch: claude/lane-t2-sonar-bearing

## Files you may edit
- game/src/simulation/advanced_sonar.gd
- new test files under game/tests/ for this bug (register any new test in .github/workflows/gauntlet-pr-checks.yml)

## Files you must not touch
Everything else, especially: simulation.gd beam, lock and hull code (another worker is changing combat rules right now), campaign files, story text, equipment files. If the cleanest fix needs another file, stop, mark the handoff BLOCKED and explain in Completion.

## What done looks like
- The coincident case no longer produces a snapshot that fails `Sonar.valid`: a save and restore round trip works with an enemy exactly on Quietus.
- A test fails before your change and passes after.
- Normal bearings, history and classification behave exactly as before (existing sonar tests unchanged and passing).
- Pick the smallest sensible rule (for example, treat a zero-length bearing as no reading, or store a fixed fallback direction) and say in Completion which one you chose and why.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean.

## Return
Pull request into claude/integration. Claude merges.

## Completion
(Codex fills this in.)
