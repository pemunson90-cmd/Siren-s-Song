# Handoff 073: Performance and battery tier: Low-effects quality setting, auto frame-time governor, and paused/idle redraw throttle

Status: OPEN
Claimed at: 
Claimed by: 
Finished at:

Precondition: 058 and 063 are DONE. Scout note: 058 (frame-rate setting) landed so settings_store and frontend_settings are not double-owned; ideally 063 (performance pass) before or after, with no overlap on ocean_view draw code. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Add a QUALITY setting (STANDARD / LOW EFFECTS) to the saved settings, defaulting to STANDARD for old settings files. LOW EFFECTS turns off, through one table of named switches, the purely decorative draw layers: regional dust drift, set-dressing inhabitants (if gap 19 has landed), extra glow passes and ambient shimmer. It never changes simulation, sensing, captions or any evidence the player needs.
Add a small frame-time governor that watches a rolling average. After about 10 seconds above the 30fps budget it shows one dismissible line suggesting LOW EFFECTS and does nothing silently. It must be a no-op in headless runs.
Add an idle throttle. When the sim is paused or a menu is up, redraw only when something changed (camera, selection, order, animated overlay) or at a low heartbeat of about 10Hz. Use an OS.low_processor_usage_mode style cap or a dirty flag in ocean_view and main._refresh. Resuming must restore full rate on the next frame, and gesture latency while paused must not change.
Register one line in the Display page of Settings (gap 17, or the current single page).

Spec basis: Settings cover ... performance. ... Target 60fps on supported modern Android hardware with a usable 30fps fallback (Approved full-release expansion, last two bullets).
Evidence it is missing: settings_store.gd DEFAULTS has only master/music/effects/text_scale/high_contrast/reduced_motion/haptics/safe_palette/audio_captions/night_mode, with no quality or effects tier. git grep for low_effects, quality_tier, adaptive and low_processor over origin/claude/integration game/src and project.godot finds nothing. presentation/ocean_view.gd _process() (line 145) calls queue_redraw() on every frame unconditionally, and main.gd _process calls _refresh() every frame, including while the sim is paused (the spec's long planning pauses) and on menus. 058 adds only a 60/30 Engine.max_fps cap, and 063 only profiles and fixes hot spots. Neither gives a device that misses 30fps a way to shed cost, and gaps 14 and 19 add more per-frame draw load.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-quality-tier

## Files you may edit
New game/src/presentation/quality/quality_table.gd, quality_governor.gd and quality_tests; small edits to persistence/settings_store.gd (additive key, sanitize defaults), presentation/frontend/frontend_settings.gd, presentation/ocean_view.gd (_process redraw gate), presentation/art/region_renderer.gd (consume switches), main.gd (_refresh gate).

## Files you must not touch
Any simulation, sensing, Hunt or photo-rule change. Hiding evidence or captions in LOW EFFECTS. Silent automatic downgrades. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Settings round-trip with the key absent and present. A paused-scene redraw-count probe shows fewer than 15 redraws per second while paused. Simulation state hashes are identical before and after in a matched 60-second scenario. Cover and inner viewport touch checks pass with LOW EFFECTS on. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
