extends SceneTree
const Simulation = preload("res://src/simulation/simulation.gd")
var emp_policy := true
func move(s, point: Vector2) -> bool:
	if not s.command("route",{"point":point}): return false
	s.paused=false
	for n in 2600:
		s.advance(0.1)
		if emp_policy:
			for c in s.contacts.values():
				if c.lock>1.0 and s.tools.emp>0: s.command("emp"); break
		if not s.outcome.is_empty(): return s.outcome=="won"
		if s.units[0].pos.distance_to(point)<20 and s.units[0].vel.length()<2: return true
	return false
func run_policy(id:int, upgrade:String, use_emp:bool, drones:bool, cruise:bool) -> String:
	emp_policy=use_emp
	var s=Simulation.new(); s.start(id,upgrade)
	if not drones: s.units[1].alive=false; s.units[2].alive=false
	if cruise: s.units[0].silent=false
	var ok=true
	for target in s.mission.objectives:
		var v=target.pos+Vector2(0,210)
		if s.blocked(v,25): v=target.pos+Vector2(-210,0)
		if not move(s,v): ok=false; break
		if not s.command("camera"): ok=false; break
		for n in int((target.get("duration",4.0)+0.5)*10): s.advance(0.1)
		if not target.captured: ok=false; break
	if ok: ok=move(s,s.mission.extraction)
	return "m%d %s emp=%s cruise=%s -> %s t=%.1f hull=%.1f o2=%.1f tools=%s" % [id+1,upgrade,use_emp,cruise,s.outcome if s.outcome!="" else "stalled",s.elapsed,s.hull,s.oxygen,s.tools]
func _initialize():
	for id in 6:
		for policy in [["endurance",false,false],["endurance",false,true],["disruption",true,false],["disruption",true,true]]:
			print(run_policy(id,policy[0],policy[1],false,policy[2]))
	quit()
