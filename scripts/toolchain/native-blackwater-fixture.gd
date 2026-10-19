extends SceneTree
# Fixture-assisted chapter entry only. No earned campaign progression assertion.
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
func _initialize():
	var output="";var earned=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
		if arg.begins_with("--verify-earned="):earned=arg.trim_prefix("--verify-earned=")
	if (output.is_empty()==earned.is_empty()) or not (output if earned.is_empty() else earned).is_absolute_path():
		push_error("Specify one absolute --output or --verify-earned path");quit(2);return
	var store=SaveStore.new()
	if not earned.is_empty():
		# Inspect this exact downloaded primary, never accept a fallback .bak.
		var data=store._read(earned);var s=Simulation.new()
		if data.is_empty() or not data.has("active") or not s.restore(data.active):
			push_error("Earned primary archive invalid");quit(1);return
		var o=s.mission.objectives
		if s.mission.id!=2 or s.mission.get("blackwater_revision",0)!=1 or not s.paused or s.elapsed<=0 or s.capture_unit!=-1 or s.selected!=1 or not s.outcome.is_empty() or not s.units[1].alive or not o[0].captured or o[1].captured or data.completed!=[0,1] or data.unlocked!=2 or data.get("evidence",{}).keys()!=["blackwater_request"]:
			push_error("Expected paused ordinary request-only progress from fixture chapter entry");quit(1);return
		if data.evidence.blackwater_request!={"name":o[0].name,"caption":o[0].evidence,"optical":o[0].optical}:
			push_error("Earned request evidence differs from production objective");quit(1);return
		print("SS_NATIVE_BLACKWATER earned_request_verified=true mission=2 paused=true request=true reply=false evidence=blackwater_request time=",s.elapsed," hull=",s.hull)
		quit();return
	var fresh=Simulation.new();fresh.start(2,"endurance")
	var data={"version":1,"unlocked":2,"completed":[0,1],"upgrade":"endurance","settings":{"music":0.5,"effects":0.8,"mute":false},"evidence":{},"active":fresh.snapshot()}
	store.path=output
	if not store.save(data):push_error(store.warning);quit(1);return
	var loaded=store._read(output);var restored=Simulation.new()
	if loaded!=data or not restored.restore(loaded.active) or restored.snapshot()!=fresh.snapshot():
		push_error("Canonical Blackwater fixture differs from untouched fresh mission");quit(1);return
	print("SS_NATIVE_BLACKWATER mission=2 elapsed=0 paused=true progression=fixture-assisted completed=[0,1] unlocked=2 evidence=empty fresh_snapshot_equal=true")
	quit()
