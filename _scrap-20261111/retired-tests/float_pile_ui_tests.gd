extends SceneTree
# WP-115 (blind critic B, round 8): the dive's floating elements at large text. Driven through the real Main scene at the
# phone cover screen (2520x1080, canvas 1680x720) and the inner screen (2184x1968), at 100% and 150% text.
# 1. The Hunt chip's first-display note leaves after a set time of being shown (not dive time), yields to a prompt and
#    leaves for good once it is answered.
# 2. A tip card sits clear of the craft, their labels and the chip, keeps its zone, and tips never chain without a gap.
# 3. A craft loss is stated once: the loss card, not also the chip at the wreck and the strip.
# 4. The strip drops exact repeats and holds at most three lines at large text, never cutting a word.
# 5. The Hunt chip keeps one place when a tip card comes and goes.
# 6. A chart tap just after a card closes places nothing.
# 7. Chart labels keep off the banner (RIDER chip, Expedition line), the Hunt chip and the pause plate.
# 8. The wheel's centre text is fitted or shortened inside the disc.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const HuntMeter=preload("res://src/presentation/hunt_meter.gd")
const TR=preload("res://src/presentation/threat_read/threat_read.gd")
const Center=preload("res://src/presentation/radial_layout/center_layout.gd")
const Banner=preload("res://src/presentation/mode_banner.gd")
const ALL_TIPS=["move","pause","drone","noise","warning","sweep"]
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
func click(button:Control):await tap(button.get_global_rect().get_center())
func clock(ms:int)->void:UiStyle.clock_override_ms+=ms
func screen(g,world:Vector2)->Vector2:
	return g.ocean.global_position+g.ocean.screen_position(world)
func open_water(g,world:Vector2,radius:float)->bool:
	return not g.sim.blocked(world,radius) and Rect2(Vector2(60,60),g.sim.world_size()-Vector2(120,120)).has_point(world)
func water(g,from:Vector2)->Vector2:
	for r in [140,180,220,110,260,300]:
		for k in 24:
			var p:Vector2=from+Vector2.from_angle(TAU*k/24.0)*r
			if not open_water(g,p,40) or g.sim.units.any(func(u):return u.pos.distance_to(p)<90):continue
			var s=screen(g,p)
			if not g.ocean.get_global_rect().grow(-70).has_point(s) or g.mission_hud.blocks(s):continue
			var local=s-g.ocean.global_position
			if not g.ocean.contexts_at(local,g.ui_touch_height*1.6).is_empty() or g.ocean.information_at(local):continue
			return p
	return Vector2.INF
# A dive with Quietus in open water, drones launched, stopped, no tip card up, the Hunt note state reset.
func fresh(g)->void:
	g.hints_seen=ALL_TIPS.duplicate()
	g._start_mission(0);await settle();preload("res://tests/fixtures/player_dive.gd").launch_drones(g.sim)
	var middle=g.sim.world_size()/2
	for r in range(0,420,30):
		var p:Vector2=middle+Vector2.from_angle(r*.7)*r
		if open_water(g,p,70):g.sim.units[0].pos=p;break
	for u in g.sim.units:u.vel=Vector2.ZERO;u.route=[];u.hold="";u.erase("route_plan");u.erase("route_undo")
	g.sim.selected=0;g.sim.paused=true;g.sim.queue_mode=false
	g.mission_hud.hints.dismiss();g.mission_hud.hints.last_closed_ms=-1;g.mission_hud.guard.reset()
	if g.advanced_orders:g.mission_hud.dismiss()
	g.ocean.focus_craft();g._layout();g._refresh();await settle()
func reset_note(g)->void:
	var hud=g.mission_hud
	for key in ["hunt_meter_intro_since","hunt_meter_intro_done",HuntMeter.INTRO_TICK,HuntMeter.INTRO_SHOWN,HuntMeter.INTRO_PROMPT]:
		if hud.has_meta(key):hud.remove_meta(key)
	g.hints_seen=g.hints_seen.filter(func(id):return id!=preload("res://src/campaign/onboarding_text.gd").HUNT_METER_HINT)
	var old=hud.find_child("HuntMeterIntro",true,false)
	if old!=null:old.hide()
func note(g)->Label:
	return g.mission_hud.find_child("HuntMeterIntro",true,false) as Label
func chip(g)->Button:
	return g.mission_hud.get_meta(HuntMeter.CHIP) if g.mission_hud.has_meta(HuntMeter.CHIP) else null
# 1. The first-display note.
func note_checks(g,tag:String)->void:
	await fresh(g)
	reset_note(g)
	var elapsed:float=g.sim.elapsed
	clock(1000);g._refresh();await settle()
	var label:=note(g)
	check(label!=null and label.visible,tag+" note: the Hunt chip's first-display note shows")
	if label==null or not label.visible:return
	clock(5000);g._refresh()
	check(label.visible,tag+" note: still there after 5 s shown (the dive is stopped, its clock does not move)")
	clock(9000);g._refresh()
	check(not label.visible and g.mission_hud.get_meta("hunt_meter_intro_done",false),tag+" note: gone after more than "+str(HuntMeter.Table.INTRO_SECONDS)+" s shown, while the dive stayed stopped")
	check(is_equal_approx(g.sim.elapsed,elapsed) and g.sim.paused,tag+" note: the dive's own clock never moved")
	# A prompt that needs an answer: the note yields, and leaves for good once it is answered.
	reset_note(g)
	clock(1000);g._refresh();await settle()
	label=note(g)
	check(label!=null and label.visible,tag+" note: shows again after a reset")
	var hud=g.mission_hud
	hud.guard.panel.show()
	HuntMeter.intro(hud,chip(g))
	check(not label.visible,tag+" note: yields to the order dialog")
	check(not (label.visible and label.get_global_rect().intersects(hud.guard.panel.get_global_rect())),tag+" note: never over the order dialog")
	hud.guard.panel.hide()
	HuntMeter.intro(hud,chip(g))
	check(not label.visible and hud.get_meta("hunt_meter_intro_done",false),tag+" note: gone for good once the prompt was answered")
	# The route-prompt case at the cover: the chart-stop prompt also takes the place.
	reset_note(g)
	clock(1000);g._refresh();await settle()
	hud.chart_choice.panel.show()
	HuntMeter.intro(hud,chip(g))
	check(not note(g).visible,tag+" note: yields to the chart-stop route prompt")
	hud.chart_choice.panel.hide()
	HuntMeter.intro(hud,chip(g))
	check(hud.get_meta("hunt_meter_intro_done",false),tag+" note: the answered route prompt ends it")
# 2. Tip card zones and no chaining.
func tip_checks(g,tag:String)->void:
	await fresh(g)
	var hud=g.mission_hud;var hints=hud.hints
	hints.show_hint("pause");g._refresh();await settle()
	check(hints.panel.visible,tag+" tip: a card is up")
	if not hints.panel.visible:return
	var card:Rect2=hints.panel.get_global_rect()
	var avoid:Array=hud._tip_avoid().map(func(r):return Rect2(r.position+hud.global_position,r.size))
	check(not avoid.any(func(r):return r.intersects(card)),tag+" tip: the card is clear of every craft, their labels and the chip")
	# The zone is chosen: block its place and the card moves to another zone; it then keeps that zone.
	var first:Vector2=hints.panel.position
	var blocked:Array=[Rect2(first,hints.panel.size)]
	hints.refresh(hud.size,hud.touch_height,16,hud.threat_floor(),blocked,hud.intent.position.y)
	var moved:Vector2=hints.panel.position
	check(moved!=first and not Rect2(moved,hints.panel.size).intersects(blocked[0]),tag+" tip: a card whose place is taken moves to a clear zone")
	hints.refresh(hud.size,hud.touch_height,16,hud.threat_floor(),blocked,hud.intent.position.y)
	check(hints.panel.position==moved,tag+" tip: and keeps that zone while it stays clear")
	hints.refresh(hud.size,hud.touch_height,16,hud.threat_floor(),[],hud.intent.position.y)
	check(hints.panel.position==moved,tag+" tip: a zone that is still clear is not given up")
	# No chaining: a second tip waits TIP_GAP_MS after the first card closes.
	await fresh(g)
	g.hints_seen=[]
	g._start_mission(0);await settle()
	hints=g.mission_hud.hints
	check(hints.current=="move",tag+" tip: the first tip is the move tip")
	clock(1000);hints.dismiss()
	g.sim.paused=false;g.sim.elapsed=1.0;g._refresh();await settle()
	check(hints.current=="" and not hints.panel.visible,tag+" tip: no second card right after the first closes")
	clock(UiStyle.TIP_GAP_MS-500);g._refresh()
	check(hints.current=="",tag+" tip: still none just inside the gap")
	clock(1000);g._refresh();await settle()
	check(hints.current=="pause",tag+" tip: the next card comes after the gap")
	g.sim.paused=true
# 3. One loss, one announcement.
func loss_checks(g,tag:String)->void:
	await fresh(g)
	var s=g.sim
	TR.reset();TR.observe(s)  # the craft are seen alive first, as in a dive
	s.units[2].alive=false;s.units[2].battery=0.0;s.events.append({"type":"loss","pos":s.units[2].pos})
	s.message="DRONE B battery exhausted. Quietus camera remains available."
	TR.observe(s);g._refresh();g.ocean.queue_redraw();await settle()
	check(TR.loss_card(s)!="",tag+" loss: the card states the loss")
	check(TR.last_draw.has("card") and TR.last_draw.card.has_area(),tag+" loss: the chart really drew the loss card in this run")
	check(TR.last_draw.get("chips",[]).is_empty(),tag+" loss: no chip at the wreck repeats it while the card is up")
	var lines:Array=Array(g.mission_hud.intent.text.split("\n"))
	check(g.mission_hud.intent.text.count("DRONE B LOST")==0,tag+" loss: the strip does not say it again ("+g.mission_hud.intent.text.replace("\n"," / ")+")")
	var seen:Dictionary={}
	var repeated:=false
	for line in lines:
		if seen.has(line):repeated=true
		seen[line]=true
	check(not repeated,tag+" loss: the strip repeats no line")
	s.elapsed+=TR.Table.LOSS_CARD_SECONDS+1.0;TR.observe(s);g._refresh();g.ocean.queue_redraw();await settle()
	check(TR.loss_card(s)=="" and not TR.loss_rows(s).is_empty(),tag+" loss: after the card the wreck mark stays as the record")
# 4. The strip.
func strip_checks(g,tag:String,scale:float)->void:
	await fresh(g)
	var hud=g.mission_hud
	var text:String="QUIETUS has stopped: its route is finished."
	g.sim.message=text
	hud.route_end.notices=[{"text":text,"until":g.sim.elapsed+8.0}]
	g._refresh();await settle()
	check(hud.intent.text.count(text)==1,tag+" strip: a message already said is not said twice ("+hud.intent.text.replace("\n"," / ")+")")
	# Many lines at once.
	g.sim.message="QUIETUS · a message that is long enough to take most of a line on its own and so wrap at large text"
	hud.route_end.notices=[{"text":"DRONE A has stopped: its route is finished.","until":g.sim.elapsed+8.0},{"text":"DRONE B has stopped: its route is finished.","until":g.sim.elapsed+8.0}]
	g._refresh();await settle()
	var label:Label=hud.intent
	var font=label.get_theme_font("font");var size=label.get_theme_font_size("font_size")
	var wide:float=maxf(1.,g.ocean.chart_width()-32)-8.
	var drawn:float=font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,wide,size).y/font.get_height(size)
	if scale>=UiStyle.STRIP_LARGE_TEXT:check(drawn<=UiStyle.STRIP_MAX_LINES_LARGE+.01 or label.text.count("\n")==0,tag+" strip: at large text at most "+str(UiStyle.STRIP_MAX_LINES_LARGE)+" lines ("+str(drawn)+")")
	var worst:float=0.0
	for word in label.text.replace("\n"," ").split(" ",false):worst=maxf(worst,font.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x)
	check(worst<=wide,tag+" strip: no word is wider than the line, so none is cut")
	check(label.get_combined_minimum_size().y<=label.size.y+1.,tag+" strip: the strip is as tall as its text (nothing clipped)")
# 5. The Hunt chip keeps its place.
func chip_checks(g,tag:String)->void:
	await fresh(g)
	var hud=g.mission_hud
	var button:=chip(g)
	check(button!=null and button.visible,tag+" chip: the Hunt chip shows")
	if button==null or not button.visible:return
	var at:Vector2=button.position
	for id in ["pause","drone"]:
		g.hints_seen=g.hints_seen.filter(func(x):return x!=id)
		hud.hints.show_hint(id);g._refresh();await settle()
		check(button.position==at,tag+" chip: it did not move when the "+id+" tip card came up")
		hud.hints.dismiss();g._refresh();await settle()
		check(button.position==at,tag+" chip: it did not move when the card went")
# 6. A tap just after a card closes.
func tap_checks(g,tag:String)->void:
	await fresh(g)
	var hud=g.mission_hud;var hints=hud.hints
	var spot:Vector2=water(g,g.sim.units[0].pos)
	check(spot!=Vector2.INF,tag+" tap: open water exists")
	hints.show_hint("pause");g._refresh();await settle()
	check(hints.panel.visible,tag+" tap: a card is up")
	await click(hints.dismiss_button)
	check(not hints.panel.visible,tag+" tap: GOT IT closed the card")
	clock(100)
	g.sim.message=""
	await tap(screen(g,spot))
	check(g.sim.route_goals().is_empty() and hud.guard.pending.is_empty(),tag+" tap: a chart tap 100 ms after a card closed places nothing")
	clock(UiStyle.TAP_AFTER_CLOSE_MS+100)
	await tap(screen(g,spot))
	check(g.sim.route_goals().size()==1 or not hud.guard.pending.is_empty(),tag+" tap: a tap after the window is an ordinary chart tap")
# 7. Chart labels keep off the banner, the chip and the pause plate.
func label_checks(g,tag:String)->void:
	await fresh(g)
	var hud=g.mission_hud
	Banner.place(g,"EXPEDITION · RUN 3 · CHART LINE · a long expedition status that fills the banner across the top of the dive screen")
	g.ocean.ui_blocked_rects=hud.occupied_rects().map(func(r):return Rect2(r.position-g.ocean.global_position,r.size))
	var text:="UNKNOWN HEAT SOURCE · AREA · BRG 063"
	var rects:Array=[["banner",g.status_label.get_global_rect()],["pause plate",g.pause_button.get_global_rect()]]
	if chip(g)!=null and chip(g).visible:rects.append(["Hunt chip",chip(g).get_global_rect()])
	for entry in rects:
		var local:Rect2=Rect2(entry[1].position-g.ocean.global_position,entry[1].size)
		var world:Vector2=g.ocean.map_position(local.get_center())
		var placed:Vector2=g.ocean.world_label_position(world,text,16)
		var ok:bool=not placed.is_finite() or not g.ocean.world_label_rect(placed,text,16).intersects(local)
		check(ok,tag+" labels: an edge label wanted under the "+entry[0]+" is placed clear of it")
	g.status_label.hide()
# 8. The wheel's centre text.
func wheel_checks(g,tag:String,scale:float)->void:
	var h:float=g.ui_touch_height
	var ring:float=h*2.25*scale
	var center:=Vector2(500,400)
	var radii:=Vector2.ONE*(ring-h*.7)
	var font=ThemeDB.fallback_font
	var lines:Array=["QUIETUS","COMMAND · SITES 4","▸ UNKNOWN SIGNAL SOURCE · FOUR CHARTED CORRIDORS · NORTH GATE RECOVERY · WESTERN DEEP TRANSIT BEACON HELD FOR THE NEXT EXPEDITION RUN"]
	var fitted:Dictionary=Center.fit_disc(lines,font,roundi(h*.26*scale),center,radii,radii.y,func(count,size_):return center.y-radii.y*.4,14,[])
	var inside:=true
	for n in fitted.lines.size():
		if not Center.inside(Center.line_rect(fitted.lines[n],font,fitted.size,center.x,fitted.first_y+n*(fitted.size+Center.STYLE.line_gap)),center,radii):inside=false
	check(inside,tag+" wheel: a long Expedition text lies inside the disc ("+str(fitted.lines.size())+" lines at "+str(fitted.size)+" px)")
	check("\n".join(fitted.lines).contains("…"),tag+" wheel: the long text is shortened with an ellipsis")
	var short:Dictionary=Center.fit_disc(["QUIETUS","COMMAND · SITES 4"],font,roundi(h*.26*scale),center,radii,radii.y,func(count,size_):return center.y-radii.y*.4,14,[])
	check(short.lines==["QUIETUS","COMMAND · SITES 4"],tag+" wheel: a text that fits is left alone")
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			root.size=shape;await settle()
			Settings.current["mirrored_hud"]=false
			Settings.current["text_scale"]=scale
			UiStyle.clock_override_ms=5000000
			var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="float-pile-tests";root.add_child(g);await settle();g.set_process(false)
			var tag="%dx%d@%d%%"%[shape.x,shape.y,roundi(scale*100)]
			await note_checks(g,tag)
			await tip_checks(g,tag)
			await loss_checks(g,tag)
			await strip_checks(g,tag,scale)
			await chip_checks(g,tag)
			await tap_checks(g,tag)
			await label_checks(g,tag)
			await wheel_checks(g,tag,scale)
			g.queue_free();await settle()
	UiStyle.clock_override_ms=-1
	print("FLOAT PILE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
