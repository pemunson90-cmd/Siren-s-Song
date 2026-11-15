extends SceneTree
# WP-104: with a craft's order wheel open, a tap on open chart closes the wheel AND gives that tap its normal meaning,
# so routing is craft, water. Driven through the real Main scene with touch events (the engine's emulated mouse press
# first, then the touch press) at the phone cover screen (2520x1080) and the inner screen (2184x1968).
# 1. Craft, then water: the wheel closes and the craft is routed once; the same single tap as with the wheel closed.
# 2. Water on rock with the wheel open gives the same answer as with the wheel closed.
# 3. Another craft with the wheel open is selected (its wheel opens); no route is ordered.
# 4. Back and Escape only close the wheel.
# 5. A tap on a HUD control with the wheel open is not a chart tap.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const BackLevels=preload("res://src/presentation/back_exit/back_levels.gd")
const SCREENS:Array=[Vector2i(2520,1080),Vector2i(2184,1968)]
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func touch(point:Vector2,pressed:bool,index:int=0):
	var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;root.push_input(e,true)
func mouse(point:Vector2,pressed:bool):
	var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true)
func tap(point:Vector2):
	mouse(point,true);touch(point,true);await process_frame
	mouse(point,false);touch(point,false);await settle()
func key(code:int):
	for down in [true,false]:
		var e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;root.push_input(e,true);await process_frame
	await settle()
func screen(g,world:Vector2)->Vector2:
	return g.ocean.global_position+g.ocean.screen_position(world)
func open_water(g,world:Vector2,radius:float)->bool:
	return not g.sim.blocked(world,radius) and Rect2(Vector2(60,60),g.sim.world_size()-Vector2(120,120)).has_point(world)
# Not under the open wheel, its dock or its sheet, and not near a craft.
func clear_of_wheel(g,s:Vector2)->bool:
	var hud=g.mission_hud
	if hud.sheet.visible and hud.sheet.get_global_rect().grow(20).has_point(s):return false
	if hud.order_dock.visible and hud.order_dock.get_global_rect().grow(20).has_point(s):return false
	if hud.occupied_rects().any(func(r):return r.grow(g.ui_touch_height*.5).has_point(s)):return false
	return not (g.advanced_orders and s.distance_to(hud.center)<hud.ring_radius*1.8)
func segment_clear(g,a:Vector2,b:Vector2)->bool:
	for i in 21:
		if g.sim.blocked(a.lerp(b,i/20.0),40):return false
	return true
# A world point whose spot on the screen is clear of the open wheel; `rock` picks charted rock, else open water.
func spot(g,rock:bool)->Vector2:
	var chart:Rect2=g.ocean.get_global_rect().grow(-120)
	var crafts=g.sim.units.map(func(u):return screen(g,u.pos))
	for y in range(160,g.ocean.get_global_rect().end.y,70):
		for x in range(160,int(g.ocean.get_global_rect().end.x),90):
			var s=Vector2(x,y)
			if not chart.has_point(s) or not clear_of_wheel(g,s) or crafts.any(func(c):return c.distance_to(s)<160):continue
			var world=g.ocean.map_position(s-g.ocean.global_position)
			if not rock and not segment_clear(g,g.sim.units[0].pos,world):continue
			if rock!=g.sim.blocked(world,0.0) or (not rock and not open_water(g,world,60)):continue
			var local=s-g.ocean.global_position
			if g.mission_hud.blocks(s) and not g.advanced_orders:continue
			if not g.ocean.contexts_at(local,g.ui_touch_height*1.6).is_empty() or g.ocean.information_at(local):continue
			if rock and not Rect2(Vector2.ZERO,g.sim.world_size()).has_point(world):continue
			return s
	return Vector2.INF
func fresh(g)->void:
	for id in ["warning","sweep"]:
		if id not in g.hints_seen:g.hints_seen.append(id)
	g._start_mission(0);await settle();preload("res://tests/fixtures/player_dive.gd").launch_drones(g.sim)
	var middle=g.sim.world_size()/2;var q=g.sim.units[0].pos
	for r in range(0,420,30):
		var found=false
		for k in 16:
			var p:Vector2=middle+Vector2.from_angle(TAU*k/16.0)*r
			if open_water(g,p,70):q=p;found=true;break
		if found:break
	g.sim.units[0].pos=q
	var placed=[q]
	for id in [1,2]:
		for r in [200,240,180,280]:
			var found=Vector2.INF
			for k in 16:
				var p:Vector2=q+Vector2.from_angle(TAU*(k+id*5)/16.0)*r
				if open_water(g,p,50) and placed.all(func(o):return o.distance_to(p)>150):found=p;break
			if found!=Vector2.INF:g.sim.units[id].pos=found;placed.append(found);break
	for u in g.sim.units:u.vel=Vector2.ZERO;u.route=[];u.hold="";u.erase("route_plan");u.erase("route_undo")
	g.sim.selected=0;g.sim.paused=true;g.sim.queue_mode=false
	g.mission_hud.hints.dismiss();g.mission_hud.guard.reset()
	if g.advanced_orders:g.mission_hud.dismiss()
	g.ocean.focus_craft();g._layout();g._refresh();await settle()
# Everything a tap on a point can change that the checks compare.
func outcome(g)->Dictionary:
	return {"goals":g.sim.route_goals().map(func(r):return snappedf(r.pos.x,.1)+snappedf(r.pos.y,.1)),"pending":not g.mission_hud.guard.pending.is_empty(),"panel":g.mission_hud.guard.panel.visible,"message":g.sim.message,"selected":g.sim.selected}
func open_wheel(g,craft:int=0)->void:
	await tap(screen(g,g.sim.units[craft].pos))
func run():
	Settings.current["mirrored_hud"]=false
	for size in SCREENS:
		root.size=size;await settle()
		var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="wheel-water-tap-tests";root.add_child(g);await settle();g.set_process(false)
		var tag="%dx%d"%[size.x,size.y]
		await route_checks(g,tag)
		await rock_checks(g,tag)
		await other_craft_checks(g,tag)
		await back_checks(g,tag)
		await hud_control_checks(g,tag)
		g.queue_free();await settle()
	print("WHEEL WATER TAP UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

func route_checks(g,tag:String)->void:
	await fresh(g);await open_wheel(g)
	check(g.advanced_orders and g.mission_hud.page=="craft",tag+": a tap on Quietus opens its wheel")
	var s:Vector2=spot(g,false)
	check(s!=Vector2.INF,tag+": open water clear of the wheel exists")
	await tap(s)
	check(not g.advanced_orders,tag+": the water tap closed the wheel")
	check(g.sim.route_goals().size()==1 and g.sim.selected==0 and g.sim.units[1].route.is_empty() and g.sim.units[2].route.is_empty(),tag+": craft then water routes Quietus once, no other craft")
	# The same tap with the wheel already closed gives the same order.
	var with_wheel:=outcome(g)
	await fresh(g)
	await tap(s)
	check(outcome(g)==with_wheel,tag+": the order equals a water tap with the wheel closed "+str(with_wheel)+" vs "+str(outcome(g)))
	# A craft that already has a route gets the replace-route prompt, like a closed-wheel tap.
	await fresh(g);await tap(s)
	await open_wheel(g)
	var second:Vector2=spot(g,false)
	await tap(second)
	# WP-127: no card; the wheel-closing tap adds a point as a closed-wheel tap does.
	check(not g.advanced_orders and not g.mission_hud.guard.panel.visible and g.sim.route_goals().size()==2 and g.sim.selected==0,tag+": with a route under way the wheel-closing water tap adds a point")
	# A drag that starts on open chart with the wheel open pans the chart and orders nothing.
	await fresh(g);await open_wheel(g)
	var offset_before=g.ocean.world_offset
	var a:Vector2=spot(g,false)
	touch(a,true);await process_frame
	for n in range(1,9):
		var e=InputEventScreenDrag.new();e.index=0;e.position=a+Vector2(0,-14)*n;e.relative=Vector2(0,-14);root.push_input(e,true);await process_frame
	touch(a+Vector2(0,-112),false);await settle()
	check(not g.advanced_orders and g.sim.route_goals().is_empty(),tag+": a drag that closes the wheel orders no route")

func rock_checks(g,tag:String)->void:
	await fresh(g);await open_wheel(g)
	var rock:Vector2=spot(g,true)
	if rock==Vector2.INF:
		check(true,tag+": no charted rock on screen clear of the wheel; rock check skipped");return
	g.sim.message=""
	await tap(rock)
	var with_wheel:=outcome(g)
	check(not g.advanced_orders,tag+": the rock tap closed the wheel")
	await fresh(g)
	g.sim.message=""
	await tap(rock)
	check(outcome(g)==with_wheel,tag+": a rock tap with the wheel open gives the usual rock answer "+str(with_wheel)+" vs "+str(outcome(g)))

func other_craft_checks(g,tag:String)->void:
	await fresh(g);await open_wheel(g)
	var clear:=Vector2.INF
	for r in [260,320,380,440]:
		for k in 24:
			var p:Vector2=g.sim.units[0].pos+Vector2.from_angle(TAU*k/24.0)*r
			if open_water(g,p,50) and clear_of_wheel(g,screen(g,p)) and g.ocean.get_global_rect().grow(-120).has_point(screen(g,p)):
				clear=p;break
		if clear!=Vector2.INF:break
	check(clear!=Vector2.INF,tag+": a spot for a drone clear of the wheel exists")
	if clear==Vector2.INF:return
	g.sim.units[1].pos=clear;g._refresh();await settle()
	await tap(screen(g,clear))
	check(g.sim.selected==1,tag+": a tap on another craft with the wheel open selects it")
	check(g.sim.route_goals().is_empty() and g.sim.units[1].route.is_empty() and g.sim.units[0].route.is_empty(),tag+": and orders no route")

func back_checks(g,tag:String)->void:
	for how in ["escape","back"]:
		await fresh(g);await open_wheel(g)
		check(g.advanced_orders,tag+" "+how+": the wheel is open")
		if how=="escape":await key(KEY_ESCAPE)
		else:BackLevels.dive(g);await settle()
		check(not g.advanced_orders,tag+" "+how+": closes the wheel")
		check(g.sim.route_goals().is_empty() and g.mission_hud.guard.pending.is_empty() and not g.mission_hud.guard.panel.visible,tag+" "+how+": and gives no order")

func hud_control_checks(g,tag:String)->void:
	await fresh(g);await open_wheel(g)
	var pause:Control=g.pause_button
	var s:Vector2=pause.get_global_rect().get_center()
	if not g.ocean.get_global_rect().has_point(s):
		check(true,tag+": the pause control is off the chart, so it is not a chart tap by position");return
	await tap(s)
	check(g.sim.route_goals().is_empty() and g.mission_hud.guard.pending.is_empty(),tag+": a tap on a HUD control with the wheel open is not a chart tap")
