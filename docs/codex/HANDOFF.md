# HANDOFF (Claude orchestrator, Siren's Song). Read this, nothing else, on restart.

Updated 2026-10-29T18:51:19-0400 (Claude S8). Live refs, PRs and BOARD are newer when they disagree. Pat's dated words (USER_DIRECTIVES on claude/integration, PAT_RULINGS_2026-10-29.md here) outrank this. Older detail: `HANDOFF_ARCHIVE_2026-10-29.md` (read only when a question needs it).

## Roles
- **Pat** rules and approves in chat only; never ask him to operate anything. One plain yes/no or widget question, recommendation first, only when it is his call.
- **Claude** (sole Claude): intent-checks PRs, writes handoffs and queue order, keeps BOARD/HANDOFF/LEDGER/tracker, talks to Pat. No Claude subagents, teams, forks or workflows (exception: a few read-only Haiku PR auditors when Pat asks).
- **Codex, two lanes:** Claude lane = BOARD rows `claude-lane` / `codex-fresh-NNN`, run by `auto.py`. Root lane = `codex-root` rows, the Codex desktop session. Neither stops, reconciles or merges the other's work.

## The queue (auto.py)
- Folder `C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6`. `auto.py` (plain Python, pid in `auto.pid`) ticks every 2 min, reads `CHAINS`/`ITEMS` in `runner.py`, launches phase A build, B measure+PR (reasoning low), C merge sessions handing off through `NNN.notes.md`.
- **Phase C starts only after Claude posts a PR comment containing `CLAUDE INTENT: PASS`.** `CLAUDE INTENT: HOLD` relaunches phase A once; a second failure gets marked BLOCKED with numbers.
- auto.log EVENT lines: `PR<n> ready; waiting for Claude intent check` means act now. Also `exited without a PHASE line` / `Claude please inspect`.
- **Red CI in phase C:** auto.log says `required CI failed in phase C`. Repair: set the BOARD row CLAIMED (if a session marked it BLOCKED), append a repair note plus `PHASE A CONTINUE` to `NNN.notes.md`, reset that session's `phase` to `A` in runner-state.json, post `CLAUDE INTENT: HOLD (procedural, pending CI repair)`, and post PASS again after re-checking the refreshed PR.
- If auto.py is dead: `Start-Process python -ArgumentList '-I','auto.py' -WorkingDirectory <folder> -WindowStyle Hidden -PassThru`, write the pid to `auto.pid`.
- Queue a new item: write `docs/codex/NNN-slug.md` (copy 118's shape), add a BOARD row `| <row> | NNN TITLE | QUEUED (claude-lane, Pat 29 Oct) | | | [handoff](NNN-slug.md) |`, add `NNN:(row,'slug')` to ITEMS and NNN to a chain in `runner.py`.
- Watch: Monitor command `bash C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6/watch.sh` (30 min max; re-arm on expiry).

## Intent check (Claude's main job)
Read the PR's before/after tables, not its summary, and its latest comments. Check against Pat's rulings:
- **Fleet must matter / finishability (Pat 28 Oct):** measure bare with Quietus SILENT throughout; bare must meet the Sirens (Hunt 20 or more, or a received lock) in about 3/4 of a batch's ops (oxygen-only pressure counts for 1/4 at most) and still finish on ACCESSIBLE and STANDARD; equipped clearly better (time, lock or hull, not oxygen only), equipped hull not worse. An op that plays like a walking simulator is a defect.
- A table identical everywhere has not met a "must change play" ruling. Presentation-only work must show physics identical.
- **Protected (Pat's call only):** beam lethality, 4 s interruptible lock warning, collision/hull/damage, Siren and role senses (silent 180 m, cruise 290 m), PR70 sweeper, photography design (exposure, grading), ending conditions, art direction. Story text: 1-2 line placeholders, no em dashes. Never an APK, force push, amend or branch deletion.

## State (2026-10-29T18:51:19-0400)
- `gauntlet/production` 13a64ed0 = Promotion 3. `claude/integration` has everything merged since (102-114, 106-113, 111 PR226 last).
- **091 audit DONE:** frozen verdict `C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/critic-091-13a64ed0/audit/INDEPENDENT_VERDICT.md` (16 findings F1-F16; END OF LINE reached). Root keeps COLD_REVIEW_4 and known-items reconciliation.
- **Chain S:** 115 thermal ops (PR227 HELD: op 39 bare lost all Siren pressure; revision running) -> 116 radio ops -> 121 photo evidence (F1/F15, Pat yes 29 Oct).
- **Chain C:** 117 tool cargo all modes (building) -> 118 readability (F2/F6/F16) -> 119 orders (F3/F5/F13) -> 120 navigation (F4/F9/F10/F11).
- Blocked: 105 PR219, 104 PR220 (replaced by 115/116). Parked: 099 slower SILENT.

## Next actions
1. Intent-check every waiting PR (PASS or HOLD comment).
2. After 121 lands, ask Pat (yes/no) about F7/F8/F14: an authored ending and more varied late-campaign evidence (story text rule). F12 collision staging is protected: suggestion only.
3. Pat deferred: wariness mark on chart, SURVIVAL in-dive pressure; ask after the audit batches.
4. **Next gauntlet loop (Pat 29 Oct: after the fixes):** when rows 115-121 all read DONE or BLOCKED, post a BOARD banner telling root to start 122 Promotion 4, then 123 cold audit 5 (fresh blind critic, region sessions). Then turn COLD_REVIEW_5 into fix batches and repeat (AGENTS.md loop).
5. Still open: 116 is paused until 115 merges (its notes already say PHASE A CONTINUE). Hunt calibration note: op 39 bare pressure fell from Hunt 92 to 22 in 115.

## How-to
- Repo checkout on `main` is stale: read live refs with `MSYS_NO_PATHCONV=1 git show origin/<ref>:<path>`. Never read the whole BOARD (89 KB) or LEDGER (40 KB): `head -c 2000` / `tail -n 5`.
- Edit `codex/handoffs` in a scratch worktree (`git worktree add --detach <tmp> origin/codex/handoffs`), small `python -I` scripts written to a file (heredocs with backslashes break), commit with `user.email 272409536+pemunson90-cmd@users.noreply.github.com` and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, `git push origin HEAD:codex/handoffs`.
- Pat's phone tracker https://claude.ai/artifact/Hheokf875FPPRczT18SnrB: Artifact list scope assets (newest) and read it; edit rows (order, task, area, owner, status, pr, note); upload with publish `asset: true`; ArtifactData update `datasets/tasks` `source.url` + `updated` with `if_version` from a get.
- Run `date` for every timestamp. Append one LEDGER line per session.
