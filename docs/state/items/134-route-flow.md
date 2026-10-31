# Item 134: Route flow (package 4)

Goal (player): A new measurement that leaves the course clear does not stop you; a stop names the obstruction.
Why now: Critic 123 C12.
Class: sim
Areas: sim.orders
Files: to be set after 127
Serial zones touched: none
Depends on: 127, PKG2
Protected rules touched: none

## Acceptance test (fails before, passes after)
to be set

## Do not
Reveal unmeasured terrain.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
sim class.

## Builder notes
Branch item/134-route-flow from origin/claude/integration. Preferred provider: codex then claude:opus.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
