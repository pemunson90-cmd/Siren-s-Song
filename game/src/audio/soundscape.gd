extends Node
const RATE := 22050
const AMBIENCE_BUS := "SirenAmbience"
const EFFECTS_BUS := "SirenEffects"
var music_volume := 0.5
var effects_volume := 0.8
var muted := false
var ambience: AudioStreamPlayer
var engine: AudioStreamPlayer
var voices: Array=[]
var panners: Array=[]
var cues: Dictionary={}
var alert_timer := 0.0
var creak_timer := 11.0
var system_suspended := false
static func engine_gain(speed: float,silent: bool) -> float:
	return clampf(speed/78.0,0,1)*(0.13 if silent else 0.35)
static func samples(cue: String) -> PackedFloat32Array:
	var duration={"ambience":8.0,"engine":2.0,"creak":1.6,"beam":1.7,"loss":2.0,"decoy":2.5,"extraction":2.4}.get(cue,1.1)
	var result=PackedFloat32Array(); result.resize(int(RATE*duration))
	var rng=RandomNumberGenerator.new(); rng.seed=cue.hash()
	var filtered=0.0
	for n in result.size():
		var time=float(n)/RATE; var k=time/duration
		var envelope=sin(PI*k) if cue=="ambience" else minf(1,time*40)*exp(-k*5)
		var value=0.0
		match cue:
			"ambience":
				filtered=lerpf(filtered,rng.randf_range(-1,1),0.01)
				value=(sin(TAU*42*time)*0.11+sin(TAU*63*time+sin(time*0.4))*0.045+filtered*0.25)*envelope
			"engine":
				filtered=lerpf(filtered,rng.randf_range(-1,1),0.07)
				value=sin(TAU*44*time)*0.21+sin(TAU*88*time)*0.06+sin(TAU*132*time)*0.02+filtered*0.03*sin(PI*k)
			"creak":
				filtered=lerpf(filtered,rng.randf_range(-1,1),0.13)
				value=(sin(TAU*(73*time+0.6*sin(time*11)))*0.17+sin(TAU*147*time)*0.05+filtered*0.12)*sin(PI*k)*exp(-k*2)
			"beam": value=(sin(TAU*(430*time+13*time*time))*0.17+sin(TAU*437*time)*0.13+sin(TAU*960*time)*0.045)*envelope
			"ping": value=(sin(TAU*(710*time-110*time*time))+sin(TAU*1240*time)*0.2)*0.28*envelope
			"camera": value=(sin(TAU*170*time)*0.12+rng.randf_range(-0.2,0.2))*envelope
			"emp": value=(sin(TAU*(140*time-45*time*time))*0.3+rng.randf_range(-0.14,0.14))*envelope
			"recon": value=sin(TAU*(1200 if int(time/0.08)%2==0 else 960)*time)*0.19*envelope
			"decoy": value=(sin(TAU*90*time)*0.17+sin(TAU*174*time)*0.08)*(0.35+pow(cos(time*9),2)*0.65)*envelope
			"loss": value=(sin(TAU*(170*time-30*time*time))*0.3+sin(TAU*63*time)*0.12)*envelope
			"record": value=(sin(TAU*440*time)+sin(TAU*554.37*time)*0.6+sin(TAU*659.25*time)*0.4)*0.15*envelope
			"extraction": value=(sin(TAU*220*time)*0.11+sin(TAU*329.63*time)*0.08+sin(TAU*440*time)*0.06)*sin(PI*k)
			_: value=(sin(TAU*210*time)+sin(TAU*215*time))*0.16*envelope
		result[n]=value
	return result
static func stream(cue: String) -> AudioStreamWAV:
	var values=samples(cue); var bytes=PackedByteArray(); bytes.resize(values.size()*2)
	for n in values.size(): bytes.encode_s16(n*2,int(clampf(values[n],-0.95,0.95)*32767))
	var wav=AudioStreamWAV.new(); wav.format=AudioStreamWAV.FORMAT_16_BITS; wav.mix_rate=RATE; wav.data=bytes
	if cue in ["ambience","engine"]: wav.loop_mode=AudioStreamWAV.LOOP_FORWARD; wav.loop_end=values.size()
	return wav
func _bus(name: String,send_to: String="Master") -> int:
	var index=AudioServer.get_bus_index(name)
	if index<0:
		AudioServer.add_bus(); index=AudioServer.bus_count-1; AudioServer.set_bus_name(index,name); AudioServer.set_bus_send(index,send_to)
	return index
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	_bus(AMBIENCE_BUS); _bus(EFFECTS_BUS)
	var guarded=false
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0,i).resource_name=="SirenPeakGuard": guarded=true
	if not guarded:
		var limiter=AudioEffectLimiter.new(); limiter.resource_name="SirenPeakGuard"; limiter.threshold_db=-3; limiter.ceiling_db=-1; AudioServer.add_bus_effect(0,limiter)
	for cue in ["ping","camera","emp","record","loss","extraction","alert","recon","decoy","creak","beam"]: cues[cue]=stream(cue)
	ambience=AudioStreamPlayer.new(); ambience.stream=stream("ambience"); ambience.bus=AMBIENCE_BUS; add_child(ambience); ambience.play()
	engine=AudioStreamPlayer.new(); engine.stream=stream("engine"); engine.bus=EFFECTS_BUS; add_child(engine); engine.play()
	for n in 5:
		var bus_name="SirenVoice%d"%n; var index=_bus(bus_name,EFFECTS_BUS)
		var panner: AudioEffectPanner
		if AudioServer.get_bus_effect_count(index)==0:
			panner=AudioEffectPanner.new(); AudioServer.add_bus_effect(index,panner)
		else: panner=AudioServer.get_bus_effect(index,0)
		panners.append(panner)
		var voice=AudioStreamPlayer.new(); voice.bus=bus_name; voice.volume_db=-7.5; add_child(voice); voices.append(voice)
func update(sim,dt: float,active_dive: bool=true) -> void:
	if ambience==null or system_suspended: return
	var ambience_index=AudioServer.get_bus_index(AMBIENCE_BUS); var effects_index=AudioServer.get_bus_index(EFFECTS_BUS)
	AudioServer.set_bus_mute(ambience_index,muted or music_volume<=0); AudioServer.set_bus_mute(effects_index,muted or effects_volume<=0)
	AudioServer.set_bus_volume_db(ambience_index,linear_to_db(maxf(0.001,music_volume)))
	AudioServer.set_bus_volume_db(effects_index,linear_to_db(maxf(0.001,effects_volume)))
	var frozen=sim.paused or not active_dive
	ambience.stream_paused=frozen; engine.stream_paused=frozen
	var speed: float=sim.units[0].vel.length()
	engine.volume_db=linear_to_db(maxf(0.0001,engine_gain(speed,sim.units[0].silent))); engine.pitch_scale=0.75+speed/100.0
	for voice in voices: voice.stream_paused=sim.paused and active_dive
	alert_timer=maxf(0,alert_timer-dt)
	if active_dive and not sim.paused:
		creak_timer-=dt
		if creak_timer<=0: play("creak"); creak_timer=13.0+sin(sim.elapsed)*3
		for contact in sim.contacts.values():
			if contact.lock>0.1 and sim.elapsed-contact.time<0.4 and alert_timer<=0:
				play("alert",contact.pos-sim.units[sim.selected].pos); alert_timer=3.0
	for event in sim.events: play(event.type,event.get("pos",sim.units[sim.selected].pos)-sim.units[sim.selected].pos)
	sim.events.clear()
func play(cue: String,relative_position: Vector2=Vector2.ZERO) -> void:
	if muted or system_suspended or not cues.has(cue): return
	for i in voices.size():
		var voice=voices[i]
		if not voice.playing:
			panners[i].pan=clampf(relative_position.x/550.0,-0.8,0.8); voice.stream=cues[cue]; voice.play(); return
func suspend() -> void:
	system_suspended=true
	if ambience!=null: ambience.stream_paused=true
	if engine!=null: engine.stream_paused=true
	for voice in voices: voice.stream_paused=true
func resume() -> void: system_suspended=false
func _exit_tree() -> void:
	if ambience!=null: ambience.stop(); ambience.stream=null
	if engine!=null: engine.stop(); engine.stream=null
	for voice in voices: voice.stop(); voice.stream=null
	cues.clear()
