# Handoff 038 (PRIORITY): OPS HOME, make the Operations list a usable home screen

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-24 23:38:50 UTC
Claimed by: codex
Finished at:

Precondition: handoff 023 is DONE or paused by Pat; do not start while 023 holds main.gd and HUD files. Source: docs/design/COLD_REVIEW_3.md finding F5 (F13 as an optional small extra).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub game-smoke runs it. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track, and do not commit line-ending churn in .import files. Windows: see docs/DESKTOP_HANDOFF.md for the Windows Godot build.

## Task (plain language)
A fresh critic found the Operations list is 3.6 to 7.3 screens long. With everything recovered, the next operation is 5.2 screens down, ROUTE MAP 5.4, FITTINGS 5.6, VIEW CAMPAIGN ENDING 5.8, ERASE PROGRESS 6.0 (right under it) and SETTINGS 7.2. Every return from a dive lands at the top of this list, so players cannot find the next operation or the new route map.
1. Top of Operations: one large NEXT OPERATION button (the first AVAILABLE operation), and RESUME DIVE beside or above it when a dive is active. Mission rows must not shift when RESUME appears (keep the FIX2 rule).
2. Directly under it: ROUTE MAP and FITTINGS buttons.
3. Collapse recovered operations under a fold labelled RECOVERED (N), closed by default once N is 3 or more, open by default when N is below 3. Locked and available rows stay visible. Folding changes presentation only, never save data or what can be launched.
4. Keep ERASE PROGRESS only in Settings (with its existing confirm). Remove it from the Operations list.
5. Optional, only if small (F13): Android Back from the Field Manual returns to the briefing (the button says BACK TO BRIEFING), and Back from evidence gallery detail returns to the gallery before Operations.
Do not change what operations unlock, the route map content, the ending logic, or the Settings, Title, Challenges and Credits screens (reaching those from Operations is a Pat decision, not part of this).

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-ops-home

## Files you may edit
The Operations list presentation and its tests only (find the owning module after 023; add to main.gd only a narrow seam call).

## Files you must not touch
Simulation, rules, save schema (no new required fields), ending logic, camera files.

## What done looks like
By real touch at both Fold7 shapes and 960x432: NEXT OPERATION reachable with no scrolling on a fresh save, mid-campaign and with all ops recovered; ROUTE MAP and FITTINGS within one screen of the top; RECOVERED fold works; ERASE not on Operations; RESUME does not shift rows; scroll height with everything recovered under 3 screens at 2520x1080. 48 dp targets. Android Back unchanged except item 5.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.

### Active implementation plan, 24 October 2026 Eastern
- Preserve the existing operation builders and launch callbacks. A new ops_home presentation module rearranges their controls, with a data-table flag and no saved fields.
- Reserve a stable Resume slot, add Next using the first enabled unrecovered row, place map/fittings above the list, and group recovered rows behind a visit-local fold.
- Move the confirmed erase entry through a single Settings seam. Inspection found the small in-game Settings lacked the entry that already exists in title Settings; this seam is necessary to satisfy item 4 without changing the screen's other controls.
- Test fresh, two/three recovered, mid-campaign and all recovered fixtures with touch at both Fold7 shapes and the desktop fallback, normal/150% text, Back, unchanged launch access and the off switch. Import/core and affected menu/map suites precede exact-head review and hosted gates.
- Optional item 5 is deferred to keep this handoff limited to Operations presentation. Branch: claude/lane-ops-home. Claim fa6093bb is published. Code is not yet pushed or merged.
- Red test reproduced 133 failures before implementation. Baseline import clean and core835/0. Initial implemented touch253/0 and existing FIX2 menu24/0; expanded native checks are pending. Original failed fixture runs remain in local038-evidence.
Recovery, 24 October 7:49 PM Eastern: first WIP pushed within 11 minutes of claim. Branch claude/lane-ops-home at99c28c30af50da927ce25f97f58a4699ba2fa985. Draft PR136: https://github.com/pemunson90-cmd/Siren-s-Song/pull/136. Native large-text and affected checks still pending; do not merge yet. Header and stock folds address rendered failures; original failures remain in ../038-evidence locally. Core835/0 reran after the initial implementation. Optional Back cleanup remains unstarted.
