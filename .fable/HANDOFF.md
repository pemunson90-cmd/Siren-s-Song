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

## 2. Where the run stands

Phases 0 to 3 are finished. Phase 4 (execution) is in progress. The run branch `fable/overhaul-20261111` is pushed; the draft pull request is https://github.com/pemunson90-cmd/Siren-s-Song/pull/262 into `claude/integration` (base `cabd5bd5`, unmoved on 2026-11-12).

| Phase | Result | Where |
| --- | --- | --- |
| 0 Preflight | Done. Base tag `fable/pre-overhaul-20261111` pushed. Baseline: import OK, core `CHECKS 850 FAILURES 0`. Guard self-test exception recorded as D-01. | `.fable/RUN_LOG.md` |
| 1 Survey | Done. | `.fable/SURVEY.md`, `.fable/PROTECTED_CAPABILITIES.md` (390 rows, `python scripts/repo/ledger_check.py`), `.fable/DOC_INVENTORY.md`, `.fable/BRANCH_LEDGER.md`, `.fable/CI_INVENTORY.md`, `.fable/COLD_REVIEW_6.md` (three blind critics, partial coverage) |
| 2 Plan | Done. P0 is WP-00 to WP-05, P1 is WP-06 to WP-12, P2 is a backlog. | `.fable/OVERHAUL_PLAN.md` |
| 3 Foundation | Done: WP-00 (critic kit), WP-01 (ledger), WP-02 (governance: new `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/STATUS.md`, `docs/WORKFLOW.md`, `docs/GOVERNANCE_MIGRATION.md`, ten documents in `_scrap-20261111/`), WP-03 (hygiene), WP-04 (CI). Each was reviewed or checked as the run log records. Full matrix dispatched as run 43188734403 on 075f627e; its `guidance` job passed, the rest was still running at the time of writing: read it with `gh run view 43188734403`. | commits 4debf73f, 990b819f, 29553c36, 075f627e |
| 4 Execution | WP-05, WP-06 and WP-07 are being built by three implementer subagents in isolated worktrees. WP-08 to WP-11 follow one after another (they share HUD and input files). WP-12 is root's. | section 3 |
| 5 and 6 | Not started. | charter section 8 |

## 3. In-flight work and how to recover it

Subagents end with the session that started them. Their worktrees and branches stay on disk: list them with `git worktree list` and `git branch --list 'worktree-*' '*wp*'`.

| Piece | If the session died |
| --- | --- |
| WP-05 harness (golden extension, `never_disabled_tests.gd`) | Look for commits on its worktree branch (`git log 075f627e..<branch>`). If the work is committed and its acceptance lines are in the branch's files, send it to a reviewer; if not, relaunch an implementer with the brief in section 4 of `.fable/OVERHAUL_PLAN.md` row WP-05 (owned paths and acceptance are there). |
| WP-06 release hygiene | Same, row WP-06. |
| WP-07 operation metadata and guides | Same, row WP-07. Its parity fixture must be generated from unchanged base code before the refactor. |
| CI run 43188734403 | `gh run view 43188734403 --json conclusion,jobs`. A failure is attributed in the run log before Phase 4 continues; the two new Godot-dependent helper tests in `game-core` had never run on Linux with Godot before this run. |

Merging a work package (charter 5.3): reviewer verdict APPROVE, then `git merge --no-ff <branch> -m "merge(wp-NN): <title>"` naming the verdict, add the new suite rows to `game/tests/suites.txt` (root owns that file), run import, core, the new suite, the canaries and `python scripts/toolchain/check-suites.py`, update state and log, push.

## 4. Working rules a new session must know

- **Local checks run natively on Windows:** set `$env:ARTIFACT_DIR` to a fresh folder under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`, then `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate`, the same with `-Action Core` (about 180 s) and `-Action Script -Script <suite> -Prefix "<PREFIX>"`. Render suites run only on GitHub.
- **Linux check of tool tests:** WSL distribution `Foundry-Ubuntu-24.04` has Python and keytool, no Godot. Test on a clean LF export (`git archive HEAD | tar -x`), not on the CRLF working copy.
- **Never `cd` outside this clone in the Bash tool;** the other clone (`repos\Siren-s-Song`) must not be touched. Do not write backslash-heavy text through a shell heredoc: use the Write or Edit tool (two files were damaged that way and repaired).
- **`git add` only what belongs to the commit.** On 2026-11-12 ten staged scrap moves went into the plan commit 894c0c70 by accident; the next commit repaired the links.
- **Commits carry the noreply email** set in the repository-local git config. Two local tags are never pushed and cannot be removed: `fable/local-pre-reauthor-20261111`, `fable/guard-selftest-tmp`.
- **The tool cache is shared.** Write only into folders named `fable-*` or `critic6-fable-*` under `%USERPROFILE%\.cache\sirens-song-toolchain`. Subagent reports are saved in its `fable-notes` folder.
- **Pat's rulings for this run** are appended verbatim to `docs/USER_DIRECTIVES.md` ("Rulings recorded by the overhaul run"). The one that changes plans: save files are minor priority (2026-11-11).
- **Critic kit:** `scripts/critic/`; kit instance at `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111` (built from the base). No critic game is running.

## 5. Closeout routine after every task

1. Before a step: `python scripts/repo/run_state.py --now "what is about to be done"`.
2. After it: one call records state and log, for example `python scripts/repo/run_state.py --wp WP-05=merged --next "..." --checkpoint "..." --log "PHASE 4, what happened, evidence, next"`.
3. `python scripts/repo/handoff_check.py` and fix what it reports.
4. Commit state, log and notes with the change they describe, and push the run branch.

## 6. Open decisions for Pat

Nine are open in `.fable/DECISIONS.md` (D-01 to D-09). None blocks the run. D-08 (photo pay table) and D-09 (drone pace and an early purchase) came from the blind critics.

## 7. What comes next

Finish Phase 4 per the plan, then Phase 5 (merge the base if it moved, recheck every ledger row, full gate, one debug package through `gh workflow run android-validation.yml --ref fable/overhaul-20261111`, behavior-change table from the diff) and Phase 6 (commit the archive dry run as BRANCH_ARCHIVE_PLAN.md under .fable, write FINAL_REPORT.md under .fable, put it in the PR body, mark the PR ready, set status DONE).
