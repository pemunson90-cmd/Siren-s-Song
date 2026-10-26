extends SceneTree
# Hull, chassis, typed mount and budget loadouts: model rules, actual simulation
# consequences of each budget, save schema and the briefing frame controls.
const Sim=preload("res://src/simulation/simulation.gd")
const Kit=preload("res://src/equipment/equipment_catalog.gd")
const Upgrades=preload("res://src/equipment/craft_upgrades.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
const View=preload("res://src/presentation/equipment_context.gd")
var checks=0
var failures=0
var game
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func open(fitted:Dictionary,index:int=0):
 var s=Sim.new();s.start(index,"endurance",{"fitted":fitted});s.sirens=[];s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 return s
func model():
 var all=Kit.ITEMS.keys()
 check(Kit.ITEMS.values().all(func(i):return i.mount in Kit.Hulls.MOUNT_TYPES and i.power is int and i.cargo is int and i.has_all(["noise","endurance"])),"every fitting declares a typed mount and budget costs")
 check(Kit.Hulls.HULLS.size()==3 and Kit.Chassis.CHASSIS.size()==4,"three hulls and four drone chassis")
 var base=Kit.default_loadout()
 check(Kit.valid_fitting(base) and Kit.valid_fitting({}) and Kit.valid_fitting({"quietus":"","drone_a":"","drone_b":""}),"default, absent and original three-key fits are the standard loadout")
 for unit in 3:
  var f=Kit.frame(base,unit)
  check(f.noise==1.0 and f.endurance==1.0 and f.get("speed",1.0)==1.0 and f.get("reach",1.0)==1.0 and f.pulse==1.0 and f.cargo==2,"standard frame reproduces the authored baseline for unit "+str(unit))
 for item in all:
  var slot=Kit.ITEMS[item].compatible_slots[0];var single={slot:item}
  check(Kit.valid_fitting(single) and Upgrades.pulse_cost(single,Kit.SLOTS.find(slot))==1.0,"each original single fitting stays legal on its standard frame without a new pulse cost: "+item)
 check(Kit.reason({"hull":"quiet","quietus":"quietus_baffles"}).contains("PROPULSION mount"),"wrong mount is refused with a reason")
 check(Kit.reason({"quietus":"quietus_prism","quietus_2":"quietus_correlator"}).contains("SENSOR mount"),"two items cannot share one typed mount")
 check(Kit.valid_fitting({"hull":"fast","quietus":"quietus_prism","quietus_2":"quietus_correlator","quietus_3":"quietus_baffles","quietus_4":"quietus_decoder"}),"fast hull carries two sensors within its five point bus")
 check(Kit.reason({"quietus":"quietus_prism","quietus_2":"quietus_vector_drive"}).contains("over power budget 4 / 3"),"over power fit is refused with its budget")
 check(Kit.reason({"chassis_a":"scout","drone_a":"drone_traction_yoke"})!="","scout chassis has no cargo mount for the traction yoke")
 check(Kit.reason({"chassis_a":"endurance","drone_a":"drone_survey_array","drone_a_2":"drone_sampler"})!="","long endurance chassis refuses a second powered fitting")
 check(Kit.reason({"chassis_a":"heavy","drone_a":"drone_traction_yoke","drone_a_2":"drone_sampler","drone_a_3":"drone_deep_cells"}).is_empty(),"heavy chassis carries yoke, sampler and cells together")
 check(not Kit.valid_fitting({"hull":"submarine"}) and not Kit.valid_fitting({"chassis_a":"standard","chassis_c":"standard"}) and not Kit.valid_fitting({"hull":3}),"unknown frames and keys are malformed")
 check(not Kit.valid_fitting({"drone_a":"drone_sampler","drone_b_2":"drone_sampler"}),"one physical module cannot be fitted twice")
 # choose: adds into a free mount, swaps a same-type item, refuses with a reason.
 var pick=Kit.choose(base,"quietus","quietus_baffles",all)
 pick=Kit.choose(pick.fitted,"quietus","quietus_decoder",all)
 check(pick.ok and Kit.has(pick.fitted,0,"quietus_baffles") and Kit.has(pick.fitted,0,"quietus_decoder"),"second fitting enters a free typed mount")
 var swap=Kit.choose(pick.fitted,"quietus","quietus_vector_drive",all)
 check(swap.ok and Kit.has(swap.fitted,0,"quietus_vector_drive") and not Kit.has(swap.fitted,0,"quietus_baffles"),"same mount choice swaps the propulsion fitting")
 var refused=Kit.choose(swap.fitted,"quietus","quietus_prism",all)
 check(not refused.ok and "power" in refused.reason,"over budget choice is refused with a reason")
 var frame=Kit.choose(pick.fitted,"hull","quiet",all)
 check(not frame.ok and "PROPULSION" in frame.reason,"a hull change that strands a fitting is refused")
 check(Kit.choose(base,"hull","fast",[]).ok and Kit.choose(base,"chassis_b","scout",[]).ok,"frames need no recovered entitlement")
 var b=Kit.budget({"hull":"fast","quietus":"quietus_prism"},0)
 check(b.power==2 and b.power_cap==5 and b.mounts.size()==6 and b.mounts[0].item=="quietus_prism","budget summary places items in typed mounts")
func budgets():
 # NOISE: the same actual drive makes less or more sound.
 var std=open({});var quiet=open({"hull":"quiet"});var loud=open({"hull":"fast","chassis_a":"heavy"})
 for s in [std,quiet,loud]:s.units[0].vel=Vector2(60,0);s.units[1].vel=Vector2(60,0)
 check(absf(quiet.motion_radius(0)-std.motion_radius(0)*0.7)<0.01 and loud.motion_radius(0)>std.motion_radius(0) and loud.motion_radius(1)>std.motion_radius(1),"noise budget scales actual motion sound radius")
 # Speed of the hull frame.
 var fast=open({"hull":"fast"});std=open({})
 # Keep the speed comparison clear of the parked drone now that hull contact slows Quietus.
 for s in [fast,std]:s.units[2].pos=Vector2(280,650);s.units[0].silent=false;s.command("route",{"point":Vector2(900,800)})
 advance(fast,3);advance(std,3)
 check(fast.hull==100 and std.hull==100 and fast.units[0].pos.x>std.units[0].pos.x+8 and absf(fast.units[0].vel.length()-78*1.15)<0.5,"fast hull travels farther in the same time")
 # ENDURANCE: Quietus life support and drone battery.
 var long=open({"hull":"quiet","chassis_a":"endurance"});std=open({})
 advance(long,20);advance(std,20)
 check(long.oxygen>std.oxygen and long.units[1].battery>std.units[1].battery,"endurance budget slows life support and drone battery drain")
 var scout=open({"chassis_b":"scout"});advance(scout,20)
 check(scout.units[2].battery<std.units[2].battery and scout.passive_range(2)>std.passive_range(2),"scout trades battery for passive reach")
 # POWER: a bus drawn to capacity makes each SONAR pulse cost more reserve.
 var spare=open({"quietus":"quietus_decoder"});var full=open({"quietus":"quietus_decoder","quietus_2":"quietus_correlator","quietus_3":"quietus_baffles"})
 var before=[spare.oxygen,full.oxygen];Sonar.emit(spare,0);Sonar.emit(full,0)
 check(absf((before[1]-full.oxygen)-(before[0]-spare.oxygen)*1.5)<0.0001 and before[0]-spare.oxygen>0,"full power bus makes a SONAR pulse cost half again as much reserve")
 var cheap=open({"hull":"fast"});var o=cheap.oxygen;Sonar.emit(cheap,0)
 check(o-cheap.oxygen<before[0]-spare.oxygen,"fast hull power makes pulses cheaper")
 # CARGO: winch places limit how many lost modules a craft carries home.
 var fitted={"hull":"quiet","drone_a":"drone_deep_cells","drone_b":"drone_survey_array"}
 for hull in ["standard","quiet"]:
  fitted.hull=hull;var s=open(fitted);s.units[1].pos=Vector2(300,800);s.units[2].pos=Vector2(330,800);s.units[1].battery=0;s.units[2].battery=0;advance(s,Sim.STEP)
  s.units[0].pos=Vector2(300,830);s.units[0].vel=Vector2.ZERO;s.units[0].route=[]
  check(s.command("salvage",{"item":"drone_deep_cells"}),"first lost module winches aboard "+hull);advance(s,4.2)
  s.units[0].vel=Vector2.ZERO
  var second=s.salvage_context("drone_survey_array",0)
  if hull=="standard":check(second.ready,"standard hull keeps its two winch places")
  else:check(not second.ready and "cargo" in second.reason,"low noise hull has one winch place: "+second.reason)
func saves():
 var path="user://loadout-frames-test.save";var store=Store.new();store.path=path
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(path+suffix)
 var fit=Kit.canonical({"hull":"quiet","chassis_a":"scout","chassis_b":"heavy","quietus":"quietus_vector_drive","drone_b":"drone_deep_cells"})
 var bad_mount=fit.duplicate();bad_mount.drone_b="";bad_mount.quietus_2=""
 var s=Sim.new();s.start(1,"endurance",{"fitted":Kit.canonical({"hull":"fast","chassis_b":"heavy","quietus":"quietus_vector_drive","drone_b":"drone_deep_cells"})})
 var data={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"equipment":Kit.canonical({"hull":"fast","chassis_a":"scout","quietus":"quietus_vector_drive","drone_b":"drone_deep_cells"}),"active":s.snapshot()}
 check(store.save(data),"current loadout schema saves")
 var loaded=store.load_game()
 check(loaded.equipment==data.equipment and loaded.active.mission.launch_equipment.hull=="fast" and loaded.active.mission.launch_equipment.chassis_b=="heavy","hull, chassis and mounts round-trip through the binary archive")
 var restored=Sim.new();check(restored.restore(loaded.active) and restored.mission.launch_equipment==s.mission.launch_equipment and absf(Upgrades.cruise_speed(restored.mission.launch_equipment)-112*1.15)<0.001,"restored dive keeps its launched hull budget")
 var old={"version":1,"unlocked":1,"completed":[0],"upgrade":"endurance","settings":{},"equipment":{"quietus":"","drone_a":"","drone_b":""}}
 check(store.valid(old),"version 1 single-slot archives stay valid within a campaign")
 for suffix in [".tmp",".bak"]:DirAccess.remove_absolute(path+suffix)
 check(store.save(old) and store.load_game()==old and Kit.valid_fitting(Kit.canonical(store.load_game().equipment)),"a version 1 archive loads and reads as standard frames")
 var over=data.duplicate(true);over.equipment=Kit.canonical({"hull":"quiet","quietus":"quietus_vector_drive"})
 check(not store.valid(over),"an archive with a wrong-mount loadout is rejected")
 var heavy=data.duplicate(true);heavy.active.mission.launch_equipment.quietus_2="quietus_prism";heavy.active.mission.launch_equipment.quietus_3="quietus_decoder";heavy.active.mission.launch_equipment.quietus_4="quietus_pressure_sleeve"
 check(not Sim.valid_snapshot(heavy.active),"an active dive with an over-budget launch loadout is rejected")
 var unearned=data.duplicate(true);unearned.equipment.quietus_2="quietus_decoder"
 check(not store.valid(unearned),"unrecovered items in an extra mount are rejected")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(path+suffix)
func frame_button(unit:String,id:String="quiet") :
 for control in game.panel_box.get_children():
  if control is Button and control.get_meta("action","")=="frame_"+unit+"_"+id:return control
 return null
func fit_button(slot:String,name:String):
 for control in game.panel_box.get_children():
  if control is Button and control.get_meta("action","")=="fit_"+slot and name in control.text:return control
 return null
func tap(control):
 game.scroll.ensure_control_visible(control);await settle()
 var p=control.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=p;motion.global_position=p;root.push_input(motion,true)
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func ui():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="loadout-frames-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[];game._briefing(0);await settle()
  check(frame_button("quietus")==null,"first briefing stays free of frame choices")
  game.completed=[0];game.unlocked=1;game.expedition={"completed":[],"entitlements":["quietus_prism","quietus_decoder"]}
  game._briefing(1);await settle()
  var hull=frame_button("quietus")
  check(hull!=null and "LOW NOISE HULL" in hull.text,"briefing lists the low noise hull directly")
  var width=game.scroll.get_global_rect()
  check(game.panel_box.get_children().all(func(c):return not c is Control or c.get_global_rect().size.x<=width.size.x+1),"frame rows and budget bars fit the briefing width")
  await tap(hull)
  check(game.fitted_equipment.hull=="quiet" and game.screen=="briefing","tapping the hull row selects the low noise hull")
  await tap(fit_button("quietus","Reach directional prism"))
  check(Kit.has(game.fitted_equipment,0,"quietus_prism"),"prism fits the low noise hull sensor mount")
  var decoder=fit_button("quietus","Range service decoder")
  check(decoder.disabled and "REFUSED" in decoder.text and "POWER" in decoder.text,"over budget decoder row is refused with its power reason: "+decoder.text)
  hull=frame_button("quietus","fast")
  check(hull!=null and not hull.disabled and "FAST TRANSIT HULL" in hull.text,"the legal fast hull stays available as a named choice")
  await tap(frame_button("drone_a","scout"))
  check(game.fitted_equipment.chassis_a=="scout","drone A chassis selects scout directly")
  game._start_mission(1);await settle()
  check(game.sim.mission.launch_equipment.hull=="quiet" and game.sim.mission.launch_equipment.chassis_a=="scout" and Kit.has(game.sim.mission.launch_equipment,0,"quietus_prism"),"launch freezes the chosen hull, chassis and mounts")
  check("LOW NOISE HULL" in View.status(game.sim) and "REACH DIRECTIONAL PRISM" in View.status(game.sim),"in-dive status names the launched hull and fitting")
  game.queue_free();await settle()
func run():
 model();budgets();saves()
 await ui()
 print("LOADOUT FRAMES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
