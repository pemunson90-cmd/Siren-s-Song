extends RefCounted
# Ordered, incremental ARCH2 presentation contract: applies(sim),
# build_panel(hud), draw(view). Lists retain the original HUD/ground/world order.
# Ordered groups retain the original HUD/world slots during incremental migration.
# Revert this PR to restore direct calls; no simulation or save fields are owned.
# Private synchronous draw context keeps the caller's existing craft transform.
class UnitDraw:
 extends RefCounted
 var canvas
 var sim
 var unit:int
 func _init(source_view,unit_index:int):
  canvas=source_view;sim=source_view.sim;unit=unit_index
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const Rendezvous=preload("res://src/presentation/rendezvous_view.gd")
const Shelf=preload("res://src/presentation/shelf_habitat_view.gd")
const ShelfGround=preload("res://src/presentation/feature_views/shelf_ground.gd")
const WarningChain=preload("res://src/presentation/warning_chain_view.gd")
const Delivery=preload("res://src/presentation/blackwater_delivery_view.gd")
const Recipient=preload("res://src/presentation/feature_views/recipient.gd")
const Concealed=preload("res://src/presentation/concealed_harbour_view.gd")
const Witness=preload("res://src/presentation/feature_views/witness.gd")
const WitnessCarried=preload("res://src/presentation/feature_views/witness_carried.gd")
const HUD_PANELS=[Wake,Rendezvous,Shelf,WarningChain,Delivery,Recipient,Concealed,Witness]
const Courier=preload("res://src/presentation/blackwater_courier_view.gd")
const FieldTools=preload("res://src/presentation/field_tools_view.gd")
const WORLD_VIEWS=[Courier,Shelf,Wake,Rendezvous,WarningChain,Witness,Concealed,Recipient,FieldTools]
const Landmarks=preload("res://src/presentation/landmarks/landmark_view.gd")
const GROUND_VIEWS=[ShelfGround,Landmarks]
const Expedition=preload("res://src/presentation/expedition_view.gd")
const HUD_BADGE_PANELS=[Expedition]
const WORLD_DETAIL_VIEWS=[Expedition]
const Recovery=preload("res://src/presentation/module_recovery_view.gd")
const Cache=preload("res://src/presentation/optional_cache_view.gd")
const HUD_CONTEXT_PANELS=[Recovery,Cache]
const WORLD_SCREEN_VIEWS=[Recovery]
const Industrial=preload("res://src/presentation/industrial_view.gd")
const HUD_ACTIVITY_PANELS=[Industrial]
const WORLD_ACTIVITY_VIEWS=[Industrial]
const CARRIED_VIEWS=[WitnessCarried]
static func build_panel(hud)->void:_build_panels(hud,HUD_PANELS)
static func build_context(hud)->void:_build_panels(hud,HUD_CONTEXT_PANELS)
static func build_activity(hud)->void:_build_panels(hud,HUD_ACTIVITY_PANELS)
static func build_badges(hud)->void:_build_panels(hud,HUD_BADGE_PANELS)
static func _build_panels(hud,features:Array)->void:
 for feature in features:
  if feature.applies(hud.host.sim):feature.build_panel(hud)
static func draw(view)->void:_draw_views(view,WORLD_VIEWS)
static func draw_detail(view)->void:_draw_views(view,WORLD_DETAIL_VIEWS)
static func draw_screen(view)->void:_draw_views(view,WORLD_SCREEN_VIEWS)
static func draw_activity(view)->void:_draw_views(view,WORLD_ACTIVITY_VIEWS)
static func draw_ground(view)->void:_draw_views(view,GROUND_VIEWS)
static func draw_carried(view,unit:int)->void:_draw_views(UnitDraw.new(view,unit),CARRIED_VIEWS)
static func _draw_views(view,features:Array)->void:
 for feature in features:
  if feature.applies(view.sim):feature.draw(view)
