extends SceneTree
# WP-11 (cold review 6, G6): Quietus life support is on screen during a dive,
# as the second line of the running pause control, while running and with a
# command ring open, on the Fold cover and inner shapes, normal and mirrored,
# at 100 and 150 percent text. The control keeps its size, so nothing else
# moves. The briefing names the operation's life-support limit as a fact line.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const CHIP_PATH="res://src/presentation/life_support_chip.gd"
var Chip
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func controls(game)->Array:
	var out=[]
	for b in game.mission_hud.action_controls().values():
		if b is Control and b.is_visible_in_tree():out.append(Rect2(b.global_position-game.mission_hud.global_position,b.size))
	return out
func run():
	Chip=load(CHIP_PATH) if ResourceLoader.exists(CHIP_PATH) else null
	check(Chip!=null,"the life support chip module exists")
	var saved=Settings.current.duplicate()
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for mirrored in [false,true]:
			for scale in [1.0,1.5]:
				Settings.current["mirrored_hud"]=mirrored;Settings.current["text_scale"]=scale
				await shape_case(shape,mirrored,scale)
	Settings.current=saved
	await briefing_case()
	print("LIFE SUPPORT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func shape_case(shape:Vector2i,mirrored:bool,scale:float):
	var stamp="%dx%d %s %d%%"%[shape.x,shape.y,"mirrored" if mirrored else "normal",roundi(scale*100)]
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp11-life-%d-%d.save"%[shape.x,Time.get_ticks_usec()]
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	Settings.current["mirrored_hud"]=mirrored;Settings.current["text_scale"]=scale
	game._start_mission(0);await settle();game._layout();await settle()
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	var s=game.sim;s.sirens=[]
	var hud=game.mission_hud;var pause:Button=game.pause_button
	# Paused: the control reads as before and gives the size to compare with.
	s.paused=true;game._refresh();await settle()
	# WP-36: the paused control reads "▶ RESUME" over the same life support reading (it was "PAUSED" over "▶ RESUME").
	var paused_lines=pause.text.split("
")
	# WP-48: the paused control names the state, then the tap, then the reading (two or three lines, the plate's size unchanged).
	check(paused_lines.size() in [2,3] and paused_lines[0]=="PAUSED" and "TAP TO RESUME" in pause.text and pause.text.find("O₂")>pause.text.find("TAP TO RESUME"),"the paused control states PAUSED, TAP TO RESUME and carries life support "+stamp+" "+str(paused_lines))
	check(pause.get_node_or_null(Chip.GAUGE)!=null and pause.get_node(Chip.GAUGE).visible and pause.get_node(Chip.GAUGE).mouse_filter==Control.MOUSE_FILTER_IGNORE,"a life support gauge lies inside the pause control and takes no tap "+stamp)
	check(Chip.gauge_color(.8)==preload("res://src/presentation/ui_style.gd").ACCENT and Chip.gauge_color(.4)==preload("res://src/presentation/ui_style.gd").WARNING and Chip.gauge_color(.2)==preload("res://src/presentation/ui_style.gd").DANGER_RED,"the gauge is accent, amber below 50 percent and red below 25 "+stamp)
	var paused_rect=pause.get_rect()
	# Running, unselected detail window elapsed: the old plate would be hidden here.
	s.paused=false
	for n in roundi(6.0/s.STEP):s.advance(s.STEP)
	game._refresh();await settle()
	var lines=pause.text.split("
")
	check(lines.size() in [2,3] and lines[0]=="RUNNING" and "TAP TO PAUSE" in pause.text and pause.text.find("O₂")>pause.text.find("TAP TO PAUSE"),"the running pause control states RUNNING, TAP TO PAUSE and carries life support "+stamp+" "+str(lines))
	if lines.size() not in [2,3]:game.queue_free();await settle();return
	var reading=pause.text.substr(pause.text.find("O₂"))
	check(pause.get_theme_font_size("font_size")>=10 and pause.get_theme_font("font").get_multiline_string_size(pause.text,HORIZONTAL_ALIGNMENT_LEFT,-1,pause.get_theme_font_size("font_size")).x<=pause.size.x,"both plate texts fit inside the plate "+stamp)
	check(pause.get_meta("ui_role","")=="QUIET","the running plate is a quiet outline while the paused plate is filled "+stamp)
	var left=int(s.oxygen/preload("res://src/simulation/operation_endurance.gd").oxygen_drain(s.mission,1.0))
	var clock="~%d:%02d"%[left/60,left%60];var percent="%d%%"%roundi(s.oxygen)
	check(reading in ["O₂ %s %s"%[percent,clock],"O₂ "+clock,"O₂ "+percent],"the reading is the live one: percent, time left at the base drain rate, or both %s: %s"%[stamp,reading])
	if shape.x==2520 and scale==1.0:check(clock in reading,"the cover screen at normal text shows the time left "+stamp)
	check(pause.get_rect()==paused_rect,"the pause control keeps its place and size "+stamp)
	check(Rect2(Vector2.ZERO,hud.size).encloses(pause.get_rect()),"the pause control lies inside the HUD area "+stamp)
	check(not Chip.rect(hud).has_area(),"the reading reserves no space of its own "+stamp)
	# WP-48: the running plate is a QUIET role plate, which carries its own role text colour; only amber is the warning.
	check(not pause.has_meta(Chip.META) and pause.get_theme_color("font_color")!=Chip.AMBER,"the reading has the ordinary colour above 25 percent "+stamp)
	var oxygen_text=pause.text
	s.oxygen=20.0;game._refresh();await settle()
	check("20%" in pause.text or "~" in pause.text,"the reading follows a falling value "+stamp)
	check(pause.text!=oxygen_text and pause.has_meta(Chip.META) and pause.get_theme_color("font_color")==Chip.AMBER,"the reading turns amber at 25 percent or below "+stamp)
	check(pause.get_rect()==paused_rect,"the pause control keeps its size when the reading changes "+stamp)
	s.oxygen=80.0;game._refresh();await settle()
	check(not pause.has_meta(Chip.META) and pause.get_theme_color("font_color")!=Chip.AMBER and pause.get_theme_color("font_color")==preload("res://src/presentation/ui_style.gd").QUIET_TEXT,"the amber state clears, and the plate's own role colour returns above 25 percent "+stamp)
	# A command ring open while running: the reading stays.
	hud.open("craft",{"kind":"craft","unit":0,"pos":s.units[0].pos});await settle();game._refresh();await settle()
	if not s.paused:check("O₂" in pause.text,"life support stays on screen with the command ring open "+stamp)
	else:check(pause.text.begins_with("PAUSED"),"a ring that pauses the dive shows the paused control "+stamp)
	check(not controls(game).any(func(r):return r!=pause.get_rect() and r.intersects(pause.get_rect())),"ring controls clear the pause control "+stamp)
	hud.dismiss();await settle()
	s.paused=true;game._refresh();await settle()
	check(pause.text.begins_with("PAUSED\n") and "O₂" in pause.text and not pause.has_meta(Chip.META),"pausing restores the paused text, with the reading, and no amber "+stamp)
	game.queue_free();await settle()
func briefing_case():
	root.size=Vector2i(2520,1080);await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp11-life-brief-%d.save"%Time.get_ticks_usec()
	root.add_child(game);await settle();game.set_process(false)
	game.upgrade="endurance";game._briefing(1);await settle()
	var found=""
	for c in game.panel_box.find_children("*","Label",true,false):
		if c.text.begins_with("Loadout:"):found=c.text
	var s=load("res://src/simulation/simulation.gd").new();s.start(1,"endurance")
	var seconds=int(s.oxygen/preload("res://src/simulation/operation_endurance.gd").oxygen_drain(s.mission,1.0))
	check(("LIFE SUPPORT %d:%02d"%[seconds/60,seconds%60]) in found,"the briefing states the operation's life-support limit %d s: %s"%[seconds,found])
	check(found.begins_with("Loadout:") and "O₂" in found,"the existing stock line is unchanged ahead of it")
	game.queue_free();await settle()
