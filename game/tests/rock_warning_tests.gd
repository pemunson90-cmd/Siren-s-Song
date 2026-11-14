extends SceneTree
# WP-121 (Pat, 14 Nov 2026, rulings 1, 2, 4 and 5): the rock warning sounds and their captions, Okafor's debrief
# time, the route-end pause default and the Expedition operation order.
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
const RockWarning=preload("res://src/simulation/rock_warning.gd")
const Observer=preload("res://src/presentation/accessibility/cue_observer.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const Voices=preload("res://src/campaign/voices/voices.gd")
const Oxygen=preload("res://src/presentation/oxygen_reading.gd")
const RunState=preload("res://src/campaign/runs/run_state.gd")
const Meta=preload("res://src/campaign/operation_meta.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const TrialRules=preload("res://src/trial_rules.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
# A dive with one charted wall (x=700 from y=400 to 600) and Quietus at (500,500).
func fixture():
	# Operation 0 is a fully charted opening operation: its rock outlines are the charted faces. The authored rock is
	# replaced by one wall (x=700, y 400 to 600) so the test knows where it is.
	var s=Sim.new();s.start(0);s.sirens=[]
	s.rock_shapes=[PackedVector2Array([Vector2(700,400),Vector2(740,400),Vector2(740,600),Vector2(700,600)])]
	return place(s)
func place(s):
	s.units[0].pos=Vector2(500,500);s.units[0].vel=Vector2(30,0)
	return s
func run():
	Settings.apply({"audio_captions":true,"haptics":false,"master":0.})
	rock_cases()
	await sound_cases()
	caption_cases()
	debrief_words_cases()
	trial_and_order_cases()
	print("ROCK WARNING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func rock_cases():
	var s=fixture();var before=s.snapshot()
	var far=RockWarning.read(s,0)
	check(far.state=="" ,"rock 200 m ahead at 30 m/s is beyond the 150 m reach: silent")
	s.units[0].pos=Vector2(580,500)
	var near=RockWarning.read(s,0)
	check(near.state=="ramming" and near.distance>=119. and near.distance<=121.,"charted rock 120 m ahead at 30 m/s: RAMMING (speed would damage the hull): "+str(near))
	s.units[0].pos=Vector2(650,500)
	var closer=RockWarning.read(s,0)
	check(closer.state=="ramming" and closer.urgency>near.urgency,"closer rock is more urgent: "+str(near.urgency)+" < "+str(closer.urgency))
	check(s.collision_damage(30.)>0.0 and s.collision_damage(8.)==0.0,"the collision rule the warning reads: 30 m/s hurts, 8 m/s does not")
	s.units[0].vel=Vector2(8,0);s.units[0].pos=Vector2(670,500)
	var slow=RockWarning.read(s,0)
	check(slow.state=="rock","at 8 m/s (under the safe speed) the warning is proximity only: "+str(slow))
	s.units[0].vel=Vector2(-30,0)
	check(RockWarning.read(s,0).state=="","heading away from the rock is silent")
	s.units[0].vel=Vector2(0,30);s.units[0].pos=Vector2(500,300)
	check(RockWarning.read(s,0).state=="","moving past the wall, not at it, is silent")
	s.units[0].vel=Vector2(2,0);s.units[0].pos=Vector2(690,500)
	check(RockWarning.read(s,0).state=="","a craft barely moving is not heading anywhere")
	check(RockWarning.read(s,1).state=="","a drone aboard is silent")
	PlayerDive.launch_drones(s)
	s.units[1].pos=Vector2(580,500);s.units[1].vel=Vector2(30,0)
	check(RockWarning.read(s,1).state=="rock","a drone gets the proximity warning but never the hull-damage one (only Quietus has a hull)")
	s.units[0].vel=Vector2(30,0);s.units[0].pos=Vector2(300,500)
	var worst=RockWarning.worst(s)
	check(worst.unit==1,"the most urgent craft is chosen: "+str(worst))
	s.paused=true;before=s.snapshot();RockWarning.read(s,0);RockWarning.worst(s)
	check(s.snapshot()==before,"reading the warning changes nothing in the dive")
	# A discovered chart (a later operation): only rock the craft's sensors have measured counts; unmeasured rock is silent.
	var d=Sim.new();d.start(10);d.sirens=[]
	check(d.depth_charts[1]!=null,"operation 10 earns its chart")
	if d.depth_charts[1]!=null:
		d.rock_shapes=[PackedVector2Array([Vector2(700,400),Vector2(740,400),Vector2(740,600),Vector2(700,600)])]
		place(d);d.units[0].pos=Vector2(580,500)
		check(RockWarning.read(d,0).state=="","rock the chart has not measured stays silent")
		d.depth_charts[1].surface_segments.append(PackedVector2Array([Vector2(700,400),Vector2(700,600)]))
		check(RockWarning.read(d,0).state=="ramming","the same rock once measured warns")
func sound_cases():
	var sound=Sound.new();root.add_child(sound)
	check(sound.cues.has("rock_close") and sound.cues.has("rock_ram") and sound.cues.rock_close!=sound.cues.rock_ram,"two distinct warning sounds exist")
	var s=fixture();s.units[0].pos=Vector2(580,500);s.paused=false
	sound.update(s,0.1,true)
	check(sound.rock_state=="ramming" and sound.rock_plays==1 and sound.rock_voice.stream==sound.cues.rock_ram,"ramming sound starts")
	check(not s.paused,"the warning does not pause the dive")
	var slow_interval=sound.rock_next-s.elapsed
	s.units[0].pos=Vector2(660,500);s.elapsed=5.;sound.update(s,0.1,true)
	check(sound.rock_next-s.elapsed<slow_interval,"the beeps quicken as impact nears")
	s.units[0].vel=Vector2(8,0);s.units[0].pos=Vector2(680,500);s.elapsed=9.;sound.update(s,0.1,true)
	check(sound.rock_state=="rock" and sound.rock_voice.stream==sound.cues.rock_close,"slow approach uses the proximity sound")
	var plays=sound.rock_plays
	s.paused=true;s.elapsed=12.;sound.update(s,0.1,true)
	check(sound.rock_plays==plays and not sound.rock_voice.playing,"a paused dive is silent")
	s.paused=false;s.elapsed=14.;sound.alerts_volume=0.;sound.update(s,0.1,true)
	check(sound.rock_plays==plays and not sound.rock_voice.playing,"the Alerts volume at zero silences it")
	sound.alerts_volume=.8;sound.muted=true;s.elapsed=16.;sound.update(s,0.1,true)
	check(sound.rock_plays==plays,"mute silences it")
	sound.queue_free();await process_frame
func caption_cases():
	var s=fixture();var o=Observer.new();o.observe(s,true)
	s.paused=false;s.elapsed=1.;s.units[0].pos=Vector2(580,500);o.observe(s,true)
	check(o.emitted.has("ramming") and "RAMMING SPEED" in o.text(),"captions on: RAMMING SPEED is shown: "+o.text())
	s.elapsed=1.5;o.observe(s,true)
	check(o.emitted.is_empty(),"the caption is not repeated every frame")
	s.elapsed=5.;o.observe(s,true)
	check(o.emitted.has("ramming"),"a lasting warning is captioned again after 3 s")
	s.units[0].vel=Vector2(8,0);s.units[0].pos=Vector2(670,500);s.elapsed=6.;o.observe(s,true)
	check(o.emitted.has("rock_ahead") and "ROCK AHEAD" in o.text(),"slow approach: ROCK AHEAD")
	check(Words.TEXT.rock_ahead=="ROCK AHEAD" and Words.TEXT.ramming=="RAMMING SPEED","the words are defined once in hud_words.gd")
	Settings.apply({"audio_captions":false,"haptics":false,"master":0.})
	s.elapsed=20.;s.units[0].vel=Vector2(30,0);s.units[0].pos=Vector2(580,500);o.observe(s,true)
	check(o.text().is_empty(),"captions off: no caption text")
	Settings.apply({"audio_captions":true,"haptics":false,"master":0.})
func debrief_words_cases():
	var cases={-1:"Some margin",30:"Under a minute of margin",60:"One minute of margin",90:"A minute and a half of margin",
		149:"Two and a half minutes of margin",180:"Three minutes of margin",480:"Eight minutes of margin",
		590:"Ten minutes of margin",660:"Eleven minutes of margin",1500:"Twenty-five minutes of margin"}
	for seconds in cases:check(Voices.margin_phrase(seconds)==cases[seconds],"margin for %d s: %s"%[seconds,Voices.margin_phrase(seconds)])
	var s=Sim.new();s.start(0);s.oxygen=83.0
	var left=Oxygen.seconds_left(s)
	check(Oxygen.time_left(s)=="~%d:%02d"%[left/60,left%60],"time_left is written from seconds_left")
	var line=Voices.line(0,"debrief",left)
	check(line.begins_with("OKAFOR / BRANNOCK: Logged. ") and Voices.margin_phrase(left).to_lower() in line.to_lower() and line.ends_with("left, Quietus. That is how I like it."),"Okafor names the real time: "+line)
	check(not ("{margin}" in Voices.line(0,"debrief")) and "Eight minutes" not in Voices.line(0,"debrief"),"no figure leaves no stray token and no fixed eight minutes: "+Voices.line(0,"debrief"))
func trial_and_order_cases():
	TrialRules.reset()
	check(not TrialRules.pause_at_route_end(),"rule 3 (pause at route end) is off by default")
	TrialRules.override("PAUSE_AT_ROUTE_END",true)
	check(TrialRules.pause_at_route_end(),"the switch still works when set true")
	TrialRules.reset()
	for seed in [0,1,7,31,99,12345,2147483647]:
		var run=RunState.new_run(seed)
		var ops:Array=run.operations
		var sorted=ops.duplicate();sorted.sort()
		check(ops==sorted,"seed %d: operations run in Campaign order, easiest first: %s"%[seed,str(ops)])
		check(RunState.new_run(seed)==run,"seed %d is deterministic"%seed)
		var caps=ops.map(func(op):return Meta.hunt_cap(op))
		var rising=true
		for i in range(1,caps.size()):
			if caps[i]<caps[i-1]:rising=false
		check(rising,"seed %d: Hunt caps never fall along the order %s"%[seed,str(caps)])
