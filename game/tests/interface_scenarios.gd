extends RefCounted
static func run(t,game) -> void:
	t.check(game.has_method("_toggle_advanced"),"primary orders have an explicit secondary-orders disclosure")
	if not game.has_method("_toggle_advanced"): return
	game._start_mission(0); game._layout(); await t.process_frame
	t.check(game.order_buttons.home.is_visible_in_tree() and game.order_buttons.camera.is_visible_in_tree() and not game.order_buttons.contact_hold.is_visible_in_tree(),"camera and emergency remain primary while advanced conditions start tucked away")
	var before=game.sim.snapshot()
	await t.click(game.advanced_button.get_global_rect().get_center())
	t.check(game.order_buttons.contact_hold.is_visible_in_tree() and game.order_buttons.waypoint_mode.is_visible_in_tree() and game.sim.snapshot()==before,"opening advanced orders reveals controls without mutating paused mission")
	await t.click(game.order_buttons.waypoint_mode.get_global_rect().get_center())
	t.check(not game.sim.pass_through,"STOP/PASS remains accessible through actual secondary control input")
	await t.click(game.advanced_button.get_global_rect().get_center())
	t.check(not game.order_buttons.contact_hold.is_visible_in_tree() and game.order_buttons.home.is_visible_in_tree(),"closing secondary orders preserves immediate emergency access")
