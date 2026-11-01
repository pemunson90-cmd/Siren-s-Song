# Item 133: Recovery manifest before the dive ends

Goal (player): Pressing EXTRACT (or WITHDRAW) while any craft is outside recovery shows a manifest: each craft IN or OUT with its distance to recovery, and what OUT means (lost with its cargo). HOLD keeps the dive running; CONFIRM ends it as today. With every craft in, EXTRACT ends the dive at once, as today.
Why now: Critic 123 C11 (drones lost with no confirm; the missing manifest is real). C06 path conflict warning is split out (needs simulation.gd).
Class: ui
Areas: hud.recovery
Files: game/src/presentation/recovery_manifest.gd (new), game/src/presentation/module_recovery_view.gd, game/src/main.gd (one hook in _recovery_route only), game/tests/recovery_manifest_ui_tests.gd
Serial zones touched: main.gd
Depends on: 127
Protected rules touched: none (recovery reach, loss rules and damage stay as they are; this only asks before ending)

## Acceptance test (fails before, passes after)
recovery_manifest_ui_tests: in a staged op with drone B outside recovery, EXTRACT shows the manifest naming DRONE B OUT with a distance; HOLD leaves the dive running with all craft unchanged; CONFIRM ends it with the same outcome as today; with all craft in, EXTRACT ends the dive with no manifest. Fails today (EXTRACT ends at once).

## Do not
Change recovery reach, loss rules, rewards or the WITHDRAW/EXTRACT labels. Touch mission_hud.gd or ocean_view.gd (held by PKG2).

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
ui: control list of the manifest in both cases, test counts; PNGs if a render backend exists.

## Builder notes
Branch item/133-recovery-manifest from origin/claude/integration. Preferred provider: claude:sonnet then codex.
Checks before push: the minimum (RULINGS.md speed rule).
