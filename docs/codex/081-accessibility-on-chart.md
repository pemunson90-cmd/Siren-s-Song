# Handoff 081: Reduced motion, high contrast and safe palette do not reach the tactical chart

Status: CLAIMED
Claimed at: 2026-10-28 08:13:45 UTC
Claimed by: codex-root-parallel
Finished at:

Precondition: 063 is DONE or remains unclaimed with chart ownership reserved to081. Scout note: Handoff 063 (performance pass edits presentation draw code) should be DONE or unclaimed so ocean_view.gd edits do not collide. No other claimed handoff owns these files. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Make the three existing settings apply to the tactical chart and HUD overlays, without touching simulation. (1) Reduced motion: stop regional dust drift (hold phase for the atmosphere), replace the lock-arc and threat-vignette pulses with steady values, and cap camera_flash and the hunt meter wave. (2) Safe palette: route chart colours for threat, heard/received evidence, route preview and warning through Palette.color roles, and add a pattern or shape redundancy (dash, ring or marker shape) wherever a meaning is colour-only. (3) High contrast: on the chart, thicken outlines, brighten route and craft rings, and mute regional dust/light so contacts and routes separate from the water. Keep standard rendering byte-identical when all three are off. Add a short on-screen legend line for the safe-palette roles in the existing help text.

Spec basis: CURRENT_GAME_SPEC 'Approved full-release expansion': settings cover 'text scale, contrast/color alternatives, reduced motion, haptics' and 'give visual equivalents' to consequential sounds.
Scout baseline (27 Oct; lane implementation below is pending integration): On origin/claude/integration, git grep finds no reference to Settings/FrontendSettings/reduced_motion/high_contrast in presentation/ocean_view.gd, presentation/art/*, hunt_meter.gd, lock_warning.gd or first_siren_cue.gd. high_contrast only edits the UI Theme (frontend_settings.gd:38-48). Palette.color() has consumers only in photo_pricing_overlay.gd, and palette.gd's own header says 'Narrow consumers ... no global art recoloring'. ocean_view.gd still animates water dust by phase (lines 218, 406), pulses the lock target arc at sin(phase*18) (390), pulses the threat edge vignette at sin(sim.elapsed*7) (503) and flashes camera_flash, with about 70 hard-coded Color("hex") literals. A player who turns these settings on still gets the full motion and colour-only threat/evidence coding on the chart where the game is played.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-chart-accessibility

## Files you may edit
game/src/presentation/ocean_view.gd, presentation/art/region_renderer.gd, presentation/art/art_renderer.gd, presentation/accessibility/palette.gd and cue_table.gd (new roles), presentation/hunt_meter.gd, presentation/lock_warning.gd, presentation/first_siren_cue/first_siren_cue.gd, presentation/contact_feedback.gd. New tests extend presentation/accessibility/cue_tests.gd.

## Files you must not touch
Any change to sensing, lock timing, visibility rules or what information is shown. Do not recolour Siren or terrain art beyond the safe-palette roles. Do not remove warnings; only change how they animate. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import and core. Extend cue_tests.gd: with all three settings off the draw-command output is unchanged; with reduced_motion on, two frames at different phase draw identical atmosphere and pulses; with safe_palette on, each threat/evidence role has a distinct pattern or shape and contrast at least 3:1 against the water backing. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
WIP: existing chart settings wired reversibly; PR [171](https://github.com/pemunson90-cmd/Siren-s-Song/pull/171), headf692ac85f9a784a129d4c9de0b356a6b4988d471 on integration0320f632.
Isolated import pass; core848/0, cue52/0, Compatibility cue/render66/0; standard legacy/earned charts byte-identical to pre081 source. Guidance pass.
Root collects exact-head hosted guidance/game-smoke and merges; CLAIMED until verified merge. 063 still waits for draw-file release.
No simulation, eligibility, sensing, story, save or art-color changes. No APK/phone/human perception checks; camera_flash is an unused chart timer capped under reduced motion.
Outside source ownership: only owned A11Y docs, append-only MODULES/RESUME notes and this handoff/board status.

Root scheduling28Oct08:14UTC:063 is OPEN/unclaimed and waits on060, so its ordering dependency exists only to avoid draw-file collision.081 may proceed now; reserve chart/render files to081 and make063 wait for081 release. No design scope change.
