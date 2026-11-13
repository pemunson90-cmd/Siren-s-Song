extends SceneTree
# WP-48: in-dive wording and state. The pause plate names the state first; the silent segment and its centre
# caption say what a tap does and costs, with every figure read from the simulation's own constants; a craft
# that runs out of route says so once without pausing the dive; a route dialog is named as the reason time is held.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
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
	await silent_case()
	await route_end_case()
	Settings.current=saved
	print("HUD WORDS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func plate_case(shape:Vector2i,scale:float):
	var stamp="%dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
	var game=await make(shape,scale)
	var pause:Button=game.pause_button
	for paused in [true,false]:
		game.sim.paused=paused;game._refresh();await settle()
		var lines=pause.text.split("\n")
		check(lines[0]==("PAUSED" if paused else "RUNNING"),"the plate names the state first "+stamp+" "+str(lines))
		check(("TAP TO RESUME" if paused else "TAP TO PAUSE") in pause.text and "O₂" in pause.text,"the plate names the tap and keeps the oxygen reading "+stamp+" "+str(lines))
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
		check(game.order_buttons.silent.text==("SILENT IS ON" if silent else "GO SILENT"),"the silent segment says what it is or does: "+game.order_buttons.silent.text)
		var caption="\n".join(Words.silent_caption(s))
		if silent:check(("tap for full speed (%d m/s) · seen from %d m"%[roundi(speed.cruise),roundi(sight.open)]) in caption,"silent on says what the tap gives back: "+caption)
		else:check(("slower (%d m/s) · seen from %d m"%[roundi(speed.silent),roundi(sight.silent)]) in caption,"silent off says its cost and its gain: "+caption)
	# A finger on the segment, or the last one touched, puts the caption in the wheel's centre.
	s.units[0].silent=false;hud.open("craft");await settle()
	hud.wheel_focus=game.order_buttons.silent;hud.queue_redraw();await settle()
	check(hud.caption_texts.any(func(t):return "slower (" in t),"the wheel centre carries the silent caption for the touched segment: "+str(hud.caption_texts))
	hud.wheel_focus=null;hud.queue_redraw();await settle()
	check(not hud.caption_texts.any(func(t):return "slower (" in t),"the caption leaves with the touch")
	# A drone keeps LOW PROFILE and says what it does.
	s.selected=1;s.units[1].silent=true;game._refresh();await settle()
	check(game.order_buttons.silent.text=="LOW\nPROFILE" and "180 m, not 290 m" in "\n".join(Words.silent_caption(s)),"a drone's LOW PROFILE says what it changes")
	# The sonar segments use the plain words.
	s.selected=0;game._refresh();hud.open("acoustics");await settle()
	check(hud.extra.sonar_emit.text.begins_with("PING SONAR\nuses ") and hud.extra.sonar_history.text=="PAST PINGS","the sonar segments say PING SONAR and PAST PINGS")
	check(hud.extra.sonar_sector.text=="PING ARC: ALL ROUND" and hud.extra.sonar_power.text=="PING POWER: LOW","the arc and power segments say what they set: "+hud.extra.sonar_sector.text+" / "+hud.extra.sonar_power.text)
	game.queue_free();await settle()
func route_end_case():
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
	# The route dialog holds time and is named as the reason.
	var dialog=await make(Vector2i(2520,1080),1.0)
	dialog.sim.paused=false;dialog._refresh()
	dialog.mission_hud.guard.pending={"unit":0,"point":dialog.sim.units[0].pos+Vector2(80,0)};dialog._refresh();dialog._refresh();await settle()
	check(dialog.pause_button.text.begins_with("PAUSED") and "choose what to do with the route" in dialog.mission_hud.intent.text,"a route dialog shows PAUSED and why: "+dialog.pause_button.text+" / "+dialog.mission_hud.intent.text)
	dialog.queue_free();await settle()
