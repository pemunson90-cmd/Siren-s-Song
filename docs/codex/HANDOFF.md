# HANDOFF (Claude orchestrator, Siren's Song). Read this, nothing else, on restart.

Updated 2026-10-30T12:09:01-04:00 (Claude S10). Live refs, PRs and BOARD are newer when they disagree. Pat's dated words (USER_DIRECTIVES on claude/integration, PAT_RULINGS_2026-10-29.md here) outrank this. Older detail: `HANDOFF_ARCHIVE_2026-10-29.md` (read only when a question needs it).

## Roles
- **Pat** rules and approves in chat only; never ask him to operate anything. One plain yes/no or widget question, recommendation first, only when it is his call.
- **Claude** (sole Claude): intent-checks PRs, writes handoffs and queue order, keeps BOARD/HANDOFF/LEDGER/tracker, talks to Pat. No Claude subagents, teams, forks or workflows (exception: a few read-only Haiku PR auditors when Pat asks).
- **Codex, two lanes:** Claude lane = BOARD rows `claude-lane` / `codex-fresh-NNN`, run by `auto.py`. Root lane = `codex-root` rows, the Codex desktop session. Neither stops, reconciles or merges the other's work.

## The queue (auto.py)
- Folder `C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6`. `auto.py` (plain Python, pid in `auto.pid`) ticks every 2 min, reads `CHAINS`/`ITEMS` in `runner.py`, launches phase A build, B measure+PR (reasoning low), C merge sessions handing off through `NNN.notes.md`.
- **Phase C starts only after Claude posts a PR comment containing `CLAUDE INTENT: PASS`.** `CLAUDE INTENT: HOLD` relaunches phase A once; a second failure gets marked BLOCKED with numbers.
- auto.log EVENT lines: `PR<n> ready; waiting for Claude intent check` means act now. Also `exited without a PHASE line` / `Claude please inspect`.
- **Red CI in phase C:** auto.log says `required CI failed in phase C`. Repair: set the BOARD row CLAIMED (if a session marked it BLOCKED), append a repair note plus `PHASE A CONTINUE` to `NNN.notes.md`, reset that session's `phase` to `A`, `starts` to 3 and `revisions` to 1 in runner-state.json (revisions=1 stops auto.py treating the procedural HOLD as a revision request; starts>MAX_CONTINUES+3 halts the item), drop `waiting`/`alerted`, post `CLAUDE INTENT: HOLD (procedural, pending CI repair)`, and post PASS again after re-checking the refreshed PR. Never append text after a session's final PHASE line (auto.py reads the last PHASE line). A chain advances past a BLOCKED row, so flip it back to CLAIMED before the next item launches. Process kills are denied by the auto-mode classifier.
- If auto.py is dead: `Start-Process python -ArgumentList '-I','auto.py' -WorkingDirectory <folder> -WindowStyle Hidden -PassThru`, write the pid to `auto.pid`.
- Queue a new item: write `docs/codex/NNN-slug.md` (copy 118's shape), add a BOARD row `| <row> | NNN TITLE | QUEUED (claude-lane, Pat 29 Oct) | | | [handoff](NNN-slug.md) |`, add `NNN:(row,'slug')` to ITEMS and NNN to a chain in `runner.py`.
- Watch: Monitor command `bash C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/queue-s6/watch.sh` (30 min max; re-arm on expiry).

## Intent check (Claude's main job)
Read the PR's before/after tables, not its summary, and its latest comments. Check against Pat's rulings:
- **Fleet must matter / finishability (Pat 28 Oct):** measure bare with Quietus SILENT throughout; bare must meet the Sirens (Hunt 20 or more, or a received lock) in about 3/4 of a batch's ops (oxygen-only pressure counts for 1/4 at most) and still finish on ACCESSIBLE and STANDARD; equipped clearly better (time, lock or hull, not oxygen only), equipped hull not worse. An op that plays like a walking simulator is a defect.
- A table identical everywhere has not met a "must change play" ruling. Presentation-only work must show physics identical.
- **Protected (Pat's call only):** beam lethality, 4 s interruptible lock warning, collision/hull/damage, Siren and role senses (silent 180 m, cruise 290 m), PR70 sweeper, photography design (exposure, grading), ending conditions, art direction. Story text: 1-2 line placeholders, no em dashes. Never an APK, force push, amend or branch deletion.

## State (2026-10-30T06:36:19-04:00, Claude S9)
- claude/integration tip cdd58f64. Merged this session: 116 PR231 (radio ops), 121 PR232 (photo evidence), 120 PR233 (navigation), 118 PR229 (readability, after seven bounded CI repairs, the last one a real touch-ownership regression between 118's fold and 120's CONTINUE). PR220 closed as superseded.
- Tasks 115-121 all DONE. BOARD banner told root to start 122 Promotion 4, then 123 cold audit 5.
- 124 PR audit cleanup resumed in phase A on current integration (it had self-blocked on overlap with 118).
- Pat said yes (2026-10-30T12:09:01-04:00) to the authored ending plus late-campaign evidence (F7/F8/F14): queued as 125, BOARD row 122, chain 2. 124 PR235 merged 2ef78adf; root 122 Promotion 4 merged 26e09906; root holds 123 cold audit 5.

## Next actions
0. **FREEZE (Pat 2026-10-30T12:53:27-04:00):** no new game items queued in either lane after 125. Root runs remaining 123 regions in parallel (late campaign to ending; side modes). When COLD_REVIEW_5 lands, Claude writes ONE comprehensive ranked plan from it plus open COLD_REVIEW_4 items (F12 etc.) and the story-depth gap, then fans out across both lanes.
1. Intent-check every waiting PR (PASS or HOLD comment). 124 is next.
2. Intent-check 125 when its PR is ready (ending conditions and physics must be identical).
3. Pat deferred: wariness mark on chart, SURVIVAL in-dive pressure; ask after the audit batches.
4. When root's 123 COLD_REVIEW_5 lands, turn it into fix batches and repeat (AGENTS.md loop).

## How-to
- Repo checkout on `main` is stale: read live refs with `MSYS_NO_PATHCONV=1 git show origin/<ref>:<path>`. Never read the whole BOARD (89 KB) or LEDGER (40 KB): `head -c 2000` / `tail -n 5`.
- Edit `codex/handoffs` in a scratch worktree (`git worktree add --detach <tmp> origin/codex/handoffs`), small `python -I` scripts written to a file (heredocs with backslashes break), commit with `user.email 272409536+pemunson90-cmd@users.noreply.github.com` and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, `git push origin HEAD:codex/handoffs`.
- Pat's phone tracker https://claude.ai/artifact/Hheokf875FPPRczT18SnrB: Artifact list scope assets (newest) and read it; edit rows (order, task, area, owner, status, pr, note); upload with publish `asset: true`; ArtifactData update `datasets/tasks` `source.url` + `updated` with `if_version` from a get.
- Run `date` for every timestamp. Append one LEDGER line per session.
