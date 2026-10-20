extends RefCounted
# The same packet can be received at its watched berth, on its actual voyage,
# or at permanent refuge. Presentation gets only measured/locally sensed fixes.
const Region=preload("res://src/simulation/world_region.gd")
const SPEED=24.0
const CONTROL=Vector2(650,1000)
const CONTROL_RANGE=120.0
const NOISE=950.0
const NOISE_TIME=6.0
const POINTS=[Vector2(540,640),Vector2(440,640),Vector2(440,300),Vector2(420,180)]
static func applies(mission:Dictionary)->bool:return mission.id==7 and mission.has("rendezvous_transport")
static func initial()->Dictionary:return {"released_at":-1.0,"control_known":false,"seen":{}}
static func duration()->float:
 var length=0.0
 for n in range(1,POINTS.size()):length+=POINTS[n-1].distance_to(POINTS[n])
 return length/SPEED
static func position(mission:Dictionary,time:float)->Vector2:
 var release=mission.rendezvous_transport.released_at
 if release<0 or time<release:return POINTS[0]
 var distance=(time-release)*SPEED
 for n in range(1,POINTS.size()):
  var length=POINTS[n-1].distance_to(POINTS[n])
  if distance<length:return POINTS[n-1].move_toward(POINTS[n],distance)
  distance-=length
 return POINTS.back()
static func phase(mission:Dictionary,time:float)->String:
 var release=mission.rendezvous_transport.released_at
 # Paused release has no elapsed motion; an observation at that instant stays true.
 return "moored" if release<0 or time<=release else ("transit" if time-release<duration() else "refuge")
static func _angle(mission:Dictionary,time:float)->float:
 if phase(mission,time)=="moored":return (POINTS[1]-POINTS[0]).angle()
 var pos=position(mission,time);var next=position(mission,time+.01)
 return pos.angle_to_point(next) if next.distance_squared_to(pos)>.000001 else (POINTS[-1]-POINTS[-2]).angle()
static func source_position(sim,source:Dictionary)->Vector2:
 return position(sim.mission,sim.elapsed) if applies(sim.mission) and source.id=="rendezvous" else source.pos
static func _sensing(sim,pos:Vector2,active:bool=false)->Dictionary:
 var receivers=sim.passive_receivers(pos)
 var survey=(active or sim.recon_time>0) and Region.survey_visible(sim,pos)
 var sonar=sim.ping_time>0 and sim.ping_origin.distance_to(pos)<650 and sim.line_clear(sim.ping_origin,pos)
 return {"receivers":receivers,"survey":survey,"sonar":sonar,"live":not receivers.is_empty() or survey or sonar}
static func observe(sim,active:bool=false)->void:
 if not applies(sim.mission):return
 var state=sim.mission.rendezvous_transport
 if _sensing(sim,CONTROL,active).live:state.control_known=true
 var pos=position(sim.mission,sim.elapsed);var sensing=_sensing(sim,pos,active)
 if not sensing.live:return
 state.seen={"pos":pos,"angle":_angle(sim.mission,sim.elapsed),"time":sim.elapsed,"phase":phase(sim.mission,sim.elapsed),"receivers":sensing.receivers,"survey":sensing.survey,"sonar":sensing.sonar}
 for objective in sim.mission.objectives:
  if objective.get("site_id","")=="rendezvous":objective.pos=pos;objective["observed_at"]=sim.elapsed
static func observed(sim)->bool:
 return applies(sim.mission) and not sim.mission.rendezvous_transport.seen.is_empty() and sim.mission.rendezvous_transport.seen.time==sim.elapsed
static func known_source_position(mission:Dictionary,source:Dictionary)->Vector2:
 return mission.rendezvous_transport.seen.get("pos",source.pos) if applies(mission) and source.id=="rendezvous" else source.pos
static func release_context(sim,station:int)->Dictionary:
 var state=sim.mission.rendezvous_transport;var result={"known":state.control_known,"ready":false,"reason":"Locate the berth control locally or with Survey"}
 if not state.control_known:return result
 result.merge({"pos":CONTROL,"range":CONTROL_RANGE,"used":state.released_at>=0,"noise_radius":NOISE,"noise_duration":NOISE_TIME})
 var unit=sim.units[station]
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif result.used:result.reason="Berth released · announced refuge remains available"
 elif not unit.alive:result.reason="Craft lost"
 elif not sim.captures[station].is_empty():result.reason="Finish this craft's packet reception first"
 elif unit.pos.distance_to(CONTROL)>CONTROL_RANGE:result.reason="Reach berth control within120m"
 elif not sim.line_clear(unit.pos,CONTROL):result.reason="Cover blocks the control link"
 elif unit.vel.length()>=12:result.reason="Settle below12m/s"
 else:result.ready=true;result.reason="RELEASE BERTH · audible950m /6s · tender goes to north refuge"
 return result
static func release(sim)->bool:
 if not applies(sim.mission):return false
 var context=release_context(sim,sim.selected)
 if not context.ready:sim.message=context.reason;return false
 sim.mission.rendezvous_transport.released_at=sim.elapsed
 sim._noise(CONTROL,NOISE,"BERTH RELEASE",NOISE_TIME);sim.events.append({"type":"berth_release","pos":CONTROL})
 sim.message="Berth released · tender departs toward northern refuge · machinery audible; route is announced, not a live tracker"
 return true
static func feedback(sim,station:int)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.rendezvous_transport;var vessel={"known":not state.seen.is_empty(),"live":false}
 if vessel.known:
  var sensing=_sensing(sim,position(sim.mission,sim.elapsed));vessel.live=sensing.live
  vessel.merge({"pos":position(sim.mission,sim.elapsed) if vessel.live else state.seen.pos,"angle":_angle(sim.mission,sim.elapsed) if vessel.live else state.seen.angle,"phase":phase(sim.mission,sim.elapsed) if vessel.live else state.seen.phase,"age":0.0 if vessel.live else maxf(0,sim.elapsed-state.seen.time),"receivers":sensing.receivers if vessel.live else [],"survey":sensing.survey if vessel.live else false,"sonar":sensing.sonar if vessel.live else false})
 return {"released":state.released_at>=0,"course":POINTS.duplicate() if state.control_known else [],"vessel":vessel,"control":release_context(sim,station)}
static func receiver(sim,station:int)->Dictionary:
 if not applies(sim.mission):return {}
 var target=-1
 for n in sim.mission.objectives.size():
  if sim.mission.objectives[n].get("site_id","")=="rendezvous":target=n;break
 var unit=sim.units[station];var pos=position(sim.mission,sim.elapsed);var local=unit.alive and unit.pos.distance_to(pos)<sim.passive_range(station) and sim.line_clear(unit.pos,pos)
 var result={"target":target,"ready":false,"text":"Locate the rendezvous hull or use local Survey","range":240.0,"distance":unit.pos.distance_to(pos) if local else -1.0,"clear":local,"settled":unit.vel.length()<12}
 if target<0:return result
 if sim.mission.objectives[target].captured:result.text="Rendezvous packet aboard · return Quietus to recovery"
 elif station!=0:result.text="Quietus hydrophones must decode the rendezvous packet"
 elif not local:result.text="Regain local carrier reception · measured fixes can become stale"
 elif result.distance>=240:result.text="Bring Quietus within240m of the actual hull"
 elif not result.settled:result.text="Settle below12m/s to decode the rendezvous packet"
 else:result.ready=true;result.text="READY · RENDEZVOUS HULL · passive decode4s"
 return result
static func valid(mission:Dictionary,time:float)->bool:
 if not mission.has("rendezvous_transport"):return mission.get("id")!=7
 if mission.get("id")!=7 or not is_finite(time) or time<0:return false
 var state=mission.rendezvous_transport
 if not state is Dictionary or state.size()!=3 or not state.get("control_known") is bool or not state.get("seen") is Dictionary or not (state.get("released_at") is float or state.get("released_at") is int):return false
 if not is_finite(state.released_at) or (state.released_at<0 and state.released_at!=-1) or state.released_at>time or (state.released_at>=0 and not state.control_known):return false
 if state.seen.is_empty():return true
 var seen=state.seen
 if seen.size()!=7 or not seen.get("pos") is Vector2 or not seen.pos.is_finite() or not seen.get("receivers") is Array or not seen.get("survey") is bool or not seen.get("sonar") is bool or not (seen.get("time") is float or seen.get("time") is int) or not (seen.get("angle") is float or seen.get("angle") is int):return false
 if not is_finite(seen.time) or not is_finite(seen.angle) or seen.time<0 or seen.time>time or seen.get("phase")!=phase(mission,seen.time) or seen.pos.distance_to(position(mission,seen.time))>.01:return false
 var ids=[]
 for id in seen.receivers:
  if not id is int or id not in [0,1,2] or id in ids:return false
  ids.append(id)
 return not seen.receivers.is_empty() or seen.survey or seen.sonar
