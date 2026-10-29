extends Node
const HuntPressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const HuntTable=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const RegionAudioTable=preload("res://src/audio/region_audio_table.gd")
const RATE := 22050
const AMBIENCE_BUS := "SirenAmbience"
const EFFECTS_BUS := "SirenEffects"
const ALERTS_BUS := "SirenAlerts" # SETDEPTH: independent Master child; threat cues.
const MESSAGES_BUS := "SirenMessages" # SETDEPTH: independent Master child; received messages.
const Depth=preload("res://src/presentation/frontend/settings_depth.gd")
const ATTRIBUTION := preload("res://assets/audio/attribution.tres")
var music_volume := 0.5
var effects_volume := 0.8
var alerts_volume := 0.8
var messages_volume := 0.8
var muted := false
var night_mode := false
var region_mission_id := ""
var region_clock := -1.0
var ambience_base_db := -17.0
var ambience: AudioStreamPlayer
var engine: AudioStreamPlayer
var tension: AudioStreamPlayer
var tension_level := 0.0
var last_clock := -1.0
var voices: Array=[]
var panners: Array=[]
var cues: Dictionary={}
var accessibility=preload("res://src/presentation/accessibility/cue_observer.gd").new()
var received_cues=preload("res://src/audio/received_cues.gd").new()
var heartbeat_timer := 0.0
var lock_voice: AudioStreamPlayer
var lock_interval := .7
var lock_next := -1.0
var lock_source := -1
var lock_clock := -1.0
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
		AudioServer.add_bus(); index=AudioServer.bus_count-1; AudioServer.set_bus_name(index,name)
	AudioServer.set_bus_send(index,send_to)
	return index
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	set_meta("audio_attribution",ATTRIBUTION)
	_bus(AMBIENCE_BUS); _bus(EFFECTS_BUS)
	if Depth.ENABLED: _bus(ALERTS_BUS); _bus(MESSAGES_BUS)
	var guarded=false
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0,i).resource_name=="SirenPeakGuard": guarded=true
	if not guarded:
		var limiter=AudioEffectLimiter.new(); limiter.resource_name="SirenPeakGuard"; limiter.threshold_db=-3; limiter.ceiling_db=-1; AudioServer.add_bus_effect(0,limiter)
	_sync_night_mode()
	for cue in ["ping","camera","emp","knock","snare","salvage","record","loss","extraction","alert","recon","decoy","creak","beam","factory","carrier_received","return_received","sweep_received","heartbeat","berth_release","plant_switch"]: cues[cue]=stream(cue)
	cues["hunt_stage"]=preload("res://src/audio/photo_audio/photo_wave.gd").stream(HuntTable.CUE_SOURCE)
	ambience=AudioStreamPlayer.new(); ambience.stream=stream("ambience"); ambience.bus=AMBIENCE_BUS; ambience.volume_db=-17; add_child(ambience); ambience.play()
	tension=AudioStreamPlayer.new(); tension.stream=stream("tension"); tension.bus=AMBIENCE_BUS; tension.volume_db=-80; add_child(tension); tension.play()
	engine=AudioStreamPlayer.new(); engine.stream=stream("engine"); engine.bus=EFFECTS_BUS; engine.volume_db=-80; add_child(engine); engine.play()
	for bed in [ambience,engine,tension]: bed.stream_paused=true
	lock_voice=AudioStreamPlayer.new();lock_voice.stream=stream("alert");lock_voice.bus=ALERTS_BUS if Depth.ENABLED else EFFECTS_BUS;lock_voice.volume_db=-6;add_child(lock_voice)
	for n in 5:
		var bus_name="SirenVoice%d"%n; var index=_bus(bus_name,EFFECTS_BUS)
		var panner: AudioEffectPanner
		if AudioServer.get_bus_effect_count(index)==0:
			panner=AudioEffectPanner.new(); AudioServer.add_bus_effect(index,panner)
		else: panner=AudioServer.get_bus_effect(index,0)
		panners.append(panner)
		var voice=AudioStreamPlayer.new(); voice.bus=bus_name; voice.volume_db=-7.5; add_child(voice); voices.append(voice)
func _sync_night_mode() -> void:
	var enabled=night_mode and RegionAudioTable.enabled
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0,i).resource_name=="SirenNightMode":
			if not enabled:AudioServer.remove_bus_effect(0,i)
			return
	if not enabled:return
	var compressor=AudioEffectCompressor.new()
	compressor.resource_name="SirenNightMode"
	compressor.threshold=-24.0; compressor.ratio=3.0; compressor.gain=4.0
	compressor.attack_us=20000.0; compressor.release_ms=300.0
	var before=AudioServer.get_bus_effect_count(0)
	for i in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0,i).resource_name=="SirenPeakGuard":before=i;break
	AudioServer.add_bus_effect(0,compressor,before)
func _sync_region(mission: Dictionary,elapsed: float,frozen: bool) -> void:
	# Only mission identity and its public regional presentation key select this bed.
	var bed=RegionAudioTable.bed(mission)
	var recording: AudioStream=bed.get("stream",stream("ambience"))
	var mission_id=str(mission.get("id",""))
	if ambience.stream!=recording or mission_id!=region_mission_id or elapsed<region_clock:
		ambience.stream=recording
		if ambience.is_inside_tree():ambience.play()
		ambience.stream_paused=frozen
	region_mission_id=mission_id; region_clock=elapsed
	ambience_base_db=float(bed.get("gain_db",-17.0))
	_sync_night_mode()
func _lock_update(sim,frozen:bool,active:bool)->void:
	if lock_voice==null:return
	var frames=preload("res://src/presentation/lock_warning.gd").frames(sim) if active else []
	if sim.elapsed<lock_clock:lock_source=-1;lock_next=-1.
	lock_clock=sim.elapsed
	if frames.is_empty() or not cue_audible("alert"):
		lock_voice.stop();lock_source=-1;lock_next=-1.;return
	lock_voice.stream_paused=frozen
	if frozen:return
	var frame=frames[0]
	lock_interval=lerpf(.7,.16,frame.progress)
	lock_voice.pitch_scale=lerpf(1.15,2.,frame.progress)
	if lock_source!=frame.id or sim.elapsed>=lock_next:
		lock_voice.play();lock_next=sim.elapsed+lock_interval;lock_source=frame.id
	elif lock_voice.get_playback_position()>.09:
		lock_voice.stop()
func update(sim,dt: float,active_dive: bool=true) -> void:
	accessibility.observe(sim,active_dive and not system_suspended)
	var photo_engine=preload("res://src/audio/photo_audio/photo_audio.gd").sync(self,sim,dt,active_dive)
	preload("res://src/audio/event_cues/event_cues.gd").sync(self,sim,dt,active_dive)
	received_cues.observe_clock(sim.elapsed)
	if ambience==null: return
	apply_bus_levels()
	var frozen=sim.paused or not active_dive or system_suspended
	_sync_region(sim.mission,sim.elapsed,frozen)
	_lock_update(sim,frozen,active_dive)
	ambience.volume_db=ambience_base_db+HuntPressure.ambience_offset(sim.mission)
	ambience.stream_paused=frozen; engine.stream_paused=frozen
	if sim.elapsed<last_clock: tension_level=0.0
	last_clock=sim.elapsed
	if tension!=null:
		tension.stream_paused=frozen
		if not frozen:
			# Only the public, fresh received-contact threat channel is eligible.
			# Public Hunt affects only ambience/stage cues; hidden sources/locks/rosters stay unread.
			var target=clampf(float(sim.recon_feedback().get("threat",0.0)),0.0,1.0)
			var seconds=.7 if target>tension_level else 4.0
			tension_level=lerpf(tension_level,target,1.0-exp(-maxf(dt,0.0)/seconds))
		tension.volume_db=linear_to_db(maxf(.0001,tension_level*.24))
	if system_suspended or not active_dive:
		for voice in voices: voice.stream_paused=true
		sim.events.clear()
		return
	var speed: float=sim.propulsion_speed(sim.units[0])
	engine.volume_db=linear_to_db(maxf(0.0001,engine_gain(speed,sim.units[0].silent)*photo_engine)); engine.pitch_scale=0.75+speed/100.0
	if active_dive and not sim.paused:
		heartbeat_timer=maxf(0,heartbeat_timer-dt)
		var pressure=sim.recon_feedback()
		if pressure.threat>.1 and heartbeat_timer<=0:
			play("heartbeat");heartbeat_timer=.45 if pressure.hostile else .9
		creak_timer-=dt
		if creak_timer<=0: play("creak"); creak_timer=13.0+sin(sim.elapsed)*3
	for raw_event in sim.events:
		var event=preload("res://src/simulation/contact_identity.gd").event(sim,raw_event)
		if event.type=="hunt_stage" and not HuntPressure.active(sim.mission):continue
		if event.type=="plant_control":play("plant_switch")
		elif event.type in ["carrier_received","return_received","sweep_received"]:
			var received=received_cues.take(event,sim.selected,sim.elapsed,active_dive and not sim.paused)
			if not received.is_empty():_play_observed(received.cue,received.relative,event.get("sound",""))
		else:_play_observed(event.type,event.get("pos",sim.units[sim.selected].pos)-sim.units[sim.selected].pos,event.get("sound",""))
	# play() starts a fresh voice unpaused. Apply the tactical freeze after
	# event dispatch too, including a switch accepted while planning.
	for voice in voices: voice.stream_paused=frozen
	sim.events.clear()
# Event audio entry point: field tools and research call this with their cue id.
func event_cue(id: String) -> void:
	var layer=get_node_or_null("EventAudio")
	if layer!=null and layer.fire(id):accessibility.note(id,last_clock)
# Each split category owns its gain; Effects no longer gates alerts or messages.
func cue_audible(cue: String) -> bool:
	var category=Depth.bus_category(cue)
	var level=alerts_volume if category=="alerts" else (messages_volume if category=="messages" else effects_volume)
	return not muted and level>0
func play(cue: String,relative_position: Vector2=Vector2.ZERO) -> void:
	_play_recording(cue,relative_position,"")
func _play_observed(cue:String,relative_position:Vector2,sound_override:String)->void:
	# Keep the established public playback/observer seam for ordinary cues.
	if sound_override.is_empty() or sound_override==cue:play(cue,relative_position)
	else:_play_recording(cue,relative_position,sound_override)
func _play_recording(cue:String,relative_position:Vector2,sound_override:String)->void:
	if not cue_audible(cue) or system_suspended or not cues.has(cue): return
	var recording=cue if sound_override.is_empty() else sound_override
	if not cues.has(recording):return
	for i in voices.size():
		var voice=voices[i]
		if not voice.playing:
			if Depth.ENABLED: _route_voice(i,cue)
			panners[i].pan=clampf(relative_position.x/550.0,-0.8,0.8); voice.stream=cues[recording]; voice.play(); return
func apply_bus_levels() -> void:
	var ambience_index=AudioServer.get_bus_index(AMBIENCE_BUS); var effects_index=AudioServer.get_bus_index(EFFECTS_BUS)
	AudioServer.set_bus_mute(ambience_index,muted or music_volume<=0); AudioServer.set_bus_mute(effects_index,muted or effects_volume<=0)
	AudioServer.set_bus_volume_db(ambience_index,linear_to_db(maxf(0.001,music_volume)))
	AudioServer.set_bus_volume_db(effects_index,linear_to_db(maxf(0.001,effects_volume)))
	if Depth.ENABLED:
		for row in [[ALERTS_BUS,alerts_volume],[MESSAGES_BUS,messages_volume]]:
			var split=AudioServer.get_bus_index(row[0])
			if split<0:continue
			AudioServer.set_bus_mute(split,muted or row[1]<=0); AudioServer.set_bus_volume_db(split,linear_to_db(maxf(0.001,row[1])))
# SETDEPTH: an idle voice chain sends to the cue's category bus (alerts, messages or effects) before it plays.
func _route_voice(i: int,cue: String) -> void:
	var category=Depth.bus_category(cue)
	var target=ALERTS_BUS if category=="alerts" else (MESSAGES_BUS if category=="messages" else EFFECTS_BUS)
	var index=AudioServer.get_bus_index("SirenVoice%d"%i)
	if index>=0 and AudioServer.get_bus_index(target)>=0: AudioServer.set_bus_send(index,target)
func suspend() -> void:
	system_suspended=true
	if lock_voice!=null:lock_voice.stream_paused=true
	if ambience!=null: ambience.stream_paused=true
	if engine!=null: engine.stream_paused=true
	if tension!=null: tension.stream_paused=true
	# Module-owned players obey direct suspension too (for example entering a challenge).
	for voice in find_children("*","AudioStreamPlayer",true,false): voice.stream_paused=true
func resume() -> void: system_suspended=false
func _exit_tree() -> void:
	if lock_voice!=null:lock_voice.stop();lock_voice.stream=null
	if ambience!=null: ambience.stop(); ambience.stream=null
	if engine!=null: engine.stop(); engine.stream=null
	if tension!=null: tension.stop(); tension.stream=null
	for voice in voices: voice.stop(); voice.stream=null
	cues.clear()
	# stop() queues fade-out/deletion on the audio thread. Finish its pending
	# mix block before a rapid scene/application exit releases imported WAVs.
	# This bounded wait runs only during teardown, never during play or pause.
	var drain_seconds=clampf(AudioServer.get_time_to_next_mix(),0.0,.1)+.03
	OS.delay_usec(int(drain_seconds*1000000.0))
