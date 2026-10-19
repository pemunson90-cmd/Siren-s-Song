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
	var direct=coordinated(false)
	var sheltered=coordinated(true)
	t.check(direct.outcome=="won" and direct.units[1].alive and direct.units[2].alive,"coordinated drone relay run returns archive and both drones survive")
	t.check(sheltered.outcome=="won" and sheltered.hull>direct.hull+10,"a planned decoy return preserves more hull than the direct route")
	for result in [direct,sheltered]: print("SPLIT ","DIRECT" if result==direct else "PLANNED RETURN"," outcome=",result.outcome," time=",snappedf(result.elapsed,0.1)," hull=",snappedf(result.hull,0.1)," EMP remaining=",result.tools.emp," DECOYS remaining=",result.tools.decoy)
static func coordinated(safe_return: bool,stop_at_return_seconds: float=-1.0):
	var s=Simulation.new(); s.start(1,"disruption")
	for id in [1,2,0]:
		s.command("select",{"unit":id})
		s.command("route",{"point":[Vector2(840,780),Vector2(420,490),Vector2(1220,490)][id]})
	s.paused=false
	var returning=false
	var return_started=0.0
	var drone_returned={1:false,2:false}
	for n in 1600:
		s.advance(0.1)
		for contact in s.contacts.values():
			if s.elapsed-contact.time>0.3 or contact.lock<1 or s.tools.emp<=0: continue
			var nearest=0; var distance=INF
			for id in 3:
				if s.units[id].alive and s.units[id].pos.distance_to(contact.pos)<distance: nearest=id; distance=s.units[id].pos.distance_to(contact.pos)
			s.command("select",{"unit":nearest}); s.command("emp"); break
		for drone in [1,2]:
			if s.mission.objectives[drone-1].captured and not drone_returned[drone] and s.units[drone].alive:
				s.command("select",{"unit":drone}); s.command("route",{"point":s.mission.extraction}); drone_returned[drone]=true
		if s.capture_unit<0 and not s.all_records():
			for objective_id in 3:
				var unit_id=[1,2,0][objective_id]; var o=s.mission.objectives[objective_id]
				if not o.captured and s.units[unit_id].alive and s.units[unit_id].pos.distance_to(o.pos)<230:
					s.command("select",{"unit":unit_id}); s.command("camera"); break
		if s.all_records() and not returning:
			s.command("select",{"unit":0})
			if safe_return:
				s.command("decoy"); s.command("route",{"point":s.mission.extraction})
			else: s.command("route",{"point":s.mission.extraction})
			returning=true; return_started=s.elapsed
		if returning and stop_at_return_seconds>=0 and s.elapsed-return_started>=stop_at_return_seconds: return s
		if not s.outcome.is_empty(): break
	return s
