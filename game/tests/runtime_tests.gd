extends SceneTree
var failures:=0
var checks:=0
var game
func check(value: bool,label: String) -> void:
	checks+=1
	if not value: failures+=1; printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func click(p: Vector2) -> void:
	var down=InputEventMouseButton.new(); down.position=p; down.global_position=p; down.button_index=MOUSE_BUTTON_LEFT; down.button_mask=MOUSE_BUTTON_MASK_LEFT; down.pressed=true
	var motion=InputEventMouseMotion.new(); motion.position=p; motion.global_position=p; root.push_input(motion,true)
	root.push_input(down,true); await process_frame
	var up=InputEventMouseButton.new(); up.position=p; up.global_position=p; up.button_index=MOUSE_BUTTON_LEFT; up.pressed=false
	root.push_input(up,true); await process_frame
func select_craft(index:int) -> void:
	if game.advanced_orders:game.mission_hud.dismiss()
	await click(game.advanced_button.get_global_rect().get_center());await process_frame
	await click(game.unit_buttons[index].get_global_rect().get_center());await process_frame
	await click(game.mission_hud.close_button.get_global_rect().get_center());await process_frame
func run() -> void:
	# A headless DisplayServer starts at 64x64. Declare the physical input fixture
	# before creating density-sized controls, as later resize cases already do.
	root.size=Vector2i(1280,720); await process_frame; await process_frame
	var metrics=preload("res://src/presentation/layout_metrics.gd")
	var safe=metrics.content_rect(Vector2(1680,720),Vector2(2520,1080),Rect2(136,0,2384,1080))
	check(absf(safe.position.x-90.6667)<0.01 and absf(safe.end.x-1680)<0.01,"native display cutout maps to correct logical inset")
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="runtime-test"; root.add_child(game)
	await process_frame; await process_frame
	game._show_campaign(); await process_frame
	var pressed_mission
	for child in game.panel_box.find_children("*","Button",true,false):
		if child is Button and child.get_meta("action","")=="mission0": pressed_mission=child
	pressed_mission.pressed.emit()
	check(pressed_mission.is_inside_tree(),"menu selection keeps dispatching control inside the tree until input delivery completes")
	await process_frame; await process_frame
	game._start_mission(0); await process_frame
	print("UI root=",root.size," game=",game.size," drone=",game.unit_buttons[1].get_global_rect())
	await select_craft(1)
	check(game.sim.selected==1,"actual pointer input selects independent drone")
	var destination=Vector2(320,800)
	var screen_point=game.ocean.global_position+game.ocean.world_offset+destination*game.ocean.world_scale
	await click(screen_point)
	check(not game.sim.units[1].route.is_empty(),"actual map tap issues route to selected drone")
	await select_craft(0)
	check(game.sim.selected==0 and not game.sim.queue_mode,"actual sub selection clears queue mode")
	await click(game.pause_button.get_global_rect().get_center())
	check(not game.sim.paused,"actual pause button starts simulation")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	var before=game.sim.snapshot(); await process_frame
	check(game.sim.paused and before==game.sim.snapshot(),"application suspend freezes active mission")
	game.sim.units[1].pos=Vector2(1300,510); game.sim.command("select",{"unit":1}); game.sim.command("camera"); await process_frame
	check(game.ocean.optical_feed.visible,"optical inset belongs to the currently operated camera station")
	await select_craft(0); await process_frame
	check(not game.ocean.optical_feed.visible and game.sim.capture_unit==1,"switch to submarine clears camera overlay while exposure continues")
	game._start_mission(0); game.sim.command("route",{"point":Vector2(360,800)}); game._show_campaign(); await process_frame
	var has_resume=false
	for child in game.panel_box.find_children("*","Button",true,false):
		if child.get_meta("action","")=="resume" and not child.disabled and child.text.begins_with("RESUME DIVE"): has_resume=true
	check(has_resume,"a paused zero-time plan remains resumable from operations")
	var planned=game.sim.snapshot(); game._briefing(1); await process_frame; game._show_campaign(); await process_frame
	check(game.sim.snapshot()==planned,"browsing another briefing then back preserves active mission and orders")
	game.screen="mission"; game.menu.hide(); game.hud.show()
	for dimensions in [Vector2i(1280,720),Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,540)]:
		root.size=dimensions; await process_frame; await process_frame
		game._layout()
		var all=game.mission_hud.action_controls().values()
		for button in all:
			var rect=button.get_global_rect()
			check(Rect2(Vector2.ZERO,game.size).encloses(rect),"%s button %s remains inside viewport"%[dimensions,button.text])
			check(button.size.y>=44,"%s button %s has logical touch height"%[dimensions,button.text])
		check(game.mission_hud.blocks(game.pause_button.get_global_rect().get_center()),"%s persistent pause owns input above full-bleed water"%dimensions)
	await preload("res://tests/observed_contact_ui_scenarios.gd").run(self,game)
	await preload("res://tests/acoustic_ui_scenarios.gd").run(self,game)
	await preload("res://tests/touch_navigation_scenarios.gd").run(self,game)
	await preload("res://tests/interface_scenarios.gd").run(self,game)
	await preload("res://tests/finale_ui_scenarios.gd").run(self,game)
	await preload("res://tests/blackwater_ui_scenarios.gd").run(self,game)
	await preload("res://tests/campaign_ui_scenarios.gd").run(self,game)
	# The recovery command emits this own-craft event; production audio must route it.
	game.sound.resume(); game.sound.muted=false; game.sim.paused=false
	for voice in game.sound.voices:voice.stop()
	game.sim.events=[{"type":"salvage","pos":game.sim.units[0].pos}]
	game.sound.update(game.sim,0.0,true)
	check(game.sound.voices.any(func(voice):return voice.playing and voice.stream==game.sound.cues.get("salvage")),"own recovery-winch event reaches an actual production audio voice")
	var winch_voice=game.sound.voices.filter(func(voice):return voice.stream==game.sound.cues.get("salvage"))[0]
	game.sim.paused=true;game.sound.update(game.sim,0.0,true)
	check(winch_voice.stream_paused,"tactical planning freezes the actual recovery-winch voice")
	game.sim.paused=false;game.sound.update(game.sim,0.0,true)
	check(winch_voice.playing and not winch_voice.stream_paused,"leaving tactical pause resumes that same recovery-winch voice")
	for voice in game.sound.voices:voice.stop()
	game.sound.resume(); game.screen="debrief"; game.sim.paused=false; game.sound.lock_voice.play()
	game.sim.contacts[0]={"pos":game.sim.units[0].pos+Vector2(100,0),"time":game.sim.elapsed,"mode":"LOCKING","lock":1.2,"angle":0.0,"target":0}
	await process_frame
	check(game.sound.ambience.stream_paused and not game.sound.lock_voice.playing,"debrief does not continue dive ambience or repeat threat alarms")
	game.sound.muted=true; game.sound.update(game.sim,0.1,false)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("SirenAmbience")) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SirenEffects")),"mute silences both production buses rather than leaving a low-level signal")
	game.sound.suspend(); game.sim.paused=false; game.sound.update(game.sim,0.1,true)
	check(game.sound.engine.stream_paused and game.sound.ambience.stream_paused,"system suspension freezes propulsion and ambience even before simulation notification")
	game.recovered_evidence.clear(); game._start_mission(3); game._evidence_gallery(0); await process_frame
	check(game.screen=="menu" and game.recovered_evidence.is_empty(),"optical archive does not expose undiscovered factory records")
	game.sim.mission.objectives[0].captured=true; game._retain_evidence()
	game._evidence_gallery(0); await process_frame
	var photos=[]
	for child in game.panel_box.get_children():
		if child is TextureRect: photos.append(child.texture.resource_path)
	check(game.screen=="evidence" and photos==["res://assets/evidence/foundry_furnace.png"],"recovered furnace gallery displays its own earned image")
	game.sim.mission.objectives[1].captured=true; game._retain_evidence(); game._start_mission(4)
	game._evidence_gallery(1); await process_frame
	photos.clear()
	for child in game.panel_box.get_children():
		if child is TextureRect: photos.append(child.texture.resource_path)
	check(photos==["res://assets/evidence/foundry_cradle.png"] and game.store.valid(game._archive()),"distinct departure evidence persists across dives in a valid campaign archive")
	await preload("res://tests/save_feedback_scenarios.gd").run(self)
	game.queue_free(); await process_frame
	await create_timer(0.5).timeout
	preload("res://tests/operation_catalog_scenarios.gd").run(self)
	preload("res://tests/depth_sonar_scenarios.gd").run(self)
	preload("res://tests/sweeper_scenarios.gd").run(self)
	preload("res://tests/opening_depth_scenarios.gd").run(self)
	print("RUNTIME CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
