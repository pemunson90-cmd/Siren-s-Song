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
func click(control,touch:bool=false):
 if control==null:return
 if game.route_editor!=null and game.route_editor.visible and game.route_editor.rows.is_ancestor_of(control):game.route_editor.row_scroll.ensure_control_visible(control);await settle()
 var p=control.get_global_rect().get_center()
 if not touch:
  var motion=InputEventMouseMotion.new();motion.position=p;root.push_input(motion,true)
 for down in [true,false]:
  if touch:
   var e=InputEventScreenTouch.new();e.position=p;e.index=0;e.pressed=down;root.push_input(e,true)
   var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=p;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true)
  else:
   var e=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
  await process_frame
 await settle()
func action(key):
 for c in game.route_editor.find_children("*","Button",true,false):
  if c.get_meta("action","")==key:return c
 return null
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle();game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="program-test";
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
  check(game.order_buttons.has("program"),"program editor has an actual accessible order on "+str(dimensions))
  if not game.order_buttons.has("program"):game.queue_free();await settle();continue
  game.sim.command("route",{"point":Vector2(260,800)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(400,800)});game.sim.paused=false
  game._toggle_advanced();await settle();await click(game.order_buttons.program)
  print("EDITOR_GEOMETRY ",dimensions," viewport=",root.get_visible_rect()," host=",game.size," panel=",game.route_editor.get_global_rect()," min=",game.route_editor.get_combined_minimum_size());
  for key in ["goal1","propulsion","close"]:
   var b=action(key);print("EDITOR_CONTROL ",key," rect=",b.get_global_rect() if b!=null else Rect2())
  check(game.screen=="program" and game.sim.paused and game.route_editor.visible,"pointer opens a paused modal editor")
  var before=game.sim.snapshot();await click(action("goal1"),true)
  check(game.route_editor.selected_goal==1 and game.sim.snapshot()==before,"touch selects individual goal without issuing a world order")
  check(game.route_editor.row_scroll.get_global_rect().encloses(action("goal1").get_global_rect()),"selected program row stays visible after touch and list reflow")
  await click(action("propulsion"),true)
  check(game.sim.route_goals()[1].mode=="cruise","touch programs selected leg propulsion")
  await click(action("arrival"));check(not game.sim.route_goals()[1].stop,"pointer toggles selected arrival PASS")
  await click(action("insert"));check(game.sim.route_goals().size()==3,"pointer inserts an individual goal")
  await click(action("delete"),true);check(game.sim.route_goals().size()==2,"touch deletes an individual goal")
  await click(action("undo"));check(game.sim.route_goals().size()==3,"pointer undo restores deleted point")
  var selected=game.route_editor.selected_goal;var preview=game.route_editor.preview;var rect=preview.chart_rect();var p=preview.global_position+rect.position+rect.size*Vector2(0.15,0.85)
  for down in [true,false]:
   var e=InputEventScreenTouch.new();e.position=p;e.index=0;e.pressed=down;root.push_input(e,true);await process_frame
  await settle();check(game.sim.route_goals()[selected].pos.distance_to(Vector2(240,816))<2,"touch on explicit preview edits only selected point")
  var before_drag=game.sim.snapshot();var start=preview.global_position+preview.chart_rect().get_center()
  var finger=InputEventScreenTouch.new();finger.index=0;finger.position=start;finger.pressed=true;root.push_input(finger,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=start+Vector2(60,0);drag.relative=Vector2(60,0);root.push_input(drag,true)
  finger=finger.duplicate();finger.position=drag.position;finger.pressed=false;root.push_input(finger,true);await settle()
  check(game.sim.snapshot()==before_drag,"dragging editor preview never commits an accidental move")
  var space=InputEventKey.new();space.keycode=KEY_SPACE;space.pressed=true;root.push_input(space,true);await settle()
  check(game.sim.paused,"SPACE cannot resume simulation behind the program modal")
  var plan=game.sim.route_goals();await click(action("craft1"),true);check(game.sim.selected==1 and game.sim.route_goals(0)==plan,"editor craft selection preserves other craft program")
  check(action("propulsion").disabled and "FIXED96" in action("propulsion").text,"drone editor truthfully exposes fixed propulsion without implying a silent speed change")
  await click(action("craft0"));await click(action("close"),true)
  check(game.screen=="mission" and game.sim.paused and game.sim.route_goals()==plan,"closing leaves edited program paused and persistent")
  check("PROGRAM" in game.order_buttons.program.text and "TO 1: INHERIT" in game.detail_label.text,"selected craft program intent persists outside modal")
  game._order("program");await settle()
  var viewport=Rect2(Vector2.ZERO,root.get_visible_rect().size)
  for key in ["propulsion","arrival","insert","delete","undo","close"]:
   var b=action(key);check(b!=null and viewport.encloses(b.get_global_rect()) and b.size.y>=game.ui_touch_height,"density-safe editor control "+key+" "+str(dimensions))
  game.queue_free();await settle()
 print("ROUTE PROGRAM UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
