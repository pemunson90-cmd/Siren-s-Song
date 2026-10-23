# First Siren Cue Implementation Plan

> Execute inline with superpowers:executing-plans; one final independent review.

**Goal:** Present the approved D1 first-notice bearing and soft sound once per Siren per dive in operations 1 to 3.
**Architecture:** Publish the existing heard/visual-acquisition decision before lock accumulation through a read-only signal. A presentation-owned tracker consumes it; one main registration installs the passive overlay and audio. All settings live in its table.
**Tech Stack:** Godot 4.6.3, GDScript, Compatibility renderer.
**Spec:** Handoff036 on codex/handoffs and USER_DIRECTIVES D1 on integration.

## Constraints
- Detection, four-second lock, beam, movement, hull and damage stay unchanged.
- Enabled operations are exactly 1, 2, 3. No new contacts or sonar information.
- Android touch stays primary; the passive cue must not intercept touches or Back.
- No story, APKs, em dashes, branch deletion or frozen-branch promotion.
- Photo PR92 merges first; reconcile its actual merge before final cue review/CI.

## Review focus
- A direct visual acquisition must notify before its lock increment.
- Heard investigation must notify without requiring a visible contact.
- Repeated notices stay silent after the first; a new dive resets the tracker.
- Mute, pause, menu and application suspension must silence/freeze audio.
- Cue-on and cue-off simulation snapshots must match, including losses and tools.

## Task 1: Complete cue module
Files: create presentation/first_siren_cue/{cue_table,notice_tracker,first_siren_cue}.gd; add one read-only signal seam to simulation.gd and one registration in main.gd. Tests: first_siren_cue_tests.gd and first_siren_cue_ui_tests.gd; append unique registry rows.

Interface: Simulation.siren_notice(id, source_position) emits only from its existing heard/detected branch, before lock accumulation. NoticeTracker.bind(sim), unbind(), frames() own transient deduplication and bearing records. FirstSirenCue.install(host) owns drawing, sound and lifecycle.

- [x] Write and run failing functional checks for missing module, operations filter, hearing/visual timing, once-only/reset, expiry, off switch and paired snapshot hashes.
- [x] Implement table and tracker; run focused checks until green.
- [x] Write and run failing real-touch UI checks at both Fold7 shapes: visible bearing, logged audio, readable bounds, pause/Back untouched, lifecycle/mute, expiry and later-operation silence.
- [x] Implement passive overlay/audio and register it; pass focused checks under actual Canvas rendering.
- [ ] Import, run core and affected warning/audio/FIX2 suites. Expected CHECKS N FAILURES 0, no Godot exit errors/leaks. GitHub owns the full scenario list.
- [ ] Commit/push WIP and record branch/SHA in036 Completion. Reconcile actual photo merge; obtain final independent source review and exact-head CI, merge normally, then DONE plus BOARD together.

Builder choices: 2.5-second cue; bearing only, without an exact enemy-position marker; a quiet lowered-pitch short alert recording distinct from the accelerating lock warning. Settings are revertible table values. No save fields or simulation event-list writes are introduced.

Execution ledger: functional missing-module RED, then32/0 after implementing the read-only signal/tracker. A test callback retained its Sim and leaked resources; explicit disconnect removed the cycle, verified clean exit. UI missing-registration RED, then actual Canvas34/0 after registration. Lifecycle trace proved Godot playing=false when stream_paused=true; tests now assert playback before suspension and paused afterward. A fresh event before touch pause tests an active sound rather than an already-finished 0.18s clip. Rendered screenshots inspected at both Fold7 shapes. Core and affected regressions pending. Existing036 Completion is the published recovery ledger; no additional governance workspace/tooling.
