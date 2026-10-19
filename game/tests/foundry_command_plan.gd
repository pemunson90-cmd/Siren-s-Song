extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func advance(s,seconds: float,protect: bool) -> void:
	for n in int(seconds*10):
		s.advance(0.1)
		if protect:
			for contact in s.contacts.values():
				if contact.lock>1 and s.elapsed-contact.time<0.3 and s.tools.emp>0:
					s.command("select",{"unit":contact.get("target",0) if contact.get("target",0)>=0 else 0}); s.command("emp"); break
static func travel(s,id: int,destination: Vector2,protect: bool) -> bool:
	s.command("select",{"unit":id})
	if not s.command("route",{"point":destination}): return false
	s.paused=false
	for n in 1800:
		advance(s,0.1,protect)
		if not s.outcome.is_empty(): return s.outcome=="won"
		if not s.units[id].alive: return false
		if s.units[id].pos.distance_to(destination)<20 and s.units[id].vel.length()<2: return true
	return false
static func play(coordinated: bool,stage: String="complete",protect: bool=true,withdrawal: String="exposed"):
	var s=Simulation.new(); s.start(3,"disruption")
	if stage=="initial": return s
	if coordinated:
		# Quietus takes the sheltered southern transit while the pilot operates Drone A.
		s.command("route",{"point":Vector2(740,800)})
		s.command("select",{"unit":2}); s.command("route",{"point":Vector2(860,840)})
	if not travel(s,1 if coordinated else 0,Vector2(1000,540) if coordinated else Vector2(930,360),protect): return s
	if stage=="approach": s.paused=true; return s
	s.command("select",{"unit":1 if coordinated else 0}); s.command("camera"); advance(s,2.0,protect)
	if stage=="furnace": s.command("select",{"unit":s.capture_unit if s.capture_unit>=0 else 0}); s.paused=true; return s
	advance(s,2.5,protect)
	if coordinated:
		s.command("select",{"unit":1}); s.command("route",{"point":Vector2(860,840) if withdrawal=="diagonal" else Vector2(860,540)})
		if withdrawal=="queued":
			s.command("queue"); s.command("route",{"point":Vector2(860,840)}); s.command("queue")
		s.command("select",{"unit":0}); s.command("route",{"point":s.mission.extraction})
	if not travel(s,2 if coordinated else 0,Vector2(1110,830),protect): return s
	s.command("select",{"unit":2 if coordinated else 0}); s.command("camera"); advance(s,2.0,protect)
	if stage=="cradle": s.command("select",{"unit":s.capture_unit if s.capture_unit>=0 else 0}); s.paused=true; return s
	advance(s,2.5,protect)
	if stage=="response": s.paused=true; return s
	if coordinated:
		s.command("select",{"unit":1}); s.command("decoy")
	if coordinated:
		s.command("select",{"unit":2}); s.command("route",{"point":Vector2(1040,880) if withdrawal!="exposed" else Vector2(1120,880)})
	travel(s,0,s.mission.extraction,protect)
	return s
