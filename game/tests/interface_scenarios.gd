extends RefCounted
static func reveal(t,game,button):
 # Status wrapping and chart projection resolve on subsequent frames, including
 # radial layouts. Sample the pointer target after that geometry has settled.
 for n in 6:await t.process_frame
 if not game.mission_hud.order_dock.visible:return
 var scroll=game.mission_hud.order_dock_scroll
 scroll.ensure_control_visible(button)
 for n in 6:await t.process_frame
 t.check(scroll.get_global_rect().encloses(button.get_global_rect()),"scroll reveals the complete "+str(button.get_meta("action","command"))+" pointer target")
static func run(t,game) -> void:
 game._start_mission(0);game._layout();await t.process_frame
 t.check(not game.order_buttons.camera.is_visible_in_tree() and game.pause_button.is_visible_in_tree(),"water keeps explicit pause while contextual tools wait for craft tap")
 var before=game.sim.snapshot()
 game.mission_hud.open("craft");await t.process_frame
 t.check(game.order_buttons.camera.is_visible_in_tree() and game.sim.snapshot()==before,"craft command projection reveals camera without mutating paused mission")
 # Compact viewports use full-size scrollable commands. Reveal the actual
 # command before injecting its pointer tap, just as a player scrolls to it.
 await reveal(t,game,game.mission_hud.extra.route_menu)
 await t.click(game.mission_hud.extra.route_menu.get_global_rect().get_center())
 t.check(game.order_buttons.waypoint_mode.is_visible_in_tree() and game.order_buttons.home.is_visible_in_tree(),"route submenu exposes point mode and emergency recovery")
 await reveal(t,game,game.order_buttons.waypoint_mode)
 await t.click(game.order_buttons.waypoint_mode.get_global_rect().get_center())
 t.check(not game.sim.pass_through and not game.advanced_orders,"actual STOP/PASS selection returns to water")
