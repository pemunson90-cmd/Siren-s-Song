**28Oct06:29ET, Pat direct ruling:** Codex may run subagents. Claude has a subagent bug; it does not restrict Codex. Apply standing fit-to-task delegation: Codex orchestrator Sol6.1 medium, smallest capable model/effort per bounded subtask, never Astra. No routine approval needed. Four Codex workers are active on066 cache,056 layout,064 briefing and165/171 CI reconciliation. Promotion2 PR179 is a fixed00394df8 integration snapshot, under sharded verification; Codex root handles merge on green.

**28Oct06:22ET, explicit Pat authorization:** Claude is on a five-hour cooldown; Codex root continues without waiting.084/PR172 is merged e52a8d6c and083/PR164 merged00394df8. Codex root collects/reconciles pending Claude lanes072/082/064/075/060-cues, preserving their WIP;056/PR175 loadout-layout failure and064/PR178 opening-brief failure get bounded repairs. Migration of cancelled165/171 and other old-CI heads uses the integrated sharded gate.066 physical-cache worker remains active; do not touch its worktree. Promotion2 is now Codex-root integration work under standing approval when a coherent current head is green.

# HANDOFF: Siren's Song, Claude root + Codex (written 28 Oct 2026 ~06:10 ET)

Read this first after any context clear or restart. It is the single current handoff for both Claude (root orchestrator) and Codex (implementation, or codex-root while Claude is away). Live refs, PRs and BOARD.md rows are newer than this file whenever they disagree; check them before acting. Pat's dated words in `docs/USER_DIRECTIVES.md` on `claude/integration` outrank everything here.

## 1. Who does what

- **Pat** (owner) only rules and approves in chat. Never ask him to click, merge, type to Codex, or operate git. Ask one plain question at a time, only for decisions that are genuinely his.
- **Claude** is root orchestrator: plans, writes handoffs on this branch, runs its own lanes, merges green PRs into `claude/integration`, opens and merges milestone promotions to `gauntlet/production` (Pat's standing option A), keeps Pat's tracker current.
- **Codex** builds handoffs. While Claude is rate-limited, a Codex desktop session acts as **codex-root**: it resumes Claude-claimed lanes, collects CI centrally and merges. Its worktrees are `Siren-s-Song-codex-NNN` beside the repo and `C:\Users\Archi\.cache\sirens-song-toolchain\worktrees\NNN-*`. When Claude returns, the split is written on the BOARD banner; neither root touches branches or worktrees the other holds without a banner note first.
- **Models:** Codex runs gpt-6.1-sol at medium effort; its subagents use the weakest model properly scoped to the task and never Astra. Claude subagents: haiku for mechanical/docs, sonnet for features, opus only for very hard work or the final audit.

## 2. Standing rules (Pat, 26 to 28 Oct)

- Finish the game. Content first. Tests only when necessary: import + core, plus a new suite only for a new save field/validator, a new core operation (bare-Quietus finishability journey), or outcome-deciding math. Never skip, loosen or delete a test.
- No per-feature independent review, no evidence folders. Merge on green `guidance` + `game-smoke` for the exact head, merge commit. One whole-game cold audit happens after content is complete.
- Every task closes by: status DONE + five-line Completion in its handoff file, BOARD row, MODULES/RESUME lines it made stale, release worktree/claim.
- Protected (Pat's call): beam lethality, 4 s interruptible lock warning, collision/hull/damage rules, Siren sight/hearing/speed (only the approved sight-only Hunt), enemy role senses, photography design, story ending conditions, art direction.
- Story: provisional bible `docs/STORY_BIBLE_DRAFT.md`; 1 to 2 line placeholders; Sirens were here first and strike drilling/military sites they read as threats; Quietus is a recon sub rescuing human survivors. No em dashes in added text.
- No APK, no force push, no amend of pushed commits, no branch deletion, no pushes to `main` or `gauntlet/production` except Claude's milestone promotion PRs.
- **28 Oct ~06:00 ET, Pat: "Hold off on subagents."** Claude spawns no new subagents or workflows until Pat says to resume in a new session. Lanes already running when this was written were left to finish (section 4). Codex is unaffected unless Pat says otherwise.
- Pat 28 Oct: **evaluate before initiation.** On every resume, read this file, the BOARD banner and live PRs, then decide.

## 3. State at writing

| Ref | SHA | Meaning |
|---|---|---|
| `gauntlet/production` | 66a3b21f | Promotion 1 (PR148): handoffs 001 to 049 |
| `claude/integration` | 609f29a9 | Includes 050 to 055, 058 to 062, 074, 077 to 079, C6 doc sweep, C7 economy calibration |
| `codex/handoffs` | affef2e3+ | This branch (board, handoffs, prompts) |

Merged since promotion 1: PR147 (050 Hunt), 151 (054 economy), 152 (051 Calder), 153 (052 optionals), 154 (053 regional look/sound, Night mode), 150 (055 modules + 8 field tools), 156 (doc sweep), 157 (C7 economy calibration), 158 (059 challenge pars), 159 (060 event audio), 160 (061+062 voices, field log, research, archive, credits), 162 (074 optional 38/39 geometry), 163 (058 menu focus, fps cap), 166 (077 route carry), 167+170 (078 ledger), 168 (079 Ironman one timeline).

**CI:** the single game-smoke job outgrew GitHub's 90-minute cap. 084 (PR172) splits it into game-core plus four runtime shards and an aggregate `game-smoke` check (about 36 minutes total). Its first run failed on `..` in an upload-artifact path; Claude fixed it (317e4630, green on all seven checks), then resolved a conflict with PR150's temporary 150-minute cap by keeping the sharded jobs (94835a77). **Done 06:20 ET: PR172 merged as e52a8d6c (084 DONE).** After that, any PR whose run was started on the old single job should merge fresh integration and push so it reruns on the sharded gate.

## 4. In flight (owner, branch, PR, next action)

| Handoff | Owner | Branch / worktree | PR | Next action |
|---|---|---|---|---|
| 056 modes + expeditions | codex-root | claude/c3-modes | 175 | Codex root collects CI, merges |
| 066 fleet sites | codex-root | claude/lane-fleet-sites | 169 | Codex root |
| 076 Arc 6 maps + capstone | codex-root | claude/c11-arc6-capstone | 165 | Was cancelled by the 90-min cap and conflicts: merge integration (after 172), push, rerun |
| 081 chart accessibility | codex-root | claude/lane-chart-accessibility | 171 | Codex root |
| 083 Siren dossier | codex-root | claude/lane-siren-dossier | 164 | Green earlier but conflicting: merge integration, push |
| 072 settings depth | Claude lane | claude/c15-settings-depth, worktree Siren-s-Song-claude-c15-settings | 174 | Lane workflow collects CI and merges; if the lane died, collect CI and merge by hand |
| 082 crew effects | Claude lane | claude/c16-crew-effects, Siren-s-Song-claude-c16-crew | 173 | same |
| 060 follow-up: four field-tool cues | Claude lane | claude/c17-tool-cues, Siren-s-Song-claude-c17-cues | 177 | same; then mark 060 DONE |
| 064 fit surface (24 modules) | codex-root bounded repair | claude/c18-fit-surface, Siren-s-Song-claude-c18-fit | 178 | Head `8bfa330a` includes pushed WIP and concise-opening fix. The fit summary remains available behind `FIT SUMMARY · SHOW`; the 420-character and goal/danger assertions remain. Local onboarding 30/0 and fit_surface_ui 52/0 passed after reconciling integration including 084. PR comment records the repair. Root owns CI collection and final task closeout. |
| 075 phone profile transfer | Claude lane | claude/c19-profile-transfer, Siren-s-Song-claude-c19-profiles | 176 | same as 072 |

Claude lane runner: `docs/codex/claude-lane-workflow.js` on this branch (implement, preflight, PR, CI watch/fix loop, merge). Relaunch a lane with the Workflow tool, `scriptPath` = a local copy of that file, and `args` = {key, worktree, branch, title, handoffs[], notes, files, avoid, anchor, ranksLocal, ranksCI}. Only when Pat allows subagents again.

Board hygiene owed: 059 row still says CLAIMED but it is DONE (PR158 merged); 060 closes when PR177 merges.

## 5. Queue (OPEN, in priority order; preconditions gate eligibility)

057 naval career (after 056) · 063 performance (after 081) · 065 alien module world uses (after 076) · 067 late-campaign teaching (after 072) · 068 expedition offers, 069 expedition records/seed, 070 resume after app kill (after 056; career half after 057) · 071 career riders (after 057) · 073 quality tier/battery governor (after 058 and 063) · 080 arc intro/outro cards (after 056 and 061).

Then: **Promotion 2** (Claude: PR `claude/integration` to `gauntlet/production`; 084 is in, so open it once the integration head is green; merge commit; tell Pat in one line). Then the remaining queue, then the **whole-game cold audit** (fresh critic with no build notes; photographic reconnaissance, strategic depth and player experience first, per Pat's 27 Oct ruling 6), then fix lists for both streams.

Not queued yet: content that needs Pat (sonic identity per Siren role, late-role silhouettes, economy custom toggles, ambient sea life, app icon/splash). See section 6.

## 6. Waiting on Pat

- **Asked, pending:** should arcs 4 to 6 be able to change which of the four endings you get (decide at op 34), or stay decided at ops 12/13? Until he rules, endings stay as they are.
- Full list of 24 scout questions: `docs/QUESTIONS_FOR_PAT.md` on integration. Ask one at a time; current behavior stays until he rules.
- Small ones raised by lanes: the credits creator line is a visible placeholder "Created by (to be named)"; whether to credit Claude Code and Codex as tools; par for lung_solo bypass/isolate outcomes (currently 110 s); haptic pulse for hull strain; whether a mid-dive voice line re-shows on retry.
- AI-DESIGNED and provisional: economy numbers, Hunt tuning, field-tool and module numbers, voice lines, ledger text.

## 7. How-to (Windows box, Git Bash + PowerShell)

- Repo: `C:\Users\Archi\Documents\Claude Cowork Homebase C\repos\Siren-s-Song` (checkout on `main` is stale; read live refs with `git show origin/<ref>:<path>`; set `MSYS_NO_PATHCONV=1` for paths starting with `.`).
- Git identity for every commit: `user.email 272409536+pemunson90-cmd@users.noreply.github.com` (other emails are rejected on push). Claude commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Edit this branch from a scratch worktree: `git worktree add --detach <tmp> origin/codex/handoffs`, edit, commit, `git push origin HEAD:codex/handoffs` (on rejection: fetch, rebase own unpushed commit, push). Write multi-line edits as Python script files, not heredocs with apostrophes (Git Bash parses them badly).
- Godot 4.6.3 local checks (PowerShell, from a worktree root, isolated per lane): `$env:ARTIFACT_DIR='C:\Users\Archi\.cache\sirens-song-toolchain\artifacts\<lane>'; powershell -NoProfile -ExecutionPolicy Bypass -File scripts\toolchain\win\headless.ps1 -Action Import -Isolate -UserDataRoot 'C:\Users\Archi\.cache\sirens-song-toolchain\isolated-<lane>'`, then `-Action Core`, `-Action Script -Script <suite> -Prefix <PREFIX>`. Registry: `python -I scripts\toolchain\check-suites.py`. Never run the full list locally.
- Shared files: insert suite rows, MODULES/RESUME rows and validator registrations next to related rows, not at the end, so parallel merges do not collide. Each lane gets its own rank block in `game/tests/suites.txt`.
- Launch Codex headless (when Codex is idle and OPEN handoffs exist): `C:\Users\Archi\AppData\Local\OpenAI\Codex\bin\<hash>\codex.exe exec -m gpt-6.1-sol -c model_reasoning_effort="medium" -C "C:\Users\Archi\Documents\Codex\2026-10-24\you-are-codex-the-implementation-worker\sirens-song" -` with prompt A of START_PROMPTS.md on stdin, via PowerShell `Start-Process -WindowStyle Hidden`, logs to a scratch folder. Check first that a codex-root desktop session is not already driving the queue (board banner time, `~/.codex/logs_2.sqlite-wal` mtime).
- Pat's phone tracker: https://claude.ai/artifact/Hheokf875FPPRczT18SnrB (Dashboard). To refresh: rebuild the rows JSON (order, task, area, owner, status, pr, note) from BOARD.md, upload it as an asset (Artifact publish `asset: true`, `url` above), then ArtifactData `update` datasets/tasks `source.url` + `updated` with the document's current version.

## 8. Restart checklists

**Claude:** run `date`; read memory; `git fetch origin`; read this file, the BOARD banner (top 5 entries), the top entry of USER_DIRECTIVES on integration; `gh pr list --state open`; `git worktree list`. Evaluate: what merged, what is red, who holds what. Then: merge green PRs you own; handle section 3's next action; refresh the tracker; write handoffs so Codex has at least four eligible OPEN items; ask Pat at most one pending question. No new subagents until Pat says so.

**Codex:** follow prompt A (or C for a blank cloud chat) in START_PROMPTS.md, which now reads this file first. Work only on handoffs CLAIMED by codex or OPEN and eligible; leave Claude-claimed lanes to Claude unless the banner says Claude is away.
