extends RefCounted
# Ordered, incremental ARCH2 presentation contract: applies(sim),
# build_panel(hud), draw(view). Lists retain the original HUD/world call order.
# Wake and Rendezvous are registered; other features retain original seams.
# Revert this PR to restore direct calls; no simulation or save fields are owned.
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const Rendezvous=preload("res://src/presentation/rendezvous_view.gd")
const HUD_PANELS=[Wake,Rendezvous]
const WORLD_VIEWS=[Wake,Rendezvous]
static func build_panel(hud)->void:
 for feature in HUD_PANELS:
  if feature.applies(hud.host.sim):feature.build_panel(hud)
static func draw(view)->void:
 for feature in WORLD_VIEWS:
  if feature.applies(view.sim):feature.draw(view)
