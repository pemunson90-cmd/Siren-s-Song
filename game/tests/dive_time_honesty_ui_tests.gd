extends SceneTree
# WP-103: the dive never silently eats time or an order. Driven through the real Main scene with touch events
# followed by their emulated mouse events, at the phone cover (2520x1080) and inner (2184x1968) screens, at normal
# and 150% text.
# 1. The plate never offers the wrong action: ANSWER while a route prompt waits (a tap keeps the marker and says so),
#    CLOSE while an open menu holds time (a tap closes it), RUN while stopped, PAUSE while running.
# 2. A tap on a card's body (lock card, tip card) never starts time and never reaches the chart.
# 3. The lock card says what a landed lock does.
# 4. A craft that holds with its route kept says why and what releases it.
# 5. Quietus at the recovery mouth says what recovery still needs.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const TrialRules=preload("res://src/trial_rules.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func touch(point:Vector2,pressed:bool):
	var e=InputEventScreenTouch.new();e.position=point;e.index=0;e.pressed=pressed;root.push_input(e,true)
func mouse(point:Vector2,pressed:bool):
	var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true)
func tap(point:Vector2):
	mouse(point,true);touch(point,true);await process_frame
	mouse(point,false);touch(point,false);await settle()
func make(shape:Vector2i,scale:float):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp103-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	game.sim.selected=0
	return game
func refresh(game):
	game._refresh();await settle()
func plate_fits(game,label:String):
	var b:Button=game.pause_button
	var size=b.get_theme_font_size("font_size")
	var inner=b.get_theme_font("font").get_multiline_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
	check(inner.x<=b.size.x-b.get_theme_stylebox("normal").get_minimum_size().x+0.5 and inner.y<=b.size.y,"the plate's words fit inside it "+label+" "+str(inner)+" in "+str(b.size)+" "+b.text.replace("\n"," / "))
func run():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
			await plate_case(shape,scale,stamp)
			await card_case(shape,scale,stamp)
			await lock_card_case(shape,scale,stamp)
			await hold_case(shape,scale,stamp)
			await extraction_case(shape,scale,stamp)
	Settings.current=saved
	TrialRules.reset()
	print("DIVE TIME HONESTY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
# 1. The plate.
func plate_case(shape:Vector2i,scale:float,stamp:String):
	var g=await make(shape,scale)
	var s=g.sim;var plate:Button=g.pause_button
	var at:Vector2=plate.get_global_rect().get_center()
	s.paused=true;await refresh(g)
	check(plate.text.begins_with(Words.TEXT.act_run),"stopped: the plate offers RUN "+stamp+" "+plate.text)
	s.paused=false;await refresh(g)
	check(plate.text.begins_with(Words.TEXT.act_pause),"running: the plate offers PAUSE "+stamp+" "+plate.text)
	# A route prompt over a running dive: time is held, the plate says ANSWER and a tap keeps the marker.
	var marker:Vector2=s.units[0].pos+Vector2(90,0)
	g.mission_hud.guard.pending={"unit":0,"point":marker};await refresh(g);await refresh(g)
	check(g.mission_hud.guard.panel.visible,"the route prompt is up "+stamp)
	check(plate.text.begins_with(Words.TEXT.act_answer) and not plate.text.contains("PAUSE") and not plate.text.contains("RUN"),"held by the route prompt: the plate offers ANSWER, never PAUSE "+stamp+" "+plate.text)
	check(plate.text.contains(Words.TEXT.held),"and still says HELD "+stamp+" "+plate.text)
	plate_fits(g,"answer "+stamp)
	var routes:Array=s.units[0].route.duplicate()
	await tap(at)
	check(not s.paused and g.mission_hud.guard.pending.size()>0 and g.mission_hud.guard.panel.visible,"a tap on ANSWER keeps the marker and the prompt, and does not pause "+stamp)
	check(s.message==Words.TEXT.plate_answer and "Marker cancelled" not in s.message,"and says what is waiting: "+s.message+" "+stamp)
	check(s.units[0].route==routes,"and orders nothing "+stamp)
	# The same prompt over a stopped dive: the plate still says ANSWER (RUN used to drop the marker silently).
	s.paused=true;await refresh(g)
	check(plate.text.begins_with(Words.TEXT.act_answer),"stopped with the prompt up: ANSWER, not RUN "+stamp+" "+plate.text)
	await tap(at)
	check(s.paused and not g.mission_hud.guard.pending.is_empty() and "Marker cancelled" not in s.message,"a tap there neither resumes nor drops the marker "+stamp)
	g.mission_hud.guard.cancel();await refresh(g)
	check(plate.text.begins_with(Words.TEXT.act_run),"the prompt answered: RUN again "+stamp+" "+plate.text)
	# An open menu holds time: CLOSE, and the tap closes it.
	s.paused=false;g.mission_hud.open("craft");await refresh(g)
	check(g.advanced_orders and g._time_held(),"the wheel is open and holds time "+stamp)
	check(plate.text.begins_with(Words.TEXT.act_close) and not plate.text.contains("PAUSE"),"held by a menu: the plate offers CLOSE, never PAUSE "+stamp+" "+plate.text)
	plate_fits(g,"close "+stamp)
	await tap(plate.get_global_rect().get_center())
	check(not g.advanced_orders and not s.paused,"a tap on CLOSE closes the menu and time runs "+stamp)
	check(plate.text.begins_with(Words.TEXT.act_pause),"and the plate offers PAUSE again "+stamp+" "+plate.text)
	# The plate still pauses and resumes by hand.
	await tap(plate.get_global_rect().get_center())
	check(s.paused,"a tap on PAUSE stops the dive "+stamp)
	await tap(plate.get_global_rect().get_center())
	check(not s.paused,"a tap on RUN starts it "+stamp)
	g.queue_free();await settle()
# A received lock on a craft: Siren 1 east of it, two seconds into its lock.
func lock_on(g,craft:int):
	g.sim.contacts={0:{"pos":g.sim.units[craft].pos+Vector2(80,0),"time":g.sim.elapsed,"mode":"LOCKING","lock":2.0,"target":craft,"type":"patroller","source":"optical","angle":0.0,"band":1}}
	await refresh(g)
# 2. Cards: a tap on a card's body never starts time and never reaches the chart.
func card_case(shape:Vector2i,scale:float,stamp:String):
	var g=await make(shape,scale)
	var s=g.sim
	g.hints_seen=["move","pause","drone","noise","sweep"]
	for paused in [true,false]:
		s.paused=paused
		await lock_on(g,0)
		var card:Rect2=Rect2(g.lock_warning.global_position+g.lock_warning.banner.position,g.lock_warning.banner.size)
		check(g.lock_warning.visible and card.size.x>0,"the lock card shows "+stamp)
		var spots:Array=[card.position+Vector2(card.size.x*.5,12.),card.position+Vector2(card.size.x*.3,card.size.y*.25),card.get_center()]
		for spot in spots:
			s.message="";var before:Array=s.units[0].route.duplicate()
			await tap(spot)
			var tag="lock card tap at "+str(spot)+" ("+("stopped" if paused else "running")+") "+stamp
			check(s.paused==paused,tag+": time is unchanged")
			check(s.units[0].route==before and g.mission_hud.guard.pending.is_empty() and not g.advanced_orders,tag+": nothing reached the chart")
		s.contacts={};await refresh(g)
	# The tip card.
	s.paused=true;g.hints_seen=[]
	g.mission_hud.hints.show_hint("pause");await refresh(g)
	if g.mission_hud.hints.panel.visible:
		var r:Rect2=g.mission_hud.hints.panel.get_global_rect()
		await tap(r.get_center())
		check(s.paused and g.mission_hud.hints.panel.visible,"a tap on the tip card's text does not start time "+stamp)
	else:check(false,"the tip card shows "+stamp)
	g.queue_free();await settle()
# 3. The lock card's consequence line.
func lock_card_case(shape:Vector2i,scale:float,stamp:String):
	var g=await make(shape,scale)
	var s=g.sim;s.paused=true
	preload("res://tests/fixtures/player_dive.gd").launch_drones(s);await refresh(g)
	await lock_on(g,0)
	check("When it lands, QUIETUS is destroyed." in g.lock_warning.card_text,"a lock on Quietus says it destroys Quietus: "+g.lock_warning.card_text+" "+stamp)
	var banner:Rect2=Rect2(g.lock_warning.global_position+g.lock_warning.banner.position,g.lock_warning.banner.size)
	check(Rect2(Vector2.ZERO,Vector2(shape)).encloses(banner),"the lock card stays on the screen with the added line "+stamp+" "+str(banner))
	await lock_on(g,1)
	check("When it lands, DRONE A is lost." in g.lock_warning.card_text,"a lock on a drone says the drone is lost: "+g.lock_warning.card_text+" "+stamp)
	g.queue_free();await settle()
# 4. A holding craft with a route says why and how to go on.
func hold_case(shape:Vector2i,scale:float,stamp:String):
	var g=await make(shape,scale)
	var s=g.sim;s.paused=false
	s.command("route",{"point":s.units[0].pos+Vector2(120,0)})
	var u=s.units[0];u.vel=Vector2.ZERO
	await refresh(g)
	check("holding" not in g.mission_hud.intent.text and "route kept" not in g.mission_hud.intent.text,"a craft that is not held says nothing about a hold "+stamp)
	for kind in [["HOLD","tap HOLD to go on"],["CONTACT","tap IF CONTACT to go on"],["DRONE","tap WAIT DRONE to go on"],["SCOUT_STOP","tap SCOUT to go on"]]:
		u.hold=kind[0];u.vel=Vector2.ZERO;await refresh(g)
		var text:String=g.mission_hud.intent.text
		check("QUIETUS" in text and "route kept" in text and kind[1] in text,"hold "+kind[0]+" says why and what releases it: "+text.replace("\n"," | ")+" "+stamp)
	# A depth change that leaves the hold on: the strip still names the hold once the craft has settled.
	u.hold="HOLD";u.band=2;await refresh(g)
	check("tap HOLD to go on" in g.mission_hud.intent.text,"a held craft at DEEP says how to go on "+stamp)
	# Moving craft and ended routes say nothing.
	u.hold="HOLD";u.vel=Vector2(20,0);await refresh(g)
	check("tap HOLD to go on" not in g.mission_hud.intent.text,"a moving craft is not called held "+stamp)
	u.vel=Vector2.ZERO;u.route=[];u.erase("route_plan");await refresh(g)
	check("tap HOLD to go on" not in g.mission_hud.intent.text,"a hold with no route kept says nothing here "+stamp)
	g.queue_free();await settle()
# 5. Extraction.
func extraction_case(shape:Vector2i,scale:float,stamp:String):
	var g=await make(shape,scale)
	var s=g.sim;s.paused=true
	for o in s.mission.objectives:o["captured"]=true
	var u=s.units[0];u.pos=s.mission.extraction;u.vel=Vector2.ZERO;u.band=2
	await refresh(g)
	check("Extraction: settle QUIETUS in MIDDLE to recover" in g.mission_hud.intent.text,"at the mouth in DEEP the strip says what is needed: "+g.mission_hud.intent.text.replace("\n"," | ")+" "+stamp)
	u.band=1;u.vel=Vector2(20,0);await refresh(g)
	check("Extraction: slow QUIETUS to under 12 m/s to recover" in g.mission_hud.intent.text,"at the mouth moving fast the strip says to slow down: "+g.mission_hud.intent.text.replace("\n"," | ")+" "+stamp)
	u.vel=Vector2.ZERO;await refresh(g)
	check("Extraction:" not in g.mission_hud.intent.text,"settled in MIDDLE nothing is missing "+stamp)
	u.band=2;u.pos=s.mission.extraction+Vector2(400,0);await refresh(g)
	check("Extraction:" not in g.mission_hud.intent.text,"away from the mouth the strip says nothing about extraction "+stamp)
	g.queue_free();await settle()
