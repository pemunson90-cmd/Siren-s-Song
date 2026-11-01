# Item 148: Android smoke tests match today's game

Goal (player): Indirect: the native Android smoke (install, lifecycle, touch targets, Siren roles, Blackwater) runs green on integration again, so a phone build is checked on a real Android runtime, not only built.
Why now: dispatch run 41352249311 (item 147) failed in scripts/toolchain/test-android-blackwater.py test_actual_fresh_fixture_and_ordinary_earned_archive_verifier: "ERROR: ordinary request was not earned" (earn.gd:15). The Android workflow last ran 19 Oct; 126/127 (truthful commands, release controls: one-press travel is test-only) and later items changed the flows these scripts drive.
Class: ui
Areas: tooling
Files: scripts/toolchain/android-*.py, scripts/toolchain/android-*.sh, scripts/toolchain/test-android-*.py
Serial zones touched: none
Depends on: 147
Protected rules touched: none

## Acceptance test (fails before, passes after)
`python3 scripts/toolchain/test-android-blackwater.py` and the other test-android-*.py pass locally (fail today), and one workflow_dispatch of native-smoke on this branch passes through the emulator smoke, or fails only for a hosted-emulator reason quoted from its log.

## Do not
Loosen an assertion or drop a check to get green: update what the scripts drive to today's controls (dev state may use test shortcuts, per Pat's 30 Oct ruling). Change game code; touch signing.

## Evidence (class cap)
Before/after test lines, the dispatch run id.

## Builder notes
Branch item/148-android-smokes from origin/claude/integration after 147 merges. Preferred provider: claude:sonnet. The native-smoke job is limited to gauntlet/production; for the dispatch proof, temporarily dispatch from this branch only if 147 widened the condition, otherwise report the local results and leave the hosted proof to the next production-equivalent run.
Checks before push: the minimum (RULINGS.md speed rule).
