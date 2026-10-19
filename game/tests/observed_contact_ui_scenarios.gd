extends RefCounted
static func entries(game) -> Array:
	return game.ocean.contact_entries() if game.ocean.has_method("contact_entries") else []
static func rects(game) -> Array:
	return game.ocean.contact_readout_rects() if game.ocean.has_method("contact_readout_rects") else []
static func run(t,game) -> void:
	game._start_mission(4);game.sim.paused=true
	game.sim.contacts={1:{"pos":Vector2(800,700),"time":0.0,"mode":"INVESTIGATE","lock":0.0,"angle":0.0,"target":-1,"type":"hunter"}}
	var rows=entries(game)
	t.check(rows.size()==1 and rows[0].tag=="S2" and rows[0].text.begins_with("S2 HUNTER"),"actual chart consumes one shared observed identity for glyph and readout")
	game.sim.elapsed=3;rows=entries(game)
	t.check(rows.size()==1 and rows[0].text=="S2 HUNTER · LAST SEEN 3s","actual chart retains role/identity in an explicitly historical echo row")
	game.sim.contacts={1:{"pos":game.sim.mission.rocks[0].get_center(),"time":3.0,"mode":"LOCKING","lock":2.0,"angle":0.0,"target":0,"type":"hunter"}}
	t.check(not game.sim.line_clear(game.sim.contacts[1].pos,game.sim.units[0].pos),"beam-readout cover fixture has blocked current line of sight")
	t.check(not entries(game).any(func(r):return r.urgent),"readout preserves current cover guard before showing an urgent beam target")
	# Both native-sized physical layouts at their actual density scale, plus desktop.
	for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(1280,720)]:
		t.root.size=dimensions;await t.process_frame;await t.process_frame;game._layout()
		var view=game
		if dimensions.x>1280:
			view=load("res://scenes/main.tscn").instantiate();view.set_script(preload("res://tests/density_main.gd"));view.capture_scenario="observed-contact-density-fixture";t.root.add_child(view)
			view._start_mission(4);await t.process_frame;await t.process_frame;view._layout()

		view.sim.elapsed=3
		for id in 3:view.sim.contacts[id]={"pos":view.sim.units[0].pos+Vector2(30+id*40,20),"time":3.0 if id==2 else 0.0,"mode":"LOCKING" if id==2 else "PATROL","lock":2.0 if id==2 else 0.0,"angle":0.0,"target":0 if id==2 else -1,"type":["patroller","hunter","sentinel"][id]}
		view.sim.command("ping") # Four emission rows, the larger instrument case.
		rows=entries(view);var boxes=rects(view)
		t.check(rows.size()==3 and rows[0].tag=="S3" and "BEAM 2.0s" in rows[0].text,"%s actual chart keeps urgent observed beam first"%dimensions)
		t.check(boxes.size()==3,"%s actual chart provides three observation rows"%dimensions)
		for i in boxes.size():
			t.check(Rect2(Vector2.ZERO,view.ocean.size).encloses(boxes[i]),"%s observed readout stays inside chart"%dimensions)
			t.check(not boxes[i].intersects(Rect2(view.ocean.optical_feed.position,view.ocean.optical_feed.size)),"%s three observed rows stay above camera inset"%dimensions)
			for button in view.zoom_buttons:t.check(not boxes[i].intersects(button.get_rect()),"%s observed readout avoids zoom controls"%dimensions)
			if i>0:t.check(not boxes[i].intersects(boxes[i-1]),"%s observed rows do not overlap each other"%dimensions)
		if view!=game:
			view.queue_free();await t.process_frame
