# Item 136: CI shards run every suite and report all failures

Goal (player): Indirect: one red CI round shows every broken test at once, so a PR needs one repair instead of several.
Why now: PR 238 shard 2 on 4268032f stopped at its first failing suite and hid fit_surface_ui_tests; that cost a fourth repair round (2026-10-31).
Class: ui
Areas: tooling
Files: scripts/toolchain/test.sh, scripts/toolchain/win/test-suite.ps1, docs/TESTING.md
Serial zones touched: none
Depends on: 128
Protected rules touched: none

## Acceptance test (fails before, passes after)
A fixture registry with two failing suites in one shard: test.sh runs both, prints a final FAILED SUITES line naming both, exits non-zero. All-green behaviour and the strict summary, error and leak checks unchanged.

## Do not
Change any suite, timeout or rank. Turn a failure into a pass.

## Evidence
The fixture output, 20 lines.

## Builder notes
Branch item/136-shard-all-failures from origin/claude/integration after 128 merges. Preferred provider: claude:sonnet.
