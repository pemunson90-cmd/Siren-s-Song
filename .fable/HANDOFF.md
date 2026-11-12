# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-11 21:17 at commit 50b8c262

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone. Every statement was checked against a file or a read-only command at the commit above. Where the documents disagree with git, see "Discrepancies found" at the end.

## 1. Resume in five steps

1. **Open this folder as the project.** The session's project folder must be this run clone, so that the hooks load. `.claude/settings.json` (tracked) holds the command guard and the post-command check. `.claude/settings.local.json` (on disk only, ignored by git) holds the session-start context hook and the stop gate. A session started in another folder loads none of them (decision D-01).
2. **Run `/siren-s-start-fable`.** The command file is `.claude/commands/siren-s-start-fable.md`. It sets the run parameters and tells a resumed session to continue from `next_action` instead of restarting Phase 0.
3. **Read, in this order and in full:** `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.fable/RUN_STATE.json`, the last 50 lines of `.fable/RUN_LOG.md`, `.fable/DECISIONS.md`, this guide, then `.fable/NOW.md` (the step in progress when the last session ended).
4. **Run the staleness check and reconcile with git.** Run `python scripts/repo/handoff_check.py`, then `git status --short 2>/dev/null` (ignore lines ending in `.uid` and `.import`), `git log --oneline -15` and `git ls-remote origin 'refs/heads/fable/*' 'refs/tags/fable/*'`. Repair any gap between the state file and git from the run log, as charter section 11 "Resume" says.
5. **Recover in-flight work (section 3 below), set status RUNNING and continue** from `next_action` in `.fable/RUN_STATE.json`. Rewrite `.fable/NOW.md` before the first step.

## 2. Where the run stands

The run is in **Phase 1: Survey**, status RUNNING. The run branch `fable/overhaul-20261111` is at 50b8c262 locally and on GitHub, with nothing unpushed. The base is `claude/integration` at cabd5bd5. No pull request exists yet (the charter opens the draft at the Phase 3 exit).

**Phase 0: Preflight is finished.** Its exit gate (all SHAs recorded, guard test, baseline recorded) was met with one exception recorded as D-01.

| Deliverable | Where | Commit |
| --- | --- | --- |
| Charter, target file, guard hooks, agent files, state, log, decisions | `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.claude/hooks/guard.py` and its siblings, `.claude/agents/implementer.md`, `.claude/agents/reviewer.md` | 8091be4b |
| Preflight steps 1 to 4 and the failed guard self-test | `.fable/RUN_LOG.md`, `.fable/RUN_STATE.json` | 4622e790 |
| Decision D-01, base tag, green baseline (Import OK, Core `CHECKS 850 FAILURES 0`, as logged) | `.fable/DECISIONS.md`, `.fable/RUN_LOG.md` | f5bc2774 |
| Tag `fable/pre-overhaul-20261111` at cabd5bd5 | on GitHub (seen with `git ls-remote`) | tag only |

**Phase 1: Survey is in progress.** Its exit gate is: all five survey files committed and every documentation file in the inventory read in full.

| Deliverable | State | Commit |
| --- | --- | --- |
| `.fable/BRANCH_LEDGER.md` and `scripts/repo/branch_ledger.py` | Finished (generated) | aa77916c, refreshed in 3b949a12 and 50b8c262 |
| `.fable/CI_INVENTORY.md` | Finished | aa77916c |
| `.fable/DOC_INVENTORY.md` and decisions D-02 to D-06 | Finished | 874a92c9 |
| `.fable/SURVEY.md` | In progress: sections 1 to 6 complete, section 7 provisional until the critics report | 50b8c262 |
| PROTECTED_CAPABILITIES.md (to live under `.fable/`) | Not written yet. A drafter subagent was running. | none |
| COLD_REVIEW_6.md (to live under `.fable/`, required by TARGET.md section 6) | Not written yet. Three blind critics were playing. | none |
| Critic kit, versioned | `scripts/critic/kit.py` and its siblings. Still needs a reviewer pass. | aa77916c |
| Handoff system | `.fable/NOW.md`, `scripts/repo/handoff_check.py`, `Status:` lines | 3b949a12 |
| This guide | Written by a subagent, to be verified by a second one, then committed by root | uncommitted |

**Not started:** Phase 2 (Plan; OVERHAUL_PLAN.md is not written yet), Phase 3 (Foundation), Phase 4 (Execution), Phase 5 (Integration and verification), Phase 6 (Closeout). `work_packages` in the state file is empty.

## 3. In-flight work and how to recover each piece

Background subagents belong to the session that started them and end with it. `.fable/NOW.md` lists them. The critic kit instance is outside the repository at `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111` (built from cabd5bd5; folders `audit`, `brief`, `control`, `evidence`, `game`, `private`).

| Piece | Writes to | Recovery if the session died |
| --- | --- | --- |
| Code architecture explorer | Finished. Its findings are in `.fable/SURVEY.md`. | Nothing to do. |
| Capabilities ledger drafter | PROTECTED_CAPABILITIES.md under `.fable/` | If the file exists, review it against TARGET.md section 6 (Phase 1 coverage list), finish it and commit it. If it does not, relaunch a drafter with the brief below. |
| Blind critic A: opening campaign, cover view, slot `a`, session `critic-a-opening` | `audit\critic-a-opening\JOURNAL.md` and `evidence\critic-a-opening\` in the kit | Read the journal. Quit a leftover game (commands below). If findings are thin, relaunch a critic with the same slot, view and session name, which resumes the same isolated player profile. |
| Blind critic B: side modes, inner view, slot `b`, session `critic-b-modes` | `audit\critic-b-modes\JOURNAL.md`, `evidence\critic-b-modes\` | Same, slot `b`. |
| Blind critic C: mid campaign from an imported earned profile, cover view, slot `c`, session `critic-c-glass` | `audit\critic-c-glass\JOURNAL.md`, `evidence\critic-c-glass\` | Same, slot `c`. |
| Handoff verifier | Reports to root; writes nothing | Relaunch it against this guide if no verdict was saved. |

Quit a leftover game instance, one command per slot (Bash tool, run from this folder; syntax confirmed from the argument parser in `scripts/critic/kit.py`, not executed by the writer because the critics were live):

```
python scripts/critic/kit.py quit --kit "$USERPROFILE/.cache/sirens-song-toolchain/artifacts/critic6-fable-20261111" --slot a
python scripts/critic/kit.py quit --kit "$USERPROFILE/.cache/sirens-song-toolchain/artifacts/critic6-fable-20261111" --slot b
python scripts/critic/kit.py quit --kit "$USERPROFILE/.cache/sirens-song-toolchain/artifacts/critic6-fable-20261111" --slot c
```

To relaunch a critic, give it only the two files in the kit's `brief` folder (copies of `scripts/critic/CRITIC_BRIEF.md` and `scripts/critic/OPERATE.md`), the kit path, the path to `scripts/critic/kit.py`, its slot, view, session name, assignment and a command budget (the first three had 110 commands each). Give it no source, no watch list and no earlier audit (`scripts/critic/README.md`). The three critics do not cover the endings or END OF LINE (run log, 21:09 entry).

Brief for a relaunched capabilities drafter (reconstructed from the charter and TARGET.md; the original brief text was not saved to disk):

```
Work package: WP-01 Protected capabilities ledger
Goal: a regression ledger of every working capability a player or maintainer can reach.
Base: fable/overhaul-20261111 at the current head
Owned path: .fable/PROTECTED_CAPABILITIES.md (create; add a Status: line near the top)
Do not touch: every other file. No commits, pushes or deletions. Do not run Godot.
Read: .fable/FABLE_RUN.md section 8 (Phase 1, second bullet) and sections 4 and 6;
  .fable/TARGET.md section 4 (protected game rules) and section 6 (Phase 1 coverage list);
  .fable/SURVEY.md; game/tests/suites.txt; docs/USER_DIRECTIVES.md.
Acceptance: every item in the TARGET.md coverage list has at least one row with an ID,
  where it lives, and how to verify it (a test name, a script or a code path that exists).
Report: rows written, items you could not locate, anything unverified.
```

## 4. Document map

| Path | Purpose | Status (the document's own line) | Updated by, and when |
| --- | --- | --- | --- |
| `.fable/FABLE_RUN.md` | Charter: phases, exit gates, safety model, state rules | No status line (protected) | Nobody during the run |
| `.fable/TARGET.md` | Facts about this repository, rulings to apply, gates | No status line (protected) | Nobody during the run |
| `.fable/RUN_STATE.json` | Machine-readable state: status, phase, `next_action`, SHAs | JSON field `status`: RUNNING | Root, after every work-package change and phase boundary |
| `.fable/RUN_LOG.md` | Resume trail, one entry per meaningful event | LIVE LOG (append only) | Root, append only |
| `.fable/NOW.md` | Write-ahead note: the step being done right now | LIVE NOTE (rewritten before every step; if a session died, this is the step it died in) | Root, before every step |
| `.fable/HANDOFF.md` | This guide | LIVE GUIDE | Root, at every phase boundary and when in-flight work changes |
| `.fable/DECISIONS.md` | Numbered questions for Pat, each with a recommendation | No document status line; each entry has `Status: OPEN` | Root, when a decision arises or Pat answers |
| `.fable/SURVEY.md` | Architecture map, defects S-01 to S-13, ranked weaknesses | IN PROGRESS (2026-11-11, Phase 1) | Root, until the critics are merged in |
| `.fable/SURVEY_NOTES.md` | Root's working notes, session facts, hazards, plan sketch | LIVE NOTES (superseded by SURVEY.md and HANDOFF.md where they overlap) | Root, as facts are learned |
| `.fable/DOC_INVENTORY.md` | Every documentation file with its class, and 13 contradictions | COMPLETE (2026-11-11, Phase 1). Phase 3 executes it; rows are not edited afterwards. | Finished |
| `.fable/CI_INVENTORY.md` | Workflows, suite registry, redundancy and gaps | COMPLETE (2026-11-11, Phase 1). Recheck at Phase 3 when workflows change. | Root, at Phase 3 |
| `.fable/BRANCH_LEDGER.md` | Every remote branch with its class (374 branches) | GENERATED (rerun the script to refresh; do not edit by hand) | `scripts/repo/branch_ledger.py` |
| `scripts/repo/branch_ledger.py` | Read-only generator of the branch ledger | tool | Root |
| `scripts/repo/handoff_check.py` | Read-only staleness check for these documents | tool | Root; run after every task |
| `scripts/critic/kit.py`, `scripts/critic/driver.gd` | Build a kit from a ref, launch one game per slot, send touch commands | tool | Root |
| `scripts/critic/README.md`, `scripts/critic/OPERATE.md`, `scripts/critic/CRITIC_BRIEF.md` | How to run a critic, the command reference, the critic's brief | reference | Root |

Not written yet, all to live under `.fable/`: PROTECTED_CAPABILITIES.md and COLD_REVIEW_6.md (Phase 1), OVERHAUL_PLAN.md (Phase 2), BRANCH_ARCHIVE_PLAN.md and FINAL_REPORT.md (Phase 6).

## 5. Working rules a new session must know

- **Local checks run natively on Windows, without the Linux subsystem.** Set `$env:ARTIFACT_DIR` to a fresh folder under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`, then run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate` and the same with `-Action Core`. The baseline took 22.4 seconds for import and 178.2 seconds for core. Rendered suites cannot run locally and run only on GitHub. See `scripts/toolchain/win/README.md`.
- **A Godot import dirties the tree.** It leaves tracked `.import` files changed by line endings and many untracked `.gd.uid` files. Ignore them in `git status` and do not commit them before the hygiene package. Redirect git's error output when listing status, because line-ending warnings flood it.
- **Commits must carry the noreply email.** GitHub refused the first push for exposing a private address. The repository-local `user.email` is now a GitHub noreply address; leave it. Three commits were re-authored then; the old ones are held by the local tag `fable/local-pre-reauthor-20261111`.
- **Two local tags are never pushed and cannot be removed:** `fable/local-pre-reauthor-20261111` and `fable/guard-selftest-tmp`. Only `fable/pre-overhaul-20261111` is on GitHub.
- **Never `cd` outside this clone in the Bash tool.** The shell then resets to Pat's other clone, which the run must never touch. Use absolute paths or `git -C`.
- **The tool cache is shared and read-only for this run**, except folders named `fable-*` or `critic6-fable-*`. `%USERPROFILE%\.cache\sirens-song-toolchain` holds earlier agents' evidence. Copies of the handoffs branch files are in its `fable-notes` folder.
- **The guard and decision D-01.** The first session was started in Pat's other clone, so the command guard, the post-command check and the stop gate never loaded, and the Phase 0 guard self-test failed. Pat answered "Just fix it snd go". The run continued with those rules applied by hand; the git-level hooks (pre-commit, pre-push, reference-transaction in `.git/hooks`) were tested and work. A session opened in this folder is option B of D-01: rerun the four self-test commands of charter Phase 0 step 5, log the result, and tell Pat that D-01 can close.
- **Custom agent types may or may not be registered.** They were not in the first session. If `implementer` and `reviewer` are missing, start a general-purpose subagent and paste the text of `.claude/agents/implementer.md` or `.claude/agents/reviewer.md` into its brief.
- **Save every subagent report to disk when it arrives**, under `%USERPROFILE%\.cache\sirens-song-toolchain\fable-notes\`, before using it. A report that exists only in the conversation is lost at a context clear.
- **Write Windows paths in the log with care.** Two paths in the run log lost characters because `\f` and `\a` were read as escapes (see Discrepancies).

## 6. Closeout routine after every task

Pat's instruction of 2026-11-11 (recorded in the run log, 21:09 entry, and in `.fable/NOW.md`):

1. Before starting a step, rewrite `.fable/NOW.md` with what is about to be done and set its `Updated:` line.
2. After finishing, mark the document or work package finished in its `Status:` line and in `.fable/RUN_STATE.json` (also update `run_head`, `next_action`, `last_checkpoint`, `updated`).
3. Append an entry to `.fable/RUN_LOG.md`.
4. Run `python scripts/repo/handoff_check.py` and fix everything it reports.
5. Commit and push the run branch.

## 7. Open decisions for Pat

Full text is in `.fable/DECISIONS.md`. None of them blocks the run.

- D-01 Run continues without the command-text guard: recommendation B (A until Pat is at the desktop).
- D-02 Documents whose staleness is uncertain: recommendation A.
- D-03 Contradictions in the story draft and the sweeper patrol note: recommendation B.
- D-04 Retire the `codex/handoffs` coordination branch: recommendation A.
- D-05 Perpetual Gauntlet or bounded runs: recommendation C.
- D-06 Open workflow questions this run does not answer: recommendation A.

## 8. What comes next

**Remaining Phase 1 steps:** collect and save the critic and drafter reports; merge the critic findings into COLD_REVIEW_6.md; finish section 7 of `.fable/SURVEY.md` and set its status to complete; review and commit PROTECTED_CAPABILITIES.md; update the state file and the log; push; give the phase report.

**Then Phase 2:** write OVERHAUL_PLAN.md. `PLAN_GATE` is off, so the run commits the plan and continues into Phase 3 (governance consolidation first; the design notes are in `.fable/SURVEY_NOTES.md`, section "Documentation inventory done").

**Plan sketch, not binding until OVERHAUL_PLAN.md exists** (from `.fable/SURVEY_NOTES.md`, "Root's intended plan"):

- P0: WP-00 critic kit (built, needs review); WP-01 capabilities ledger; WP-02 governance consolidation (root does it itself); WP-03 repository hygiene; WP-04 CI necessity; WP-05 progress-loss defect S-01 (test first, second reviewer).
- P1 candidates, to be ranked after the critics: release hygiene S-02 to S-04; data-driven operation tables and guides for adding content; photo payoff; ARRIVALS shows received content; duplicated constants and dead guards; critic findings.
- P2 backlog: look and sound comparison, shared test assertion helper, decomposition of the two largest scripts, settings stored twice, narrower suite selection, nightly on `main`.

## Discrepancies found

1. `run_head` in the state file is 874a92c9; HEAD is 50b8c262 (two commits later).
2. `decisions_open` is 7; DECISIONS.md has six entries (D-01 to D-06). The staleness check also counts the `Status: OPEN` line in that file's format comment, so 7 passes and 6 would fail.
3. `next_action`, `last_checkpoint` and NOW.md step 2 say SURVEY.md is still to be written; it was committed in 50b8c262 as IN PROGRESS.
4. The run log's 21:09 entry has two damaged paths. The real ones are `%USERPROFILE%\.cache\sirens-song-toolchain\fable-notes\explorer-doc-inventory.md` and `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111`; both exist.
5. Timestamps run ahead of the machine clock. NOW.md says `Updated: 2026-11-11 21:22` and "finished 21:15", and the plan sketch is stamped 21:20, while the clock read 21:13 when those files were already committed (HEAD is stamped 21:12).
6. NOW.md says the start command reads this guide and NOW.md. The command text names only the charter, the target file, the state, the log and the decisions; the pointer to this guide is in `next_action`.
7. The stop gate and the session-start hook are configured in `.claude/settings.local.json`, not in `.claude/settings.json`.
8. No code-architecture explorer report file is in the `fable-notes` folder; only the documentation inventory report is. Its content survives only as written up in SURVEY.md.
9. SURVEY_NOTES.md marks WP-00 done while `work_packages` in the state file is empty (work-package IDs are a sketch until the plan exists). Its section "Critic kit (external, not in the repository)" describes the older kit; the current kit is in `scripts/critic/`.
10. TARGET.md records `main` at a2300840 and 373 remote branches; the live values are f5b66a19 and 374 (already noted in the run log).
11. At 21:16 the staleness check failed on NOW.md only: it names three files in backticks that are not written yet (the capabilities ledger, the cold review and the plan). Root fixes this by writing those names without backticks until the files exist.
