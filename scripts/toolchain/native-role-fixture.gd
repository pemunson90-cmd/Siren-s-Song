extends SceneTree
# Run with --path game --script /absolute/path/to/this.gd -- --output=/absolute/file.
# Focused debug archive entry; never a claim of earned campaign progression.
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
func _initialize():
	var output=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
	if not output.is_absolute_path():
		push_error("native-role-fixture requires absolute --output path"); quit(2); return
	var fresh=Simulation.new(); fresh.start(4,"endurance")
	var data={"version":1,"unlocked":4,"completed":[0,1,2,3],"upgrade":"endurance","settings":{"music":0.5,"effects":0.8,"mute":false},"evidence":{},"active":fresh.snapshot()}
	var store=SaveStore.new(); store.path=output
	if not store.save(data): push_error(store.warning); quit(1); return
	var loaded=store.load_game(); var restored=Simulation.new()
	if loaded!=data or not restored.restore(loaded.active) or restored.snapshot()!=fresh.snapshot():
		push_error("Canonical role fixture archive roundtrip differs from untouched fresh mission"); quit(1); return
	print("SS_NATIVE_FIXTURE mission=4 elapsed=0 paused=true progression=fixture-assisted completed=",data.completed," unlocked=4 fresh_snapshot_equal=true output=",output)
	quit()
