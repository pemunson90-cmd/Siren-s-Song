# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-12 at the pause after phase 8 (sections 1, 2, 3, 4, 6 and 7 rewritten by root)

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone.

## 1. Resume in five steps

1. **Open this folder as the project** (`repos\_fable\Siren-s-Song`), so the hooks in the tracked `.claude/settings.json` load. Sessions started in Pat's other clone and pointed here run without the command guard: apply charter section 4.3 by hand (decision D-01).
2. **Run `/siren-s-start-fable`.** It names what to read and the standing rules, and tells a resumed session to continue from `next_action`.
3. **Read what the command lists:** `.fable/RUN_STATE.json`, `.fable/NOW.md`, `.fable/PHASE9.md`, this guide, `.fable/UX_AUDIT.md`, the tail of `.fable/RUN_LOG.md`, the 2026-11-12 sections of `docs/USER_DIRECTIVES.md`, and charter sections 4 and 11.
4. **Check for staleness:** `python scripts/repo/handoff_check.py`, `git status --short`, `git log --oneline -10`, `git worktree list`. Do not start any GitHub run to check anything.
5. **Continue** from `next_action`. Before each step record it with `python scripts/repo/run_state.py --now "..."`.

## 2. Where the run stands (pause of 2026-11-12, after phase 8)

Phases 0 to 8 are finished and pushed on `fable/overhaul-20261111`. Pull request 262 is a draft; its body is `.fable/FINAL_REPORT.md` (behind the file by behavior rows 54 to 56).

Phase 8 on 12 November: the code base audit (`.fable/CODE_AUDIT.md`) and the fixes Pat approved. Names defined once (`game/src/names.gd`). Player rules are the default for every dive, tests included. `main.gd` went from 931 to 765 lines (`dive_clock.gd`, `presentation/dive_input.gd`, `persistence/campaign_archive_flow.gd`). Career, Expedition and Challenges share one base for hiding the campaign, launching and the save notice, and Career and Expedition share one save core (`campaign/mode_archive.gd`). An independent review on Pat's eight headings found two real defects, both fixed. The test suites were trimmed (`.fable/TEST_TRIM.md`): 238 kept, 39 of them the everyday set, 152 retired to `_scrap-20261111/tests-retired/`.

**Next is phase 9, defined in `.fable/PHASE9.md`:** the UI and UX audit is delivered (`.fable/UX_AUDIT.md`); Pat has not answered its nineteen yes or no items. Ask him, fix the ten plain defects meanwhile, then build what he approves. Nothing is in flight; no code is uncommitted.

**GitHub Actions are off.** Pat's allowance for the month is spent. No workflow run is started; every push carries `[skip ci]`; all testing is local.

## 3. In-flight work and how to recover it

Nothing is in flight. Worktrees and branches of finished packages stay on disk (`git worktree list`, about a dozen under `.claude/worktrees/`); nothing is deleted. Branch `wp-28` holds one unmerged commit (2605793a, screenshots and target report moved out of `main.gd`) that root left out because it changed how a wait behaves.

Isolated worktrees are created at `main`, not at the run head, so every implementer brief tells the subagent to `git fetch origin fable/overhaul-20261111` and `git switch -c <name> origin/fable/overhaul-20261111` first. Push the run branch before dispatching so the subagent finds the head.

Merging a work package: root reads the diff (a separate reviewer only for risky code), `git merge --no-ff <branch>`, run the suites that test what changed, add a behavior row to `.fable/FINAL_REPORT.md` and a row to `docs/MODULES.md` for a new module, update state and log, push with `[skip ci]`.

## 4. Working rules a new session must know

- **Local checks run natively on Windows:** set `$env:ARTIFACT_DIR` to a fresh folder named `fable-*` under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`, then `scripts\toolchain\win\headless.ps1 -Action Import -Isolate`, `-Action Core` (about 100 s, 856 checks), `-Action Script -Script <suite> -Prefix "<PREFIX>"`. The everyday set is `scripts\toolchain\win\test-suite.ps1 -All -Profile local` (39 suites, about 20 minutes). Every test run gets its own fresh user-data folder and never touches the real save folder. To pass arguments to the game, call the script directly from PowerShell with `-GodotArgs @('--',...)`.
- **Linux check of tool tests:** WSL distribution `Foundry-Ubuntu-24.04` has Python and keytool, no Godot. Test on a clean LF export (`git archive HEAD | tar -x`), not on the CRLF working copy.
- **Never `cd` outside this clone in the Bash tool;** the other clone (`repos\Siren-s-Song`) must not be touched. Do not write backslash-heavy text through a shell heredoc: use the Write or Edit tool (two files were damaged that way and repaired).
- **`git add` only what belongs to the commit.** On 2026-11-12 ten staged scrap moves went into the plan commit 894c0c70 by accident; the next commit repaired the links.
- **Commits carry the noreply email** set in the repository-local git config. Two local tags are never pushed and cannot be removed: `fable/local-pre-reauthor-20261111`, `fable/guard-selftest-tmp`.
- **The tool cache is shared.** Write only into folders named `fable-*` or `critic6-fable-*` under `%USERPROFILE%\.cache\sirens-song-toolchain`. Subagent reports are saved in its `fable-notes` folder.
- **Run one Godot process at a time.** Two test jobs at once pushed a 470 s suite past its 480 s limit. Run the combined local suite `opening_depth_policy_ui_tests` as its two partitions (`opening_depth_policy_cover_ui_tests`, `opening_depth_policy_inner_ui_tests`).
- **Nothing is ever deleted** (Pat, 2026-11-12, verbatim in `docs/USER_DIRECTIVES.md`): move to scrap or leave in place. Put that sentence in every subagent brief.
- **Pat's rulings for this run** are appended verbatim to `docs/USER_DIRECTIVES.md` ("Rulings recorded by the overhaul run"). The one that changes plans: save files are minor priority (2026-11-11).
- **Critic kit:** `scripts/critic/`; latest kit instance `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-critic7-20261112` (built from 1dadecd7; evidence of the three UI critics and root's replay under `evidence/`). No critic game is running. Critics must use native pixel coordinates: two of them misread half-size screenshots.

## 5. Closeout routine after every task

1. Before a step: `python scripts/repo/run_state.py --now "what is about to be done"`.
2. After it: one call records state and log, for example `python scripts/repo/run_state.py --wp WP-05=merged --next "..." --checkpoint "..." --log "PHASE 4, what happened, evidence, next"`.
3. `python scripts/repo/handoff_check.py` and fix what it reports.
4. Commit state, log and notes with the change they describe, and push the run branch.

## 6. Open decisions for Pat

- `.fable/UX_AUDIT.md` Part B: B1 to B19, each with a recommendation. Not answered yet.
- Three play questions from his rules: `docs/V7_TO_GODOT_PARITY.md`, "Tests that still fly on the older rules".
- N-1 to N-7 in section 9 of `.fable/FINAL_REPORT.md`, and his playtest feedback.
- D-01 to D-15 are answered (`.fable/DECISIONS.md`).

## 7. What comes next

Phase 9 (`.fable/PHASE9.md`): Part A defects, Pat's answers to Part B, the approved repairs, a replay through the critic kit, then the open items from phase 8 and Pat's playtest feedback. Testing is local only; no GitHub run without Pat asking for it in the conversation.
