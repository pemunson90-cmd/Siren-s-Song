# Handoff 064: FITTINGS AND BRIEFING FIT SURFACE AT 24-MODULE CATALOG SCALE

Status: CLAIMED
Claimed at: 2026-10-28 09:43:24 UTC
Claimed by: claude
Finished at:

Precondition: 055 is DONE. Scout note: Handoff 055 (modules and field tools, PR150) DONE and merged so the full catalog and tool table exist; handoff 062 adds only one-line entry buttons here. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Rebuild the fit surface so it stays usable with about 30 recoverable items. Show one craft at a time (QUIETUS / DRONE A / DRONE B tabs), then one row per mount slot (SENSOR, HARDWARE, UTILITY, OPTICS, PROPULSION, CARGO) listing only items that fit that mount. Tapping an item previews the resulting POWER / CARGO / NOISE / ENDURANCE bars as a delta against the current fit, shows refusal reasons in plain words, and confirms with one tap; empty and BARE stay one tap away. Replace the hard-coded loadout line with text generated from the field-tool and drone counts of the actual fit. Keep 48 dp targets, both Fold7 shapes, 150% text, and Android Back. Reuse the same widget in the briefing and in Fittings.

Spec basis: 'Complete ... fitting/research/archive' and 'Typed mounts and power/noise/endurance/cargo budgets create actual tradeoffs' with 18 conventional + 6 alien modules, 3 hulls, 4 drone chassis, 8 field tools.
Evidence it is missing: equipment_context.gd rows() emits one row per module per compatible craft slot, and fitting() prints a text paragraph plus one button for every row in one flat scrolling column. The same list is embedded in the briefing screen (flow/campaign_flow.gd briefing(), which also calls loadout() and fitting()). Budget bars (_bar) are shown only for the current frame, not as a projected change when a module is chosen. The briefing still prints the hard-coded line 'O2 %d%% ... 3 DECOYS · 2 DRONES · 2 TORPEDOES' (campaign_flow.gd), which will be wrong once the 8-tool table exists. PR150 (claude/c2-equipment) changes equipment_context.gd by 45 lines and fittings_menu.gd by 1 line, adding items and a tool chooser but no grouping, tabs or comparison.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-fit-surface

## Files you may edit
game/src/presentation/equipment_context.gd, presentation/fittings_menu.gd, presentation/flow/campaign_flow.gd (briefing fit hook only), new presentation/fit_surface/* (tab and slot views).

## Files you must not touch
Any change to equipment/ catalog rules, budgets, costs, or choose() validation; the view stays a projection. No new economy rules. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import and core. One native-UI touch journey on both viewports at 150% text: open Fittings, switch craft tab, preview a module (bars change, nothing saved), confirm, back. One data test that every catalog item appears under exactly its compatible mounts. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

## Claude claim (28 Oct)
Claude builds this on `claude/c18-fit-surface`. Codex: skip it.
