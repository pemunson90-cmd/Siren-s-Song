# Handoff 043: SAVE2, hard saves, fork save states, and a truthful ending screen

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 030 (SAVE1 profiles, copy/clear, export/import) DONE, because this builds on its profile and archive handling. Pat decided 24 Oct: yes to replaying endings without erasing, using "save states and hard saves" (cold review 3 finding F3).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header. Existing saves must keep loading unchanged. Push WIP every 30 minutes. No em dashes. Never change rules or the existing ending logic. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
Today, seeing a different ending means ERASE PROGRESS. Pat wants hard saves and save states instead. AI-DESIGNED interpretation, Pat to adjust:
1. HARD SAVES: 3 manual slots on the Operations or Settings screen. Each slot shows a name, last operation recovered, play count of recovered operations and a timestamp. SAVE HERE writes a full copy of the campaign archive between dives (never mid-dive); LOAD replaces the live campaign after a confirm that names what will be replaced; DELETE only through Pat's existing confirm pattern (the player's own slot, not repo files). Slots live next to the existing campaign file and use the existing validation path. The live autosave stays as is.
2. SAVE STATES at forks: when an ending is first resolved (the ops 13/14 ending), or a branch choice is first made, the game automatically takes one labelled snapshot ("Before the first ending", and similar for the Iron Choir and Glass Reach fork) into a separate fork-state list, up to 4 entries, oldest replaced only when a fifth is needed. Each snapshot keeps film (evidence gallery), fittings and recovered operations at that moment.
3. REPLAY FROM FORK: from VIEW CAMPAIGN ENDING, a button lists the snapshots and loads one after a confirm, keeping the player's best film and fittings earned afterwards if feasible via the existing merge rules; if merge is not safe, load the snapshot as is and say so. Report the choice in Completion.
4. Truthful ending screen: hide CONTINUE buttons for branches already recovered, and label the ending "FIRST ENDING" when later endings exist. Do not change which ending is chosen.
5. ERASE PROGRESS stays in Settings with its confirm and must not delete hard saves or fork states unless the player ticks a second explicit option.
6. All new save fields optional and validated; a corrupt slot is shown as unreadable and left alone, never overwritten silently.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-save2

## Files you may edit
A new self-contained module (slots, fork snapshots, UI, tests), narrow seams from Settings/Operations and the ending screen, and the save layer through its existing public API.

## Files you must not touch
Simulation, rules, endings.gd decision logic, camera, unrelated screens.

## What done looks like
By real touch at both Fold7 shapes: save to a slot, change the campaign, load the slot and get exactly the saved state; fork snapshot appears after the first ending and replay restores it; stale CONTINUE buttons gone; erase leaves slots alone by default; corrupt slot test; old-save load test; every existing save test green.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.
