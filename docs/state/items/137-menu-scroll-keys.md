# Item 137: Menu panels scroll and take keyboard input everywhere

Goal (player): Every frontend menu panel scrolls to its last control by touch drag and wheel, and keyboard focus moves through its controls, so nothing is unreachable on a small screen.
Why now: Critic 123 C25 (frontend.gd:38, :120, :192), verified medium. Independent of 127 and PKG2.
Class: ui
Areas: frontend
Files: game/src/presentation/frontend/**, game/tests/menu_reach_ui_tests.gd
Serial zones touched: none
Depends on: none
Protected rules touched: none

## Acceptance test (fails before, passes after)
menu_reach_ui_tests (extend if it exists): for each frontend panel at 100% and 150% text, the last control is reachable by scroll and by focus-next; fails today on the panels C25 names.

## Do not
Touch the mission HUD, ocean view or campaign flow. Add a second scroll container inside a panel.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: per-panel table (panel, controls, reachable by scroll, by focus) before/after; test counts.

## Builder notes
Branch item/137-menu-scroll-keys from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: import, core, the affected suites for the changed files, the canary set once it exists.
