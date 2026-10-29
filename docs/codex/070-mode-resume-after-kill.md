# Handoff 070: EXPEDITION AND CAREER DIVE RESUME AFTER APP KILL

Status: DONE (codex-root; PR211 merged044dd3bc)
Claimed at: 28 Oct 2026 (root retained)
Claimed by: codex-root; claude/lane-mode-resume; PR211
Finished at: 28 Oct 2026 (root closeout)

Precondition: 056 is DONE (career half after 057). Scout note: 056 DONE; 057 DONE for the career half. The expedition half can ship alone. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Give the expedition and career sidecar archives an optional 'active' field. It holds a Simulation snapshot, the mode context (run seed and node, or contract id and riders) and a launch id. Save it on the same autosave cadence the campaign uses. On mode entry, show 'Resume dive' if the snapshot validates. If it fails validation, show a truthful 'Could not restore, run kept at last checkpoint' message, never a crash or silent reset. Add an explicit Abandon option that applies the same loss or contract-fail outcome as a normal loss. Once-only settlement must still hold (economy.gd settle keys on the launch id), so a resumed dive cannot pay twice. Reuse Simulation.valid_snapshot, the SaveStore atomic write and .bak recovery pattern, and the existing cold-restart test idiom from the SAVE2/profile suites.

Spec basis: CURRENT_GAME_SPEC.md: "All modes share operation systems; their resources/story state remain separate"; "truthful recovery/error flows"; "validate lifecycle, resize and audio focus" on Android-first hardware.
Evidence it is missing: The campaign persists a mid-dive snapshot (`active`, validated in persistence/save_store.gd via Simulation.valid_snapshot, resumed by 'RESUME DIVE' in presentation/flow/campaign_flow.gd). The challenge session deliberately does not (challenge_session.gd overrides _load_archive and _save_archive to pass). Handoffs 056 and 057 copy the challenge sidecar precedent and say nothing about an active dive. If Android kills the process mid-operation, a roguelite expedition run is lost, or an unrecorded career contract is silently voided with no recovery message.

## Base and branch
Base: accepted152111a1. Active worktree: Siren-s-Song-codex-070; branch: claude/lane-mode-resume

## Files you may edit
New campaign/runs/run_active.gd (and later campaign/career/career_active.gd or a shared mode_active.gd); presentation/runs/run_session.gd; sidecar archive validators in persistence/profiles/* file sets. Tests: new mode_resume_tests (snapshot round trip, corrupt snapshot falls back, single settlement after resume).

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: mode_resume_tests EXACT local318 / CI418, root checked against accepted and pending100/095/101 registries (supersedes tentative419).

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Current status
DONE PR211 head fede2d1192ffd95b8b942372fab053c4e0caba40; all seven required checks SUCCESS40809465805; merged044dd3bcc3170ebaefd45d3216808fbe7751e598. Root verified fresh head/checks and exact merge tree b410 before merge; source reviews52/55 and final mechanical60A b410 approved before commits. Paused Expedition/Career preserve actual resources, Rider counters, pinned candidate, once-only settlement, records and DEV isolation; source-focused201/0, console274/0, records125/0. No actual Android process-kill or human acceptance claim. 070-owned archives released subject to current claims; 097 candidate already includes070 fede.

## Completion
- PR211 merged044dd3bcc3170ebaefd45d3216808fbe7751e598; reviewed headfede2d1192ffd95b8b942372fab053c4e0caba40, all7 SUCCESS40809465805.
- Source52/55 and final mechanical60A b410 approved before commits; root verified exact merge tree before merge.
- Paused Expedition/Career preserve resources, Rider counters, pinned candidate, once-only settlement, records and DEV isolation.
- Source-focused201/0, console274/0, records125/0; actual Android process kill and human acceptance remain unclaimed.
- Owned archives released subject to current claims;097 candidate already includes070 fede; root continues097 then090/091.
