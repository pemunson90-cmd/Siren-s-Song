# Handoff 058: C5 SETTINGS GAPS: controller focus, frame rate

Status: DONE
Claimed at: 2026-10-28 02:23:59 UTC
Claimed by: codex-root-parallel
Finished at: 2026-10-28 06:52:18 UTC

Precondition: no CLAIMED handoff currently owns presentation/frontend/*. Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Add controller/keyboard focus navigation for menus (buttons are FOCUS_NONE today) without hurting touch, and a frame-rate setting (60 / 30 cap) applied via Engine.max_fps. Touch stays primary.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c5-settings

## Files you may edit
persistence/settings_store.gd, presentation/frontend/frontend_settings.gd and the settings screen, focus flags in menu builders; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 390-394, CI 490-494.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Verified closeout28Oct06:53UTC: PR163 mergedaef173ac; heada8a0a88a both checks green40637057079. Ownership released. Root collects semantic reconciliation and next eligible work.
