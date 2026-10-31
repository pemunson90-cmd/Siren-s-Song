# Item 129: R3 protected rules golden test

Goal (player): Indirect: no protected rule can change without a red check and a ruling line.
Why now: RULING_TESTS.md R3.
Class: protected
Areas: tests.shared
Files: game/tests/protected_rules_tests.gd, game/tests/fixtures/protected_golden.json, game/tests/suites.txt
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
protected_rules_tests green on current integration; a one-line local edit to silent sight makes it red (shown in the PR).

## Do not
Change any constant.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
Golden file and the red/green demonstration, 20 lines.

## Builder notes
Branch item/129-protected-golden from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
