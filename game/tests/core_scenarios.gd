extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(0)
	var snap=s.snapshot(); s.command("ping"); var paused_snap=s.snapshot(); s.advance(100)
	t.check(paused_snap==s.snapshot(),"paused ping and resource clocks stay frozen")
	s.command("queue"); s.command("select",{"unit":1}); s.command("queue"); s.command("route",{"point":Vector2(300,780)}); s.command("select",{"unit":0})
	t.check(not s.queue_mode,"changing back to sub clears append state")
	s.command("hold"); s.command("route",{"point":Vector2(300,800)}); s.command("queue"); s.command("route",{"point":Vector2(400,800)})
	t.check(s.units[0].route.size()>=2 and not s.units[0].route[0].stop,"queued intermediate waypoint is pass-through")
	s.command("emergency",{"point":Vector2(200,700)})
	t.check(s.units[0].hold=="" and not s.queue_mode and s.units[0].route.back().pos==Vector2(200,700),"emergency replaces queue and conditional hold")
	t.check(not s.line_clear(Vector2(300,480),Vector2(800,480)),"bedrock blocks LOS in both directions")
	t.check(not s.line_clear(Vector2(800,480),Vector2(300,480)),"reverse LOS is blocked")
	var route=s.path(Vector2(300,480),Vector2(800,480))
	t.check(not route.is_empty(),"assisted navigation finds route around basalt")
	for p in route: t.check(not s.blocked(p.pos,18),"route waypoints preserve hull clearance")
	s.sirens[0].pos=Vector2(800,480); s.contacts.clear(); s.units[0].pos=Vector2(300,480); s.units[1].alive=false; s.units[2].alive=false
	s.command("ping")
	t.check(not s.visible(s.sirens[0].pos),"sonar does not reveal through cover")
	s.units[0].route.clear(); s.units[0].vel=Vector2.ZERO; s.paused=false
	for n in 60: s.advance(1.0/60)
	t.check(s.contacts.is_empty() and s.sirens[0].lock==0,"hidden Siren truth does not leak or lock through cover")
	s=Simulation.new(); s.start(0); s.units[0].pos=Vector2(400,800); s.sirens[0].pos=Vector2(700,800); s.command("ping"); s.paused=false
	for n in 10: s.advance(1.0/60)
	var inferred:Vector2=s.sirens[0].goal
	t.check(inferred.distance_to(Vector2(400,800))<=40.01 and inferred!=Vector2(400,800) and s.sirens[0].lock==0 and s.sirens[0].target==-1,"fresh direct sound gives coarse80m-bin inference without hidden exact goal or visual lock")
	var legacy=Simulation.new();legacy.start(0);legacy.mission.erase("acoustic_revision")
	legacy.units[0].pos=Vector2(400,800);legacy.sirens[0].pos=Vector2(700,800);legacy.command("ping");legacy.paused=false
	for n in 10:legacy.advance(1.0/60)
	t.check(legacy.sirens[0].goal.distance_to(Vector2(400,800))<1,"legacy active hearing keeps its exact historical ping-origin contract")
	s.units[0].pos=Vector2(650,800); s.command("emp"); var hull=s.hull
	for n in 120: s.advance(1.0/60)
	t.check(s.hull==hull and s.sirens[0].lock==0,"stunned Sirens cannot detect or damage")
	var a=Simulation.new(); a.start(0); a.command("route",{"point":Vector2(350,800)}); a.paused=false
	var b=Simulation.new(); b.start(0); b.command("route",{"point":Vector2(350,800)}); b.paused=false
	for n in 120: a.advance(1.0/60)
	for n in 60: b.advance(1.0/30)
	t.check(a.units[0].pos.distance_to(b.units[0].pos)<0.001 and absf(a.oxygen-b.oxygen)<0.001,"fixed-step simulation is frame-rate independent")
	var restored=Simulation.new()
	t.check(restored.restore(a.snapshot()),"active snapshot restores")
	t.check(restored.units==a.units and restored.mission==a.mission and restored.paused,"restore preserves orders and records, always pauses")
	# Malformed snapshots must be rejected before they can become active state.
	t.check(not restored.restore({"mission":{},"units":[{}, {}, {}],"sirens":[],"known":{},"tools":{}}),"structurally invalid save rejected safely")
