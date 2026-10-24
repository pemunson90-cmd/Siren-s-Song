# Handoff 041 (PRIORITY): BACK1, Android Back must never quit the app by accident

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none. Small; may be taken between steps of 023 if it does not touch files 023 holds, otherwise right after 023. Pat decided 24 Oct: yes (cold review 3 finding F1).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first, Android Back = Escape, self-contained, tests beside code. Push WIP every 30 minutes. No em dashes. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
game/project.godot has no application/config/quit_on_go_back line, so Godot's default (true) applies and one Back press on a phone can close the app. Every test injects the Back notification by hand, so none reaches the engine's quit path.
1. Set application/config/quit_on_go_back=false in project.godot.
2. On the top Operations screen, Back shows a short "Press Back again to exit" toast; a second Back within about 2.5 seconds quits. Every other screen keeps its current one-level-back behavior. During a dive Back stays Escape (pause and save as today). Put the timing and text in a data table.
3. Add a test that reads the setting and asserts it is false, and a test that the first Back on Operations does not quit and the second within the window does (use a quit hook or flag the test can observe; do not actually quit the test run).
4. Note in Completion that behavior on a real phone is unverified.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-back-exit

## Files you may edit
project.godot (one line), a small module for the exit-confirm logic, one narrow seam call from the Android Back handler, and tests.

## Files you must not touch
Simulation, rules, save schema, camera.

## What done looks like
Setting false and asserted; double-Back exit tested; all existing Back and Escape tests unchanged and green; CI green on the exact head.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
