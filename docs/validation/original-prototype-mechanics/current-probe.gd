extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
func _initialize(): call_deferred("run")
func setup():
 var s=Sim.new(); s.start(0,"survey"); s.mission.rocks=[]; s._build_navigation(); s.sirens=[s.sirens[0].duplicate(true)]
 s.units[0].pos=Vector2(300,800); s.units[0].vel=Vector2.ZERO
 s.units[1].alive=false; s.units[2].alive=false
 var e=s.sirens[0]; e.pos=Vector2(650,800); e.home=e.pos; e.goal=e.pos; e.route=[]; e.path_time=999.0; e.suspicion=0.0; e.lock=0.0; e.stun=0.0; e.target=-1; e.mode="PATROL"
 return s
func run():
 var out={"velocity_hearing":[],"stationary_detection":[],"sources_sha":OS.get_cmdline_user_args()}
 for speed in [0.0,42.0,50.0,50.01,78.0]:
  var s=setup(); s.units[0].vel=Vector2(speed,0); s._threats(0.01)
  out.velocity_hearing.append({"speed":speed,"distance":350,"suspicion":s.sirens[0].suspicion,"investigates":s.sirens[0].goal==s.units[0].pos,"target":s.sirens[0].target,"noise_events":s.noises.size()})
 for silent in [true,false]:
  var s=setup(); s.sirens[0].pos=Vector2(500,800); s.sirens[0].goal=s.sirens[0].pos; s.units[0].silent=silent; s._threats(0.01)
  out.stationary_detection.append({"silent":silent,"distance":200,"target":s.sirens[0].target,"lock":s.sirens[0].lock})
 var s=setup(); s.command("ping"); s._threats(0.01)
 out.ping={"investigates":s.sirens[0].goal==s.units[0].pos,"suspicion":s.sirens[0].suspicion,"noise_radius":s.noises[0].radius}
 s=setup(); s.sirens[0].pos=Vector2(400,800); s.sirens[0].lock=3.99; s.sirens[0].target=0; s._threats(0.02)
 out.beam={"hull":s.hull,"lock":s.sirens[0].lock}; s.sirens[0].stun=1.0; s._threats(1.0); out.stun={"hull":s.hull,"lock":s.sirens[0].lock,"target":s.sirens[0].target}
 s=setup(); s.paused=false; s.contacts={0:{"pos":s.sirens[0].pos,"lock":0.2,"time":s.elapsed}}
 var sound=Sound.new(); root.add_child(sound); sound.update(s,0.01)
 out.audio={"fresh_lock_alert_timer":sound.alert_timer,"voice_playing":sound.voices[0].playing,"engine_gain_42_silent":Sound.engine_gain(42,true),"engine_gain_78_cruise":Sound.engine_gain(78,false)}
 print("MECHANICS_AUDIT "+JSON.stringify(out)); sound.queue_free(); await process_frame; quit()
