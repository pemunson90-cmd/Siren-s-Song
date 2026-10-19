extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(3)
	t.check(not s.mission.get("structures",[]).is_empty(),"Cold Foundry has physical industrial mass in its approach")
	t.check(s.mission.extraction.distance_to(s.units[0].pos)>900,"far-side recovery gives Quietus a meaningful perimeter transit")
	t.check(s.mission.objectives[0].name=="FURNACE VENT" and s.mission.objectives[1].name=="DEPARTURE CRADLE","factory records describe two different observations")
	if s.mission.get("structures",[]).is_empty(): return
	t.check(not s.path(s.units[0].pos,Vector2(1090,570)).is_empty(),"assisted navigation reaches a clear vantage beside a factory wall")
	var building:Rect2=s.mission.structures[0]
	t.check(s.blocked(building.get_center()) and not s.line_clear(building.position-Vector2(30,-200),Vector2(building.end.x+30,building.position.y+200)),"factory movement and sight agree with its solid footprint")
	for siren in s.sirens: siren.stun=30.0
	# Isolate acquisition/response semantics; ordinary solvability is exercised separately.
	s.units[0].pos=s.mission.objectives[1].pos+Vector2(0,80)
	t.check(not s.command("camera"),"departure interpretation requires the furnace observation first")
	for id in 2:
		s.units[0].pos=s.mission.objectives[id].pos+Vector2(-160,0)
		t.check(s.command("camera"),"factory observation %d starts from a valid clear vantage"%id)
		s.paused=false
		for n in 45: s.advance(0.1)
		t.check(s.mission.objectives[id].captured and not s.mission.objectives[id].get("evidence","").is_empty(),"captured factory record retains the detail supporting its interpretation")
	t.check(s.mission.get("phase","")=="response" and s.noises.any(func(n): return n.label=="FACTORY RESPONSE"),"discovery creates a real explained acoustic return consequence")
	var restored=Simulation.new(); restored.restore(s.snapshot())
	t.check(restored.mission==s.mission and restored.paused,"factory response and recovered evidence survive paused restoration")

	var coordinated=preload("res://tests/foundry_command_plan.gd").play(true,"complete",true,"queued")
	t.check(coordinated.outcome=="won" and coordinated.units[1].alive and coordinated.units[2].alive,"queued covered withdrawal and finite tools recover both Foundry records without forced drone losses")
	print("FOUNDRY STAGED outcome=",coordinated.outcome," time=",snappedf(coordinated.elapsed,0.1)," hull=",snappedf(coordinated.hull,0.1)," tools=",coordinated.tools)
