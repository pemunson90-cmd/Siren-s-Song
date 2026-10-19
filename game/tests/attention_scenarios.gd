extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	var s=Simulation.new(); s.start(0)
	s.units[1].pos=Vector2(1300,510); s.command("select",{"unit":1}); s.command("camera")
	s.command("select",{"unit":0}); s.paused=false
	for n in 45: s.advance(0.1)
	t.check(s.mission.objectives[0].captured and s.units[1].hold=="","switching stations preserves commanded exposure and releases its hold")
	s=Simulation.new(); s.start(0); s.command("select",{"unit":1}); s.units[1].alive=false
	var tools=s.tools.duplicate(); var noises=s.noises.duplicate(true)
	t.check(not s.command("emp") and s.tools==tools and s.noises==noises,"lost drone cannot consume or fire tools")
	t.check(s.selected==0 and not s.queue_mode,"lost active drone safely falls back to submarine command")
	s=Simulation.new(); s.start(0); s.sirens[0].pos=Vector2(900,800); s.sirens[0].goal=Vector2(900,800); s.sirens[0].route=[]
	s.units[0].pos=Vector2(850,800); s.units[1].pos=Vector2(1040,800); s.units[2].alive=false; s.paused=false
	for n in 38: s.advance(0.1)
	t.check(s.sirens[0].lock>3,"lock test has acquired submarine before handoff")
	s.units[0].pos=Vector2(140,800); s.units[1].pos=s.sirens[0].pos+Vector2(60,0)
	for n in 3: s.advance(0.1)
	t.check(s.units[1].alive and s.sirens[0].lock<0.5,"Siren target change requires a fresh beam telegraph")

	# The fast drone must actually round known terrain under production steering.
	s=Simulation.new(); s.start(0); s.command("select",{"unit":1}); s.command("route",{"point":Vector2(1300,510)}); s.paused=false
	for n in 500:
		s.advance(0.1)
		if s.units[1].pos.distance_to(Vector2(1300,510))<20: break
	t.check(s.units[1].pos.distance_to(Vector2(1300,510))<20,"assisted drone route rounds known basalt with inertia")
