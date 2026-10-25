extends "res://tests/endings_photo_ui_tests.gd"
# UI checks stop at the real operation 31 recovery boundary. They do not model
# ordinary play through the campaign or replace its physical recovery rules.
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Store=preload("res://src/persistence/save_store.gd")
const FinaleTablePath="res://src/presentation/finale/finale_table.gd"
func has_text(node,text):
	if node==null:return false
	for label in node.find_children("*","Label",true,false):
		if label.text==text:return true
	return false
func all_text(node):
	var out=""
	if node==null:return out
	for label in node.find_children("*","Label",true,false):out+=label.text+"\n"
	return out
func value_if_present(node,key,otherwise=null):
	for property in node.get_property_list():
		if property.name==key:return node.get(key)
	return otherwise
func clean(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func target_visible(node,id,host,label):
	var b=button(node,id)
	check(b!=null,label+" control exists")
	if b==null:return
	var rect=b.get_global_rect();var viewport=host.get_viewport_rect()
	check(rect.size.y>=host.ui_touch_height-1.0 and rect.position.y>=0 and rect.end.y<=viewport.size.y,label+" meets touch height and stays inside viewport")
func reveal(node,id):
	var b=button(node,id)
	if b==null:return
	var parent=b.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(b);await settle()
func capture(stage,shape):
	var capture_dir=OS.get_environment("SIRENS_042_CAPTURE_DIR")
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
	if not DirAccess.dir_exists_absolute(capture_dir):
		check(DirAccess.make_dir_recursive_absolute(capture_dir)==OK,"native capture directory exists: "+capture_dir)
	await RenderingServer.frame_post_draw
	var path=capture_dir+"/finale-%s-%dx%d.png"%[stage,shape.x,shape.y]
	check(root.get_texture().get_image().save_png(path)==OK,"native rendered state captured at "+path)
func expedition_fixture()->Dictionary:
	var completed=[6,7,9,11,12]
	for id in range(14,30):completed.append(id)
	completed.append(30)
	return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed","glass_choice":"salvage","choir_choice":"bypass","choir_people":"landed","choir_plant":"reconnect"},"completed":completed,"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func fixture_last_recovery(game)->bool:
	game._start_mission(31)
	var sim=game.sim;var objective=sim.mission.objectives[0]
	sim.units[0].band=objective.band
	sim.units[0].pos=objective.pos+Vector2(-120,0);sim.units[0].vel=Vector2.ZERO;sim.units[0].angle=0.0
	var framed=sim.command("frame",{"mode":"tight","focus":objective.optical})
	var exposed=sim.command("camera")
	sim.paused=false
	for n in 360:sim.advance(1.0/60.0)
	check(framed and exposed and objective.captured,"fixture uses ordinary operation 31 core framing and camera exposure")
	sim.units[0].pos=sim.mission.extraction;sim.units[0].vel=Vector2.ZERO
	for n in 60:sim.advance(1.0/60.0)
	var won=sim.outcome=="won" and sim.mission.recovered
	check(won,"fixture reaches operation 31 through physical recovery")
	return won
func debrief_last(game)->void:
	if fixture_last_recovery(game):game._debrief()
	else:check(false,"operation 31 debrief fixture reaches its authored boundary")
func wall_case(game,heading,label):
	check(game.screen=="photo_ending",label+" presents the existing photo wall")
	var plates=game.panel_box.get_children().filter(func(c):return c is ArchiveView.Plate)
	check(plates.size()==4,label+" retains the four existing archive plates")
	check(has_text(game,"END OF LINE")==heading,label+" has expected End of Line heading state")
	target_visible(game,"back",game,label+" Operations footer")
func shape_case(shape):
	root.size=shape;await settle()
	var stem="user://finale-provisional-%dx%d"%[shape.x,shape.y]
	var archive=stem+".save";var settings=stem+"-settings.json"
	clean(archive);clean(settings)
	var game=load("res://scenes/main.tscn").instantiate()
	if shape.x!=960:game.set_script(load("res://tests/density_main.gd"))
	game.capture_scenario="runtime-test";game.store.path=archive;game.settings_path=settings
	root.add_child(game);await settle();game.set_process(false)
	game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition=expedition_fixture()
	check(Campaign.valid(game.expedition),"fixture is a valid deep expedition completed through operation 30")
	game.recovered_evidence=archive_fixture();game.active_started=false
	game._show_campaign();game.capture_scenario=""
	debrief_last(game);await settle()
	wall_case(game,true,"first successful operation 31 recovery")
	check(game.expedition.completed.count(31)==1,"the first successful recovery records operation 31 once")
	check(value_if_present(game,"end_of_line_seen")==true,"first recovery records End of Line as seen")
	check(button(game,"finale_credits")!=null,"first wall offers existing Frontend credits")
	var payload=game._archive()
	check(Store.new().valid(payload),"first wall archive remains valid with optional finale state")
	var store=Store.new();store.path=archive
	check(store.save(payload) and store.load_game()==payload,"first wall and finale state survive checksummed archive save")
	target_visible(game,"finale_credits",game,"wall Credits")
	await capture("first-finale",shape)
	var raw_wall=all_text(game)
	for raw_fact in ["GLASS CHOICE /","CHOIR CHOICE /","CHOIR PEOPLE /","CHOIR PLANT /"]:
		check(not raw_wall.contains(raw_fact),"wall displays the fact mapping instead of raw label "+raw_fact)
	var finale=load("res://src/presentation/finale/finale.gd")
	var placeholders=finale.lines(game.expedition.facts)
	check(placeholders.size()==2,"finale adds exactly two provisional recorded-fact lines")
	for line in placeholders:check(has_text(game,line),"recorded placeholder is visible: "+line)
	if await press(game,"finale_credits"):
		var front=game.get_node_or_null("Frontend")
		check(front!=null and front.screen=="credits","wall credits opens the existing Frontend credits screen")
		check(game.screen=="menu","credits returns to the Operations host context")
		if front!=null:
			target_visible(front,"frontend_back",game,"existing Frontend credits Back")
			await capture("existing-credits",shape)
			if await press(front,"frontend_back"):
				check(game.screen=="menu" and game.get_node_or_null("Frontend")==null,"Frontend credits Back returns to unobscured Operations")
	else:check(false,"touch opens existing credits from the finale wall")
	# A true marker survives a real boot. The completed pair must not auto-open,
	# while Operations keeps its manual replay control.
	var seen_payload=store.load_game()
	check(seen_payload.get("end_of_line_seen")==true,"saved archive contains an explicit seen=true marker")
	var seen_reload=load("res://scenes/main.tscn").instantiate()
	if shape.x!=960:seen_reload.set_script(load("res://tests/density_main.gd"))
	seen_reload.store.path=archive;seen_reload.settings_path=settings;seen_reload.capture_scenario=""
	root.add_child(seen_reload);await settle();seen_reload.set_process(false)
	check(seen_reload.screen=="menu" and seen_reload.get_node_or_null("Frontend")!=null,"explicit-true reload follows normal title/menu boot")
	check(not has_text(seen_reload,"END OF LINE") and seen_reload.screen!="photo_ending","explicit-true reload does not auto-open End of Line")
	var seen_front=seen_reload.get_node_or_null("Frontend")
	if seen_front!=null:await press(seen_front,"frontend_continue")
	check(button(seen_reload,"end_of_line")!=null,"explicit-true reload retains manual Operations replay")
	seen_reload.queue_free();await settle()
	await reveal(game,"end_of_line")
	target_visible(game,"end_of_line",game,"Operations End of Line replay")
	await capture("ops-replay",shape)
	if await press(game,"end_of_line"):
		wall_case(game,true,"Operations replay after credits")
		if await press(game,"back"):check(game.screen=="menu","wall Back after Ops replay returns to Operations")
	else:check(false,"Operations can replay End of Line after credits")
	if await press(game,"end_of_line"):
		if await press(game,"back"):check(game.screen=="menu","photo wall Back returns to Operations")
	# Replay the recovered operation after the once-only automatic intro.
	debrief_last(game);await settle()
	wall_case(game,false,"operation 31 replay")
	if await press(game,"back"):check(game.screen=="menu","replay wall Back returns to Operations")
	# Old complete-pair saves without the optional field must still get a manual replay.
	var old=store.load_game();old.erase("end_of_line_seen")
	check(store.save(old),"legacy complete-pair fixture omits only the optional seen field")
	var loaded=load("res://scenes/main.tscn").instantiate()
	if shape.x!=960:loaded.set_script(load("res://tests/density_main.gd"))
	loaded.store.path=archive;loaded.settings_path=settings;loaded.capture_scenario=""
	root.add_child(loaded);await settle();loaded.set_process(false)
	check(loaded.screen=="menu" and loaded.get_node_or_null("Frontend")!=null,"loading a complete-pair save stays in the normal menu flow")
	check(not has_text(loaded,"END OF LINE") and loaded.screen!="photo_ending","loading a legacy pair never auto-opens the intro")
	var loaded_front=loaded.get_node_or_null("Frontend")
	if loaded_front!=null:await press(loaded_front,"frontend_continue")
	check(button(loaded,"end_of_line")!=null,"seen or legacy-complete Operations offers manual End of Line replay")
	if await press(loaded,"end_of_line"):
		wall_case(loaded,true,"manual Operations End of Line replay")
		if await press(loaded,"back"):check(loaded.screen=="menu","manual finale wall Back returns to Operations")
	else:check(false,"touch reopens End of Line from Operations")
	# The final-pair switch restores the old wall and hides only the new entry.
	if ResourceLoader.exists(FinaleTablePath):
		var table=load(FinaleTablePath);var enabled=table.enabled
		table.enabled=false
		loaded._show_ending();await settle()
		check(loaded.screen=="photo_ending" and not has_text(loaded,"END OF LINE"),"disabling the finale table restores the original wall")
		check(button(loaded,"finale_credits")==null,"disabling the finale table removes its Credits action")
		var seen=value_if_present(loaded,"end_of_line_seen")
		loaded._show_campaign();await settle()
		check(button(loaded,"end_of_line")==null,"disabling the finale table hides its Operations replay action")
		check(value_if_present(loaded,"end_of_line_seen")==seen,"disabling presentation preserves the recorded seen flag")
		table.enabled=enabled
	loaded.queue_free();game.queue_free();await settle();clean(archive);clean(settings)
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:await shape_case(shape)
	print("FINALE UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
