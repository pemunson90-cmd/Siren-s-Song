extends SceneTree
var checks=0
var failures=0
var tool
const REFERENCE=[0.4,0.8,0.4]
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func samples(time:float)->Array:
 return [{"receiver":0,"origin":Vector2(100,100),"direction":Vector2.LEFT,"time":time,"uncertainty":0.65,"cadence":REFERENCE.duplicate(),"label":"SECRET RETURN","source_pos":Vector2(9,9)}, {"receiver":0,"origin":Vector2(100,100),"direction":Vector2.RIGHT,"time":time,"uncertainty":0.18,"cadence":[0.8,0.4,0.8]}]
func run_listen(enabled=true,speed=0.0)->Dictionary:
 var state={}
 for n in 361:state=tool.advance(state,samples(n/60.0),REFERENCE,Vector2(100,100),speed,n/60.0,1.0/60,enabled)
 return state
func _initialize():
 var path="res://src/equipment/cadence_correlator.gd"
 if not ResourceLoader.exists(path):check(false,"fresh local cadence correlation resolves only after physical listening")
 else:
  tool=load(path)
  var state={}
  for n in 300:state=tool.advance(state,samples(n/60.0),REFERENCE,Vector2(100,100),0,n/60.0,1.0/60)
  check(state.status=="listening" and state.dwell<6,"five seconds cannot grant six-second interpretation")
  state=run_listen()
  check(state.status=="match" and state.arrivals.size()==2 and state.arrivals[0].classification=="match" and state.arrivals[1].classification=="other","two unnamed carriers distinguish only measured reference pattern")
  check(state.arrivals[0].direction==Vector2.LEFT and state.arrivals[0].uncertainty==0.65 and not state.arrivals[0].has("label") and not state.arrivals[0].has("source_pos"),"result retains bent arrival uncertainty and strips source truth/label")
  check(state.qualification.contains("identity") and state.qualification.contains("range"),"match explicitly does not authenticate source or range")
  check(run_listen(false).status=="unresolved" and run_listen(false).dwell==0,"bare craft gets no kit interpretation")
  check(run_listen(true,12.0).dwell==0,"moving craft cannot integrate reference")
  var paused=tool.advance(state,samples(6),REFERENCE,Vector2(100,100),0,state.last_time,1.0/60)
  check(paused==state,"same elapsed pause grants no sample or progress")
  var moved_samples=samples(6.1)
  for reading in moved_samples:reading.origin=Vector2(109,100)
  var moved=tool.advance(state,moved_samples,REFERENCE,Vector2(109,100),0,6.1,1.0/60)
  check(moved.dwell<0.02 and moved.status=="listening","displacement resets accumulated interpretation")
  var stale=tool.advance(state,samples(3),REFERENCE,Vector2(100,100),0,6.1,1.0/60)
  check(stale.dwell==0 and stale.arrivals.is_empty(),"remembered stale sample cannot drive live interpretation")
  var future=tool.advance(state,samples(7),REFERENCE,Vector2(100,100),0,6.1,1.0/60)
  check(future.dwell==0,"future samples reject")
  var foreign=samples(6.1)
  for reading in foreign:reading.receiver=1
  check(tool.advance(state,foreign,REFERENCE,Vector2(100,100),0,6.1,1.0/60).dwell==0,"remote drone reception cannot feed Quietus receiver")
  var changed=samples(6.1);changed[1].cadence=REFERENCE.duplicate()
  var ambiguity={}
  for n in 361:
   for reading in changed:reading.time=n/60.0
   ambiguity=tool.advance(ambiguity,changed,REFERENCE,Vector2(100,100),0,n/60.0,1.0/60)
  check(ambiguity.status=="unresolved" and ambiguity.arrivals.size()==2 and ambiguity.arrivals.all(func(a):return a.classification=="match"),"same-cadence competing arrivals cannot choose an authentic source")
  var spoof=[samples(6.1)[0]]
  var matched={}
  for n in 361:
   spoof[0].time=n/60.0
   matched=tool.advance(matched,spoof,REFERENCE,Vector2(100,100),0,n/60.0,1.0/60)
  check(matched.status=="match" and matched.qualification==state.qualification,"a sole copied cadence yields pattern match only, never trustworthy identity")
  var no_reference=tool.advance(state,samples(6.1),[],Vector2(100,100),0,6.1,1.0/60)
  check(no_reference.dwell==0 and no_reference.status=="unresolved","field observation without recovered reference grants no correlation")
  var bad=samples(6.1);bad[0].cadence=[NAN,0.4];bad[1].time=INF
  check(tool.advance(state,bad,REFERENCE,Vector2(100,100),0,6.1,1.0/60).dwell==0,"malformed cadence or time cannot enter interpretation")
  var late={}
  for n in 360:
   var others=[samples(n/60.0)[1]]
   late=tool.advance(late,others,REFERENCE,Vector2(100,100),0,n/60.0,1.0/60)
  var appeared=tool.advance(late,[samples(6)[0]],REFERENCE,Vector2(100,100),0,6,1.0/60)
  check(appeared.status=="listening" and appeared.dwell<0.02 and appeared.arrivals.is_empty(),"late new match cannot inherit almost six seconds of another pattern")
  var reordered=samples(6.1);reordered.reverse()
  check(tool.advance(state,reordered,REFERENCE,Vector2(100,100),0,6.1,1.0/60).status=="match","reading order change does not reset coherent patterns")
  var binary=bytes_to_var(var_to_bytes(state));check(tool.valid_state(binary,6.0) and binary==state,"correlation state is exactly serializable")
  var resumed=tool.advance(binary,samples(6.1),REFERENCE,Vector2(100,100),0,6.1,1.0/60)
  check(resumed==tool.advance(state,samples(6.1),REFERENCE,Vector2(100,100),0,6.1,1.0/60),"saved listening has identical future")
  var tampered=state.duplicate(true);tampered.dwell=INF;check(not tool.valid_state(tampered,6.0),"invalid saved progress rejects")
  var leaked=state.duplicate(true);leaked.arrivals[0]["source_pos"]=Vector2(9,9)
  check(not tool.valid_state(leaked,6.0),"restored public state cannot smuggle hidden source fields")
  check(tool.valid_state({},0) and not tool.valid_state([],0),"optional absence remains compatible, malformed state rejects")
 print("CADENCE CORRELATOR CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
