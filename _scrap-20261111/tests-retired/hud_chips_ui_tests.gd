extends SceneTree
# WP-11 (cold review 6, I2): HUD chips stay inside the content area, clear the
# pause control, the lock card, the Expedition banner and each other, hold one
# seat between frames of the same layout, and ring centre text stays inside its
# disc. Cover and inner shapes, normal and mirrored HUD, 100 and 150 percent text.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const RunState=preload("res://src/campaign/runs/run_state.gd")
var checks=0
var failures=0
var lock_cases=0
var ring_cases=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func run():
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for mirrored in [false,true]:
			for scale in [1.0,1.5]:
				await campaign_case(shape,mirrored,scale)
				Settings.current=saved.duplicate()
				await ring_case(shape,mirrored,scale)
				Settings.current=saved.duplicate()
	for mirrored in [false,true]:
		await expedition_case(Vector2i(2184,1968),mirrored)
		Settings.current=saved.duplicate()
	Settings.current=saved
	check(lock_cases>0,"at least one case reached a lock card (%d did)"%lock_cases)
	check(ring_cases>0,"at least one case drew ring centre text (%d did)"%ring_cases)
	print("HUD CHIPS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func global_of(control:Control,rect:Rect2)->Rect2:
	return Rect2(control.global_position+rect.position,rect.size)
# Every chip that is on screen, as global rectangles keyed by name.
func chips(game)->Dictionary:
	var out={}
	var hud=game.mission_hud
	var hunt=hud.get_meta("hunt_meter_button") if hud.has_meta("hunt_meter_button") else null
	if is_instance_valid(hunt) and hunt.is_visible_in_tree():out["hunt"]=hunt.get_global_rect()
	var life=hud.get_meta("life_support_chip") if hud.has_meta("life_support_chip") else null
	if is_instance_valid(life) and life.is_visible_in_tree():out["life"]=life.get_global_rect()
	var cue=game.hud.get_node_or_null("FirstSirenCue")
	if cue!=null and cue.is_visible_in_tree():
		if not cue.frames.is_empty():out["notice"]=global_of(cue,cue.chip_rect)
		if not cue.note_frames.is_empty():out["new_type"]=global_of(cue,cue.note_rect)
	return out
func text_inside(cue,font)->bool:
	var ok=true
	if not cue.frames.is_empty():ok=ok and (font.get_string_size(cue.label_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,cue.font_size).x<=cue.chip_rect.size.x-minf(cue.chip_rect.size.y,cue.host.ui_touch_height*.9)-4 or cue.chip_rect.size.y>cue.host.ui_touch_height*.9+1)
	if not cue.note_frames.is_empty():ok=ok and (font.get_string_size(cue.note_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,cue.font_size).x<=cue.note_rect.size.x-8 or cue.note_rect.size.y>cue.host.ui_touch_height*.9+1)
	return ok
func layout_checks(game,stamp:String,banner:Rect2=Rect2()):
	var area=game.get_global_rect()
	var found=chips(game)
	var pause=game.pause_button.get_global_rect()
	var lock=Rect2()
	if game.lock_warning!=null and game.lock_warning.visible:lock=global_of(game.lock_warning,game.lock_warning.banner)
	for key in found:
		var r:Rect2=found[key]
		check(area.encloses(r),"%s chip lies inside the content area %s %s in %s"%[key,stamp,r,area])
		check(not r.intersects(pause),"%s chip clears the pause control %s"%[key,stamp])
		check(not (lock.has_area() and r.intersects(lock)),"%s chip clears the lock card %s %s lock %s"%[key,stamp,r,lock])
		check(not (banner.has_area() and r.intersects(banner)),"%s chip clears the Expedition banner %s"%[key,stamp])
		for other in found:
			if other>key:check(not r.intersects(found[other]),"%s and %s chips do not overlap %s"%[key,other,stamp])
	return found
func notice(game):
	var s=game.sim;s.paused=false
	var enemy=s.sirens[0];enemy.pos=s.units[0].pos+Vector2(120,0);enemy.home=enemy.pos;enemy.goal=enemy.pos;enemy.route=[];enemy.patrol_points=[];enemy.stun=0.;enemy.band=s.units[0].band;enemy.transition={};s.sirens=[enemy]
	s._threats(.1);game._refresh();await settle()
func campaign_case(shape:Vector2i,mirrored:bool,scale:float):
	var stamp="%dx%d %s %d%%"%[shape.x,shape.y,"mirrored" if mirrored else "normal",roundi(scale*100)]
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
	game.store.path="user://wp11-chips-%d.save"%Time.get_ticks_usec()
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	Settings.current["mirrored_hud"]=mirrored;Settings.current["text_scale"]=scale
	game._start_mission(0);await settle();game._layout();await settle()
	game.hints_seen=["move","pause","drone","noise","sweep","warning"];game.mission_hud.hints.dismiss()
	var s=game.sim
	if s.mission.has("reconnaissance"):s.mission.reconnaissance["hunt"]=35.0
	await notice(game)
	var cue=game.hud.get_node_or_null("FirstSirenCue")
	check(cue!=null and cue.is_visible_in_tree() and not cue.frames.is_empty() and not cue.note_frames.is_empty(),"setup: NOTICE and NEW SIREN TYPE chips are shown "+stamp)
	var found=layout_checks(game,stamp)
	check(found.has("hunt"),"setup: the Hunt chip is shown "+stamp+" "+str(found.keys()))
	if cue!=null:check(text_inside(cue,ThemeDB.fallback_font),"NOTICE and NEW SIREN TYPE text fit inside their chips "+stamp)
	# The same layout over several frames: drones move, the Hunt chip holds its seat.
	if found.has("hunt"):
		var seat:Vector2=found.hunt.position;var moved=0
		# A received lock: the lock card joins the stack and every chip clears it.
		for n in 120:
			for k in 3:s.advance(s.STEP)
			game._refresh();await process_frame
			if game.lock_warning!=null and game.lock_warning.visible:break
		await settle()
		if game.lock_warning!=null and game.lock_warning.visible:lock_cases+=1;layout_checks(game,stamp+" with lock card")
		else:print("NO LOCK ",stamp)
		s.sirens=[];s.hull=100.0;game._refresh();await settle();seat=chips(game).get("hunt",found.hunt).position
		for id in [1,2]:s.units[id].route=[{"pos":s.units[id].pos+Vector2(260,0).rotated(id*2.),"stop":true}]
		for n in 12:
			for k in 4:s.advance(s.STEP)
			game._refresh();await process_frame;await process_frame
			var now=chips(game)
			if now.has("hunt") and now.hunt.position.distance_to(seat)>.5:
				moved+=1;seat=now.hunt.position
		check(moved==0,"the Hunt chip holds one seat between frames of one layout "+stamp+" (moved %d times)"%moved)
		layout_checks(game,stamp+" after motion")
	game.queue_free();await settle()
# Ring centre text (desktop density, where the command ring is drawn): a long
# object name stays inside the ring's inner disc and clears every wedge.
func ring_case(shape:Vector2i,mirrored:bool,scale:float):
	var stamp="ring %dx%d %s %d%%"%[shape.x,shape.y,"mirrored" if mirrored else "normal",roundi(scale*100)]
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
	game.store.path="user://wp11-ring-%d.save"%Time.get_ticks_usec()
	root.add_child(game);await settle();game.set_process(false)
	Settings.current["mirrored_hud"]=mirrored;Settings.current["text_scale"]=scale
	game._start_mission(0);await settle();game._layout();await settle()
	var s=game.sim;s.paused=true
	var hud=game.mission_hud
	var site:Dictionary=s.mission.objectives[0]
	hud.open("object",{"kind":"objective","index":0,"name":"UNKNOWN SIGNAL SOURCE UNDER THE NORTHERN SEABED RETURN","pos":site.pos});await settle()
	hud.queue_redraw();await settle()
	var disc=Rect2(hud.center-Vector2.ONE*(hud.ring_radius-hud.touch_height*.7),Vector2.ONE*2*(hud.ring_radius-hud.touch_height*.7))
	if hud.has_meta("status_command_grid") or hud.order_dock.visible:
		print("RING ",stamp," uses the order dock; no ring centre text");hud.dismiss();await settle();game.queue_free();await settle();return
	ring_cases+=1
	check(not hud.caption_rects.is_empty(),"setup: ring centre text is drawn "+stamp)
	for r in hud.caption_rects:
		check(r.position.x>=disc.position.x-1 and r.end.x<=disc.end.x+1,"ring centre line stays inside the disc width "+stamp+" "+str(r)+" in "+str(disc))
		for b in hud.ring_buttons:
			if b.visible:check(not r.intersects(b.get_rect()),"ring centre line clears the %s wedge %s"%[b.get_meta("action",""),stamp])
	check(hud.caption_texts.size()>0 and hud.caption_texts.any(func(t):return t.begins_with("UNKNOWN")),"the long name is shown, wrapped or shortened "+stamp+" "+str(hud.caption_texts))
	hud.dismiss();await settle()
	game.queue_free();await settle()
func expedition_case(shape:Vector2i,mirrored:bool):
	var stamp="expedition %dx%d %s"%[shape.x,shape.y,"mirrored" if mirrored else "normal"]
	root.size=shape;await settle()
	var host=load("res://scenes/main.tscn").instantiate();host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path="user://wp11-chips-exp-%d.save"%Time.get_ticks_usec()
	root.add_child(host);await settle();host.set_process(false)
	Settings.current["mirrored_hud"]=mirrored
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd"))
	session.campaign_host=host;session.run_state=RunState.new_run(1270840417)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await settle()
	session.set_process(false)
	session._begin();await settle()
	check(session.screen=="mission","setup: the Expedition dive starts "+stamp+" screen="+str(session.screen))
	if session.screen!="mission":host.queue_free();await settle();return
	session._layout();await settle()
	if session.sim.mission.has("reconnaissance"):session.sim.mission.reconnaissance["hunt"]=35.0
	session._refresh();await settle();session._refresh();await settle()
	var banner:Rect2=session.status_label.get_global_rect() if session.status_label.visible else Rect2()
	check(banner.has_area() and session.get_global_rect().encloses(banner),"the Expedition banner is shown inside the content area "+stamp)
	check(not banner.intersects(session.pause_button.get_global_rect()) and not banner.intersects(session.advanced_button.get_global_rect()),"the banner clears the header controls "+stamp)
	var found=layout_checks(session,stamp,banner)
	check(found.has("hunt"),"setup: the Hunt chip is shown in the Expedition dive "+stamp)
	host.queue_free();await settle()
