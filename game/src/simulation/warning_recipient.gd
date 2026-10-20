extends RefCounted
# One non-player recipient owns its hull/course. Fleet controls and sensors stay
# with the three player craft; no announcement provides a live vessel tracker.
const Region=preload("res://src/simulation/world_region.gd")
const BERTH=Vector2(1840,440)
const REFUGE=Vector2(2420,240)
const PANEL=Vector2(1840,380)
const GATE=Rect2(1800,240,160,100)
const SPEED=28.0
const COURSES={"exposed":[Vector2(1540,440),Vector2(1540,680),Vector2(2260,680),Vector2(2340,440),REFUGE],"sheltered":[Vector2(1840,160),Vector2(2280,160),REFUGE]}
static func applies(m:Dictionary)->bool:return m.get("id")==13 and m.has("warning_recipient")
static func initial()->Dictionary:
 return {"body":{"pos":BERTH,"vel":Vector2.ZERO,"angle":0.,"route":[],"alive":true,"hull":100.,"silent":true,"name":"WARNING RECIPIENT"},"delivered":false,"course":"","arrived":false,"receipt":false,"seen":{},"gate_seen":{},"gate_method":""}
static func body(sim)->Dictionary:return sim.mission.warning_recipient.body if applies(sim.mission) else {}
static func _gate(sim)->Dictionary:return sim.mission.physical_gates[0]
static func _ack(sim)->bool:return sim.mission.objectives.any(func(o):return o.get("site_id","")=="warning_reply" and o.captured)
static func _phase(state:Dictionary)->String:
 return "lost" if not state.body.alive else "refuge" if state.arrived else "moored" if state.course.is_empty() else "transit" if not state.body.route.is_empty() else "blocked"
static func _open(sim,method:String)->void:
 var gate=_gate(sim)
 if gate.opened:return
 gate.opened=true;sim.mission.structures.erase(gate.closed_shape);sim._build_navigation();sim.opened_terrain(gate.closed_shape)
 sim.mission.warning_recipient.gate_method=method
 sim._noise(PANEL,650.,"WARNING SERVICE GATE",6.);sim.events.append({"type":"warning_gate","pos":PANEL})
static func delivered(sim)->void:
 if not applies(sim.mission):return
 sim.mission.warning_recipient.delivered=true
 if sim.mission.launch_context.facts.get("warning_chain","")=="service_local_receipt":_open(sim,"credential")
static func context(sim,unit:int=-1)->Dictionary:
 if not applies(sim.mission):return {}
 var id=sim.selected if unit<0 else unit;var craft=sim.units[id];var state=sim.mission.warning_recipient
 var gate={"ready":false,"reason":"Reach service release within 60m","pos":PANEL}
 var depart={"ready":false,"reason":"Receive the local warning reply first"}
 if not sim.outcome.is_empty():gate.reason="Dive ended";depart.reason="Dive ended"
 elif not craft.alive:gate.reason="Craft lost";depart.reason="Craft lost"
 else:
  if craft.pos.distance_to(PANEL)>60:pass
  elif _gate(sim).opened:gate.reason="Service passage open"
  elif not sim.captures[id].is_empty() or not sim.module_recovery_status().jobs[id].is_empty():gate.reason="Finish this craft's active work first"
  elif not sim.line_clear(craft.pos,PANEL):gate.reason="Terrain blocks service release"
  elif craft.vel.length()>=2:gate.reason="Settle below 2m/s"
  else:gate.ready=true;gate.reason="OPEN SERVICE · audible 650m / 6s"
  if state.delivered and _ack(sim):
   if not state.body.alive:depart.reason="Recipient lost"
   elif state.arrived:depart.reason="Recipient at refuge"
   elif not state.course.is_empty() and not state.body.route.is_empty():depart.reason="Recipient already in transit"
   elif craft.pos.distance_to(state.body.pos)>240 or not sim.line_clear(craft.pos,state.body.pos):depart.reason="Reach recipient within 240m with clear local link"
   elif craft.vel.length()>=12:depart.reason="Settle below 12m/s"
   elif not sim.captures[id].is_empty() or not sim.module_recovery_status().jobs[id].is_empty():depart.reason="Finish this craft's active work first"
   else:depart.ready=true;depart.reason="Choose the ungated exposed course or open the sheltered service course"
 return {"gate":gate,"depart":depart}
static func open_gate(sim)->bool:
 var c=context(sim).get("gate",{})
 if not c.get("ready",false):sim.message=c.get("reason","Service unavailable");return false
 _open(sim,"manual");observe(sim);sim.message="Service passage opens · recipient still awaits a deliberate course";return true
static func depart(sim,course:String)->bool:
 if not applies(sim.mission):return false
 if course not in COURSES:return false
 var c=context(sim).depart
 if not c.ready:sim.message=c.reason;return false
 if course=="sheltered" and not _gate(sim).opened:sim.message="Open the north service gate before choosing the sheltered course";return false
 var state=sim.mission.warning_recipient;var route=[];var from:Vector2=state.body.pos
 for point in COURSES[course]:
  var leg=sim.path(from,point)
  if leg.is_empty():sim.message="Recipient course blocked · clear the physical passage";return false
  route.append_array(leg);from=point
 for n in route.size():route[n].stop=n==route.size()-1
 state.body.route=route;state.course=course
 sim.events.append({"type":"warning_departure","pos":state.body.pos});sim.message="Warning recipient departs by "+course+" course · observe its refuge arrival, then recover Quietus";return true
static func observe(sim)->void:
 if not applies(sim.mission):return
 var state=sim.mission.warning_recipient;var vessel=state.body
 if sim.visible(PANEL):state.gate_seen={"opened":_gate(sim).opened,"time":sim.elapsed}
 if not sim.visible(vessel.pos):return
 state.seen={"pos":vessel.pos,"angle":vessel.angle,"hull":vessel.hull,"alive":vessel.alive,"phase":_phase(state),"time":sim.elapsed}
 if state.arrived and vessel.alive and not state.receipt:
  state.receipt=true;sim.events.append({"type":"warning_arrival","pos":vessel.pos});sim.message="Recipient arrival received at refuge · recover Quietus"
static func tick(sim,dt:float)->void:
 if not applies(sim.mission):return
 var state=sim.mission.warning_recipient
 if not state.body.alive or state.arrived or state.course.is_empty():return
 sim._move(state.body,dt,SPEED,false,false)
 if state.body.route.is_empty() and state.body.pos.distance_to(REFUGE)<16 and state.body.vel.length()<2:
  state.arrived=true;sim.events.append({"type":"warning_refuge","pos":state.body.pos})
static func damage(sim,amount:float)->void:
 var state=sim.mission.warning_recipient;var vessel=state.body
 vessel.hull=maxf(0.,vessel.hull-amount)
 if vessel.hull>0:return
 vessel.alive=false;vessel.vel=Vector2.ZERO;vessel.route.clear();observe(sim)
 sim.outcome="lost";sim.paused=true;sim.message="Warning recipient destroyed · the passage failed · retry the operation"
 sim.events.append({"type":"warning_recipient_loss","pos":vessel.pos})
static func complete(sim)->bool:return not applies(sim.mission) or sim.mission.warning_recipient.receipt
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.warning_recipient;var vessel={"known":not state.seen.is_empty(),"live":false}
 if vessel.known:
  vessel.live=sim.visible(state.body.pos)
  var seen=state.seen
  vessel.merge({"pos":state.body.pos if vessel.live else seen.pos,"angle":state.body.angle if vessel.live else seen.angle,"hull":state.body.hull if vessel.live else seen.hull,"alive":state.body.alive if vessel.live else seen.alive,"phase":_phase(state) if vessel.live else seen.phase,"age":0. if vessel.live else maxf(0.,sim.elapsed-seen.time),"name":"WARNING RECIPIENT"})
 var gate_seen=state.gate_seen
 return {"recipient":vessel,"course":state.course if _ack(sim) else "","courses":COURSES.duplicate(true) if _ack(sim) else {},"arrived":state.arrived if state.receipt else false,"receipt":state.receipt,"informed":_ack(sim),"gate":{"pos":PANEL,"rect":GATE,"known":not gate_seen.is_empty(),"opened":gate_seen.get("opened",false)},"actions":context(sim)}
static func recovered_facts(m:Dictionary)->Dictionary:
 if not applies(m) or not m.get("recovered",false) or not m.warning_recipient.receipt:return {}
 var state=m.warning_recipient
 return {"warning_arrival":state.course,"warning_arrival_hull":str(roundi(state.body.hull)),"warning_service":state.gate_method}
static func _number(value)->bool:return (value is float or value is int) and is_finite(value)
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if m.get("id")!=13:return not m.has("warning_recipient")
 if not applies(m):return false
 if not m.get("signal_sources") is Array or m.signal_sources.size()!=1 or not m.signal_sources[0] is Dictionary:return false
 var state=m.warning_recipient
 if not state is Dictionary or not state.has_all(["body","delivered","course","arrived","receipt","seen","gate_seen","gate_method"]):return false
 if not state.delivered is bool or not state.arrived is bool or not state.receipt is bool or state.course not in ["","exposed","sheltered"] or not state.seen is Dictionary or not state.gate_seen is Dictionary or state.gate_method not in ["","manual","credential"]:return false
 var vessel=state.body
 if not vessel is Dictionary or not vessel.get("pos") is Vector2 or not vessel.get("vel") is Vector2 or not vessel.pos.is_finite() or not vessel.vel.is_finite() or not Region.contains(vessel.pos,m.world_size) or not vessel.get("alive") is bool or not vessel.get("route") is Array:return false
 if not (vessel.get("angle") is float or vessel.get("angle") is int) or not is_finite(vessel.angle):return false
 if state.delivered!=m.signal_sources[0].get("active",false):return false
 if not (vessel.get("hull") is float or vessel.get("hull") is int) or not is_finite(vessel.hull) or vessel.hull<0 or vessel.hull>100 or vessel.alive!=(vessel.hull>0):return false
 for point in vessel.route:
  if not point is Dictionary or not point.get("pos") is Vector2 or not Region.contains(point.pos,m.world_size) or not point.get("stop") is bool:return false
 if state.course.is_empty() and (vessel.pos!=BERTH or not vessel.route.is_empty() or state.arrived or state.receipt):return false
 if not state.course.is_empty() and not state.delivered:return false
 # Arrival and its receipt are historical facts; a later beam can still kill.
 if state.arrived and (vessel.pos.distance_to(REFUGE)>=16 or not vessel.route.is_empty()):return false
 if not vessel.alive and data.get("outcome","")!="lost":return false
 if state.receipt and (not state.arrived or state.seen.is_empty()):return false
 if not state.seen.is_empty():
  if not state.seen.has_all(["pos","angle","hull","alive","phase","time"]) or not state.seen.pos is Vector2 or not state.seen.pos.is_finite() or not _number(state.seen.time) or not _number(state.seen.angle) or not _number(state.seen.hull) or not state.seen.alive is bool or state.seen.phase not in ["lost","refuge","moored","transit","blocked"] or state.seen.time<0 or state.seen.time>data.elapsed:return false
 if not state.gate_seen.is_empty() and (not state.gate_seen.has_all(["opened","time"]) or not state.gate_seen.opened is bool or not _number(state.gate_seen.time) or state.gate_seen.time<0 or state.gate_seen.time>data.elapsed):return false
 if m.get("physical_gates",[]).size()!=1 or m.physical_gates[0].closed_shape!=GATE or not m.physical_gates[0].opened is bool:return false
 if m.physical_gates[0].opened!=(not state.gate_method.is_empty()) or (GATE in m.get("structures",[]))==m.physical_gates[0].opened:return false
 if state.gate_method=="credential" and (not state.delivered or m.launch_context.facts.get("warning_chain","")!="service_local_receipt"):return false
 return data.get("outcome","")!="won" or state.receipt
