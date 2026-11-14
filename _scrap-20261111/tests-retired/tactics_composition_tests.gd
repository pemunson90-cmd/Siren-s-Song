extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks:=0
var failures:=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(load("res://tests/density_main.gd"));ui.capture_scenario="tactics-composition"
  if dimensions.x==2520:ui.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(ui);await settle();ui.set_process(false)
  ui.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();ui.tool_racks.quietus.knock=2
  ui._start_mission(4);ui.sim.units[0].pos=Vector2(600,750);ui.sim.sirens[0].band=1;ui.sim.sirens[0].pos=Vector2(700,750);ui.sim._observe();ui._toggle_advanced();await settle()
  var planner_visible=ui.order_buttons.program.is_visible_in_tree();ui.mission_hud.open("tools");await settle()
  check(planner_visible and ui.order_buttons.knock.is_visible_in_tree(),"craft planner and contextual torpedo remain independently accessible")
  ui.sim.command("route",{"point":Vector2(820,750)});ui.sim.command("route_edit",{"index":0,"mode":"silent"})
  var before=ui.sim.snapshot();ui._order("knock");check(ui.knock_armed,"targeting can be armed before opening planner")
  ui._order("program");await settle()
  check(not ui.knock_armed and not ui.ocean.knock_targeting,"opening planner cancels armed weapon and target guidance")
  check(ui.screen=="program" and ui.sim.paused and ui.sim.snapshot()==before,"opening planner preserves programmed route, ammo and observed world")
  ui.route_editor.close();await settle()
  check(ui.screen=="mission" and ui.sim.paused and not ui.knock_armed,"closing planner stays paused without rearming a weapon")
  ui.mission_hud.open("craft");await settle()
  var camera_visible=ui.order_buttons.camera.is_visible_in_tree();ui.mission_hud.open("tools");await settle()
  check(camera_visible and ui.order_buttons.emp.is_visible_in_tree(),"contextual camera and disruption remain accessible")
  ui.queue_free();await settle()
 var s=Sim.new();s.start(4);s.units[0].pos=Vector2(600,750);s.units[0].angle=0;s.sirens[0].band=1;s.sirens[0].pos=Vector2(700,750);s._observe()
 s.command("route",{"point":Vector2(820,750)});s.command("route_edit",{"index":0,"mode":"silent"})
 check(s.command("knock",{"target":0}),"new acoustic mission launches physical torpedo alongside programmed route")
 s.paused=false;s.advance(0.1);s.paused=true
 var snapshot=s.snapshot();var store=Store.new();store.path="user://tactics-composition-test.save"
 var archive={"version":1,"unlocked":4,"completed":[],"settings":{},"upgrade":"endurance","active":snapshot}
 check(store.save(archive),"combined flight/program/acoustic state writes actual archive")
 var restored=Sim.new();var loaded=store.load_game()
 check(not loaded.is_empty() and restored.restore(loaded.active) and restored.snapshot()==snapshot,"binary restore preserves flight, programmed intent and acoustic revision together")
 check(restored.mission.acoustic_revision==1 and restored.projectiles.size()==1 and restored.route_goals()[0].mode=="silent","all three mechanics survive the same restore")
 var labels=[]
 for pulse in restored.acoustic_feedback().pulses:labels.append(pulse.label)
 check("KNOCKDOWN" in labels and "TORPEDO RUN" in labels,"launch and in-flight acoustic emissions both survive composition")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 print("TACTICS COMPOSITION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
