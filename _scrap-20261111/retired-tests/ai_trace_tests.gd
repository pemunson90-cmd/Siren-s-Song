extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Trace=preload("res://src/diagnostics/ai_trace.gd")
const Table=preload("res://src/diagnostics/ai_trace_table.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
# Same single-guard fixture the first-siren-cue tests use: one Siren 120 px from the craft.
func fixture(op):
 var s=Sim.new();s.start(op,"endurance")
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(120,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={}
 s.sirens=[e]
 for id in [1,2]:s.units[id].alive=false
 s.paused=false
 return s
func state_hash(s)->String:
 return var_to_str([s.snapshot(),s.sirens,s.units,s.noises,s.elapsed,s.hull,s.outcome,s.message]).sha256_text()
func scripted(op,trace:bool):
 var s=Sim.new();s.start(op,"endurance")
 s.command("route",{"point":s.units[0].pos+Vector2(300,40)});s.paused=false
 var rec=Trace.attach(s,true) if trace else {}
 for n in 300:
  s.advance(0.1)
  Trace.sample(rec,s)
 var out={"hash":state_hash(s),"trace":Trace.export(rec),"rec":rec}
 Trace.detach(rec,s)
 return out
func run():
 # Off by default: no recorder, no connection, sample is a no-op.
 check(Table.enabled==false,"trace flag is off by default")
 var idle=Sim.new();idle.start(0)
 var none=Trace.attach(idle)
 check(none.is_empty() and idle.siren_notice.get_connections().is_empty(),"disabled trace attaches nothing")
 Trace.sample(none,idle);check(Trace.export(none).is_empty() and Trace.metrics(none).get("samples",0)==0,"disabled trace samples nothing")
 Table.enabled=true
 check(Table.EVENT_CAP>0 and Table.TICK_CAP>=Table.EVENT_CAP,"ring caps come from the data table")
 # Read-only: identical state with and without the trace, operation 0 and a Glass Reach op.
 for op in [0,14]:
  var bare=scripted(op,false);var seen=scripted(op,true)
  check(bare.hash==seen.hash,"sim state hash identical with and without trace, op %d"%op)
  check(not seen.trace.is_empty() and seen.trace.metrics.samples==300,"trace sampled every tick, op %d"%op)
  var again=scripted(op,true)
  check(again.trace==seen.trace and again.hash==seen.hash,"two identical scripted runs give identical trace dictionaries, op %d"%op)
  var first=seen.trace.events[0] if not seen.trace.events.is_empty() else {}
  check(first.get("cause","")=="init" and first.has_all(["t","id","role","from","to","cause","suspicion","alert_floor","lock","target","pos","band"]),"event rows carry the full field set, op %d"%op)
 # Ring buffers drop oldest first and report the loss.
 var s=fixture(1);var rec=Trace.attach(s,true,{"event_cap":3,"tick_cap":5})
 for n in 60:Trace.step(rec,s,0.1);if s.outcome!="":break
 check(rec.ticks.size()==5 and rec.dropped_ticks==rec.samples-5,"tick ring holds exactly its cap and counts drops")
 check(rec.events.size()<=3 and rec.ticks[0].t<rec.ticks[4].t,"event ring never exceeds its cap, oldest dropped first")
 Trace.detach(rec,s)
 # Metrics on a scripted route that gets noticed (single close Siren, op 1).
 s=fixture(1);rec=Trace.attach(s)
 var start=s.elapsed
 for n in 60:
  Trace.step(rec,s,0.1)
  if s.sirens[0].mode=="BEAM" or s.outcome!="":break
 var m=Trace.metrics(rec)
 var sm=m.sirens[0]
 check(sm.time_to_first_notice>=0. and sm.time_to_first_notice<=0.2,"noticed on the first tick of sight")
 check(sm.time_to_lock_start>=sm.time_to_first_notice and sm.time_to_detection>=sm.time_to_first_notice,"lock start and detection follow the notice")
 check(sm.time_to_beam>sm.time_to_lock_start+3.5,"beam arrives after the 4 s lock, not before")
 check(sm.transitions>=2 and m.transitions==sm.transitions and m.noticed==1,"mode transitions counted")
 var causes=rec.events.map(func(r):return r.cause)
 var tos=rec.events.map(func(r):return r.to)
 check(tos.has("LOCKING") and tos.has("BEAM") and causes.has("sight") and causes.has("timer"),"mode changes carry derived reasons")
 check(rec.events.all(func(r):return r.t>=start and r.pos is Vector2),"rows stamped on simulation time")
 # Heard sound is attributed to its source label.
 var h=fixture(1);h.sirens[0].pos=h.units[0].pos+Vector2(350,0);h.sirens[0].home=h.sirens[0].pos
 var hr=Trace.attach(h);h._noise(h.units[0].pos,900.,"CAMERA",1.,h.units[0].band);Trace.step(hr,h,0.1)
 check(hr.events.size()>=2 and hr.events[-1].to=="INVESTIGATE" and hr.events[-1].cause=="sound:CAMERA","heard emission becomes sound cause with label")
 # Detach releases the signal and leaves the recorder inert; no leaked objects.
 Trace.detach(hr,h);check(h.siren_notice.get_connections().is_empty(),"detach disconnects the notice signal")
 Trace.detach(rec,s)
 var before=Performance.get_monitor(Performance.OBJECT_COUNT)
 for n in 3:
  var tmp=Sim.new();tmp.start(0);var r=Trace.attach(tmp,true)
  for k in 20:Trace.step(r,tmp,0.1)
  Trace.detach(r,tmp)
 check(Performance.get_monitor(Performance.OBJECT_COUNT)<=before+2,"no objects leak after attach and detach cycles")
 Table.enabled=false
 print("AI TRACE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
