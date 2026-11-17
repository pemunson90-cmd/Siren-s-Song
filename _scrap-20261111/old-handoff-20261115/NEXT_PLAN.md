# Next plan (written at the pause of 15 November 2026)

Status: LIVE PLAN (root rewrites it at every pause; the start command `/siren-s-start-opus` executes it in order)

Run `overhaul-20261111`, branch `fable/overhaul-20261111`, phase 9. Pat's order of goals (14 Nov): efficiency, then accurate and complete work, then the letter of his instructions. Every claim to Pat carries its evidence or says "unverified" (a Stop hook checks). Pat's rulings of 15 November (verbatim in `docs/USER_DIRECTIVES.md`) change how this run tests; they are in "Rules of this round" below.

## Where things stand

Head and anything still running: `.fable/NOW.md`. Merged on 15 Nov: WP-126 to WP-143 (phone build script, sweep-12 fixes, play API for Expedition and Career, honest lock and torpedo answers, Pat's decoy rule, one-tap route planning, NEXT line, small screens, label clutter, order wheel, test retirement, panel-open chart fix). Behavior rows for 15 Nov are not yet written in `.fable/FINAL_REPORT.md` (step 2). The test set is now 140 suites (`game/tests/suites.txt`); 140 retired suites are listed in `game/tests/retired_suites.txt` and their scripts are in `_scrap-20261111/retired-tests/`.

## Rules of this round (Pat, 15 Nov; they win over older text in HANDOFF and PHASE9)

- **Tests justify their existence:** a suite stays only if it plays the game to an outcome, pins a rule Pat ruled on, or caught a real defect. Never add a layout, wording or pixel test; never keep a test known to fail ("no 'as usual' failures"): fix it, or list it in `scripts/toolchain/win/sweep-skip.txt` with a reason.
- **Retest per batch:** after 2 or 3 merges, one rerun of the touched suites on the merged head (Core when simulation, campaign or photo rules changed), then push. Never merge into a folder while a test run uses it.
- **Helpers: 45 minutes,** only the suites their change touches, report what is left unrun. Models: sonnet implementers and critics, haiku for documentation. At most 3 at once. Briefs start with "First read `.fable/HELPER_RULES.md`" and end "REPORT ONCE, then STOP"; stop each helper at its first report (TaskStop: helpers often keep test jobs running).
- **Full sweep only before a phone build,** as three shards in three worktrees: `.claude/worktrees/sweep`, `sweep2`, `sweep3` checked out (detached) at the head, then for i in 0..2 start `scripts\toolchain\win\full-sweep.ps1 -Repo <worktree> -Out <scratch>\sweepN-s<i>.txt -Shard <i> -Of 3` with every path in double quotes (an unquoted path with spaces made all three exit at once on 15 Nov). Logs: `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-root-s<i>\`.
- **The APK:** `scripts\toolchain\win\build-apk.ps1` builds and signs it locally and fails unless the signer matches `scripts/toolchain/signing/sirens-song-debug.certificate.sha256`. No emulator: Pat tests on his phone. The APK is 74 MB, above the 30 MB phone-send limit: give Pat the path `%USERPROFILE%\.cache\sirens-song-toolchain\apk-local\sirens-song-debug.apk` (SendUserFile shows it on the desktop only).

## Steps, in order

1. **Finish what the pause left** (see `.fable/NOW.md`): read sweep 14 (`scratchpad` sweep14-s0..2.txt are gone after a restart: rerun the three shards if NOW.md says it was not read); fix any failure under the rules above; if the APK of the head was not built, build it and give Pat the path.
2. **Record 15 Nov in `.fable/FINAL_REPORT.md`:** one behavior row per merged package WP-126 to WP-143 with every changed text old → new (the texts are in RUN_LOG and the merge commit messages; `git log --merges`). Haiku, 45 minutes.
3. **Pat plays the APK.** Ask him in one line what he hit first; his findings outrank the queue.
4. **Eleventh critic round** (alternating; this one checks the 15 Nov fixes in play). Kits from the head (`kit.py new`). Fun tester A: Campaign 01 to 06 headless with the play API. Fun tester B: one Expedition run and two Naval Career contracts headless (reachable since WP-136; `OPERATE.md`). Critic C: blind interface, inner screen, 150% text, screenshots. Rank in `.fable/PHASE9.md`; root checks each claim it relays.
5. **Queue** (re-rank with step 3 and 4 first):
   - In the zoomed-out overview the staged Quietus can sit under the viewfinder dock (found by WP-142).
   - A label fragment shows through the chart-stop card (`wp129-screens/cover100-after-loss.png`).
   - Drop the 130% text size from the large grid suites that remain (`opening_depth_policy_ui_tests`, `stable_board_ui_tests`, `depth_policy_ui_tests`, `menu_reach_ui_tests`): Pat's yes of 15 Nov.
   - "After ▶ RUN: orders run for X" keeps the strip row over the NEXT line while paused with orders (WP-128 asked).
   - Route Map at 150%; Game Modes page top-heavy at 150% inner (WP-132).
   - First water tap after DEPLOY reported dead by a critic, not reproduced (WP-127).
   - A debrief line when a decoy breaks a lock (WP-137 put it only in the message and event).
6. **Milestone for Pat (when he has played):** split the run into grouped draft pull requests (testing and tools; interface and text; rules Pat approved; bug fixes; documentation and process): a branch `fable/pr-<group>` from `origin/claude/integration`, cherry-pick that group's merges in order (`git cherry-pick -m 1 <merge>`), rerun their suites and Core, push with `[skip ci]`, open as draft. Ask Pat before opening them.

## Open for Pat (do not decide)

The six trial rules after he has played (rule 3 is off, rule 6 is moot); whether the rock warning should also vibrate; collision speed and film cost; operation 01 solved by one EMP; drones' scouting value; after op 01 every fitting needs alloy the player cannot earn yet (fun tester B, 15 Nov); op 05 Siren timelines identical between attempts (fun tester A); drones ramming Quietus costs hull without warning (fun tester A); the lock card's EMP offer ignores depth transmission (WP-131); N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9.
