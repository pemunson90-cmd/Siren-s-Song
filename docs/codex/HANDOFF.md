# HANDOFF: Siren's Song, Claude orchestrator + Codex execution (updated 28 Oct 2026 11:20 ET)

Read this first after any context clear or restart, then LEDGER.md and the BOARD banner. Live refs, PRs and BOARD rows are newer than this file when they disagree. Pat's dated words in `docs/USER_DIRECTIVES.md` on `claude/integration` outrank everything here.

## 1. Roles (Pat, 28 Oct efficiency baseline + independent-review ruling)

- **Pat** rules and approves in chat only; never asked to operate anything. One plain question at a time, only when genuinely his.
- **Claude** (sole Claude orchestrator, Opus 5.5 medium): plans, prioritizes, decides architecture and research direction, writes handoffs and queue order, keeps BOARD/HANDOFF/LEDGER and Pat's tracker current, verifies milestones and release readiness, talks to Pat. **Claude launches no subagents, agent teams, forks or workflows.** Claude does only small git coordination itself; implementation, fixes, test runs and reviews go to Codex.
- **Codex root** (Sol6.1 medium, desktop session) executes: dispatches bounded Codex workers (weakest capable model, never Astra), obtains independent Sol6.1-high review of each frozen patch before commit and before merge, commits, collects CI, merges, closes handoffs, runs milestone promotions under Pat's standing option A after review. Its worktrees: `Siren-s-Song-codex-NNN` beside the repo and `~/.cache/sirens-song-toolchain/worktrees/`.
- Claude launches Codex headless only if no codex-root session is active (check BOARD banner time and the mtime of `~/.codex/logs_2.sqlite-wal`).

## 2. Standing rules

- Finish the game; content first; tests only where necessary (import + core, plus new suites only for new save fields, new core operations, outcome-deciding math). Never skip, loosen or delete a test.
- **Review (Pat 28 Oct, supersedes 26 Oct):** separate independent reviewer before new commits and merges; reuse valid review for unchanged code; re-review material changes and conflict resolutions. Merge only on green required checks for the exact reviewed head.
- Protected (Pat's call): beam lethality, 4 s interruptible lock warning, collision/hull/damage rules, Siren senses (only the approved sight-only Hunt), enemy role senses, photography design, story ending conditions, art direction. Story text stays 1 to 2 line placeholders within `docs/STORY_BIBLE_DRAFT.md`. No em dashes. No APK, force push, amend of pushed commits, or branch deletion.
- Evaluate before initiating; never repeat work because a conversation restarted.

## 3. State (28 Oct 2026 11:20 ET)

| Ref | SHA | Meaning |
|---|---|---|
| `gauntlet/production` | 225c3c45 | Promotion 2 (PR179), reviewed snapshot c5bd45a5 |
| `claude/integration` | e09c2db8 | Newer than P2: 063, 065, 066, 075, 082, 087 and Silt photo fix |
| `codex/handoffs` | this commit | BOARD, handoffs, HANDOFF, LEDGER, prompts |

CI: sharded gate (084) live, about 36 minutes per PR. Handoffs DONE through 084 except those listed below.

## 4. In flight (all executed by Codex root)

| Handoff | PR | State at 11:20 ET |
|---|---|---|
| 056 mode select + expeditions | 175 (draft) | head 45991efb, sharded CI running; gates 057/068/069/070/080 |
| 072 settings depth | 174 | head f99fa5a9, CI running; gates 067 |
| 085 arc 6 route carry | 185 | head 236aef01, CI running |
| 086 record unsaved rescues | 186 | head 45c58750, CI running |

DONE since 10:20: 063 (PR184), 065 (PR183), 075 (PR176), 082 (PR173), 087 (PR187), 083 board row (PR164).

## 5. Queue (priority order; preconditions gate eligibility)

Eligible now: **073** quality/battery tier (063 DONE); **089** earned chart beyond Confluence (V7 restore) once it does not overlap 073's drawing. After 085: **088** ending decided after op 34 (Pat ruling 28 Oct ~11:22 ET).
Gated on 056: 057 naval career, 068 expedition offers, 069 expedition records/seed, 070 resume after app kill, 080 arc intro/outro cards. Then 071 career riders (after 057), 067 late teaching (after 072).
**Content complete** = all of the above merged (list in 090). Then **090 Promotion 3**, then **091 whole-game cold audit** run by Codex: a fresh-context Sol6.1-high critic with no build notes, photographic reconnaissance, strategic depth and player experience first (Pat ruling 27 Oct), producing a ranked deficiency list that Claude turns into fix handoffs.
**Roadmap after 091 (Claude plans, AI-DESIGNED, 28 Oct):**
1. Claude turns COLD_REVIEW_4 into fix batches 092+ by severity: blockers and regressions first, then photographic reconnaissance, strategic depth and player experience (Pat 27 Oct order), then polish. Findings that touch protected items become one-at-a-time questions for Pat.
2. Economy and Hunt calibration from simulated full-campaign runs (Pat rulings 4 and 5: current numbers are provisional).
3. 089 stage 2 (more earned-chart ops or old-survey outlines) only if the audit says stage 1 plays well.
4. Promotion 4 after the fix batches; then Pat chooses when to play it on a phone. Development does not wait for that.
5. Bundle the Pat-only items as single questions between batches: QUESTIONS_FOR_PAT 2 (second branch point), 4 (Sorley's boy), 6 to 12 (Siren sensing, protected), 13 (tool budgets), plus the list below.
Needs Pat before queuing: per-role Siren sounds, late-role silhouettes, economy custom toggles, ambient sea life, app icon/splash.
Context hygiene (Pat 28 Oct ~10:09 ET): let in-flight Codex runs finish; start new work in fresh Codex sessions rather than extending long ones.

## 6. Waiting on Pat

- Ruled 28 Oct ~11:22 ET: arcs 4 to 6 may change the ending family, decided at op 34 (handoff 088). Next question to ask: QUESTIONS_FOR_PAT item 2 or 4.
- Full list: `docs/QUESTIONS_FOR_PAT.md` on integration. Lane-raised: credits creator name (placeholder), crediting Claude Code/Codex as tools, lung_solo bypass/isolate par, Alerts bus placement under Effects, fittings one-tap vs preview-confirm.

## 7. How-to (Windows box, Git Bash + PowerShell)

- Repo: `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\Siren-s-Song` (checkout on `main` is stale; read live refs with `git show origin/<ref>:<path>`; set `MSYS_NO_PATHCONV=1` for paths starting with `.`).
- Git identity for every commit: `user.email 272409536+pemunson90-cmd@users.noreply.github.com` (other emails are rejected on push). Claude commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Edit this branch from a scratch worktree: `git worktree add --detach <tmp> origin/codex/handoffs`, edit, commit, `git push origin HEAD:codex/handoffs` (on rejection: fetch, rebase own unpushed commit, push). Write multi-line edits as Python script files, not heredocs with apostrophes (Git Bash parses them badly).
- Godot 4.6.3 local checks (PowerShell, from a worktree root, isolated per lane): `$env:ARTIFACT_DIR='C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\<lane>'; powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate -UserDataRoot 'C:\Users\Archi\.cache\sirens-song-toolchain\isolated-<lane>'`, then `-Action Core`, `-Action Script -Script <suite> -Prefix <PREFIX>`. Registry: `python -I scripts\toolchain\check-suites.py`. Never run the full list locally.
- Shared files: insert suite rows, MODULES/RESUME rows and validator registrations next to related rows, not at the end, so parallel merges do not collide. Each lane gets its own rank block in `game/tests/suites.txt`.
- Launch Codex headless (when Codex is idle and OPEN handoffs exist): `C:\Users\Archi\AppData\Local\OpenAI\Codex\bin\<hash>\codex.exe exec -m gpt-6.1-sol -c model_reasoning_effort="medium" -C "C:\Users\Archi\Documents\Codex\2026-10-24\you-are-codex-the-implementation-worker\sirens-song" -` with prompt A of START_PROMPTS.md on stdin, via PowerShell `Start-Process -WindowStyle Hidden`, logs to a scratch folder. Check first that a codex-root desktop session is not already driving the queue (board banner time, `~/.codex/logs_2.sqlite-wal` mtime).
- Pat's phone tracker: https://claude.ai/artifact/Hheokf875FPPRczT18SnrB (Dashboard). To refresh: rebuild the rows JSON (order, task, area, owner, status, pr, note) from BOARD.md, upload it as an asset (Artifact publish `asset: true`, `url` above), then ArtifactData `update` datasets/tasks `source.url` + `updated` with the document's current version.

## 8. Restart checklists (see also LEDGER.md)

**Claude:** no subagents. Run `date`; read memory; `git fetch origin`; read this file, the BOARD banner (top 5 entries), the top entry of USER_DIRECTIVES on integration; `gh pr list --state open`; `git worktree list`. Evaluate: what merged, what is red, who holds what. Then: merge green PRs you own; handle section 3's next action; refresh the tracker; write handoffs so Codex has at least four eligible OPEN items; ask Pat at most one pending question. Append one LEDGER.md session line. Delegate execution to Codex root via handoffs and banner notes.

**Codex:** follow prompt A (or C for a blank cloud chat) in START_PROMPTS.md, which now reads this file first. Work only on handoffs CLAIMED by codex or OPEN and eligible; leave Claude-claimed lanes to Claude unless the banner says Claude is away.
