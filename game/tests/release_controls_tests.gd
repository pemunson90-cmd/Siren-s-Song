extends SceneTree
# R1 (Pat 2026-10-30): one-press travel shortcuts "are fine for testing but they
# will absolutely have to be stripped for release play". With the existing dev
# state off no shortcut is visible or acts; with it on they are all present.
# Static guard: every presentation route/emergency order is a TRAVEL_SHORTCUTS row.
const Release=preload("res://src/presentation/release_controls.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
 for i in 3:await process_frame

static func source_files(dir:String)->Array:
 var found=[]
 for name in DirAccess.get_files_at(dir):
  if name.ends_with(".gd"):found.append(dir.path_join(name))
 for sub in DirAccess.get_directories_at(dir):found.append_array(source_files(dir.path_join(sub)))
 return found

# Lines issuing a route/emergency order through the presentation host, each with
# the TRAVEL:<key> tags it carries. An untagged or unknown key is a failure.
static func audit(text:String,file:String)->Array:
 var problems=[];var call=RegEx.create_from_string("_order\\(\\s*\"(route|emergency)\"");var tag=RegEx.create_from_string("TRAVEL:([a-z_]+)")
 var lines=text.split("\n")
 for n in lines.size():
  if call.search(lines[n])==null:continue
  var keys=tag.search_all(lines[n]).map(func(m):return m.get_string(1))
  if keys.is_empty():problems.append("%s:%d untagged travel order"%[file,n+1])
  for key in keys:
   if not Release.TRAVEL_SHORTCUTS.has(key):problems.append("%s:%d unknown TRAVEL:%s"%[file,n+1,key])
 return problems

func run():
 root.size=Vector2i(2520,1080)
 # Static guard over the whole game source (presentation, main and flows).
 var problems=[];var seen={}
 for file in source_files("res://src"):
  var text=FileAccess.get_file_as_string(file)
  problems.append_array(audit(text,file))
  for m in RegEx.create_from_string("TRAVEL:([a-z_]+)").search_all(text):seen[m.get_string(1)]=true
 check(problems.is_empty(),"every presentation route/emergency order is registered: "+str(problems))
 for key in Release.TRAVEL_SHORTCUTS:check(seen.has(key),"registered shortcut has a tagged call site "+key)
 check(not audit("x._order(\"route\",{\"point\":p})","probe").is_empty(),"guard fails an unregistered one-press route order")
 check(not audit("x._order( \"emergency\" ,{})  # TRAVEL:teleport","probe").is_empty(),"guard fails an unknown shortcut key")
 check(Release.TRAVEL_SHORTCUTS.keys().filter(func(k):return not Release.TRAVEL_SHORTCUTS[k].dev_only)==["water_leg","water_leg_confirm"],"only placed legs are release travel")

 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://release-controls.save";g.capture_scenario="runtime-test"
 root.add_child(g);await frames();g.set_process(false)
 if g.get_node_or_null("Frontend")!=null:g.get_node("Frontend")._dismiss()
 var hud=g.mission_hud
 # Op set covers sites, wreck/material, plant, habitat, salvage and recovery mouths.
 for op in [0,8,10,15,17,22]:
  for dev in [false,true]:
   g._start_mission(op);g._enter_water();g.sim.paused=true
   g.set_meta("dev_profile",dev);g.sim.mission["dev"]=dev
   var origin:Vector2=g.sim.units[0].pos
   g.sim.mission.module_recovery.modules["drone_sampler"]={"state":"salvage","unit":-1,"pos":origin+Vector2(200,0)}
   var subjects={"craft":{},"route":{},"glass":{},"choir":{},"acoustics":{},"guard":{},"tools":{}}
   if not g.sim.mission.objectives.is_empty():subjects["object"]={"kind":"objective","index":0,"name":"SITE","pos":g.sim.mission.objectives[0].pos}
   subjects["salvage"]={"kind":"salvage","item":"drone_sampler","name":"FIELD SAMPLER","pos":origin+Vector2(200,0)}
   var habitat=preload("res://src/presentation/shelf_habitat_view.gd").nearest(g.sim)
   if not habitat.is_empty():subjects["habitat"]=habitat
   var plant=preload("res://src/presentation/warning_chain_view.gd").context(g.sim)
   if not plant.is_empty():
    var station=plant.stations[0];subjects["plant"]={"kind":"plant","station":station.id,"name":station.name,"pos":station.pos}
   var shown={}
   for unit in 3:
    g.sim.command("select",{"unit":unit})
    for page in subjects:
     if page=="glass" and g.sim.glass_context().is_empty():continue
     if page=="choir" and g.sim.choir_context().is_empty():continue
     hud.open(page,subjects[page] if not subjects[page].is_empty() else {"kind":"craft","unit":unit,"pos":g.sim.units[unit].pos});g._refresh()
     var controls=hud.command_controls()
     for key in Release.shortcut_controls(hud):
      var b=Release.shortcut_controls(hud)[key]
      if b in controls and b.is_visible_in_tree():shown[key]=true
     if not dev:
      check(not Release.shortcut_controls(hud).values().any(func(b):return b in controls or b.is_visible_in_tree()),"release op%d unit%d page %s shows no travel shortcut"%[op,unit,page])
     if page=="route":check(hud.extra.recall in controls and hud.extra.recall.is_visible_in_tree() and hud.extra.recall.text.begins_with("RECALL"),"RECALL on route page op%d unit%d dev=%s"%[op,unit,dev])
     if page in ["glass","choir"]:check(hud.extra.depth_up in controls and hud.extra.depth_down in controls,"work page carries depth pair op%d %s"%[op,page])
    hud.dismiss()
   if dev:
    check(shown.has("withdraw_home") and shown.has("route_here"),"dev state shows WITHDRAW autopilot and ROUTE HERE op%d"%op)
    if not g.sim.glass_context().is_empty():check(shown.has("glass_route"),"dev state shows glass route op%d"%op)
    if not g.sim.choir_context().is_empty():check(shown.has("choir_route"),"dev state shows choir route op%d"%op)
   else:check(shown.is_empty(),"release op%d shows no shortcut on any page: %s"%[op,shown.keys()])
   # Direct invocation paths refuse in release and act in dev.
   g.sim.command("select",{"unit":0})
   var before=g.sim.route_goals().duplicate(true)
   g._recovery_route()
   if not dev:check(g.sim.route_goals()==before and g.sim.units[0].route.is_empty(),"release WITHDRAW autopilot installs nothing op%d"%op)
   else:check(not g.sim.units[0].route.is_empty() or hud.page=="recovery","dev WITHDRAW still routes or opens chooser op%d"%op)
   if hud.page=="recovery" and not hud.recovery_buttons.is_empty():
    hud._recovery_choice(g.sim.mission.extraction)
   g.sim.units[0].route=[];g.sim.units[0].erase("route_plan");hud.dismiss()
   if subjects.has("object"):
    hud.open("object",subjects.object);hud._extra("route_here")
    if not dev:check(g.sim.units[0].route.is_empty(),"release ROUTE HERE invocation installs nothing op%d"%op)
    hud.dismiss();g.sim.units[0].route=[];g.sim.units[0].erase("route_plan")
   check(Release.allowed(g,"module_return")==dev and Release.allowed(g,"recovery_chooser")==dev and Release.allowed(g,"water_leg"),"shortcut permission follows the one dev state op%d dev=%s"%[op,dev])
   # A chart tap on an object opens its page and never installs a route.
   if subjects.has("object"):
    g.sim.units[0].route=[];g.sim.units[0].erase("route_plan");g._refresh();await frames()
    var point=g.ocean.global_position+g.ocean.screen_position(subjects.object.pos)
    for down in [true,false]:
     var touch=InputEventScreenTouch.new();touch.index=5;touch.position=point;touch.pressed=down
     g._map_event(touch)
    check(g.sim.units[0].route.is_empty(),"object tap installs no route op%d dev=%s"%[op,dev])
    hud.dismiss()
 g.set_meta("dev_profile",false)
 # Placed legs remain the release movement control: one tap, one straight leg.
 g._start_mission(0);g._enter_water();g.sim.paused=true;g.sim.command("select",{"unit":0})
 var start:Vector2=g.sim.units[0].pos;var goal=start+Vector2(160,0)
 hud.guard.tap_water(goal)
 check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos==goal and g.sim.units[0].route.size()==1,"release water tap installs exactly the placed straight leg")
 g.queue_free();await frames()
 print("RELEASE CONTROLS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
