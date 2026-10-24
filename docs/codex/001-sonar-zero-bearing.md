# Handoff 001: fix the sonar save bug when an enemy sits exactly on Quietus

Status: DONE
Claimed at: 2026-10-21 19:18:47 UTC
Claimed by: codex
Finished at: 2026-10-21 20:15:58 UTC

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

Current verified state,24October2026: DONE, PR59 merged atde03f29bd2cee12a2fb694eddb68b999675203d8 on21October2026,4:56PM Eastern. GitHub merged=true and current integration ancestry verified. The original recommendation to merge below is historical and already satisfied. No new tests are claimed.

### Historical original report

Fixed the save failure when an enemy occupies exactly the same position as Quietus or another sonar receiver. At that exact overlap, there is no horizontal bearing, so the game now omits the undefined passive reading and active echo instead of inventing a direction. Nearby readings, other receivers, existing echo history, pulse costs and terrain returns stay the same. Save validation and combat rules were not changed.

Pull request: https://github.com/pemunson90-cmd/Siren-s-Song/pull/59

Tests: the new regression test failed before the fix (17 failures) and now passes all 41 checks, including writing and restoring a real checksummed save. Import is clean. Core: CHECKS 758 FAILURES 0. The prescribed local script passed all 67 scenarios and ended ALL SCENARIOS OK. No existing test was changed, skipped or loosened. Independent review found no issues.

GitHub guidance and game-smoke both passed. Run: https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39665895837

Could not verify: no physical Android device run was performed. No APK was built. No file outside the allowed sonar source, new test and required workflow registration needed a change.

The completion note was committed through GitHub after the workspace shell disconnected. Only this handoff file was updated on codex/handoffs.

Recommended next: Claude should review and merge the pull request. No game-design decision is needed from Pat for this fix.
