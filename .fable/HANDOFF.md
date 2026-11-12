# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-12 at commit 075f627e (rewritten by root at the Phase 3 exit; the first version was written and cross-checked by two subagents on 2026-11-11)

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone.

## 1. Resume in five steps

1. **Open this folder as the project** (`repos\_fable\Siren-s-Song`), so the hooks in the tracked `.claude/settings.json` load: the command guard, the post-command restore check, the session-start hook and the stop gate. Two sessions so far were started in Pat's other clone and pointed here; in those the command guard did not load and its rules were applied by hand (decision D-01). The git-level hooks in `.git/hooks` work either way.
2. **Run `/siren-s-start-fable`.** It sets the run parameters (`PLAN_GATE=off`, `APK_AT_END=yes`, `SUBAGENT_LIMIT=3`) and tells a resumed session to continue from `next_action`.
3. **Read, in full and in this order:** `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.fable/RUN_STATE.json`, the last 50 lines of `.fable/RUN_LOG.md`, `.fable/DECISIONS.md`, this guide, `.fable/NOW.md`, then `.fable/OVERHAUL_PLAN.md` and `AGENTS.md`.
4. **Check for staleness:** `python scripts/repo/handoff_check.py`, `git status --short`, `git log --oneline -15`, `git worktree list`, `git ls-remote origin 'refs/heads/fable/*'`, and `gh pr view 262 --json state,isDraft,headRefOid`. Rerun the four guard self-test commands of charter Phase 0 step 5 and log the result.
5. **Recover in-flight work (section 3), then continue** from `next_action`. Before each step record it with `python scripts/repo/run_state.py --now "..."`.

## 2. Where the run stands (pause of 2026-11-12)

The run is PAUSED for a usage reset, in Phase 4 (execution). Everything is committed and pushed on `fable/overhaul-20261111`. The draft pull request is https://github.com/pemunson90-cmd/Siren-s-Song/pull/262 into `claude/integration` (base `cabd5bd5`, unmoved).

| Phase | Result |
| --- | --- |
| 0 Preflight | Done. Base tag `fable/pre-overhaul-20261111`. Baseline import OK, core `CHECKS 850 FAILURES 0`. |
| 1 Survey | Done: `.fable/SURVEY.md`, `.fable/PROTECTED_CAPABILITIES.md` (390 rows), `.fable/DOC_INVENTORY.md`, `.fable/BRANCH_LEDGER.md`, `.fable/CI_INVENTORY.md`, `.fable/COLD_REVIEW_6.md`. |
| 2 Plan | Done: `.fable/OVERHAUL_PLAN.md`. |
| 3 Foundation | Done and green: full matrix run 43188734403 on 075f627e passed (guidance, core, four runtime shards, smoke). |
| 4 Execution | Merged, reviewed and verified locally: WP-05 harness, WP-06 release hygiene, WP-07 operation metadata and guides, WP-08 readable detection and loss, WP-09 planning camera and order flow, WP-10 photograph flow, WP-12 route options document. Last local core on the merged head: `CHECKS 850 FAILURES 0`. **Open: WP-11** (built on its branch, not reported, not reviewed, not merged) and the Phase 4 CI gate. |
| 5 and 6 | Not started. |

Condensed reports of every implementer and reviewer are in the fable-notes folder of the tool cache (`report-wp*.md`, `review-wp*.md`); each merge's verdict and checks are in `.fable/RUN_LOG.md`. `CHANGELOG.md` lists every player-visible change so far.

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

Ten are open in `.fable/DECISIONS.md` (D-01 to D-10). None blocks the run. D-08 (photo pay table) and D-09 (drone pace and an early purchase) came from the blind critics.

## 7. What comes next

Finish Phase 4 per the plan, then Phase 5 (merge the base if it moved, recheck every ledger row, full gate, one debug package through `gh workflow run android-validation.yml --ref fable/overhaul-20261111`, behavior-change table from the diff) and Phase 6 (commit the archive dry run as BRANCH_ARCHIVE_PLAN.md under .fable, write FINAL_REPORT.md under .fable, put it in the PR body, mark the PR ready, set status DONE).
