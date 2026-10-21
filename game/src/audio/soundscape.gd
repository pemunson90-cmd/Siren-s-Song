extends Node
const RATE := 22050
const AMBIENCE_BUS := "SirenAmbience"
const EFFECTS_BUS := "SirenEffects"
const ATTRIBUTION := preload("res://assets/audio/attribution.tres")
var music_volume := 0.5
var effects_volume := 0.8
var muted := false
var ambience: AudioStreamPlayer
var engine: AudioStreamPlayer
var tension: AudioStreamPlayer
var tension_level := 0.0
var last_clock := -1.0
var voices: Array=[]
var panners: Array=[]
var cues: Dictionary={}
var received_cues=preload("res://src/audio/received_cues.gd").new()
var heartbeat_timer := 0.0
var alert_timer := 0.0
var creak_timer := 11.0
var system_suspended := false
static func engine_gain(speed: float,silent: bool) -> float:
	return clampf(speed/78.0,0,1)*(0.13 if silent else 0.35)
# Imported mono 16-bit recordings: no runtime oscillators, noise generation or PCM allocation.
# Preloads keep the complete asset set in exported builds. See assets/audio/ATTRIBUTION.md.
const RECORDINGS := {
	"alert": preload("res://assets/audio/alert.wav"),
	"ambience": preload("res://assets/audio/ambience.wav"),
	"beam": preload("res://assets/audio/beam.wav"),
	"berth_release": preload("res://assets/audio/berth_release.wav"),
	"camera": preload("res://assets/audio/camera.wav"),
	"carrier_received": preload("res://assets/audio/carrier_received.wav"),
	"creak": preload("res://assets/audio/creak.wav"),
	"decoy": preload("res://assets/audio/decoy.wav"),
	"emp": preload("res://assets/audio/emp.wav"),
	"engine": preload("res://assets/audio/engine.wav"),
	"extraction": preload("res://assets/audio/extraction.wav"),
	"factory": preload("res://assets/audio/factory.wav"),
	"heartbeat": preload("res://assets/audio/heartbeat.wav"),
	"knock": preload("res://assets/audio/knock.wav"),
	"loss": preload("res://assets/audio/loss.wav"),
	"ping": preload("res://assets/audio/ping.wav"),
	"plant_switch": preload("res://assets/audio/plant_switch.wav"),
	"recon": preload("res://assets/audio/recon.wav"),
	"record": preload("res://assets/audio/record.wav"),
	"return_received": preload("res://assets/audio/return_received.wav"),
	"salvage": preload("res://assets/audio/salvage.wav"),
	"snare": preload("res://assets/audio/snare.wav"),
	"sweep_received": preload("res://assets/audio/sweep_received.wav"),
	"tension": preload("res://assets/audio/tension.wav"),
}
static func samples(cue: String) -> PackedFloat32Array:
	# Compatibility/inspection API. Runtime players share imported resources directly.
	var wav=stream(cue)
	var result=PackedFloat32Array(); result.resize(wav.data.size()/2)
	for n in result.size(): result[n]=float(wav.data.decode_s16(n*2))/32768.0
	return result
static func stream(cue: String) -> AudioStreamWAV:
	return RECORDINGS.get(cue,RECORDINGS.alert)
func _bus(name: String,send_to: String="Master") -> int:
	var index=AudioServer.get_bus_index(name)
	if index<0:
		AudioServer.add_bus(); index=AudioServer.bus_count-1; AudioServer.set_bus_name(index,name); AudioServer.set_bus_send(index,send_to)
	return index
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	set_meta("audio_attribution",ATTRIBUTION)
	_bus(AMBIENCE_BUS); _bus(EFFECTS_BUS)
	var guarded=false
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0,i).resource_name=="SirenPeakGuard": guarded=true
	if not guarded:
		var limiter=AudioEffectLimiter.new(); limiter.resource_name="SirenPeakGuard"; limiter.threshold_db=-3; limiter.ceiling_db=-1; AudioServer.add_bus_effect(0,limiter)
	for cue in ["ping","camera","emp","knock","snare","salvage","record","loss","extraction","alert","recon","decoy","creak","beam","factory","carrier_received","return_received","sweep_received","heartbeat","berth_release","plant_switch"]: cues[cue]=stream(cue)
	ambience=AudioStreamPlayer.new(); ambience.stream=stream("ambience"); ambience.bus=AMBIENCE_BUS; ambience.volume_db=-17; add_child(ambience); ambience.play()
	tension=AudioStreamPlayer.new(); tension.stream=stream("tension"); tension.bus=AMBIENCE_BUS; tension.volume_db=-80; add_child(tension); tension.play()
	engine=AudioStreamPlayer.new(); engine.stream=stream("engine"); engine.bus=EFFECTS_BUS; engine.volume_db=-80; add_child(engine); engine.play()
	for bed in [ambience,engine,tension]: bed.stream_paused=true
	for n in 5:
		var bus_name="SirenVoice%d"%n; var index=_bus(bus_name,EFFECTS_BUS)
		var panner: AudioEffectPanner
		if AudioServer.get_bus_effect_count(index)==0:
			panner=AudioEffectPanner.new(); AudioServer.add_bus_effect(index,panner)
		else: panner=AudioServer.get_bus_effect(index,0)
		panners.append(panner)
		var voice=AudioStreamPlayer.new(); voice.bus=bus_name; voice.volume_db=-7.5; add_child(voice); voices.append(voice)
func update(sim,dt: float,active_dive: bool=true) -> void:
	received_cues.observe_clock(sim.elapsed)
	if ambience==null: return
	var ambience_index=AudioServer.get_bus_index(AMBIENCE_BUS); var effects_index=AudioServer.get_bus_index(EFFECTS_BUS)
	AudioServer.set_bus_mute(ambience_index,muted or music_volume<=0); AudioServer.set_bus_mute(effects_index,muted or effects_volume<=0)
	AudioServer.set_bus_volume_db(ambience_index,linear_to_db(maxf(0.001,music_volume)))
	AudioServer.set_bus_volume_db(effects_index,linear_to_db(maxf(0.001,effects_volume)))
	var frozen=sim.paused or not active_dive or system_suspended
	ambience.stream_paused=frozen; engine.stream_paused=frozen
	if sim.elapsed<last_clock: tension_level=0.0
	last_clock=sim.elapsed
	if tension!=null:
		tension.stream_paused=frozen
		if not frozen:
			# Only the public, fresh received-contact threat channel is eligible.
			# Hunt, source positions, hidden locks and enemy rosters are never read.
			var target=clampf(float(sim.recon_feedback().get("threat",0.0)),0.0,1.0)
			var seconds=.7 if target>tension_level else 4.0
			tension_level=lerpf(tension_level,target,1.0-exp(-maxf(dt,0.0)/seconds))
		tension.volume_db=linear_to_db(maxf(.0001,tension_level*.24))
	if system_suspended or not active_dive:
		for voice in voices: voice.stream_paused=true
		sim.events.clear()
		return
	var speed: float=sim.propulsion_speed(sim.units[0])
	engine.volume_db=linear_to_db(maxf(0.0001,engine_gain(speed,sim.units[0].silent))); engine.pitch_scale=0.75+speed/100.0
	alert_timer=maxf(0,alert_timer-dt)
	if active_dive and not sim.paused:
		heartbeat_timer=maxf(0,heartbeat_timer-dt)
		var pressure=sim.recon_feedback()
		if pressure.threat>.1 and heartbeat_timer<=0:
			play("heartbeat");heartbeat_timer=.45 if pressure.hostile else .9
		creak_timer-=dt
		if creak_timer<=0: play("creak"); creak_timer=13.0+sin(sim.elapsed)*3
		for contact in sim.contacts.values():
			if contact.lock>0.1 and sim.elapsed-contact.time<0.4 and alert_timer<=0:
				play("alert",contact.pos-sim.units[sim.selected].pos); alert_timer=3.0
	for event in sim.events:
		if event.type=="plant_control":play("plant_switch")
		elif event.type in ["carrier_received","return_received","sweep_received"]:
			var received=received_cues.take(event,sim.selected,sim.elapsed,active_dive and not sim.paused)
			if not received.is_empty():play(received.cue,received.relative)
		else:play(event.type,event.get("pos",sim.units[sim.selected].pos)-sim.units[sim.selected].pos)
	# play() starts a fresh voice unpaused. Apply the tactical freeze after
	# event dispatch too, including a switch accepted while planning.
	for voice in voices: voice.stream_paused=frozen
	sim.events.clear()
func play(cue: String,relative_position: Vector2=Vector2.ZERO) -> void:
	if muted or effects_volume<=0 or system_suspended or not cues.has(cue): return
	for i in voices.size():
		var voice=voices[i]
		if not voice.playing:
			panners[i].pan=clampf(relative_position.x/550.0,-0.8,0.8); voice.stream=cues[cue]; voice.play(); return
func suspend() -> void:
	system_suspended=true
	if ambience!=null: ambience.stream_paused=true
	if engine!=null: engine.stream_paused=true
	if tension!=null: tension.stream_paused=true
	for voice in voices: voice.stream_paused=true
func resume() -> void: system_suspended=false
func _exit_tree() -> void:
	if ambience!=null: ambience.stop(); ambience.stream=null
	if engine!=null: engine.stop(); engine.stream=null
	if tension!=null: tension.stop(); tension.stream=null
	for voice in voices: voice.stop(); voice.stream=null
	cues.clear()
