extends RefCounted
const Soundscape=preload("res://src/audio/soundscape.gd")
const Simulation=preload("res://src/simulation/simulation.gd")
static func run(t) -> void:
	for cue in ["ambience","ping","camera","emp","record","loss","extraction","alert","engine","creak","beam","factory","salvage"]:
		var values=Soundscape.samples(cue)
		var peak=0.0; var energy=0.0
		for v in values: peak=maxf(peak,absf(v)); energy+=v*v
		t.check(values.size()>1000 and peak<0.95 and energy>0.01,"audio %s has nonzero signal and clipping headroom"%cue)

	t.check(Soundscape.engine_gain(0,true)==0 and Soundscape.engine_gain(42,true)>0 and Soundscape.engine_gain(78,false)>Soundscape.engine_gain(42,true)*2,"propulsion audio reflects stationary, silent and noisy cruise thrust")
	for cue in ["engine","creak","beam","recon","decoy","factory","salvage"]:
		t.check(Soundscape.samples(cue)!=Soundscape.samples("alert"),"%s has its own functional sonic identity"%cue)

	for cue in ["ambience","engine"]:
		var wav=Soundscape.stream(cue)
		var frames=wav.data.size()/2
		t.check(wav.loop_begin>=0 and wav.loop_begin<wav.loop_end and wav.loop_end<frames,"%s loop endpoints address valid PCM frames at the native mixer boundary"%cue)
	_engine_effort(t)

static func _engine_effort(t) -> void:
	# Component fixtures isolate ground motion from through-water thrust. Exercise
	# update() and its actual player/bus outputs, rather than only engine_gain().
	var buses={}
	for index in AudioServer.bus_count:buses[AudioServer.get_bus_name(index)]={"muted":AudioServer.is_bus_mute(index),"volume":AudioServer.get_bus_volume_db(index)}
	# The core runner is synchronous in SceneTree._initialize(), before _ready().
	# Supply real players without starting streams or the scene lifecycle.
	var sound=Soundscape.new();sound.ambience=AudioStreamPlayer.new();sound.engine=AudioStreamPlayer.new()
	sound.add_child(sound.ambience);sound.add_child(sound.engine)
	sound._bus(sound.AMBIENCE_BUS);sound._bus(sound.EFFECTS_BUS)
	var sim=Simulation.new();sim.start(0);sim.paused=false
	var own=sim.units[0];own.silent=true;own.vel=Vector2.ZERO;own.water_velocity=Vector2(-24,0)
	sound.update(sim,0.,true)
	t.check(is_equal_approx(db_to_linear(sound.engine.volume_db),.04) and is_equal_approx(sound.engine.pitch_scale,.99),"stationkeeping counterthrust has audible engine gain and pitch despite zero ground speed")
	own.vel=Vector2(24,0);own.water_velocity=Vector2.ZERO
	sound.update(sim,0.,true)
	t.check(is_equal_approx(db_to_linear(sound.engine.volume_db),.0001) and is_equal_approx(sound.engine.pitch_scale,.75),"free current drift has idle engine gain and pitch despite nonzero ground speed")
	own.erase("water_velocity");own.vel=Vector2(42,0)
	sound.update(sim,0.,true)
	t.check(is_equal_approx(db_to_linear(sound.engine.volume_db),.07) and is_equal_approx(sound.engine.pitch_scale,1.17),"ordinary currentless silent motion preserves engine gain and pitch through the simulation fallback")
	own.vel=Vector2.ZERO;sound.update(sim,0.,true)
	t.check(is_equal_approx(db_to_linear(sound.engine.volume_db),.0001) and is_equal_approx(sound.engine.pitch_scale,.75),"ordinary currentless rest preserves idle engine output")
	own.vel=Vector2(78,0);own.silent=false;sound.update(sim,0.,true)
	t.check(is_equal_approx(db_to_linear(sound.engine.volume_db),.35) and is_equal_approx(sound.engine.pitch_scale,1.53),"ordinary noisy cruise preserves its louder actual engine output")
	own.vel=Vector2.ZERO;own.water_velocity=Vector2(-24,0);own.silent=true;sound.muted=true;sound.update(sim,0.,true)
	t.check(AudioServer.is_bus_mute(AudioServer.get_bus_index(sound.EFFECTS_BUS)) and AudioServer.is_bus_mute(AudioServer.get_bus_index(sound.AMBIENCE_BUS)),"mute still silences actual audio buses during counterthrust")
	sound.free();sim=null
	# Restore global buses touched by this real component fixture so the rest of
	# the core runner stays isolated. The detached players are freed with sound.
	for index in range(AudioServer.bus_count-1,0,-1):
		if AudioServer.get_bus_name(index) not in buses:AudioServer.remove_bus(index)
	for name in buses:
		var index=AudioServer.get_bus_index(name)
		AudioServer.set_bus_mute(index,buses[name].muted);AudioServer.set_bus_volume_db(index,buses[name].volume)
