extends RefCounted
# Between-operation economy controls: balances, costs, preset, repair,
# manufacturing and research. Main owns state; every action re-enters the
# briefing so prices stay current. Nothing here changes sensing or pause.
const Economy=preload("res://src/campaign/economy.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Inventory=preload("res://src/campaign/fleet_inventory.gd")
const LABELS={"quietus":"QUIETUS HULL","drone_a":"DRONE A","drone_b":"DRONE B"}
static func _preset_action(main)->void:
 if Economy.cycle_preset(main.economy):main._save_archive();main._show_campaign()
static func _act(main,index:int,kind:String,arg:String)->void:
 var e=main.economy
 match kind:
  "ironman":Economy.set_ironman(e)
  "repair":Economy.repair(e,arg)
  "rebuild":main.fleet=Economy.rebuild(e,main.fleet,arg)
  "spare":Economy.build_spare(e,arg)
  "research":
   if Economy.pay(e,Economy.research_cost(e)):
    main.expedition=Research.start(main.expedition,arg);main._sync_craft_upgrades()
  "bare":main.fitted_equipment=Catalog.default_loadout()
  "last":main.fitted_equipment=Inventory.reconcile_fitting(e.last_fit,Inventory.available(main._equipment_entitlements(),main.fleet))
 main._refresh_briefing(index)
static func summary(main)->void:
 var e=main.economy
 main._menu_text("%s\nPRESET · %s · %s%s"%[Economy.balance_text(e),Economy.preset(e).name,Economy.preset(e).note," · IRONMAN" if e.ironman else ""],15)
 var title="PRESET LOCKED · IRONMAN"
 if not e.ironman:title="PRESET · %s → %s"%[Economy.preset(e).name,Economy.PRESETS[Economy.ORDER[(Economy.ORDER.find(e.preset)+1)%Economy.ORDER.size()]].name]
 var button=main._button(main.panel_box,title,_preset_action.bind(main),"eco_preset")
 button.disabled=e.ironman
static func panel(main,index:int)->void:
 var e=main.economy
 main._menu_text("SUPPLIES / COSTS",19)
 summary(main)
 var iron=main._button(main.panel_box,"IRONMAN · ON (LOCKED)" if e.ironman else "IRONMAN · OFF → ON (LOCKS PRESET, EVERY FITTING PAID EACH LAUNCH)",_act.bind(main,index,"ironman",""),"eco_ironman")
 iron.disabled=e.ironman
 main._menu_text(e.report,14)
 var slots=main._equipment_context().slots
 var launch_cost=Economy.refit_cost(e,slots)
 main._menu_text("NEXT LAUNCH REFIT · %s\nA craft keeps what it carried last launch for free. Bare Quietus with the starter loadout always launches free."%Economy.fmt(launch_cost),15)
 for target in Economy.TARGETS:
  var cost=Economy.repair_cost(e,target)
  if cost.is_empty():main._menu_text("%s · CONDITION %d%%"%[LABELS[target],e.cond[target]],14);continue
  var repair=main._button(main.panel_box,"REPAIR %s · %d%% · %s"%[LABELS[target],e.cond[target],Economy.fmt(cost)],_act.bind(main,index,"repair",target),"eco_repair_"+target)
  repair.disabled=not Economy.can_pay(e,cost)
 var earned=main._equipment_entitlements()
 var lost=Economy.lost_items(main.fleet)
 for item in earned:
  if not Catalog.ITEMS.has(item):continue
  var cost=Economy.item_cost(item,e);var name=Catalog.ITEMS[item].name
  if item in lost:
   var rebuild=main._button(main.panel_box,"REBUILD LOST %s · %s"%[name,Economy.fmt(cost)],_act.bind(main,index,"rebuild",item),"eco_make_"+item)
   rebuild.disabled=not Economy.can_pay(e,cost)
  elif e.spares.get(item,0)>0:
   main._menu_text("SPARE %s · BUILT. Replaces this fitting if lost in a dive."%name,14)
  elif Catalog.ITEMS[item].compatible_slots.any(func(s):return s in ["drone_a","drone_b"]):
   var spare=main._button(main.panel_box,"BUILD SPARE %s · %s"%[name,Economy.fmt(cost)],_act.bind(main,index,"spare",item),"eco_make_"+item)
   spare.disabled=not Economy.can_pay(e,cost)
 for material in Research.pending(main.expedition):
  var cost=Economy.research_cost(e);var name=Catalog.ITEMS[Research.item_of(material)].name
  var research=main._button(main.panel_box,"RESEARCH %s · %s"%[name,Economy.fmt(cost)],_act.bind(main,index,"research",material),"eco_research_"+material)
  research.disabled=not Economy.can_pay(e,cost)
 main._button(main.panel_box,"STRIP ALL TO BARE · FREE",_act.bind(main,index,"bare",""),"eco_bare")
 if e.last_fit!=slots:
  main._button(main.panel_box,"REVERT TO LAST LAUNCH FIT · FREE",_act.bind(main,index,"last",""),"eco_last")
