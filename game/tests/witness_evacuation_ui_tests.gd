extends SceneTree
# Source-known own-position fixtures exercise the real model and ordinary touch.
# This is not an earned campaign journey or a blind player preference test.
const BERTH=Vector2(1840,760)
const HOME=Vector2(2260,2700)
const Store=preload("res://src/persistence/save_store.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
var capture_dir=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for frame in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.index=id;e.position=point;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse(point:Vector2,down:bool):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:await touch(point,down);await mouse(point,down)
 await settle()
func drag(point:Vector2,delta:Vector2,id:int=0):
 var e=InputEventScreenDrag.new();e.index=id;e.position=point+delta;e.relative=delta;root.push_input(e,true);await process_frame
func advance(sim,seconds:float):
 sim.paused=false
 for frame in ceili(seconds*60):sim.advance(1./60.)
 sim.paused=true
func progress()->Dictionary:
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch","confluence_route":"concealed"},"completed":[6,7,9,11],"notes":{},"references":{},"entitlements":["quietus_vector_drive","drone_deep_cells","quietus_baffles"],"history":[],"selected_thread":"deep"}
func game_for(dimensions:Vector2i,fitted:bool=false,prior:Dictionary={}):
 root.size=dimensions;await settle()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="witness-evacuation-ui"
 if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(g);await settle();g.set_process(false)
 g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition=progress() if prior.is_empty() else prior.duplicate(true);g.upgrade="endurance"
 if fitted:g.fitted_equipment.drone_a="drone_deep_cells"
 g._start_mission(12);g.sim.sirens=[]
 # These source-known positions isolate local custody, not voyage finishability.
 g.sim.units[0].pos=HOME+Vector2(-200,-20);g.sim.units[0].vel=Vector2.ZERO
 g.sim.units[2].pos=HOME+Vector2(-260,0);g.sim.units[2].vel=Vector2.ZERO
 g._refresh();await settle();return g
func measure(g,unit:int=1):
 g.sim.units[unit].pos=BERTH+Vector2(0,40);g.sim.units[unit].vel=Vector2.ZERO
 g.sim.command("select",{"unit":unit});advance(g.sim,.02);g.ocean.focus_craft();g._refresh();await settle()
func open_pod(g)->bool:
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 var markers=g.ocean.salvage_markers().filter(func(m):return m.site.get("witness",false))
 if markers.is_empty():check(false,"known occupied pod has a reachable physical target");return false
 await tap(g.ocean.global_position+markers[0].rect.get_center())
 check(g.mission_hud.page=="salvage","touching occupied pod opens its object context")
 return g.mission_hud.page=="salvage"
func select_craft(g,unit:int,open:bool=false):
 if g.advanced_orders:g.mission_hud.dismiss();await settle()
 await tap(g.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 if open and not g.advanced_orders:await tap(g.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 # A craft badge overlapping local work opens the owner chooser first.
 # Select that craft explicitly before the existing witness/action taps.
 if g.mission_hud.page=="choose":
  var hud=g.mission_hud
  var index=hud.target_choices.find_custom(func(c):return c.get("kind","")=="craft" and c.get("unit",-1)==unit)
  check(index>=0,"owner chooser retains requested craft")
  if index>=0:await tap(hud.target_buttons[index].get_global_rect().get_center())
 if not open and g.advanced_orders:g.mission_hud.dismiss();await settle()
func rejected(g,button,kind:String):
 var before=g.sim.snapshot();var point=button.get_global_rect().get_center()
 await touch(point,true);await mouse(point,true)
 if kind=="short drag":
  await drag(point,Vector2(20,0));await touch(point+Vector2(20,0),false);await mouse(point+Vector2(20,0),false)
 elif kind=="cancel":await touch(point,false,0,true);await mouse(point,false)
 else:
  await touch(point+Vector2(100,0),true,1);await touch(point,false);await mouse(point,false);await touch(point+Vector2(100,0),false,1)
 await settle()
 check(g.sim.snapshot()==before,"rejected "+kind+" plus emulated release issues no witness or water order")
func target_fits(g,button,label:String):
 var scale=Vector2(root.size)/root.get_visible_rect().size
 check(g.get_global_rect().encloses(button.get_global_rect()) and button.size.x*scale.x>=125.99 and button.size.y*scale.y>=125.99,label+" retains a full48dp safe-area target")
func reading(g,unit:int)->Dictionary:
 for row in g.mission_hud.fleet.readouts:
  if row.unit==unit:return row
 return {}
func capture(name:String):
 if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func berth_and_custody(dimensions:Vector2i,label:String):
 var g=await game_for(dimensions);var s=g.sim
 var before=s.snapshot();g.ocean.fit_chart();g._refresh();await settle()
 var hidden=g.ocean.pick_context(g.ocean.screen_position(BERTH),g.ui_touch_height)
 check(not s.witness_status().known and s.witness_status().capsule.is_empty() and g.ocean.salvage_markers().is_empty() and hidden.get("kind","")!="salvage","unmeasured initial berth exposes no hidden occupied-pod target "+label)
 check(s.snapshot()==before,"drawing and querying unknown witness presentation earns no observation or simulation time "+label)
 await measure(g)
 check(s.witness_status().known,"real local observation locates occupied berth "+label)
 if not await open_pod(g):g.queue_free();await settle();return
 check("WINCH" in g.mission_hud.extra.salvage.text and "WITNESS" in g.mission_hud.extra.salvage.text,"measured occupied berth names WINCH WITNESS "+label)
 target_fits(g,g.mission_hud.extra.salvage,"WINCH WITNESS "+label);await capture(label+"-occupied-berth")
 for gesture in ["short drag","cancel","pinch"]:
  if await open_pod(g):await rejected(g,g.mission_hud.extra.salvage,gesture)
 if not await open_pod(g):g.queue_free();await settle();return
 await tap(g.mission_hud.extra.salvage.get_global_rect().get_center())
 check(not s.witness_status().jobs[1].is_empty() and s.noises.filter(func(n):return n.label=="RECOVERY WINCH").size()==1,"touch starts one real local audible occupied-pod winch "+label)
 advance(s,1.5);g._refresh();await settle()
 check("WITNESS" in g.mission_hud.fleet.task(1) and reading(g,1).get("progress",{}).get("unit",-1)==1,"selected actual carrier shows its own living-witness work "+label)
 await select_craft(g,2)
 check(s.selected==2 and "WITNESS" in g.mission_hud.fleet.task(1) and reading(g,1).get("progress",{}).get("unit",-1)==1,"unselected carrier retains real witness work and progress "+label)
 var store=Store.new();store.path="user://witness-ui-partial-%d.save"%dimensions.x
 var archive=g._archive();var saved=store.save(archive)
 check(saved and store.load_game()==archive,"actual binary archive retains partial witness work "+label)
 if saved:
  check(s.restore(store.load_game().active),"binary witness work restores into actual simulation "+label)
  g._refresh();await settle()
  check("WITNESS" in g.mission_hud.fleet.task(1) and reading(g,1).get("progress",{}).get("unit",-1)==1,"restored partial work reappears on its actual carrier "+label)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 advance(s,2.6);g._refresh();await settle()
 check(s.witness_status().capsule.carrier==1 and s.witness_status().cargo==[[],["witness_capsule"],[]],"real completed winch loads only its actual drone "+label)
 check("WITNESS" in g.mission_hud.fleet.task(1) and reading(g,1).get("cues",[]).has("WITNESS") and not "INACTIVE" in g.mission_hud.fleet.task(1),"living passenger has persistent actual-carrier cargo cue "+label)
 var old=g.ocean.objective_context(g.ocean.screen_position(BERTH),g.ui_touch_height)
 check(old.get("kind","")!="objective" and g.ocean.salvage_markers().is_empty(),"loaded witness leaves no generic ghost objective at the initial berth "+label)
 await select_craft(g,1,true)
 var land=g.mission_hud.extra.get("witness_land")
 check(land!=null and land.is_visible_in_tree() and land.disabled,"remote actual carrier offers explicit disabled LAND WITNESS "+label)
 if land!=null and land.is_visible_in_tree():
  target_fits(g,land,"remote LAND WITNESS "+label);before=s.snapshot();await tap(land.get_global_rect().get_center());check(s.snapshot()==before,"disabled remote LAND cannot teleport the occupant "+label)
 if g.advanced_orders:g.mission_hud.dismiss()
 s.units[1].pos=HOME+Vector2(0,35);s.units[1].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle()
 # Touch the harbour's own coordinate beside its local carrier.
 await tap(g.ocean.global_position+g.ocean.screen_position(HOME));land=g.mission_hud.extra.get("witness_land")
 check(land!=null and land.is_visible_in_tree() and not land.disabled,"harbour object offers ready local LAND WITNESS "+label)
 if land!=null and land.is_visible_in_tree() and not land.disabled:
  target_fits(g,land,"local LAND WITNESS "+label);await rejected(g,land,"short drag")
  if g.advanced_orders:g.mission_hud.dismiss();await settle()
  await tap(g.ocean.global_position+g.ocean.screen_position(HOME));land=g.mission_hud.extra.get("witness_land")
  if land!=null and land.is_visible_in_tree():await tap(land.get_global_rect().get_center())
  check(s.witness_status().landed and s.witness_status().capsule.landed_by==1,"ordinary harbour touch physically lands actual drone passenger "+label)
  advance(s,.02);g._process(0);await settle()
  check(s.outcome.is_empty() and g.screen=="mission" and s.witness_status().landed,"drone landing leaves real Quietus recovery pending "+label)
  await capture(label+"-landed-harbour")
  preload("res://tests/concealed_fixture.gd").solve(s)
  s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;advance(s,.02);g._process(0);await settle()
  var arrival=g.menu.find_child("WitnessArrival",true,false)
  check(s.outcome=="won" and g.screen=="ending" and arrival!=null,"later Quietus recovery retains genuine visible witness arrival "+label)
 before=s.snapshot();g._refresh();await settle();check(s.snapshot()==before,"paused witness refresh changes no resources work or sensing "+label)
 g.queue_free();await settle()
func shared_wreck(dimensions:Vector2i,label:String):
 var g=await game_for(dimensions,true);var s=g.sim;await measure(g)
 check(s.command("salvage",{"item":"witness_capsule"}),"controlled actual fitted carrier begins loading "+label);advance(s,4.1)
 var lost_at=s.units[1].pos;s.units[1].battery=0;advance(s,.02)
 s.units[0].pos=lost_at+Vector2(0,40);s.units[0].vel=Vector2.ZERO;s.command("select",{"unit":0});g.ocean.focus_craft();g._refresh();await settle()
 var sites=s.salvage_sites();var markers=g.ocean.salvage_markers()
 check(not s.units[1].alive and s.witness_status().capsule.state=="salvage" and s.witness_status().capsule.pos==lost_at,"actual transport exhaustion exposes same pod at known own wreck "+label)
 check(sites.size()==1 and sites[0].get("witness",false) and markers.size()==1,"colocated witness and launched kit share one touch target "+label)
 if not markers.is_empty():
  var lines="\n".join(markers[0].lines)
  check("WITNESS" in lines.to_upper() and "DEEP CELLS" in lines and not "INACTIVE CARGO" in lines,"shared wreck identifies living occupant separately from real kit "+label)
 if await open_pod(g):
  check("WITNESS" in g.mission_hud.extra.salvage.text,"shared recovery action retains living witness identity "+label)
  await tap(g.mission_hud.extra.salvage.get_global_rect().get_center())
  check(s.noises.filter(func(n):return n.label=="RECOVERY WINCH").size()==1 and not s.witness_status().jobs[0].is_empty(),"shared wreck touch starts exactly one audible pod-and-kit winch "+label)
  advance(s,4.1);g._refresh();await settle()
  check(s.witness_status().cargo[0]==["witness_capsule"] and s.module_recovery_status().cargo[0]==["drone_deep_cells"] and not s.units[1].alive and s.salvage_sites().is_empty(),"one completed shared winch recovers occupant and inert kit without reviving carrier "+label)
  check(reading(g,0).get("cues",[]).has("WITNESS") and reading(g,0).get("cues",[]).has("KIT"),"recovered living witness and inert kit keep distinct actual-carrier cues "+label)
 await capture(label+"-shared-wreck-rescue");g.queue_free();await settle()
func already_home(dimensions:Vector2i,label:String):
 var g=await game_for(dimensions);var s=g.sim;await measure(g)
 check(s.command("salvage",{"item":"witness_capsule"}),"controlled arrival fixture loads real occupied pod "+label);advance(s,4.1)
 preload("res://tests/concealed_fixture.gd").solve(s)
 s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;s.units[1].pos=HOME+Vector2(0,35);s.units[1].vel=Vector2.ZERO
 g.ocean.focus_craft();g._refresh();await settle();await select_craft(g,1,true)
 var land=g.mission_hud.extra.get("witness_land")
 check(land!=null and land.is_visible_in_tree() and not land.disabled,"already-home Quietus still requires actual carrier's local LAND touch "+label)
 if land!=null and land.is_visible_in_tree() and not land.disabled:
  await tap(land.get_global_rect().get_center());advance(s,.02);g._process(0);await settle()
  var arc=g.get_node_or_null("ArcCard")
  if arc!=null:
   var continue_controls=arc.find_children("*","Button",true,false)
   check(not continue_controls.is_empty(),"arc departure offers touch Continue before arrival feedback "+label)
   if not continue_controls.is_empty():await tap(continue_controls[0].get_global_rect().get_center())
  var arrival=g.menu.find_child("WitnessArrival",true,false)
  check(s.outcome=="won" and g.screen=="ending" and arrival!=null and arrival.is_visible_in_tree(),"same-frame ending cannot erase real witness arrival feedback "+label)
  if arrival!=null:
   check(arrival.get("arrival_data").get("landed_by",-1)==1,"arrival illustration belongs to actual landing carrier "+label)
  await capture(label+"-already-home-arrival")
 g.queue_free();await settle()
func optional_sluice(dimensions:Vector2i,label:String):
 var g=await game_for(dimensions);var s=g.sim;await measure(g)
 s.units[0].pos=Vector2(1780,2000);s.units[0].vel=Vector2.ZERO;s.command("select",{"unit":0})
 g.ocean.focus_craft();g._refresh();await settle()
 await tap(g.ocean.global_position+g.ocean.screen_position(Vector2(1780,2040)))
 check(g.mission_hud.page=="object" and g.order_buttons.camera.is_visible_in_tree() and not g.order_buttons.camera.disabled,"optional sluice retains its own ready local operation control "+label)
 if g.order_buttons.camera.is_visible_in_tree() and not g.order_buttons.camera.disabled:
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  check(s.capture_feedback(0).unit==0 and s.witness_status().jobs==[{},{},{}],"sluice OPERATE touch cannot be intercepted by known witness berth "+label)
  advance(s,4.1);g._refresh();await settle()
  check(s.mission.physical_gates[0].opened and s.witness_status().capsule.state=="at_berth","real optional sluice operation opens physical passage without moving the witness "+label)
 g.queue_free();await settle()
func committed_quietus()->Dictionary:
 # Earn the first arrival through actual model loading, landing and recovery.
 var s=Sim.new();s.start(12,"endurance");s.sirens=[];s.units[0].pos=BERTH+Vector2(0,40);s.units[0].vel=Vector2.ZERO;advance(s,.02)
 s.command("salvage",{"item":"witness_capsule"});advance(s,4.1);preload("res://tests/concealed_fixture.gd").solve(s);s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;s.command("witness_land");advance(s,.02)
 return Campaign.recover(progress(),s.mission)
func retained_truth(dimensions:Vector2i,label:String):
 var first=committed_quietus();check(first.facts.get("witness_arrival","")=="quietus","replay fixture earns its first Quietus arrival through physical model actions "+label)
 var g=await game_for(dimensions,false,first);var s=g.sim;await measure(g)
 s.command("salvage",{"item":"witness_capsule"});advance(s,4.1)
 preload("res://tests/concealed_fixture.gd").solve(s)
 s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;s.units[1].pos=HOME+Vector2(0,35);s.units[1].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle();await select_craft(g,1,true)
 var land=g.mission_hud.extra.get("witness_land")
 check(land!=null and land.is_visible_in_tree() and not land.disabled,"completed replay retains actual local carrier landing interaction "+label)
 if land!=null and land.is_visible_in_tree() and not land.disabled:
  await tap(land.get_global_rect().get_center());advance(s,.02);g._process(0);await settle()
  var arrival=g.menu.find_child("WitnessArrival",true,false)
  check(s.outcome=="won" and g.expedition.facts.get("witness_arrival","")=="quietus" and arrival!=null and arrival.get("arrival_data").get("landed_by",-1)==1,"replay arrival shows this actual drone landing while preserving first committed Quietus history "+label)
 g.queue_free();await settle()
 g=await game_for(dimensions);s=g.sim;await measure(g);s.command("salvage",{"item":"witness_capsule"});advance(s,4.1)
 s.units[1].pos=HOME+Vector2(0,35);s.units[1].vel=Vector2.ZERO;g.ocean.focus_craft();g._refresh();await settle();await select_craft(g,1,true);land=g.mission_hud.extra.get("witness_land")
 check(land!=null and land.is_visible_in_tree() and not land.disabled,"loss fixture still requires explicit actual local landing "+label)
 if land!=null and land.is_visible_in_tree() and not land.disabled:
  await tap(land.get_global_rect().get_center());s.hull=0;advance(s,.02);g._process(0);await settle()
  var arrival=g.menu.find_child("WitnessArrival",true,false)
  check(s.outcome=="lost" and s.witness_status().landed and arrival!=null and not g.expedition.facts.has("witness_arrival"),"lost Quietus debrief preserves actual safe passenger without granting successful campaign arrival "+label)
  check(g.panel_box.find_children("*","Label",true,false).any(func(l):return "Quietus did not recover" in l.text),"loss debrief states that passenger landing did not recover Quietus "+label)
 g.queue_free();await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(capture_dir)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  var label="cover" if dimensions.x==2520 else "inner"
  await berth_and_custody(dimensions,label)
  await shared_wreck(dimensions,label)
  await already_home(dimensions,label)
  await optional_sluice(dimensions,label)
  await retained_truth(dimensions,label)
 print("WITNESS EVACUATION UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
