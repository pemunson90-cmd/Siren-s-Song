extends SceneTree
# Replays the exact ordinary-command scenario, then presents its real paused snapshot.
# Run through capture.sh --script res://tests/capture_return.gd.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	game.capture_scenario="return-replay"; root.add_child(game)
	var state=preload("res://tests/split_channel_command_plan.gd").play()
	state.paused=true
	game.sim=state; game.ocean.sim=state; game.mission_index=1; game.screen="mission"; game.menu.hide(); game.hud.show()
	print("REPLAY RETURN time=",state.elapsed," hull=",state.hull," records=",state.all_records()," decoys=",state.tools.decoy)
