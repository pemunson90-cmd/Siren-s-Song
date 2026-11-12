# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-11 21:25 at commit 7084d3fe
Checked by a second agent: 2026-11-11 21:25

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone. A first subagent wrote it at 50b8c262. A second subagent then did a cold start from the documents, checked every statement against a file or a read-only command at the commit above, and corrected it. Points where the documents still disagree with each other or with git are under "Discrepancies found" at the end.

## 1. Resume in five steps

1. **Open this folder as the project.** The session's project folder must be this run clone, so that the hooks load. All four hooks are in the tracked `.claude/settings.json`: the command guard (before each command or edit), the post-command restore check, the session-start context hook and the stop gate. The last two moved there from `.claude/settings.local.json` in commit 7084d3fe on Pat's instruction; that local file is ignored by git and now holds only permissions and session preferences. A session started in another folder loads none of the hooks (decision D-01).
2. **Run `/siren-s-start-fable`.** The command file `.claude/commands/siren-s-start-fable.md` is tracked since 7084d3fe. It sets the run parameters (`PLAN_GATE=off`, `APK_AT_END=yes`, `SUBAGENT_LIMIT=3`) and tells a resumed session to continue from `next_action` instead of restarting Phase 0.
3. **Read, in this order and in full:** `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.fable/RUN_STATE.json`, the last 50 lines of `.fable/RUN_LOG.md` (the whole log while it is shorter than that), `.fable/DECISIONS.md`, this guide, then `.fable/NOW.md` (the step in progress when the last session ended). Charter section 0 step 5 adds "the documents TARGET.md names for the current phase". For Phase 1 that is the full reading list in TARGET.md section 6. The earlier session recorded that reading in `.fable/DOC_INVENTORY.md` (status COMPLETE), `.fable/SURVEY.md` sections 1 to 6 and `.fable/SURVEY_NOTES.md` ("Governing documents read in full by root"). No document says whether a resumed session must repeat it; read those three files in full at least.
4. **Run the staleness check and reconcile with git.** Run `python scripts/repo/handoff_check.py`, then `git status --short 2>/dev/null` (ignore lines ending in `.uid` and `.import`), `git log --oneline -15` and `git ls-remote origin 'refs/heads/fable/*' 'refs/tags/fable/*'`. Expected at verification time: the check prints `HANDOFF CHECK PASS`, the status lists only 444 untracked generated files (441 ending `.uid`, 3 ending `.import`), and GitHub has the run branch at the local HEAD plus the tag `fable/pre-overhaul-20261111`. `run_head` in the state file is normally one commit behind HEAD, because the tool records HEAD before the commit that carries the state file; the check accepts any ancestor of HEAD and warns only above three commits. Repair any real gap from the run log, as charter section 11 "Resume" says.
5. **Recover in-flight work (section 3 below), set status RUNNING and continue** from `next_action` in `.fable/RUN_STATE.json`. Before the first step, record it with `python scripts/repo/run_state.py --now "..."` (section 6).

## 2. Where the run stands

The run is in **Phase 1: Survey**, status RUNNING, phase value `1-survey`. The run branch `fable/overhaul-20261111` was at 7084d3fe locally and on GitHub when verified, with nothing unpushed and no uncommitted change apart from the generated files and this guide's corrections. List later commits with `git log --oneline 7084d3fe..HEAD`. The base is `claude/integration` at cabd5bd5. No pull request exists yet (`gh pr list --head fable/overhaul-20261111 --state all` returned an empty list; the charter opens the draft at the Phase 3 exit).

**Phase 0: Preflight is finished.** Its exit gate (all SHAs recorded, guard test, baseline recorded) was met with one exception recorded as D-01.

| Deliverable | Where | Commit |
| --- | --- | --- |
| Charter, target file, guard hooks, agent files, first state, log and decisions files | `.fable/FABLE_RUN.md`, `.fable/TARGET.md`, `.claude/hooks/guard.py` and its four siblings, `.claude/agents/implementer.md`, `.claude/agents/reviewer.md` | 8091be4b |
| Preflight steps 1 to 4 and the failed guard self-test | `.fable/RUN_LOG.md`, `.fable/RUN_STATE.json` | 4622e790 |
| Decision D-01, base tag, green baseline (Import OK, Core `CHECKS 850 FAILURES 0`, as logged) | `.fable/DECISIONS.md`, `.fable/RUN_LOG.md` | f5bc2774 |
| Tag `fable/pre-overhaul-20261111` at cabd5bd5 | on GitHub (seen with `git ls-remote`) | tag only |

**Phase 1: Survey is in progress.** Its exit gate is: all five survey files committed and every documentation file in the inventory read in full. TARGET.md section 6 adds the merged critic findings as COLD_REVIEW_6.md.

| Deliverable | State | Commit |
| --- | --- | --- |
| `.fable/BRANCH_LEDGER.md` and `scripts/repo/branch_ledger.py` | Finished (generated) | aa77916c, touched again in 3b949a12 and 50b8c262 |
| `.fable/CI_INVENTORY.md` | Finished | aa77916c |
| `.fable/DOC_INVENTORY.md` and decisions D-02 to D-06 | Finished | 874a92c9 |
| `.fable/SURVEY.md` | In progress: sections 1 to 6 complete, section 7 provisional until the critics report | 50b8c262, rank 1 of section 7 changed in 9e941f9b |
| PROTECTED_CAPABILITIES.md (to live under `.fable/`) | Not on disk at 21:25. A drafter subagent was running. | none |
| COLD_REVIEW_6.md (to live under `.fable/`) | Not written yet. Three blind critics were playing. | none |
| Critic kit, versioned (work package WP-00, state `review`) | `scripts/critic/kit.py` and its siblings. Still needs a reviewer pass. | aa77916c |
| Handoff system | `.fable/NOW.md`, `scripts/repo/handoff_check.py`, `Status:` lines | 3b949a12 |
| This guide | First version committed in 9e941f9b. Root commits the second agent's corrections; `git log --oneline -3 -- .fable/HANDOFF.md` shows whether that happened. | 9e941f9b |

Commits after 50b8c262, oldest first:

| Commit | What it added |
| --- | --- |
| 9e941f9b | Pat's ruling on save files in the run log and the notes, S-01 moved to P2 in the survey, first version of this guide |
| 51fdad42 | `scripts/repo/run_state.py`; the checker ignores the commented template and requires the pointer in `next_action`; document `Status:` line in DECISIONS.md; correction entry in the run log; state file repaired (`decisions_open` 6, `work_packages` WP-00) |
| f5b95020 | `run_head` in the state file synced |
| 7084d3fe | Stop gate and session-start hook moved into `.claude/settings.json`, start command tracked, decision D-07, run log entry with Pat's instruction |

**Not started:** Phase 2 (Plan; OVERHAUL_PLAN.md is not written yet), Phase 3 (Foundation), Phase 4 (Execution), Phase 5 (Integration and verification), Phase 6 (Closeout).

## 3. In-flight work and how to recover each piece

Background subagents belong to the session that started them and end with it. `.fable/NOW.md` lists them. The critic kit instance is outside the repository at `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111` (built from cabd5bd5 according to its `kit.json`; folders `audit`, `brief`, `control`, `evidence`, `game`, `private`; files `driver.gd`, `import.log`, `kit.json`).

| Piece | Writes to | Recovery if the session died |
| --- | --- | --- |
| Code architecture explorer | Finished. Its findings are in `.fable/SURVEY.md`; no separate report file was saved. | Nothing to do. |
| Capabilities ledger drafter | PROTECTED_CAPABILITIES.md under `.fable/` | If the file exists, review it against TARGET.md section 6 (Phase 1 coverage list), finish it and commit it. If it does not, relaunch a drafter with the brief below. |
| Blind critic A: opening campaign, cover view, slot `a`, session `critic-a-opening` | `audit\critic-a-opening\JOURNAL.md` and `evidence\critic-a-opening\` in the kit | Read the journal. Quit a leftover game (below). If findings are thin, relaunch a critic with the same view and session name, which resumes the same isolated player profile. |
| Blind critic B: side modes, inner view, slot `b`, session `critic-b-modes` | `audit\critic-b-modes\JOURNAL.md`, `evidence\critic-b-modes\` | Same, slot `b`, view `inner`. |
| Blind critic C: mid campaign from an imported earned profile, cover view, slot `c`, session `critic-c-glass` | `audit\critic-c-glass\JOURNAL.md`, `evidence\critic-c-glass\` | Same, slot `c`. |
| Handoff verifier (second agent) | This guide | Finished at 21:25. Root reads its report and commits the guide. |

Critic progress at 2026-11-11 21:20, read from the three journals: A had finished the first operation (Shelf Signal) and counted 36 commands; B had covered title, profiles, settings, credits and the mode list in 25 commands; C had imported the earned profile and covered the dock, route map, fittings and supplies (its journal gives no total; its notes are numbered up to 042). All three game processes were alive. Each critic has a budget of 110 commands (run log, 21:09 entry). The number of `result-` files in a slot's control folder is an upper bound on the commands used: 69, 59 and 75 for slots a, b and c at 21:20, where slot a also holds requests from two launches made before its critic started.

Before sending anything to a slot, find out whether its game is alive: read `control\<slot>\runtime.pid` in the kit and look for that process with `tasklist`. Quit only a live game. A quit sent to a dead slot waits 30 seconds, exits with an error and leaves a request file behind, which the next launch renames with a `stale-` prefix. Commands for the Bash tool, run from this folder (syntax confirmed from the argument parser in `scripts/critic/kit.py`; not executed during verification because the critics were live):

```
python scripts/critic/kit.py quit --kit "$USERPROFILE/.cache/sirens-song-toolchain/artifacts/critic6-fable-20261111" --slot a
python scripts/critic/kit.py launch --kit "$USERPROFILE/.cache/sirens-song-toolchain/artifacts/critic6-fable-20261111" --slot a --view cover --session critic-a-opening
```

Use `--slot b --view inner --session critic-b-modes` and `--slot c --view cover --session critic-c-glass` for the other two. `launch` refuses a slot whose game is still alive.

To relaunch a critic, give it only the two files in the kit's `brief` folder (byte-identical copies of `scripts/critic/CRITIC_BRIEF.md` and `scripts/critic/OPERATE.md`), the kit path, the path to `scripts/critic/kit.py`, its slot, view, session name, assignment and a command budget. Give it no source, no watch list and no earlier audit (`scripts/critic/README.md`). The three critics do not cover the endings or END OF LINE (run log, 21:09 entry).

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
| `.fable/RUN_STATE.json` | Machine-readable state: status, phase, `next_action`, SHAs, work packages | JSON field `status`: RUNNING | `scripts/repo/run_state.py`, after every task |
| `.fable/RUN_LOG.md` | Resume trail, one entry per meaningful event | LIVE LOG (append only) | Root, append only (the `--log` option of the state tool appends an entry) |
| `.fable/NOW.md` | Write-ahead note: the step being done right now | LIVE NOTE (rewritten before every step; if a session died, this is the step it died in) | The `--now` option of the state tool before every step; root edits the "In flight" table and the "Next, in order" list by hand |
| `.fable/HANDOFF.md` | This guide | LIVE GUIDE | Root, at every phase boundary and when in-flight work changes |
| `.fable/DECISIONS.md` | Numbered questions for Pat, each with a recommendation | LIVE LOG (entries are appended; Pat answers by number and letter); each entry also has its own `Status: OPEN` line | Root, when a decision arises or Pat answers |
| `.fable/SURVEY.md` | Architecture map, defects S-01 to S-13, ranked weaknesses | IN PROGRESS (2026-11-11, Phase 1) | Root, until the critics are merged in |
| `.fable/SURVEY_NOTES.md` | Root's working notes: session facts, hazards, plan sketch, Pat's save ruling, line endings | LIVE NOTES (superseded by SURVEY.md and HANDOFF.md where they overlap) | Root, as facts are learned |
| `.fable/DOC_INVENTORY.md` | Every documentation file with its class, and 13 contradictions | COMPLETE (2026-11-11, Phase 1). Phase 3 executes it; rows are not edited afterwards. | Finished |
| `.fable/CI_INVENTORY.md` | Workflows, suite registry, redundancy and gaps | COMPLETE (2026-11-11, Phase 1). Recheck at Phase 3 when workflows change. | Root, at Phase 3 |
| `.fable/BRANCH_LEDGER.md` | Every remote branch with its class (374 branches) | GENERATED (rerun the script to refresh; do not edit by hand) | `scripts/repo/branch_ledger.py` |
| `scripts/repo/run_state.py` | Updates the state file, appends to the run log, rewrites "Doing right now" in NOW.md. Never commits or pushes. | tool | Root; usage in section 6 |
| `scripts/repo/handoff_check.py` | Read-only staleness check for these documents | tool | Root; run after every task |
| `scripts/repo/branch_ledger.py` | Read-only generator of the branch ledger (`--help` lists its options) | tool | Root |
| `scripts/critic/kit.py`, `scripts/critic/driver.gd` | Build a kit from a ref, launch one game per slot, send touch commands | tool | Root |
| `scripts/critic/README.md`, `scripts/critic/OPERATE.md`, `scripts/critic/CRITIC_BRIEF.md` | How to run a critic, the command reference, the critic's brief | reference | Root |

Not written yet, all to live under `.fable/`: PROTECTED_CAPABILITIES.md and COLD_REVIEW_6.md (Phase 1), OVERHAUL_PLAN.md (Phase 2), BRANCH_ARCHIVE_PLAN.md and FINAL_REPORT.md (Phase 6).

## 5. Working rules a new session must know

- **Pat's ruling on save files, 2026-11-11 (run log, 21:16:48 entry), verbatim:** "Save files are minor priority because the game isnt even finished yet so saves absolutely will not be able to be carried forward if there is a major refactor or a change in the flow of the game." Effect, as root recorded it in the run log and in `.fable/SURVEY_NOTES.md`: save, restore, profiles, export and import stay working on new saves (feature continuity); carrying existing saves across a refactor is not required, as long as incompatible saves are rejected cleanly; save-file defects rank low; survey finding S-01 (an unreadable save could be overwritten on focus-out) moved from P0 to the P2 backlog (`.fable/SURVEY.md` section 7, rank 1); no second reviewer is spent on save compatibility. The ruling is still to be appended verbatim to `docs/USER_DIRECTIVES.md` in Phase 3; at verification time that file did not contain it.
- **Local checks run natively on Windows, without the Linux subsystem.** Set `$env:ARTIFACT_DIR` to a fresh folder under `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\`, then run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate` and the same with `-Action Core`. The baseline took 22.4 seconds for import and 178.2 seconds for core (run log). Rendered suites cannot run locally and run only on GitHub. See `scripts/toolchain/win/README.md`.
- **A Godot import leaves generated files in the tree.** At verification time `git status` showed 441 untracked `.gd.uid` files and 3 untracked `.import` files, and no modified tracked file. The run log recorded 43 tracked `.import` files modified by line endings straight after the Phase 0 import. Ignore these files in `git status` and do not commit them before the hygiene package (the plan is in `.fable/SURVEY_NOTES.md`, "Line endings"). Redirect git's error output when listing status, because line-ending warnings flood it (`core.autocrlf` is true in this clone and there is no `.gitattributes`).
- **Commits must carry the noreply email.** GitHub refused the first push for exposing a private address. The repository-local `user.email` is a GitHub noreply address; leave it. Three commits were re-authored then; the old ones are held by the local tag `fable/local-pre-reauthor-20261111`.
- **Two local tags are never pushed and cannot be removed:** `fable/local-pre-reauthor-20261111` and `fable/guard-selftest-tmp`. Only `fable/pre-overhaul-20261111` is on GitHub.
- **Never `cd` outside this clone in the Bash tool.** The notes record that the shell then resets to Pat's other clone, which the run must never touch. Use absolute paths or `git -C`.
- **The tool cache is shared and read-only for this run**, except folders named `fable-*` or `critic6-fable-*`. `%USERPROFILE%\.cache\sirens-song-toolchain` holds earlier agents' evidence. Its `fable-notes` folder holds copies of four handoffs branch files (`handoffs-STATE.md`, `handoffs-RULINGS.md`, `handoffs-DECISIONS.md`, `handoffs-queue.json`), the documentation explorer's report (`explorer-doc-inventory.md`) and `prs.json`.
- **The guard and decision D-01.** The first session was started in Pat's other clone, so the command guard, the post-command check and the stop gate never loaded, and the Phase 0 guard self-test failed. Pat answered "Just fix it snd go". The run continued with those rules applied by hand; the git-level hooks (pre-commit, pre-push, reference-transaction in `.git/hooks`, each calling `.claude/hooks/git_guard.py`) were tested and work. A session opened in this folder is option B of D-01: rerun the four self-test commands of charter Phase 0 step 5, log the result, and tell Pat that D-01 can close.
- **Edits under `.claude/` are off limits to the run.** The one exception so far was made on Pat's direct instruction (run log, 21:22:49 entry) and is recorded as D-07.
- **Custom agent types may or may not be registered.** They were not in the first session. If `implementer` and `reviewer` are missing, start a general-purpose subagent and paste the text of `.claude/agents/implementer.md` or `.claude/agents/reviewer.md` into its brief.
- **Save every subagent report to disk when it arrives**, under `%USERPROFILE%\.cache\sirens-song-toolchain\fable-notes\`, before using it. A report that exists only in the conversation is lost at a context clear.
- **Write Windows paths with care.** Two paths in the run log lost characters because `\f` and `\a` were read as escapes. In the Bash tool, put text that contains backslashes or backticks in single quotes.

## 6. Closeout routine after every task

Pat's instruction of 2026-11-11 (run log, 21:09 "HANDOFF SYSTEM" entry). The state tool does steps 1, 3 and 4; do not edit the state file by hand.

1. Before starting a step: `python scripts/repo/run_state.py --now "what is about to be done"`. This rewrites the "Doing right now" section of `.fable/NOW.md` and its `Updated:` line. Edit the "In flight" table and the "Next, in order" list of that file by hand when they change.
2. After finishing: set the `Status:` line of each finished document (for example COMPLETE with the date and phase).
3. Record the result in the state file and the log in one call:
   `python scripts/repo/run_state.py --next "one concrete next action" --checkpoint "what is finished and what is pending" --wp WP-03=merged --log "PHASE 1, what happened, evidence, next action"`
4. Every call sets `run_head` to the current HEAD, recounts the open decisions in `.fable/DECISIONS.md` and stamps `updated` from the clock. `--next` adds the pointer to this guide and to NOW.md in front of the text by itself. `--log` adds the date and time by itself. `--wp` can be repeated; its states are planned, building, review, revise, merged, deferred. `--status` (NOT_STARTED, RUNNING, PAUSED, STUCK, DONE) and `--phase` (for example `2-plan`) are written as given, without validation by the tool. All options are optional.
5. Run `python scripts/repo/handoff_check.py` and fix everything it reports. It fails when the state file is invalid or lacks a field, when the run branch is not checked out, when `run_head` is not an ancestor of HEAD, when a run document lacks a `Status:` line in its first 8 lines, when `decisions_open` differs from the `Status: OPEN` entries in DECISIONS.md (the template inside the HTML comment is not counted), when `next_action` does not mention HANDOFF.md, when this guide or NOW.md names a repository path in backticks that does not exist, or when NOW.md is more than 90 minutes older than the newest commit. It only warns about uncommitted paths, unpushed commits and a `run_head` more than three commits behind.
6. Commit the state, log and note with the change they describe, and push the run branch.

## 7. Open decisions for Pat

Full text is in `.fable/DECISIONS.md`. Seven are open (`decisions_open` is 7). None of them blocks the run.

- D-01 Run continues without the command-text guard: recommendation B (A until Pat is at the desktop).
- D-02 Documents whose staleness is uncertain: recommendation A.
- D-03 Contradictions in the story draft and the sweeper patrol note: recommendation B.
- D-04 Retire the `codex/handoffs` coordination branch: recommendation A.
- D-05 Perpetual Gauntlet or bounded runs: recommendation C.
- D-06 Open workflow questions this run does not answer: recommendation A.
- D-07 The run's guard files travel with the pull request: recommendation A.

## 8. What comes next

**Remaining Phase 1 steps, in order:** (1) collect the critic and drafter reports and save each to disk; (2) merge the critic findings into COLD_REVIEW_6.md under `.fable/`; (3) finish section 7 of `.fable/SURVEY.md` and set its status to complete, review and commit PROTECTED_CAPABILITIES.md. Then run the closeout routine, push and give the phase report.

**Then Phase 2:** write OVERHAUL_PLAN.md. `PLAN_GATE` is off, so the run commits the plan and continues into Phase 3 (governance consolidation first; the design notes are in `.fable/SURVEY_NOTES.md`, section "Documentation inventory done").

**Plan sketch, not binding until OVERHAUL_PLAN.md exists** (from `.fable/SURVEY_NOTES.md`, "Root's intended plan", as changed by Pat's save ruling):

- P0: WP-00 critic kit (built, needs review); WP-01 capabilities ledger; WP-02 governance consolidation (root does it itself); WP-03 repository hygiene; WP-04 CI necessity.
- P1 candidates, to be ranked after the critics: release hygiene S-02 to S-04; data-driven operation tables and guides for adding content; photo payoff; ARRIVALS shows received content; duplicated constants and dead guards; critic findings.
- P2 backlog: progress-loss defect S-01 (formerly WP-05 in P0), look and sound comparison, shared test assertion helper, decomposition of the two largest scripts, settings stored twice, narrower suite selection, nightly on `main`.

## Discrepancies found

Still true at the verified commit. Items the first version listed that root has since fixed (state file fields, decision count, checker, notes heading, NOW.md wording) are removed.

1. TARGET.md records `main` at a2300840 and 373 remote branches; the live values are f5b66a19 and 374 (noted in the run log, 20:42 entry). TARGET.md is protected, so it stays as written.
2. The run log's 21:09 "explorers and critic" entry has two damaged paths. The log is append only, so the entry stays; the correction entry of 21:17:36 gives the right paths, and both exist on disk.
3. The run log's 21:09 "HANDOFF SYSTEM" entry says the start command is excluded from git. The 21:22:49 entry supersedes it: the file is tracked, although its line is still in `.git/info/exclude`.
4. Time stamps written before the 21:17:36 log entry ran up to ten minutes ahead of the machine clock (for example the plan sketch in the notes is stamped 21:20 and was committed at 21:12:29). Use commit times to order events before that entry.
5. The plan sketch in `.fable/SURVEY_NOTES.md` still lists WP-05 (defect S-01) under P0. The later section of the same file ("Pat ruling") and `.fable/SURVEY.md` section 7 place it in the P2 backlog. The ruling wins.
6. `work_packages` in the state file lists only WP-00. The capabilities ledger (WP-01 in the sketch) is being drafted and has no entry. Work-package numbers stay a sketch until OVERHAUL_PLAN.md exists.
7. TARGET.md section 3 defines Critic 6 as reaching END OF LINE and each ending family, among other things. The three bounded critics do not cover endings. No document records whether further critics will run before the Phase 1 exit or whether the gap is carried into the plan. A run log entry or a plan row would settle it.
