extends RefCounted
static func run(t,game) -> void:
	var old_path=game.store.path
	var current=game.sim.snapshot()
	game.store.path="res://tests/fixtures/accepted-finale.archive"; game._load_archive(); game._refresh()
	t.check(game.sim.snapshot()==current and not game.store.warning.is_empty(),"incompatible finale save is rejected without replacing the current mission")
	game.store.path=old_path
	game._start_mission(5)
	game.sim=preload("res://tests/finale_command_plan.gd").play(true,"receiver"); game.ocean.sim=game.sim; game._refresh()
	t.check("LEE RECEIVER" in game.detail_label.text and "HYDROPHONES" not in game.order_buttons.camera.text and "LISTEN" in game.order_buttons.camera.text,"real passive exposure explains the operated receiver in player-facing controls")
	game.sim.paused=false
	for n in 35: game.sim.advance(0.1)
	game._retain_evidence()
	t.check(game.recovered_evidence.has("warning"),"earned warning enters actual operations evidence collection")
	var index=game.recovered_evidence.keys().find("warning")
	game._evidence_gallery(index); await t.process_frame
	var plot=false
	for child in game.panel_box.get_children():
		if child is TextureRect: plot=child.texture==preload("res://src/presentation/evidence_catalog.gd").IMAGES.warning
	t.check(plot,"actual recovered gallery displays the decoded warning rather than a foundry placeholder")
