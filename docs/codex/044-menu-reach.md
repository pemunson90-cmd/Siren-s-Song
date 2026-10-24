# Handoff 044: MENU REACH, full settings, title, challenges and credits reachable from Operations

Status: OPEN
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 038 (OPS HOME) DONE, so the Operations layout is settled. Pat decided 24 Oct: yes (cold review 3 finding F6).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, optional validated save fields. Push WIP every 30 minutes. No em dashes. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
The title overlay (full settings, Challenges, Credits) is shown once at boot (_boot_frontend is called only from _ready). After CONTINUE a player cannot reach high contrast, reduced motion, haptics, master volume, Challenges or Credits until the app restarts. The Operations screen has a different, smaller AUDIO / SETTINGS screen, and a 115% text size set at the title shows no selected button there.
1. One shared settings screen (the title one, which has the superset) used from both the title and Operations. Retire the smaller in-game duplicate by routing its button to the shared screen. Keep one source of truth for each setting; selected states must show correctly (including 115%).
2. At the bottom of Operations add TITLE, CHALLENGES and CREDITS buttons that re-show the existing overlay screens. Back returns to Operations. During a dive nothing changes.
3. ERASE PROGRESS stays in Settings only (see 038).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-menu-reach

## Files you may edit
The frontend/overlay and Operations presentation, their tests.

## Files you must not touch
Simulation, rules, save schema (settings keep their current keys), camera.

## What done looks like
By real touch at both Fold7 shapes and 960x432: every setting reachable after CONTINUE and takes effect; selected states correct; Challenges, Credits and Title reachable and Back returns to Operations; 48 dp targets; existing title and settings tests green.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.
