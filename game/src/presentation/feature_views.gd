extends RefCounted
# Ordered, incremental ARCH2 presentation contract: applies(sim),
# build_panel(hud), draw(view). Lists retain the original HUD/world call order.
# Only Wake is registered so far. Other features remain at their original seams.
# Revert this PR to restore direct calls; no simulation or save fields are owned.
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const HUD_PANELS=[Wake]
const WORLD_VIEWS=[Wake]
static func build_panel(hud)->void:
 for feature in HUD_PANELS:
  if feature.applies(hud.host.sim):feature.build_panel(hud)
static func draw(view)->void:
 for feature in WORLD_VIEWS:
  if feature.applies(view.sim):feature.draw(view)
