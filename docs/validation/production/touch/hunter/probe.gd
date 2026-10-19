extends SceneTree
var game
var failures=0
var checks=0
func _initialize(): call_deferred("run")
func check(ok,label):
	checks+=1
	print("HUNTER ","PASS " if ok else "FAIL ",label)
	if not ok: failures+=1
func touch(id,p,down,canceled=false):
	var e=InputEventScreenTouch.new(); e.index=id; e.position=p; e.pressed=down; e.canceled=canceled
	root.push_input(e,true); await process_frame
func drag(id,p,delta):
	var e=InputEventScreenDrag.new(); e.index=id; e.position=p; e.relative=delta
	root.push_input(e,true); await process_frame
func tap(p):
	await mouse(p,true); await mouse(p,false)
func mouse(p,down,device=0):
	var e=InputEventMouseButton.new(); e.position=p; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down; e.device=device
	root.push_input(e,true); await process_frame
func run():
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="hunter"; root.add_child(game)
	await process_frame; await process_frame
	var challenger=game.ocean.has_method("zoom_at")
	print("HUNTER BUILD challenger=",challenger)
	for dims in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		root.size=dims; await process_frame; await process_frame; game._start_mission(0); await process_frame
		game.sim.command("route",{"point":Vector2(360,800)}); game.sim.command("queue"); game.sim.command("contact_hold")
		var before=game.sim.units[0].route.duplicate(true)
		if challenger:
			# Navigation must preserve explicit queued/conditional state, including oversized clamp pan.
			game.ocean.zoom_at(3.0,game.ocean.size/2); game.ocean.pan_chart(Vector2(100000,-100000)); game.ocean.fit_chart()
			check(game.sim.units[0].route==before and game.sim.queue_mode and game.sim.units[0].hold=="CONTACT","navigation preserves queued/conditional state "+str(dims))
		# A chart finger may coexist with an urgent HUD selection; it must not overwrite that command on lift.
		var p=game.ocean.global_position+game.ocean.size*0.65
		await touch(0,p,true)
		var home=game.order_buttons.home.get_global_rect().get_center()
		await touch(1,home,true); await mouse(home,true,InputEvent.DEVICE_ID_EMULATION); await touch(1,home,false); await mouse(home,false,InputEvent.DEVICE_ID_EMULATION); await touch(0,p,false)
		check(not game.sim.queue_mode and game.sim.units[0].hold=="" and not game.sim.units[0].silent and game.sim.units[0].route[-1].pos.distance_to(game.sim.mission.extraction)<1,"emergency replaces queued conditional route during chart touch "+str(dims))
		# Actual camera entry is independent of selecting the sub; exposed drone survives map navigation.
		game._scenario("camera"); await process_frame
		check(game.sim.capture_unit==1 and game.ocean.optical_feed.visible,"ordinary camera setup "+str(dims))
		await tap(game.unit_buttons[0].get_global_rect().get_center())
		var snap=game.sim.snapshot()
		if challenger:
			await tap(game.zoom_buttons[1].get_global_rect().get_center())
			var origin=game.ocean.global_position+game.ocean.size*0.55
			await touch(0,origin,true); await drag(0,origin+Vector2(-100,30),Vector2(-100,30)); await touch(0,origin+Vector2(-100,30),false)
		check(game.sim.selected==0 and game.sim.capture_unit==1 and not game.ocean.optical_feed.visible and game.sim.snapshot()==snap,"sub switch and navigation preserve independent exposure "+str(dims))
		await tap(game.order_buttons.home.get_global_rect().get_center())
		check(game.sim.capture_unit==1,"sub emergency does not cancel drone exposure "+str(dims))
		# Drone loss fallback remains usable after navigation, with stale queue cleared.
		game.sim.units[1].alive=false; game.sim.selected=1; game.sim.queue_mode=true; game.sim.paused=false; game.sim.advance(0.05); game.sim.paused=true; game._refresh()
		check(game.sim.selected==0 and not game.sim.queue_mode,"selected lost drone falls back to Quietus "+str(dims))
		game._start_mission(0); await process_frame
		var dest=Vector2(320,800)
		for inset in [Vector2.ZERO,Vector2(60,22)]:
			game.position=inset
			if challenger:
				game.ocean.fit_chart(); game.ocean.zoom_at(2.0,game.ocean.screen_position(dest))
			var at=game.ocean.global_position+game.ocean.world_offset+dest*game.ocean.world_scale
			check(game.ocean.get_global_rect().has_point(at),"transformed destination visible "+str(dims)+str(inset))
			game.sim.units[0].route.clear(); await tap(at)
			check(not game.sim.units[0].route.is_empty() and game.sim.units[0].route[-1].pos.distance_to(dest)<1,"actual transformed pointer endpoint "+str(dims)+str(inset))
		game.position=Vector2.ZERO
		if challenger:
			game.ocean.fit_chart(); game.sim.units[0].route.clear(); game.sim.queue_mode=true
			var at=game.ocean.global_position+game.ocean.screen_position(dest)
			await mouse(at,true); await mouse(at,false)
			check(game.sim.units[0].route.size()==1,"physical mouse queues exactly once "+str(dims))
			await touch(0,at,true); await touch(0,at,false); await mouse(at,true,InputEvent.DEVICE_ID_EMULATION); await mouse(at,false,InputEvent.DEVICE_ID_EMULATION)
			check(game.sim.units[0].route.size()==2,"touch plus emulated mouse adds exactly one further endpoint "+str(dims))
			var orders=game.sim.units[0].route.duplicate(true)
			# A drag that finishes on a zoom button should be a navigation gesture, never a route/button click.
			var end=game.zoom_buttons[1].get_global_rect().get_center(); var origin=end-Vector2(100,-50)
			var zoom=game.ocean.chart_camera.zoom
			await touch(0,origin,true); await drag(0,end,end-origin); await touch(0,end,false)
			check(game.sim.units[0].route==orders and game.ocean.chart_camera.zoom==zoom,"chart drag over plus does not click it or route "+str(dims))
			# Real resize while a tap is pending must cancel it, retaining a valid camera.
			at=game.ocean.global_position+game.ocean.size*0.6
			await touch(0,at,true); root.size=dims+Vector2i(40,-20); await process_frame; await process_frame; await touch(0,at,false)
			check(game.sim.units[0].route==orders and not game.map_gesture.active(),"actual viewport resize cancels pending route "+str(dims))
			# Camera inverse across fit, extremes and nonuniform viewport aspect changes.
			for z in [1.0,1.4,2.8,4.0]:
				game.ocean.fit_chart(); game.ocean.zoom_at(z,game.ocean.size*0.7); game.ocean.pan_chart(Vector2(34,-97))
				for world in [Vector2.ZERO,Vector2(320,800),Vector2(1600,960)]:
					check(game.ocean.map_position(game.ocean.screen_position(world)).distance_to(world)<0.001,"camera inverse z="+str(z)+" "+str(world))
	game.queue_free(); await process_frame; await create_timer(0.5).timeout
	print("HUNTER CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
