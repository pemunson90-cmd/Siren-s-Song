extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func state(s)->Dictionary:
 var d=s.snapshot();d["message"]=s.message;d["events"]=s.events.duplicate(true);d["accumulator"]=s.accumulator;d["sensor_clock"]=s.sensor_clock;d["queue_mode"]=s.queue_mode;d["pass_through"]=s.pass_through
 return d
func digest(s)->String:return var_to_bytes(state(s)).hex_encode().sha256_text()
func read_feedback(s):
 if not s.has_method("acoustic_feedback"):return
 var before=state(s)
 for n in 17:
  var f=s.acoustic_feedback()
  for kind in ["motion","pulses","responses"]:
   for row in f[kind]:row["pos"]=Vector2(-999,-999);row["name"]="MUTATED"
   f[kind].clear()
 check(state(s)==before,"feedback deep isolation")
func _initialize():call_deferred("run")
func run():
 for mission in 6:
  var s=Simulation.new();s.start(mission)
  var commands={0:["silent",{}],1:["route",{"point":Vector2(1300,510)}],50:["decoy",{}],180:["select",{"unit":1}],181:["route",{"point":Vector2(600,700)}],230:["decoy",{}],280:["ping",{}],350:["select",{"unit":0}],351:["hold",{}],370:["silent",{}],410:["emp",{}],500:["route",{"point":Vector2(600,800)}],610:["decoy",{}],760:["emergency",{"point":Vector2(140,800)}],1000:["select",{"unit":2}],1001:["route",{"point":Vector2(900,800)}],1050:["camera",{}],1400:["recon",{}],1900:["contact_hold",{}],2100:["wait_drone",{}]}
  s.paused=false
  for tick in 2700:
   if commands.has(tick):
    var c=commands[tick];print("COMMAND ",mission," ",tick," ",c[0]," ",s.command(c[0],c[1]))
   if tick==600:
    s.paused=true;var paused=state(s)
    for n in 40:read_feedback(s);s.advance(0.25)
    check(state(s)==paused,"pause is stable")
    var snapshot=s.snapshot();var copy=Simulation.new();copy.restore(snapshot)
    check(copy.paused,"restore paused")
    # Both versions exercise the same restore transition with two finite decoys.
    s=copy;s.paused=false
   read_feedback(s);s.advance(1.0/60)
   if tick%60==0:print("TRACE ",mission," ",tick," ",digest(s))
  print("END ",mission," elapsed=",s.elapsed," hull=",s.hull," outcome=",s.outcome," noises=",s.noises.size())
 if Simulation.new().has_method("acoustic_feedback"):
  var s=Simulation.new();s.start(3);s.command("decoy");s.paused=false
  for n in 180:s.advance(1.0/60)
  s.command("decoy");s.command("decoy");s.paused=true
  var restored=Simulation.new();restored.restore(s.snapshot());var f=restored.acoustic_feedback()
  check(f.pulses.size()==3,"three finite restored decoys")
  check(absf(f.pulses[0].time-12)<0.001 and f.pulses[1].time==15 and f.pulses[2].time==15,"staggered timers restored")
  var p=Vector2(1500,50);check(not restored.visible(p),"hidden response fixture really hidden")
  restored._noise(p,1150,"FACTORY RESPONSE",8);restored._noise(p,500,"UNKNOWN",8)
  check(restored.acoustic_feedback().responses.is_empty(),"hidden response suppressed")
  check(restored.acoustic_feedback().pulses.size()==3,"unknown source suppressed")
  restored.recon_time=1
  check(restored.acoustic_feedback().responses.size()==1,"existing recon reveals response")
  restored.recon_time=0;restored.paused=false
  for n in 16*60:restored.advance(1.0/60)
  check(restored.acoustic_feedback().pulses.is_empty(),"all staggered decoys expire after restore")
 print("CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
