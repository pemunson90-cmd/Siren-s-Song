extends RefCounted
# Ordered, incremental ARCH2 presentation contract: applies(sim),
# build_panel(hud), draw(view). Lists retain the original HUD/ground/world order.
# Wake, Rendezvous and Shelf are registered; other features retain original seams.
# Revert this PR to restore direct calls; no simulation or save fields are owned.
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const Rendezvous=preload("res://src/presentation/rendezvous_view.gd")
const Shelf=preload("res://src/presentation/shelf_habitat_view.gd")
const ShelfGround=preload("res://src/presentation/feature_views/shelf_ground.gd")
const HUD_PANELS=[Wake,Rendezvous,Shelf]
const WORLD_VIEWS=[Shelf,Wake,Rendezvous]
const GROUND_VIEWS=[ShelfGround]
static func build_panel(hud)->void:
 for feature in HUD_PANELS:
  if feature.applies(hud.host.sim):feature.build_panel(hud)
static func draw(view)->void:_draw_views(view,WORLD_VIEWS)
static func draw_ground(view)->void:_draw_views(view,GROUND_VIEWS)
static func _draw_views(view,features:Array)->void:
 for feature in features:
  if feature.applies(view.sim):feature.draw(view)
