extends SceneTree
# Ordinary production mission replay plus presentation-only chart controls.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var view="zoom"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--view="): view=arg.get_slice("=",1)
	var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="touch-evidence"; root.add_child(game)
	game._start_mission(3)
	game.sim=preload("res://tests/foundry_command_plan.gd").play(true,"cradle",true); game.ocean.sim=game.sim; game.sim.paused=true
	if view!="fit":
		game.ocean.zoom_at(2.2,game.ocean.screen_position(Vector2(1240,760)))
		game.ocean.pan_chart(Vector2(-35,-45))
	game._refresh()
	print("TOUCH EVIDENCE view=",view," zoom=",game.ocean.chart_camera.zoom," center=",game.ocean.chart_camera.center," time=",game.sim.elapsed," hull=",game.sim.hull)
