# Handoff 124: S8 PR AUDIT CLEANUP (PRs 225, 226, 228)

Status: QUEUED (claude-lane, Pat 29 Oct)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval, Claude's `CLAUDE INTENT: PASS` comment and green required checks on the exact head, merge commit.
Source: a read-only Haiku audit Pat authorised (29 Oct, S7 precedent) of merged PRs 225, 226, 228; Claude verified items 1 and 2 against the diffs (2026-10-29T20:44:35-0400). Behaviour-preserving except item 1 if it is a real mismatch.

## Task
1. **Career cargo chassis (PR228):** `career_state.gd` launch charges extra-tool cargo with hard-coded `"endurance"` (lines ~23-24) while the launch display uses `host.upgrade` (`economy_panel.gd:92`). Find the chassis a Career dive actually starts with. If it can differ from endurance, charge and display the same chassis and add a test; if Career is always endurance, document it in a one-line comment and add a test that proves it.
2. **Test hole (PR228):** `runs_offer_ui_tests.gd` ~67-71: the `session.sim.tools.has(tool) and` guard skips the count check when a key is absent. Assert the key exists for every allocated tool instead. Strengthen only.
3. **Duplication (PR228):** `mode_racks_view.gd` change()/show() duplicate `tool_racks_view.gd` edit()/show() and drop its `Racks.enabled` guard; reuse the existing view code. `tool_racks.gd` from_stock repeats template()'s unit mapping; share it.
4. **Small sprawl:** PR226 builds the `"%d:%d"` pair key inline three times in `tactical_aids.gd` (54, 61, 78): one helper. `mission_hud.gd` 352/362 re-preload frontend_settings inline: one const. PR225 `soundscape.gd` duplicate PhotoWave preload and repeated -7.5 literal: one each.
Leave PR226's lock-threshold auto-pause as is (Pat ruling 11).

## Bar
- Full SILENT bare voyages of ops 2 and 30 (STANDARD, ACCESSIBLE) and one Career and one Expedition op: identical before/after on every field, except item 1 if it fixes a real mismatch (then show the before/after cost).
- Net lines removed reported; no test loosened, skipped or deleted.

## Files you may edit
The files named above, their tests, docs, shared registration lines.

## Checks
Import + Core, tool rack/locker, Career, Expedition, runs offer UI, tactical aids and presentation suites.

## Return
PR into claude/integration with the before/after table; independent review; wait for CLAUDE INTENT: PASS; merge on green; close the BOARD row and add one LEDGER line.
