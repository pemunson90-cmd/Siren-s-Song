# Handoff guide: resume the overhaul run from a cold start

Status: LIVE GUIDE (root updates it at every phase boundary and whenever in-flight work changes)
Verified: 2026-11-13 16:40 at the second pause in phase 9 (sections 2, 3 and 7 rewritten by root)

This guide lets a session with an empty context resume run `overhaul-20261111` from the documents alone.

## 1. Resume in three reads

1. **Run `/siren-s-start-fable`** (best with this folder, `repos\_fable\Siren-s-Song`, open as the project so the hooks load; in a session started in Pat's other clone the command guard is not loaded: apply charter section 4.3 by hand, decision D-01).
2. **Read** `.fable/RUN_STATE.json`, `.fable/NOW.md`, `.fable/PHASE9.md` and the last 25 lines of `.fable/RUN_LOG.md`. `PHASE9.md` holds what Pat asked for, the working loop with its commands, what is merged, what was in flight, the queue and what is open for Pat.
3. **Check and go:** `python scripts/repo/handoff_check.py`, `git status --short`, then `next_action`. Do not start any GitHub run to check anything. Record each step with `python scripts/repo/run_state.py --now "..."`.

## 2. Where the run stands (14 November, early morning, in phase 9, resumed on Opus)

Branch `fable/overhaul-20261111`, pushed; pull request 262 is a draft. Pat approved every item of `.fable/UX_AUDIT.md` by Claude's judgement, and on 13 November six trial rules with the words "Yes for testing". Merged: work packages WP-31 to WP-97, behavior rows 57 to 128 of `.fable/FINAL_REPORT.md`. Six blind critic rounds; the sixth (kits 51 to 53) found a briefing running off the inner screen, words broken inside buttons, a pause control read as a label, stacked pauses, camera jargon, a useless DECOY on the lock card, oxygen shown three ways and results without the photograph; all fixed (rows 123 to 128). Before that, the fifth (14 Nov, kits 48 to 50) found a stale strip that made a craft look stuck, a decoy offered against a lock it cannot break, result screens that misreported (start hull, an unnamed Sweeper kill, Expedition Hunt numbers, vanishing tools), large text collapsing the inner screen to one column, blocky fog, a Route Map without regions or overview, and three taps per route leg; all fixed (rows 112 to 122). `.fable/PHASE9.md` lists every package, the rankings, what root has not seen in a capture, and the queue.

Sweeps 6, 7 and 8 (74337ca1) were green on every registered suite this PC can run (sweep 8's only miss, `ops_home_ui_tests`, was the sweep's time limit; fixed in `full-sweep.ps1`). WP-93 to WP-97 were merged after the eighth sweep with Core 856/0 and their touched suites; the ninth sweep is the proof for the current head (section 3).

## 3. In-flight work and how to recover it

No helper is running. The next job is the ninth full sweep on the merged head (every registered suite, about 95 minutes): `scripts\toolchain\win\full-sweep.ps1 -Repo <run clone> -Out <scratch file>` in the background. Its record is the per-suite logs in `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-root\`: read each `*.log` newer than the sweep's start for its last "CHECKS n FAILURES m" line. Check first that no other sweep runs (two once ran at once). `cold_review_archive_tests` and `art_render_measurements` do not run on this PC; `opening_depth_policy_ui_tests` leaves no log inside the sweep (time limit): run it alone with `-TimeoutSec 1500` and prefix "OPENING POLICY UI" (571 checks). `ops_home_ui_tests` needs `-TimeoutSec 1700` when run alone.

Blind critics: one kit per critic, each critic's command file inside its own `KIT/audit/<session>/` folder (parallel critics shared a working folder and one command file and drove each other's games on 13 November).

Incident of 13 November: one helper (WP-55) was created in the other clone, `repos\Siren-s-Song`, because the session's working directory had fallen back to it. That clone gained a worktree folder under `.claude\worktrees\` and a local branch `wp-55`; nothing else changed there and nothing was removed. Before every Agent dispatch, run a shell command that starts with `cd` into the run clone.

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

The queue in `.fable/PHASE9.md` (read its "Sixth critic round" paragraph first): run the ninth full sweep and fix what it finds; the rest of the sixth round's list; a seventh blind critic round on the merged head (one kit per critic), then rank again; Pat's open question (a 2x speed button while no Siren hunts; recommended yes); look at the lock card's buttons, a Career result and the new screens on the inner screen and at 150% text (root has not seen them); then refresh the pull request body from `.fable/FINAL_REPORT.md` (`gh pr edit 262 --body-file .fable/FINAL_REPORT.md`) and `docs/STATUS.md`. Ask Pat about the six trial rules again after he has played (evidence from the critics in `.fable/PHASE9.md`).
