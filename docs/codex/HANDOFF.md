# HANDOFF: Siren's Song, Claude orchestrator + two Codex lanes (updated 28 Oct 2026 20:20 ET, end of Claude session S5)

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

## 3. State (28 Oct 2026 20:20 ET)

| Ref | Meaning |
|---|---|
| `gauntlet/production` 225c3c45 | Promotion 2 (PR179) |
| `claude/integration` | Everything below marked merged |
| `codex/handoffs` | BOARD, handoffs, HANDOFF, LEDGER, prompts, design reports |

Merged 28 Oct (S4 and S5): 056, 057, 063, 065, 066, 067, 068, 071, 072, 073, 075, 082, 085, 086, 087, 088, 089 (ops 14/15/16/20 earn their chart), 096 (Calder fleet fix, 6/7 SILENT pressure), 093 report, 098 tool cargo (PR199), 100 tool lockers (PR208), PR207 (069 expedition records, 080 arc cards, 092 hidden Sorley rescue op 41).

**Claude lane, launched 20:03 ET, finishing:**

| Handoff | PR | Task |
|---|---|---|
| 094 Iron Choir fleet fix | 198 | Finish and merge. 5/8 SILENT pressure; 25, 27 and 28 still quiet |
| 095 Glass Reach fleet fix | 209 | Repair 4 hosted failures (sweeper invariant, landmark shape, keel_mark route), keep 6/8, merge |
| 101 debug console | 210 | Reconcile with integration (op 41, lockers) and merge |

Check each BOARD row: DONE, or BLOCKED with a reason.

**Root lane:** 070 resume after app kill (worktree Siren-s-Song-codex-070); 097 early-ops fleet fix (uncommitted edits in Siren-s-Song-codex-097, nothing pushed since 13:58; ask root for status if still silent).

**Parked:** 099 slower SILENT. Pat said "Sure", but the global 6 m/s candidate caused 14 oxygen losses and cut Calder pressure to 3/7. Frozen on claude/silent-speed; revisit only from audit evidence.

## 4. Next actions (in order)

1. Make sure PR198, PR209 and PR210 merged (or handle their BLOCKED rows). Refresh Pat's tracker.
2. When 070 and 097 land, **content is complete**: launch **090 Promotion 3** (Claude lane), then **091 whole-game cold audit**. 091 already lists the known open items, to hand the critic only after its own verdicts.
3. Turn COLD_REVIEW_4 into fix batches (worst first; photographic reconnaissance, strategic depth and player experience first, per Pat 27 Oct). Then economy and Hunt calibration from simulated campaigns (numbers are provisional), then Promotion 4, then Pat plays on his phone when he chooses.
4. Possible follow-ups to offer Pat:
   - Sorley rescue reward: currently supplies; pilotage charts were the preferred idea.
   - Whether the Sorley rescue counts as an 088 ending vote.
   - SURVIVAL in-dive pressure.

## 5. Pat's rulings this session (verbatim copies in USER_DIRECTIVES via PRs)

- 088: arcs 4 to 6 may change the ending family, decided after op 34. Vote rule kept "as is for now".
- 092: hidden Sorley rescue, unlocked by logs or the op 37 photo, with a reward and ending lines.
- Finishability: the two quotes above.
- 098: tools cost cargo ("Yes").
- 099: SILENT may be slowed ("Sure"), but parked on evidence.
- 101: "I think maybe we need a debug console."
- Two Codex lanes: "Op 2".
- Ask next from `docs/codex/PAT_QUESTION_PREP.md` (ranked by game-feel impact, with recommendations). Item 13 is ruled.

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
