# MINING_REPORT: homebase-sirens-song-2026-06

Prepared 2026-11-05 by a mining subagent for Pat. Report only. Nothing in this folder is active authority (promotion policy E-20261026-017). No file here was modified, moved or deleted. This report is the only new file.

Method: comparison against the current Siren repo (Godot 4.6.3, Android-first, `docs/CURRENT_GAME_SPEC.md`, `docs/SOURCE_AUTHORITY.md`, `reference/original-prototype`, `V7_TO_GODOT_PARITY.md`, MANIFEST hashes) using CR-stripped md5 and grep. Build contents were checked with grep and headers, not by reading all 3,462 lines.

## 1. What is here

66 files, about 2 MB.

- `code/sirens_song.html`: the Cowork daisy-chain build, a single-file HTML/Canvas game made in nine steps. Final size 147,438 bytes, 3,462 lines, md5 477469ef51d2a0876df13d009e7cd610. Backups of earlier steps sit beside it.
- Per-step documents: `briefs/01` to `09` plus `AUDITOR_BRIEF`, `handoffs/01` to `09`, `audits/01` to `09` (including `09_REFIRE`).
- `SIRENS_SONG_SPEC.md` (v0.2) and `SIRENS_SONG_SPEC_STEP9_PATCH.md`.
- `PROJECT_CONTEXT.md`, `SESSION_NOTES_20260605.md`, `ORCHESTRATOR_*` logs, `agent.md`, `claude_index.md`.
- `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md`, `research/GENRE_AND_MONETIZATION_RESEARCH.md`.
- Tests: `smoke_test.js` plus log (jsdom, verdict SAFE TO PLAYTEST), `tmp_audit_step6/` harnesses, `_step9_refire_patch.py`.
- `Inbox_from_Claude.ai/Siren's Song claude web/`: v0.3 spec, dev_notes, pressure_design, `sirens_song_prototype.html` (v6), `sirens_song_prototype_v7.html`.

### Build chain and what each step adds

| Step | Size at close (bytes) | Adds |
|---|---|---|
| 1 | 41,825 (pre-step1-fixpass backup) | Sub, passive sonar, active ping, terrain, hull, oxygen. Fix-pass: LOS occlusion and sub inertia. |
| 2 | 23,523 (step2 backup, order versus step 1 sizes unclear) | Suspicion and Patroller with the fairness valve. |
| 3 | 55,234 (pre-step4 backup) | Drones, camera, objectives. |
| 4 | 79,522 (pre-step5 backup) | Sentinel and Hunter with curiosity. |
| 5 | 97,702 (pre-step6 backup) | Jam, EMP, Knockdown. |
| 6 | 110,327 (pre-step7 backup) | Recon call-in. |
| 7 | 112,450 | Tuning: oxygen 210 s, Hunter 75 px/s, recon radius 460, HOSTILE label. |
| 8 | 135,266 | Mobile controls: joystick plus tray. |
| 9 (re-fire) | 147,438 | EMP kill-rule, shadow cones, procedural Web Audio, speed-as-noise with silent running. Audit verdict YELLOW. |

Size-to-step mapping is inferred from backup file names (the pre-stepN backups are the state before step N). The first Step 9 build was truncated and rolled back after a RED audit; the pre-step9 and pre-step9-refire backups are both 135,266 bytes. `claude_index.md` still quotes older sizes (97,702 bytes) in places.

Step 9 deferrals: `AU.beat()` is unbound, and noise-to-investigate write-through is missing.

## 2. Unique value worth promoting

1. **Tuning table of about 90 constants** (`handoffs/07_*` and `handoffs/08_*`). The repo carries the functional spec but I found no equivalent constants table. Useful as a balance baseline for the Godot port, subject to the Godot build's own tuning.
2. **Stationary-sub finding** (`audits/07_*`). A literally stationary sub hull-sinks at about 8.4 s instead of vaporizing. A rules edge case the repo spec does not mention.
3. **Mobile control lessons** (`handoffs/08_HANDOFF_FROM_STEP8.md`, mobile potholes and improvement notes). Includes a 22 vmin button sizing risk. Relevant to an Android-first port.
4. **Step 9 audit trail** (`audits/09_*`, `SIRENS_SONG_SPEC_STEP9_PATCH.md`, `_step9_refire_patch.py`). Records the truncated-build rollback and the re-fire. Process value: a big single-file patch can truncate, and the audit caught it.
5. **Orchestration lessons** (`SESSION_NOTES_20260605.md`, `ORCHESTRATOR_*`). How the nine-step daisy chain with build, handoff and audit per step behaved, and where it failed.
6. **Cowork versus claude.ai comparison** (`research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md`): pull-in ranking and 12 open items. Compares the Cowork build with the claude.ai v7 prototype (HUNT meter, graze damage).
7. **Ratification queue and Pat verbatim quotes** (`PROJECT_CONTEXT.md`): 35 items (19 chain, 12 inbox, 4 genre). Compare against current repo decisions before treating any as open.
8. **Title research** (`research/GENRE_AND_MONETIZATION_RESEARCH.md`): trademark check, Sker Ritual DLC and Voiceless collisions, alternative titles Deep Contact and Aphotic.
9. **Headless `__sim` harness and `smoke_test.js`** (jsdom). A test surface for the HTML build; the six invariants INV1 to INV6 are exercised there. The repo already documents invariants, so the value is the harness itself.
10. **Shadow cones and speed-as-noise with silent running** (`code/sirens_song.html`, step 9). Mechanics I did not find named in the repo docs I searched.

## 3. Superseded or stale

- **Inbox v7 prototype.** `sirens_song_prototype_v7.html` differs from the repo's v7 only in `startGame()`. This copy calls `resize()` before the HUD is shown. The repo copy (md5 e142ae3c5fcc8a6c5758d6b8bae4d614 per its MANIFEST) calls it last. The repo version is the resize-ordering fix, so this copy is the pre-fix variant.
- **Inbox v0.3 spec, dev_notes, pressure_design and v6 prototype** are duplicates of repo reference/original-prototype and the repo history copy.
- **Functional spec coverage.** Recon, jam, valve and invariants are already in the repo, along with `V7_TO_GODOT_PARITY.md` and a source-authority hierarchy.
- **`claude_index.md`** quotes older file sizes.
- **Distribution advice conflicts with the repo.** The genre research recommends itch.io first and no native mobile. The repo is Android-first Godot, and AGENTS.md excludes store and marketing work. Treat the recommendation as historical.
- **Spec v0.2** is older than the spec the Godot repo uses.

## 4. Open questions for Pat

1. Should the nine-step audit trail go to an archive branch such as `archive/homebase-prototype-2026-06`, as the README in this folder proposes and as AGENTS.md prescribes for audit trails?
2. Is the 90-constant tuning table wanted as a reference for the Godot balance pass?
3. Are shadow cones and speed-as-noise with silent running part of the Godot target, or Cowork-only experiments?
4. Which of the 35 ratification items in `PROJECT_CONTEXT.md` are still open?
5. Is the HUNT meter and graze damage from the claude.ai v7 line the intended direction, given the Cowork build went a different way (the comparison file ranks the pull-ins)?
6. Do you want the title alternatives (Deep Contact, Aphotic) kept as a note, given the trademark collisions found?

## Files not read in full

The briefs, individual audits 01 to 08, handoffs 01 to 07 and 09, `smoke_test.js`, and `code/sirens_song.html` (headers, summaries and grep checks only).
