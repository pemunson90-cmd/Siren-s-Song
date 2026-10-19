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
func operation(sim)->Dictionary:
 return sim.operation_context().get("operations",[])[0]
func _initialize():
 # Mechanical local-position fixtures; no campaign/earned-play claim.
 var sim=Sim.new();sim.start(13,"disruption");sim.units[0].pos=Vector2(1840,1080)
 check(sim.operation_context().has("operations"),"known operation costs have a public adapter")
 if not sim.operation_context().has("operations"):quit(1);return
 var ready=operation(sim)
 check(ready.action=="TRANSMIT" and ready.duration==6 and ready.emission.radius==2000 and ready.emission.duration==8,"known transmission duration and emission cost match the physical action")
 check(not ready.has("last_completed") and not ready.has("attempt") and not sim.operation_context().has("transmission_origin"),"readiness never invents a completed send")
 sim.command("emp");sim.command("camera")
 var active=operation(sim)
 check(active.has("attempt") and active.attempt.origin==Vector2(1840,1080) and not active.has("last_completed"),"active attempt is distinct from emission history")
 check(not sim.acoustic_feedback().pulses.any(func(p):return p.label=="WARNING CHAIN TRANSMISSION"),"preparation cannot advertise the actual warning pulse before completion")
 var paused_snapshot=sim.snapshot();sim.advance(0.2)
 check(sim.snapshot()==paused_snapshot and not operation(sim).has("last_completed"),"paused active attempt cannot emit or advance preparation")
 var active_restore=Sim.new();check(active_restore.restore(paused_snapshot) and operation(active_restore).attempt==active.attempt,"fresh in-flight attempt restores without a fabricated completed origin")
 advance(sim,6.2)
 check(sim.acoustic_feedback().pulses.any(func(p):return p.label=="WARNING CHAIN TRANSMISSION" and p.pos==Vector2(1840,1080)),"actual completed warning pulse enters the public own-emission instrument")
 var first=operation(sim).last_completed.duplicate(true)
 check(first.pos==Vector2(1840,1080) and first.time>6 and first.time<=sim.elapsed and first.age>=0,"completion records actual origin and simulation time")
 var private_text=JSON.stringify(sim.operation_context())
 check(not private_text.contains("request_origin") and not private_text.contains("request_time") and not private_text.contains("reply_active") and not operation(sim).has("delivered"),"public own emission never certifies request delivery or response activation")
 var public_before=sim.operation_context().duplicate(true);sim.mission.signal_sources[0].active=false
 check(sim.operation_context()==public_before,"private reply activation cannot change own-emission feedback")
 sim.mission.signal_sources[0].active=true
 sim.units[0].pos=Vector2(2000,1200);sim.command("camera")
 advance(sim,1)
 var repeat=operation(sim)
 check(repeat.attempt.origin==Vector2(2000,1200) and repeat.last_completed.pos==first.pos and repeat.last_completed.time==first.time,"partial repeat cannot move or retime the last completed emission")
 check(not sim.acoustic_feedback().pulses.any(func(p):return p.label=="WARNING CHAIN TRANSMISSION" and p.pos==Vector2(2000,1200)),"incomplete repeat cannot announce an actual pulse at its new origin")
 check(sim.operation_context().transmission_origin==first.pos,"world marker remains the completed origin during a new attempt")
 sim.command("route",{"point":Vector2(2140,1220)})
 check(not operation(sim).has("attempt") and operation(sim).last_completed.pos==first.pos,"ordinary interrupted repeat preserves completed history")
 var restored=Sim.new();check(restored.restore(sim.snapshot()),"interrupted repeat metadata restores through the actual snapshot")
 check(operation(restored).last_completed.pos==first.pos and operation(restored).last_completed.time==first.time,"restore preserves prior completed origin/time")
 restored.command("camera");advance(restored,6.2)
 check(operation(restored).last_completed.pos==Vector2(2000,1200) and operation(restored).last_completed.time>first.time,"only a finished repeat replaces completed history")
 var old=sim.snapshot();old.mission.objectives[0].erase("completed_emission")
 var legacy=Sim.new();check(legacy.restore(old) and not operation(legacy).has("last_completed") and not legacy.operation_context().has("transmission_origin"),"old unpublished send without completion metadata reports unknown historical origin")
 var bad=restored.snapshot();bad.mission.objectives[0].completed_emission.time=restored.elapsed+1
 check(not Sim.valid_snapshot(bad),"future completed emission timestamp is rejected")
 bad=restored.snapshot();bad.mission.objectives[0].completed_emission.pos=Vector2(NAN,1)
 check(not Sim.valid_snapshot(bad),"nonfinite completed origin is rejected")
 var gate=Sim.new();gate.start(12,"disruption",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});gate.command("select",{"unit":1})
 var actuator=operation(gate)
 check(actuator.action=="ACTUATE" and actuator.duration==8 and actuator.start_emission.radius==520 and actuator.emission.radius==1100,"sampler actuator exposes both real start and completion costs")
 gate.command("select",{"unit":2});var fallback=operation(gate)
 check(fallback.unit==0 and fallback.duration==4 and not fallback.has("start_emission"),"unfitted selected drone previews eligible Quietus rather than inventing drone capability")
 gate.command("select",{"unit":0});gate.units[0].pos=gate.mission.objectives[0].pos;gate.command("emp");gate.command("camera");advance(gate,4.1)
 check(gate.acoustic_feedback().pulses.any(func(p):return p.label=="SERVICE SLUICE MOTOR" and p.pos==gate.mission.objectives[0].pos),"actual sluice motor pulse enters the same public own-emission instrument")
 var unchanged=true
 for id in range(11):
  var old_world=Sim.new();old_world.start(id);var before=old_world.snapshot();old_world.operation_context();var clone=Sim.new()
  unchanged=unchanged and old_world.snapshot()==before and clone.restore(before) and clone.snapshot()==before
 check(unchanged,"old0..10 snapshots and read-only feedback remain exact")
 print("OPERATION EMISSION FEEDBACK ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
