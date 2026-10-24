# Builder conventions

- New simulation features own one module with static applies, tick, valid and command seams.
- Document the integration seam and how to revert the feature in its module header.
- Keep feature tick hooks narrow; register save checks in persistence/save_checks.gd.
- Save-check phases preserve existing shape guards and short-circuit order.
- Keep new orders in their family under simulation/orders, registered in the order table.
- Add operations through operation_catalog and a <region>_operations.gd factory.
- Keep tunable numbers in simulation/tuning.gd or the feature's data table.
- Keep save fields in the feature dictionary; validate them in the owning module.
- Preserve optional fields and compatible versions; bump VERSION only for shape changes.
- Never add simulation-data checks to save_store.gd.
- Keep presentation in the feature's own view module with a narrow documented seam.
- Add <feature>_tests.gd for logic and <feature>_ui_tests.gd for screens.
- Register standalone tests in tests/suites.txt; do not grow shared runners.
- Prefer lines under 140 characters. Do not rename existing files during extractions.
- Android touch and Back are primary; keyboard is fallback. Preserve 48 dp targets.

- Presentation flow extractions retain Main's existing entry signatures and
  host-bound callbacks as forwarders; state ownership and deferred order stay.
- Prove moved bodies, rules, numbers and text unchanged, then match core and
  named UI counts. Each ARCH2 extraction has its own reviewed PR and CI.
- Incremental presentation registration lives in presentation/feature_views.gd.
  Migrated views expose applies(sim), build_panel(hud) and draw(view). The panel
  seam refreshes existing controls; setup, input and Node lifetimes stay owned
  by their existing hosts. Keep applicability checks free of state changes.
- Preserve each original refresh/draw position and the separate ordered HUD,
  ground and world lists. A small adapter implements the same contract when an
  existing feature draws in more than one layer. Preserve every original layer
  slot. Only registered views use this seam; migrate one feature per PR.
- If a view also owns a Control screen, keep that Node class and its lifecycle
  unchanged; a small RefCounted adapter supplies the shared contract. Keep
  ordered segments separate while intervening legacy calls are still present.
- For a craft-local draw pass, use a private synchronous context containing the
  existing canvas, simulation reference and unit index. Keep the caller's exact
  transform slot and restore behavior; the context owns no gameplay state.
