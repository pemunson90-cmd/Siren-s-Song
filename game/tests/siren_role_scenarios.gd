extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func advance(s,seconds: float) -> void:
	for n in int(round(seconds*10)): s.advance(0.1)
static func fixture(role: String):
	var s=Simulation.new(); s.start(0)
	# Exact historical heard-point assertions preserve legacy active-role archives.
	# Fresh terrain-arrival rules are exercised in acoustic_hearing_tests.gd.
	s.mission.erase("acoustic_revision")
	s.mission.rocks=[]; s.mission.erase("structures"); s._build_navigation()
	s.units[0].pos=Vector2(140,850); s.units[1].alive=false; s.units[2].alive=false
	var guard=s.sirens[0]
	guard["type"]=role; guard["tether"]=190.0; guard.pos=Vector2(1000,500); guard.home=guard.pos; guard.goal=guard.pos; guard.angle=PI
	guard.patrol_points=[Vector2(700,500),Vector2(1000,700),Vector2(1200,500)]; guard.patrol_index=0
	s.paused=false
	return s
static func run(t) -> void:
	var foundry=Simulation.new(); foundry.start(3)
	t.check(foundry.sirens.all(func(s):return s.get("type","")=="sentinel"),"Cold Foundry intentionally assigns tethered station guards")
	var well=Simulation.new(); well.start(4)
	t.check(well.sirens.any(func(s):return s.get("type","")=="hunter"),"Listening Well has a distinct fast responder rather than another generic patrol")
	var sentinel=fixture("sentinel"); var furthest=0.0
	for n in 300:
		sentinel.advance(0.1); furthest=maxf(furthest,sentinel.sirens[0].pos.distance_to(sentinel.sirens[0].home))
	t.check(furthest<=190,"unprovoked sentinel remains tethered to its authored station")
	var hunter=fixture("hunter"); advance(hunter,10)
	t.check(hunter.sirens[0].pos.distance_to(hunter.sirens[0].home)<1,"unprovoked hunter waits at home as in actual v7 implementation")
	var distances=[]
	for role in ["patroller","hunter"]:
		var s=fixture(role); s.units[0].pos=Vector2(500,500); s.command("ping"); var origin:Vector2=s.sirens[0].pos; advance(s,2)
		distances.append(s.sirens[0].pos.distance_to(origin))
		if role=="hunter":
			s.units[0].pos=Vector2(140,900); advance(s,0.2)
			t.check(s.sirens[0].goal.distance_to(Vector2(500,500))<1,"hunter follows heard last-known point without tracking the now-hidden pilot")
			advance(s,30)
			t.check(s.sirens[0].pos.distance_to(s.sirens[0].home)<35,"hunter completes local investigation/search and returns to station")
	t.check(distances[1]>distances[0]+5,"hunter has faster physical response than ordinary patrol under identical hearing conditions")
	var lure=fixture("sentinel"); lure.sirens[0].pos=Vector2(760,500); lure.units[0].pos=Vector2(140,900)
	lure.command("decoy",{"point":Vector2(600,500)}); advance(lure,1)
	t.check(lure.sirens[0].goal.distance_to(Vector2(600,500))<1 and lure.sirens[0].pos.distance_to(lure.sirens[0].home)>190,"fresh audible lure can draw a sentinel beyond tether; it is not a hard chase leash")
	advance(lure,30)
	t.check(lure.sirens[0].pos.distance_to(lure.sirens[0].home)<35,"sentinel returns home after the outside lure ends")
	for role in ["sentinel","hunter"]:
		var s=fixture(role); s.units[0].pos=Vector2(900,500); advance(s,3)
		t.check(s.hull==100 and s.sirens[0].lock>2.5,"%s retains full fresh visual lock warning before damage"%role)
		s.command("emp"); var position:Vector2=s.sirens[0].pos; advance(s,2)
		t.check(s.hull==100 and s.sirens[0].pos==position and s.sirens[0].lock==0,"%s cannot move, lock or fire while disrupted"%role)

	var memory=fixture("hunter"); memory.units[0].pos=Vector2(500,500); memory.command("ping"); advance(memory,3)
	var saved=memory.snapshot(); var loaded=Simulation.new()
	t.check(loaded.restore(saved) and loaded.sirens==memory.sirens,"active role, heard point, bounded search memory and physical route survive restoration")
	var frozen=loaded.snapshot(); advance(loaded,2)
	t.check(frozen==loaded.snapshot(),"paused restoration freezes hunter attention and movement")
	loaded.paused=false; memory.paused=false; advance(loaded,2); advance(memory,2)
	t.check(loaded.sirens==memory.sirens,"restored hunter resumes the same deterministic response")
	var legacy=fixture("patroller").snapshot(); legacy.sirens[0].erase("type")
	t.check(loaded.restore(legacy) and not loaded.sirens[0].has("type"),"legacy saves preserve their existing patrol content rather than replacing an active mission")
	for field in ["type","attention_time","last_known","search_index"]:
		var bad=saved.duplicate(true); bad.sirens[0][field]="invalid"
		t.check(not Simulation.valid_snapshot(bad),"invalid optional role state %s is rejected"%field)
	for role in ["sentinel","hunter"]:
		var s=fixture(role)
		# A rock blocks visual lock and attenuates an ordinary camera's local sound.
		s.mission.rocks=[Rect2(740,200,100,600)]; s._build_navigation()
		s.units[0].pos=Vector2(660,500); s._noise(s.units[0].pos,700,"TEST",0.2); advance(s,0.3)
		t.check(s.sirens[0].target==-1 and s.sirens[0].pos.distance_to(s.sirens[0].home)<1,"%s cannot hear a quiet occluded stimulus or see through cover"%role)
		s.command("ping"); advance(s,0.2)
		t.check(s.sirens[0].mode=="INVESTIGATE" and s.sirens[0].target==-1 and not s.sirens[0].route.is_empty(),"%s follows a loud occluded sound via navigable water without visual lock"%role)

	for role in ["sentinel","hunter"]:
		var s=fixture(role); s.units[0].pos=Vector2(750,500); s.units[0].silent=false
		var origin:Vector2=s.sirens[0].pos
		advance(s,2)
		t.check(s.sirens[0].pos.distance_to(origin)>20 and s.sirens[0].lock>1.9 and s.hull==100,"%s physically pursues a distant visible target while preserving the lock telegraph"%role)
		advance(s,1.8)
		t.check(s.sirens[0].pos.distance_to(s.units[0].pos)>110 and s.hull==100,"%s brakes at safe emitter standoff instead of overlapping a visible target"%role)

	var collision=fixture("hunter"); collision.mission.rocks=[Rect2(700,200,100,400)]; collision._build_navigation()
	collision.sirens[0].pos=Vector2(812,400); collision.sirens[0].vel=Vector2(-96,0)
	collision.message="Quietus orders intact"; collision._threats(0.1)
	t.check(collision.message=="Quietus orders intact","enemy terrain braking cannot falsely report that the player's autopilot stopped")
