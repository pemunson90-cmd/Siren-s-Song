# Handoff 072: Settings depth: separate mixer, haptic strength and coverage, gesture timing

Status: CLAIMED
Claimed at: 2026-10-28 09:06:27 UTC
Claimed by: claude
Finished at:

Precondition: 058 and 060 are DONE. Scout note: Handoff 058 (controller focus and frame-rate setting) DONE since it owns settings_store.gd and the settings screen; handoff 060 DONE so the final bus set is known. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Split Settings into three pages: AUDIO, DISPLAY and CONTROLS. AUDIO: Master, Ambience, Alerts and threat cues, Effects and equipment, and Messages/voice (rename 'Music'), each a bus under Master; keep Night mode as the dynamic-range control and add a one-line explanation. CONTROLS: haptic strength (off / light / normal / strong, scaling the pulse length), haptic coverage extended to impact, torpedo launch, extraction and photo shutter; touch drag sensitivity and long-press delay presets. DISPLAY: existing text scale, contrast, motion, palette, captions. All new keys sanitize to defaults so older settings files load unchanged, and RESET restores everything.

Spec basis: 'Settings cover audio buses/dynamic range, text scale, contrast/color alternatives, reduced motion, haptics, controls/controller focus and performance.'
Evidence it is missing: settings_store.gd DEFAULTS has only master, music, effects, text_scale, high_contrast, reduced_motion, haptics, safe_palette, audio_captions, night_mode. 'MUSIC' drives SirenAmbience (ambience plus tension), 'EFFECTS' drives SirenEffects (engine, lock, all cues), so there is no way to turn down threat cues and keep ambience, or the reverse. Haptics is an on/off toggle fired for four cues only ('lock','sweep_received','film_empty','loss') at a fixed PULSE_MS=45 (cue_observer.gd:26, cue_table.gd:8). Gesture constants are fixed: DRAG_THRESHOLD=14 (input/map_gesture.gd) and tool-help HOLD_SECONDS=.5. frontend.gd _settings_screen puts every control in one scroll column. Handoff 058 adds only controller focus and a frame-rate cap.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-settings-depth

## Files you may edit
game/src/persistence/settings_store.gd, presentation/frontend/frontend_settings.gd, presentation/frontend/frontend.gd (settings pages), audio/soundscape.gd (bus names and volume apply only), presentation/accessibility/cue_observer.gd and cue_table.gd (haptic table), input/map_gesture.gd (threshold from setting), presentation/tool_help/tool_help.gd (hold delay).

## Files you must not touch
Do not remove or rename existing settings keys, change tactical pause, or weaken the peak guard on Master. Skip handedness-mirrored layouts unless the owner asks. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import and core. Settings round trip: old settings.json loads with defaults, corrupt new keys fall back, each bus level maps to its AudioServer bus. One touch journey on both viewports at 150% text: open each page, change one control, Back, value persists. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

## Claude claim (28 Oct)
Claude builds this on `claude/c15-settings-depth`. Codex: skip it.
