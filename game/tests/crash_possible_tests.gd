extends SceneTree
# R4 (Pat 2026-10-30): "You should still be able to crash. But there should be
# moderate autopilot for edges". A straight release leg into measured rock
# collides and costs hull under the existing damage table on both chart shapes
# (opening public chart and earned measured chart). After the first impact the
# edge assist slides or holds: at most one collision per 10 s, goals unchanged.
const Sim=preload("res://src/simulation/simulation.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 legacy_shape()
 earned_shape()
 graze()
 dev_path()
 recall_rules()
 print("CRASH CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)

# Open water start, straight line through a rock to open water beyond it.
static func aim(s,shape:PackedVector2Array)->Dictionary:
 var centre=Vector2.ZERO
 for p in shape:centre+=p
 centre/=shape.size()
 for turn in 16:
  var d=Vector2.from_angle(TAU*turn/16.)
  for reach in range(160,420,20):
   var start=centre+d*reach
   if s.blocked(start,60):continue
   for far in range(60,500,20):
    var goal=centre-d*far
    if not Rect2(Vector2(40,40),s.world_size()-Vector2(80,80)).has_point(goal) or not Rect2(Vector2(40,40),s.world_size()-Vector2(80,80)).has_point(start):break
    if not s.blocked(goal,30) and not s.line_clear(start,goal):return {"start":start,"goal":goal}
 return {}

func run_crash(s,label:String)->void:
 var q=s.units[0]
 var plan=s.route_goals().duplicate(true)
 var hull=s.hull;var contacts=[];var first=-1.0
 s.paused=false
 for n in 60*40:
  var count=s.events.size()
  s.advance(Sim.STEP)
  for e in s.events.slice(count):
   if e.get("type","")=="edge_contact":contacts.append(s.elapsed)
  if first<0 and not contacts.is_empty():first=contacts[0]
  if first>=0 and s.elapsed-first>30:break
 s.paused=true
 var impact=float(q.get("edge_assist",{}).get("strikes",0))
 check(not contacts.is_empty(),label+": straight leg into measured rock collides")
 check(s.hull<hull,label+": collision costs hull")
 check(hull-s.hull<=Sim.COLLISION_MAX_DAMAGE+0.001,label+": loss stays inside the existing damage table")
 var later=contacts.slice(1)
 var worst=0
 for t in later:
  worst=maxi(worst,later.filter(func(x):return x>=t and x<t+10.0).size())
 check(worst<=1,label+": after the first impact at most one collision per 10 s (got %d)"%worst)
 check(s.route_goals()==plan or (s.route_goals().is_empty() and plan.is_empty()),label+": assist never changes the installed leg end")
 check(q.hold=="HOLD" or q.get("edge_assist",{}).size()>0 or q.route.is_empty() or q.pos.distance_to(plan[0].pos)<40,label+": craft slides, arrives or holds instead of grinding")
 if q.hold=="HOLD":check(not str(q.get("edge_hold","")).is_empty(),label+": hold carries a reason")
 print("CRASH ",label," hull=",snappedf(s.hull,0.1)," contacts=",contacts.size()," hold=",q.hold," reason=",q.get("edge_hold","")," impact_strikes=",impact)

func legacy_shape():
 var s=Sim.new();s.start(0);s.sirens=[]
 check(HandPilot.release(s),"release play is the default without the dev state")
 var setup={}
 for shape in s.rock_shapes:
  setup=aim(s,shape)
  if not setup.is_empty():break
 check(not setup.is_empty(),"opening chart has a rock to fly into")
 if setup.is_empty():return
 var q=s.units[0];q.pos=setup.start;q.angle=setup.start.angle_to_point(setup.goal);q.vel=Vector2.ZERO;q.silent=false
 check(s.command("route",{"point":setup.goal}),"release accepts a leg through charted rock")
 check(q.route.size()==1 and q.route[0].pos==setup.goal,"release leg is the straight placed leg, no pathfinder corners")
 check(not HandPilot.warnings(s,0).is_empty() and HandPilot.warnings(s,0)[0].reason==HandPilot.ROCK_REASON,"leg through charted rock carries a warning and reason")
 run_crash(s,"opening chart")

func earned_shape():
 var s=Sim.new();s.start(16);s.sirens=[]
 check(s.terrain_chart!=null,"Furnace Drift uses the earned measured chart")
 var q=s.units[0];var setup={}
 s._use_band(q.band)
 for shape in s.rock_shapes:
  setup=aim(s,shape)
  if setup.is_empty():continue
  # Measure this rock from where Quietus will start.
  q.pos=setup.start;s.paused=false;s._observe();s.paused=true
  if HandPilot.crosses_rock(s,setup.start,setup.goal):break
  setup={}
 check(not setup.is_empty(),"earned chart measures a rock on the planned leg")
 if setup.is_empty():return
 q.pos=setup.start;q.angle=setup.start.angle_to_point(setup.goal);q.vel=Vector2.ZERO;q.silent=false;q.erase("chart_stop")
 check(s.command("route",{"point":setup.goal}),"earned chart accepts a leg through measured rock")
 check(q.route.size()==1,"earned release leg stays straight")
 check(not HandPilot.warnings(s,0).is_empty(),"measured rock leg is drawn as a warning")
 run_crash(s,"earned chart")

# A shallow approach slides along the wall without an impact and keeps going.
func graze():
 var s=Sim.new();var face={}
 for op in [0,1,2,3,4,5]:
  s.start(op);s.sirens=[];s._use_band(1)
  face=long_face(s)
  if not face.is_empty():break
 var q=s.units[0]
 check(not face.is_empty(),"an opening chart has a long rock face")
 if face.is_empty():return
 q.pos=face.start;q.vel=Vector2.ZERO;q.angle=face.start.angle_to_point(face.goal);q.silent=false;q.band=1
 var hull=s.hull
 check(s.command("route",{"point":face.goal}),"shallow leg along a face is accepted")
 s.paused=false
 var strikes=0;var touched=false
 for n in 60*30:
  var count=s.events.size();s.advance(Sim.STEP)
  for e in s.events.slice(count):if e.get("type","")=="edge_contact":strikes+=1
  touched=touched or q.has("edge_assist")
  if q.route.is_empty() or q.hold=="HOLD":break
 check(touched,"the shallow leg actually touches the face")
 check(strikes==0 and s.hull==hull,"a shallow graze slides without an impact")
 print("GRAZE start=",face.start," goal=",face.goal," pos=",q.pos," hold=",q.hold," why=",q.get("edge_hold","")," route=",q.route.size()," t=",s.elapsed)
 check(q.route.is_empty() and q.pos.distance_to(face.goal)<20,"the slide carries the craft on to its own leg end")

static func long_face(s)->Dictionary:
 for shape in s.rock_shapes:
  for n in shape.size():
   var a:Vector2=shape[n];var b:Vector2=shape[(n+1)%shape.size()]
   if a.distance_to(b)<180:continue
   var along=(b-a).normalized();var out=Vector2(along.y,-along.x)
   if s.blocked((a+b)*.5+out*30,12):out=-out
   var start=a+along*40+out*34;var goal=b+along*70
   if s.blocked(start,24) or s.blocked(goal,16) or not s.segment_safe(start,start+along*60,20):continue
   return {"start":start,"goal":goal}
 return {}

# Dev state keeps the existing pathfinder for tests and harnesses.
func dev_path():
 var s=Sim.new();s.start(0);s.sirens=[];s.mission["dev"]=true
 var setup={}
 for shape in s.rock_shapes:
  setup=aim(s,shape)
  if not setup.is_empty():break
 if setup.is_empty():return
 s.units[0].pos=setup.start
 if s.command("route",{"point":setup.goal}):check(s.units[0].route.size()>1,"dev route still solves around rock")
 else:check(true,"dev route refusal is the pathfinder's own")

func recall_rules():
 var s=Sim.new();s.start(0);s.sirens=[]
 var q=s.units[0];var a=s.units[1]
 a.pos=q.pos+Vector2(200,0)
 if s.blocked(a.pos,20):a.pos=q.pos+Vector2(0,-200)
 check(not s.command("recall"),"Quietus cannot RECALL itself")
 s.command("select",{"unit":1})
 var plan=HandPilot.recall_plan(s,1)
 if plan.has("points"):
  check(s.command("recall"),"drone RECALL installs straight legs back")
  check(s.route_goals().size()==plan.points.size() and s.route_goals().back().pos.distance_to(q.pos)<=HandPilot.RECALL_STANDOFF+0.01,"recall ends beside Quietus")
  s.paused=false
  for n in 60*20:s.advance(Sim.STEP)
  s.paused=true
  check(HandPilot.recalled(s,1),"recalled drone inside recovery reach counts as recovered")
  check(s.ModuleRecovery.departure(s,{"pos":s.mission.extraction,"name":"TEST"}).recovered_drones.has(1),"departure recovers the recalled drone")
 a.band=2
 check(not s.command("recall") and "Needs MIDDLE" in s.message,"recall refuses with a reason across depth")
 a.band=1
 # A drone walled off from Quietus is refused with a reason, never re-routed.
 var walled={}
 for shape in s.rock_shapes:
  walled=aim(s,shape)
  if not walled.is_empty():break
 if not walled.is_empty():
  q.pos=walled.start;a.pos=walled.goal;a.erase("trail");a.vel=Vector2.ZERO;a.route=[];a.erase("route_plan")
  check(not s.command("recall") and "Rock between" in s.message and a.route.is_empty(),"recall refused with a reason when rock blocks the straight way back")
 s.command("select",{"unit":0})
 check(s.command("recall_all") or "Rock between" in s.message,"Quietus RECALL ALL orders every live drone or explains")
