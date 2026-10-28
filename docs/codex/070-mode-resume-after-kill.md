# Handoff 070: EXPEDITION AND CAREER DIVE RESUME AFTER APP KILL

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 056 is DONE (career half after 057). Scout note: 056 DONE; 057 DONE for the career half. The expedition half can ship alone. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Give the expedition and career sidecar archives an optional 'active' field. It holds a Simulation snapshot, the mode context (run seed and node, or contract id and riders) and a launch id. Save it on the same autosave cadence the campaign uses. On mode entry, show 'Resume dive' if the snapshot validates. If it fails validation, show a truthful 'Could not restore, run kept at last checkpoint' message, never a crash or silent reset. Add an explicit Abandon option that applies the same loss or contract-fail outcome as a normal loss. Once-only settlement must still hold (economy.gd settle keys on the launch id), so a resumed dive cannot pay twice. Reuse Simulation.valid_snapshot, the SaveStore atomic write and .bak recovery pattern, and the existing cold-restart test idiom from the SAVE2/profile suites.

Spec basis: CURRENT_GAME_SPEC.md: "All modes share operation systems; their resources/story state remain separate"; "truthful recovery/error flows"; "validate lifecycle, resize and audio focus" on Android-first hardware.
Evidence it is missing: The campaign persists a mid-dive snapshot (`active`, validated in persistence/save_store.gd via Simulation.valid_snapshot, resumed by 'RESUME DIVE' in presentation/flow/campaign_flow.gd). The challenge session deliberately does not (challenge_session.gd overrides _load_archive and _save_archive to pass). Handoffs 056 and 057 copy the challenge sidecar precedent and say nothing about an active dive. If Android kills the process mid-operation, a roguelite expedition run is lost, or an unrecorded career contract is silently voided with no recovery message.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-mode-resume

## Files you may edit
New campaign/runs/run_active.gd (and later campaign/career/career_active.gd or a shared mode_active.gd); presentation/runs/run_session.gd; sidecar archive validators in persistence/profiles/* file sets. Tests: new mode_resume_tests (snapshot round trip, corrupt snapshot falls back, single settlement after resume).

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
