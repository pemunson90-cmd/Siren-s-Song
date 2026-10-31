extends RefCounted
# Standard host buttons and the existing radial page own all geometry and touch.
const Tools=preload("res://src/equipment/field_tools.gd")
const Effects=preload("res://src/simulation/field_tool_effects.gd")
static func setup(hud)->void:
 hud.extra.more_tools=hud.host._button(hud,"MORE\nTOOLS",func():hud.open("field_tools"),"more_tools")
 for id in Tools.field_ids():
  hud.extra[id]=hud.host._button(hud,Tools.spec(id).name.to_upper(),func():hud.host._order(id),id)
static func controls(hud)->Array:
 if hud.page=="tools":return [hud.host.order_buttons.decoy,hud.host.order_buttons.emp,hud.host.order_buttons.recon,hud.host.order_buttons.knock]+([hud.extra.more_tools] if Tools.enabled else [])
 var result=[]
 if hud.page=="field_tools":
  for id in Tools.field_ids():result.append(hud.extra[id])
 return result
static func refresh(hud)->void:
 var sim=hud.host.sim;var unit=sim.units[sim.selected]
 for id in Tools.field_ids():
  var spec=Tools.spec(id);var remaining=preload("res://src/presentation/truthful_commands.gd").stock(sim,id);var reason="READY"
  if not Tools.is_enabled(id):reason="UNAVAILABLE"
  elif remaining<=0:reason="EMPTY"
  elif not unit.alive or not sim.outcome.is_empty():reason="UNAVAILABLE"
  elif id=="hull_patch":
   if sim.selected!=0:reason="QUIETUS ONLY"
   elif sim.hull<=0 or sim.hull>=100 or float(Effects.state(sim).get("repairable_collision_loss",0.0))<=0:reason="NEEDS COLLISION DAMAGE"
  elif Effects.live(sim,id).size()>=spec.max_active:reason="ACTIVE"
  var button=hud.extra[id]
  button.text="%s %d\n%s"%[spec.name.to_upper(),remaining,reason]
  button.disabled=reason!="READY"
  button.tooltip_text=description(id)+(" Deploys here at the selected craft." if id!="hull_patch" else "")
static func description(id:String)->String:
 if id=="hull_patch":return "Repairs up to 30% collision hull damage. Quietus only; audible work."
 if id=="relay_buoy":return "Boosts nearby drone passive listening range by 35% for 3 min. Audible chirp."
 return Tools.spec(id).summary
static func choose(main,choice:String)->void:
 preload("res://src/presentation/tool_racks_view.gd").fill(main,choice)
 main._save_archive();main._show_fittings()
static func fittings(main)->void:
 if not Tools.enabled:return
 preload("res://src/presentation/tool_racks_view.gd").show(main)

# Keep warning acknowledgement and every tool visible on the same command surface.
static func place_notice(hud)->void:
 if not hud.host.advanced_orders or hud.page not in ["tools","field_tools"] or not hud.hints.panel.visible:return
 var panel=hud.hints.panel
 var bounds=preload("res://src/presentation/status_text/status_view.gd").content_bounds(hud,hud.size)
 var area=Rect2(Vector2.ZERO,bounds)
 var occupied=[]
 for button in hud.command_controls()+[hud.close_button,hud.host.pause_button]:
  if button.is_visible_in_tree():occupied.append(Rect2(button.global_position-hud.global_position,button.size))
 if hud.alarm.visible:occupied.append(hud.alarm.get_rect())
 var right=bounds.x-panel.size.x-12
 var bottom=bounds.y-panel.size.y-12
 var points=[panel.position,Vector2(right,panel.position.y),Vector2(12,bottom),Vector2(right,bottom),Vector2(right,hud.touch_height+24),Vector2(12,hud.touch_height+24)]
 for point in points:
  var rect=Rect2(point,panel.size)
  if area.encloses(rect) and not occupied.any(func(other):return rect.intersects(other)):
   panel.position=point;return
