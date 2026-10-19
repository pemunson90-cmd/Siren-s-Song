extends Node
const RATE := 22050
var music_volume := 0.5
var effects_volume := 0.8
var muted := false
var ambience: AudioStreamPlayer
var engine: AudioStreamPlayer
var voices: Array=[]
var cues: Dictionary={}
var alert_timer := 0.0
static func samples(cue: String) -> PackedFloat32Array:
	var duration=8.0 if cue=="ambience" else (2.0 if cue=="loss" else 1.1)
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
			"ping": value=(sin(TAU*(710*time-110*time*time))+sin(TAU*1240*time)*0.2)*0.28*envelope
			"camera": value=(sin(TAU*170*time)*0.12+rng.randf_range(-0.2,0.2))*envelope
			"emp": value=(sin(TAU*(140*time-45*time*time))*0.3+rng.randf_range(-0.14,0.14))*envelope
			"loss": value=(sin(TAU*(170*time-30*time*time))*0.3+sin(TAU*63*time)*0.12)*envelope
			"record", "extraction": value=(sin(TAU*440*time)+sin(TAU*554.37*time)*0.6+sin(TAU*659.25*time)*0.4)*0.15*envelope
			_: value=(sin(TAU*210*time)+sin(TAU*215*time))*0.16*envelope
		result[n]=value
	return result
static func stream(cue: String) -> AudioStreamWAV:
	var values=samples(cue); var bytes=PackedByteArray(); bytes.resize(values.size()*2)
	for n in values.size(): bytes.encode_s16(n*2,int(clampf(values[n],-0.95,0.95)*32767))
	var wav=AudioStreamWAV.new(); wav.format=AudioStreamWAV.FORMAT_16_BITS; wav.mix_rate=RATE; wav.data=bytes
	if cue=="ambience": wav.loop_mode=AudioStreamWAV.LOOP_FORWARD; wav.loop_end=values.size()
	return wav
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	for cue in ["ping","camera","emp","record","loss","extraction","alert","recon","decoy"]: cues[cue]=stream(cue)
	ambience=AudioStreamPlayer.new(); ambience.stream=stream("ambience"); add_child(ambience); ambience.play()
	for n in 5:
		var voice=AudioStreamPlayer.new(); add_child(voice); voices.append(voice)
func update(sim,dt: float) -> void:
	if ambience==null: return
	ambience.volume_db=linear_to_db(maxf(0.001,0 if muted else music_volume))
	ambience.stream_paused=sim.paused
	for voice in voices:
		voice.volume_db=linear_to_db(maxf(0.001,0 if muted else effects_volume*0.65))
		voice.stream_paused=sim.paused
	alert_timer=maxf(0,alert_timer-dt)
	for contact in sim.contacts.values():
		if contact.lock>0.1 and sim.elapsed-contact.time<0.4 and alert_timer<=0 and not sim.paused:
			play("alert"); alert_timer=3.0
	for event in sim.events: play(event.type)
	sim.events.clear()
func play(cue: String) -> void:
	if muted or not cues.has(cue): return
	for voice in voices:
		if not voice.playing: voice.stream=cues[cue]; voice.play(); return
func suspend() -> void:
	if ambience!=null: ambience.stream_paused=true
	for voice in voices: voice.stream_paused=true

func _exit_tree() -> void:
	if ambience!=null: ambience.stop(); ambience.stream=null
	for voice in voices: voice.stop(); voice.stream=null
	cues.clear()
