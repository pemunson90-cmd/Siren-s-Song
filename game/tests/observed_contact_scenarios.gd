extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
static func entries(contacts: Dictionary,elapsed: float,units: Array) -> Array:
	var path="res://src/presentation/contact_feedback.gd"
	return load(path).entries(contacts,elapsed,units) if FileAccess.file_exists(path) else []
static func run(t) -> void:
	var s=Simulation.new();s.start(4)
	# Only cached player observations, including a hunter now out of contact.
	s.contacts={1:{"pos":Vector2(800,700),"time":10.0,"mode":"INVESTIGATE","lock":0.0,"angle":0.2,"target":-1,"type":"hunter"}}
	var rows=entries(s.contacts,10,s.units)
	t.check(rows.size()==1 and rows[0].tag=="S2" and rows[0].text=="S2 HUNTER · INVESTIGATE","fresh observed hunter has stable shared glyph/readout identity")
	rows=entries(s.contacts,13,s.units)
	t.check(rows.size()==1 and rows[0].tag=="S2" and rows[0].text=="S2 HUNTER · LAST SEEN 3s","lost hunter retains last-observed identity and role without asserting its current mode")
	s.contacts[0]={"pos":Vector2(750,610),"time":13.0,"mode":"INVESTIGATE","lock":0.0,"angle":0.1,"target":-1,"type":"patroller"}
	rows=entries(s.contacts,13,s.units)
	t.check(rows.size()==2 and rows.any(func(r):return r.text=="S1 PATROL · INVESTIGATE") and rows.any(func(r):return r.text=="S2 HUNTER · LAST SEEN 3s"),"new investigating patrol remains distinguishable from the hunter echo")
	var original=entries(s.contacts,13,s.units);s.sirens[1].mode="RETURN";s.sirens[1].pos=Vector2(1500,50)
	t.check(entries(s.contacts,13,s.units)==original,"hidden current role state and position cannot change contact readout")
	s.elapsed=13;s.paused=true;var snap=s.snapshot();s.advance(10)
	t.check(entries(s.contacts,s.elapsed,s.units)==original and snap==s.snapshot(),"tactical pause freezes observed age and simulation state")
	var restored=Simulation.new();restored.restore(bytes_to_var(var_to_bytes(s.snapshot())))
	t.check(entries(restored.contacts,restored.elapsed,restored.units)==original,"serialized existing observation records preserve identity and age on paused restore")
	t.check(entries(s.contacts,34,s.units).is_empty(),"expired observations cannot leave persistent contact rows")
	var memory=s.contacts.duplicate(true);rows=entries(s.contacts,13,s.units)
	if not rows.is_empty():rows[0].pos=Vector2.ZERO;rows[0].text="fiction"
	t.check(s.contacts==memory,"presentation contact entries cannot mutate cached observations")
	# Put an observed lock after two nonurgent observations; lock must take priority.
	s.contacts[2]={"pos":Vector2(720,620),"time":13.0,"mode":"LOCKING","lock":1.5,"angle":0.0,"target":0,"type":"sentinel"}
	rows=entries(s.contacts,13,s.units)
	t.check(rows.size()==3 and rows[0].tag=="S3" and rows[0].text=="S3 GUARD → QUIETUS · BEAM 2.5s","fresh observed beam target and countdown stay first among three contact rows")
	rows=entries(s.contacts,14,s.units)
	t.check(not rows.any(func(r):return "BEAM" in r.text or "INVESTIGATE" in r.text),"stale contacts cannot retain live beam or investigation claims")
	s.start(0);s.command("decoy")
	t.check(s.message=="Decoy launched · 15s transmission","decoy launch log describes a historical event rather than claiming a live transmission")
	s.paused=false
	for i in 16*60:s.advance(1.0/60)
	t.check(s.noises.is_empty() and s.message=="Decoy launched · 15s transmission","launch wording remains true after transmission expiry")
