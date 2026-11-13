# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-13 at the pause in phase 9 (sections 1, 2, 3, 6 and 7 rewritten by root)

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone.

## 1. Resume in three reads

1. **Run `/siren-s-start-fable`** (best with this folder, `repos\_fable\Siren-s-Song`, open as the project so the hooks load; in a session started in Pat's other clone the command guard is not loaded: apply charter section 4.3 by hand, decision D-01).
2. **Read** `.fable/RUN_STATE.json`, `.fable/NOW.md`, `.fable/PHASE9.md` and the last 25 lines of `.fable/RUN_LOG.md`. `PHASE9.md` holds what Pat asked for, the working loop with its commands, what is merged, what was in flight, the queue and what is open for Pat.
3. **Check and go:** `python scripts/repo/handoff_check.py`, `git status --short`, then `next_action`. Do not start any GitHub run to check anything. Record each step with `python scripts/repo/run_state.py --now "..."`.

## 2. Where the run stands (pause of 2026-11-13, in phase 9)

Phases 0 to 8 are finished. Phase 9, the UI and UX repair, is under way on `fable/overhaul-20261111`; pull request 262 is a draft whose body is `.fable/FINAL_REPORT.md`.

Pat approved every item of `.fable/UX_AUDIT.md` by Claude's judgement. Merged so far (behavior rows 57 to 64): the plain defects, the button roles (`presentation/ui_style.gd`), the lost screen with its photographs and Pat's photo rule by difficulty, two confirmations, DEPLOY DRONE and RECALL on the wheel, the route dialog kept off the craft, the pause and FLEET controls drawn as buttons with a life support bar, status lines that stay current. `.fable/PHASE9.md` has the table, the packages in flight at the pause and the queue.

**GitHub Actions are off.** Pat's allowance for the month is spent. No workflow run is started; every push carries `[skip ci]`; all testing is local. The last full pass (run 43349293662 on 395c1b2a, before the test trim) was green.

## 3. In-flight work and how to recover it

`.fable/PHASE9.md`, section "In flight at the pause", lists the packages that were running, their branches and what each was told to build, and `.fable/NOW.md` says which were already merged. A helper commits to a local branch in its own worktree under `.claude/worktrees/`; `git log --oneline -3 <branch>` shows what it finished. A branch with commits is a report that never arrived: read the diff, run its suites, look at it in the kit, merge. A branch without commits: dispatch the package again.

Worktrees and branches of finished packages stay on disk; nothing is deleted. Isolated worktrees are created at `main`, so every brief tells the helper to `git fetch origin fable/overhaul-20261111` and `git switch -c <name> origin/fable/overhaul-20261111` first; push the run branch (with `[skip ci]`) before dispatching. Branch `wp-28` holds one commit left unmerged on purpose.

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

Listed in `.fable/PHASE9.md`, "Open for Pat": three things to judge in play, three questions from his rules, the phone build, and N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9. D-01 to D-15 are answered (`.fable/DECISIONS.md`).

## 7. What comes next

The queue in `.fable/PHASE9.md`: land the packages in flight, then the Career and Expedition briefings and results, fittings cards, the title backdrop, the route dialog switch, a fresh blind critic round, and the loop again. Testing is local only; no GitHub run without Pat asking for it in the conversation.
