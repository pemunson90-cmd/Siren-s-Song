extends SceneTree
# Source-known input and rendering fixtures; not a blind campaign playthrough.
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for frame in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0):
 var e=InputEventScreenTouch.new();e.index=id;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  await touch(point,down)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func drag(point:Vector2,delta:Vector2,id:int=0):
 var e=InputEventScreenDrag.new();e.index=id;e.position=point+delta;e.relative=delta;root.push_input(e,true);await process_frame
func tactical(s):
 var state=s.snapshot()
 for field in ["selected","queue_mode","message"]:state.erase(field)
 return state
func capture(name:String):
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func row(fleet,id:int)->Dictionary:
 for r in fleet.readouts:
  if r.unit==id:return r
 return {}
func menu_tap(game,action:String):
 var controls=game.panel_box.find_children("*","Button",true,false)+game.menu_footer.find_children("*","Button",true,false)
 var button=controls.filter(func(b):return b.get_meta("action","")==action)[0]
 if game.scroll.is_ancestor_of(button):game.scroll.ensure_control_visible(button);await settle()
 await tap(button.get_global_rect().get_center())
func stock_reference(game):
 # Loadouts change starting supply, not the shared maximum-stock scale.
 # Exercise the real menu, then a real binary archive with a different NEXT fit.
 for choice in ["endurance","disruption","survey"]:
  game.upgrade=choice;game._start_mission(0);await settle()
  var sim=game.sim;var fleet=game.mission_hud.fleet;var stock=120. if choice=="endurance" else 100.
  check(is_equal_approx(row(fleet,0).reserves[1].fraction,stock/120.),"actual "+choice+" supply uses the same120-unit reference")
  sim.oxygen=27.;sim.command("select",{"unit":1});game._refresh();await settle()
  var before=sim.snapshot();var warning=row(fleet,0).reserves[1]
  check(warning.capacity==120. and warning.critical and fleet.telemetry[0].visible and "27" in fleet.telemetry[0].text,"active low oxygen has an unselected numeric warning")
  game._show_campaign();await settle();await menu_tap(game,"loadout")
  check(game.upgrade!=choice and sim.snapshot()==before,"actual NEXT loadout cycle preserves the active supply and physics")
  await menu_tap(game,"resume")
  check(game.screen=="mission" and sim.snapshot()==before and row(fleet,0).reserves[1]==warning and fleet.telemetry[0].visible,"actual RESUME cannot rescale or hide the active oxygen warning")
  var store=preload("res://src/persistence/save_store.gd").new();store.path="user://fleet-ring-stock-test.save"
  var archive={"version":1,"unlocked":0,"completed":[],"upgrade":game.upgrade,"settings":{},"active":sim.snapshot()}
  check(store.save(archive) and store.load_game()==archive,"binary archive preserves low active supply beside different NEXT supplies")
  var saved=store.load_game();check(sim.restore(saved.active),"actual low-stock binary snapshot restores")
  game._refresh();await settle()
  check(sim.snapshot()==before and row(fleet,0).reserves[1]==warning and fleet.telemetry[0].visible,"binary restore retains the same reserve scale and numeric critical state")
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="fleet-ring"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(10);await settle()
  var s=game.sim;var hud=game.mission_hud;var fleet=hud.fleet;var ocean=game.ocean;var name="cover" if dimensions.x==2520 else "inner"
  s.units[0].pos=Vector2(480,1060);s.units[1].pos=Vector2(650,1220);s.units[2].pos=Vector2(1500,1100)
  s.units[0].vel=Vector2.ZERO;s.units[1].vel=Vector2.ZERO;s.units[2].vel=Vector2.ZERO
  ocean.fit_chart();game._refresh();await settle();await capture(name+"-stations")
  for id in 3:
   var r=row(fleet,id)
   if not r.get("offscreen",true):
    check(fleet.buttons[id].get_rect().get_center().distance_to(ocean.screen_position(s.units[id].pos))<1,"visible craft target stays centred on body "+name)
    check(r.get("ring",false),"visible reserve is a spatial ring "+name)
   check(fleet.buttons[id].size.x>=game.ui_touch_height and fleet.buttons[id].size.y>=game.ui_touch_height,"rings preserve full touch size")
  check(is_equal_approx(row(fleet,0).get("reserves",[{},{}])[1].get("fraction",0.),1.),"endurance stock fills the shared oxygen reference")
  # Measured centres of the old Q floating handle, inside charted clear water.
  # Replay the same world tap on baseline and challenger, not a new UI target.
  var water=Vector2(55.3334,578.4445) if dimensions.x==2520 else Vector2(234.6574,778.5394)
  var saved=s.snapshot();await tap(ocean.global_position+ocean.screen_position(water))
  var goals=s.route_goals()
  check(not game.advanced_orders and not goals.is_empty() and goals[0].pos.distance_to(water)<1,"water beneath former detached handle plots the intended course")
  hud.dismiss();s.restore(saved);ocean.fit_chart();game._refresh();await settle()
  await tap(ocean.global_position+ocean.screen_position(s.mission.objectives[0].pos))
  check(game.advanced_orders and hud.page=="plant","station marker beside a body opens actual local plant controls")
  await tap(hud.extra.chain_connect.get_global_rect().get_center())
  check(s.warning_chain_context().power.unit==0 and row(fleet,0).get("cues",[]).has("PWR") and row(fleet,0).progress.unit<0,"actual shore connection gets a persistent power cue without fake work progress")
  await capture(name+"-shore-power")
  s.command("chain_power",{"mode":"disconnect"});game._refresh()
  hud.dismiss();await settle()
  var before=tactical(s);var at=fleet.buttons[1].get_global_rect().get_center()
  await tap(at)
  check(s.selected==1 and game.advanced_orders and hud.page=="craft","one body tap selects and opens its actual context")
  check(tactical(s)==before,"context inspection preserves physical work and reserves")
  hud.dismiss();await settle();ocean.fit_chart();game._refresh();await settle()
  ocean.focus_craft();ocean.zoom_at(2.,ocean.size/2);game._refresh();await settle()
  var start=fleet.buttons[0].get_global_rect().get_center();var center=ocean.chart_camera.center
  await touch(start,true);await drag(start,Vector2(90,25));await touch(start+Vector2(90,25),false);await settle()
  check(ocean.chart_camera.center.distance_to(center)>1,"drag from craft ring actually pans camera")
  check(tactical(s)==before and not game.advanced_orders,"ring pan issues no route or selection")
  ocean.fit_chart();game._refresh();await settle();start=fleet.buttons[0].get_global_rect().get_center()
  var second=start+Vector2(200,0);var zoom=ocean.chart_camera.zoom
  await touch(start,true);await touch(second,true,1);await drag(second,Vector2(100,0),1);await touch(second+Vector2(100,0),false,1);await touch(start,false);await settle()
  check(ocean.chart_camera.zoom>zoom,"pinch from craft ring actually changes zoom")
  check(tactical(s)==before and not game.advanced_orders,"ring pinch never issues an order")
  # All full-size targets share one physical location: never choose the first ID.
  s.units[1].pos=s.units[0].pos;s.units[2].pos=s.units[0].pos;ocean.fit_chart();game._refresh();await settle()
  check(row(fleet,s.selected).get("cluster",[]).size()==3 and row(fleet,s.selected).get("identity","")=="A +2","coincident craft show the selected identity and the other-body count")
  await tap(ocean.global_position+ocean.screen_position(s.units[0].pos))
  check(game.advanced_orders and hud.page=="fleet","true craft overlap requests explicit fleet choice")
  check(tactical(s).units[0].pos==s.units[0].pos,"overlap does not issue a route")
  await tap(game.unit_buttons[2].get_global_rect().get_center())
  check(s.selected==2 and hud.page=="craft","explicit fleet choice opens the chosen clustered craft")
  hud.dismiss();await settle()
  # Exact critical reserves remain numeric, even for an unselected craft.
  s.units[1].pos=Vector2(650,1220);s.units[2].pos=Vector2(1500,1100);s.units[1].battery=9.;s.command("select",{"unit":0})
  game._refresh();await settle();await capture(name+"-critical")
  check(fleet.telemetry[1].visible and "9" in fleet.telemetry[1].text,"unselected critical battery has a numeric warning")
  var stopped=s.snapshot();s.paused=false
  for n in 210:s.advance(1./60.)
  game._refresh();await settle()
  check(not fleet.telemetry[0].visible and fleet.telemetry[1].visible,"RUN sheds ordinary selected detail while retaining critical numbers")
  s.paused=true;game._refresh();await settle()
  check(fleet.telemetry[0].visible,"tactical pause restores exact selected reserves and task")
  s.restore(stopped);game._refresh();await settle()
  start=fleet.buttons[1].get_global_rect().get_center();before=tactical(s);await touch(start,true)
  var cancel=InputEventScreenTouch.new();cancel.index=0;cancel.position=start;cancel.pressed=false;cancel.canceled=true;root.push_input(cancel,true);await process_frame
  await touch(start,false);await settle()
  check(tactical(s)==before and not game.advanced_orders and not fleet.gesture.active(),"canceled ring touch never becomes a late selection or order")
  # Known finite observation remains authoritative when own rings are visible.
  var enemy=s.sirens[0];enemy.pos=s.units[2].pos+Vector2(130,0);enemy.stun=0.;enemy.lock=2.;enemy.target=2;enemy.mode="ACQUIRE"
  s._observe();game._refresh();await settle();await capture(name+"-beam")
  check(ocean.contact_entries().any(func(e):return e.urgent and "DRONE B" in e.text),"fresh incoming beam keeps exact craft attribution")
  # Deliberate fit can leave remote bodies: edge handles remain bounded.
  ocean.focus_craft();ocean.zoom_at(3.,ocean.size/2);game._refresh();await settle()
  for r in fleet.readouts:
   if r.offscreen:check(game.get_global_rect().encloses(fleet.buttons[r.unit].get_global_rect()),"offscreen handle remains bounded")
  # A body covered by persistent controls gets bounded edge access; it cannot
  # take a pause press, and tool targeting keeps complete pointer ownership.
  ocean.chart_camera.mode="free";ocean.chart_camera.center=Vector2(1000,1040);ocean.chart_camera.zoom=4.
  s.units[0].pos=ocean.map_position(game.pause_button.get_global_rect().get_center()-ocean.global_position);game._refresh();await settle()
  check(not fleet.buttons[0].get_global_rect().intersects(game.pause_button.get_global_rect()),"covered hull never places a fleet hit target over pause")
  await tap(game.pause_button.get_global_rect().get_center());check(not s.paused,"pause remains directly reachable above a covered craft")
  await tap(game.pause_button.get_global_rect().get_center());check(s.paused,"pause returns to unlimited planning")
  start=fleet.buttons[1].get_global_rect().get_center();game.knock_armed=true;game._refresh();await settle();before=tactical(s)
  check(not fleet.is_visible_in_tree(),"tool aim hides fleet targets instead of competing for the same tap")
  await tap(start)
  check(tactical(s)==before and s.selected==0,"aim tap at a former ring cannot select a craft or route")
  await tap(hud.close_button.get_global_rect().get_center());check(not game.knock_armed,"explicit aim cancellation stays reachable")
  await stock_reference(game)
  game.queue_free();await settle()
 print("FLEET RING UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
