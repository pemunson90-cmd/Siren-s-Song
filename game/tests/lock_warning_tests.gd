extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var path="res://src/presentation/lock_warning.gd"
 check(ResourceLoader.exists(path),"lethal lock has a dedicated readable warning")
 if not ResourceLoader.exists(path):finish();return
 var Warning=load(path)
 var sim=Sim.new();sim.start(0);sim.paused=false;sim.elapsed=10.
 var contact={"pos":sim.units[0].pos+Vector2(80,0),"time":10.,"mode":"LOCKING","lock":.01,"target":0,"type":"patroller","source":"optical"}
 sim.contacts={0:contact}
 var warning=Warning.new();root.add_child(warning)
 var early=Warning.frames(sim)
 check(early.size()==1 and early[0].remaining>3.9,"warning starts at first observed lock, not after a threshold")
 var sound=Sound.new();root.add_child(sound);sound.update(sim,.01)
 check(sound.lock_voice.playing,"dedicated warning voice starts immediately")
 var pitch=sound.lock_voice.pitch_scale;var interval=sound.lock_interval
 contact.lock=3.5;sim.elapsed=10.8;contact.time=sim.elapsed;sound.update(sim,.01)
 check(sound.lock_voice.pitch_scale>pitch and sound.lock_interval<interval,"warning pitch rises and pulse interval shortens")
 check(sound.lock_voice.stream!=Sound.stream("heartbeat") and sound.lock_voice.stream!=Sound.stream("ping"),"warning uses a different sound from heartbeat and sonar")
 sim.paused=true;sound.update(sim,.1)
 check(sound.lock_voice.stream_paused,"tactical pause freezes the lock cue")
 sim.paused=false;contact.lock=0.;sound.update(sim,.01)
 check(not sound.lock_voice.playing and Warning.frames(sim).is_empty(),"broken lock immediately stops cue")
 contact.lock=4.;contact.mode="BEAM";sound.update(sim,.01)
 check(not sound.lock_voice.playing and Warning.frames(sim).is_empty(),"firing ends buildup cue")
 contact.mode="LOCKING";contact.lock=1.;contact.target=1;sound.update(sim,.01)
 check(not sound.lock_voice.playing and Warning.frames(sim).is_empty(),"drone locks never trigger Quietus warning")
 contact.target=-1;sound.update(sim,.01)
 check(Warning.frames(sim).is_empty(),"non-hostile contacts never trigger warning")
 contact.target=0;contact.mode="PATROL"
 check(Warning.frames(sim).is_empty(),"residual lock outside LOCKING cannot trigger warning")
 contact.mode="LOCKING";contact.time=sim.elapsed-.4
 check(Warning.frames(sim).is_empty(),"stale contacts never become live warnings")
 contact.time=sim.elapsed+.1
 check(Warning.frames(sim).is_empty(),"future observations are rejected")
 contact.time=sim.elapsed;contact.recipient_target=true
 check(Warning.frames(sim).is_empty(),"recipient target cannot alias Quietus")
 contact.erase("recipient_target");sim.mission.structures=[Rect2(sim.units[0].pos+Vector2(30,-30),Vector2(20,60))]
 check(Warning.frames(sim).is_empty(),"cover breaks a cached warning before another observation")
 sim.mission.structures=[]
 sim.mission.depth_geometry={0:{"structures":[Rect2(sim.units[0].pos+Vector2(30,-30),Vector2(20,60))]}}
 sim._use_band(0)
 check(Warning.frames(sim).size()==1,"selecting a drone in another band cannot hide Quietus warning")
 sim.mission.depth_geometry={};sim._use_band(1)
 sim.units[0].band=0
 check(Warning.frames(sim).is_empty(),"settled depth separation stops cached lock cues")
 sim.units[0].band=1
 for episode in 4:
  warning.update_state(sim,true)
  check(warning.show_hint==(episode<3),"hint appears only for first three episodes")
  warning.update_state(sim,true)
  check(warning.episodes==episode+1,"refresh does not consume another hint")
  contact.lock=0.;warning.update_state(sim,true);contact.lock=1.
 sound.update(sim,.01);sound.suspend()
 check(sound.lock_voice.stream_paused,"application suspension silences warning")
 sound.resume();sound.update(sim,.01,false)
 check(not sound.lock_voice.playing,"leaving mission stops warning")
 sound.queue_free();warning.queue_free();sim=null;await process_frame;await create_timer(.1).timeout
 finish()
func finish():
 print("LOCK WARNING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
