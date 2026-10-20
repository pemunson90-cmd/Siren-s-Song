extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(1)
	t.check(s.mission.objectives.size()==3,"Split Channel has two relay records and a distinct submarine uplink")
	if s.mission.objectives.size()<3: return
	var uplink=s.mission.objectives[2]
	s.units[1].pos=uplink.pos; s.command("select",{"unit":1})
	t.check(not s.command("camera"),"drone cannot perform submarine archive uplink")
	s.units[0].pos=uplink.pos; s.command("select",{"unit":0})
	t.check(not s.command("camera"),"uplink requires records from both separated relays")
	s.mission.objectives[0].captured=true; s.mission.objectives[1].captured=true
	t.check(s.command("camera"),"Quietus links the collected relay archive at the anchor")
	s.command("select",{"unit":2}); s.paused=false
	for n in 65: s.advance(0.1)
	t.check(uplink.captured and s.units[0].hold=="","uplink completes autonomously while pilot commands drone")
	t.check(not s.line_clear(Vector2(460,280),Vector2(1240,280)),"central spine physically separates relay sightlines")
	# Current authored region replaces the retired scalar-save compact fixture.
	var fleet=preload("res://tests/split_channel_command_plan.gd").play()
	t.check(fleet.outcome=="won" and fleet.all_records(),"current opposite-arm drone policy recovers all records and extracts")
	t.check(fleet.units.all(func(u):return u.alive),"current coordinated fleet returns with every craft alive")
	t.check(fleet.tools.emp>=0 and fleet.tools.emp<=3 and fleet.tools.decoy>=0 and fleet.tools.decoy<=3,"current coordinated policy respects finite defensive charges")
	print("SPLIT CURRENT outcome=",fleet.outcome," time=",snappedf(fleet.elapsed,0.1)," hull=",snappedf(fleet.hull,0.1)," tools=",fleet.tools)
