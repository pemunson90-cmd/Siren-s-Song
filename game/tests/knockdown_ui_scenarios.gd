extends SceneTree
var capture_dir:=""
var checks:=0
var failures:=0
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",text)
func _initialize() -> void:call_deferred("run")
func wait_frames(count:int=4) -> void:
 for n in count:await process_frame
func click(point: Vector2) -> void:
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true);await process_frame
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await wait_frames()
# Use public touch scrolling and the named contact's visible FIRE target.
func reveal(game,button):
 var hud=game.mission_hud
 if not hud.order_dock.visible or button.get_parent()!=hud.order_dock_commands:return
 var scroll=hud.order_dock_scroll
 for attempt in 8:
  var area=scroll.get_global_rect()
  if area.encloses(button.get_global_rect()):return
  var target=button.get_global_rect()
  var delta=area.position.y-target.position.y if target.position.y<area.position.y else area.end.y-target.end.y
  delta=signf(delta)*clampf(absf(delta),24.,area.size.y*.45)
  var start=area.get_center();var finish=start+Vector2(0,delta)
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=start;touch.pressed=true;root.push_input(touch,true);await process_frame
  var previous=start
  for n in 6:
   var point=start.lerp(finish,float(n+1)/6.)
   var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point;drag.relative=point-previous;root.push_input(drag,true);previous=point;await process_frame
  touch=InputEventScreenTouch.new();touch.index=0;touch.position=finish;touch.pressed=false;root.push_input(touch,true);await wait_frames()
 check(scroll.get_global_rect().encloses(button.get_global_rect()),"touch scrolling reveals "+str(button.get_meta("action","command")))
func action(ui,button):
 await reveal(ui,button)
 await click(button.get_global_rect().get_center())
func contact(ui,key:int):
 var aims=ui.ocean.knock_aim_targets()
 var index=aims.find_custom(func(a):return a.key==key)
 check(index>=0,"fresh contact retains its explicit public FIRE target")
 if index>=0:await click(ui.ocean.global_position+aims[index].rect.get_center())
func setup(ui) -> void:
 # Equip the launcher stock these actual aim/fire/cancel inputs exercise.
 ui.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();ui.tool_racks.quietus.knock=2
 ui._start_mission(4);ui.sim.units[0].band=1;ui.sim.units[0].pos=Vector2(600,750);ui.sim.units[0].angle=0
 for enemy in ui.sim.sirens:enemy.band=1;enemy.transition={}
 ui.sim.sirens[0].pos=Vector2(740,750);ui.sim.sirens[1].pos=Vector2(800,750);ui.sim.paused=false
 for i in 24:ui.sim.advance(1.0/60)
 ui.sim.paused=true;ui.sim._observe();ui.mission_hud.open("tools");ui._refresh()
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for profile in [{"name":"desktop","size":Vector2i(1280,720),"dpi":95.0,"inset":0},{"name":"cover","size":Vector2i(2520,1080),"dpi":420.0,"inset":136},{"name":"inner","size":Vector2i(2184,1968),"dpi":420.0,"inset":0}]:
  root.size=profile.size;await wait_frames()
  var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(preload("res://tests/fit_label_main.gd"));ui.fixture_dpi=profile.dpi;ui.capture_scenario="knockdown-test"
  if profile.inset:ui.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(ui);await wait_frames()
  check(ui.order_buttons.has("knock"),"secondary order includes distinct KNOCK tool")
  if not ui.order_buttons.has("knock"):ui.queue_free();await process_frame;await create_timer(0.5).timeout;finish();return
  setup(ui);await wait_frames()
  # Native child chart fitting and the paused root refresh settle asynchronously.
  ui.ocean.zoom_at(2.0,ui.ocean.planning_size/2);ui.ocean.pan_chart(ui.ocean.planning_size/2-ui.ocean.screen_position(ui.sim.units[0].pos));await wait_frames(12)
  check(not ui.order_buttons.camera.is_visible_in_tree() and ui.order_buttons.knock.is_visible_in_tree(),"contextual TOOLS projection exposes distinct torpedo action")
  var rect=ui.order_buttons.knock.get_global_rect();var scale=Vector2(profile.size)/ui.get_viewport_rect().size;var center=ui.mission_hud.center
  for n in 2:await process_frame
  check(ui.order_buttons.knock.get_global_rect()==rect and ui.mission_hud.center==center,"settled stationary torpedo target keeps its input position")
  check(ui.get_global_rect().encloses(rect) and rect.size.x*scale.x>=48*profile.dpi/160.0 and rect.size.y*scale.y>=48*profile.dpi/160.0,"knock target stays safe and touch sized")
  await click(rect.get_center())
  check(ui.knock_armed and "QUIETUS" in ui.detail_label.text and "150m" in ui.detail_label.text and "impact pins 8s" in ui.detail_label.text and "noisy flight" in ui.detail_label.text and "CANCEL" in ui.order_buttons.knock.text,"armed targeting explains launcher/range and visible cancellation")
  if not capture_dir.is_empty():
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir+"/"+profile.name+"-targeting.png")
  var route=ui.sim.units[0].route.duplicate(true)
  await click(ui.ocean.screen_position(Vector2(300,800))+ui.ocean.global_position)
  check(ui.knock_armed and ui.sim.tools.knock==2 and ui.sim.units[0].route==route,"invalid target tap neither spends a torpedo nor plots a route")
  var actual=ui.sim.sirens[0].pos;ui.sim.sirens[0].pos=Vector2(1500,900)
  await contact(ui,0)
  check(ui.knock_armed and ui.sim.tools.knock==2 and ui.sim.projectiles.is_empty(),"stale live-position rejection keeps explicit targeting and never spends or plots")
  ui.sim.sirens[0].pos=actual;ui.sim._observe()
  ui.mission_hud.open("fleet");await wait_frames();await click(ui.unit_buttons[1].get_global_rect().get_center())
  check(not ui.knock_armed and ui.sim.selected==1 and ui.order_buttons.knock.disabled,"unit switch clears targeting and cannot silently launch from drone")
  ui.mission_hud.open("fleet");await wait_frames();await click(ui.unit_buttons[0].get_global_rect().get_center());ui.mission_hud.open("tools");await wait_frames();await action(ui,ui.order_buttons.knock)
  await contact(ui,0)
  check(not ui.knock_armed and ui.sim.tools.knock==1 and ui.sim.projectiles.size()==1 and ui.sim.units[0].route==route,"fresh contact tap launches physical torpedo and never creates a route")
  if not capture_dir.is_empty():
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir+"/"+profile.name+"-launched.png")
  ui.mission_hud.open("tools");await wait_frames();await action(ui,ui.order_buttons.knock);await click(ui.mission_hud.close_button.get_global_rect().get_center())
  check(not ui.knock_armed and ui.sim.tools.knock==1,"explicit cancel does not spend")
  ui.mission_hud.open("craft");await wait_frames();check(ui.order_buttons.camera.is_visible_in_tree(),"craft CAMERA remains available")
  ui.queue_free();await process_frame;await create_timer(0.5).timeout
 finish()
func finish() -> void:
 print("KNOCKDOWN UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
