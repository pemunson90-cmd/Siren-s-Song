extends SceneTree
# WP-45: who owns a tap. Driven through the real Main scene at the phone cover screen (2520x1080) with
# touch events followed by their emulated mouse events, as a phone delivers them.
# 1. A tap on the extraction circle or its label sends the selected craft to the extraction point and says so.
# 2. A tap that closes a wheel, wheel page, panel or card only closes it; the chart receives nothing from it.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
# The engine hands the emulated mouse event to the game before the touch it came from, both in the same frame,
# and the critic kit leaves one frame between press and release (scripts/critic/driver.gd).
func touch(point:Vector2,pressed:bool,index:int=0):
	var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;root.push_input(e,true)
func mouse(point:Vector2,pressed:bool):
	var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true)
func tap(point:Vector2):
	mouse(point,true);touch(point,true);await process_frame
	mouse(point,false);touch(point,false);await settle()
func click(button:Control):await tap(button.get_global_rect().get_center())
func screen(g,world:Vector2)->Vector2:
	return g.ocean.global_position+g.ocean.screen_position(world)
func open_water(g,world:Vector2,radius:float)->bool:
	return not g.sim.blocked(world,radius) and Rect2(Vector2(60,60),g.sim.world_size()-Vector2(120,120)).has_point(world)
# A tappable water point near `from`: open water, on the chart, clear of HUD and drawn targets.
func water(g,from:Vector2,exclude:Array=[])->Vector2:
	for r in [140,180,220,110,260,300]:
		for k in 24:
			var p:Vector2=from+Vector2.from_angle(TAU*k/24.0)*r
			if not open_water(g,p,40) or exclude.any(func(q):return q.distance_to(p)<90):continue
			var s=screen(g,p)
			if not g.ocean.get_global_rect().grow(-70).has_point(s) or g.mission_hud.blocks(s):continue
			var local=s-g.ocean.global_position
			if not g.ocean.contexts_at(local,g.ui_touch_height*1.6).is_empty() or g.ocean.information_at(local):continue
			return p
	return Vector2.INF
# Quietus near the middle of the chart and both drones in open water about 200 m away.
func fresh(g)->void:
	for id in ["warning","sweep"]:
		if id not in g.hints_seen:g.hints_seen.append(id)
	g._start_mission(0);await settle();preload("res://tests/fixtures/player_dive.gd").launch_drones(g.sim)
	var middle=g.sim.world_size()/2;var spots=[]
	for r in range(0,420,30):
		for k in 16:
			var p:Vector2=middle+Vector2.from_angle(TAU*k/16.0)*r
			if open_water(g,p,70) and spots.size()<1:spots.append(p)
	var q:Vector2=spots[0] if not spots.is_empty() else g.sim.units[0].pos
	g.sim.units[0].pos=q
	var placed=[q]
	for id in [1,2]:
		var found=Vector2.INF
		for r in [200,240,180,280]:
			for k in 16:
				var p:Vector2=q+Vector2.from_angle(TAU*(k+id*5)/16.0)*r
				if open_water(g,p,50) and placed.all(func(o):return o.distance_to(p)>150):found=p;break
			if found!=Vector2.INF:break
		if found!=Vector2.INF:g.sim.units[id].pos=found;placed.append(found)
	for u in g.sim.units:u.vel=Vector2.ZERO;u.route=[];u.hold="";u.erase("route_plan");u.erase("route_undo")
	g.sim.selected=0;g.sim.paused=true;g.sim.queue_mode=false
	g.mission_hud.hints.dismiss();g.mission_hud.guard.reset()
	if g.advanced_orders:g.mission_hud.dismiss()
	g.ocean.focus_craft();g._layout();g._refresh();await settle()
func run():
	Settings.current["mirrored_hud"]=false
	root.size=Vector2i(2520,1080);await settle()
	var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="tap-ownership-tests";root.add_child(g);await settle();g.set_process(false)
	await extraction_checks(g)
	await closing_tap_checks(g)
	g.queue_free();await settle()
	print("TAP OWNERSHIP UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

# The centre of the drawn EXTRACTION label: the label plate nearest the spot the chart draws it at.
func label_point(g,ex:Vector2)->Vector2:
	var drawn:Vector2=g.ocean.screen_position(ex+Vector2(-120 if ex.y>830 else -66,84 if ex.y>830 else 90))
	var best=Vector2.INF
	for r in g.ocean.world_label_rects:
		if r.get_center().distance_to(drawn)<120 and (best==Vector2.INF or r.get_center().distance_to(drawn)<best.distance_to(drawn)):best=r.get_center()
	return g.ocean.global_position+best if best!=Vector2.INF else Vector2.INF
# 1. The extraction circle and its label. Quietus starts on the circle, so a tap on the circle itself is a tap
# on the craft; the checks send Quietus away first, as a dive does, and tap the circle from the chart.
func extraction_checks(g)->void:
	for running in [false,true]:
		for place in ["circle","ring","label"]:
			await fresh(g)
			var ex:Vector2=g.sim.mission.extraction
			g.sim.units[0].pos=ex+Vector2(380,-100);g.sim.units[1].pos=ex+Vector2(380,-260);g.sim.units[2].pos=ex+Vector2(240,-260)
			g.sim.paused=not running;g.ocean.focus_craft();g._refresh();await settle()
			var at:Vector2=screen(g,ex+Vector2(30,-20)) if place=="circle" else screen(g,ex+Vector2(0,-60)) if place=="ring" else label_point(g,ex)
			var tag="%s %s"%["running" if running else "paused",place]
			check(g.ocean.get_global_rect().has_point(at),tag+": the extraction circle is on the chart at "+str(at))
			g.sim.message=""
			await tap(at)
			var goals=g.sim.route_goals()
			check(goals.size()==1 and goals[0].pos.distance_to(ex)<1.,tag+": a tap routes Quietus to the extraction point")
			check("heading to extraction" in g.sim.message,tag+": the status line says so, not '"+g.sim.message+"'")
	# The critic's own taps, native pixels, at the start of the operation with Quietus on the circle: each is answered.
	for native in [Vector2(150,930),Vector2(170,890),Vector2(300,880),Vector2(230,790),Vector2(215,945)]:
		await fresh(g)
		g.sim.units[0].pos=g.sim.mission.extraction;g.sim.units[1].pos=g.sim.mission.extraction+Vector2(260,-120);g.sim.units[2].pos=g.sim.mission.extraction+Vector2(180,-260)
		g.ocean.focus_craft();g._refresh();await settle()
		g.sim.message=""
		await tap(native/1.5)
		check(not g.sim.route_goals().is_empty() or g.advanced_orders or g.mission_hud.guard.panel.visible,"critic tap "+str(native)+" at the start is answered: a route, a wheel or the order dialog")
	# A craft that already has a route gets the same replace-route dialog a water tap gives.
	await fresh(g)
	var home:Vector2=g.sim.mission.extraction
	g.sim.units[0].pos=home+Vector2(380,-100);g.ocean.focus_craft();g._refresh();await settle()
	var leg=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,leg))
	check(g.sim.route_goals().size()==1,"a first water tap plots a leg")
	await tap(screen(g,home+Vector2(30,-20)))
	check(g.mission_hud.guard.panel.visible and g.mission_hud.guard.pending.point.distance_to(home)<1.,"with a route under way the extraction tap asks to replace it, marker on the extraction point")
	await click(g.mission_hud.guard.go_button)
	check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(home)<1.,"REPLACE ROUTE then sends the craft to extraction")

# 2. A tap that closes something only closes it.
func opened(g,how:String)->void:
	if how=="fleet view":
		await click(g.advanced_button);await click(g.mission_hud.extra.view_menu);return
	await tap(screen(g,g.sim.units[0].pos))
	match how:
		"history":
			await click(g.mission_hud.extra.depth_menu);await click(g.mission_hud.extra.sonar_history)
		"silent":
			# WP-52: the first tap arms SILENT and shows its cost; the second performs it (and closes the wheel).
			await click(g.order_buttons.silent);await click(g.order_buttons.silent)
# Open-water screen points clear of the open surface: outside its sheet, wheel, dock and every craft.
func outside_spots(g)->Array:
	var hud=g.mission_hud;var found=[]
	var crafts=g.sim.units.map(func(u):return screen(g,u.pos))
	var chart:Rect2=g.ocean.get_global_rect().grow(-120)
	for y in range(160,640,110):
		for x in range(160,1560,170):
			var p=Vector2(x,y)
			var world=g.ocean.map_position(p-g.ocean.global_position)
			if not chart.has_point(p) or not open_water(g,world,60):continue
			if hud.sheet.visible and hud.sheet.get_global_rect().grow(20).has_point(p):continue
			if hud.order_dock.visible and hud.order_dock.get_global_rect().grow(20).has_point(p):continue
			if g.advanced_orders and p.distance_to(hud.center)<hud.ring_radius*1.8:continue
			if crafts.any(func(c):return c.distance_to(p)<160):continue
			found.append(p)
	return found
# Taps spread over the chart, plus the two points the critic closed panels with (native 740,780 and 740,380).
func closing_tap_checks(g)->void:
	for how in ["wheel","history","fleet view","silent"]:
		var count=1
		var index=0
		while index<count:
			await fresh(g)
			await opened(g,how)
			var spots=outside_spots(g)
			if how=="silent":spots=[Vector2(740,780)/1.5,Vector2(740,380)/1.5]
			count=mini(spots.size(),5) if how!="silent" else 2
			check(not spots.is_empty(),how+": there is open water to tap")
			if spots.is_empty():break
			var spot:Vector2=spots[(index*spots.size())/count]
			var tag="%s tap %d at %s"%[how,index,str(spot)]
			var open_now:bool=g.advanced_orders
			var hull=g.sim.hull
			var snap=g.sim.snapshot()
			# SILENT closes the wheel by itself; a tap after that is an ordinary order, so only its own press is judged.
			if how!="silent":
				await tap(spot)
				check(open_now,tag+": the surface was open before the tap")
			check(not g.advanced_orders,tag+": the surface is closed")
			check(g.sim.route_goals().is_empty() and g.sim.units[1].route.is_empty() and g.sim.units[2].route.is_empty(),tag+": the closing tap orders no route")
			check(g.sim.hull==hull and g.sim.selected==0 and g.sim.snapshot()["units"]==snap["units"] or how=="silent",tag+": nothing else changed")
			await tap(spot)
			# WP-52: a leg across charted rock waits for a second tap on its marker; the player taps it again.
			if g.sim.route_goals().is_empty() and not g.mission_hud.guard.pending.is_empty():await tap(spot)
			check(g.sim.route_goals().size()==1,tag+": the next tap orders as usual")
			index+=1
