# Handoff 056: C3 MODES: mode select, campaign rename, seeded expeditions

Status: CLAIMED
Claimed at: 2026-10-28 09:32:33 UTC
Claimed by: codex-root-queue
Finished at:

Precondition: 054 and 055 are DONE. Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
1) Rename player-facing EXPEDITION(S) strings in the post-tutorial campaign (presentation/expedition_operations.gd, ops_home, expedition_view) to OPERATIONS / CAMPAIGN wording; do NOT rename code ids or save keys. 2) A mode-select screen between START GAME and new campaign (Campaign, Challenges, Expeditions; Career disabled until 057). 3) Seeded roguelite expeditions: a run of 3 to 6 operations drawn from existing operation factories (OperationCatalog.make) with a seed choosing sequence and run modifiers (starting loadout, resource scarcity, starting Hunt stage within caps); the run ends on loss; separate resources and story state in its own sidecar archive (follow the challenge_session.gd and challenge archive precedent); profile and SAVE2 aware. No new enemy rules.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c3-modes

## Files you may edit
presentation/frontend/*, presentation/ops_home/*, presentation/expedition_*.gd strings, campaign/expedition_campaign.gd strings, new campaign/runs/* and presentation/runs/*, main.gd flow hooks, persistence/profiles/* and save_states/* file sets; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 370-379, CI 470-479.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
Implementation pushed: e18ab971, PR175 into claude/integration; CLAIMED pending root's hosted gate/merge.
Mode selector; seeded3–6 opening recon operations, finite carried tools, capped Hunt, run loss, profile-pinned sidecar; campaign/SAVE2 and079 isolated.
Godot4.6.3 import/core848/0, run65/0, staged session12/0, profiles75/0; guidance/diff pass; isolated userdata/logs.
084/PR172 still open: root reconciles landed integration before final hosted gate; no CI polling or057 claim.068–071 remain followups.
MODULES/RESUME corrected. No files outside056 ownership; main.gd lifecycle guard only.075 must preserve new .runs profile suffixes/validation and legacy4-file package normalization.
