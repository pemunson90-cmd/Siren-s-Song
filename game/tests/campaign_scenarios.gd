extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func move(s, point: Vector2) -> bool:
	if not s.command("route",{"point":point}): return false
	s.paused=false
	for n in 2600:
		s.advance(0.1)
		for contact in s.contacts.values():
			if contact.lock>1.0 and s.tools.emp>0: s.command("emp"); break
		if not s.outcome.is_empty(): return s.outcome=="won"
		if s.units[0].pos.distance_to(point)<20 and s.units[0].vel.length()<2: return true
		if s.units[0].route.is_empty() and s.units[0].vel.length()<2: return false
	return false
static func run(t) -> void:
	for id in 6:
		var s=Simulation.new(); s.start(id,"disruption")
		# The fallback suite deliberately starts after both drones are lost.
		s.units[1].alive=false; s.units[2].alive=false
		if id==4:
			s=preload("res://tests/listening_well_command_plan.gd").play(true,false,s)
			t.check(s.outcome=="won","Listening Well completes with both drones lost via western optical vantage, finite diversion and physical return")
			print("CAMPAIGN 5 outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1)," tools=",s.tools)
			continue
		if id==5:
			preload("res://tests/finale_command_plan.gd").play(false,"complete",true,-1,s)
			t.check(s.outcome=="won","finale completes via covered solo routes, optical observations, passive decode and return after both drones lost")
			print("CAMPAIGN 6 outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",s.hull)
			continue
		var success=true
		# Blackwater quiet156m fallback: observed safe reverse-order return,
		# preserving the inherited forward south-vantage stop as separate evidence.
		var objectives=s.mission.objectives.duplicate()
		if id==2:objectives.reverse()
		for target in objectives:
			if target.get("optional",false):continue
			var vantage=target.pos+Vector2(0,140 if id==2 else 210)
			if s.blocked(vantage,25): vantage=target.pos+Vector2(-210,0)
			if not move(s,vantage): success=false; break
			if not s.command("camera"): success=false; break
			for n in int((target.get("duration",4.0)+0.5)*10): s.advance(0.1)
			if not target.captured: success=false; break
		if success: success=move(s,s.mission.extraction)
		t.check(success and s.outcome=="won","mission %d completes via routes, camera, extraction with drone-loss fallback"%(id+1))
		print("CAMPAIGN ",id+1," outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1)," oxygen=",snappedf(s.oxygen,0.1)," last=",s.message)
