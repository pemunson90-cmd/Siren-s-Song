extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	for mission in 6:
		var s=Simulation.new(); s.start(mission); s.paused=false
		for siren in s.sirens:
			var points=siren.get("patrol_points",[])
			t.check(points.size()>=3,"mission %d has an authored legible circulation route"%mission)
			for point in points:
				t.check(not s.blocked(point,24) and (siren.pos.distance_to(point)<35 or not s.path(siren.pos,point).is_empty()),"authored patrol waypoint has physical clearance and reachable terrain")
		var travel=[]; var last=[]
		for siren in s.sirens: travel.append(0.0); last.append(siren.pos)
		for n in 350:
			s.advance(0.1)
			for id in s.sirens.size():
				travel[id]+=last[id].distance_to(s.sirens[id].pos); last[id]=s.sirens[id].pos
		for id in s.sirens.size():
			if s.sirens[id].get("type","patroller")=="patroller":
				t.check(travel[id]>75,"mission %d patroller %d circulates without player noise"%[mission,id])
			else:
				t.check(travel[id]<1 and s.sirens[id].pos.distance_to(s.sirens[id].home)<1,"mission %d station role %d deliberately guards its home without a stimulus"%[mission,id])
			var siren=s.sirens[id]
			t.check(siren.pos.distance_to(siren.goal)<35 or (not s.blocked(siren.goal,24) and not s.path(siren.pos,siren.goal).is_empty()),"mission %d Siren %d has an arrived or reachable patrol destination"%[mission,id])
	var heard=Simulation.new(); heard.start(0)
	# A legal hull can emit beside cover where a larger navigation margin rejects the exact noise point.
	heard.units[0].pos=Vector2(905,300); heard.command("ping"); heard.paused=false; heard.advance(0.1)
	var hunter=heard.sirens[0]
	t.check(hunter.mode=="INVESTIGATE" and hunter.goal.distance_to(Vector2(905,300))<100,"unreachable heard point projects to its nearby search area instead of forgetting the stimulus")
	t.check(not hunter.route.is_empty() and not heard.blocked(hunter.route.back().pos,24),"investigation beside cover has a real navigable approach")

	var recovery=Simulation.new(); recovery.start(2); recovery.sirens.clear()
	recovery.units[0].pos=Vector2(1351.367,643.4868); recovery.units[0].angle=2.9
	t.check(not recovery.blocked(recovery.units[0].pos,12) and recovery.blocked(recovery.units[0].pos,24),"retained stranded position is physically legal but inside autopilot comfort margin")
	t.check(recovery.command("emergency",{"point":Vector2(1430,500)}),"emergency can recover a legal hull stranded near a basalt corner")
	recovery.paused=false; var safe=true
	for n in 120:
		recovery.advance(0.1)
		if recovery.blocked(recovery.units[0].pos,12): safe=false
	t.check(safe and recovery.units[0].pos.distance_to(Vector2(1430,500))<20,"near-wall recovery moves continuously through safe water to open clearance")
	t.check(not recovery.command("route",{"point":Vector2(1260,740)}),"recovery does not make a destination inside basalt legal")

	var malformed=recovery.snapshot(); malformed.sirens=Simulation.Missions.make(0).sirens
	malformed.sirens[0].patrol_points="invalid"
	t.check(not Simulation.valid_snapshot(malformed),"malformed authored patrol metadata cannot enter an active restored mission")
