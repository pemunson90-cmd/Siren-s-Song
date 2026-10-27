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
  var spec=Tools.spec(id);var remaining=Effects.count(sim,id);var reason="READY"
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
 main.upgrade=choice
 main._show_fittings()
static func fittings(main)->void:
 if not Tools.enabled:return
 main._menu_text("FINITE TOOLS / NEXT LAUNCH",19)
 main._menu_text("Choose a supply bundle. RESUME keeps the active dive's stock. During a dive: craft → TOOLS → MORE TOOLS; new deployments drop at that craft.",15)
 for choice in Tools.LOADOUTS:
  var stock=[]
  for id in Tools.ids():
   if Tools.is_enabled(id):stock.append("%s %d"%[Tools.spec(id).name,Tools.loadout_count(id,choice)])
  var oxygen=main._loadout_stock(choice)[0]
  var button=main._button(main.panel_box,"%s%s · O₂ %d%%\n%s"%[choice.to_upper()," · SELECTED" if main.upgrade==choice else "",oxygen," / ".join(stock)],choose.bind(main,choice),"tools_loadout_"+choice)
  button.disabled=main.upgrade==choice
 for id in Tools.field_ids():main._menu_text(Tools.spec(id).name.to_upper()+" · "+description(id),15)
