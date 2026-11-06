---
folder: sirens-song/
purpose: routing index for the Siren's Song daisy-chain build project
last_updated: 2026-06-05
status: STEP 9 RE-FIRE **AUDIT YELLOW** (2026-06-05 ~23:50 UTC). First Step 9 build delivered truncated file — RED — rolled back. RE-FIRE applied all 4 ratified pulls cleanly via atomic Python patch; all 5 hardened completion gates PASS. Re-fire audit verdict YELLOW: patch lands; all 4 pulls structurally present; INV5 strengthened; no regressions; `isLineOfSightClear` + `applySuspicion` byte-equivalent to baseline; 73→80 `__sim` entries (strict superset). Two documented deferrals: Flag A (`AU.beat` HOSTILE-entry seam not wired — minor) and Flag B (noise→Siren investigate write-through deferred — substantive; noise math computed but not consumed by AI). Recommend Option 1: Pat playtest current build, queue Step 9b later. File: 147,438 B / 3,462 lines / md5 `477469ef51d2a0876df13d009e7cd610`. Steps 1–8 remain GREENLIGHT; `pre-step9-20260605` backup (md5 `9e6d673b4bcc3e8a82a100f414ef0557`) is still the canonical Step-8-closed playable.
authority: SIRENS_SONG_SPEC.md is canonical (v0.2 on disk; v0.3 in inbox pending Pat ratification); agent.md is operating doc; PROJECT_CONTEXT.md is cold-instance pickup briefing; this is the router
---

# Siren's Song — Routing Index

Read this first if you're cold and have landed in this folder. Don't grep. Find your intent below.

## What this project is

A daisy-chain build of **Siren's Song** — a 2D top-down stealth game where the player pilots a zero-kill US sub into an alien deep-sea factory, photographs it, and gets out. Sirens are unkillable; the suspicion meter is the spine. Function-before-form prototype.

Pat ratified the daisy-chain orchestration approach 2026-06-03. Phase 1 (scaffold) is complete. Phase 2 (build agents) spawns from a separate orchestrator task.

## Read first if you're cold

If you want... | Path
---|---
**Cold-instance pickup briefing (read this first)** | `PROJECT_CONTEXT.md` *(2026-06-05)*
The canonical functional spec (single source of truth) | `SIRENS_SONG_SPEC.md`
**Step 9 spec patch (sidecar; canonical spec EPERM-locked during build)** | `SIRENS_SONG_SPEC_STEP9_PATCH.md` *(2026-06-05)*
Operating doc for any step-agent (mandate, invariants, sim-test capability) | `agent.md`
Operating doc for the auditor (verification methodology) | `briefs/AUDITOR_BRIEF.md`
**Inbox comparison — claude.ai parallel build** | `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` *(2026-06-05)*
**Step 9 brief — v0.3 pull-ins ratified by Pat in claude.ai-space** | `briefs/09_v03_pullin_patch.md` *(2026-06-05)*
**Step 9 RE-FIRE handoff — clean build, 5 hardened gates PASS** | `handoffs/09_HANDOFF_FROM_STEP9.md` *(2026-06-05, REWRITTEN 23:22 UTC)*
First Step 9 audit (RED — truncated file, rolled back) | `audits/09_AUDIT_STEP_09.md` *(2026-06-05)*
**Step 9 RE-FIRE audit (YELLOW — patch lands; 2 documented deferrals)** | `audits/09_AUDIT_STEP_09_REFIRE.md` *(2026-06-05)*
Today's Dispatch session log | `SESSION_NOTES_20260605.md` *(2026-06-05)*
Genre + monetization research (off-chain) | `research/GENRE_AND_MONETIZATION_RESEARCH.md` *(2026-06-05)*

## If you're spawning as a step-agent

Read in this exact order:

1. `SIRENS_SONG_SPEC.md` — the spec
2. `agent.md` — your operating envelope
3. `briefs/NN_<your step>.md` — your assignment
4. `handoffs/NN-1_<previous slug>.md` — what you inherit (skip if step 1)
5. `audits/NN-1_AUDIT_STEP_NN-1.md` — previous step's verdict (skip if step 1)
6. `code/sirens_song.html` — current code state (skip if step 1)

Then build. Then write `handoffs/NN_<your slug>.md`. Then stop.

## If you're spawning as the auditor

Read in this exact order:

1. `SIRENS_SONG_SPEC.md` — the spec
2. `briefs/AUDITOR_BRIEF.md` — your operating doc
3. `briefs/NN_<step being audited>.md` — what the step was supposed to do
4. `handoffs/NN_<step slug>.md` — what the step-agent claims they did
5. `code/sirens_song.html` — current code state

Then verify (read + sim test). Then write `audits/NN_AUDIT_STEP_NN.md`. Then stop.

## Build steps (briefs/)

If you want... | Path
---|---
Step 1: sub movement + sonar + terrain + hull + oxygen | `briefs/01_sub_sonar_terrain.md`
Step 2: suspicion meter + Patroller + 4 thresholds + warning valve | `briefs/02_suspicion_patroller.md`
Step 3: drones + sub fallback cam + photo objectives + win/lose | `briefs/03_drones_camera_objectives.md`
Step 4: Sentinel + Hunter + curiosity/decoy | `briefs/04_sentinel_hunter_curiosity.md`
Step 5: disruption tools (jam / EMP / knockdown) | `briefs/05_disruption_tools.md`
Step 6: recon call-in | `briefs/06_recon_call_in.md`
Step 7: tuning pass (originally last step per spec) | `briefs/07_tuning_pass.md`
Step 8: mobile controls + responsive layout (extension, Pat-ratified post-Step-7) | `briefs/08_mobile_controls.md`
Step 9: v0.3 pull-in patch (EMP kill-rule + shadow cones + procedural Web Audio + speed-as-noise + silent running) | `briefs/09_v03_pullin_patch.md`
Auditor brief (post-step verification) | `briefs/AUDITOR_BRIEF.md`

## Working folders

If you want... | Path
---|---
Step-agent handoff READMEs (one per completed step) | `handoffs/` — `01_HANDOFF_FROM_STEP1.md` + `02_HANDOFF_FROM_STEP2.md` + `03_HANDOFF_FROM_STEP3.md` + `04_HANDOFF_FROM_STEP4.md` + `05_HANDOFF_FROM_STEP5.md` landed 2026-06-04. Step 1 fix-pass handoff at `01_FIXPASS_HANDOFF_20260604.md` (LOS occlusion + sub inertia per Pat 2026-06-03 diagnostic notes).
Auditor reports (one per completed step) | `audits/` — `01_AUDIT_STEP_01.md` GREENLIGHT + `02_AUDIT_STEP_02.md` GREENLIGHT + `03_AUDIT_STEP_03.md` GREENLIGHT (combined step 3 + step 1 fix-pass) + `04_AUDIT_STEP_04.md` GREENLIGHT 2026-06-04; step 5 audit pending
The single build artifact | `code/sirens_song.html` (97,702 bytes / 2,322 lines; step 5 layered onto step 1+2+3+4 + step 1 fix-pass substrate 2026-06-04). Backups: pre-step-5 at `code/sirens_song.html.bak.pre-step5-20260604` (79,522 bytes); pre-step-4 at `code/sirens_song.html.bak.pre-step4-20260604` (55,234 bytes); pre-fix-pass at `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes); pre-step-3 at `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes).
Genre + monetization research (post-Step-8, off-chain) | `research/GENRE_AND_MONETIZATION_RESEARCH.md` — 5-section research deliverable on genre placement, IP-safe mechanic borrows, title/aesthetic risk, monetization paths, and survival check. Authored 2026-06-05 by Cowork research agent. 25+ sources cited.

## 2026-06-05 close-out artifacts (project promotion)

| Artifact | Path | Bytes |
|---|---|---|
| Smoke test harness | `smoke_test.js` | ~19 KB |
| Smoke test run log | `smoke_test_run_20260605.log` | ~3 KB — VERDICT: SAFE TO PLAYTEST |
| Genre + monetization research | `research/GENRE_AND_MONETIZATION_RESEARCH.md` | 59 KB — 5 sections, 25+ sources |
| Inbox folder (claude.ai parallel track) | `Inbox_from_Claude.ai/Siren's Song claude web/` | ~125 KB — spec v0.3 + dev notes + pressure design + 2 prototypes |
| **Inbox comparison analysis** | `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` | ~7,200 words — convergence/divergence + pull-ins |
| **Cold-instance project context** | `PROJECT_CONTEXT.md` | ~5,400 words — 11 sections, project canon |
| **Today's session notes** | `SESSION_NOTES_20260605.md` | ~3,600 words — chain timeline + decisions |

## Build progress

| Step | Status | Handoff | Audit |
|---|---|---|---|
| 01 sub/sonar/terrain | COMPLETE 2026-06-04; FIX-PASS 2026-06-04 (LOS occlusion + sub inertia) | `handoffs/01_HANDOFF_FROM_STEP1.md` + `handoffs/01_FIXPASS_HANDOFF_20260604.md` | `audits/01_AUDIT_STEP_01.md` GREENLIGHT; fix-pass regression audit pending |
| 02 suspicion/Patroller | COMPLETE 2026-06-04 | `handoffs/02_HANDOFF_FROM_STEP2.md` | `audits/02_AUDIT_STEP_02.md` GREENLIGHT |
| 03 drones/cam/objectives | COMPLETE 2026-06-04 | `handoffs/03_HANDOFF_FROM_STEP3.md` | `audits/03_AUDIT_STEP_03.md` GREENLIGHT (combined with step 1 fix-pass regression) |
| 04 Sentinel/Hunter/curiosity | COMPLETE 2026-06-04 | `handoffs/04_HANDOFF_FROM_STEP4.md` | `audits/04_AUDIT_STEP_04.md` GREENLIGHT |
| 05 disruption tools | COMPLETE 2026-06-04 | `handoffs/05_HANDOFF_FROM_STEP5.md` | `audits/05_AUDIT_STEP_05.md` GREENLIGHT |
| 06 recon call-in | COMPLETE 2026-06-04 | `handoffs/06_HANDOFF_FROM_STEP6.md` | `audits/06_AUDIT_STEP_06.md` GREENLIGHT |
| 07 tuning pass | COMPLETE 2026-06-04 | `handoffs/07_HANDOFF_FROM_STEP7.md` | `audits/07_AUDIT_STEP_07.md` GREENLIGHT |
| 08 mobile controls (extension) | COMPLETE 2026-06-04 | `handoffs/08_HANDOFF_FROM_STEP8.md` | `audits/08_AUDIT_STEP_08.md` GREENLIGHT |
| 09 v0.3 pull-in patch (kill-rule + shadow cones + audio + speed-noise/silent) | First attempt BUILT 2026-06-05 — **AUDIT RED (rollback)** — file truncated mid-comment. | `handoffs/09_HANDOFF_FROM_STEP9.md` (REWRITTEN) | `audits/09_AUDIT_STEP_09.md` **RED — ROLL BACK** |
| 09 RE-FIRE same scope, hardened gates | COMPLETE 2026-06-05 23:22 UTC — all 5 hardened build gates PASS. Audit verdict **YELLOW**: 4/4 pulls structurally present + sim-verified; INV5 strengthened (kill-rule now perception-AND-time); no regressions; `isLineOfSightClear`+`applySuspicion` byte-equivalent; 73→80 `__sim` superset. Flag A `AU.beat` HOSTILE-entry seam not wired (minor). Flag B noise→Siren investigate write-through deferred (substantive — noise math is computed and exposed but not consumed by AI). Recommend Option 1: Pat playtest current build; queue Step 9b later. | `handoffs/09_HANDOFF_FROM_STEP9.md` (REWRITTEN with integrity certifications) | `audits/09_AUDIT_STEP_09_REFIRE.md` **YELLOW** |

Chain close: Steps 1–7 completed 2026-06-04 14:58 UTC (`ORCHESTRATOR_COMPLETE.md`). Step 8 extension (mobile controls + responsive layout) completed 2026-06-04 17:48 UTC (`ORCHESTRATOR_COMPLETE_STEP8.md`). Step 9 v0.3 pull-in patch (post-leash ratification) built 2026-06-05 but delivered as a truncated file — audit verdict **RED — ROLL BACK**. Steps 1–8 remain GREENLIGHT and the Step 8 closed state (`.bak.pre-step9-20260605`, md5 `9e6d673b4bcc3e8a82a100f414ef0557`) is the canonical playable build until Step 9 re-fires successfully. Ready for Pat playtest off the Step 8 build; Pat decides whether to re-fire Step 9 or hold the pull-ins.

## Key rules at a glance

- `SIRENS_SONG_SPEC.md` is the single source of truth. Do not paraphrase, fork, or rewrite.
- Six invariants are in `agent.md` §2 verbatim. Any code that violates one is wrong by definition.
- One step-agent per §11 numbered step. Stop at the seam.
- Auditor verifies, doesn't modify code.
- Node.js sim testing is encouraged for step-agents and required for the auditor.
- Implementation is Cowork's call; game design is the spec's call; design improvements are handoff notes, not implementations.
- Function before form. No art or sound until tuning passes.

## Scaffold provenance

Scaffold task completed 2026-06-03 (re-fired after prior task hit a spec-not-accessible block; prior `SETUP_BLOCKED.md` archived to `_scrap-20260603/SETUP_BLOCKED_sirens-song.md`).

All 10 scaffold files written:

- `SIRENS_SONG_SPEC.md` (copied verbatim from attached spec)
- `agent.md`
- `briefs/01_sub_sonar_terrain.md`
- `briefs/02_suspicion_patroller.md`
- `briefs/03_drones_camera_objectives.md`
- `briefs/04_sentinel_hunter_curiosity.md`
- `briefs/05_disruption_tools.md`
- `briefs/06_recon_call_in.md`
- `briefs/07_tuning_pass.md`
- `briefs/AUDITOR_BRIEF.md`
- `claude_index.md` (this file)

Empty working directories created: `handoffs/`, `audits/`, `code/`.

Status: **READY FOR ORCHESTRATOR**. Phase 2 (build agents) spawns separately.
