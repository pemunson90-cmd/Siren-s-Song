extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var checks:=0
var failures:=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func fixture(kind:String):
 # Restorable endgame state, with a real beam, drone route and sonar clocks.
 # Production _tick decides the result; no stub or preassigned outcome.
 var s=Simulation.new();s.start(0)
 s.sirens[0].pos=Vector2(220,800);s.sirens[0].goal=s.units[0].pos;s.sirens[0].route=[];s.sirens[0].target=0;s.sirens[0].lock=4.0 if kind=="hull" else 0.0
 check(s.line_clear(s.sirens[0].pos,s.units[0].pos),"terminal fixture beam has physical line of sight")
 check(s.command("select",{"unit":1}) and s.command("route",{"point":Vector2(220,700)}) and s.command("select",{"unit":0}) and s.command("ping"),"terminal fixture uses actual route/select/sonar commands")
 if kind=="won":
  for objective in s.mission.objectives:objective.captured=true
 elif kind=="oxygen":s.oxygen=Simulation.STEP/36.0
 else:s.hull=0.15
 check(s.outcome.is_empty() and Simulation.valid_snapshot(s.snapshot()),"nonterminal fixture is a valid restorable game state")
 return s
func clone(source):
 var s=Simulation.new();check(s.restore(source.snapshot()),"paired state restores through actual simulation archive contract");return s
func state(s):
 return {"snapshot":s.snapshot(),"events":s.events.duplicate(true),"sensor_clock":s.sensor_clock,"message":s.message,"queue_mode":s.queue_mode,"pass_through":s.pass_through}
func _initialize():
 for kind in ["won","oxygen","hull"]:
  var seed=fixture(kind)
  for batch in [0.1,0.25]:
   var label="%s / %.2fs"%[kind,batch]
   var single=clone(seed);single.paused=false;single.advance(Simulation.STEP)
   check(single.outcome==("won" if kind=="won" else "lost") and is_equal_approx(single.elapsed,Simulation.STEP),label+" reaches the real terminal condition on first STEP")
   check(single.units[1].battery<seed.units[1].battery and single.ping_time<seed.ping_time and single.units[1].pos!=seed.units[1].pos,label+" terminal tick actually advances actors/resources before ending")
   if kind=="won":check(single.hull==seed.hull and single.oxygen<seed.oxygen and single.all_records(),"winning terminal tick consumes life support and extracts before a beam charges")
   var reference=clone(seed);reference.paused=false
   for n in ceili(batch/Simulation.STEP):reference.advance(Simulation.STEP)
   check(state(reference)==state(single),label+" successive STEP calls stop at first terminal state")
   var batched=clone(seed);batched.paused=false;batched.advance(batch)
   print("TERMINAL_PAIR ",label," batch_elapsed=",batched.elapsed," step_elapsed=",reference.elapsed," batch_hull=",batched.hull," step_hull=",reference.hull)
   check(state(batched)==state(reference),label+" batched snapshot/actors/clocks/events equal successive STEP calls")
   if kind=="won":check(batched.events.filter(func(event):return event.type=="extraction").size()==1 and reference.events.filter(func(event):return event.type=="extraction").size()==1,label+" emits exactly one extraction cue")
   var ended=state(batched);var remainder=batched.accumulator
   batched.advance(batch);batched.advance(10.0)
   check(state(batched)==ended and batched.accumulator==remainder,label+" later advance calls preserve the complete terminal state")
   var paused=clone(seed);var frozen=state(paused);var paused_accumulator=paused.accumulator
   paused.advance(batch)
   check(state(paused)==frozen and paused.accumulator==paused_accumulator,label+" tactical pause preserves state even beside a terminal threshold")
 print("TERMINAL TICK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
