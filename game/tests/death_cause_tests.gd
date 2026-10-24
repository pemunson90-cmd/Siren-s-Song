extends SceneTree
# Handoff 046: death cause line. Scripted losses through the real Simulation, observer is read-only.
const Sim=preload("res://src/simulation/simulation.gd")
const Log=preload("res://src/presentation/death_cause/cause_log.gd")
const Table=preload("res://src/presentation/death_cause/cause_table.gd")
const Summary=preload("res://src/presentation/loss_summary.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func fixture(dist:float,loud:bool=false):
 var s=Sim.new();s.start(0)
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(dist,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={}
 s.sirens=[e]
 for id in [1,2]:s.units[id].alive=false
 s.units[0].silent=not loud
 s.paused=false
 return s
# Journeys: ping, loud engine, camera shutter, plain sight. Returns the finished sim and the observer (or null).
func journey(kind:String,observe:bool):
 var s=fixture({"ping":700.,"engine":900.,"camera":260.,"sight":150.}[kind],kind=="engine")
 var log=null
 if observe:log=Log.new();log.bind(s)
 if kind=="ping":s.command("ping")
 if kind=="engine":s.command("route",{"point":s.units[0].pos+Vector2(500,0)})
 if kind=="camera":
  s.units[0].pos=s.mission.objectives[0].pos;s.sirens[0].pos=s.units[0].pos+Vector2(260,0);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
  s.command("camera")
 for i in 3000:
  s.advance(0.1)
  if log!=null:log.sample()
  if not s.outcome.is_empty():break
 return {"sim":s,"log":log}
func state(s)->String:
 return var_to_str([s.snapshot(),s.sirens,s.units,s.noises,s.elapsed,s.hull,s.outcome,s.message]).sha256_text()
func run():
 check(Table.enabled and Table.WINDOW==20.0 and Table.CAP>0 and Table.MOTION_RADIUS>125. and Table.MOTION_RADIUS<430.,"table defaults: on, 20 s window, threshold between silent and cruise motion")
 var expect={"ping":["ACTIVE SONAR"],"engine":["moving at speed"],"camera":["CAMERA"],"sight":["sight line"]}
 for kind in expect:
  var a=journey(kind,true);var b=journey(kind,false)
  check(a.sim.outcome=="lost" and "Siren beam" in a.sim.message,"%s journey ends in a beam loss"%kind)
  var text=a.log.line()
  check(text!="" and expect[kind][0] in text,"%s journey states its cause: %s"%[kind,text])
  if kind in ["ping","camera"]:check(text.ends_with("before the lock.") and text.begins_with("It was drawn by:"),"%s cause names the lead time"%kind)
  check(state(a.sim)==state(b.sim),"%s: sim state identical with and without the observer"%kind)
  check(a.sim.snapshot().keys()==b.sim.snapshot().keys() and Sim.valid_snapshot(a.sim.snapshot()),"%s: snapshot shape and validity unchanged (old saves unaffected)"%kind)
  check(Summary.line(a.sim)==Summary.line(b.sim) and Summary.line(a.sim)!="","%s: existing loss line is untouched"%kind)
  a.log.free()
 # Cause priority: a ping before the lock wins over engine noise and sight.
 var s=fixture(700.);var log=Log.new();log.bind(s);s.units[0].silent=false
 s.command("ping");s.command("route",{"point":s.units[0].pos+Vector2(100,0)})
 for i in 3000:
  s.advance(0.1);log.sample()
  if not s.outcome.is_empty():break
 check("ACTIVE SONAR" in log.line(),"an own emission outranks motion and sight")
 log.free()
 # No record: no line, never an invented cause.
 var o=fixture(150.);var l2=Log.new();l2.bind(o);o.outcome="lost";o.message=o.VAPORIZED_TEXT;o.elapsed=10.
 o.contacts={0:{"time":10.,"pos":o.units[0].pos+Vector2(140,0),"mode":"BEAM","target":0,"source":"triangulation"}}
 check(l2.line()=="","an unobserved, non-optical contact with an empty log shows no cause")
 o.contacts={};check(l2.line()=="","no contact shows no cause")
 o.contacts={0:{"time":10.,"pos":o.units[0].pos+Vector2(140,0),"mode":"BEAM","target":0,"source":"optical"}}
 check("sight line" in l2.line(),"a fresh optical contact alone gives the sight line")
 o.oxygen=0.;check(l2.line()=="","oxygen losses keep their line and get no cause")
 o.oxygen=50.;o.message="Quietus lost.";o.hull=0.;check(l2.line()=="","hull losses get no cause")
 o.message=o.VAPORIZED_TEXT;o.outcome="won";check(l2.line()=="","only losses get a cause line")
 o.outcome="lost";Table.enabled=false
 check(l2.line()=="","flag off restores today's debrief (no line)")
 var rows=l2.ring.size();l2.sample();check(l2.ring.size()==rows,"flag off stops sampling")
 Table.enabled=true;l2.free()
 # Stale emission outside the window is never reported.
 var w=fixture(150.);var l3=Log.new();l3.bind(w);w.elapsed=100.
 l3.sample();l3.ring.append({"t":50.,"kind":"emission","label":"ACTIVE SONAR","unit":-1})
 w.outcome="lost";w.message=w.VAPORIZED_TEXT;w.contacts={0:{"time":100.,"pos":w.units[0].pos,"mode":"BEAM","target":0,"source":"triangulation"}}
 check(l3.line()=="","an emission older than the window is not a cause")
 # Ring is bounded and clears on mission change and clock rewind.
 var r=fixture(900.);var l4=Log.new();l4.bind(r)
 for i in 200:
  r.elapsed=float(i)*0.01;r.noises=[{"label":"ACTIVE SONAR","pos":Vector2.ZERO,"radius":10.,"time":2.,"band":1,"n":i}];l4.sample()
 check(l4.ring.size()==Table.CAP,"ring holds its table cap or less (%d)"%l4.ring.size())
 for i in 400:
  r.elapsed=2.+float(i);r.noises=[{"label":"CAMERA","pos":Vector2.ZERO,"radius":10.,"time":2.,"band":1,"n":i}];l4.sample()
 check(l4.ring.size()<=Table.CAP and l4.ring.all(func(x):return r.elapsed-x.t<=Table.WINDOW),"ring is bounded in count and age")
 r.noises=[];r.elapsed=1.;l4.sample();check(l4.ring.is_empty(),"clock rewind clears the log")
 r.noises=[{"label":"CAMERA","pos":Vector2.ZERO,"radius":10.,"time":2.,"band":1}];l4.sample();check(l4.ring.size()==1,"one noise is logged once")
 l4.sample();check(l4.ring.size()==1,"a noise lasting several frames is not double counted")
 r.mission={"id":99};r.noises=[];l4.sample();check(l4.ring.is_empty(),"mission change clears the log")
 l4.free();l3.free()
 print("DEATH CAUSE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
