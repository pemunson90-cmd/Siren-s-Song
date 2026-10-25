# Handoff 043: SAVE2, hard saves, fork save states, and a truthful ending screen

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 17:03:24 UTC
Claimed by: codex
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

### In progress, 25 October 2026, 2:30 PM Eastern

Last published lane head a449f1bc; draft PR143 remains unmerged. Storage194/0 and fork46/0 cover the reproduced profile rollback and pending-fork launch failures, failed cold rollback, oversized quarantine recovery, recovery-path validation, explicit deletion of unreadable fork slots, exact profile isolation and replay recovery counts. Core836/0, import and registry261/0 pass. Native profile168/0, ending42/0, menu309/0, Settings23/0 and Operations1502/0 pass. Current SAVE2 UI source/test changes remain uncommitted while 150 percent text/touch checks are resolved; normal-text replay200/0 is historical evidence, not final acceptance.

Evidence checkpoint [220a4d39](https://github.com/pemunson90-cmd/Siren-s-Song/tree/220a4d39/evidence/043-windows-20261025) preserves94 raw log/probe members with verified CRCs, exact sizes and SHA256. The initial double-activation theory was premature: isolated native/headless probes show the inherited combined viewport touch/mouse helper activates once. Physical touch parsing instead requires engine emulation and the window coordinate transform. Failed input experiments remain recorded; no final touch result, exact-head approval or hosted gate is claimed. Further work continues on the same claim.

### In progress, 25 October 2026, 2:09 PM Eastern

Draft PR [143](https://github.com/pemunson90-cmd/Siren-s-Song/pull/143), published WIP c569c29f. Storage153/0, fork controller30/0, touch UI110/0 at both Fold shapes, core836/0 and registry261/0. Existing save-profile68/0 plus cold3/0, FIX2 SAVE12/0, state10/0 and save UI4/0 passed. The save UI retry-failed message is the existing test's deliberate persistent-storage-failure fixture. Additional focused save/ending regressions are recorded in local evidence; final exact-head review and hosted checks remain pending.

Storage hardening preserved the original RED106/1 plus malformed Variant errors, then fixed strict bounded decoding; later RED152/6 demonstrated oversized unreadable files could not be explicitly cleared. Confirmed deletion now moves those originals into a retained recovery bucket without unbounded reads, making the slot reusable while preserving original bytes and timestamps. UI parsing and touch-fixture failures remain in raw logs; latest run110/0 supersedes them without deleting evidence. Intermediate non-author review found that SAVE1 raw profile snapshots need to recover a pending SAVE2 journal first, otherwise later cold recovery could undo a confirmed import/clear. Targeted RED coverage and the narrow public-save-layer fix are in progress. This handoff is not DONE.

### Implementation plan,25October2026 Eastern

- New self-contained persistence/save_states module: pure table/optional-field validator, bounded storage/transaction helper, controller, fresh-session adapter, and UI. Revert flag hides new UI/capture behavior while retaining every saved file; pending recovery remains safe. No simulation/rules/camera/ending-selection changes.
- Three manual and four fork files live in a sidecar directory derived from the already-pinned live Store path. SAVE1 profile copy/import/export/clear retains its existing four-file contract; these sidecars stay with the physical profile slot. Explain this in SAVE2 UI and test isolation. Existing autosave contents/path remain the authoritative live campaign.
- Reuse existing archive validation/checksum format through public SaveStore APIs. Add strict primary inspection without backup fallback, optional validated metadata, a public path-pinning adapter, and a tiny leaf recovery guard. Reject unreadable occupied targets and preserve their bytes; explicit confirmed deletion is the only way to clear one. Save/overwrite/load/delete confirmations bind the displayed target fingerprint, so a stale confirmation cannot replace changed data.
- A SAVE2-owned whitelisted single-entry transaction stages and verifies bytes, journals the previous primary/backup/tmp bytes and absence, commits, and rolls back on failure. Cold SaveStore reads/writes recover a pending journal first or block safely. No profile-store private helpers or arbitrary journal paths. Tests inject failures at actual filesystem boundaries.
- Manual saves are allowed only between dives, including no unfinished Resume dive. Snapshot metadata includes name, last recorded recovered operation, successful recovery count and timestamp. A new optional validated live save2_state tracks successful recoveries including replays; legacy archives start at the known unique-recovery minimum and are labeled honestly. Independent cryptographic run/launch IDs avoid touching gameplay RNG and guard pending-candidate association across restore/profile replacement.
- Fork candidates are full prelaunch archives persisted separately, never nested into live saves. A narrow prelaunch hook runs before launch mutation, and a recovery hook compares actual committed state only after successful first recovery. Cover initial route, selected thread, Confluence route, first old ending, Glass choice, Choir choice/people/plant. Keep at most four chronological snapshots; a fifth distinct snapshot replaces the oldest readable entry. Never destroy unreadable entries. Exact duplicate pre-choice snapshots are idempotent; device timestamps do not control rotation.
- Restore the snapshot exactly, rather than merge later film/fittings: existing validation couples earned fittings, fleet, references and campaign history, and no safe general merge API exists. The confirmation explicitly says later film, fittings and recovered operations are replaced. Suspend old Store/retries/processes before replacement; after successful atomic commit discard old callbacks and construct a fresh host with the same pinned profile/custom path and settings path. Failed writes retain the old session and previous files, or block until cold recovery succeeds.
- Keep transport metadata out of restored live payloads. An optional between-dive marker prevents a stored archive's inactive/terminal simulation snapshot from becoming an unintended Resume dive after restore. Preserve every existing campaign field, film, fitted equipment and optional extension value. Fork restore returns to Operations for deliberate relaunch.
- Operations gets HARD SAVES; both ending paths get REPLAY FROM FORK. The legacy ending is labeled FIRST ENDING when a later ending exists. CONTINUE entries require an available, not-yet-recovered target, leaving mission availability/replay rules unchanged. The existing erase confirmation gets an unchecked second option to delete this profile's SAVE2 files; otherwise all slots/states survive. Specific SAVE2 Back handling returns one level.
- Reserved new suite ranks: storage245/CI265, forks246/CI266, UI247/CI267. Observe baseline RED before implementation, then real-disk round trips, corruption/old-save/failure recovery/profile isolation/fork-before-choice/counting/rotation/erase coverage, plus real touch and Android Back on both Fold shapes. Import/core and named save/ending/menu regressions only locally. Publish WIP within30minutes; exact-head independent review and hosted guidance/game-smoke before merge. No full local matrix, APK, phone request, branch deletion, force push, amend or no-verify.

Initial read-only architecture review identified why the old autosave fallback cannot be reused blindly for manual slots, and why capturing at debrief entry is already too late for a true pre-choice snapshot. The non-author save reviewer remains separate from implementation and will test the final exact head. No old save, profile, source file or gameplay rule was modified during planning.


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.
