extends RefCounted
# A ballast-driven archive glider carries the eastern reply around the basalt
# to a buried western intake. Its quiet relay carrier has the same passive
# reach as the fixed terminals. It is neither cover, a lure nor a new objective.
const SPEED=24.0
const POINTS=[Vector2(1360,480),Vector2(1120,560),Vector2(740,740),Vector2(360,760)]
static func duration()->float:
 var length=0.0
 for i in range(1,POINTS.size()):length+=POINTS[i-1].distance_to(POINTS[i])
 return length/SPEED
static func position(age:float)->Vector2:
 var distance=maxf(0,age)*SPEED
 for i in range(1,POINTS.size()):
  var length=POINTS[i-1].distance_to(POINTS[i])
  if distance<length:return POINTS[i-1].move_toward(POINTS[i],distance)
  distance-=length
 return POINTS[-1]
static func active(sim)->bool:
 if sim.mission.get("courier_revision",0)!=1:return false
 var launch_time=sim.mission.courier_launch
 return launch_time>=0 and sim.elapsed>=launch_time and sim.elapsed-launch_time<duration() and sim.outcome.is_empty()
static func launch(sim)->void:
 if sim.mission.get("courier_revision",0)==1 and sim.mission.courier_launch<0 and not sim.mission.objectives[1].captured:
  sim.mission.courier_launch=sim.elapsed
static func feedback(sim)->Dictionary:
 if not active(sim):return {}
 var age=sim.elapsed-sim.mission.courier_launch
 var pos=position(age);var receivers=sim.passive_receivers(pos)
 if receivers.is_empty():return {}
 return {"pos":pos,"angle":pos.angle_to_point(position(age+0.1)),"receivers":receivers}
static func receiver(sim,station:int)->Dictionary:
 var report=feedback(sim)
 if report.is_empty() or not report.receivers.has(station):return {}
 var u=sim.units[station];var radius=(240.0 if station==0 else 330.0)*0.65
 return {"distance":u.pos.distance_to(report.pos),"quiet_range":radius,"clear":true,"quiet":true,"replay":0.0,"ready":true,"settled":u.vel.length()<2,"source":"courier","origin":report.pos}
static func valid(mission:Dictionary,time)->bool:
 if not mission.has("courier_revision"):return not mission.has("courier_launch")
 if mission.id!=2 or mission.get("blackwater_revision",0)!=1 or not mission.courier_revision is int or mission.courier_revision!=1 or mission.objectives.size()!=2:return false
 if not mission.objectives[0].captured is bool:return false
 var launch_time=mission.get("courier_launch",null)
 if not (time is float or time is int) or not is_finite(float(time)) or time<0:return false
 if not (launch_time is float or launch_time is int) or not is_finite(float(launch_time)) or (launch_time<0 and launch_time!=-1) or launch_time>time:return false
 if launch_time>=0 and not mission.objectives[0].captured:return false
 return true
