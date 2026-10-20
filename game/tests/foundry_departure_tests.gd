extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds:float):
 for n in roundi(seconds*60):s.advance(1.0/60)
func finish():print("FOUNDRY DEPARTURE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=Sim.new();s.start(3,"disruption")
 check(s.mission.get("departure_revision",0)==1,"fresh Foundry has one optional industrial departure")
 check(s.has_method("departure_feedback"),"industrial observations have a bounded player receiver interface")
 if not s.has_method("departure_feedback"):finish();return
 var legacy=s.snapshot();legacy.mission.erase("departure_revision")
 var restored=Sim.new();check(restored.restore(legacy) and restored.snapshot()==legacy,"legacy archives receive neither a new clock nor departure state")
 restored.paused=false;tick(restored,30)
 check(not restored.noises.any(func(n):return n.label=="DEEP MOTOR") and restored.departure_feedback().is_empty(),"old Foundry has no industrial source or cue")
 var paused=s.snapshot();s.advance(30);check(s.snapshot()==paused,"pause freezes event progression and all observations")
 # Receiver is placed in ordinary clear staging water. No listener truth reaches feedback.
 s.units[2].band=2;s.units[2].pos=Vector2(1040,860);s.elapsed=24.1
 var heard=s.departure_feedback()
 check(not heard.is_empty() and heard.moving and heard.receivers.has(2),"current moving motor is heard through supported thermal/terrain transmission")
 check(heard.get("lit",false) and heard.has("pos"),"lit deep hull is shown only inside own physical range and clear sight")
 s.units[2].pos=Vector2(1001,880)
 var bearing=s.departure_feedback()
 check(not bearing.is_empty() and not bearing.lit and not bearing.has("pos") and bearing.receivers.has(2),"audible remote motor supplies a bearing, never an exact hidden hull dot")
 var physical_clear=true
 for n in 141:
  var center=Vector2(1320,770).move_toward(Vector2(1540,880),n*2.0)
  for vertex in [Vector2(-36,-9),Vector2(24,-10),Vector2(48,0),Vector2(24,10),Vector2(-36,9),Vector2(-42,0)]:physical_clear=physical_clear and not s.blocked(center+vertex.rotated(Vector2(1320,770).angle_to_point(Vector2(1540,880))),2)
 check(physical_clear,"the authored projected hull footprint remains in clear water along its whole course")
 s.units[2].pos=Vector2(140,800);s.units[1].pos=Vector2(140,700)
 check(s.departure_feedback().is_empty(),"remote industrial phase and position are not globally revealed")
 s.units[2].pos=Vector2(1040,860);s.elapsed=25.1;s.paused=false;tick(s,0.1)
 var active=s.snapshot();var copy=Sim.new();check(copy.restore(active),"active departure restores existing elapsed and noise state")
 s.paused=false;copy.paused=false;tick(s,2);tick(copy,2)
 check(s.sirens==copy.sirens and s.noises==copy.noises and s.departure_feedback()==copy.departure_feedback(),"restoration preserves motor timing, actual guard reaction and permitted receiver report")
 tick(s,15);check(s.departure_feedback().is_empty() and not s.noises.any(func(n):return n.label=="DEEP MOTOR"),"one finite departure ends without recurring pulses or ghost hull")
 var bad=active.duplicate(true);bad.mission.departure_revision=2;check(not Sim.valid_snapshot(bad),"unknown departure revisions reject before recovery")
 bad=active.duplicate(true);bad.mission.id=4;check(not Sim.valid_snapshot(bad),"departure cannot activate in another chapter")
 bad=active.duplicate(true);bad.elapsed=NAN;check(not Sim.valid_snapshot(bad),"invalid event clock rejects before recovery")
 # Existing industrial timbre is reused only for an actual selected receiver.
 var audio=Sim.new();audio.start(3);audio.elapsed=24.0;audio.units[2].band=2;audio.units[2].pos=Vector2(1040,860);audio.selected=2;audio.paused=false;tick(audio,0.1)
 check(audio.events.filter(func(e):return e.get("industrial",false)).size()==1,"locally received departure has one restrained existing factory audio cue")
 tick(audio,1);check(audio.events.filter(func(e):return e.get("industrial",false)).size()==1,"industrial audio does not spam on each motor emission")
 var remote=Sim.new();remote.start(3);remote.elapsed=24.0;remote.paused=false;tick(remote,0.1)
 check(not remote.events.any(func(e):return e.get("industrial",false)),"unreceived industry does not create an omniscient player sound")
 # A bright real player target keeps ordinary beam acquisition despite the motor.
 var combat=Sim.new();combat.start(3);combat.elapsed=24.0;combat.units[0].band=2;combat.units[0].pos=Vector2(1200,840)
 combat.units[1].alive=false;combat.units[2].alive=false;combat.paused=false;tick(combat,0.2)
 check(combat.sirens[1].target==0 and combat.sirens[1].lock>0,"motor cannot override a legitimate optical lock")
 for chapter in [0,1,2,4,5]:
  var other=Sim.new();other.start(chapter);check(not other.mission.has("departure_revision") and other.departure_feedback().is_empty(),"chapter%d has no new industrial behavior"%chapter)
 finish()
