extends RefCounted
# 127 release controls (Pat 2026-10-30): "You should still be able to crash.
# But there should be moderate autopilot for edges". In release play (dev state
# off, the default) a player leg is installed straight, the runtime never solves
# a path around terrain, and a light edge assist slides a craft along a wall it
# touches or grazes, or holds it with a reason when sliding makes no progress.
# Collision damage, cooldown and retained speed stay the existing Simulation
# rules (_hull_strike). RECALL returns a drone by straight legs.
# Seams: Simulation._install_program chooses straight() over player_path,
# _course_prepare/_move_in_band/_current_step hand the position step to step(),
# ModuleRecovery.departure asks recalled(). Revert: make release() return false;
# the pathfinder and earned-chart autopilot remain intact behind it.
const GRAZE_SINE:=0.574 # sin(35 deg): shallower contact slides without a strike.
const ASSIST_SPEED:=0.5 # Fraction of the craft's thrust budget while sliding.
const MIN_SLIDE:=6.0
const HEAD_ON:=0.26 # cos(75 deg): a wall this square to the leg holds at once.
const CONTACT_GAP:=1.0 # Seconds clear of rock before a new touch is a new impact.
const STALL_SECONDS:=3.0
const PROGRESS:=2.0
const PROBE:=3.0
const RECALL_REACH:=65.0
const RECALL_STANDOFF:=40.0
const TRAIL_MAX:=16
const TRAIL_SPACING:=40.0
const ROCK_REASON:="Crosses charted rock"

static func release(sim)->bool:
 return not (sim.mission is Dictionary and sim.mission.get("dev",false))

static func _cell(chart,p:Vector2)->Vector2i:return Vector2i((p/chart.TILE).floor())

# Measured rock only: the earned chart's received rock cells, or the opening
# chart's public physical terrain. Unknown water is never reported as rock.
static func rock_at(sim,p:Vector2)->bool:
 if sim.terrain_chart!=null:return sim.terrain_chart.return_cells.has(_cell(sim.terrain_chart,p))
 return sim.blocked(p,12)

static func crosses_rock(sim,a:Vector2,b:Vector2)->bool:
 if sim.terrain_chart==null:return not sim._player_leg_safe(a,b)
 var count=maxi(1,ceili(a.distance_to(b)/10.0))
 for n in count+1:
  var p=a.lerp(b,float(n)/count)
  # A measured clear cell already certifies the whole hull footprint.
  if sim.terrain_chart.clear_cells.has(_cell(sim.terrain_chart,p)):continue
  for offset in [Vector2.ZERO,Vector2(12,0),Vector2(-12,0),Vector2(0,12),Vector2(0,-12)]:
   if sim.terrain_chart.return_cells.has(_cell(sim.terrain_chart,p+offset)):return true
 return false

# Release leg compiler: the operator's point, unchanged. Only a point inside
# measured rock is refused; a leg may still be plotted through danger.
static func straight(sim,a:Vector2,b:Vector2)->Array:
 if rock_at(sim,b):return []
 return [{"pos":b,"stop":true}]

static func warnings(sim,unit_id:int)->Array:
 var result=[]
 if unit_id<0 or unit_id>=sim.units.size():return result
 var u=sim.units[unit_id]
 if not u.alive or u.route.is_empty():return result
 sim._use_band(u.band)
 var origin:Vector2=u.pos
 for node in u.route:
  if crosses_rock(sim,origin,node.pos):result.append({"from":origin,"to":node.pos,"reason":ROCK_REASON})
  origin=node.pos
 sim._use_band(sim.units[sim.selected].band)
 return result

static func note_trail(sim,u:Dictionary)->void:
 if u==sim.units[0]:return
 var trail:Array=u.get("trail",[])
 if trail.is_empty() or trail.back().distance_to(u.pos)>=TRAIL_SPACING:trail.append(u.pos)
 while trail.size()>TRAIL_MAX:trail.pop_front()
 u["trail"]=trail

static func clear_contact(u:Dictionary)->void:
 u.erase("edge_assist");u.erase("edge_hold")

# Final position step for a player craft in release play. Free water moves as
# ordered. Contact at a steep angle is an impact under the existing rule; a
# shallow touch or the following contact slides along the wall toward the leg
# end at reduced speed, and a slide that stops gaining holds with a reason.
static func step(sim,u:Dictionary,next:Vector2,dt:float,flow:Vector2,budget:float)->void:
 var velocity:Vector2=(next-u.pos)/maxf(dt,0.0001)
 if not sim.blocked(next,12) and sim.segment_safe(u.pos,next,12):
  u.pos=next;u.vel=velocity
  var idle=u.get("edge_assist",{})
  if not idle.is_empty() and sim.elapsed-float(idle.touch)>CONTACT_GAP:u.erase("edge_assist")
  _water(sim,u,flow);return
 var n:=Vector2.ZERO
 for i in 16:
  var d=Vector2.from_angle(TAU*i/16.0)
  if sim.blocked(u.pos+d*PROBE,12):n-=d
 n=n.normalized() if n.length()>0.001 else -velocity.normalized()
 var speed=velocity.length()
 var assist:Dictionary=u.get("edge_assist",{})
 var fresh=assist.is_empty() or sim.elapsed-float(assist.touch)>CONTACT_GAP
 var goal:Vector2=u.route[0].pos if not u.route.is_empty() else u.pos+velocity
 if fresh:
  assist={"touch":sim.elapsed,"since":sim.elapsed,"best":u.pos.distance_to(goal),"strikes":int(assist.get("strikes",0))}
  if speed>0.01 and -velocity.dot(n)>speed*GRAZE_SINE:
   # Existing collision rule: cooldown, damage table and retained speed.
   sim._hull_strike(u,speed);assist.strikes+=1
   sim.events.append({"type":"edge_contact","unit":sim.units.find(u),"pos":u.pos,"impact":speed})
   u.vel=u.vel*sim.COLLISION_SPEED_RETAINED if u==sim.units[0] else Vector2.ZERO
   assist.touch=sim.elapsed;u["edge_assist"]=assist;_water(sim,u,flow);return
 assist.touch=sim.elapsed
 var tangent=Vector2(-n.y,n.x);var toward:Vector2=goal-u.pos
 if toward.length()<0.01:toward=velocity
 if toward.dot(tangent)<0:tangent=-tangent
 var along=toward.normalized().dot(tangent)
 var moved=false
 if along>=HEAD_ON:
  var pace=maxf(MIN_SLIDE,budget*ASSIST_SPEED*along)
  # Slide, then ease off the face if the corner or a bump stops the slide.
  for slide in [tangent*pace+n*1.0,tangent*pace,tangent*pace*.5+n*3.0,n*3.0]:
   var at=u.pos+slide*dt
   if not sim.blocked(at,12) and sim.segment_safe(u.pos,at,12):u.pos=at;u.vel=slide;moved=true;break
 if not moved:u.vel=Vector2.ZERO
 var distance=u.pos.distance_to(goal)
 if distance<float(assist.best)-PROGRESS:assist.best=distance;assist.since=sim.elapsed
 u["edge_assist"]=assist
 if along<HEAD_ON or sim.elapsed-float(assist.since)>STALL_SECONDS:
  _hold(sim,u,"Rock ahead blocks this leg" if along<HEAD_ON else "No way along this rock")
 _water(sim,u,flow)

static func _hold(sim,u:Dictionary,reason:String)->void:
 u.vel=Vector2.ZERO;u.hold="HOLD";u["edge_hold"]=reason;u.erase("edge_assist")
 sim.message="%s · %s · holding · replot"%[u.name,reason]

static func _water(sim,u:Dictionary,flow:Vector2)->void:
 if u.has("water_velocity") or not sim.mission.get("currents",[]).is_empty():u["water_velocity"]=u.vel-flow

# RECALL: straight legs to a standoff beside Quietus, or back along this
# drone's own breadcrumbs when the direct line crosses measured rock.
static func recall_plan(sim,id:int)->Dictionary:
 if id<=0 or id>=sim.units.size():return {"reason":"Select a drone"}
 var u=sim.units[id];var q=sim.units[0]
 if not u.alive:return {"reason":"Craft lost"}
 if not q.alive:return {"reason":"Quietus lost"}
 if not u.transition.is_empty():return {"reason":"Finish changing depth first"}
 if u.band!=q.band:return {"reason":"Needs %s to meet Quietus"%sim.Depth.NAMES[q.band]}
 var offset:Vector2=u.pos-q.pos
 var end:Vector2=q.pos+(offset.normalized()*RECALL_STANDOFF if offset.length()>RECALL_STANDOFF else offset)
 sim._use_band(u.band)
 var points=[];var from:Vector2=u.pos;var ok=false
 if rock_at(sim,end):end=q.pos+offset.normalized()*minf(offset.length(),RECALL_STANDOFF*.5)
 if not rock_at(sim,end):
  var trail:Array=u.get("trail",[]).duplicate();trail.reverse()
  for crumb in [null]+trail:
   if crumb!=null:
    if crosses_rock(sim,from,crumb):break
    points.append(crumb);from=crumb
   if not crosses_rock(sim,from,end):points.append(end);ok=true;break
 sim._use_band(sim.units[sim.selected].band)
 if not ok:return {"reason":"Rock between %s and Quietus · plot legs back by hand"%u.name}
 return {"points":points}

static func recall(sim,id:int)->bool:
 var plan=recall_plan(sim,id)
 if plan.has("reason"):sim.message=plan.reason;return false
 var u=sim.units[id]
 var goals=plan.points.map(func(p):return {"pos":p,"stop":true,"mode":"inherit"})
 sim._use_band(u.band)
 var ok=sim._install_program(u,goals,false)
 sim._use_band(sim.units[sim.selected].band)
 if not ok:sim.message="Rock between %s and Quietus · plot legs back by hand"%u.name;return false
 # Leaving HOLD releases this drone's work too; Quietus-issued RECALL ALL would not.
 u.hold="";sim.JobRelease.cancel(sim,id,"recall");u["recall"]=true;sim.captures[id]={}
 sim.message="%s · recalled to Quietus · %d leg%s"%[u.name,goals.size(),"" if goals.size()==1 else "s"]
 return true

static func recall_all(sim)->bool:
 var sent=[];var refused=[]
 for id in [1,2]:
  if not sim.units[id].alive:continue
  if recall(sim,id):sent.append(sim.units[id].name)
  else:refused.append(sim.message)
 sim.message=("Recalled "+", ".join(sent) if not sent.is_empty() else "No drone recalled")+("" if refused.is_empty() else " · "+" · ".join(refused))
 return not sent.is_empty()

# A recalled drone that waits inside Quietus's recovery reach comes home with it.
static func recalled(sim,id:int)->bool:
 var u=sim.units[id];var q=sim.units[0]
 return u.alive and u.get("recall",false) and q.alive and u.band==q.band and u.transition.is_empty() and q.transition.is_empty() and u.pos.distance_to(q.pos)<RECALL_REACH and u.vel.length()<12 and sim.Depth.clear(sim,u.pos,q.pos,u.band)

static func valid(data:Dictionary)->bool:
 for u in data.get("units",[]):
  if not u is Dictionary:return false
  if u.has("recall") and not u.recall is bool:return false
  if u.has("edge_hold") and (not u.edge_hold is String or u.edge_hold.length()>80):return false
  if u.has("trail"):
   if not u.trail is Array or u.trail.size()>TRAIL_MAX:return false
   for p in u.trail:
    if not p is Vector2 or not p.is_finite():return false
  if u.has("edge_assist"):
   var a=u.edge_assist
   if not a is Dictionary or not a.has_all(["touch","since","best","strikes"]) or a.size()!=4:return false
   for key in ["touch","since","best"]:
    if not (a[key] is float or a[key] is int) or not is_finite(float(a[key])):return false
   if not a.strikes is int or a.strikes<0:return false
 return true
