# Item PKG2: Stable board and clear threat (PR 239, Claude takeover 1 Nov)

Goal (player): The board does not move under your finger; overlapping targets get a chooser; threat text is never covered; every craft action reachable at 150%.
Why now: Critic 123 C02/C07/C08/C09/C15/C20/C52 (COLD_REVIEW_5 ranks 1, 2, 5, 6), the largest player cost left. Pat 1 Nov: "#239 yes. There is no codex until nov3/4" (Claude takes it over from Codex root).
Class: ui
Areas: hud.layout
Files: game/src/presentation/chart_camera.gd, game/src/presentation/chart_stop_choice.gd, game/src/presentation/concealed_harbour_view.gd, game/src/presentation/expedition_view.gd, game/src/presentation/field_tool_view.gd, game/src/presentation/fleet_instruments.gd, game/src/presentation/hunt_meter.gd, game/src/presentation/industrial_view.gd, game/src/presentation/order_guard.gd, game/src/presentation/rendezvous_view.gd, game/src/presentation/shelf_habitat_view.gd, game/src/presentation/status_text/status_view.gd, game/src/presentation/wake_crossing_view.gd, game/src/presentation/warning_chain_view.gd, game/src/presentation/warning_recipient_view.gd, game/tests/** (fixture answers and the stable_board suites only)
Serial zones touched: main.gd, mission_hud.gd, ocean_view.gd
Depends on: none
Protected rules touched: none

## State at takeover
Branch root/stable-board-pkg2 head 716c895a: all 8 CI checks green on its old base 75e561e7 (run 41257658446); independent reviews HIGH99/102/106/107 approved (see PR 239 comments; earlier root notes are in this file's Git history). It is 65 commits behind origin/claude/integration (126, 127, 130, 131, 133, 137-145 landed since; several touch mission_hud.gd, ocean_view.gd and the same fixtures).

## Acceptance test (fails before, passes after)
The existing stable_board_ui_tests, stable_board_inner_normal_ui_tests, stable_board_inner_mirror_ui_tests and stable_board_cover_mirror_ui_tests (all eight cases, 34 captures) pass on the merged head; they do not exist on origin/claude/integration, so record that as the RED BEFORE line. Every suite that passes on integration still passes in CI.

## Do not
Rebase or force-push the branch: merge origin/claude/integration into it. Drop or loosen any PKG2 case or assertion, or any assertion of the merged items. Change wording or route targets (126), release controls (127), recovery manifest (133, 143) or the launch guard (142); where they meet PKG2 code, keep both behaviours. Edit docs/RESUME.md: take integration's version (item 146 owns it). Change protected rules (beam, lock warning, collision, senses, photo grading, endings).

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: the conflict list and how each was resolved, the stable_board counts, control ids reachable at 150% on both shapes.

## Builder notes
Work in the existing branch root/stable-board-pkg2 (PR 239). Preferred provider: claude:opus. First `git merge origin/claude/integration`, resolve, then run import, core, the four stable_board suites and the suites of every file that had a conflict. Push and refresh the PR body (under the ui cap). The full matrix is CI's job.
Checks before push: the minimum (RULINGS.md speed rule).
