# Phase 9: UI and UX repair, and the queue after it

Status: LIVE PLAN (written 2026-11-12 at the pause Pat asked for; root updates it as items finish)

Pat, 2026-11-12 (chat, verbatim): "Once you're done and your work is checked for not just accuracy, but also necessarity, functionality, complexity, scalability, interoperability, stability, bend overall code-based health; I want to perform another comprehensive audit and repair of the UI and ux, please and thank you"

Pat, 2026-11-12 (chat, verbatim): "Pause after this task, configure the siren-s-start-fable command, unstale your docs, prep your next queue and self context handoff, and we'll clear and restart fresh on the next task."

## Where things stand

- Branch `fable/overhaul-20261111`, everything committed and pushed. Pull request 262 is a draft; its body is `.fable/FINAL_REPORT.md` (refreshed through behavior row 53; rows 54 to 56 are in the file and not yet in the pull request body).
- Phase 8 is finished: the code base audit (`.fable/CODE_AUDIT.md`), the approved fixes (A3 to A8, A10 measured; A1 and the second half of A2 wait for a real screen; A9 is item B16 below; A11 and A12 refused by Pat), the independent eight-heading review and its fixes, and the test trim (`.fable/TEST_TRIM.md`: 238 suites kept, 39 of them the everyday set, 152 retired to `_scrap-20261111/tests-retired/`).
- The UI and UX audit is delivered: `.fable/UX_AUDIT.md`. Part A is ten plain defects. Part B is nineteen yes or no items, B1 to B19, each with a recommendation. **Pat has not answered Part B yet.**
- GitHub Actions: Pat's monthly allowance is spent (12 November 2026, resets in about 18 days). No run is started by this run. Every push carries `[skip ci]` in its head commit message. All testing is local.

## Work, in order

### 9.1 Ask Pat for his answers to Part B (first thing after the restart)

One short message: the five that matter most (B1 stray taps close the wheel, B2 LAUNCH and RECALL on the wheels, B3 photos on the end-of-dive screen, B4 confirm before discarding a dive or run, B5 route dialog off the craft), then "yes to all recommended, or answer by number". Do not rebuild the list; point to `.fable/UX_AUDIT.md`.

### 9.2 Part A: plain defects (no answer needed; start here while waiting)

A1 to A9 in `.fable/UX_AUDIT.md`. A10 (failure screen read "DRONE A · ABOARD") must be checked first: find where the loss screen writes drone status and whether a launched drone can read as aboard after the dive ends. Small packages, one Sonnet implementer at a time on disjoint files, root reviews each diff. Player-facing wording changes go in `.fable/FINAL_REPORT.md` as behavior rows. Where to look: the wheel is `game/src/presentation/` (radial HUD, `mission_hud.gd`, `truthful_commands.gd`), tools wheel label source is the `field_tools` key, the Expedition lost screen is `presentation/runs/` (`run_summary_view.gd`, `expedition_session.gd`), the Supplies page is `presentation/economy_panel.gd`, tabs are in `presentation/frontend/` and the archive views.

### 9.3 Part B: build what Pat approves

One work package per approved item, in the order of the list (it is ranked by cost to the player). B8, B9 and B17 are wording: prepare a table of current text and proposed text for Pat before changing anything; story and mission text is his. B16 (use the full screen width; the old A9) is its own step after the others. Each change that alters what the player sees gets a behavior row and, where it touches a prototype mechanic, a line in `docs/V7_TO_GODOT_PARITY.md`.

### 9.4 Confirm on a screen

After Part A and the first approved Part B items: replay the changed screens through the critic kit (`scripts/critic/`, build a new kit from the head with a name starting `fable-`) and look at the screenshots yourself. Use exact native coordinates: the two dive critics misread half-size screenshots and reported taps "leaking" to the chart, which root could not reproduce. Give any future critic this warning in the dispatch text, not in the brief files.

### 9.5 Still open from phase 8

- **Three play questions from Pat's rules** (in `docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules"): the tender door photo with quiet drones, the scout-ahead opening, operations 17 and 30 on discovered charts. They wait for his playtest. The legacy rule path stays in the code until he rules.
- **Drawing cost (A1)** needs a real screen: his phone, or a windowed local run. The chart cache still hashes the whole chart each draw; do nothing more to it without a measurement.
- **Autosave:** 16 ms on this PC, about 7 ms ours. If Pat sees a regular small stutter on the phone, move the interval from 5 to 15 seconds.
- **Next code cleanups, by value** (from the review): one `DroneBay` question for "in the water, aboard or lost" in place of about 30 direct reads of `alive`; state moved out of `main.gd` (765 lines) for its helper modules; the unmerged second commit of branch `wp-28` (screenshots and target report) stays unmerged unless its wait behavior is made exact.
- **Pull request 262:** refresh its body from `.fable/FINAL_REPORT.md` (it is behind by rows 54 to 56). Editing the body starts no workflow.
- **A debug package for Pat's phone** needs GitHub Actions (the Android validation workflow). Do not start one. When Pat asks for a build, tell him it costs Actions minutes and ask whether to wait for the reset.

### 9.6 After Pat's playtest

His feedback and remaining answers (N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9, the survey question), then the items approved for after the playtest: photo pay retune (numbers shown first), fast-forward and a starter drone tool, late-campaign alternates. When he says his rulings are done: mark pull request 262 ready (that starts one check run: ask first while the allowance is spent) and set status DONE.

## Rules for this phase

The standing rules in `.claude/commands/siren-s-start-fable.md`. The ones that changed on 12 November: no GitHub Actions; local tests only, the everyday set before a merge of size; nothing deleted, retired tests go to scrap; decide without asking where Pat has delegated ("you can figure it out"), ask one yes or no line where the decision is his (game design, story, wording, spending).
