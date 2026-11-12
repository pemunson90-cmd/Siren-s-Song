# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-12 at the closeout (sections 2, 6 and 7 rewritten by root; earlier rewritten at the Phase 3 exit; the first version was written and cross-checked by two subagents on 2026-11-11)

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone.

## 1. Resume in five steps

1. **Open this folder as the project** (`repos\_fable\Siren-s-Song`), so the hooks in the tracked `.claude/settings.json` load: the command guard, the post-command restore check, the session-start hook and the stop gate. Two sessions so far were started in Pat's other clone and pointed here; in those the command guard did not load and its rules were applied by hand (decision D-01). The git-level hooks in `.git/hooks` work either way.
2. **Run `/siren-s-start-fable`.** It sets the run parameters (`PLAN_GATE=off`, `APK_AT_END=yes`, `SUBAGENT_LIMIT=3`) and tells a resumed session to continue from `next_action`.
3. **Read, in full and in this order:** `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.fable/RUN_STATE.json`, the last 50 lines of `.fable/RUN_LOG.md`, `.fable/DECISIONS.md`, this guide, `.fable/NOW.md`, then `.fable/OVERHAUL_PLAN.md` and `AGENTS.md`.
4. **Check for staleness:** `python scripts/repo/handoff_check.py`, `git status --short`, `git log --oneline -15`, `git worktree list`, `git ls-remote origin 'refs/heads/fable/*'`, and `gh pr view 262 --json state,isDraft,headRefOid`. Rerun the four guard self-test commands of charter Phase 0 step 5 and log the result.
5. **Recover in-flight work (section 3), then continue** from `next_action`. Before each step record it with `python scripts/repo/run_state.py --now "..."`.

## 2. Where the run stands (second closeout, 2026-11-12)

The run is finished. Phases 0 to 6 closed first at `247e0582` (full matrix run 43242777379 green). Pat then answered every decision and approved repairs (phase 7): bare-minimum testing on pull requests, the drone launch restored from the prototype (WP-13), a TITLE control (WP-14), a prototype parity audit (WP-15), housekeeping and archive tags. All of it is merged and pushed. The report is `.fable/FINAL_REPORT.md` and is also the body of pull request 262. Nothing is in flight. A new session waits for Pat's playtest feedback and his answers to the new questions N-1 to N-7 in the report.

## 3. In-flight work and how to recover it

Read `.fable/NOW.md`: its "In flight" table has the exact recovery steps for WP-11 and the ordered list of what follows. Worktrees and branches of finished packages stay on disk (`git worktree list`); nothing is deleted. Isolated worktrees are created at `main`, not at the run head, so every implementer brief tells the subagent to make its branch first with `git switch -c <name> <run head>`.

Merging a work package (charter 5.3): reviewer verdict, then `git merge --no-ff <branch> -m "merge(wp-NN): <title>"` naming the verdict, add the new suite rows to `game/tests/suites.txt` (root owns that file), run import, core, the new suites, the canaries and `python scripts/toolchain/check-suites.py`, update state and log, push.

## 4. Working rules a new session must know

- **Local checks run natively on Windows:** set `$env:ARTIFACT_DIR` to a fresh folder under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`, then `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate`, the same with `-Action Core` (about 180 s) and `-Action Script -Script <suite> -Prefix "<PREFIX>"`. Render suites run only on GitHub.
- **Linux check of tool tests:** WSL distribution `Foundry-Ubuntu-24.04` has Python and keytool, no Godot. Test on a clean LF export (`git archive HEAD | tar -x`), not on the CRLF working copy.
- **Never `cd` outside this clone in the Bash tool;** the other clone (`repos\Siren-s-Song`) must not be touched. Do not write backslash-heavy text through a shell heredoc: use the Write or Edit tool (two files were damaged that way and repaired).
- **`git add` only what belongs to the commit.** On 2026-11-12 ten staged scrap moves went into the plan commit 894c0c70 by accident; the next commit repaired the links.
- **Commits carry the noreply email** set in the repository-local git config. Two local tags are never pushed and cannot be removed: `fable/local-pre-reauthor-20261111`, `fable/guard-selftest-tmp`.
- **The tool cache is shared.** Write only into folders named `fable-*` or `critic6-fable-*` under `%USERPROFILE%\.cache\sirens-song-toolchain`. Subagent reports are saved in its `fable-notes` folder.
- **Run one Godot process at a time.** Two test jobs at once pushed a 470 s suite past its 480 s limit. Run the combined local suite `opening_depth_policy_ui_tests` as its two partitions (`opening_depth_policy_cover_ui_tests`, `opening_depth_policy_inner_ui_tests`).
- **Nothing is ever deleted** (Pat, 2026-11-12, verbatim in `docs/USER_DIRECTIVES.md`): move to scrap or leave in place. Put that sentence in every subagent brief.
- **Pat's rulings for this run** are appended verbatim to `docs/USER_DIRECTIVES.md` ("Rulings recorded by the overhaul run"). The one that changes plans: save files are minor priority (2026-11-11).
- **Critic kit:** `scripts/critic/`; kit instance at `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111` (built from the base). No critic game is running.

## 5. Closeout routine after every task

1. Before a step: `python scripts/repo/run_state.py --now "what is about to be done"`.
2. After it: one call records state and log, for example `python scripts/repo/run_state.py --wp WP-05=merged --next "..." --checkpoint "..." --log "PHASE 4, what happened, evidence, next"`.
3. `python scripts/repo/handoff_check.py` and fix what it reports.
4. Commit state, log and notes with the change they describe, and push the run branch.

## 6. Open decisions for Pat

D-01 to D-15 are answered (`.fable/DECISIONS.md`). New yes or no questions N-1 to N-7 are in section 9 of `.fable/FINAL_REPORT.md`.

## 7. What comes next

Pat plays the debug package and merges pull request 262. Approved for after the playtest: photo pay retune (D-08), fast-forward and a starter drone tool (D-09), late-campaign alternates and Siren pressure on optional operations (D-10). Testing rule for all of it: the bare minimum (`docs/WORKFLOW.md`); the full matrix only by manual dispatch before a release package.
