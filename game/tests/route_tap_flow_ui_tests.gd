extends SceneTree
# WP-127: route planning by tap is one predictable thing, on the cover (1680x720 canvas) and inner (1280x1153) screens at 100% and 150% text.
# 1. A water tap with a route set appends a point: no REPLACE / ADD / CANCEL card. The first tap sets the route.
# 2. UNDO takes back the last point and goes once the route it would restore to has ended; REPLACE ROUTE on the ROUTE page clears the route.
# 3. A leg across charted rock is drawn red and asks on a slim bar (SEND ANYWAY / CANCEL) that covers no chart tap; open water elsewhere plots.
# 4. The tap mode is printed beside the selected craft.
# 5. After DEPLOY the first water tap routes the deployed drone.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func touch(point:Vector2,pressed:bool):
	var e=InputEventScreenTouch.new();e.position=point;e.index=0;e.pressed=pressed;root.push_input(e,true);await process_frame
func mouse(point:Vector2,pressed:bool):
	var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true);await process_frame
func tap(point:Vector2):
	UiStyle.clock_override_ms=maxi(UiStyle.clock_override_ms,Time.get_ticks_msec())+UiStyle.TAP_AFTER_CLOSE_MS+100
	await touch(point,true);await mouse(point,true);await touch(point,false);await mouse(point,false);await settle()
func click(button:Control):await tap(button.get_global_rect().get_center())
func screen(g,world:Vector2)->Vector2:
	return g.ocean.global_position+g.ocean.screen_position(world)
func open_water(g,world:Vector2,radius:float)->bool:
	return not g.sim.blocked(world,radius) and Rect2(Vector2(60,60),g.sim.world_size()-Vector2(120,120)).has_point(world)
# A tappable water point near `from`: open water on the chart, clear of the HUD and of drawn targets, whose leg from `origin` crosses no rock.
func water(g,from:Vector2,origin:Vector2,exclude:Array=[])->Vector2:
	for r in [140,180,220,110,260,300,360]:
		for k in 24:
			var p:Vector2=from+Vector2.from_angle(TAU*k/24.0)*r
			if not open_water(g,p,40) or exclude.any(func(q):return q.distance_to(p)<90) or HandPilot.crosses_rock(g.sim,origin,p):continue
			var s=screen(g,p)
			if not g.ocean.get_global_rect().grow(-70).has_point(s) or g.mission_hud.blocks(s):continue
			var local=s-g.ocean.global_position
			if not g.ocean.contexts_at(local,g.ui_touch_height*1.6).is_empty() or g.ocean.information_at(local):continue
			return p
	return Vector2.INF
func rock_point(s,from:Vector2)->Variant:
	for distance in [160.0,240.0,320.0,420.0,540.0,700.0,900.0]:
		for i in 32:
			var p:Vector2=from+Vector2.from_angle(TAU*i/32.0)*distance
			if Rect2(Vector2.ONE*24,s.world_size()-Vector2.ONE*48).has_point(p) and not HandPilot.rock_at(s,p) and HandPilot.crosses_rock(s,from,p):return p
	return null
func make(shape:Vector2i,scale:float):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp127-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	for id in ["warning","sweep"]:
		if id not in game.hints_seen:game.hints_seen.append(id)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[]
	game.mission_hud.hints.dismiss();game.mission_hud.guard.reset()
	game.sim.paused=true;game.sim.selected=0;game.ocean.focus_craft();game._refresh();await settle()
	return game
func run():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var tag="%dx%d@%d%%"%[shape.x,shape.y,roundi(scale*100)]
			var g=await make(shape,scale)
			await append_case(g,tag)
			await undo_case(g,tag)
			await replace_case(g,tag)
			await rock_case(g,tag)
			await mode_case(g,tag)
			g.queue_free();await settle()
			await deploy_case(shape,scale,tag)
	Settings.current=saved
	print("ROUTE TAP FLOW UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func reset(g)->void:
	g.mission_hud.guard.reset()
	var u=g.sim.units[0];u.route=[];u.hold="";u.erase("route_plan");u.erase("route_undo");u.vel=Vector2.ZERO
	g.sim.selected=0;g.sim.queue_mode=false;g.sim.paused=true
	if g.advanced_orders:g.mission_hud.dismiss()
	g.ocean.focus_craft();g._refresh()
# 1. Taps: set, then add; no card.
func append_case(g,tag:String)->void:
	reset(g);await settle()
	var guard=g.mission_hud.guard;var q:Vector2=g.sim.units[0].pos
	var a=water(g,q,q);await tap(screen(g,a))
	check(g.sim.route_goals().size()==1 and not guard.panel.visible,tag+": the first tap sets a one-stop route")
	var b=water(g,a,a,[a,q]);await tap(screen(g,b))
	check(g.sim.route_goals().size()==2 and not guard.panel.visible and guard.pending.is_empty(),tag+": the second tap adds a point, no card")
	check(g.sim.route_goals()[0].pos.distance_to(a)<1 and g.sim.route_goals()[1].pos.distance_to(b)<1,tag+": the first point stays and the new one is last")
	var c=water(g,b,b,[a,b,q]);await tap(screen(g,c))
	check(g.sim.route_goals().size()==3 and not g.sim.queue_mode,tag+": a third tap adds again and leaves the old TAPS switch where it was")
# 2. UNDO.
func undo_case(g,tag:String)->void:
	reset(g);await settle()
	var guard=g.mission_hud.guard;var q:Vector2=g.sim.units[0].pos
	var a=water(g,q,q);await tap(screen(g,a))
	var b=water(g,a,a,[a,q]);await tap(screen(g,b))
	check(guard.undo_button.visible and "1 stop" in guard.undo_button.text,tag+": UNDO says it goes back to the one-stop route: "+guard.undo_button.text)
	check(guard.undo_button.get_global_rect().size.x<=g.ocean.chart_width()-24+1.,tag+": the UNDO chip fits the chart width")
	await click(guard.undo_button)
	check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(a)<1,tag+": UNDO takes back the last point only")
	# The route ends: the chip goes (it used to say "back to no route" after the craft had arrived).
	reset(g);await settle()
	await tap(screen(g,a))
	check(guard.undo_button.visible and "no route" in guard.undo_button.text.to_lower(),tag+": after a first leg UNDO offers no route")
	var u=g.sim.units[0];u.route=[];u.erase("route_plan");g._refresh();await settle()
	check(not guard.undo_button.visible and guard.undo.is_empty(),tag+": once the route has ended the UNDO chip is gone")
# REPLACE ROUTE on the ROUTE page.
func replace_case(g,tag:String)->void:
	reset(g);await settle()
	var guard=g.mission_hud.guard;var q:Vector2=g.sim.units[0].pos
	var a=water(g,q,q);await tap(screen(g,a))
	var b=water(g,a,a,[a,q]);await tap(screen(g,b))
	await tap(screen(g,q))
	check(g.advanced_orders,tag+": Quietus's wheel opens")
	await click(g.mission_hud.extra.route_menu)
	var button=g.mission_hud.extra.replace_route
	check(g.mission_hud.page=="route" and button.is_visible_in_tree() and button.text==Words.TEXT.replace_route,tag+": the ROUTE page offers REPLACE ROUTE")
	await click(button)
	check(g.sim.route_goals().is_empty() and not g.advanced_orders,tag+": REPLACE ROUTE clears the route and closes the wheel")
	check(guard.undo_button.visible and "2 stops" in guard.undo_button.text,tag+": UNDO restores the two-stop route: "+guard.undo_button.text)
	var c=water(g,q,q,[a,b,q]);await tap(screen(g,c))
	check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(c)<1,tag+": the next tap plots a fresh one-stop route")
# 3. Rock.
func rock_case(g,tag:String)->void:
	reset(g);await settle()
	var guard=g.mission_hud.guard;var s=g.sim;var q:Vector2=s.units[0].pos
	var p=rock_point(s,q)
	check(p!=null,tag+": there is a leg across charted rock to test")
	if p==null:return
	await tap(screen(g,p))
	var on_screen:bool=g.ocean.get_global_rect().has_point(screen(g,p))
	if not on_screen:guard.tap_water(p);await settle()
	check(s.units[0].route.is_empty() and not guard.pending.is_empty() and guard.panel.visible,tag+": a leg across rock waits on the bar")
	check(guard.go_button.text==Words.TEXT.send_anyway and guard.cancel_button.text=="CANCEL",tag+": the bar offers SEND ANYWAY and CANCEL only")
	var bar:Rect2=guard.panel.get_global_rect();var chart:Rect2=g.ocean.get_global_rect()
	check(bar.size.y<=g.ui_touch_height*1.8 and bar.position.y>=chart.position.y-1 and bar.end.y<=g.size.y+1,tag+": the bar is slim and inside the screen: "+str(bar))
	check(not bar.intersects(Rect2(guard.craft_rect(g.ui_touch_height).grow(-2).position+g.ocean.global_position,guard.craft_rect(g.ui_touch_height).grow(-2).size)) and not bar.intersects(Rect2(guard.marker_rect(g.ui_touch_height).position+g.ocean.global_position,guard.marker_rect(g.ui_touch_height).size)),tag+": the bar covers neither the craft nor the marker")
	# Open water elsewhere plots without the bar.
	var clear=water(g,q,q,[p,q])
	await tap(screen(g,clear))
	check(guard.pending.is_empty() and not guard.panel.visible and s.units[0].route.size()>=1,tag+": a tap on open water elsewhere plots and closes the bar")
	reset(g);await settle()
	guard.tap_water(p);await settle()
	await click(guard.cancel_button)
	check(s.units[0].route.is_empty() and guard.pending.is_empty(),tag+": CANCEL orders nothing")
	guard.tap_water(p);await settle()
	await click(guard.go_button)
	check(not s.units[0].route.is_empty() and guard.pending.is_empty(),tag+": SEND ANYWAY sends the leg")
	# The committed leg is drawn red by the chart (release_controls.draw_legs).
	check(not HandPilot.warnings(s,0).is_empty(),tag+": the sent leg is a red warning leg")
# 4. Tap mode label.
func mode_case(g,tag:String)->void:
	reset(g);await settle()
	var guard=g.mission_hud.guard;var q:Vector2=g.sim.units[0].pos
	check(guard.tap_mode_text()==Words.TEXT.tap_mode_set and guard.mode_visible(),tag+": no route: TAP WATER · SET ROUTE")
	var rect:Rect2=guard.mode_rect()
	check(Rect2(Vector2.ZERO,Vector2(g.ocean.chart_width(),g.size.y)).encloses(rect),tag+": the label fits the chart: "+str(rect))
	var a=water(g,q,q);await tap(screen(g,a))
	check(guard.tap_mode_text()==Words.TEXT.tap_mode_add,tag+": with a route: TAP WATER · ADD POINT")
	check(Words.TEXT.tap_mode_add in g.mission_hud.intent.text,tag+": the status strip says the same: "+g.mission_hud.intent.text)
# 5. DEPLOY then a water tap (a fresh dive with the drones aboard).
func deploy_case(shape:Vector2i,scale:float,tag:String)->void:
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"))
	g.store.path="user://wp127d-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(g);await settle();g.set_process(false)
	for id in ["warning","sweep"]:
		if id not in g.hints_seen:g.hints_seen.append(id)
	g._start_mission(0);await settle();g._layout();await settle()
	g.sim.sirens=[];g.mission_hud.hints.dismiss();g.sim.paused=true;g.sim.selected=0;g.ocean.focus_craft();g._refresh();await settle()
	var q:Vector2=g.sim.units[0].pos
	check(g.sim.DroneBay.aboard(g.sim.units[1]),tag+": drone A starts aboard")
	await tap(screen(g,q))
	var deploy=g.mission_hud.extra.deploy
	check(g.advanced_orders and deploy.is_visible_in_tree(),tag+": Quietus's wheel offers DEPLOY")
	await click(deploy)
	check(g.sim.selected==1 and not g.sim.DroneBay.aboard(g.sim.units[1]),tag+": DEPLOY puts drone A in the water and selects it")
	var a=water(g,g.sim.units[1].pos,g.sim.units[1].pos,[q])
	check(a!=Vector2.INF,tag+": there is water to tap")
	await tap(screen(g,a))
	check(g.sim.route_goals(1).size()==1 and g.sim.units[1].route.size()>=1,tag+": the first water tap after DEPLOY routes drone A: "+g.sim.message)
	check(g.sim.units[0].route.is_empty(),tag+": and Quietus gets no order")
	g.queue_free();await settle()
