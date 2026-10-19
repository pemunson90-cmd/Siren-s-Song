extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func feedback(s) -> Dictionary:
	return s.acoustic_feedback() if s.has_method("acoustic_feedback") else {"motion":[],"pulses":[],"responses":[]}
static func run(t) -> void:
	var s=Simulation.new(); s.start(0)
	s.command("decoy"); s.command("select",{"unit":1}); s.command("route",{"point":Vector2(500,700)})
	var f=feedback(s)
	t.check(f.pulses.size()==1 and f.pulses[0].label=="DECOY" and f.pulses[0].time==15.0,"decoy remaining life survives unrelated station and route feedback")
	var before=s.snapshot(); s.advance(10)
	t.check(feedback(s)==f and s.snapshot()==before,"paused decoy feedback consumes no transmission life or simulation state")
	var restored=Simulation.new(); restored.restore(s.snapshot())
	t.check(feedback(restored).pulses.size()==1 and feedback(restored).pulses[0].time==15,"restored existing noise records retain finite decoy feedback without a new save field")
	s.paused=false
	for i in 31*60: s.advance(1.0/60)
	t.check(feedback(s).pulses.is_empty(),"expired decoy vanishes from persistent feedback")
	s.start(0); s.command("decoy"); s.paused=false
	for i in 3*60: s.advance(1.0/60)
	s.command("decoy"); s.paused=true; f=feedback(s)
	t.check(f.pulses.size()==2 and absf(f.pulses[0].time-12)<0.01 and f.pulses[1].time==15,"staggered decoys retain their independent remaining times")
	s.start(0); s.units[0].vel=Vector2(51,0); s.units[0].silent=true; s.units[1].vel=Vector2(96,0)
	f=feedback(s)
	t.check(f.motion.size()==2,"silent toggle and drone station cannot hide actual above-threshold movement emissions")
	s.units[0].vel=Vector2(50,0); s.units[1].alive=false
	t.check(feedback(s).motion.size()==1 and feedback(s).motion[0].radius<430,"continuous own speed estimate survives old threshold and excludes lost craft")
	s.command("ping"); s.command("recon"); s.command("emp"); s._noise(Vector2(1500,50),1150,"FACTORY RESPONSE",8); s._noise(Vector2(1200,20),500,"UNKNOWN",8)
	f=feedback(s)
	t.check(f.pulses.map(func(n):return n.label)==["ACTIVE SONAR","RECON UPLINK","DISRUPTION"],"own pulse feedback excludes enemy and unknown noise sources")
	before=s.snapshot(); f.pulses.clear(); f.motion.append({"name":"fiction"})
	t.check(s.snapshot()==before,"presentation cannot mutate simulation through its acoustic snapshot")
	var hidden=feedback(s); s.sirens[0].mode="BEAM"; s.sirens[0].goal=Vector2(1,2); s.sirens[0].suspicion=1
	t.check(feedback(s)==hidden,"acoustic feedback cannot disclose hidden enemy reception or reaction")
	s.recon_time=0; s.ping_time=0
	s._noise(s.units[0].pos,1150,"FACTORY RESPONSE",8)
	t.check(feedback(s).responses.size()==1 and feedback(s).responses[0].pos==s.units[0].pos,"factory response is presented only while its source is sensor-visible")
