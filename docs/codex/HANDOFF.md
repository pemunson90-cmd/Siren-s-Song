# HANDOFF (Claude orchestrator, Siren's Song). Read this, nothing else, on restart.

Updated 2026-10-30T22:13:30-04:00 (Claude S11). Live refs, PRs and BOARD are newer when they disagree. Pat's dated words (USER_DIRECTIVES on claude/integration, PAT_RULINGS_2026-10-29.md here) outrank this. Older detail: `HANDOFF_ARCHIVE_2026-10-29.md` (read only when a question needs it).

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

## State (2026-10-30T22:13:30-04:00, Claude S11 checkpoint before /clear)
- claude/integration tip 05d09718. Production 26e09906 (Promotion 4). Main unchanged.
- **Freeze lifted for packages 0-2** (Pat ~18:00). Plan: docs/codex/PLAN_DRAFT_1.md (+1b release controls). Pat rule: only ask what needs him; log every other call in docs/codex/DECISIONS.md (D1-D9 so far) and keep him posted.
- **Pat rulings today (PAT_RULINGS file):** one-press travel shortcuts are test-only, stripped for release play; release play is piloted by hand (waypoints, depth, in-reach jobs, recall drones); you must still be able to crash, with a light edge-slide/hold assist so you do not grind on walls; it must stay challenging and risky.
- **126 TRUTHFUL COMMANDS, PR238** (claude/truthful-commands): wording accepted (real exit names, legal work approach points, grey-action reasons in status line, per-craft tools, DECODE for Blackwater). CI repair 3 queued 2026-10-30T22:13:30-04:00 for head 4268032f failures: STATUS TEXT UI off-switch ARRIVALS label x10, desktop LISTEN SAMPLE task x1. Latest PR comment is a procedural HOLD; **post CLAUDE INTENT: PASS only when every required check is green on the refreshed head.** Root cause of 3 red CI cycles: runner.py:64 told workers "affected suites only"; fixed at 2026-10-30T22:13:30-04:00 to require the FULL suite list before every push (also patched prompt-126.txt; backup runner.py.bak-s11b).
- **127 RELEASE CONTROLS** queued after 126 (BOARD row 124, chain 2). Handoff has Pat's crash/edge-assist rules and the full-suite rule.
- **Root:** owns package 0 (critic driver fix: parse-error result, temp-then-rename) and package 2 (ROOT-PKG2: overlap chooser, stable chart, threat stack, 150% reachability; includes the pre-existing cover150 WITHDRAW/TORPEDO fold). COLD_REVIEW_5 still pending. Asked root to trace a candidate progress-loss bug: briefing DIVE PAUSED replaced an active dive (Choir C2-027).
- **Critics:** all regions frozen (main O2-G2, L1, side S1-S3, Choir C1/C2, Trench T1/T2). All five stalls are driver.gd:18 parse failures (harness). Evidence: artifacts/evidence-base/CLAUDE_REVIEW.md + ADDENDUM_LATE_VERDICTS.md (C52 threat text, C53 per-craft tools, C44 route-to-object-centre, source-verified lines). Nobody has played END OF LINE.

## How-to
- Repo checkout on `main` is stale: read live refs with `MSYS_NO_PATHCONV=1 git show origin/<ref>:<path>`. Never read the whole BOARD (89 KB) or LEDGER (40 KB): `head -c 2000` / `tail -n 5`.
- Edit `codex/handoffs` in a scratch worktree (`git worktree add --detach <tmp> origin/codex/handoffs`), small `python -I` scripts written to a file (heredocs with backslashes break), commit with `user.email 272409536+pemunson90-cmd@users.noreply.github.com` and `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, `git push origin HEAD:codex/handoffs`.
- Pat's phone tracker https://claude.ai/artifact/Hheokf875FPPRczT18SnrB: Artifact list scope assets (newest) and read it; edit rows (order, task, area, owner, status, pr, note); upload with publish `asset: true`; ArtifactData update `datasets/tasks` `source.url` + `updated` with `if_version` from a get.
- Run `date` for every timestamp. Append one LEDGER line per session.
