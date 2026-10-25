# Handoff 042: FINALE1 (PROVISIONAL), an END OF LINE screen when the last operation is first recovered

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 05:15:17 UTC
Claimed by: codex
Finished at:

Precondition: handoff 023 DONE or paused (touches debrief and campaign flow). Pat, 24 Oct: no firm answer on where the campaign ends; "mild blocker, pick a provisional repair". This is that repair. It is AI-DESIGNED and provisional: everything on the screen can be replaced by Pat later without rework.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers and text in a data table, optional validated save fields, a revert note in the module header. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules, or the existing ending logic at ops 13 and 14. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## UPDATE 24 Oct (Claude, after the independent review of PR122 / handoff 027)
Handoff 027 is DONE and changed the premise of this one: the campaign now ends with a final pair, ops 30 and 31 (ids 30 and 31 in the code; the old ops 13/14 ending still exists in Endings.resolve), and 027 already built the recovered-film photo wall (game/src/campaign/endings_photo.gd, game/src/presentation/endings_photo_view.gd, FinalPair.ENABLED). Retarget this handoff accordingly:
1. Do NOT build a second photo wall. The END OF LINE screen triggers only when the LAST operation (op 31) is first recovered, after or as part of the existing wall flow, not after op 30.
2. Reduce scope to: the 2 to 3 placeholder END OF LINE lines from recorded facts (data table, AI-DESIGNED placeholder, Pat to rewrite), the hand-off into the existing credits screen, and a VIEW END OF LINE button on Operations once seen.
3. Replace the raw uppercase fact-key labels on the wall (for example GLASS CHOICE / value) with short plain-word labels from a data table, presentation only.
4. Note: the ops 13/14 ending in Endings.resolve is ids 12 and 13. Do not touch it.
Everything below this line that says op 30 or builds a photo wall is superseded by the four points above.

## Task (plain language)
Source: docs/design/COLD_REVIEW_3.md F2. Finishing op 30 shows a generic EXPEDITION RECOVERED debrief with no finale, and no photo wall exists. Add a provisional closing sequence shown once, the first time the last operation (op 30) is recovered:
1. END OF LINE screen with 2 to 3 short placeholder lines chosen from existing recorded facts (choir_choice, choir_people, choir_plant and whatever the run already knows); a fixed fallback line from a data table when a fact is missing. Mark the table "AI-DESIGNED placeholder, Pat to rewrite".
2. A photo wall: a grid of the player's best recovered frames from the evidence gallery (it holds the photo keys), tap to enlarge, Back returns to the grid, grid scrolls by touch.
3. Then CREDITS (reuse the existing credits screen) and OPERATIONS. Add a "VIEW END OF LINE" button on Operations after it has been seen (placement per handoff 038 if landed, otherwise below VIEW CAMPAIGN ENDING).
4. Do not touch Endings.resolve or the ops 13/14 ending screen. Label the existing one nowhere new; just leave it.
5. Flag in the data table turns the whole feature off; a saved "seen" flag is an optional validated save field.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-finale-provisional

## Files you may edit
A new self-contained module (screen, table, tests), one narrow seam from the debrief or recovery path, the evidence gallery read-only accessor if needed.

## Files you must not touch
Simulation, rules, ending logic (endings.gd), save schema beyond one optional validated field.

## What done looks like
By real touch at both Fold7 shapes and 960x432: screen appears once after op 30 is first recovered, photo wall shows the best frames with tap to enlarge, Back and Android Back navigate one level, credits reachable, no clipping, 48 dp targets; flag off restores today's behavior; save and reload does not repeat it.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.

### Implementation plan,25 October2026 Eastern
- UPDATE governs: only first successful recovery of code id31, with both final-pair recoveries and the existing photo ending eligible. Reuse the027 wall/frames; do not create another wall or edit Endings.resolve/old ids12 and13.
- New finale module/table supplies exactly two short recorded-fact placeholder strings, marked AI-DESIGNED placeholder, Pat to rewrite. Plain labels map the four existing wall fact keys; values remain the actual recorded strings. Credits reuses the existing frontend via menu_reach and returns to Operations.
- One recovery seam uses the existing previous-progress snapshot before displaying the wall. A module-controlled header/credits section decorates that existing wall for first recovery or explicit VIEW END OF LINE replay; normal recovered replays keep the old wall. Operations gets the replay entry after seen.
- One optional validated root boolean end_of_line_seen, no version bump: tiny Main archive/restore helpers, SaveStore validator, and new-campaign reset. Missing field on an already-complete legacy final pair is inferred seen for manual replay access, never auto-opened at boot. Feature off hides its UI and preserves existing stored marker. These persistence/Operations adapters are required by the explicitly authorized optional field and replay button.
- Add unit243/CI263 and real-touch UI244/CI264 tests. First observe RED, then verify last31 versus30, facts/fallbacks, once/reload/manual replay, credits/Back, existing plates, flag off and malformed optional field. Import/core plus named wall/ending/save/UI tests only locally; exact-head independent review and hosted guidance/game-smoke before merge. No phone/APK/full local matrix.
