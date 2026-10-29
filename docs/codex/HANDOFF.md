# HANDOFF: Siren's Song, Claude orchestrator + two Codex lanes (updated 29 Oct 2026 11:32 ET, end of Claude session S6)

Read this first after any context clear or restart, then the top of BOARD.md and the tail of LEDGER.md. Live refs, PRs and BOARD rows are newer than this file when they disagree. Pat's dated words in `docs/USER_DIRECTIVES.md` on `claude/integration` outrank everything here.

## 1. Roles

- **Pat** rules and approves in chat only. Never ask him to operate anything. One plain question at a time, only when it is genuinely his call. He is not a GitHub expert: explain plainly.
- **Claude** (sole Claude orchestrator, Opus 5.5 medium):
  - plans, writes handoffs and queue order
  - intent-checks every PR against Pat's rulings before it merges (read the PR's before/after table; do not trust the summary)
  - keeps BOARD/HANDOFF/LEDGER and Pat's tracker current, and talks to Pat
  - **launches no Claude subagents, agent teams, forks or workflows**
  - delegates implementation, tests and reviews to Codex
- **Two Codex lanes (Pat, 28 Oct ~20:00 ET, "Op 2"):**
  - **Claude lane:** BOARD rows marked `CLAIMED (claude-lane ...)` or `CLAIMED (codex-fresh-NNN ...)`. Claude launches a fresh headless Codex session per handoff (section 7). The session implements, gets an independent Sol6.1-high review, reconciles integration and **merges** on green exact-head checks.
  - **Root lane:** rows marked `CLAIMED (codex-root ...)`. That is the long-running Codex desktop session ("root", Sol6.1 medium). It dispatches its own workers and merges its own work.
  - **Neither lane stops, collects, reconciles or merges the other's work.** Claim the row on BOARD *before* creating a worktree. Before launching, check both the BOARD row and `git worktree list` (root sometimes makes a worktree before marking the row). Read root's BOARD banner before reacting to any session exit.

## 2. Standing rules

- **Finish the game, content first.** Tests only where necessary: import + core, plus new suites only for new save fields, core operations or outcome-deciding math. Never skip, loosen or delete a test.
- **Review:** an independent nonauthor Sol6.1-high reviewer before commits and merges; re-review conflict resolutions; merge only on green required checks for the exact reviewed head.
- **Protected (Pat's call only):**
  - beam lethality
  - the 4 s interruptible lock warning
  - collision, hull and damage rules
  - Siren senses and role senses, including silent sight 180 m and cruise sight 290 m
  - the V7-senses sweeper (PR70), including its patrol shape
  - photography design
  - ending conditions (beyond Pat's rulings)
  - art direction
- **Text:** story text stays 1 to 2 line placeholders within `docs/STORY_BIBLE_DRAFT.md`. No em dashes.
- **Never:** an APK, a force push, an amend of a pushed commit, or a branch deletion.
- **Finishability and "the fleet must matter"** (Pat 28 Oct ~12:25/12:30 ET, verbatim in USER_DIRECTIVES):
  - A bare launch finishing a required op is a skill feat: possible, demanding, worse results. It is also the anti-soft-lock floor on ACCESSIBLE and STANDARD.
  - Planning, drones, tools and progression must change the outcome on every preset. An op that plays like a walking simulator is a defect.
- **Fleet-fix acceptance bar (learned the hard way):**
  - Measure bare with Quietus in **SILENT running throughout**. Contact made by leaving SILENT, emergency bursts or exposure-only travel does not count.
  - Bare must meet the Sirens (Hunt 20 or more, or a received lock episode) in about three quarters of a batch's ops. Oxygen-only pressure counts for a quarter at most.
  - Equipped must be clearly better, and equipped hull not clearly worse.
  - Keep a permanent silent counterexample test.
  - Proven method: 096 Calder (guards on forced routes, earned discovery, drone evidence).
- Evaluate before initiating; never repeat work because a conversation restarted. Run `date` for every timestamp; never estimate.

## 3. State (29 Oct 2026 11:32 ET)

| Ref | Meaning |
|---|---|
| `gauntlet/production` 13a64ed0 | Promotion 3 (PR213, content complete) |
| `claude/integration` | 5acb079d plus whatever merged after (102 PR214, 107 PR215; 110 PR217 merging) |
| `codex/handoffs` | BOARD, handoffs, HANDOFF, LEDGER, QUEUE_S6, PAT_RULINGS_2026-10-29 |

Overnight root merged 070 (PR211), 097 (PR212, 6/7), 090 Promotion 3 (PR213). Claude S6 merged 102 diver ascent (PR214; small effect: only op 41 bare +4 s) and 107 Ironman permanent losses (PR215).

**Root lane:** 091 whole-game cold audit ACTIVE (critic pid 54908; verdicts not in). EXP-PHOTO-INTENT experiment prepared; HUD ownership released.

**Claude lane, running when Claude S6 cleared:**
- **Codex QUEUE RUNNER** pid 39080, prompt and logs in `C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\queue-s6`. It works `docs/codex/QUEUE_S6.md`: chain S 103b -> 105 -> 104 -> 106; chain C 110 -> 112 -> 109 -> 108 -> 111 -> 113. It launches fresh sessions per item, applies Claude's intent bar, keeps a "[QUEUE RUNNER ...]" banner line on BOARD.
- 103b role senses (PR216, draft): fresh pid 52948. Held because its table was identical everywhere; must show a hunter/sentinel contrast probe and two ops where the role decides the plan.
- 110 advanced economy + easier preset (PR217): fresh pid 2880; Claude intent check PASS; merges on green.

**Parked:** 099 slower SILENT (frozen on claude/silent-speed).

## 4. Next actions (in order)

1. On restart: read the QUEUE RUNNER banner and pid 39080. If the runner died, relaunch it from its saved prompt (`queue-s6\prompt-runner.txt`) after checking BOARD for what is done. Re-arm the Monitor on merges, new PRs and pids (54908, 39080 plus any session pids the runner reports).
2. Intent-check each new PR yourself too (the runner applies the bar, Claude has final say). Pay most attention to 103b, 105, 104: they must change play, not just numbers.
3. When 091 verdicts land: turn COLD_REVIEW into fix batches (worst first; photographic reconnaissance, strategic depth and player experience first). Then economy and Hunt calibration from simulated campaigns, then Promotion 4, then Pat plays on his phone when he chooses.
4. Pat deferred: wariness mark on chart (item 4), SURVIVAL in-dive pressure (item 14). Ask again after the audit, as yes/no.

## 5. Pat's rulings (S6, 29 Oct)

- Diver ascent: "For now* Yes*"; then "Survivor depth change is fine."
- Twenty widget answers, verbatim in `docs/codex/PAT_RULINGS_2026-10-29.md` (16 yes, Sorley vote no, wariness later, SURVIVAL later, keep 29 ops).
- 110 harder-preset switch removed: "That's fine for now."
- "Just keep codex running with a queue and plan your next steps so i can clear and reset you."
- Ask Pat questions as yes/no lines, or in the multiple-choice widget (he prefers it), recommendation first.
- `/siren-start` may not register as a slash command after /clear; Claude loads the `siren-start` skill instead.

## 6. Pat's phone tracker

https://claude.ai/artifact/Hheokf875FPPRczT18SnrB, pinned in his sidebar. To refresh:
1. Read the current rows asset (Artifact `list` scope assets, newest; `read` it).
2. Edit the rows: order, task, area, owner, status, pr, note.
3. Upload them with Artifact publish `asset: true` and that `url`.
4. ArtifactData `update` datasets/tasks: `source.url` plus `updated`, with `if_version` = the current version (read it first).

## 7. How-to (Windows, Git Bash + PowerShell)

- **Repo:** `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\Siren-s-Song`. The checkout on `main` is stale: read live refs with `git show origin/<ref>:<path>` (`MSYS_NO_PATHCONV=1` for paths starting with a dot).
- **Commit identity:** `user.email 272409536+pemunson90-cmd@users.noreply.github.com`. Claude commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Editing this branch:** use a scratch worktree (`git worktree add --detach <tmp> origin/codex/handoffs`), make edits with small Python scripts (`python -I`, raw strings for backslashes), commit, then `git push origin HEAD:codex/handoffs`.
- **Launching a Claude-lane session:**
  1. Claim the BOARD row first.
  2. `git worktree add -b <branch> "...\repos\Siren-s-Song-codex-NNN" origin/claude/integration`.
  3. Write a prompt from `docs/codex/FRESH_SESSION_PROMPT.md`.
  4. From PowerShell: `Start-Process -FilePath C:\Users\Archi\AppData\Local\OpenAI\Codex\bin\2993767bd1dfb009\codex.exe -ArgumentList @('exec','-m','gpt-6.1-sol','-c','model_reasoning_effort="medium"','-C',"`"<worktree>`"",'-') -RedirectStandardInput <prompt> -RedirectStandardOutput <out.log> -RedirectStandardError <err.log> -WindowStyle Hidden -PassThru`, keeping the pid. Godot import noise (`*.import`, `*.uid`) is never committed.
- **Watching (Pat wants no idle states):** keep a Monitor that polls `gh pr list` for new merged/opened PRs and `tasklist` for the session pids. Act on every event: intent-check new PRs, unlock and launch newly eligible handoffs, refresh the tracker. Re-arm it on expiry.
- **Godot checks** (from a worktree, isolated per lane): `$env:ARTIFACT_DIR='C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\<lane>'; powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate -UserDataRoot '...\isolated-<lane>'`, then `-Action Core` or `-Action Script -Script <suite> -Prefix <PREFIX>`. Never the full suite list locally. CI: sharded gate, about 36 min per PR.
- **Measurement harnesses:** 093 at `C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\093`; per-handoff artifacts sit beside it.

## 8. Restart checklist (Claude)

1. No subagents. Run `date`; read memory.
2. `git fetch origin`; read this file, the top of BOARD, the tail of LEDGER and the top of USER_DIRECTIVES on integration.
3. `gh pr list --state open` (and checks); `git worktree list`; check which codex.exe exec processes are alive.
4. Evaluate: what merged, what is red, which lane holds what.
5. Then do section 4, keep a watch running, refresh the tracker, and append one LEDGER session line.
6. Tell Pat in plain language what changed, with at most one question.
