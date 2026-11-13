extends SceneTree
# WP-09: the planning camera and the order flow, driven through the real Main scene with
# touch events followed by their emulated mouse events, as a phone delivers them.
# 1. While paused, selecting a craft does not move or rescale the view.
# 2. RESUME closes any open ring or order dialog and resumes in the same press.
# 3. The order dialog and its status line name controls that exist and say what is true now.
# 4. While the route confirm dialog is open the simulation does not advance.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func touch(point:Vector2,pressed:bool,index:int=0):
	var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;root.push_input(e,true);await process_frame
func mouse(point:Vector2,pressed:bool):
	var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true);await process_frame
func tap(point:Vector2):
	await touch(point,true);await mouse(point,true);await touch(point,false);await mouse(point,false);await settle()
func click(button:Control):await tap(button.get_global_rect().get_center())
func drag(from:Vector2,to:Vector2):
	await touch(from,true)
	for n in range(1,9):
		var e=InputEventScreenDrag.new();e.index=0;e.position=from.lerp(to,n/8.0);e.relative=(to-from)/8.0;root.push_input(e,true);await process_frame
	await touch(to,false);await settle()
func key(code:int):
	for down in [true,false]:
		var e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;root.push_input(e,true);await process_frame
	await settle()
func view(g)->Array:
	g.ocean.screen_position(Vector2.ZERO)
	return [g.ocean.world_offset,g.ocean.world_scale]
func same_view(a:Array,b:Array)->bool:
	return a[0].distance_to(b[0])<.01 and absf(a[1]-b[1])<.0001
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
	# The once-only lock and sweep tips pause by design; they are not under test here.
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
func fleet_page(g)->void:
	await click(g.advanced_button)
func run():
	Settings.current["mirrored_hud"]=false
	root.size=Vector2i(2520,1080);await settle()
	var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="planning-order-flow-tests";root.add_child(g);await settle();g.set_process(false)
	await camera_checks(g)
	await resume_checks(g)
	await order_text_checks(g)
	await hold_checks(g)
	await status_checks(g)
	await dialog_place_checks(g)
	await contact_card_checks(g)
	await label_checks(g)
	Settings.current["mirrored_hud"]=true
	await mirrored_resume_check(g)
	Settings.current["mirrored_hud"]=false
	g.queue_free();await settle()
	root.size=Vector2i(2184,1968);await settle()
	g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="planning-order-flow-tests";root.add_child(g);await settle();g.set_process(false)
	await planner_resume_check(g)
	await dialog_place_checks(g)
	await contact_card_checks(g)
	Settings.current["mirrored_hud"]=true
	await planner_resume_check(g)
	Settings.current["mirrored_hud"]=false
	g.queue_free();await settle()
	print("PLANNING ORDER FLOW UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

# 5. WP-36: the bottom status shows what is current. The LAST result belongs to the previous order;
# the next order to any craft (or selecting another craft) clears it, and an accepted order replaces a
# stale cancelled message. Nothing here waits on a timer: a paused plan keeps its message.
func status_checks(g)->void:
	await fresh(g)
	var hud=g.mission_hud
	hud.task_result={"owner":"QUIETUS","ok":true,"text":"Camera exposure · hold 4 seconds"};g.sim.message="Marker cancelled · orders unchanged";g._refresh();await settle()
	check("LAST ·" in hud.intent.text and "Marker cancelled" in hud.intent.text,"before the next order the result and the message are shown")
	for n in 120:await process_frame
	check("LAST ·" in hud.intent.text and "Marker cancelled" in hud.intent.text,"waiting while paused does not remove them")
	g._order("select",{"unit":0});g._refresh();await settle()
	check("LAST ·" in hud.intent.text,"selecting the craft that is already selected keeps the result")
	g._order("hold");g._refresh();await settle()
	check(hud.task_result.is_empty() and "LAST ·" not in hud.intent.text,"the next order clears the LAST result")
	check("Marker cancelled" not in hud.intent.text and "Marker cancelled" not in g.sim.message,"an accepted order replaces the cancelled message")
	check(hud.intent.text.split("\n").size()<=2,"at rest the status is the current line and the standing hint: "+hud.intent.text)
	hud.task_result={"owner":"QUIETUS","ok":false,"text":"Camera refused"};g._refresh();await settle()
	g._order("select",{"unit":1});g._refresh();await settle()
	check(hud.task_result.is_empty(),"selecting another craft clears the LAST result")
	g.sim.message="Marker cancelled · orders unchanged";g._order("select",{"unit":99});g._refresh();await settle()
	check(g.sim.message=="Marker cancelled · orders unchanged","a refused order keeps the message it reports")

# 1. Planning camera.
func camera_checks(g)->void:
	await fresh(g)
	check(g.ocean.chart_camera.mode=="follow","the dive opens with the camera following the selected craft")
	var before=view(g)
	await fleet_page(g)
	check(g.advanced_orders and g.unit_buttons[1].is_visible_in_tree(),"FLEET offers the craft buttons")
	await click(g.unit_buttons[1])
	check(g.sim.selected==1,"the DRONE A button selects drone A")
	check(same_view(view(g),before),"paused: selecting drone A from FLEET leaves the view where it was")
	g.mission_hud.dismiss();g._refresh();await settle()
	check(same_view(view(g),before),"paused: closing the ring leaves the view where it was")
	await tap(screen(g,g.sim.units[2].pos))
	check(g.sim.selected==2,"tapping drone B on the chart selects it")
	check(same_view(view(g),before),"paused: tapping a craft on the chart leaves the view where it was")
	g.mission_hud.dismiss();g._refresh();await settle()
	check(same_view(view(g),before),"paused: the view still has not moved after the ring closes")
	await click(g.pause_button)
	check(not g.sim.paused,"RESUME resumes")
	check(g.ocean.chart_camera.mode=="follow" and g.ocean.chart_camera.desired_center.distance_to(g.sim.units[2].pos)<.01,"resumed without a pan: the camera follows the selected craft as before")
	var running=view(g)
	g._order("select",{"unit":0});g._refresh();await settle()
	check(g.ocean.chart_camera.mode=="follow" and g.ocean.chart_camera.desired_center.distance_to(g.sim.units[0].pos)<.01 and not same_view(view(g),running),"running: selecting a craft still follows it at once")
	# A pan while paused is the player's intent; resuming keeps it.
	await fresh(g)
	g._order("select",{"unit":1});g._refresh();await settle()
	var middle=g.ocean.get_global_rect().get_center()
	await drag(middle,middle+Vector2(-160,90))
	check(g.ocean.chart_camera.mode=="free","a drag pans into free view")
	var panned=g.ocean.chart_camera.snapshot()
	await click(g.pause_button)
	check(not g.sim.paused and g.ocean.chart_camera.mode=="free" and g.ocean.chart_camera.snapshot()==panned,"resumed after a pan: the panned view is kept")
	# FOCUS stays the explicit way to recentre.
	await fresh(g)
	before=view(g)
	g._order("select",{"unit":2});g._refresh();await settle()
	check(same_view(view(g),before),"paused: a select order from any surface leaves the view")
	await fleet_page(g)
	await click(g.mission_hud.extra.view_menu)
	check(g.mission_hud.page=="view" and g.mission_hud.focus_button.is_visible_in_tree(),"FLEET then VIEW offers FOCUS")
	await click(g.mission_hud.focus_button)
	check(g.ocean.chart_camera.mode=="follow" and g.ocean.chart_camera.desired_center.distance_to(g.sim.units[2].pos)<.01,"FOCUS recentres on the selected craft")
	check(g.sim.paused,"FOCUS does not resume the dive")

# 2. RESUME always resumes.
func resume_checks(g)->void:
	await fresh(g)
	await tap(screen(g,g.sim.units[0].pos))
	check(g.advanced_orders,"tapping Quietus opens its command ring")
	await click(g.pause_button)
	check(not g.sim.paused,"RESUME with a ring open resumes in the same press")
	check(not g.advanced_orders,"RESUME with a ring open also closes the ring")
	await click(g.pause_button)
	check(g.sim.paused,"PAUSE pauses again")
	await tap(screen(g,g.sim.units[0].pos))
	await click(g.mission_hud.extra.route_menu)
	check(g.advanced_orders and g.mission_hud.page=="route","the ROUTE page is open")
	await key(KEY_SPACE)
	check(not g.sim.paused and not g.advanced_orders,"SPACE with a ring open closes it and resumes")
	await key(KEY_SPACE)
	check(g.sim.paused,"SPACE pauses")
	# An open order dialog does not keep RESUME from resuming.
	await fresh(g)
	var first=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,first))
	var second=water(g,g.sim.units[0].pos,[first,g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,second))
	check(g.mission_hud.guard.panel.visible,"a second water tap opens the order dialog")
	var goals=g.sim.route_goals().duplicate(true)
	await click(g.pause_button)
	check(not g.sim.paused,"RESUME with the order dialog open resumes")
	check(not g.mission_hud.guard.panel.visible and g.mission_hud.guard.pending.is_empty(),"RESUME closes the order dialog")
	check(g.sim.route_goals()==goals,"closing the dialog through RESUME leaves the orders unchanged")
func mirrored_resume_check(g)->void:
	await fresh(g)
	await tap(screen(g,g.sim.units[0].pos))
	check(g.advanced_orders,"mirrored: tapping Quietus opens its command ring")
	await click(g.pause_button)
	check(not g.sim.paused and not g.advanced_orders,"mirrored: RESUME closes the ring and resumes in one press")
# The route planner hides the HUD; DONE returns to a paused chart whose RESUME
# must answer a tap anywhere on its visible label.
func planner_resume_check(g)->void:
	await fresh(g)
	var side="mirrored" if Settings.current.get("mirrored_hud",false) else "normal"
	g._order("program");await settle()
	check(g.screen=="program" and g.sim.paused,side+": PLAN ROUTE opens the paused planner")
	var done=null
	for b in g.route_editor.find_children("*","Button",true,false):
		if b.get_meta("action","")=="close":done=b
	await click(done)
	check(g.screen=="mission" and g.sim.paused,side+": DONE returns to the chart, still paused")
	var b:Button=g.pause_button;var r:Rect2=b.get_global_rect()
	var font=b.get_theme_font("font");var size=b.get_theme_font_size("font_size");var margin=b.get_theme_stylebox("normal").get_minimum_size()
	var text_height=font.get_multiline_string_size(b.text,HORIZONTAL_ALIGNMENT_CENTER,maxf(1.,r.size.x-margin.x),size).y
	check(r.size.y+.5>=text_height+margin.y,side+": the RESUME control is as tall as its label")
	await tap(Vector2(r.get_center().x,r.position.y+margin.y/2+text_height-3))
	check(not g.sim.paused,side+": a tap on the last line of RESUME resumes")

# 3. Truthful order text.
func visible_texts(g)->Array:
	var guard=g.mission_hud.guard;var texts=[]
	for b in [guard.go_button,guard.add_button,guard.points_button,guard.cancel_button,guard.undo_button]:
		if b.is_visible_in_tree() and not b.disabled:texts.append(b.text)
	return texts
func order_text_checks(g)->void:
	await fresh(g)
	var guard=g.mission_hud.guard
	var first=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,first))
	check(g.sim.route_goals().size()==1 and not guard.panel.visible,"a first water tap plots a leg at once")
	var second=water(g,g.sim.units[0].pos,[first,g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,second))
	check(guard.panel.visible,"a second water tap asks first")
	check(not ("GO " in g.sim.message) and not g.sim.message.begins_with("GO"),"the status line names no GO control")
	check("REPLACE ROUTE" in g.sim.message and "REPLACE ROUTE" in visible_texts(g),"the status line names the REPLACE ROUTE button that is on screen")
	check("1 stop" in guard.prompt.text,"the dialog counts the one stop the route has")
	check(guard.add_button.visible and not guard.add_button.disabled,"ADD TO ROUTE is offered for a craft with a route")
	await click(guard.go_button)
	check(not guard.panel.visible and g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(second)<1,"REPLACE ROUTE replaces the route")
	check(guard.undo_button.visible and "1 stop" in guard.undo_button.text,"UNDO says it restores the earlier one-stop route")
	await click(guard.undo_button)
	check(g.sim.route_goals().size()==1 and g.sim.route_goals()[0].pos.distance_to(first)<1,"UNDO restores the earlier route")
	check(not guard.panel.visible and not guard.undo_button.visible,"UNDO leaves no stale dialog")
	var third=water(g,g.sim.units[0].pos,[first,second,g.sim.units[1].pos,g.sim.units[2].pos])
	await tap(screen(g,third))
	check(guard.panel.visible and "1 stop" in guard.prompt.text,"after UNDO the dialog reads the restored route")
	await click(guard.cancel_button)
	check(not guard.panel.visible and g.sim.route_goals()[0].pos.distance_to(first)<1,"CANCEL keeps the orders")
	# A first leg undone: the craft has no orders, so the next tap does not ask.
	await fresh(g)
	await tap(screen(g,first))
	check(guard.undo_button.visible and "no route" in guard.undo_button.text.to_lower(),"UNDO after a first leg says it returns to no route")
	await click(guard.undo_button)
	check(g.sim.route_goals().is_empty(),"UNDO removes the first leg")
	await tap(screen(g,second))
	check(not guard.panel.visible and g.sim.route_goals().size()==1,"after that UNDO the next tap plots at once without a stale dialog")
	# A craft that only holds: the dialog names the hold and offers no dead ADD control.
	await fresh(g)
	g._order("hold");g._refresh();await settle()
	await tap(screen(g,first))
	check(guard.panel.visible,"a holding craft asks before a new route")
	check("HOLD" in guard.prompt.text.to_upper() and not ("stop" in guard.prompt.text),"the dialog says the craft is holding")
	check(not (guard.add_button.visible and guard.add_button.disabled),"no disabled ADD TO ROUTE is shown when there is no route to add to")
	await click(guard.go_button)
	check(g.sim.units[0].hold=="" and g.sim.route_goals().size()==1,"the replace button sets the route and releases the hold")
	# The ROUTE page wedge is a mode switch and reads as one.
	await fresh(g)
	await tap(screen(g,g.sim.units[0].pos))
	await click(g.mission_hud.extra.route_menu)
	var wedge=g.order_buttons.queue
	check(wedge.is_visible_in_tree() and wedge.text!="REPLACE" and "REPLACE" in wedge.text and "TAP" in wedge.text,"the wedge names the water-tap mode, not a REPLACE action")
	await click(wedge)
	check(g.sim.queue_mode and "QUEUE" in wedge.text and "TAP" in wedge.text,"pressing it switches taps to QUEUE and says so")
	await tap(screen(g,g.sim.units[0].pos))
	await click(g.mission_hud.extra.route_menu)
	await click(wedge)
	check(not g.sim.queue_mode and "REPLACE" in wedge.text,"pressing again switches back")
	# A tip card never swallows a dialog press.
	await fresh(g)
	await tap(screen(g,first))
	g.mission_hud.hints.show_hint("drone");g._refresh();await settle()
	await tap(screen(g,second))
	var hint=g.mission_hud.hints.panel
	check(not (hint.visible and hint.get_global_rect().intersects(guard.panel.get_global_rect())),"a tip card never overlaps the order dialog")
	await click(guard.add_button)
	check(not guard.panel.visible and g.sim.route_goals().size()==2,"the first ADD TO ROUTE press acts")

# 5. WP-35: the route dialog covers neither the selected craft nor the pending marker, and stays on screen.
func dialog_place_checks(g)->void:
	var shape="%dx%d"%[root.size.x,root.size.y]
	for pan in [Vector2.ZERO,Vector2(0,300),Vector2(0,-300)]:
		for target in ["top","bottom","corner"]:
			await fresh(g)
			var guard=g.mission_hud.guard;var h:float=g.ui_touch_height
			if pan!=Vector2.ZERO:g.ocean.pan_chart(pan)
			var at:Vector2=g.ocean.get_global_rect().size*(Vector2(.5,.2) if target=="top" else Vector2(.5,.82) if target=="bottom" else Vector2(.08,.85))
			var craft:Vector2=g.ocean.screen_position(g.sim.units[0].pos)
			var point:Vector2=g.sim.units[0].pos+(at-craft)/g.ocean.world_scale
			guard.pending={"unit":0,"point":point};g._refresh();await settle()
			var tag="%s pan %d marker %s"%[shape,int(pan.y),target]
			check(guard.panel.visible and g.ocean.screen_position(point).distance_to(at)<2.,"%s: the dialog is open over a marker placed where intended"%tag)
			var panel:Rect2=guard.panel.get_rect()
			check(Rect2(Vector2.ZERO,g.mission_hud.size).encloses(panel),"%s: the dialog stays inside the safe area %s in %s"%[tag,panel,g.mission_hud.size])
			check(not panel.intersects(guard.craft_rect(h)),"%s: the dialog does not cover the selected craft"%tag)
			check(not panel.intersects(guard.marker_rect(h)),"%s: the dialog does not cover the marker"%tag)
			guard.cancel();await settle()

# 4. The dialog holds the dive.
func hold_checks(g)->void:
	for start_paused in [false,true]:
		for finish in ["cancel","go"]:
			await fresh(g)
			var guard=g.mission_hud.guard
			var first=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
			await tap(screen(g,first))
			g.sim.paused=start_paused;g._refresh()
			var before=g.sim.elapsed
			if not start_paused:
				g._process(.2)
				check(g.sim.elapsed>before,"control: the running dive advances without a dialog")
			var second=water(g,g.sim.units[0].pos,[first,g.sim.units[1].pos,g.sim.units[2].pos])
			await tap(screen(g,second))
			check(guard.panel.visible,"the order dialog is open (%s, %s)"%["paused" if start_paused else "running",finish])
			var held=g.sim.elapsed
			for n in 5:g._process(.2)
			check(g.sim.elapsed==held,"no dive time passes while the order dialog is open (%s)"%("paused" if start_paused else "running"))
			check(g.sim.paused==start_paused,"the dialog does not change the pause state")
			await click(guard.cancel_button if finish=="cancel" else guard.go_button)
			check(not guard.panel.visible and g.sim.paused==start_paused,"closing with %s returns the dive to its earlier state"%finish.to_upper())
			held=g.sim.elapsed;g._process(.2)
			check((g.sim.elapsed>held)!=start_paused,"after %s time runs only if it ran before"%finish.to_upper())

# 6. UI review B6: a tap on a drawn contact opens its card and sets no route and no marker.
func plant_contact(g,id:int,pos:Vector2,known:bool=false)->void:
	g.sim.contacts[id]={"pos":pos,"time":g.sim.elapsed,"mode":"INVESTIGATE","lock":0.0,"angle":0.0,"target":-1,"type":"hunter","display_type":"hunter" if known else "PATROLLER","band":1,"transition":{},"source":"optical","confidence":1.0,"seen_by":[]}
	if known:g.sim.sonar["identified"]={id:"hunter"}
	elif g.sim.sonar.has("identified"):g.sim.sonar.identified.erase(id)
	g._refresh();await settle()
func nothing_ordered(g)->bool:
	return g.sim.route_goals().is_empty() and g.mission_hud.guard.pending.is_empty() and not g.advanced_orders
func card_area(g)->Rect2:
	return Rect2(Vector2.ZERO,Vector2(g.ocean.chart_width(),g.mission_hud.size.y))
func contact_card_checks(g)->void:
	var shape="%dx%d"%[root.size.x,root.size.y]
	await fresh(g)
	var hud=g.mission_hud;var card=hud.contact_card
	var spot=water(g,g.sim.units[0].pos,[g.sim.units[1].pos,g.sim.units[2].pos])
	var elsewhere=water(g,spot,[spot,g.sim.units[0].pos,g.sim.units[1].pos,g.sim.units[2].pos])
	check(spot!=Vector2.INF and elsewhere!=Vector2.INF,shape+": the card fixture found two clear water points")
	await plant_contact(g,9,spot)
	check(not card.is_open(),shape+": a drawn contact alone opens no card")
	await tap(screen(g,spot))
	check(card.is_open() and card.key==9 and g.ocean.selected_contact==9,shape+": tapping a drawn contact opens its card and marks it")
	check(nothing_ordered(g) and g.sim.paused,shape+": the contact tap sets no route and no marker, and leaves the dive paused")
	var c=g.sim.contacts[9];var u=g.sim.units[0];var d=card.shown
	var entry=card.entry_for(g.sim,9)
	check(d.title==entry.text and "S10" in d.title,shape+": the card title is the readout label of that contact")
	check(d.range==roundi(u.pos.distance_to(c.pos)) and d.facts=="RANGE %dm · BEARING %03d° · SEEN NOW"%[d.range,d.bearing],shape+": range, bearing and age come from the observed contact: "+d.facts)
	check(d.tell.is_empty() and d.counter.is_empty(),shape+": an unidentified role shows no dossier lines")
	var live=g.sim.sirens;g.sim.sirens=[]
	check(card.describe(g.sim,9)==d,shape+": the card reads no hidden Siren state")
	g.sim.sirens=live
	var shown_rect:Rect2=card.panel.get_rect();var h:float=hud.touch_height
	check(card_area(g).encloses(shown_rect),shape+": the card stays inside the safe area %s"%shown_rect)
	check(not shown_rect.intersects(card.contact_rect(h)) and not shown_rect.intersects(card.craft_rect(h)),shape+": the card covers neither the contact nor the selected craft")
	# Trial rule 1 (trial_rules.gd): an open contact card holds dive time. Off, the old behaviour: the dive keeps running.
	var rules=preload("res://src/trial_rules.gd")
	g.sim.paused=false;g._refresh();var held=g.sim.elapsed;g._process(.2)
	check(is_equal_approx(g.sim.elapsed,held) and not g.sim.paused and card.is_open(),shape+": rule 1 on: the open card holds dive time without pausing")
	rules.override("WHEEL_HOLDS_TIME",false)
	g._process(.2)
	check(g.sim.elapsed>held and card.is_open(),shape+": rule 1 off: a running dive keeps running with the card open")
	rules.reset()
	g.sim.paused=true;g._refresh()
	await tap(screen(g,elsewhere))
	check(not card.is_open() and g.ocean.selected_contact==-1 and nothing_ordered(g),shape+": a tap elsewhere closes the card and does nothing else")
	await tap(screen(g,spot))
	await click(card.close_button)
	check(not card.is_open() and nothing_ordered(g),shape+": CLOSE closes the card and orders nothing")
	# A stale contact keeps its last observed place and says how old it is.
	g.sim.contacts[9].time=g.sim.elapsed-8.;g._refresh();await settle()
	await tap(screen(g,spot))
	check(card.is_open() and "SEEN 8s AGO" in card.shown.facts and "LAST SEEN 8s" in card.shown.title and card.shown.range==d.range,shape+": a stale contact says how old it is: "+card.shown.facts)
	card.close();await settle()
	# An identified role adds the dossier's tell and counterplay lines.
	await plant_contact(g,9,spot,true)
	await tap(screen(g,spot))
	var role:Dictionary={}
	for row in preload("res://src/presentation/siren_dossier/dossier_table.gd").ROLES:
		if row.id=="hunter":role=row
	check(card.is_open() and card.shown.tell=="OBSERVABLE TELL · "+role.tell and card.shown.counter=="COUNTERPLAY · "+role.counter,shape+": an identified role shows its dossier tell and counterplay")
	check(card.tell_label.visible and card.counter_label.visible and card_area(g).encloses(card.panel.get_rect()),shape+": the longer card stays inside the safe area %s"%card.panel.get_rect())
	check(not card.panel.get_rect().intersects(card.contact_rect(h)) and not card.panel.get_rect().intersects(card.craft_rect(h)),shape+": the longer card covers neither the contact nor the craft")
	card.close();await settle()
	# With a torpedo armed the tap is a target pick, never a card.
	g.knock_armed=true;g._refresh()
	await tap(screen(g,spot))
	check(not card.is_open() and g.sim.route_goals().is_empty(),shape+": with a torpedo armed a contact tap opens no card")
	g.knock_armed=false;g.decoy_armed=false;g._refresh();await settle()
	# A craft under the same finger: the contact joins the choice list.
	await plant_contact(g,9,g.sim.units[1].pos+Vector2(10,0))
	await tap(screen(g,g.sim.units[1].pos))
	check(hud.page=="choose" and hud.target_buttons.any(func(b):return b.text.begins_with("S10")),shape+": a craft and a contact under the finger give a choice list that names the contact")
	var pick=null
	for b in hud.target_buttons:
		if b.text.begins_with("S10"):pick=b
	if pick!=null:await click(pick)
	check(card.is_open() and not g.advanced_orders and nothing_ordered(g),shape+": choosing the contact opens its card and orders nothing")
	card.close();await settle()
	# A Siren the player has not observed has no card: the tap sets a route as before.
	g.sim.contacts.erase(9);g._refresh();await settle()
	await tap(screen(g,spot))
	check(not card.is_open() and not g.sim.route_goals().is_empty(),shape+": an unobserved Siren has no card and the tap plots a route")

# 7. UI review C10: chart labels sit on plates and never overlap each other.
func label_checks(g)->void:
	await fresh(g)
	var o=g.ocean;o.world_label_rects.clear()
	var at=g.sim.units[0].pos+Vector2(200,-150)
	var first="UNKNOWN SIGNAL SOURCE · AREA · BRG 276";var second="EXTRACTION"
	var a=o.world_label_position(at,first,16);o.reserve_world_label(a,first,16)
	var b=o.world_label_position(at,second,18);o.reserve_world_label(b,second,18)
	check(a.is_finite() and b.is_finite() and not o.label_plate(a,first,16).intersects(o.label_plate(b,second,18)),"two labels made to coincide end up with separate plates")
	check(o.world_label_rects.size()==2 and o.world_label_rects[0]==o.label_plate(a,first,16),"a placed label reserves its whole plate")
	check(o.label_priority("S1 SIGHT ~300m",{})<o.label_priority("EXTRACTION",{}) and o.label_priority("EXTRACTION",{})<o.label_priority("OWN SHUTTER",{}) and o.label_priority("OWN SHUTTER",{})<o.label_priority("PRESSURE / 3s",{}),"labels rank threat, objective, own craft, landmark")
	check(o.label_plate_colour().a<1.,"the plate is translucent in the standard palette")
	Settings.current["high_contrast"]=true
	check(o.label_plate_colour().a==1.,"the plate is fully opaque in high contrast")
	Settings.current["high_contrast"]=false
