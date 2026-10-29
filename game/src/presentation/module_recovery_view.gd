extends RefCounted
# ARCH2 context-panel and screen-overlay contract. Keep the original
# salvage guards, helpers and overlay slot; no recovery commands move here.
# Revert this PR to restore direct HUD/ocean calls.
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 if hud.subject.get("kind","")=="salvage" and sim.has_method("salvage_context"):
  var salvage=sim.salvage_context(hud.subject.item)
  hud.extra.salvage.text="RECOVER\n4s AUDIBLE" if not salvage.active else "RECOVERING\n%d%%"%floori(salvage.elapsed/salvage.duration*100)
  hud.extra.salvage.disabled=not salvage.ready
  hud.instrument_info.text=detail(sim,hud.subject.item)
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Delivery=preload("res://src/presentation/blackwater_delivery_view.gd")
const Witness=preload("res://src/presentation/witness_evacuation_view.gd")
const Cache=preload("res://src/presentation/optional_cache_view.gd")
# Own-module projection only. Recovery and inventory mutation belong to commands
# and FleetInventory; a carried fitting is never an operational installation.
static func status(sim)->Dictionary:
 return sim.module_recovery_status() if sim.has_method("module_recovery_status") else {"modules":[],"cargo":[[],[],[]],"jobs":[{},{},{}],"result":{}}
static func name(item:String)->String:
 if item.begins_with("glass_") or item.begins_with("choir_"):return item.trim_prefix("glass_").trim_prefix("choir_").replace("_"," ").to_upper()
 return Catalog.ITEMS.get(item,{"name":item}).name.to_upper()
static func work(sim,unit:int)->Dictionary:
 var cache_work=Cache.work(sim,unit)
 if not cache_work.is_empty():return cache_work
 if sim.Choir.busy(sim,unit):
  var result=sim.mission.iron_choir.jobs[unit].duplicate(true);result.unit=unit;result.item="choir_"+result.action;return result
 if sim.Glass.busy(sim,unit):
  var result=sim.mission.glass_reach.job.duplicate(true);result["item"]=sim.Glass.item(sim);return result
 var jobs=status(sim).get("jobs",[])
 if unit<0 or unit>=jobs.size() or jobs[unit].is_empty():return {"unit":-1}
 var result=jobs[unit].duplicate(true);result.unit=unit;return result
static func cargo(sim,unit:int)->String:
 var names=Cache.cargo(sim,unit)
 if sim.Choir.applies(sim.mission):
  var industrial=sim.mission.iron_choir.artifact
  if not industrial.is_empty() and industrial.state=="cargo" and industrial.carrier==unit:names.append("CHOIR MATERIAL · "+industrial.id.replace("_"," ").to_upper())
  if sim.Choir.towing(sim,unit):names.append("PHYSICAL TOW · "+sim.Choir.body(sim).name)
 var a=sim.Glass.artifact(sim)
 if not a.is_empty() and a.state=="cargo" and a.carrier==unit:names.append("REACH MATERIAL · "+a.id.replace("_"," ").to_upper())
 var loads=status(sim).get("cargo",[])
 if unit>=0 and unit<loads.size():
  for item in loads[unit]:names.append("INACTIVE CARGO · "+short_name(item))
 return "\n".join(names)
static func task(sim,unit:int)->String:
 var job=work(sim,unit)
 if job.unit<0:return ""
 var data=Delivery.wreck_cargo(sim,job.item)
 return ("WORK %d%% · %s" if job.item.begins_with("choir_") else "RECOVER %d%% · %s")%[clampi(floori(job.elapsed/maxf(.01,job.duration)*100),0,100),name(job.item)]+("\n"+data if not data.is_empty() else "")
static func active(sim,unit:int)->bool:
 return work(sim,unit).unit>=0 or not cargo(sim,unit).is_empty()
static func short_name(item:String)->String:
 return {"drone_sampler":"FIELD SAMPLER","drone_survey_array":"SURVEY ARRAY","drone_deep_cells":"DEEP CELLS"}.get(item,name(item))
static func site_lines(sim,site:Dictionary)->Array:
 if sim.Cache.pieces(sim).has(site.item):return ["OPTIONAL CACHE",site.name]
 if site.item.begins_with("glass_"):return ["REACH MATERIAL",site.name]
 if site.get("witness",false):return Witness.site_lines(sim,site)
 var packets=site.get("packets",[])
 if packets.is_empty():return ["MODULE SALVAGE",short_name(site.item)]
 var lines=["WRECK RECOVERY"]
 if Catalog.ITEMS.has(site.item):lines.append(short_name(site.item))
 for module in status(sim).get("modules",[]):
  if module.state=="salvage" and module.pos.distance_to(site.pos)<=1. and not short_name(module.item) in lines:lines.append(short_name(module.item))
 for packet in Delivery.status(sim).get("packets",[]):
  if packet.id in packets:lines.append(packet.name+" BUFFER")
 return lines
static func nearest_clear_rect(box:Rect2,bounds:Rect2,occupied:Array)->Rect2:
 # If preferred tethers are crowded, a clear rectangle can be placed along
 # an obstacle or boundary edge. Search those edges, preserving full plates.
 var xs=[box.position.x,bounds.position.x,bounds.end.x-box.size.x]
 var ys=[box.position.y,bounds.position.y,bounds.end.y-box.size.y]
 for obstacle in occupied:
  for x in [obstacle.position.x-box.size.x-5,obstacle.end.x+5]:
   var value=clampf(x,bounds.position.x,bounds.end.x-box.size.x)
   if not value in xs:xs.append(value)
  for y in [obstacle.position.y-box.size.y-5,obstacle.end.y+5]:
   var value=clampf(y,bounds.position.y,bounds.end.y-box.size.y)
   if not value in ys:ys.append(value)
 var best=box;var distance=INF
 for x in xs:
  for y in ys:
   var candidate=Rect2(Vector2(x,y),box.size);var cost=candidate.position.distance_squared_to(box.position)
   if cost<distance and not occupied.any(func(r):return r.intersects(candidate.grow(5))):best=candidate;distance=cost
 return best
static func markers(ocean,sim,touch:float)->Array:
 var result=[]
 if not sim.has_method("salvage_sites"):return result
 var occupied=ocean.ui_blocked_rects.duplicate();occupied.append_array(ocean.own_craft_rects())
 var bounds=Rect2(Vector2(12,touch+24),ocean.size-Vector2(24,touch*2+48))
 for site in sim.salvage_sites():
  var lines=site_lines(sim,site)
  var extent=Vector2(minf(touch*3.,bounds.size.x),maxf(touch,lines.size()*(ocean.feedback_font_size+6)+16))
  var anchor=ocean.screen_position(site.pos)
  if not Rect2(Vector2.ZERO,ocean.size).has_point(anchor):continue
  var box=Rect2((anchor+Vector2(touch*.9,-touch*.5)).clamp(bounds.position,bounds.end-extent),extent)
  var clear=false
  for offset in [Vector2(.9,-.5),Vector2(-3.9,-.5),Vector2(-1.5,-1.8),Vector2(-1.5,.8),Vector2(.9,1.),Vector2(-3.9,1.)]:
   var candidate=Rect2((anchor+offset*touch).clamp(bounds.position,bounds.end-extent),extent)
   if not occupied.any(func(r):return r.intersects(candidate.grow(5))):box=candidate;clear=true;break
  if not clear:box=nearest_clear_rect(box,bounds,occupied)
  result.append({"rect":box,"anchor":anchor,"site":site,"lines":lines});occupied.append(box)
 return result
static func draw(ocean,sim=null)->void:
 if sim==null:sim=ocean.sim
 var font=ThemeDB.fallback_font;var size=ocean.feedback_font_size;var color=Color("d9b475")
 for marker in markers(ocean,sim,ocean.instrument_height):
  var box:Rect2=marker.rect;var anchor:Vector2=marker.anchor
  ocean.draw_line(anchor,anchor.clamp(box.position,box.end),Color(color,.5),1.5)
  ocean.draw_rect(Rect2(anchor-Vector2(7,5),Vector2(14,10)),Color("314d51"));ocean.draw_rect(Rect2(anchor-Vector2(7,5),Vector2(14,10)),color,false,1.5)
  ocean.draw_rect(box,Color(.025,.065,.075,.94));ocean.draw_rect(box,color,false,1)
  for row in marker.lines.size():
   ocean.draw_string(font,box.position+Vector2(10,size+8+row*(size+6)),marker.lines[row],HORIZONTAL_ALIGNMENT_LEFT,box.size.x-20,size,Color("8eb1b3") if row==0 else color)
static func detail(sim,item:String)->String:
 if sim.Cache.pieces(sim).has(item):return name(item)+"\n"+sim.salvage_context(item).reason+"\n4s settled ·60m · same depth · clear terrain\nAUDIBLE WINCH ·520m open-water estimate\nOne shared cargo place per piece. CACHE / UNLOAD at recovery frees places before photography is complete. All three received earn a first-return account."
 if Witness.site_for_item(sim,item):return Witness.salvage_detail(sim,item)
 var context=sim.salvage_context(item)
 for site in sim.salvage_sites():
  if site.item==item and not site.get("packets",[]).is_empty():
   return "\n".join(site_lines(sim,site))+"\n"+context.reason+"\nONE WINCH · 4s settled · 60m · clear line of sight\nAUDIBLE · 520m open-water estimate\nQuietus receives recovered buffers aboard. A drone carries them until local TRANSFER to Quietus."+("\nRecovered kit stays inactive cargo until its carrier reaches recovery." if Catalog.ITEMS.has(item) else "")
 return name(item)+"\n"+context.reason+"\nRECOVER · 4s settled · within 60m · clear line of sight\nAUDIBLE WINCH · 520m open-water estimate\nCarried cargo stays inactive. Bring its carrier to Quietus's chosen recovery mouth."
static func departure_signature(context:Dictionary)->String:
 var left=[]
 for module in context.get("left",[]):left.append([module.item,module.state,module.unit])
 return str([context.get("available",false),context.get("corridor",{}),left,context.get("recovered",[])])
static func consequence(sim,economy:Dictionary={})->String:
 var iron=preload("res://src/campaign/ironman_losses.gd").active(economy)
 if not sim.has_method("module_recovery_status"):return ""
 var result=status(sim).get("result",{});var lines=[];var absent=false
 for id in [1,2]:
  var u=sim.units[id];var state="LOST" if not u.alive else "SURVIVED"
  if u.alive and not result.is_empty():state="RECOVERED" if id in result.get("recovered_drones",[]) else "OUTSIDE RECOVERY"
  if state in ["LOST","OUTSIDE RECOVERY"]:absent=true
  lines.append(u.name+" · "+state)
 for key in ["recovered","lost"]:
  var names=[]
  for item in result.get(key,[]):names.append(name(item))
  if not names.is_empty():lines.append(("MODULES RECOVERED · " if key=="recovered" else "LEFT BEHIND · ")+", ".join(names))
 if not result.get("lost",[]).is_empty() and sim.mission.get("fleet_commit",false):lines.append("Listed modules are unavailable for future launches.")
 if absent:lines.append("Ironman replacements require paid manufacturing. Empty bays can launch." if iron else "Bare replacement drones remain available.")
 if not iron and (sim.outcome!="won" or not sim.mission.get("fleet_commit",false)):lines.append("Retry / replay leaves permanent module stock unchanged.")
 return "\n".join(lines)
static func debrief(main)->void:
 var text=consequence(main.sim,main.get("economy") if main.get("economy") is Dictionary else {})
 if not text.is_empty():main._menu_text("FLEET RECOVERY\n"+text,17)
 Cache.debrief(main)
static func confirm_departure(main)->void:
 var context=main.sim.departure_context()
 if not context.available:return
 main.sim.paused=true;main.screen="departure";main._clear_menu()
 main.departure_confirmation=departure_signature(context)
 main._menu_text("RECOVERY DECISION",24)
 main._menu_text("RETURN TO · "+context.corridor.name.to_upper(),17)
 if preload("res://src/campaign/ironman_losses.gd").active(main.economy):main._menu_text("IRONMAN: unrecovered drones and fittings are permanently lost, including replays. Replacements require paid manufacturing.",16)
 else:main._menu_text("Abandoned kits are unavailable next launch. Bare drones remain available." if main.sim.mission.get("fleet_commit",false) else "COMPLETED REPLAY · permanent module stock unchanged.",16)
 for module in context.left:
  var place="SALVAGE · LOCAL RETRIEVAL" if module.state=="salvage" else main.sim.units[module.unit].name+" · "+("INACTIVE CARGO" if module.state=="cargo" else "FITTED · OUTSIDE MOUTH")
  main._menu_text(name(module.item)+"\n"+place,17)
 main._menu_text("Return each carrier to this mouth: within 65m, below 12m/s, clear of terrain. Salvage needs a local 4s audible retrieval. Carried kits stay inactive until recovered.",16)
 var holders=[]
 for module in context.left:
  if module.state!="salvage" and module.unit>0 and main.sim.units[module.unit].alive and module.unit not in holders:
   holders.append(module.unit)
   var unit=module.unit;var mouth=context.corridor.duplicate(true)
   main._button(main.panel_box,main.sim.units[unit].name+" → "+mouth.name.to_upper(),func():
    var current=main.sim.departure_context()
    if not current.available or current.corridor.pos!=mouth.pos or current.corridor.get("route","")!=mouth.get("route",""):
     if current.available:confirm_departure(main)
     else:main._enter_water()
     return
    # Separate explicit station and route commands clear queued append intent,
    # preserving this craft's profile and propulsion rather than emergency drive.
    main._order("select",{"unit":unit});main._order("route",{"point":mouth.pos})
    main._order("depart",{"confirm":false});main._enter_water()
   ,"return_module_%d"%unit)
  elif module.state=="salvage":
   var point=module.pos
   main._button(main.panel_box,"VIEW SALVAGE · "+short_name(module.item),func():
    main._order("depart",{"confirm":false});main._enter_water()
    main.ocean.chart_camera.mode="free";main.ocean.chart_camera.center=point;main._view_changed()
   ,"view_salvage_"+module.item)
 main._button(main.menu_footer,"KEEP\nRECOVERING",func():main._order("depart",{"confirm":false});main._enter_water(),"keep_recovering")
 main._button(main.menu_footer,"ABANDON %d MODULE%s\nDEPART"%[context.left.size(),"" if context.left.size()==1 else "S"],func():
  var current=main.sim.departure_context()
  if departure_signature(current)!=main.departure_confirmation:
   if current.available:confirm_departure(main)
   else:main._enter_water()
   return
  main._order("depart",{"confirm":true,"corridor":current.corridor})
  if not main.sim.outcome.is_empty():main._debrief()
  else:main._enter_water()
 ,"abandon_modules")
 main.menu_footer.show()
 main._save_archive();main.call_deferred("_layout")
