extends SceneTree
# Event cue layer: hull severity tiers, survivor/artifact observation, rate limit, off switch.
const Sim=preload("res://src/simulation/simulation.gd")
const Sound=preload("res://src/audio/soundscape.gd")
const Table=preload("res://src/audio/event_cues/event_cue_table.gd")
const Text=preload("res://src/presentation/accessibility/cue_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func fresh():
 var s=Sim.new();s.start(0);s.sirens=[];s.paused=false;return s
func run():
 Settings.apply({"audio_captions":true,"haptics":false,"master":0.})
 for id in Table.CUES:check(Text.TEXT.has(id),"cue "+id+" has a caption row")
 check(Table.hull_cue(0.)=="" and Table.hull_cue(2.)=="hull_light" and Table.hull_cue(8.)=="hull_medium" and Table.hull_cue(30.)=="hull_heavy","hull tiers follow the removed percent")
 var sound=Sound.new();root.add_child(sound);await process_frame
 var s=fresh();sound.update(s,0.)
 var layer=sound.get_node_or_null("EventAudio")
 check(layer!=null,"the soundscape owns an event audio layer")
 if layer==null:sound.queue_free();await process_frame;finish();return
 sound.event_cue("not_a_tool");sound.event_cue("sonobuoy")
 check(layer.played==["sonobuoy"],"unknown ids are ignored and an unfired tool id plays by entry point")
 sound.event_cue("sonobuoy")
 check(layer.played==["sonobuoy"],"the repeat interval blocks an immediate repeat")
 s.hull-=20.;sound.update(s,0.)
 check(layer.played==["hull_heavy"],"a heavy collision plays the severe hull cue")
 check("Hull strain: severe" in sound.accessibility.text(),"the hull cue is captioned")
 sound.update(s,0.)
 check(layer.played.is_empty(),"a refresh does not replay the strike")
 s.hull-=8.;sound.update(s,0.)
 check(layer.played==["hull_medium"],"a lighter strike plays the lighter cue")
 var before=s.snapshot();s.hull-=1.;s.events=[{"type":"witness_landed","pos":Vector2.ZERO}];sound.update(s,0.)
 check(layer.played.size()==2 and "survivor_landed" in layer.played,"survivor landing plays with priority over a light strike")
 s.paused=true;s.hull-=30.;sound.update(s,0.)
 check(layer.played.is_empty(),"a frozen plan does not trigger cues")
 s.paused=false;sound.update(s,0.);check(layer.played.is_empty(),"unfreezing does not replay what was held")
 check(s.snapshot()!=before,"fixture sanity: the simulation was edited by the test, not by audio")
 s.mission.module_recovery={"modules":{"a":{"state":"salvage"}}};sound.update(s,0.)
 s.mission.module_recovery.modules.a.state="cargo";sound.update(s,0.)
 check(layer.played==["artifact_secured"],"a module reaching cargo plays the secured cue")
 sound.update(s,0.);check(layer.played.is_empty(),"a carried module does not replay")
 s.mission.module_recovery.erase("modules");s.mission.erase("module_recovery")
 sound.muted=true;s.hull-=10.;sound.update(s,0.)
 check(layer.played.is_empty(),"mute consumes the change silently")
 sound.muted=false
 Table.enabled=false
 var off=Sound.new();root.add_child(off);await process_frame
 off.update(fresh(),0.)
 check(off.get_node_or_null("EventAudio")==null,"disabled switch creates no layer")
 Table.enabled=true
 off.queue_free();sound.queue_free();await process_frame;await create_timer(.1).timeout
 finish()
func finish():
 print("EVENT CUE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
