extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(0)
	t.check(s.command("waypoint_mode") and not s.pass_through,"pilot can explicitly select STOP queued waypoints")
	for passthrough in [false,true]:
		s=Simulation.new(); s.start(0); s.pass_through=passthrough
		s.command("route",{"point":Vector2(280,800)}); s.command("queue"); s.command("route",{"point":Vector2(440,800)}); s.paused=false
		var transition_speed=-1.0
		for n in 1000:
			s.advance(1.0/60)
			if transition_speed<0 and s.units[0].route.size()==1: transition_speed=s.units[0].vel.length()
			if s.units[0].route.is_empty() and s.units[0].vel.length()<2: break
		t.check(transition_speed>30 if passthrough else transition_speed<3.5,"PASS preserves motion" if passthrough else "STOP genuinely settles before queued continuation")
		t.check(s.units[0].pos.distance_to(Vector2(440,800))<12 and s.units[0].vel.length()<2,"final waypoint stops reliably after queued route")
	s=Simulation.new(); s.start(0); s.elapsed=5.0
	s.contacts[0]={"pos":Vector2(1200,100),"time":0.0,"mode":"PATROL","lock":0.0,"angle":0.0}
	s.command("route",{"point":Vector2(350,800)}); s.command("contact_hold"); s.paused=false
	for n in 20: s.advance(0.1)
	t.check(s.units[0].pos.x>170,"conditional contact hold ignores stale memory echoes")

	s=Simulation.new(); s.start(0); s.command("decoy"); s.paused=false
	for n in 30: s.advance(0.1)
	t.check(s.noises.any(func(n): return n.label=="DECOY"),"decoy continues transmitting long enough to draw a recovering Siren")
