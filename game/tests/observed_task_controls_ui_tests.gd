extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func action(key):
 for control in game.route_editor.find_children("*","Button",true,false):
  if control.get_meta("action","")==key and control.is_visible_in_tree():return control
 return null
func click(control):
 if control==null:return
 var editor=game.route_editor
 if editor.rows.is_ancestor_of(control):editor.row_scroll.ensure_control_visible(control);await settle()
 var point=control.get_global_rect().get_center();var previous=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(false)
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle();Input.set_emulate_touch_from_mouse(previous)
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle();game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="observed-task-ui"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(10)
  game.sim.command("route",{"point":Vector2(650,1120)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(1000,1880)});game._order("program");await settle()
  var panel=game.route_editor
  check(action("task")==null and "STOP" in panel.point_info.text and "task" in panel.point_info.text.to_lower(),"eligible PASS point explains explicit STOP prerequisite without automatic work")
  await click(action("arrival"));var task=action("task")
  check(task!=null,"selected known-receiver STOP exposes contextual TASK/NONE")
  if task==null:game.queue_free();await settle();continue
  var before=game.sim.snapshot();var tail=game.sim.route_goals()[1].duplicate(true)
  await click(task)
  check(action("task_chain_west")!=null and action("task_none")!=null and action("task_back")!=null,"task choice reuses scroll list with explicit receiver/NONE/BACK")
  check(game.sim.snapshot()==before and panel.preview.visible,"opening task choices preserves physical state and route preview")
  check([action("task_chain_west"),action("task_none"),action("task_back")].all(func(button):return panel.row_scroll.get_global_rect().encloses(button.get_global_rect())),"first receiver choice/NONE/BACK all show full touch targets without buried controls")
  var receiver=action("task_chain_west")
  check("4s" in receiver.text and "quiet" in receiver.text.to_lower(),"Quietus option discloses actual quiet four-second local work")
  await click(receiver)
  var goals=game.sim.route_goals()
  check(goals[0].get("task_site","")=="chain_west" and goals[0].stop and goals[1]==tail,"explicit receiver choice attaches only selected STOP and preserves queued withdrawal")
  check(game.sim.selected==0 and game.sim.capture_feedback().unit<0 and game.sim.paused,"planning neither starts capture nor resumes or selects another craft")
  check("WEST" in panel.point_info.text and "4s" in panel.point_info.text and "quiet" in panel.point_info.text.to_lower(),"selected task remains named and costed after chooser closes")
  check("TASK" in action("goal0").text,"route list retains task intent outside chooser")
  check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(panel.get_global_rect()),"closing chooser cannot grow planner beyond viewport")
  await click(action("arrival"));check(game.sim.route_goals()[0].stop and "TASK" in panel.point_info.text.to_upper(),"PASS cannot silently discard attached physical task")
  await click(action("task"));await click(action("task_none"));check(not game.sim.route_goals()[0].has("task_site") and game.sim.route_goals()[1]==tail,"explicit NONE removes task without changing queued return")
  await click(action("undo"));check(game.sim.route_goals()[0].get("task_site","")=="chain_west","ordinary UNDO restores chosen task intent")
  await click(action("task"));before=game.sim.snapshot();await click(action("task_back"));check(game.sim.snapshot()==before and action("goal0")!=null,"BACK restores route rows without changing task or physical work")
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  for key in ["task","propulsion","arrival","close"]:
   var button=action(key);check(button!=null and Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(button.get_global_rect()) and button.size.x*scale.x>=125.99 and button.size.y*scale.y>=125.99,"contextual planner target stays visible48dp: "+key)
  await click(action("craft1"));game.sim.command("route",{"point":Vector2(650,1120)});panel.refresh();await settle()
  check(action("task")==null,"unfitted drone at the same planned receiver point gains no fictional task")
  # Explicit launch-fit fixture exercises public availability and displayed cost;
  # genuine earned fitting is covered by the external Main profile captures.
  game.fitted_equipment={"quietus":"","drone_a":"drone_sampler","drone_b":""};game._start_mission(10);game.sim.command("select",{"unit":1})
  game.sim.command("route",{"point":Vector2(650,1120)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(1000,1880)});game._order("program");await settle()
  panel=game.route_editor;await click(action("arrival"));await click(action("task"));receiver=action("task_chain_west")
  check(receiver!=null and "8s" in receiver.text and "AUDIBLE" in receiver.text,"fitted drone choice discloses actual eight-second audible fieldwork")
  before=game.sim.snapshot();await click(receiver)
  check(game.sim.route_goals()[0].get("task_site","")=="chain_west" and game.sim.capture_feedback().unit<0 and game.sim.tools==before.tools,"fitted drone attaches future work without immediate capture or spend")
  check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(panel.get_global_rect()) and action("undo").get_global_rect().end.y<=root.get_visible_rect().size.y,"fitted drone task disclosure keeps bottom edit targets inside viewport")
  game.sim.paused=false
  for tick in 740:game.sim.advance(1./60)
  game.sim.paused=true
  check(game.sim.capture_feedback().unit==1,"ordinary planned approach starts canonical drone work before interruption")
  game.sim.command("contact_hold");var manual_guard=game.sim.units[1].hold;panel.refresh();await settle()
  check("BLOCKED" in panel.point_info.text and "TASK" in panel.point_info.text and "guard" in panel.point_info.text.to_lower(),"interrupted task explains explicit rearm and retained guard authority")
  await click(action("task"));await click(action("task_chain_west"))
  check(not game.sim.units[1].has("task_run") and game.sim.units[1].hold==manual_guard and game.sim.capture_feedback().unit<0,"explicit rearm clears blocked bookkeeping without changing the explicit manual guard or starting work")
  await click(action("task"));before=game.sim.snapshot();var selected=panel.selected_goal
  root.size=Vector2i(2184,1968) if dimensions.x==2520 else Vector2i(2520,1080);await settle()
  check(game.sim.snapshot()==before and panel.selected_goal==selected and action("task_none")!=null,"resize keeps task choice and paused intent without implicit assignment")
  await click(action("task_back"));root.size=dimensions;await settle()
  game._start_mission(12);game.sim.command("route",{"point":Vector2(1780,2040)});game._order("program");await settle()
  check(action("task")==null,"known optional machinery never becomes silently queued receiver work")
  game._start_mission(9);game.sim.command("route",{"point":Vector2(480,620)});game._order("program");await settle()
  check(action("task")==null and game.sim.observable_sites().is_empty(),"unobserved carrier coordinates cannot become task choices")
  game.queue_free();await settle()
 print("OBSERVED TASK CONTROLS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
