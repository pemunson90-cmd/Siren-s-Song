extends SceneTree
# SETDEPTH: new optional settings keys, bus mapping, haptic strength and coverage, gesture presets.
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Depth=preload("res://src/presentation/frontend/settings_depth.gd")
const Sound=preload("res://src/audio/soundscape.gd")
const Gesture=preload("res://src/input/map_gesture.gd")
const Observer=preload("res://src/presentation/accessibility/cue_observer.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func send_of(bus):
	return AudioServer.get_bus_send(AudioServer.get_bus_index(bus))
func run():
	var old={"version":1,"master":0.7,"music":0.3,"effects":0.6,"text_scale":1.3,"frame_cap":30,"haptics":false}
	var loaded=Store.sanitize(old)
	check(loaded.master==0.7 and loaded.music==0.3 and loaded.effects==0.6 and not loaded.haptics,"old file keeps its values")
	for key in ["alerts","messages","haptic_strength","drag_preset","hold_preset"]:
		check(loaded[key]==Store.DEFAULTS[key],"old file loads new key at default: "+key)
	check(Store.DEFAULTS.alerts==1.0 and Store.DEFAULTS.messages==1.0,"new bus levels default to 0 dB so the mix is unchanged")
	for bad in ["x",-1,7,2.5,NAN,INF,true,null,[],{}]:
		var v=Store.sanitize({"haptic_strength":bad,"drag_preset":bad,"hold_preset":bad,"alerts":bad,"messages":bad})
		check(v.haptic_strength==2 and v.drag_preset==1 and v.hold_preset==1,"corrupt preset falls back: "+str(bad))
		if not ((bad is int or bad is float) and is_finite(float(bad))):
			check(v.alerts==1.0 and v.messages==1.0,"corrupt level falls back: "+str(bad))
	check(Store.sanitize({"haptic_strength":0}).haptic_strength==2 and Store.sanitize({"haptic_strength":4}).haptic_strength==2,"strength outside 1..3 rejected")
	check(Store.sanitize({"alerts":9.0}).alerts==1.0 and Store.sanitize({"alerts":-3}).alerts==0.0,"levels clamp to 0..1")
	var chosen=Store.sanitize({"haptic_strength":3.0,"drag_preset":0,"hold_preset":2.0,"alerts":0.25,"messages":0.0})
	check(chosen.haptic_strength==3 and chosen.drag_preset==0 and chosen.hold_preset==2 and chosen.alerts==0.25 and chosen.messages==0.0,"valid choices accepted")
	var path="user://settings-depth-test.json"
	for suffix in ["",".tmp"]:DirAccess.remove_absolute(path+suffix)
	var store=Store.new();store.path=path
	check(store.save_settings(chosen) and store.load_settings()==chosen,"new keys round trip through the store")
	var damaged=FileAccess.open(path,FileAccess.WRITE);damaged.store_string('{"alerts":"loud","haptic_strength":[1],"hold_preset":9}');damaged.close()
	var recovered=store.load_settings()
	check(recovered.alerts==1.0 and recovered.haptic_strength==2 and recovered.hold_preset==1,"corrupt new keys on disk fall back to defaults")
	for suffix in ["",".tmp"]:DirAccess.remove_absolute(path+suffix)
	# Haptic strength scales pulse length; the normal level equals the previous fixed pulse.
	check(Depth.pulse_ms(45,{"haptic_strength":2})==45,"normal strength keeps the 45 ms pulse")
	var light=Depth.pulse_ms(45,{"haptic_strength":1});var strong=Depth.pulse_ms(45,{"haptic_strength":3})
	check(light<45 and strong>45 and light>0,"light is shorter and strong is longer than normal")
	for cue in ["lock","sweep_received","film_empty","loss","hull_light","hull_medium","hull_heavy","snare","knock","extraction","camera"]:
		check(Depth.haptic_cue(cue),"haptic coverage includes "+cue)
	check(not Depth.haptic_cue("ping") and not Depth.haptic_cue("develop"),"unrelated cues stay without a pulse")
	Settings.apply(Store.DEFAULTS)
	var observer=Observer.new()
	for cue in ["camera","knock","extraction","hull_heavy"]:observer.note(cue,1.0)
	check(observer.pulse_requests==4,"new coverage requests a pulse through the existing observer path")
	Settings.apply(Store.sanitize({"haptics":false}))
	var quiet=Observer.new();quiet.note("camera",1.0);quiet.note("lock",1.0)
	check(quiet.pulse_requests==0 and not Settings.vibrate(10),"haptics off blocks every pulse including new coverage")
	# Gesture presets: the normal preset is today's constants.
	Settings.apply(Store.DEFAULTS)
	check(Gesture.threshold()==Gesture.DRAG_THRESHOLD and Depth.hold_seconds(Settings.current)==0.5,"default presets keep today's numbers")
	Settings.apply(Store.sanitize({"drag_preset":2,"hold_preset":2}))
	var gesture=Gesture.new();gesture.feed("press",0,Vector2.ZERO)
	check(gesture.feed("release",0,Vector2(20,0)).has("tap"),"relaxed drag preset still counts a 20 px wobble as a tap")
	Settings.apply(Store.sanitize({"drag_preset":0}))
	gesture.feed("press",0,Vector2.ZERO)
	var precise=gesture.feed("move",0,Vector2(12,0))
	check(precise.has("pan"),"precise drag preset starts a drag at 12 px")
	check(Depth.hold_seconds({"hold_preset":0})<0.5 and Depth.hold_seconds({"hold_preset":2})>0.5,"hold presets bracket the default")
	Settings.apply(Store.DEFAULTS)
	# Bus mapping: categories route under effects, levels reach their AudioServer buses.
	var sound=Sound.new();root.add_child(sound);await process_frame;await process_frame
	for bus in [Sound.ALERTS_BUS,Sound.MESSAGES_BUS]:
		check(AudioServer.get_bus_index(bus)>=0 and send_of(bus)==Sound.EFFECTS_BUS,bus+" exists under the effects bus")
	check(send_of(Sound.AMBIENCE_BUS)=="Master" and send_of(Sound.EFFECTS_BUS)=="Master","ambience and effects stay under Master")
	sound.apply_bus_levels()
	for bus in [Sound.ALERTS_BUS,Sound.MESSAGES_BUS]:
		check(is_zero_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))),bus+" default is 0 dB")
	sound.alerts_volume=0.5;sound.messages_volume=0.0;sound.apply_bus_levels()
	var alerts_index=AudioServer.get_bus_index(Sound.ALERTS_BUS);var messages_index=AudioServer.get_bus_index(Sound.MESSAGES_BUS)
	check(is_equal_approx(AudioServer.get_bus_volume_db(alerts_index),linear_to_db(0.5)) and not AudioServer.is_bus_mute(alerts_index),"alerts level maps to its bus")
	check(AudioServer.is_bus_mute(messages_index),"zero messages level mutes only its bus")
	sound._route_voice(0,"alert");check(send_of("SirenVoice0")==Sound.ALERTS_BUS,"alert cue routes to the alerts bus")
	sound._route_voice(0,"carrier_received");check(send_of("SirenVoice0")==Sound.MESSAGES_BUS,"received message routes to the messages bus")
	sound._route_voice(0,"ping");check(send_of("SirenVoice0")==Sound.EFFECTS_BUS,"equipment cue stays on the effects bus")
	check(sound.lock_voice.bus==Sound.ALERTS_BUS,"lock warning voice is an alert")
	Settings.apply(Store.DEFAULTS,null)
	sound.queue_free();await process_frame
	print("SETTINGS DEPTH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
