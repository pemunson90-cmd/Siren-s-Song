extends RefCounted
static func run(t,game) -> void:
 game._start_mission(0);game._layout();await t.process_frame
 t.check(not game.order_buttons.camera.is_visible_in_tree() and game.pause_button.is_visible_in_tree(),"water keeps explicit pause while contextual tools wait for craft tap")
 var before=game.sim.snapshot()
 game.mission_hud.open("craft");await t.process_frame
 t.check(game.order_buttons.camera.is_visible_in_tree() and game.sim.snapshot()==before,"craft command projection reveals camera without mutating paused mission")
 await t.click(game.mission_hud.extra.route_menu.get_global_rect().get_center())
 t.check(game.order_buttons.waypoint_mode.is_visible_in_tree() and game.order_buttons.home.is_visible_in_tree(),"route submenu exposes point mode and emergency recovery")
 await t.click(game.order_buttons.waypoint_mode.get_global_rect().get_center())
 t.check(not game.sim.pass_through and not game.advanced_orders,"actual STOP/PASS selection returns to water")
