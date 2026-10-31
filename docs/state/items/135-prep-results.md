# Item 135: Prep and results (package 5)

Goal (player): Fittings and Career show the decision first; every dive-end path shows time, hull and oxygen.
Why now: Critic 123 C26/C32/C41.
Class: ui
Areas: equipment, economy, frontend
Files: to be set
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
to be set

## Do not
Change prices or economy.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui class.

## Builder notes
Branch item/135-prep-results from origin/claude/integration. Preferred provider: codex then claude:sonnet.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
