# Handoff 053: REGIONAL PRESENTATION, ambience, palette/lighting, dynamic range

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 050 is DONE (soundscape.gd is free). If 052 is OPEN and eligible, take 052 first. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Today every region sounds and looks the same: one global ambience.wav set once, one shared ocean texture and grid. Make the six regions (Corran Bank shelf, Divergence deep/shelf, Confluence, Glass Reach, Iron Choir, Calder Trench) feel like different places.
1. Region ambience: one bed per region, swapped at mission start through the existing Soundscape path, from a table mapping region to stream and gain. Use the existing generated-audio approach or license-clean sources; credit any CC-BY in Soundscape.ATTRIBUTION.
2. Region look: a table of per-region water tint, light falloff, particulate and terrain palette applied through the ART1 renderer and ocean_view. Readability first: threats, contacts and touch targets stay as clear as today on both Fold7 shapes.
3. Dynamic range: a "Night mode" option that compresses the Master bus (today only a fixed peak limiter exists). Claude owns settings_store.gd; append your one key as an append-only change and note it in Completion.
Every table has an enabled switch that restores today's behavior.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-regional-presentation

## Files you may edit
audio/soundscape.gd and a new audio region table/assets; presentation/art/*; region drawing in presentation/ocean_view.gd and presentation/confluence_world.gd; one appended settings key and its settings row; shared append-only files; one MODULES.md row and one RESUME bullet.

## Files you must not touch
Claude-owned files except the single settings key, protected mechanics, HUD layout.

## What done looks like
Each region has its own sound and look, switchable off, nothing harder to read. CI green.

## Checks
Import and core. No new suites unless a save field is added.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
