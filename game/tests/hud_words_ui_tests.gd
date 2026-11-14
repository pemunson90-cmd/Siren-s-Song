extends SceneTree
# WP-48: in-dive wording and state. The pause plate names the state first; the silent segment and its centre
# caption say what a tap does and costs, with every figure read from the simulation's own constants; a craft
# that runs out of route says so once without pausing the dive; a route dialog is named as the reason time is held.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const TrialRules=preload("res://src/trial_rules.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func make(shape:Vector2i,scale:float):
	root.size=shape;await settle()
	Settings.current["text_scale"]=scale
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp48-words-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle();game._layout();await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	return game
func run():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			await plate_case(shape,scale)
	Settings.current=saved
	Settings.current["text_scale"]=1.0
	await centre_case()
	await silent_case()
	await two_tap_case()
	await slot_case()
	await fit_case()
	await rock_case()
	await prompt_case()
	await planner_case()
	await route_end_case()
	Settings.current=saved
	TrialRules.reset()
	print("HUD WORDS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func plate_case(shape:Vector2i,scale:float):
	var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
	var game=await make(shape,scale)
	var pause:Button=game.pause_button
	for paused in [true,false]:
		game.sim.paused=paused;game._refresh();await settle()
		var lines=pause.text.split("\n")
		check(lines[0]==("PAUSED" if paused else "RUNNING"),"the plate names the state first "+stamp+" "+str(lines))
		check(lines.size() in [2,3] and "O₂" in lines[-1],"the plate keeps the oxygen reading under the state "+stamp+" "+str(lines))
		var size=pause.get_theme_font_size("font_size")
		var inner=pause.get_theme_font("font").get_multiline_string_size(pause.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
		check(inner.x<=pause.size.x-pause.get_theme_stylebox("normal").get_minimum_size().x+0.5 and inner.y<=pause.size.y,"both lines fit inside the plate "+stamp+" "+str(inner)+" in "+str(pause.size))
		check(pause.get_meta("ui_role","")==("MAIN" if paused else "QUIET"),"paused is filled, running is a quiet outline "+stamp)
	game.queue_free();await settle()
func silent_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var hud=game.mission_hud
	var sight=Words.sights()
	check(sight.silent==Pricing.SIREN_SIGHT_SILENT and sight.open==Pricing.SIREN_SIGHT,"the shown sight ranges are the simulation's constants")
	for silent in [false,true]:
		s.units[0].silent=silent;s.selected=0;game._refresh();await settle()
		var speed=Words.speeds(s)
		check(speed.cruise==CraftUpgrades.cruise_speed(s.mission.get("launch_equipment",{})),"the cruise figure is the fitted cruise speed")
		check(game.order_buttons.silent.text==("GO LOUD" if silent else "GO SILENT"),"the silent segment names the action its tap performs: "+game.order_buttons.silent.text)
		check(Words.state_line("silent",s)==("silent is on" if silent else "running loud"),"its small second line names the state: "+Words.state_line("silent",s))
		var caption="\n".join(Words.silent_caption(s))
		check(caption.begins_with(game.order_buttons.silent.text),"the centre caption starts with the same name as the segment: "+caption)
		if silent:check(("full speed (%d m/s) · seen from %d m"%[roundi(speed.cruise),roundi(sight.open)]) in caption,"silent on says what the tap gives back: "+caption)
		else:check(("slower (%d m/s) · seen from %d m"%[roundi(speed.silent),roundi(sight.silent)]) in caption,"silent off says its cost and its gain: "+caption)
	# A finger on the segment, or the last one touched, puts the caption in the wheel's centre.
	s.units[0].silent=false;hud.open("craft");await settle()
	hud.wheel_focus=game.order_buttons.silent;hud.queue_redraw();await settle()
	check(hud.caption_texts.any(func(t):return "slower (" in t),"the wheel centre carries the silent caption for the touched segment: "+str(hud.caption_texts))
	hud.wheel_focus=null;hud.queue_redraw();await settle()
	check(not hud.caption_texts.any(func(t):return "slower (" in t),"the caption leaves with the touch")
	# A drone's segment names the profile a tap switches to and its small line says which one is on now.
	s.selected=1;s.units[1].silent=true;game._refresh();await settle()
	check(game.order_buttons.silent.text=="GO OPEN" and Words.state_line("silent",s)=="low profile is on" and "290 m, not 180 m" in "\n".join(Words.silent_caption(s)),"a drone on low profile offers GO OPEN and says what it changes: "+game.order_buttons.silent.text)
	s.units[1].silent=false;game._refresh();await settle()
	check(game.order_buttons.silent.text=="GO LOW PROFILE" and Words.state_line("silent",s)=="open profile" and "180 m, not 290 m" in "\n".join(Words.silent_caption(s)),"a drone on the open profile offers GO LOW PROFILE: "+game.order_buttons.silent.text)
	# The sonar segments use the plain words.
	s.selected=0;game._refresh();hud.open("acoustics");await settle()
	check(hud.extra.sonar_emit.text.begins_with("PING SONAR\nuses ") and hud.extra.sonar_history.text=="PAST PINGS","the sonar segments say PING SONAR and PAST PINGS")
	check(hud.extra.sonar_sector.text=="PING ARC\nALL" and hud.extra.sonar_power.text=="PING POWER\nLOW","the arc and power segments say what they set: "+hud.extra.sonar_sector.text+" / "+hud.extra.sonar_power.text)
	game.queue_free();await settle()
func touch(point:Vector2,down:bool):
	var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
# WP-81: the wheel's centre says each fact once, never below the reading floor, with no glyph the font lacks; a
# segment's second line stays clear of its name; the target chooser asks the right question.
func centre_case():
	var CenterLayout=preload("res://src/presentation/radial_layout/center_layout.gd")
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
			var game=await make(shape,scale)
			var s=game.sim;var hud=game.mission_hud;s.selected=0
			var o:Dictionary=s.mission.objectives[0]
			var floor_px:int=CenterLayout.reading_floor(hud)
			game._refresh();hud.open("craft");await settle()
			centre_checks(hud,floor_px,"camera not ready, lead "+stamp)
			var joined=" ".join(hud.caption_texts)
			check("UNKNOWN SIGNAL SOURCE" in joined.replace("\n"," ") and "NOT READY" in joined and joined.count("240")==1,"the target, NOT READY and the reach once: "+str(hud.caption_texts)+" "+stamp)
			# Resolved and in reach: READY with the distance and reach.
			o.erase("unknown");var u=s.units[0];u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.0;u.vel=Vector2.ZERO;u.angle=u.pos.angle_to_point(o.pos)
			game._refresh();hud.queue_redraw();await settle()
			centre_checks(hud,floor_px,"camera ready "+stamp)
			check("READY" in " ".join(hud.caption_texts),"the ready camera says READY: "+str(hud.caption_texts)+" "+stamp)
			# Armed two-tap segment: cost lines and the confirm line.
			s.units[0].silent=false;game._refresh();hud.open("craft");await settle()
			await click(game.order_buttons.silent)
			centre_checks(hud,floor_px,"armed segment "+stamp)
			check(hud.caption_texts.any(func(t):return "Tap again to confirm" in t),"the armed segment keeps its confirm line: "+str(hud.caption_texts)+" "+stamp)
			hud.segments.disarm()
			segment_marks(game,"craft "+stamp)
			hud.open("acoustics");await settle()
			centre_checks(hud,floor_px,"acoustics page "+stamp)
			game.queue_free();await settle()
	var game=await make(Vector2i(2520,1080),1.0)
	var hud=game.mission_hud
	hud.target_choices=[{"kind":"craft","unit":0},{"kind":"craft","unit":1}]
	check(Words.choose_prompt(hud.target_choices)=="WHICH CRAFT?","only craft to choose from: "+Words.choose_prompt(hud.target_choices))
	hud.target_choices.append({"kind":"objective","name":"SITE"})
	check(Words.choose_prompt(hud.target_choices)=="CRAFT OR OBJECT?","craft and an object: "+Words.choose_prompt(hud.target_choices))
	game.queue_free();await settle()
func centre_checks(hud,floor_px:int,label:String):
	var seen={}
	for t in hud.caption_texts:
		check(not seen.has(t),"no line repeats in the centre: "+str(t)+" ("+label+")")
		seen[t]=true
		check(not "▸" in t,"no glyph the font lacks: "+str(t)+" ("+label+")")
	check(hud.caption_size>=floor_px,"the centre type %d is at or above the floor %d (%s)"%[hud.caption_size,floor_px,label])
	check(hud.caption_texts.size()<=7,"the centre stays short: "+str(hud.caption_texts)+" ("+label+")")
func segment_marks(game,label:String):
	for b in game.mission_hud.ring_buttons:
		var mark:Label=b.get_node_or_null("StateLine")
		if mark==null or not mark.visible:continue
		var margin=b.get_theme_stylebox("normal").content_margin_bottom
		check(mark.get_global_rect().position.y>=b.get_global_rect().position.y+b.size.y-margin-1.,"the second line sits below the segment's name: "+b.text+" ("+label+")")
func click(button):
	var point=button.get_global_rect().get_center()
	for down in [true,false]:
		await touch(point,down)
		var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
	await settle()
# WP-52: a segment that costs something is armed by its first tap and performed by its second.
func two_tap_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var hud=game.mission_hud
	check(Words.TWO_TAP==["silent","all_stop"],"the two-tap list is one table: "+str(Words.TWO_TAP))
	s.selected=0;s.units[0].silent=false;game._refresh();hud.open("craft");await settle()
	var button=game.order_buttons.silent
	check(button in hud.ring_buttons,"the silent segment is on Quietus's wheel")
	var before=s.snapshot()
	await click(button)
	check(hud.segments.armed=="silent" and not s.units[0].silent and s.snapshot()==before,"the first tap arms the segment and changes nothing in the simulation")
	check(hud.caption_texts.any(func(t):return "Tap again to confirm" in t) and hud.caption_texts.any(func(t):return "slower (" in t),"the centre shows the cost and asks for a second tap: "+str(hud.caption_texts))
	var fill=UiStyleRef.role_colors(UiStyleRef.MAIN).fill
	check(hud.segments.is_armed(button) and button.get_theme_color("font_color")==UiStyleRef.role_colors(UiStyleRef.MAIN).text and fill!=Color(.025,.095,.12,.9),"the armed segment is drawn with the MAIN role colours")
	await click(button)
	check(s.units[0].silent and hud.segments.armed=="","the second tap on the same segment goes silent")
	check(game.order_buttons.silent.text=="GO LOUD","and the segment now offers GO LOUD: "+game.order_buttons.silent.text)
	# Another segment, or outside the wheel, disarms.
	s.units[0].silent=false;game._refresh();hud.open("craft");await settle()
	await click(game.order_buttons.silent)
	check(hud.segments.armed=="silent","armed again")
	await click(hud.extra.depth_menu)
	check(hud.segments.armed=="" and not s.units[0].silent and hud.page=="acoustics","a tap on another segment disarms and does its own work")
	hud.open("craft");await settle();await click(game.order_buttons.silent)
	hud.dismiss();await settle()
	check(hud.segments.armed=="" and not s.units[0].silent,"closing the wheel disarms")
	# ALL STOP shows its cost only when armed, and keeps its name.
	hud.open("craft");await settle()
	var stop:Button=hud.extra.all_stop
	check(stop in hud.ring_buttons and stop.text=="ALL STOP","the ALL STOP segment keeps its bare name: "+stop.text)
	var oxygen=s.oxygen
	await click(stop)
	check(hud.segments.armed=="all_stop" and s.oxygen==oxygen and hud.page=="craft" and hud.caption_texts.any(func(t):return "restart" in t),"the first ALL STOP tap arms it and shows the cost in the centre: "+str(hud.caption_texts))
	await click(stop)
	check(hud.page=="route" and hud.segments.armed=="","the second tap performs it")
	# A drone's profile segment is a two-tap too.
	s.selected=1;s.units[1].silent=false;game._refresh();hud.open("craft",{"kind":"craft","unit":1,"pos":s.units[1].pos});await settle()
	var profile=game.order_buttons.silent
	await click(profile)
	check(hud.segments.armed=="silent" and not s.units[1].silent,"a drone's first tap arms the profile switch")
	await click(profile)
	check(s.units[1].silent,"and the second switches it")
	game.queue_free();await settle()
# WP-52: no segment's words cross its own rectangle, and no rectangle crosses the screen-edge margin (cover and inner
# screens, both text scales the layout suites test). The state line has its own room under the name.
func fit_case():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for scale in [1.0,1.5]:
			var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
			var game=await make(shape,scale)
			var s=game.sim;var hud=game.mission_hud
			for who in [0,1]:
				for page in ["craft","route","acoustics"]:
					s.selected=who;game._refresh()
					hud.open(page,{"kind":"craft","unit":who,"pos":s.units[who].pos});await settle()
					var margin=hud.edge_margin(hud.touch_height);var safe=Rect2(Vector2.ZERO,hud.size).grow(-margin+.5)
					for b in hud.ring_buttons:
						var font=b.get_theme_font("font");var size=b.get_theme_font_size("font_size")
						var box=b.get_theme_stylebox("normal").get_minimum_size()
						var inner=font.get_multiline_string_size(b.text,HORIZONTAL_ALIGNMENT_CENTER,b.size.x-box.x,size)
						var widest=0.0
						for word in b.text.split(" ",false):
							for part in word.split("\n",false):widest=maxf(widest,font.get_string_size(part,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x)
						var label="%s on %s page of craft %d at %s: %s"%[b.get_meta("action"),page,who,stamp,b.text.replace("\n"," / ")]
						check(widest<=b.size.x-box.x+.5,"no word crosses its segment: "+label)
						check(inner.y<=b.size.y-box.y+.5,"the words fit the segment's height with room for the state line: "+label+" "+str(inner.y)+" of "+str(b.size.y-box.y))
						if not hud.order_dock.visible:check(safe.encloses(b.get_rect()),"the segment keeps the screen-edge margin: "+label)
						var line:Label=b.get_node_or_null("StateLine")
						if line!=null and line.visible:
							var small=line.get_theme_font_size("font_size")
							check(font.get_string_size(line.text,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x<=b.size.x-box.x+.5,"the state line fits its width: "+label)
					if page=="route" and who==0:
						var stop:Button=hud.extra.all_stop
						check(stop.text=="ALL STOP" and "costs" not in stop.text,"ALL STOP keeps only its name on the segment: "+stop.text)
					if page=="craft":
						check(hud.extra.depth_menu.text=="DEPTH AND\nSONAR","DEPTH AND SONAR is on two lines: "+hud.extra.depth_menu.text)
			game.queue_free();await settle()
const UiStyleRef=preload("res://src/presentation/ui_style.gd")
func slot_key(buttons:Array)->Dictionary:
	var out={}
	for i in buttons.size():out[str(buttons[i].get_meta("action"))]=i
	return out
# WP-52: an action keeps its place in the ring whether or not a drone is aboard.
func slot_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var hud=game.mission_hud
	s.selected=0;game._refresh();hud.open("craft");await settle()
	var aboard=slot_key(hud.ring_buttons)
	check(aboard.has("deploy") and not aboard.has("program") and aboard.deploy==3 and hud.ring_buttons.size()==8,"with a drone aboard DEPLOY takes PLAN ROUTE's place in the ring: "+str(aboard))
	hud.dismiss();await settle()
	for n in 2:
		game._order("select",{"unit":0});ReleaseControls.activate_deploy(hud);await settle()
	game._order("select",{"unit":0});game._refresh();hud.open("craft");await settle()
	var out=slot_key(hud.ring_buttons)
	check(out.has("recall") and out.recall==3 and not out.has("deploy") and hud.ring_buttons.size()==8,"with both drones out RECALL ALL takes the same place: "+str(out))
	for key in aboard:
		if key in ["deploy","recall","program"]:continue
		check(out.get(key,-1)==aboard[key],"%s keeps its angle with the drones in or out (%s then %s)"%[key,str(aboard[key]),str(out.get(key,-1))])
	s.selected=1;game._refresh();hud.open("craft",{"kind":"craft","unit":1,"pos":s.units[1].pos});await settle()
	var drone=slot_key(hud.ring_buttons)
	check(drone.get("recall",-1)==3,"a deployed drone's RECALL sits in the same place: "+str(drone))
	game.queue_free();await settle()
# WP-58: the route prompt keeps its layout, rock is checked along the route actually flown, and a first route reads as set.
func prompt_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var guard=game.mission_hud.guard
	s.paused=true;s.selected=0;game._refresh()
	var first:Vector2=s.units[0].pos+Vector2(60,0)
	if HandPilot.crosses_rock(s,s.units[0].pos,first):first=s.units[0].pos+Vector2(-60,0)
	guard.tap_water(first);await settle()
	check(not s.units[0].route.is_empty() and "set route" in s.message and not ("replaced" in s.message),"a first route reads as set, not replaced: "+s.message)
	# Layout: the action buttons keep their places inside the dialog on every opening and the switch is apart.
	var offsets:Array=[]
	var points:Array[Vector2]=[first+Vector2(0,70),first+Vector2(40,-90),first+Vector2(-80,40)]
	var rp=rock_point(s)
	if rp!=null:points.append(rp)
	for p in points:
		guard.reset();guard.pending={"unit":0,"point":p};game._refresh();await settle()
		var origin:Vector2=guard.panel.get_global_rect().position
		var row:Array=[]
		for b in [guard.go_button,guard.add_button,guard.cancel_button]:row.append(b.get_global_rect().position-origin)
		row.append(guard.panel.size)
		row=row.map(func(v):return Vector2(roundf(v.x),roundf(v.y)))
		offsets.append(row)
		var switch_rect:Rect2=guard.points_button.get_global_rect()
		check(guard.points_button.visible and not switch_rect.intersects(guard.go_button.get_global_rect()) and not switch_rect.intersects(guard.add_button.get_global_rect()) and not switch_rect.intersects(guard.cancel_button.get_global_rect()),"the STOP AT EACH NEW POINT switch sits apart from the actions")
	for i in range(1,offsets.size()):check(offsets[i]==offsets[0],"the prompt's buttons and size are identical on opening %d: %s vs %s"%[i,str(offsets[i]),str(offsets[0])])
	# Rock is read from the end of the queued route when adding, from the craft when replacing.
	var end:Vector2=s.units[0].route.back().pos;var found:Variant=null
	for distance in [200.0,320.0,480.0,700.0]:
		for i in 48:
			var q:Vector2=end+Vector2.from_angle(TAU*i/48.0)*distance
			if Rect2(Vector2.ONE*24,s.world_size()-Vector2.ONE*48).has_point(q) and not HandPilot.rock_at(s,q) and HandPilot.crosses_rock(s,end,q)!=HandPilot.crosses_rock(s,s.units[0].pos,q):
				found=q;break
		if found!=null:break
	if found!=null:
		var adds:bool=HandPilot.crosses_rock(s,end,found)
		var text:String=guard.rock_text(found)
		check(text==(Words.TEXT.rock_route_add if adds else Words.TEXT.rock_route_replace),"the rock sentence names the choice that crosses rock: "+text)
		guard.reset();guard.pending={"unit":0,"point":found};game._refresh();await settle()
		check(guard.prompt.text==text,"the prompt shows the same rock check: "+guard.prompt.text)
	game.queue_free();await settle()
const ReleaseControls=preload("res://src/presentation/release_controls.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
# A water point whose straight leg from the craft crosses charted rock without ending in it.
func rock_point(s)->Variant:
	var from:Vector2=s.units[0].pos
	for distance in [160.0,240.0,320.0,420.0,540.0,700.0,900.0]:
		for i in 32:
			var p:Vector2=from+Vector2.from_angle(TAU*i/32.0)*distance
			if Rect2(Vector2.ONE*24,s.world_size()-Vector2.ONE*48).has_point(p) and not HandPilot.rock_at(s,p) and HandPilot.crosses_rock(s,from,p):return p
	return null
# WP-52: a route across charted rock needs a second tap; the neutral note keeps its own colour.
func rock_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var guard=game.mission_hud.guard
	s.paused=true;s.selected=0;game._refresh()
	var p=rock_point(s)
	check(p!=null,"the opening chart has a water point behind charted rock to test with")
	if p!=null:
		guard.tap_water(p);await settle()
		check(s.units[0].route.is_empty() and not guard.pending.is_empty() and s.message==Words.TEXT.rock_route,"a red leg is not ordered by the first tap and the status line says why: "+s.message)
		check(guard.panel.visible and guard.prompt.text==Words.TEXT.rock_route,"the pending dialog names the rock: "+guard.prompt.text)
		guard.tap_water(p);await settle()
		check(not s.units[0].route.is_empty() and guard.pending.is_empty(),"the second tap on the marker sends it anyway")
		# Open water elsewhere moves the marker without ordering.
		s.command("order_undo",{"goals":[],"hold":""});game._refresh()
		guard.reset();guard.tap_water(p);await settle()
		var clear:Vector2=s.units[0].pos+Vector2(50,0)
		var safe=not HandPilot.crosses_rock(s,s.units[0].pos,clear)
		guard.tap_water(clear);await settle()
		check(not safe or (guard.pending.is_empty() and not s.units[0].route.is_empty()),"a tap on open water orders a clear leg at once")
	check(ReleaseControls.is_warning({"reason":HandPilot.ROCK_REASON}) and not ReleaseControls.is_warning({"reason":"Passes QUIETUS"}),"only a rock leg is a warning; passing another craft is a neutral note")
	check(UiStyleRef.NOTE_COLOR!=ReleaseControls.WARNING,"the note colour is not the warning red")
	check(Words.point_row(1,{"mode":"inherit","stop":true},false)=="Point 1: same speed, stops here" and Words.point_row(2,{"mode":"cruise","stop":false},true)=="Point 2: transit drive, passes through","the status panel's point row reads in plain words")
	game.queue_free();await settle()
# The route planner holds a point whose leg crosses charted rock for a second tap on the same point.
func planner_case():
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim
	s.paused=true;s.selected=0;game._refresh()
	var p=rock_point(s)
	if p==null:check(false,"a rock point exists for the planner");return
	game.route_editor.open(game);await settle()
	game.route_editor.choose_point(p);await settle()
	check(s.route_goals().is_empty() and game.route_editor.preview.pending_point!=null and game.route_editor.point_info.text==Words.TEXT.rock_route,"the planner does not place a red point on the first tap and says why: "+game.route_editor.point_info.text)
	game.route_editor.choose_point(p);await settle()
	check(not s.route_goals().is_empty() and game.route_editor.preview.pending_point==null,"the second tap on the same point places it")
	game.queue_free();await settle()
func route_end_case():
	# The wording and once-only behaviour of the line, with trial rule 3 (pause at route end) switched off through
	# the test seam; the pausing itself is checked at the end and in trial_rules_tests.
	TrialRules.override("PAUSE_AT_ROUTE_END",false)
	var game=await make(Vector2i(2520,1080),1.0)
	var s=game.sim;var hud=game.mission_hud
	var end_line="QUIETUS has stopped: its route is finished."
	s.paused=true
	s.command("select",{"unit":0})
	s.command("route",{"point":s.units[0].pos+Vector2(60,0)})
	s.paused=false;game._refresh()
	var seen=0;var frames=0
	while not s.units[0].route.is_empty() and frames<400:
		s.advance(0.1);frames+=1;game._refresh()
	check(s.units[0].route.is_empty() and not s.paused,"the craft finished its route and the dive kept running")
	for n in 3:s.advance(0.1);game._refresh()
	check(end_line in hud.intent.text,"the status line says the craft stopped: "+hud.intent.text)
	check(hud.intent.text.count(end_line)==1,"the line appears once, not once per frame")
	check(not s.paused,"the line did not pause the dive")
	for n in roundi((Words.ROUTE_END_SECONDS+1.0)/0.1):s.advance(0.1)
	game._refresh()
	check(end_line not in hud.intent.text,"the line leaves after a while: "+hud.intent.text+" notices "+str(hud.route_end.notices)+" at "+str(s.elapsed))
	game.queue_free();await settle()
	# A craft that never had a route says nothing.
	var other=await make(Vector2i(2520,1080),1.0)
	other.sim.paused=false;for n in 20:other.sim.advance(0.1);other._refresh()
	check("has stopped" not in other.mission_hud.intent.text,"an idle craft says nothing")
	other.queue_free();await settle()
	# Rule 3 on: the same moment pauses the dive and names the reason; the status line keeps its words.
	TrialRules.reset()
	var paused_end=await make(Vector2i(2520,1080),1.0)
	var ps=paused_end.sim
	ps.paused=true;ps.command("select",{"unit":0});ps.command("route",{"point":ps.units[0].pos+Vector2(60,0)})
	ps.paused=false;paused_end._refresh()
	var guard_frames=0
	while not ps.units[0].route.is_empty() and guard_frames<400:
		ps.advance(0.1);guard_frames+=1;paused_end._refresh()
	check(ps.paused,"rule 3 on: the finished route paused the dive")
	# The same route at frame-sized steps: the craft brakes below MOVING_SPEED before its route empties, which 0.1 s
	# steps never sampled, so play showed no notice and no pause (13 Nov).
	var frame_end=await make(Vector2i(2520,1080),1.0)
	var fs=frame_end.sim
	fs.paused=true;fs.command("select",{"unit":0});fs.command("route",{"point":fs.units[0].pos+Vector2(300,0)})
	fs.paused=false;frame_end._refresh()
	var frame_steps=0
	while not fs.paused and frame_steps<3600:
		fs.advance(1.0/60.0);frame_steps+=1;frame_end._refresh()
	check(fs.paused and fs.units[0].route.is_empty() and "has stopped" in frame_end.mission_hud.intent.text,"rule 3 at frame-sized steps: a route that ends in a braking stop is noticed and pauses the dive ("+str(frame_steps)+" frames)")
	frame_end.queue_free();await settle()
	paused_end._refresh();await settle()
	check(end_line in paused_end.mission_hud.intent.text and "PAUSED: QUIETUS finished its route" in paused_end.mission_hud.intent.text,"the status line keeps its words and adds the reason: "+paused_end.mission_hud.intent.text)
	paused_end.queue_free();await settle()
	TrialRules.override("PAUSE_AT_ROUTE_END",false)
	# The route dialog holds time and is named as the reason.
	var dialog=await make(Vector2i(2520,1080),1.0)
	dialog.sim.paused=false;dialog._refresh()
	dialog.mission_hud.guard.pending={"unit":0,"point":dialog.sim.units[0].pos+Vector2(80,0)};dialog._refresh();dialog._refresh();await settle()
	# Running before the dialog: the dialog only holds time (CANCEL lets it run again), so the plate reads HELD.
	check(dialog.pause_button.text.begins_with(Words.TEXT.held) and Words.TEXT.held_route in dialog.mission_hud.intent.text,"a route dialog over a running dive shows HELD and why: "+dialog.pause_button.text+" / "+dialog.mission_hud.intent.text)
	dialog.sim.paused=true;dialog._refresh();dialog._refresh();await settle()
	check(dialog.pause_button.text.begins_with(Words.TEXT.paused) and "choose what to do with the route" in dialog.mission_hud.intent.text,"a route dialog over a paused dive shows PAUSED and why: "+dialog.pause_button.text+" / "+dialog.mission_hud.intent.text)
	dialog.queue_free();await settle()
