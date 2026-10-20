extends RefCounted
static func touch(t,index: int,p: Vector2,pressed: bool) -> void:
	var event=InputEventScreenTouch.new(); event.index=index; event.position=p; event.pressed=pressed
	t.root.push_input(event,true); await t.process_frame
static func drag(t,index: int,p: Vector2,delta: Vector2) -> void:
	var event=InputEventScreenDrag.new(); event.index=index; event.position=p; event.relative=delta
	t.root.push_input(event,true); await t.process_frame
static func press(t,button:Button)->void:
	var point=button.get_global_rect().get_center()
	await touch(t,0,point,true);await touch(t,0,point,false);await t.process_frame
static func open_view(t,game)->void:
	await press(t,game.advanced_button)
	await press(t,game.mission_hud.extra.view_menu)
static func close_view(t,game)->void:
	await press(t,game.mission_hud.close_button)
	await press(t,game.mission_hud.close_button)
static func run(t,game) -> void:
	t.check(game.ocean.has_method("zoom_at"),"chart has presentation-only anchored zoom")
	if not game.ocean.has_method("zoom_at"): return
	game._start_mission(0); await t.process_frame; await t.process_frame
	var ocean=game.ocean
	var anchor=ocean.size*0.5+Vector2(30,-20); var before=ocean.map_position(anchor); var snapshot=game.sim.snapshot()
	ocean.zoom_at(2.0,anchor)
	t.check(ocean.map_position(anchor).distance_to(before)<0.01,"pinch anchor preserves the inspected world point")
	ocean.pan_chart(Vector2(40,20))
	var point=Vector2(800,480)
	t.check(ocean.map_position(ocean.screen_position(point)).distance_to(point)<0.01,"world and input transform agree after zoom and pan")
	t.check(game.sim.snapshot()==snapshot,"chart navigation does not change paused simulation or observations")
	t.check(not game.zoom_buttons[2].is_visible_in_tree() and not game.mission_hud.focus_button.is_visible_in_tree(),"camera buttons live in VIEW while water keeps direct gestures")
	await open_view(t,game)
	t.check(game.mission_hud.page=="view" and game.zoom_buttons[2].is_visible_in_tree() and game.mission_hud.focus_button.is_visible_in_tree() and game.zoom_buttons[2].size.y>=44,"actual FLEET to VIEW exposes full-size camera targets")
	await press(t,game.mission_hud.focus_button)
	t.check(ocean.chart_camera.mode=="follow","actual VIEW FOCUS restores selected-craft follow")
	await close_view(t,game)
	ocean.fit_chart(); game.sim.command("queue")
	var destination=Vector2(480,850); var p=ocean.global_position+ocean.screen_position(destination)
	await touch(t,0,p,true); await touch(t,0,p,false)
	# Android may emit a mouse event for the same real finger. Never append it twice.
	var mouse=InputEventMouseButton.new(); mouse.device=InputEvent.DEVICE_ID_EMULATION; mouse.position=p; mouse.button_index=MOUSE_BUTTON_LEFT; mouse.pressed=true
	t.root.push_input(mouse,true); mouse=mouse.duplicate(); mouse.pressed=false; t.root.push_input(mouse,true); await t.process_frame
	t.check(game.sim.units[0].route.size()==1 and game.sim.units[0].route[-1].pos.distance_to(destination)<1,"one real touch plus emulated mouse appends exactly one waypoint")
	var orders=game.sim.units[0].route.duplicate(true)
	ocean.zoom_at(2.0,ocean.size/2); var origin=ocean.global_position+ocean.size/2; var old_offset=ocean.world_offset
	await touch(t,0,origin,true); await drag(t,0,origin+Vector2(70,15),Vector2(70,15)); await touch(t,0,origin+Vector2(70,15),false)
	t.check(game.sim.units[0].route==orders and ocean.world_offset!=old_offset,"single-finger chart drag pans without issuing an order")
	var old_scale=ocean.world_scale
	await touch(t,0,origin-Vector2(30,0),true); await touch(t,1,origin+Vector2(30,0),true)
	await drag(t,1,origin+Vector2(70,0),Vector2(40,0)); await touch(t,0,origin-Vector2(30,0),false); await touch(t,1,origin+Vector2(70,0),false)
	t.check(ocean.world_scale>old_scale and game.sim.units[0].route==orders,"two-finger pinch zooms and cancels pending route for its whole gesture")
	game.sim.command("queue")
	var target=ocean.map_position(ocean.size/2)
	p=ocean.global_position+ocean.screen_position(target)
	await touch(t,0,p,true); await touch(t,0,p,false)
	t.check(not game.sim.units[0].route.is_empty() and game.sim.units[0].route[-1].pos.distance_to(target)<1,"tap after pan and pinch commands the intended world destination")
	orders=game.sim.units[0].route.duplicate(true)
	await touch(t,0,origin,true); await drag(t,0,ocean.global_position+ocean.size+Vector2(80,80),Vector2(500,500)); await touch(t,0,ocean.global_position+ocean.size+Vector2(80,80),false)
	t.check(game.sim.units[0].route==orders and not game.map_gesture.active(),"drag release outside chart leaves no order or stuck gesture")
	await touch(t,0,origin,true); game._notification(Node.NOTIFICATION_APPLICATION_PAUSED); await touch(t,0,origin,false)
	t.check(game.sim.units[0].route==orders and not game.map_gesture.active() and game.sim.paused,"suspension cancels a pending tap without commanding or advancing")
	ocean.fit_chart(); game.sound.resume()
	var root_position=game.position; game.position+=Vector2(60,0)
	game.sim.command("route",{"point":Vector2(240,800)})
	p=ocean.global_position+ocean.screen_position(destination)
	await touch(t,0,p,true); await touch(t,0,p,false)
	t.check(game.sim.units[0].route[-1].pos.distance_to(destination)<1,"cutout-inset root maps global touch release to the same world destination")
	game.position=root_position
	ocean.fit_chart()
	var wheel=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.position=ocean.global_position+ocean.size/2;wheel.pressed=true;t.root.push_input(wheel,true);await t.process_frame
	t.check(ocean.chart_camera.zoom>1,"actual chart wheel input zooms the chart")
	wheel=wheel.duplicate();wheel.pressed=false;t.root.push_input(wheel,true);await t.process_frame
	await open_view(t,game)
	await press(t,game.zoom_buttons[2])
	t.check(is_equal_approx(ocean.chart_camera.zoom,1),"actual VIEW FIT tap restores the overview")
	await close_view(t,game)
	ocean.zoom_at(100,ocean.size/2); t.check(ocean.chart_camera.zoom==4,"chart zoom has a useful upper bound")
	ocean.zoom_at(0.001,ocean.size/2); t.check(ocean.chart_camera.zoom==1,"zooming out cannot lose the entire chart")
	orders=game.sim.units[0].route.duplicate(true)
	await touch(t,0,origin,true); game._layout(); await touch(t,0,origin,false)
	t.check(game.sim.units[0].route==orders and not game.map_gesture.active(),"layout change cancels a pending route tap")
	await touch(t,0,origin,true); await touch(t,1,origin+Vector2(30,0),true); await touch(t,2,origin+Vector2(60,0),true)
	await touch(t,1,origin+Vector2(30,0),false); await touch(t,2,origin+Vector2(60,0),false); await touch(t,0,origin,false)
	t.check(game.sim.units[0].route==orders and not game.map_gesture.active(),"third-finger release cannot become a stale single-touch order")

	orders=game.sim.units[0].route.duplicate(true)
	await touch(t,0,origin,true)
	var canceled=InputEventScreenTouch.new(); canceled.index=0; canceled.position=origin; canceled.pressed=false; canceled.canceled=true
	t.root.push_input(canceled,true); await t.process_frame
	t.check(game.sim.units[0].route==orders and not game.map_gesture.active(),"OS-canceled touch never commits a route on release")
	await touch(t,0,origin,true); await touch(t,1,game.pause_button.get_global_rect().get_center(),true)
	t.check(not game.map_gesture.active(),"a second finger entering HUD cancels chart navigation instead of pinching behind controls")
	await touch(t,1,game.pause_button.get_global_rect().get_center(),false); await touch(t,0,origin,false)
