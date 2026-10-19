extends RefCounted
static func run(t,game):
	game.recovered_evidence.clear();game._start_mission(2);game._refresh()
	t.check(game.order_buttons.camera.text=="SAMPLE","fresh Blackwater labels its receiver action SAMPLE")
	game._briefing(2);await t.process_frame
	var copy=""
	for child in game.panel_box.get_children():
		if child is Label:copy+=child.text+"\n"
	t.check("SAMPLE" in copy and not "Use CAMERA within 240m" in copy,"Blackwater briefing explains local reception without generic optical range instructions")
	game._start_mission(2);game.sim.units[0].pos=Vector2(760,330);game.sim.command("camera");game._refresh();await t.process_frame
	t.check(game.ocean.optical_feed.visible,"receiving station owns the live hydrophone inset")
	t.check(game.unit_buttons[0].text.ends_with("\nSAMPLE"),"receiver station shows the short SAMPLE task matching its action")
	game.sim.command("select",{"unit":1});game._refresh();await t.process_frame
	t.check(not game.ocean.optical_feed.visible and game.sim.capture_unit==0,"handoff hides remote receiver feed while sample stays with Quietus")
	game.sim.command("select",{"unit":0});game.sim.paused=false
	for n in 123:game.sim.advance(1.0/60)
	game.sim.paused=true;game._retain_evidence()
	t.check(game.recovered_evidence.keys()==["blackwater_request"],"first record retains only its earned request plate")
	game._evidence_gallery(0);await t.process_frame
	var images=[];copy=""
	for child in game.panel_box.get_children():
		if child is TextureRect:images.append(child.texture.resource_path)
		if child is Label:copy+=child.text+"\n"
	t.check(images==["res://assets/evidence/blackwater_request.png"] and "FIELD HYDROPHONE RECORDS / 1 OF 1" in copy,"earned hydrophone field record uses its distinct plate without implying extraction")
	t.check(game.store.valid(game._archive()),"completed receiver progress and new record are valid in the existing campaign archive")
	game.sim.mission.objectives[1].captured=true;game._retain_evidence();game._evidence_gallery(1);await t.process_frame
	images.clear()
	for child in game.panel_box.get_children():
		if child is TextureRect:images.append(child.texture.resource_path)
	t.check(images==["res://assets/evidence/blackwater_reply.png"],"second retained record reveals the distinct ancient ocean reply")
	var old_path=game.store.path;game.store.path="res://tests/fixtures/accepted-blackwater.archive";game._load_archive();game._refresh();game.store.path=old_path
	t.check(game.order_buttons.camera.text=="CAMERA","legacy active Blackwater retains optical control wording")
