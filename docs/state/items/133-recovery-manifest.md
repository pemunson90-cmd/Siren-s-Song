# Item 133: Recovery manifest (PLAN_DRAFT_1 package 3)

Goal (player): Before the dive ends you see which craft are in or out and can hold or confirm; own craft get a path conflict warning.
Why now: Critic 123 C11/C19/C06.
Class: sim
Areas: campaign.flow, hud.wording
Files: to be set when the item is refined
Serial zones touched: none
Depends on: 127
Protected rules touched: none

## Acceptance test (fails before, passes after)
to be set: a staged op where a drone is outside recovery shows the manifest and holds on request.

## Do not
Change collision or damage.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui class.

## Builder notes
Branch item/133-recovery-manifest from origin/claude/integration. Preferred provider: codex then claude:opus.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
