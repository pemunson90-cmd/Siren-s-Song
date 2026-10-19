extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func advance(s,seconds: float,protect: bool=true,abandon: int=-1) -> void:
	for n in int(round(seconds*10)):
		s.advance(0.1)
		if not protect: continue
		for contact in s.contacts.values():
			var id=int(contact.get("target",-1))
			if id>=0 and id!=abandon and contact.lock>1 and s.elapsed-contact.time<0.3 and s.tools.emp>0:
				s.command("select",{"unit":id}); s.command("emp"); break
static func travel(s,id: int,destination: Vector2,protect: bool=true,abandon: int=-1) -> bool:
	s.command("select",{"unit":id})
	if not s.command("route",{"point":destination}): return false
	s.paused=false
	for n in 1800:
		advance(s,0.1,protect,abandon)
		if not s.outcome.is_empty(): return s.outcome=="won"
		if not s.units[id].alive: return false
		if s.units[id].pos.distance_to(destination)<20 and s.units[id].vel.length()<2: return true
	return false
static func play(coordinated: bool,stage: String="complete",protect: bool=true,abandon: int=-1,existing=null):
	var s=Simulation.new() if existing==null else existing
	if existing==null: s.start(5,"disruption")
	if stage=="initial": return s
	if coordinated: s.command("route",{"point":Vector2(690,780)})
	var first=1 if coordinated else 0
	if not travel(s,first,Vector2(1010,240),protect,abandon): return s
	s.command("select",{"unit":first})
	if not s.command("camera"): return s
	advance(s,2,protect,abandon)
	if stage=="crown": s.command("select",{"unit":first}); s.paused=true; return s
	advance(s,2.5,protect,abandon)
	if coordinated:
		s.command("select",{"unit":first}); s.command("route",{"point":Vector2(690,780)})
	if not coordinated: s.command("select",{"unit":0}); s.command("decoy")
	var second=2 if coordinated else 0
	if not travel(s,second,Vector2(1190,780),protect,abandon): return s
	s.command("select",{"unit":second})
	if not s.command("camera"): return s
	advance(s,2,protect,abandon)
	if stage=="wakes": s.command("select",{"unit":second}); s.paused=true; return s
	advance(s,2.5,protect,abandon)
	if not travel(s,0,Vector2(690,780),protect,abandon): return s
	s.command("select",{"unit":0})
	if not s.command("camera"): return s
	advance(s,3,protect,abandon)
	if stage=="receiver": s.command("select",{"unit":0}); s.paused=true; return s
	advance(s,3.5,protect,abandon)
	if stage=="warning": s.paused=true; return s
	if stage=="return":
		s.command("select",{"unit":0}); s.command("emergency",{"point":s.mission.extraction}); advance(s,3,protect,abandon); s.paused=true; return s
	travel(s,0,s.mission.extraction,protect,abandon)
	return s
