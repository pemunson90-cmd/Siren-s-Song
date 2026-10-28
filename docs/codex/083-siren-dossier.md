# Handoff 083: Add a Siren dossier: what each of the eight roles does and how to counter it, unlocked by what the player has seen or studied

Status: CLAIMED
Claimed at: 2026-10-28 03:32:23 UTC
Claimed by: codex-root-parallel
Finished at:

Precondition: 062 is DONE. Scout note: Handoff 062 (research/archive/credits) merged, so the archive entry point exists. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Build a data-driven SIREN DOSSIER screen.
1. One row per role, shown once the role is in first_siren_types or has a siren_<type> intel entry. Show the best photo quality if studied.
2. Each row has at most three 1 to 2 line placeholder lines: what it does, its observable tell, and the counterplay tools that exist for it (cover, decoy, EMP, torpedo, silence, band change). Source them only from rules already public in play, such as the 4 s lock warning, windup noises and sweeper-has-no-sonar. Never show hidden values.
3. Add one entry button from Operations home and the archive, 48 dp, with Android Back handling and a text equivalent for any glyph.
4. Unseen roles show a locked silhouette with no text.

Spec basis: CURRENT_GAME_SPEC: "Differentiate sensing, movement, coordination, attacks and counterplay"; "Concise briefs and own-state/received-evidence context teach decisions in play"; "fitting/research/archive".
Evidence it is missing: The player's only description of a Siren role is a contact label from presentation/contact_feedback.gd (HUNTER, GUARD, SWEEPER, LISTENER, RELAY, INTERCEPTOR, WARDEN) plus the one-time first-Siren cue. Two role-knowledge records already exist with no player-facing page: saved first_siren_types in first_siren_cue/cue_archive.gd, and siren_<type> photo-intel keys (photo_capture SIREN_TYPES, photo_intel.keys). The only consumers of siren_* intel are the endings_photo count and the plain intel list in photo_review.gd. The handoff 062 archive view does not list Siren roles, and 061 covers messages and logs only. The Field Manual is per operation and does not describe roles.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-siren-dossier

## Files you may edit
new game/src/presentation/siren_dossier/* (view and table), game/src/presentation/ops_home/ops_home.gd (one entry line), game/src/campaign/archive_recap.gd or the 062 archive view (one entry line)

## Files you must not touch
No mechanics change and no new Siren tuning. Do not display alert_floor or readiness values. Do not reveal roles the player has not seen or studied. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Presentation table only. Optional: one check that a locked role shows no text. No new save field, since both sources are existing saved data. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Ownership note:058 currently owns menu focus flags. Build standalone dossier and archive entry now; do not edit ops_home.gd until058 releases it. Coordinate that final one-line entry after058 lands, or leave it documented for root. Earlier eligible files overlap active owners; this task is independent after062.
