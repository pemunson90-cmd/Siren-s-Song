extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Carry=preload("res://src/campaign/carry/carry.gd")
const Table=preload("res://src/campaign/carry/carry_table.gd")
const Calder=preload("res://tests/calder_trench_journey_tests.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func go(s,point)->bool:
 if s.outcome=="won":return s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return (s.outcome=="won" or s.units[0].pos.distance_to(point)<25) and s.units[0].alive
func dive(s,band)->bool:
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2);return s.units[0].band==band and s.units[0].transition.is_empty()
# Bare-Quietus courses copied from glass_reach_journeys.gd for the ops a carry row changes.
const COURSES={
 14:[["go",Vector2(1000,1300)],["depth",2],["go",Vector2(1000,720)],["depth",1],["go",Vector2(950,560)],["camera"],["depth",2],["go",Vector2(1000,1300)],["depth",1],["go",Vector2(2000,1800)],["exit"]],
 15:[["go",Vector2(800,2420)],["work","vane"],["go",Vector2(1000,2000)],["go",Vector2(1000,1150)],["go",Vector2(1000,600)],["camera"],["go",Vector2(1000,1150)],["go",Vector2(1000,2600)],["exit"]],
 16:[["go",Vector2(1400,2250)],["depth",2],["go",Vector2(1400,1560)],["depth",1],["camera"],["depth",2],["go",Vector2(1400,2250)],["depth",1],["go",Vector2(700,2000)],["exit"]],
 17:[["depth",0],["go",Vector2(2700,1450)],["depth",1],["depth",2],["go",Vector2(2860,1395)],["recover"],["go",Vector2(2700,1450)],["depth",1],["go",Vector2(600,1350)],["go",Vector2(400,850)],["go",Vector2(2470,850)],["go",Vector2(2470,400)],["go",Vector2(2700,420)],["camera"],["exit",1]],
 20:[["go",Vector2(1150,1685)],["recover"],["go",Vector2(1200,1600)],["camera"],["exit"]],
 21:[["go",Vector2(2300,1500)],["go",Vector2(1950,800)],["go",Vector2(1700,1200)],["camera"],["go",Vector2(1635,1300)],["depth",2],["recover"],["depth",1],["go",Vector2(1950,800)],["go",Vector2(2300,1500)],["exit"]]}
func course(s,id,steps)->bool:
 for step in steps:
  match step[0]:
   "go":if not go(s,step[1]):check(false,"bare course reaches "+str(step[1])+" "+str(id));return false
   "depth":if not dive(s,step[1]):check(false,"bare depth crossing to band "+str(step[1])+" "+str(id));return false
   "work":check(s.command("glass_action",{"action":step[1]}),"bare local machine accepts work "+str(id));tick(s,8.2)
   "camera":
    check(s.command("camera"),"account acquisition starts "+str(id));tick(s,s.mission.objectives[0].duration+.2)
    check(s.mission.objectives[0].captured,"bare Quietus receives the account "+str(id))
   "recover":
    check(s.command("glass_action",{"action":"recover"}),"material winch "+str(id));tick(s,4.2)
    check(s.mission.glass_reach.artifact.carrier==0,"material rides Quietus "+str(id))
   "exit":check(go(s,s.mission.corridors[step[1] if step.size()>1 else 0].pos),"bare return reaches recovery mouth "+str(id))
 return true
func progress(thread:String,facts:Dictionary):
 var f={"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"};f.merge(facts,true)
 return {"version":2,"route":thread,"routes":[thread],"completed":[6,7,9,11,12],"facts":f,"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
func journey(id:int,p:Dictionary,steps=null):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
 s.units[1].alive=false;s.units[2].alive=false
 var tools=s.tools.duplicate()
 course(s,id,COURSES[id] if steps==null else steps)
 check(s.outcome=="won" and s.hull>0 and s.tools==tools,"bare Quietus without finite tools finishes carried op "+str(id))
 return s
func strip(m:Dictionary)->String:
 var c=m.duplicate();c.erase("launch_context");return var_to_str(c)
func same(a,b)->bool:return strip(a)==strip(b)
func ctx(row:Dictionary)->Dictionary:
 var h={"thread":"","facts":{}}
 if row.when.has("thread"):h.thread=row.when.thread
 if row.when.has("fact"):h.facts[row.when.fact]=row.when.is[0]
 return h
func _initialize():call_deferred("run")
func run():
 var earlier=Table.ROWS.filter(func(row):return row.op<30)
 var arc6=Table.ROWS.filter(func(row):return row.op>=30)
 check(earlier.size()>=6 and earlier.size()<=8,"earlier carry table retains 6 to 8 deltas")
 check(arc6.size()>=3 and arc6.size()<=5,"arc six authors 3 to 5 deltas")
 var seen=[]
 for row in Table.ROWS:
  check(row.id not in seen and row.op>=14 and row.op<=36 and row.kind in ["mouth","drop_guard","add_guard","start"],"row is well formed "+row.id)
  check(not row.line.contains("—") and row.line.length()<140,"row line is a short placeholder without em dashes "+row.id)
  seen.append(row.id)
 # Legacy and unrelated history: exactly today's mission.
 var other={"thread":"","facts":{"confluence_route":"unknown"}}
 for id in range(14,37):
  var base=Catalog.make(id)
  var untouched=base.duplicate(true);Carry.apply(untouched,id,{})
  check(var_to_bytes(base)==var_to_bytes(untouched),"empty carry is byte equivalent "+str(id))
  check(same(base,Catalog.make(id,{})),"empty history is the legacy mission "+str(id))
  check(same(base,Catalog.make(id,{"thread":"","facts":{}})),"blank thread and facts are the legacy mission "+str(id))
  check(same(base,Catalog.make(id,other)),"unmatched facts add no delta "+str(id))
 # Each delta changes its op, only when its fact is present, and names its cause.
 for row in Table.ROWS:
  var base=Catalog.make(row.op);var h=ctx(row);var m=Catalog.make(row.op,h)
  check(Carry.rows_for(row.op,h).has(row),"fact selects row "+row.id)
  check(m.brief.contains(row.line) and not base.brief.contains(row.line),"brief names the cause "+row.id)
  match row.kind:
   "mouth":check(m.corridors.size()==base.corridors.size()+1 and m.corridors[0]==base.corridors[0] and m.corridors.size()<=2,"extra mouth keeps the first "+row.id)
   "drop_guard":
    check(m.sirens.size()==base.sirens.size()-1,"guard removed "+row.id)
    var numbered=true
    for i in m.sirens.size():numbered=numbered and m.sirens[i].patrol==i
    check(numbered,"guards stay numbered by position "+row.id)
   "add_guard":check(m.sirens.size()==base.sirens.size()+1 and m.sirens.back().type==row.type,"guard added "+row.id)
   "start":check(m.start==row.pos and base.start!=row.pos,"start changed "+row.id)
  check(not same(base,m),"delta differs from legacy "+row.id)
  var absent={"thread":"" if row.when.has("thread") else "deep","facts":{}}
  if row.when.has("fact"):absent.facts[row.when.fact]="nothing_recorded"
  check(same(Catalog.make(row.op,absent),base),"absent fact leaves the mission unchanged "+row.id)
  check(same(Catalog.make(row.op),base),"fact build cannot contaminate later legacy builds "+row.id)
  if row.op>=30:
   check(m.objectives==base.objectives and m.structures==base.structures and m.required_site_ids==base.required_site_ids,"arc six preserves photos, work and gates "+row.id)
 # Bare Quietus, no finite tool, still finishes every changed Glass op with its fact present.
 var cases=[[14,"shelf",{}],[14,"deep",{"wake_crossing":"repeater_played"}],[15,"deep",{"warning_chain":"service_local_receipt"}],
  [16,"deep",{"confluence_route":"overt"}],[17,"deep",{"warning_arrival":"sheltered"}],[21,"shelf",{}],
  [21,"deep",{"warning_chain":"mast_transmission_external_unknown"}]]
 for c in cases:journey(c[0],progress(c[1],c[2]))
 var steps=COURSES[14].duplicate();steps[steps.size()-1]=["exit",1]
 check(journey(14,progress("shelf",{}),steps).outcome=="won","the added shelf mouth is itself a finishing recovery")
 # Ordinary authored core courses with each new fact; standard Quietus, no drones or finite tools.
 for row in arc6:
  arc6_journey(row,false)
  if row.kind=="mouth":arc6_journey(row,true)
 print("CARRY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func arc6_journey(row:Dictionary,extra_mouth:bool):
 var s=Sim.new();s.start(row.op,"standard",{"context":ctx(row)})
 s.units[1].alive=false;s.units[2].alive=false
 var tools=s.tools.duplicate(true)
 var field=s.mission.get("field_tools",{}).get("counts",{}).duplicate(true)
 var route=Calder.steps(row.op,s)
 if extra_mouth:
  # The shelf mouth is south of the survey's MIDDLE ridge: retrace its DEEP gap.
  # Its western turn needs a northern viewpoint with room for the four-second dive.
  for step in route:
   if step[0]=="go" and step[1]==Vector2(1180,300):step[1]=Vector2(1300,190)
  route=route.slice(0,5)
  route.append_array([["burst",Vector2(1300,30)],["go",Vector2(800,30)],["emergency",Vector2(100,100)],["quiet"],["dive",2],["go",s.mission.corridors[1].pos],["dive",1]])
 var finished=true
 for step in route:
  var ok=false
  match step[0]:
   "emergency":ok=s.command("emergency",{"point":step[1]}) and Calder.go(s,step[1])
   "quiet":ok=s.units[0].silent or s.command("silent")
   "burst":
    ok=s.command("emergency",{"point":step[1]})
    Calder.tick(s,1.)
    ok=ok and s.command("silent") and Calder.go(s,step[1])
   "go":ok=Calder.go(s,step[1])
   "dive":ok=Calder.dive(s,step[1])
   "shoot":ok=Calder.expose(s,Calder.obj(s,step[1]),.1 if extra_mouth else 2.)
   "cargo":ok=Calder.recover_cargo(s)
  if not ok:
   finished=false;print("CARRY ARC6 STOP ",row.id," ",step," ",s.message," pos=",s.units[0].pos);break
 Calder.tick(s,1.)
 check(finished and s.outcome=="won" and s.mission.recovered,"bare arc six recovery "+row.id+str(extra_mouth))
 check(s.tools==tools and s.mission.get("field_tools",{}).get("counts",{})==field,"no finite tools used "+row.id)
 check(s.mission.objectives.filter(func(o):return not o.get("optional",false)).all(func(o):return o.captured),"all required stages and photos complete "+row.id)
 check(Sim.valid_snapshot(s.snapshot()),"carried arc six current snapshot valid "+row.id)
 print("CARRY ARC6 ",row.id," extra_mouth=",extra_mouth," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen)
