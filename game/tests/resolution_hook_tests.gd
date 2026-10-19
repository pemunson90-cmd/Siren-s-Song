extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func advance(sim,seconds:float):
 sim.paused=false
 for i in ceili(seconds*60):sim.advance(1.0/60)
func _initialize():
 # These local actor positions are mechanical fixtures, never earned-play proof.
 var gate=Sim.new();gate.start(12,"disruption")
 var center:Vector2=gate.mission.physical_gates[0].closed_shape.get_center()
 check(gate.blocked(center) and not gate.line_clear(Vector2(1780,2500),Vector2(1780,2000)),"closed authored gate physically blocks water and sight")
 gate.units[0].pos=gate.mission.objectives[0].pos;gate.command("emp")
 check(gate.command("camera"),"local actuator uses ordinary finite-duration command")
 advance(gate,4.1)
 check(gate.mission.physical_gates[0].opened and not gate.blocked(center),"actual actuator completion removes gate collision")
 check(not gate.navigation.is_point_solid(Vector2i(center/40)),"actuator rebuilds AStar grid occupancy in the opened passage")
 check(gate.line_clear(Vector2(1780,2500),Vector2(1780,2000)) and gate.acoustic_paths.clear(Vector2(1780,2500),Vector2(1780,2000)),"gate transition rebuilds actual sight and acoustic geometry")
 var restored=Sim.new();check(restored.restore(gate.snapshot()) and not restored.blocked(center),"restored opened gate rebuilds derived geometry before first tick")
 var bad=gate.snapshot();bad.mission.physical_gates[0].opened=false
 check(not Sim.valid_snapshot(bad),"phase cannot disagree with missing closed structure and captured actuator")
 var quiet=Sim.new();quiet.start(12);quiet.units[0].pos=quiet.mission.signal_sources[0].pos+Vector2(0,150)
 advance(quiet,0.1);quiet.command("camera");advance(quiet,4.1)
 check(quiet.all_records() and not quiet.mission.physical_gates[0].opened,"quiet witness recovery does not require optional sluice operation")
 var inactive=Sim.new();inactive.start(13);inactive.units[0].pos=inactive.mission.signal_sources[0].pos+Vector2(0,100);inactive.command("recon");advance(inactive,0.1)
 check(inactive.mission.expedition_facts.is_empty() and inactive.signal_readings().is_empty(),"inactive reply cannot be received or precisely surveyed before transmission")
 var tx=Sim.new();tx.start(13,"disruption");tx.units[0].pos=Vector2(1840,1080);tx.command("emp")
 check(tx.camera_context().ready,"Quietus can choose a clear settled origin anywhere inside the authored sector")
 check(tx.command("camera"),"sector transmission uses ordinary CAMERA command")
 advance(tx,5.9)
 check(not tx.mission.signal_sources[0].active and not tx.noises.any(func(n):return n.label=="WARNING CHAIN TRANSMISSION"),"partial work grants no response or completed emission")
 advance(tx,0.3)
 check(tx.mission.signal_sources[0].active,"complete local warning enables exactly its authored response")
 check(tx.noises.any(func(n):return n.label=="WARNING CHAIN TRANSMISSION" and n.pos==Vector2(1840,1080)),"finite transmission is emitted at actual chosen origin")
 advance(tx,0.8) # Existing 0.75s receiver clock must run after the completed transmission.
 check(not tx.signal_readings().is_empty() and tx.mission.expedition_facts.is_empty(),"eastern origin receives uncertain reply before any exact passive source fix")
 check(tx.camera_context().ready,"completed broadcast remains explicitly retryable without claiming reception")
 check(Sim.valid_snapshot(tx.snapshot()),"completed origin and activation save consistently")
 bad=tx.snapshot();bad.mission.signal_sources[0].active=false
 check(not Sim.valid_snapshot(bad),"response activation must agree with the completed warning")
 bad=tx.snapshot();bad.mission.objectives[0].erase("captured")
 check(not Sim.valid_snapshot(bad),"malformed transmitter save is rejected without executing incomplete operation data")
 print("RESOLUTION HOOKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
