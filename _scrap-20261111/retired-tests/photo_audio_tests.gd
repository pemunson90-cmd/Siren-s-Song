extends SceneTree
# Headless event/real-player checks. Source-known local exposure fixtures, not a journey.
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func fresh():
 var s=Sim.new();s.start(0);s.sirens=[];s.paused=false
 var o=s.mission.objectives[0];var u=s.units[0]
 u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.;u.angle=u.pos.angle_to_point(o.pos);u.vel=Vector2.ZERO
 return s
func advance(s,seconds):
 for n in ceili(seconds*60):s.advance(1./60)
func run():
 var sound=Sound.new();root.add_child(sound);await process_frame
 var s=fresh();sound.update(s,0.)
 var layer=sound.get_node_or_null("PhotoAudio")
 check(layer!=null,"the soundscape integrates its owned photo/audio layer")
 if layer==null:sound.queue_free();await process_frame;finish();return
 var Table=load("res://src/audio/photo_audio/photo_cue_table.gd")
 var Wave=load("res://src/audio/photo_audio/photo_wave.gd")
 for cue in Table.CUES:
  var wav=Wave.stream(cue);var peak=0.;var energy=0.
  for n in wav.data.size()/2:
   var sample=float(wav.data.decode_s16(n*2))/32768.;peak=maxf(peak,absf(sample));energy+=sample*sample
  check(wav.data.size()>2000 and peak<.8 and energy>.01,"a short procedural "+cue+" has signal and headroom")
  check(Table.CUES[cue].gain_db<=-18,"cue gain is quiet and table controlled")
 check(s.command("camera"),"an ordinary accepted PHOTO starts the exposure")
 var before=s.snapshot();sound.update(s,0.)
 check(layer.last_cues.has("shutter") and layer.voices.any(func(v):return v.playing and v.stream==Wave.stream("shutter")),"the actual shutter voice plays once")
 check(s.snapshot()==before,"audio leaves the simulation snapshot unchanged")
 var early=layer.hold.volume_db
 advance(s,2.);sound.update(s,2.)
 check(layer.hold.playing and layer.hold.volume_db>early,"held exposure tension builds from its real progress")
 s.paused=true;sound.update(s,0.)
 check(layer.hold.stream_paused and layer.voices.all(func(v):return not v.playing or v.stream_paused),"tactical pause freezes the new voices too")
 s.paused=false;advance(s,8.);sound.update(s,8.)
 check(layer.last_cues.has("develop") and not layer.hold.playing,"a completed plate develops and releases hold tension")
 sound.update(s,0.);check(layer.last_cues.is_empty(),"a refresh cannot replay a developed plate")
 var restored=Sim.new();check(restored.restore(s.snapshot()),"a photographed fixture reloads")
 sound.update(restored,0.);check(layer.last_cues.is_empty(),"loaded film does not replay historical developing")
 s=fresh();s.mission.photo_pricing={"film":[3,4,4]};sound.update(s,0.)
 for left in [2,1,0]:
  check(s.command("camera"),"the next exposure is accepted with film remaining")
  sound.update(s,0.)
  check(layer.last_cues.has("film_empty") if left==0 else layer.last_cues.has("film_low") if left==2 else not layer.last_cues.has("film_low"),"film warning acknowledges the budget edge only")
  s.command("route",{"point":s.units[0].pos+Vector2(5,0)})
 sound.update(s,0.);check(layer.last_cues.is_empty(),"empty-film warning does not repeat on refresh")
 s=fresh();sound.update(s,0.);sound.muted=true;s.command("camera");sound.update(s,0.)
 check(layer.last_cues.is_empty() and not layer.hold.playing and layer.voices.all(func(v):return not v.playing),"mute consumes changes without starting or queuing audio")
 sound.muted=false;sound.update(s,0.);check(layer.last_cues.is_empty(),"unmute does not replay the missed shutter")
 sound.effects_volume=0.;sound.update(s,0.)
 check(not layer.hold.playing,"zero effects volume silences new loops")
 sound.effects_volume=.8;sound.update(s,0.)
 sound.suspend()
 check(layer.hold.stream_paused and layer.voices.all(func(v):return not v.playing or v.stream_paused),"direct campaign suspension immediately freezes nested audio without another update")
 root.propagate_notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(layer.hold.stream_paused and layer.voices.all(func(v):return not v.playing or v.stream_paused),"Android suspension immediately freezes all new voices")
 sound.resume();root.propagate_notification(Node.NOTIFICATION_APPLICATION_RESUMED);sound.update(s,0.)
 check(not layer.hold.stream_paused,"foreground live exposure resumes its current tension")
 sound.update(s,0.,false)
 check(not layer.hold.playing and layer.voices.all(func(v):return not v.playing),"menus stop the photo layer without lingering tails")
 s=fresh();s.units[0].vel=Vector2(78,0);sound.update(s,0.)
 check(s.command("all_stop"),"actual ALL STOP is accepted")
 sound.update(s,0.);check(layer.last_cues.has("engine_down"),"ALL STOP gives a single engine spin-down cue")
 advance(s,1.);sound.update(s,1.)
 check(sound.engine.volume_db<=-79,"coasting with engines off becomes acoustically silent")
 for band in [0,2]:
  s=fresh();sound.update(s,0.)
  check(s.command("depth",{"band":band}),"an ordinary adjacent band change is accepted")
  sound.update(s,0.)
  check(layer.last_cues.has("pressure_shallow" if band==0 else "pressure_deep"),"pressure creak distinguishes shallower and deeper travel")
 sound.queue_free();s=null;await process_frame;await create_timer(.1).timeout
 finish()
func finish():
 print("PHOTO AUDIO CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
