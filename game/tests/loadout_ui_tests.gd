extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 5:await process_frame
func button(action):
	# Operations shortcuts now share a top row; retain every original assertion.
	for child in game.menu.find_children("*","Button",true,false):
		if child is Button and child.get_meta("action","")==action:return child
	return null
func click(control):
	if game.scroll.is_ancestor_of(control):game.scroll.ensure_control_visible(control)
	await settle()
	var p=control.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new();motion.position=p;motion.global_position=p;root.push_input(motion,true)
	for down in [true,false]:
		var e=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
	await settle()
func copy():
	var text=""
	for c in game.panel_box.find_children("*","Control",true,false):
		if c is Label or c is Button:text+=c.text+"\n"
	return text
func stock(s):return "O₂ %d%% · DISRUPT %d · SURVEY %d"%[s.oxygen,s.tools.emp,s.tools.recon]
# Explicit loading keeps this test about selected stock, launch and resume,
# while the default templates preserve winch room rather than granting tools.
func load_tools(host):
	var Tools=preload("res://src/equipment/field_tools.gd")
	host.tool_racks=preload("res://src/equipment/tool_racks.gd").empty()
	for id in Tools.ids():host.tool_racks.quietus[id]=Tools.loadout_count(id,host.upgrade)
func run():
	root.size=Vector2i(1280,720);await settle()
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="loadout-test";game.store.path="user://test-loadout-ui.save";root.add_child(game);await settle();game.set_process(false)
	game.upgrade="endurance";load_tools(game);game._start_mission(0)
	game.sim.command("emp");game.sim.command("recon");game.sim.command("route",{"point":Vector2(300,800)});game.sim.paused=true
	var active=game.sim.snapshot();game._show_campaign();await settle()
	await click(button("launch_details"))
	var starts={}
	for choice in ["endurance","disruption","survey"]:
		var s=load("res://src/simulation/simulation.gd").new();s.start(0,choice);starts[choice]=s
	for choice in ["endurance","disruption","survey"]:
		load_tools(game);game._show_campaign();await settle()
		if not game.get_meta("ops_home_details_open",false):await click(button("launch_details"))
		check(game.upgrade==choice,"genuine cycle input reaches "+choice)
		var text=copy();var expected=stock(starts[choice])
		check("NEXT DIVE / RETRY" in text and choice.to_upper() in text and expected in text,"selected "+choice+" starting stock is advertised before launch")
		for option in starts:
			var s=starts[option];var row="%s · %d%% / %d / %d"%[option.to_upper(),s.oxygen,s.tools.emp,s.tools.recon]
			check("O₂ / DISRUPT / SURVEY" in text and row in text,"comparison exposes actual "+option+" stock while "+choice+" selected")
		var ordinary=starts[choice];var drones=ordinary.units.slice(1).filter(func(u):return u.alive).size()
		check("FREE TOOLS:" in text and ("%d DECOYS"%ordinary.tools.decoy) in text and ("%d DRONES"%drones) in text,"common equipment matches actual start while "+choice+" selected")
		check(button("resume")!=null and button("resume").text.begins_with("RESUME DIVE") and game.sim.snapshot()==active,"selection explains active equipment preservation")
		check(game.sim.snapshot()==active,"cycling next-dive choice preserves spent resources and paused route")
		print("CHOICE ",choice," expected=",expected," active=",game.sim.tools," labels=",text)
		if choice!="survey":
			await click(button("loadout"))
	var effects=copy();var d=starts.disruption;d.sirens[0].pos=d.units[0].pos+Vector2(100,0);d.command("emp");var survey=starts.survey;survey.command("recon")
	check("12s" in effects and d.sirens[0].stun==12,"advertised disruption duration matches actual command effect")
	check("8s" in effects and "audible" in effects and survey.recon_time==8 and survey.noises.any(func(n):return n.label=="RECON UPLINK"),"advertised survey duration and emission match actual command")
	await click(button("resume"));check(game.screen=="mission" and game.sim.snapshot()==active,"genuine resume preserves the active dive's equipment and plan")
	game._show_campaign();game._briefing(0);await settle()
	var arc=game.get_node_or_null("ArcCard")
	if arc!=null:
		var next=arc.find_children("*","Button",true,false)[0]
		var point=next.get_global_rect().get_center()
		for down in [true,false]:
			var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
			var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
		await settle()
		check(game.get_node_or_null("ArcCard")==null,"real touch dismisses arc entry before launch stock checks")
	var fresh=load("res://src/simulation/simulation.gd").new();fresh.start(0,"survey")
	check("NEXT DIVE / RETRY" in copy() and "SURVEY" in copy() and stock(fresh) in copy(),"prelaunch briefing confirms the selected stock")
	await click(button("begin"))
	check(game.screen=="mission" and game.sim.oxygen==fresh.oxygen and game.sim.tools==fresh.tools,"genuine ENTER WATER starts selected survey equipment")
	check(game.sim.units.filter(func(u):return u.alive).size()==3,"new dive retains Quietus and two drones")
	for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		root.size=dimensions;await settle()
		var dense=load("res://scenes/main.tscn").instantiate();dense.set_script(load("res://tests/density_main.gd"));dense.capture_scenario="loadout-density";dense.store.path="user://test-loadout-density.save"
		if dimensions.x==2520:dense.fixture_safe_area=Rect2(136,0,2384,1080)
		root.add_child(dense);dense.set_process(false);await settle();dense.upgrade="survey";load_tools(dense);dense._start_mission(0);dense._show_campaign();await settle()
		var original_game=game;game=dense;await click(button("launch_details"));game=original_game
		dense.scroll.scroll_vertical=100000;await settle()
		var area=dense.scroll.get_global_rect();var selected=false;var comparison=false
		for c in dense.panel_box.find_children("*","Control",true,false):
			if c is Label and c.text.begins_with("NEXT DIVE / RETRY"):selected=area.encloses(c.get_global_rect())
			if c is Label and c.text.begins_with("COMPARE:"):comparison=area.encloses(c.get_global_rect())
			if c is Button and c.get_meta("action","") in ["loadout","settings"]:check(area.encloses(c.get_global_rect()),"%s scrolled selector keeps %s reachable"%[dimensions,c.get_meta("action")])
		check(selected,"%s selected next-dive stock fits with bottom selector"%dimensions)
		check(comparison,"%s all three comparison rows fit together"%dimensions)
		dense.queue_free();await settle()
	game.queue_free();await process_frame;await create_timer(0.5).timeout
	print("LOADOUT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
