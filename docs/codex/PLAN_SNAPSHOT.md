# Plan snapshot for Codex (Claude wrote this 22 Oct 2026; read after README, before any handoff)

## What the game is
Siren's Song: an Android-first 2D tactical submarine STEALTH and PHOTOGRAPHIC RECONNAISSANCE game (Godot 4.6.3, GDScript, game in game/). One vulnerable military recon sub, USS Quietus, plus two drones, investigate the Sirens: superior aliens who were here first, built the factory (their base) and are becoming dangerous. Iron Lung is the model for the camera: photography is the central, recurring, consequential act. Rescue and industrial work (human survivors from drilling and military sites) support it and must not displace it. Unlimited tactical pause, fair information, physical simulation, finite tools. Ops 0 to 29 exist (0 to 5 are the tutorial arc; the target is a much longer branching campaign with upgrades and several endings).

## Who decides what
Pat (owner, not a professional developer) decides how the game feels and any change to combat, detection, damage, hull, story, photography design. Claude is the root orchestrator and merges to claude/integration (Codex may merge only where a handoff says so). Only Pat promotes to gauntlet/production or main. Never build an APK.

## Standing engineering rule (Pat, 22 Oct)
Keep every change as self-contained as possible so it can be changed or reverted without breaking much else. Modular, scalable, upgradeable, consistent, easy to work on, without losing fidelity or competency: new systems in their own files with one narrow documented seam, tunable numbers in data tables, optional validated save fields, tests beside the feature, match the style of surrounding code, no duplicated logic. Report places where existing structure makes this hard instead of working around it.

## Input priority (Pat, 22 Oct)
Primary release target is ANDROID, so everything is touch-first: on-screen controls of at least 48 dp, tap/hold/drag/pinch, the Android back gesture or button as the Escape equivalent, no hover, no keyboard-only paths. Keyboard is a working fallback only. Verify new UI with the real-touch harness at the Fold7 cover and inner shapes, not just keyboard events. (Example: an Escape fix must also work for back.)

## Settled rules you must not break
- A fired Siren beam destroys Quietus outright; the 4 s lock warning stays and can be broken; drones die to a beam; collisions cost hull by speed with a cooldown. Do not change these.
- V7 Sirens have no sonar of their own. They sense by proximity plus line of sight, throttle noise (speed squared), and Quietus pings and loud tools. Claude is rebuilding the sweeper on this (handoff 009, branch claude/lane-t2-sweeper).
- Photography is a core pillar; do not change how the camera works. Claude's PHOTO2 builder (branch claude/photo2-images) is making the photograph a real lit image with discovery and consequences.
- Testing: import, core suite (ends CHECKS N FAILURES 0), and only tests for what you touched. Never run the full 73-scenario list locally; GitHub game-smoke (about 25 minutes) is the gate. A Godot "resources still in use at exit" line fails CI. Never skip, loosen or delete a test.
- No em dashes. Story and briefing text stay 1 to 2 line placeholders. Gameplay, layout and UI come first.

## What has landed on claude/integration (22 Oct)
Glass Reach ops 14 to 21; hulls, drones and fitting; sonar and rule fixes; story rewrite to the survivor premise; front end (title, settings, credits); Iron Choir ops 22 to 29; lethal-beam combat and collisions; PHOTO1 (viewpoint-dependent camera, archive, intel, gear); ONBOARD1 (teaching prompts, order confirm and undo, text size, clearer title).

## What is in flight (do not touch these areas)
(22 Oct 17:45 UTC) PR 69 Priced Shots (new photo_pricing folders), the sweeper rebuild (sonar_sweeper.gd, branch claude/lane-t2-sweeper), then depth-band photos and an ARCH1 behavior-preserving refactor of simulation.gd and main.gd. Codex already landed PR 68 (lock warning readability).
PHOTO2 (camera, viewfinder, archive, discovery), SWEEP1 (sweeper and its warning text, plus a tutorial pause on the first Siren warning). Next after those: a "Priced Shots" milestone (finite film, light and distance trades) and a photo depth-band choice, both Claude's.

## Where to read more (only if your handoff points there)
AGENTS.md, docs/USER_DIRECTIVES.md (newest first), docs/CURRENT_GAME_SPEC.md, docs/PHOTO_RECON.md, docs/SESSION_LEDGER_2026-10-21.md, docs/FUTURE_OPTIONS.md. Read these ON claude/integration, not on this branch.
