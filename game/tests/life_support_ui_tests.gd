extends SceneTree
# WP-11 (cold review 6, G6): Quietus life support is on screen during a dive,
# while running and with a command ring open, on the Fold cover and inner
# shapes, normal and mirrored, at 100 and 150 percent text. The briefing names
# the operation's life-support limit as a fact line.
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
func chip_label(game)->Label:
	for c in game.mission_hud.get_children():
		if c is Label and c.visible and c.text.begins_with("LIFE"):return c
	return null
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
	# Running, unselected detail window elapsed: the old plate would be hidden here.
	s.paused=false
	for n in roundi(6.0/s.STEP):s.advance(s.STEP)
	game._refresh();await settle()
	var hud=game.mission_hud;var area=Rect2(Vector2.ZERO,hud.size)
	var label=chip_label(game)
	check(label!=null,"life support is on screen while the dive runs "+stamp)
	if label==null:game.queue_free();await settle();return
	check(("%d%%"%roundi(s.oxygen)) in label.text and "~" in label.text,"the chip reads the live oxygen value and time left "+stamp+" "+label.text)
	check(area.encloses(label.get_rect()),"the chip lies inside the HUD area "+stamp)
	check(not label.get_rect().intersects(game.pause_button.get_rect()),"the chip clears the pause control "+stamp)
	check(not controls(game).any(func(r):return r.intersects(label.get_rect())),"the chip clears every visible control "+stamp)
	var pause_left=game.pause_button.get_rect().get_center().x<hud.size.x*.5
	check(pause_left!=mirrored and (label.get_rect().get_center().x<hud.size.x*.5)==pause_left,"the chip follows the pause side "+stamp)
	check(hud.threat_rects().has(label.get_rect()),"placed panels and chips are told to clear the chip "+stamp)
	var oxygen_text=label.text
	var left=int(s.oxygen/preload("res://src/simulation/operation_endurance.gd").oxygen_drain(s.mission,1.0))
	check(("~%d:%02d"%[left/60,left%60]) in label.text,"the clock is oxygen over the base drain rate %s: %s"%[stamp,label.text])
	s.oxygen=80.0;game._refresh();await settle()
	var calm:Color=label.get_theme_color("font_color")
	s.oxygen=20.0;game._refresh();await settle()
	check(label.visible and "20%" in label.text and label.text!=oxygen_text,"the chip follows a falling reading "+stamp)
	check(label.get_theme_color("font_color")!=calm,"the chip changes colour at 25 percent or below "+stamp)
	# A command ring open: the reading stays, and the ring clears it.
	s.oxygen=80.0
	hud.open("craft",{"kind":"craft","unit":0,"pos":s.units[0].pos});await settle()
	label=chip_label(game)
	check(label!=null and "80%" in label.text,"life support stays on screen with the command ring open "+stamp)
	if label!=null:
		check(not controls(game).any(func(r):return r.intersects(label.get_rect())),"ring controls clear the chip "+stamp)
		check(not hud.close_button.get_rect().intersects(label.get_rect()),"ring BACK clears the chip "+stamp)
		check(not (hud.alarm.visible and hud.alarm.get_rect().intersects(label.get_rect())),"the warning header clears the chip "+stamp)
	hud.dismiss();await settle()
	game.queue_free();await settle()
func briefing_case():
	root.size=Vector2i(2520,1080);await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path="user://wp11-life-brief-%d.save"%Time.get_ticks_usec()
	root.add_child(game);await settle();game.set_process(false)
	game.upgrade="endurance";game._briefing(0);await settle()
	var found=""
	for c in game.panel_box.find_children("*","Label",true,false):
		if c.text.begins_with("NEXT DIVE / RETRY"):found=c.text
	var s=load("res://src/simulation/simulation.gd").new();s.start(0,"endurance")
	var seconds=int(s.oxygen/preload("res://src/simulation/operation_endurance.gd").oxygen_drain(s.mission,1.0))
	check(("LIFE SUPPORT %d:%02d"%[seconds/60,seconds%60]) in found,"the briefing states the operation's life-support limit %d s: %s"%[seconds,found])
	check(found.begins_with("NEXT DIVE / RETRY") and "O₂ 120% · DISRUPT" in found,"the existing stock line is unchanged ahead of it")
	game.queue_free();await settle()
