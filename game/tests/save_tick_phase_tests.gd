extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(s,count:int):
 s.paused=false
 for n in count:s.advance(Sim.STEP)
func make():
 var s=Sim.new();s.start(0);return s
func _initialize():
 var source=make();step(source,47);source.paused=true
 print("SOURCE elapsed=",source.elapsed," sensor_clock=",source.sensor_clock," accumulator=",source.accumulator)
 var saved=source.snapshot()
 check(saved.has("tick_phase"),"new saves retain both fixed-step and receiver phases")
 var fresh=Sim.new();check(fresh.restore(saved),"fresh instance restores phase-bearing snapshot")
 var reused=make();step(reused,43);check(reused.restore(saved),"used instance restores phase-bearing snapshot")
 check(fresh.sensor_clock==source.sensor_clock and reused.sensor_clock==source.sensor_clock,"fresh and reused restore retain the actual sensor phase")
 check(fresh.snapshot()==saved and reused.snapshot()==saved,"paused phase-bearing snapshot remains exact")
 source.advance(0.2);fresh.advance(0.2);reused.advance(0.2)
 check(source.snapshot()==saved and fresh.snapshot()==saved and reused.snapshot()==saved,"pause consumes neither fractional time nor receiver phase")
 # Mechanical sensor fixture, not an earned campaign journey. An ordinary
 # SCOUT order must brake on this craft's actual first received contact.
 var scout=make();step(scout,47);scout.paused=true
 scout.sirens[0].pos=Vector2(280,700);scout.sirens[0].stun=10.0
 scout.command("select",{"unit":1});scout.command("route",{"point":Vector2(340,700)});scout.command("contact_hold")
 var copy=Sim.new();check(copy.restore(scout.snapshot()),"SCOUT contact fixture restores")
 step(scout,2);step(copy,2)
 print("SCOUT original_contacts=",scout.contacts," restored_contacts=",copy.contacts," original_hold=",scout.units[1].hold," restored_hold=",copy.units[1].hold)
 check(scout.contacts==copy.contacts and scout.units[1]==copy.units[1],"same next frames preserve actual contact acquisition and SCOUT braking")
 step(scout,18);step(copy,18)
 check(scout.snapshot()==copy.snapshot(),"receiver phase preserves complete future state after the contact handoff")
 var fractional=make();fractional.paused=false;fractional.advance(Sim.STEP*0.4);fractional.paused=true
 var half=fractional.snapshot();var fraction_copy=Sim.new();check(fraction_copy.restore(half),"subtick snapshot restores")
 check(fraction_copy.accumulator==fractional.accumulator,"fractional elapsed frame survives save")
 fractional.paused=false;fraction_copy.paused=false;fractional.advance(Sim.STEP*0.7);fraction_copy.advance(Sim.STEP*0.7)
 print("FRACTION original_elapsed=",fractional.elapsed," restored_elapsed=",fraction_copy.elapsed)
 check(fractional.snapshot()==fraction_copy.snapshot(),"same fractional next frame executes the same fixed tick")
 var near=make();near.paused=false;near.advance(Sim.STEP-0.00000005);near.paused=true
 check(near.accumulator<0 and near.accumulator>=-0.0000001,"actual epsilon boundary produces a legitimate negative remainder")
 var near_copy=Sim.new();check(near_copy.restore(near.snapshot()) and near_copy.accumulator==near.accumulator,"negative epsilon remainder restores without clamping")
 step(near,1);step(near_copy,1);check(near.snapshot()==near_copy.snapshot(),"epsilon-edge future remains exact")
 # Canonical camera completion must also land on the same next fixed tick.
 var camera=make();camera.units[0].pos=Vector2(1300,500)
 check(camera.command("camera"),"ordinary camera begins in clear local fixture")
 step(camera,240);camera.advance(Sim.STEP*0.4);camera.paused=true
 var camera_copy=Sim.new();check(camera_copy.restore(camera.snapshot()),"fractional in-flight camera restores")
 camera.paused=false;camera_copy.paused=false;camera.advance(Sim.STEP*0.7);camera_copy.advance(Sim.STEP*0.7)
 check(camera.mission.objectives[0].captured and camera_copy.mission.objectives[0].captured and camera.snapshot()==camera_copy.snapshot(),"fractional continuation preserves canonical evidence completion tick")
 # A terminal tick discards its unused frame so STEP and batched endings
 # serialize the same clock while active fractional phase remains exact.
 var terminal=make();terminal.oxygen=0.0001;terminal.paused=false;terminal.advance(0.25);terminal.paused=true
 print("TERMINAL accumulator=",terminal.accumulator)
 var terminal_copy=Sim.new()
 check(terminal.outcome=="lost" and terminal.accumulator==0 and terminal_copy.restore(terminal.snapshot()) and terminal_copy.accumulator==0,"terminal frame discards unused time and round-trips a canonical ended clock")
 var isolation=make();step(isolation,47);isolation.start(0)
 check(isolation.sensor_clock==0 and isolation.accumulator==0 and isolation.snapshot()==make().snapshot(),"new mission phase is independent of prior mission ticks")
 # Absence means the old phase is unknowable. Keep the old snapshot shape;
 # deterministic zero fallback prevents any previous instance leaking in.
 var legacy=saved.duplicate(true);legacy.erase("tick_phase")
 var old_fresh=Sim.new();var old_reused=make();step(old_reused,43)
 check(old_fresh.restore(legacy) and old_reused.restore(legacy),"legacy absent-phase saves remain accepted")
 check(old_fresh.snapshot()==legacy and old_reused.snapshot()==legacy,"legacy absence round-trips without adding invented precision")
 check(old_fresh.sensor_clock==0 and old_reused.sensor_clock==0 and old_fresh.accumulator==0 and old_reused.accumulator==0,"legacy fallback cannot inherit another dive's phase")
 step(old_fresh,12);step(old_reused,12);check(old_fresh.snapshot()==old_reused.snapshot(),"legacy fresh and reused restore have the same deterministic future")
 for value in [null,{},[],{"sensor_clock":0.1},{"sensor_clock":0.1,"accumulator":0.0,"extra":1},{"sensor_clock":NAN,"accumulator":0.0},{"sensor_clock":INF,"accumulator":0.0},{"sensor_clock":-0.01,"accumulator":0.0},{"sensor_clock":0.151,"accumulator":0.0},{"sensor_clock":true,"accumulator":0.0},{"sensor_clock":0.1,"accumulator":-0.00000011},{"sensor_clock":0.1,"accumulator":Sim.STEP},{"sensor_clock":0.1,"accumulator":INF}]:
  var bad=saved.duplicate(true);bad["tick_phase"]=value
  check(not Sim.valid_snapshot(bad),"malformed or out-of-range phase rejected: "+str(value))
 var bad_terminal=terminal.snapshot();bad_terminal.tick_phase.accumulator=0.250001
 check(not Sim.valid_snapshot(bad_terminal),"terminal unused frame remains bounded by actual advance cap")
 var atomic=source.snapshot();var invalid=atomic.duplicate(true);invalid.tick_phase.sensor_clock=INF
 check(not source.restore(invalid) and source.snapshot()==atomic,"invalid phase restore cannot mutate current state or clocks")
 var legacy_exact=true
 for id in range(11):
  var old_world=Sim.new();old_world.start(id);var old_save=old_world.snapshot();old_save.erase("tick_phase")
  var old_copy=Sim.new();legacy_exact=legacy_exact and old_copy.restore(old_save) and old_copy.snapshot()==old_save
 check(legacy_exact,"all old0..10 absent-phase snapshot shapes remain exact")
 var archive={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","active":half}
 var store=Store.new();store.path="user://save-tick-phase-test.save"
 check(store.save(archive),"phase travels through actual checksummed SaveStore")
 var loaded=store.load_game();check(not loaded.is_empty() and loaded.active==half,"disk round-trip preserves fractional phase exactly")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 # Preserve the existing ten-tick interval, including its float residual.
 var cadence=make();var observations=[];var prior=0.0
 for i in 31:
  step(cadence,1)
  if cadence.sensor_clock>prior:observations.append(i+1)
  prior=cadence.sensor_clock
 check(observations==[1,11,21,31],"existing actual sensor interval is not retuned")
 print("SAVE TICK PHASE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
