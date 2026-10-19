extends RefCounted
# Synthetic archive/debrief fixtures, never earned campaign or native evidence.
static func apply(game,full:bool) -> void:
	game._start_mission(5);game.set_process(false);game.recovered_evidence={}
	var chapters=[2,3,4,5] if full else [5]
	for chapter in chapters:
		var mission=load("res://src/campaign/missions.gd").make(chapter)
		for objective in mission.objectives:
			if objective.has("optical"):game.recovered_evidence[objective.optical]={"name":objective.name,"caption":objective.evidence,"optical":objective.optical}
	if full:game.recovered_evidence.well_signature={"name":"QUIETUS / RETURNED CADENCE","caption":"SYNTHETIC ARCHIVE FIXTURE: prior-dive comparison retained; source and intent unresolved.","optical":"well_signature"}
	for objective in game.sim.mission.objectives:objective.captured=true
	game.sim.outcome="won"
