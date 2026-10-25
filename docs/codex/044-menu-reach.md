# Handoff 044: MENU REACH, full settings, title, challenges and credits reachable from Operations

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 03:10:26 UTC
Claimed by: codex
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

### Implementation plan, 24 October 2026 Eastern
1. Reuse Frontend._settings_screen and its existing SettingsStore/FrontendSettings values in an embedded Operations context. Keep the fixed Operations Back and archive warning region; retire the smaller duplicate from normal routing. Preserve old screen/control IDs as adapters, not a second settings store.
2. Add a self-contained menu_reach module/table with a reversible flag and bottom Title/Challenges/Credits entries into the existing overlay. Contextual Back returns direct entries to Operations; challenge detail keeps its existing one-level list return. Title entry retains its internal navigation.
3. Keep erase behind existing confirmation and settings keys unchanged. Use shared master for mute and retain first-dive tips access in the shared renderer. Flush pending settings when dismissing so rapid Back cannot lose a change.
4. First add a focused touch test (delegated test-only agent, exact file menu_reach_ui_tests.gd) and observe baseline RED. Parent owns production. Register local241/CI261. Adapt affected old test fixtures to the shared view without weakening original behavior assertions; explicitly verify115selected, input effects, persistence, Back,48dp and unchanged dive state.
5. Native Windows import/core, named menu/frontend/settings/accessibility/scroll checks and new touch test, independent exact-head review with actual runs, fresh current integration merge and exact-head hosted guidance/game-smoke before merge. Preserve evidence and all original failures. No full local scenario list/phone/APK. Own code branch claude/lane-menu-reach on69fc9e46, claim7ca6bfec published.

Recovery, 24 October 11:27 PM Eastern: claimed044 in7ca6bfec after038 verified merge69fc9e46; plan904ea389. First WIP1f8c1b71 published within15minutes of claim, draftPR141 https://github.com/pemunson90-cmd/Siren-s-Song/pull/141. Current pushed88cb77ab412ac2fda30734ddee5f12c448e86552 adds pending-save/off-switch tests; base69fc remains current/contained. Shared Frontend settings builder has an embedded Operations context retaining sticky Back/archive warnings and existing IDs; new module/table bottom links reuse existing overlays with contextual Back. Master/mute share the existing master key; audio mirrors remain compatibility fields, no schema or camera/rules edits.
Baseline touch126/39 RED preserved. Candidate225/6 compared archive audio mirrors incorrectly; diagnostic proved only deliberately selected music/effects values changed via existing Android Back autosave, so the new test now compares every other field exactly and matches those mirrors to chosen values. Existing accessibility88/2 exposed reloading saved values over live choices; source corrected to use live choices on reopen, original assertion retained and88/0 rerun. Old test adapter expands full-settings IDs and explicitly waits for the existing300ms save debounce. Earlier candidate core836/home1472/frontend63/menu7/scroll17 all0 remain qualified prior evidence.
Exact88 author native menu297/0 includes12 new PNG writes; rules-menu15/onboarding30/Back17/Challenges86 all0. Fresh core and independent exact-head import/core/native/affected checks running; screenshots partly inspected, no overlap in representative settings/credits/challenges views. Registry255 validates0/0, suite241/261 leaves Claude ranks intact. Hosted40158097727 guidance121063732070 green, game-smoke121063732224 running. No merge/DONE. Evidence remains locally044-evidence pending archive. Physical Android and complete campaign/fork journeys unverified; no phone/APK/full local matrix.
