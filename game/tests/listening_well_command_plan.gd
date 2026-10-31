extends RefCounted
const HandLegs=preload("res://tests/hand_legs.gd") # 127: journeys place their own straight legs.
const Simulation=preload("res://src/simulation/simulation.gd")
# Ordinary finite commands, no target knowledge beyond authored chart/objectives
# and observed contacts. Retains conservative silent and exposed-leg cruise variants.
static func travel(s,point: Vector2) -> bool:
	s.command("select",{"unit":0})
	if not HandLegs.route(s,point): return false
	s.paused=false
	var last_pulse=-1.0
	for n in 2600:
		s.advance(0.1)
		for contact in s.contacts.values():
			if contact.lock>1 and contact.time>last_pulse and s.elapsed-contact.time<0.3 and s.tools.emp>0:
				s.command("emp"); last_pulse=s.elapsed; break
		if not s.outcome.is_empty(): return s.outcome=="won"
		if s.units[0].pos.distance_to(point)<20 and s.units[0].vel.length()<2: return true
		if s.units[0].route.is_empty() and s.units[0].vel.length()<2: return false
	return false
static func play(diversion: bool=true,cruise: bool=false,existing=null):
	var s=Simulation.new() if existing==null else existing
	if existing==null:
		s.start(4,"disruption"); s.units[1].alive=false; s.units[2].alive=false
	for id in 3:
		var point=[Vector2(800,390),Vector2(1150,450),Vector2(780,850)][id]
		# Actual clear-water160m deployment; no remote API-only lure.
		if id==1 and diversion and not s.command("decoy"): return s
		if id==1 and cruise: s.command("silent")
		if not travel(s,point): return s
		if id==1 and cruise: s.command("silent")
		if not s.command("camera"): return s
		for n in 80: s.advance(0.1)
		if not s.mission.objectives[id].captured: return s
	travel(s,s.mission.extraction)
	return s
