# M3a Landmarks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give operations6 to29 three to five authored, illuminated landmark treatments using the accepted visual vocabulary and existing physical places.

**Architecture:** An authored table owns shape references, surface treatment and cosmetic glow. A pure presentation adapter uses the existing feature-view ground list. Prefer existing real terrain/hardware as anchors; never draw fake solid obstacles or change simulation geometry merely for decoration.

**Tech Stack:** Godot4.6.3, GDScript, Compatibility renderer, native Windows console toolchain.

**Spec:** origin/codex/handoffs:docs/codex/025-landmarks-m3a.md and docs/design/DESIGN_CAMPAIGN_DEPTH.md section5, read atc0abb9c.

## Global Constraints

- Three to five landmarks per operation6 to29; none added to0 to5 or endings.
- No new story text, art direction, rules, op logic, collision/sight/hearing/beam/damage/hull changes, APKs, branch deletion or frozen promotion.
- Reuse existing colors, terrain silhouettes, physical hardware and photo-scene lamp vocabulary. Cosmetic glow must not change camera light or sonar transmission.
- No new simulation/save state. Old saves or missing geometry must skip unavailable accents safely.
- Preserve the five authored fixtures and compare the bounded pressure probe truthfully, including its existing losses/controller findings/timeouts.
- Core must end CHECKS N FAILURES0 with positiveN; import, affected suites only locally. Full matrix belongs to GitHub.
- Same implementation worker and designated independent reviewer. Existing handoff and user standing order authorize execution; no further design-approval gate.

## Review Focus

1. Unknown or occluded landmarks must not expose terrain, subject or moving-object locations.
2. A received surface patch must not imply an entire polygon, closure or unmeasured wall.
3. A landmark must remain backed by actual geometry at the selected depth band.
4. Moving sled glow may use only the existing fresh public projection, never raw unobserved position.
5. A disabled table, old save or absent referenced shape must preserve baseline behavior without new persistent fields.

## Task1: Authored landmark table

**Files:** Create game/src/presentation/landmarks/landmark_data.gd; create game/tests/landmark_tests.gd.

**Interfaces:** Data.rows(operation:int, enabled:bool=ENABLED)->Array returns independent authored records. Records have stable id, source, shape/edge reference, position along edge, span, style, glow and one existing palette per operation. Sources are existing rock surfaces or existing public industrial-load projection. All tunable presentation numbers stay in this module.

- [x] Write coverage tests: ids6..29 each have3..5 unique finite records with0<glow<=1; ids-1..5 and30 returnempty; disabled returns empty; returned rows cannot mutate the table.
- [x] Run the new test and retain a meaningful missing-feature RED.
- [x] Author fixed rows from the current geometry inventory. Use the existing glass spires, warm industrial frames and fresh observed sleds; three physical-feature treatments per op plus photo/load lamps fit the three-to-five entry cap. Anchor at least one useful accent near the starting approach and one near existing photo work where practical.
- [x] Run the data tests; commit/push WIP on claude/lane-landmarks with required hooks.

## Task2: Visible accents, preservation and evidence

**Files:** Create game/src/presentation/landmarks/landmark_view.gd and game/tests/landmark_ui_tests.gd; modify game/src/presentation/feature_views.gd, game/tests/suites.txt and docs/RESUME.md. Capture harness/logs stay outside production source.

**Interfaces:** View.applies(sim)->bool, build_panel(hud)->void (empty), draw(view)->void. View.project(sim)->Array is a pure projection. A face-clipping helper returns only received collinear patches; a visibility helper restricts non-earned-map surface detail and all lamps to legitimate observation. Draw runs in the existing ground phase below fog, craft, input and warnings.

- [x] Write RED tests for unseen suppression, one partial face with no inferred closure, band mismatch, missing geometry, disabled rendering, stale/unobserved sled suppression and unchanged simulation snapshot after projection/drawing.
- [x] Implement surface-backed relief and restrained lamp glow with the existing palette. Keep solid-looking strokes on actual physical surfaces. Do not create noncolliding walls/spires, add thermal fronts for color, repurpose photo subjects or move work sites.
- [x] Register this adapter in the ground list only. Append unique standalone test rows; preserve all existing assertions and suite order.
- [x] Run import, data/UI suites, core, runtime and relevant density checks; every Godot script error/leak/resource-in-use line fails even if a suite prints zero assertion failures.
- [x] Run the five unchanged authored command-plan fixtures in their supported bare-Quietus configurations. Run before/after bounded pressure probes; preserve losses and controller limits as such, not wins. The external epsilon-bound wrapper may stop an existing900s zero-time spin, never alter simulation state or policy.
- [x] Capture and inspect three actual rendered representative operations. Keep captures as evidence, not phone/human-play acceptance; attach immutable screenshot links in025 Completion.
- [ ] Reconcile RESUME to023 complete/025 active; commit/push at least every30minutes. Obtain independent final-head review and own exact guidance/game-smoke before a merge commit. Mark done025 and BOARD together only after the actual merged source is verified.

**Builder call:** Preserve physical geometry and gameplay inputs wherever possible; improve legibility by authored surface detail and light accents on real existing places. Any unavoidable additional physical geometry requires route/clearance proof and independent review within the same handoff, not a change to rules. No implementation claim is made by this plan.

24 October execution note: all local implementation/evidence steps are complete.
The independent critic rejected the first thin borders; final localized motifs
and three native capture pairs passed source/visual review after a hidden-back-edge
repair. Raw evidence is in archive commit7e44ec9. The final checkbox remains open
for exact-head hosted checks, final independent evidence approval, merge and done025.

Current-base reconciliation: PR116 landed0e92729 while6ffab72's hosted checks
were running. The premerge guard prevented publication. Feature source remains
unchanged; preserve patrol195/216 and shift landmark196/217, UI197/218. Current
import/core831, runtime665, density883, data468, projection92, patrol56 and five
fixtures49 all pass with0failures. Pressure12freshchanged-operation pairs plus
64proven unchanged pairs match all76records/1107commands. Current evidence is
archive33dfe86/current-base-0e927. New exact-head review/CI remain required.
