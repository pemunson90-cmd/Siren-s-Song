extends SceneTree
var checks=0
var failures=0
var captures=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func tap(point,button=false):
 for down in [true,false]:
  var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
  if button:
   var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func click(control):await tap(control.get_global_rect().get_center(),true)
func action(panel,key):
 for b in panel.find_children("*","Button",true,false):
  if b.get_meta("action","")==key:return b
 return null
func capture(name):
 if not captures.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://drone-drive-ui-%d.save"%dimensions.x
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
  var name="cover" if dimensions.x==2520 else "inner"
  var before=g.sim.snapshot();var point=g.ocean.global_position+g.ocean.screen_position(g.sim.units[1].pos)
  await tap(point)
  if g.mission_hud.page=="fleet":await click(g.unit_buttons[1])
  check(g.sim.selected==1 and g.advanced_orders,"touch chooses actual drone identity "+name)
  await click(g.mission_hud.extra.route_menu);await click(g.order_buttons.program)
  check(g.screen=="program" and g.sim.paused,"actual craft ROUTE projection opens paused planner "+name)
  var panel=g.route_editor
  await tap(panel.preview.global_position+panel.preview.screen_position(Vector2(400,700)))
  check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(Vector2(400,700))<2,"touch preview plots first drone destination "+name)
  var mode=action(panel,"propulsion")
  check(not mode.disabled and "INHERIT" in mode.text and "DRIVE TRANSIT96" in panel.info.text,"current legacy drive and inherited incoming choice are readable "+name)
  if mode.disabled:g.queue_free();await settle();continue
  await click(mode);check(g.sim.route_goals()[0].mode=="cruise" and "TRANSIT96" in mode.text,"touch selects fast incoming drive "+name)
  await click(mode);check(g.sim.route_goals()[0].mode=="silent" and "QUIET42" in mode.text and g.sim.units[1].silent,"touch selects quiet drive without changing LOW PROFILE "+name)
  var plan=g.sim.route_goals();var paused=g.sim.snapshot();await settle()
  check(g.sim.snapshot()==paused and paused.elapsed==0,"planning and display frames collect no time or resources "+name)
  await capture(name+"-quiet-plan")
  await click(action(panel,"close"))
  check(g.sim.paused and "QUIET42" in g.detail_label.text and "FIXED96" not in g.detail_label.text,"closed planner keeps incoming drive intent "+name)
  var saved=g.store.load_game();var copy=load("res://src/simulation/simulation.gd").new()
  check(saved.has("active") and copy.restore(saved.active) and copy.route_goals(1)==plan and not copy.units[1].has("drone_drive"),"ordinary save retains unexecuted quiet plan without adding current state "+name)
  g.sim.paused=false
  for n in 180:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  check(g.sim.units[1].get("drone_drive","")=="quiet" and g.sim.units[1].vel.length()<=42.01,"actual planned leg executes quiet thrust "+name)
  var metrics=g._planner_intent_metrics()
  check(metrics.units[1].get("drive","")=="quiet" and metrics.units[1].silent,"diagnostics distinguish actual drive and visual profile "+name)
  check(g.ocean.ship_instrument_layout().any(func(item):return "QUIET42" in item.text),"ship-local instrument identifies current drive "+name)
  point=g.ocean.global_position+g.ocean.screen_position(g.sim.units[1].pos);await tap(point);await click(g.order_buttons.silent)
  check(not g.sim.units[1].silent and g.sim.units[1].drone_drive=="quiet","existing OPEN PROFILE choice cannot change drive "+name)
  await tap(point);await click(g.mission_hud.extra.route_menu);await click(g.order_buttons.program)
  panel=g.route_editor;mode=action(panel,"propulsion")
  check("DRIVE QUIET42" in panel.info.text and "OPEN PROFILE" in panel.info.text,"current drive and independent visual state stay readable "+name)
  await click(mode);await click(mode)
  check(g.sim.route_goals()[0].mode=="cruise","touch can override the accepted current quiet leg to transit "+name)
  await click(action(panel,"undo"));check(g.sim.route_goals()[0].mode=="inherit","touch undo restores preceding incoming intent "+name)
  await click(mode);check(g.sim.route_goals()[0].mode=="cruise","touch transit choice remains available after undo "+name)
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(mode.get_global_rect()) and mode.size.y*scale.y>=125.99,"drive uses existing visible48dp control "+name)
  await capture(name+"-transit-override")
  await click(action(panel,"close"));check(g.sim.paused,"closing propulsion edit leaves tactical pause intact "+name)
  g.queue_free();await settle()
 print("DRONE DRIVE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
