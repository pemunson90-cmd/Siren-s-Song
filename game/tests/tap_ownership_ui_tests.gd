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
	await tip_card_tap_checks(g)
	await warning_card_checks(g)
	await lock_move_checks(g)
	await water_tap_checks(g)
	g.queue_free();await settle()
	print("TAP OWNERSHIP UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

# WP-69: a water tap that orders nothing names what a water tap needs; one that orders something stays quiet.
class IdleGuard:
	extends "res://src/presentation/order_guard.gd"
	func tap_water(_world:Vector2)->void:pass
func water_tap_checks(g)->void:
	await fresh(g)
	var Words=preload("res://src/presentation/hud_words.gd")
	var DiveInput=preload("res://src/presentation/dive_input.gd")
	var spot:Vector2=water(g,g.sim.units[0].pos)
	check(spot!=Vector2.INF,"water tap: an open-water point exists")
	var real=g.mission_hud.guard
	g.sim.message="stale line"
	DiveInput.water_tap(g,spot)
	check(g.sim.units[0].route.size()>0 and g.sim.message!=Words.TEXT.tap_idle,"water tap: a tap that routes the craft does not say the idle line (%s)"%g.sim.message)
	var idle=IdleGuard.new();g.mission_hud.add_child(idle);idle.setup(g);g.mission_hud.guard=idle
	g.sim.message="stale line"
	DiveInput.water_tap(g,spot)
	check(g.sim.message==Words.TEXT.tap_idle,"water tap: a tap that orders nothing says what a tap needs (%s)"%g.sim.message)
	g.sim.outcome="lost"
	DiveInput.water_tap(g,spot)
	check(g.sim.message==Words.TEXT.tap_over,"water tap: after the dive ends the line says so (%s)"%g.sim.message)
	g.sim.outcome=""
	g.mission_hud.guard=real;idle.queue_free()

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

# WP-51: the tip card owns every tap on it and within one touch height of GOT IT, in the engine's real event order
# (emulated mouse press, then the touch press, in one frame). A tap there neither dismisses the card nor reaches the chart.
func tip_card_tap_checks(g)->void:
	await fresh(g)
	var hints=g.mission_hud.hints
	hints.show_hint("pause");g._refresh();await settle()
	check(hints.panel.visible and hints.current=="pause","a tip card is up")
	if not hints.panel.visible:return
	var h:float=g.ui_touch_height
	var card:Rect2=hints.panel.get_global_rect()
	var button:Rect2=hints.dismiss_button.get_global_rect()
	var spots:Array=[card.get_center(),Vector2(card.end.x+h*.3,button.get_center().y),Vector2(button.get_center().x,card.end.y+h*.4),Vector2(button.get_center().x,button.position.y-h*.3)]
	for spot in spots:
		g.sim.message=""
		await tap(spot)
		var tag="tip card tap at "+str(spot)
		check(hints.panel.visible and hints.current=="pause",tag+": the card stays up and keeps its place")
		check(hints.panel.get_global_rect()==card,tag+": the card did not move")
		check(g.sim.route_goals().is_empty() and not g.mission_hud.guard.panel.visible and g.sim.message=="",tag+": nothing reached the chart ("+g.sim.message+")")
	await click(hints.dismiss_button)
	check(not hints.panel.visible and hints.current=="" and g.sim.route_goals().is_empty(),"GOT IT dismisses the card and gives no order")
	var leg:Vector2=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,leg))
	check(g.sim.route_goals().size()==1,"after the card is gone the next water tap orders as usual")

# A received lock on a craft: Siren 1 east of it, two seconds into its four.
func lock_on(g,craft:int)->void:
	g.sim.contacts={0:{"pos":g.sim.units[craft].pos+Vector2(80,0),"time":g.sim.elapsed,"mode":"LOCKING","lock":2.0,"target":craft,"type":"patroller","source":"optical","angle":0.0,"band":1}}
	g._refresh();await settle()
# WP-51: a lock is stated once; one tip at a time; no tip over a warning but its own; the viewfinder does not open by itself.
func warning_card_checks(g)->void:
	await fresh(g)
	var hints=g.mission_hud.hints
	g.hints_seen=["move","pause","drone","noise","sweep"]
	# The parked tip: a tip is up, a lock starts, the tip steps aside, and comes back in the same place.
	hints.show_hint("pause");g._refresh();await settle()
	var place:Vector2=hints.panel.position
	await lock_on(g,1)
	var warning=g.lock_warning
	check(warning.visible and g.ocean.lock_card_source==0,"a lock on a drone shows the lock card")
	check("locks DRONE A in " in warning.card_text and warning.card_text.contains("Move it behind rock, or let it go."),"the card for a drone gives its own advice: "+warning.card_text)
	check(place!=Vector2.ZERO and hints.current=="warning" and hints.panel.visible,"the first lock's own tip replaces the tip that was up: one card at a time")
	check(not g.ocean.contact_readout_entries().any(func(e):return e.locking) and not ("BEAM" in g.mission_hud.alarm.text),"the top-left readout does not repeat the lock")
	check(preload("res://src/presentation/threat_read/threat_read.gd").last_draw.chips.is_empty(),"no tag at the craft repeats the lock")
	for kept in [["EXTRACTION",{}],["A",{}],["SIGNAL SPIRE",{"kind":"objective"}]]:check(g.ocean._kept_under_lock(kept[0],kept[1]),"a "+kept[0]+" label stays while a lock shows")
	for dropped in ["SHUTTER HEARD 40m","OBSERVED SIREN","UNKNOWN SIGNAL · AREA · BRG 055"]:check(not g.ocean._kept_under_lock(dropped,{}),"the label "+dropped+" is hidden while a lock shows")
	# Only the explaining tip: queued tips wait while the warning shows and are dropped when their moment has passed.
	await click(hints.dismiss_button)
	hints._queue_first_use("first_depth");hints.current="";g._refresh();await settle()
	check(not hints.panel.visible and hints.current=="","a queued first-use tip waits while the lock card shows")
	g.sim.elapsed+=8.0;g.sim.contacts={};g._refresh();await settle()
	check(not hints.panel.visible and hints.current=="" and hints.pending_first_use.is_empty(),"a queued tip whose moment passed is dropped, not shown late")
	# Warning tips only; GOT IT never leaves a second card behind.
	await fresh(g)
	check(not hints._drone_moment(),"once the drones are launched the 'send a drone ahead' tip's moment is over")
	hints.drones_aboard_at_start=false
	check(hints._drone_moment(),"drones in the water with no orders and none lost: the tip's moment is open")
	g.sim.units[1].alive=false
	check(not hints._drone_moment(),"a lost drone ends it too")
	g.sim.units[1].alive=true
	# The viewfinder: not opened by a warning, opened again when the warning is over.
	await fresh(g)
	g.sim.contacts={};g._refresh();await settle()
	var feed=g.ocean.optical_feed
	feed.hide()
	var spire=g.sim.mission.objectives[0]
	g.sim.units[0].pos=spire.pos+Vector2(-50,0)
	g._refresh();await settle()
	var opens:bool=feed.viewfinder_visible(g.sim)
	check(opens,"Quietus beside the first photo subject has a viewfinder subject")
	if opens:
		check(feed.visible,"without a warning the viewfinder opens when a subject is near")
		feed.hide();await lock_on(g,0);await settle()
		check(g.ocean.warning_showing() and not feed.visible,"a lock does not open the viewfinder by itself")
		g.sim.contacts={};g._refresh();await settle()
		check(feed.visible,"the viewfinder comes back once the warning is over")

# WP-67: the moves on the lock card are one-tap buttons; the card owns their taps.
func shown_buttons(w)->Array:
	return w.buttons.filter(func(b):return b.visible)
func lock_move_checks(g)->void:
	var Words=preload("res://src/presentation/hud_words.gd")
	var Table=preload("res://src/presentation/threat_read/threat_read_table.gd")
	await fresh(g)
	g.sim.paused=true;g.sim.units[0].silent=false;await lock_on(g,0)
	var w=g.lock_warning
	var shown:Array=shown_buttons(w)
	check(shown.size()>=2 and shown[0].text==Words.TEXT.silent_off,"a paused lock on Quietus shows its moves as buttons, GO SILENT first: "+str(shown.map(func(b):return b.text)))
	var card:Rect2=Rect2(w.global_position+w.banner.position,w.banner.size)
	check(shown.all(func(b):return b.size.y>=g.ui_touch_height-1.0 and card.encloses(b.get_global_rect())),"every move button has the normal touch height and sits inside the card")
	check(is_equal_approx(w.banner.size.x,minf(g.size.x-32,g.ui_touch_height*preload("res://src/presentation/ui_style.gd").LOCK_CARD_WIDTH)),"the card keeps its width")
	check(g.mission_hud.blocks(card.get_center()) and g.mission_hud.blocks(shown[0].get_global_rect().get_center()),"the card owns taps on its buttons and its body")
	var route_before=str(g.sim.units[0].get("route_plan",[]))
	var decoy=shown.filter(func(b):return b.get_meta("order")=="decoy")
	check(decoy.size()==1,"a DECOY button is on the card")
	if decoy.size()==1:
		await click(decoy[0])
		check(g.decoy_armed and g.decoy_unit==0 and g.sim.selected==0,"DECOY arms placement for the locked craft")
		check(w.card_text.contains(Table.TEXT.decoy_aim),"the card says what to do next: "+w.card_text)
		check(str(g.sim.units[0].get("route_plan",[]))==route_before,"the tap did not become a route order")
	g.decoy_armed=false;g._refresh();await settle()
	var silent=shown_buttons(w)[0]
	await click(silent)
	check(g.sim.units[0].silent and not shown_buttons(w).any(func(b):return b.get_meta("order")=="silent"),"GO SILENT sets Quietus silent in one tap and leaves the card")
	var emp=shown_buttons(w).filter(func(b):return b.get_meta("order")=="emp")
	if emp.size()==1:
		await click(emp[0])
		check(g.sim.message.contains("EMP") ,"the EMP button sends the EMP order: "+g.sim.message)
	# A lock on a drone: the buttons select the drone first.
	await fresh(g)
	g.sim.paused=true;g.sim.units[1].silent=false;await lock_on(g,1)
	var drone=shown_buttons(g.lock_warning)
	check(not drone.is_empty() and drone[0].text==Words.TEXT.profile_low,"a drone's card offers GO LOW PROFILE")
	if not drone.is_empty():
		await click(drone[0])
		check(g.sim.selected==1 and g.sim.units[1].silent,"the drone's button selects the drone and lowers its profile")
	g.sim.paused=false;g._refresh();await settle()
	check(shown_buttons(g.lock_warning).is_empty(),"running play shows no buttons")

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
