# Plan snapshot for Codex (Claude wrote this 22 Oct 2026; read after README, before any handoff)

## What the game is
Siren's Song: an Android-first 2D tactical submarine STEALTH and PHOTOGRAPHIC RECONNAISSANCE game (Godot 4.6.3, GDScript, game in game/). One vulnerable military recon sub, USS Quietus, plus two drones, investigate the Sirens: superior aliens who were here first, built the factory (their base) and are becoming dangerous. Iron Lung is the model for the camera: photography is the central, recurring, consequential act. Rescue and industrial work (human survivors from drilling and military sites) support it and must not displace it. Unlimited tactical pause, fair information, physical simulation, finite tools. Ops 0 to 29 exist (0 to 5 are the tutorial arc; the target is a much longer branching campaign with upgrades and several endings).

## Who decides what
Pat (owner, not a professional developer) decides how the game feels and any change to combat, detection, damage, hull, story, photography design. Claude is the root orchestrator and merges to claude/integration (Codex may merge only where a handoff says so). Only Pat promotes to gauntlet/production or main. Never build an APK.

## Standing engineering rule (Pat, 22 Oct)
Keep every change as self-contained as possible so it can be changed or reverted without breaking much else. Modular, scalable, upgradeable, consistent, easy to work on, without losing fidelity or competency: new systems in their own files with one narrow documented seam, tunable numbers in data tables, optional validated save fields, tests beside the feature, match the style of surrounding code, no duplicated logic. Report places where existing structure makes this hard instead of working around it.

## Input priority (Pat, 22 Oct)
Primary release target is ANDROID, so everything is touch-first: on-screen controls of at least 48 dp, tap/hold/drag/pinch, the Android back gesture or button as the Escape equivalent, no hover, no keyboard-only paths. Keyboard is a working fallback only. Verify new UI with the real-touch harness at the Fold7 cover and inner shapes, not just keyboard events. (Example: an Escape fix must also work for back.)

## Stable preservation rules
- Preserve beam lethality, the interruptible lock warning, physical collision and fair Siren sight/hearing unless the handoff records Pat's approval to change them. V7-senses sweepers have no sonar of their own.
- Photography is a core pillar. Apply the ratified camera decisions and the exact assigned repair/content scope; capability limitations live in PHOTO_RECON on integration.
- Test inventories and ordering come from `game/tests/suites.txt` on integration. Run focused local checks under README; GitHub owns the full registered matrix. Preserve meaningful assertions and explain stale-fixture corrections.
- No em dashes. Story and briefing text stay 1 to 2 line placeholders. Gameplay, layout and UI come first.

## Current state and ownership
Use docs/RESUME.md on fetched `origin/claude/integration` for the reconciled source baseline and live PR links. Use the live board and each handoff's Status/Completion on `origin/codex/handoffs` for assignment, claim and recovery refs. This document carries no duplicated landed/in-flight list. Earlier dated snapshots are recoverable in Git history. No claim, completion, precondition or queue order is changed by this pointer reconciliation.

## Where to read more (only if your handoff points there)
AGENTS.md, docs/USER_DIRECTIVES.md (current decisions and dated provenance), docs/CURRENT_GAME_SPEC.md, docs/PHOTO_RECON.md and docs/FUTURE_OPTIONS.md. Read these ON claude/integration, not on this branch.
