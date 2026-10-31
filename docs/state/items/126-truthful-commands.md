# Item 126: Truthful commands (PR 238)

Goal (player): Every action says what it does: real exit names, legal work approach points, a reason on every grey action, per-craft tool counts.
Why now: Critic 123 C44/C23/C53, PLAN_DRAFT_1 package 1. Repair 3 committed and independently approved, being pushed.
Class: text
Areas: hud.wording
Files: as already in PR 238
Serial zones touched: mission_hud.gd
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
Required CI green on the pushed repair head; truthful_commands_tests and status_text_ui_tests green.

## Do not
Change layout, hit-testing or chart camera (package 2).

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
Existing PR 238 body plus one line for repair 3.

## Builder notes
Branch claude/truthful-commands from origin/claude/integration. Preferred provider: codex then claude:sonnet.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
