extends RefCounted
const OperationsCatalog=preload("res://src/campaign/operation_catalog.gd")
# Witness-guided environmental work. The tow follows the actual body trail;
# only authored seating unfolds a screen into solid/acoustic geometry.
const DEEP_FLOAT=Vector2(1840,1040)
const TRACE_BLOCK=Rect2(1760,1060,160,40)
const DEPARTURE_SHUTTER=Rect2(2120,740,60,120)
const SHELF_SCREEN=Vector2(1940,1070)
const SCREEN=Rect2(1980,940,60,260)
const REPLY_DEEP=Vector2(2180,800)
const REPLY_SHELF=Vector2(2300,970)
const RANGE=65.0
static func applies(m:Dictionary)->bool:return OperationsCatalog.supports(m.get("id",-1),"witness") and m.has("concealed_harbour")
static func build(m:Dictionary)->void:
 var thread="shelf" if m.launch_context.get("thread","")=="shelf" else "deep"
 m["concealed_harbour"]={"thread":thread,"known":false,"phase":"waiting","pos":SHELF_SCREEN if thread=="shelf" else DEEP_FLOAT,"carrier":-1,"trail":[],"placement":"","connected":thread=="deep","heard_departures":0,"next_trace":0.0,"next_noise":0.0,"reply_time":-1.0,"receipt":false,"account":"","station_seen":{},"folded":false,"reply_sent":false}
 if thread=="shelf":
  m.rocks.append_array([Rect2(1980,860,420,80),Rect2(1980,1200,420,100),Rect2(2080,1000,160,80)])
  m.structures.append(SCREEN)
 else:
  m.rocks.append_array([Rect2(1660,920,100,320),Rect2(1920,920,480,220),Rect2(2220,500,180,400)])
  m.structures.append_array([TRACE_BLOCK,DEPARTURE_SHUTTER])
static func complete(sim)->bool:return not applies(sim.mission) or (sim.mission.concealed_harbour.receipt and (sim.mission.concealed_harbour.thread!="deep" or not sim.mission.structures.has(TRACE_BLOCK)))
static func reply_pos(state:Dictionary)->Vector2:return REPLY_DEEP if state.thread=="deep" else REPLY_SHELF
static func placements(state:Dictionary)->Array:
 if state.thread=="deep":return []
 return [{"id":"service","name":"CLEAR SERVICE MOUTH","pos":Vector2(1900,970),"description":"Park the folded screen on the western service cradle. Both approaches stay open: the northern entrance is short and direct, and carries sound directly into the bunker."},{"id":"baffle","name":"SHELTERED LOWER MOUTH","pos":Vector2(2010,970),"description":"Unfold the screen across the north entrance. Close the short straight approach; the longer lower turn stays open and bends sound around the inner wall. This placement cannot trap Quietus."}]
static func account(sim)->String:
 var state=sim.mission.concealed_harbour;var facts=sim.mission.launch_context.get("facts",{})
 if state.thread=="deep":
  var text="KESTREL'S SONAR OPERATOR: That float straddles the trench mouth. Its submerged pickup feeds berthing traffic into a surface trace: listening hardware, nothing more. Take its tow eye, then actually haul it at least90m from the socket: the surface trace breaks and its taut cable clears the mouth. Merely attaching and releasing does nothing. Cast off in clear water once the cable is clear. The crew below can confirm their own disconnected line and open the local shutter."
  if facts.has("rendezvous"):text+=" Your berthing tender account names the same correction channel; the float copied that traffic without being part of it."
  return text
 var text="KESTREL'S SONAR OPERATOR: The blast door is not the only thing in the way. The collapsed screen blocks the bunker mouth. Tow its folded boom to either cradle: preserve the short open service approach, or unfold a sound baffle and take the longer lower turn."
 if facts.has("shelf_warning"):text+=" Your warning bought the watch crew time to seal the bunker; the lit sections behind this mouth are theirs."
 if facts.get("warning_chain","")=="service_local_receipt":text+=" You verified a local service receipt at the warning plant. That preparation did not clear this physical mouth."
 return text
static func reveal(sim)->void:
 if not applies(sim.mission):return
 var state=sim.mission.concealed_harbour
 if state.known or sim.mission.witness_evacuation.state not in ["carried","landed","salvage"]:return
 state.known=true;state.phase="ready";state.account=account(sim)
 sim.message="Living witness has practical knowledge · open WITNESS ACCOUNT from the selected craft orders";sim.events.append({"type":"witness_account","pos":sim.mission.witness_evacuation.pos})
static func context(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.concealed_harbour;var body=sim.units[sim.selected]
 var result={"ready":false,"reason":"Rescue the witness to learn the local problem","tow":false,"release":false,"seats":[]}
 if not state.known:return result
 result.reason="Bring Quietus within 65m of the tow eye, clear line and below 2m/s"
 if state.phase=="seated":result.reason="Environmental work complete · receive the local station reply";return result
 if state.phase=="towing":
  result.release=sim.selected==state.carrier;result.reason="Tow attached · actual trail · cruise40m/s / silent26m/s; moving cable audible"
  for seat in placements(state):
   var option=seat.duplicate(true);option.ready=sim.selected==state.carrier and body.alive and body.vel.length()<2 and body.pos.distance_to(seat.pos)<=RANGE and state.pos.distance_to(seat.pos)<=110 and sim.segment_safe(body.pos,seat.pos,12) and sim.segment_safe(state.pos,seat.pos,12)
   option.reason="Move the attached tow within65m of this cradle and settle"
   if option.id=="baffle" and sim.units.any(func(u):return u.alive and Rect2(2040,940,200,60).grow(12).has_point(u.pos)):
    option.ready=false;option.reason="Move every living craft clear of the unfolding north screen"
   var pod=sim.mission.witness_evacuation
   if option.id=="baffle" and pod.state=="salvage" and Rect2(2040,940,200,60).grow(12).has_point(pod.pos):
    option.ready=false;option.reason="Recover the occupied pressure pod clear of the unfolding north screen"
   result.seats.append(option)
  return result
 # Quietus has the towing hardpoint. Drones remain independent scouts/receivers,
 # carriers of the witness, defenders, and optional sluice workers.
 if sim.selected!=0:result.reason="Quietus has the towing hardpoint; drones can scout, receive, protect or carry the witness"
 elif not body.alive or not sim.outcome.is_empty():result.reason="Quietus unavailable"
 elif body.pos.distance_to(state.pos)>RANGE:pass
 elif not sim.segment_safe(body.pos,state.pos,12):result.reason="Terrain blocks the tow eye"
 elif body.vel.length()>=2:result.reason="Settle below 2m/s to attach"
 elif not sim.captures[0].is_empty() or not sim.module_recovery_status().jobs[0].is_empty() or sim._witness_recovery_busy(0):result.reason="Finish active work first"
 else:result.ready=true;result.tow=true;result.reason="ATTACH TOW · no tool consumed · movement drags audibly; release anywhere in clear water"
 return result
static func command(sim,action:String)->bool:
 if not applies(sim.mission):return false
 var state=sim.mission.concealed_harbour;var c=context(sim)
 if action=="attach":
  if not c.tow:sim.message=c.reason;return false
  if state.thread=="shelf" and sim.mission.structures.has(SCREEN):
   sim.mission.structures.erase(SCREEN);state.folded=true;sim._build_navigation();sim.opened_terrain(SCREEN)
  state.phase="towing";state.carrier=0;state.trail=[sim.units[0].pos]
  sim._noise(state.pos,420.0,"TOW COUPLING",2.0);sim.message="Tow attached · HAUL90m to pull the trace from its socket" if state.thread=="deep" else "Screen folded onto tow · bunker mouth physically clear";return true
 if action=="release":
  if not c.release:return false
  state.phase="ready";state.carrier=-1;state.trail=[];sim.message="Tow released at its actual water position · reattach locally";return true
 var seats=c.seats.filter(func(p):return p.id==action)
 if seats.is_empty():sim.message="Bring the attached tow locally to its cradle and settle";return false
 if not seats[0].ready:sim.message=seats[0].reason;return false
 state.phase="seated";state.carrier=-1;state.trail=[];state.placement=action;state.pos=seats[0].pos;state.reply_time=sim.elapsed+2.0 if state.thread=="shelf" else state.reply_time
 if state.thread=="shelf" and action=="baffle":
  sim.mission.structures.append(Rect2(2040,940,200,60));sim._build_navigation();sim.opened_terrain(Rect2(1800,860,440,400))
 sim._noise(state.pos,460.0,"TOW SEATED",2.0);sim.events.append({"type":"concealed_seated","pos":state.pos});sim.message="Tow seated · wait for a received local station acknowledgement";return true
static func speed(sim,speed:float,unit:Dictionary)->float:
 if applies(sim.mission) and sim.mission.concealed_harbour.phase=="towing" and unit.name=="QUIETUS":return minf(speed,26.0 if unit.silent else 40.0)
 return speed
static func tick(sim,dt:float)->void:
 if not applies(sim.mission):return
 reveal(sim);var state=sim.mission.concealed_harbour
 if state.known and (not sim.passive_receivers(reply_pos(state)).is_empty() or preload("res://src/simulation/world_region.gd").survey_visible(sim,reply_pos(state))):
  state.station_seen={"time":sim.elapsed,"open":state.reply_time>=0 and sim.elapsed>=state.reply_time}
 # This real connected float hears the authored departure station, then repeats
 # the sampled contact over its physical surface trace. Breaking cable ends it.
 if state.connected and sim.elapsed>=state.next_trace:
  state.next_trace=sim.elapsed+6.0
  if not sim.acoustic_paths.arrivals(state.pos,Vector2(1840,800),850.0).is_empty():state.heard_departures+=1
 if state.phase=="towing":
  var body=sim.units[0]
  if not body.alive:state.phase="ready";state.carrier=-1;state.trail=[];return
  if state.trail.is_empty() or state.trail.back().distance_to(body.pos)>=3:state.trail.append(body.pos)
  # Pay out a short cable along actual travelled water, never a chord through rock.
  var remaining=0.0;var previous=state.pos
  for p in state.trail:remaining+=previous.distance_to(p);previous=p
  var travel=maxf(0,remaining-35.0)
  while travel>.001 and not state.trail.is_empty():
   var target:Vector2=state.trail[0];var distance=state.pos.distance_to(target)
   if distance<=travel:state.pos=target;state.trail.pop_front();travel-=distance
   else:state.pos=state.pos.move_toward(target,travel);travel=0
  if body.vel.length()>1 and sim.elapsed>=state.next_noise:
   state.next_noise=sim.elapsed+.3;sim._noise(state.pos,180.0+body.vel.length()*9.0,"TOW DRAG",.35)
 if state.thread=="deep" and state.connected and state.pos.distance_to(DEEP_FLOAT)>=90.0:
  state.connected=false;state.reply_time=sim.elapsed+2.0
  sim.mission.structures.erase(TRACE_BLOCK);sim._build_navigation();sim.opened_terrain(TRACE_BLOCK)
  sim.message="Trace hauled out of its socket · taut cable clears the mouth · receive the local station reply"
 if state.thread=="deep" and not state.connected and state.reply_time>=0 and sim.elapsed>=state.reply_time and sim.mission.structures.has(DEPARTURE_SHUTTER):
  sim.mission.structures.erase(DEPARTURE_SHUTTER);sim._build_navigation();sim.opened_terrain(DEPARTURE_SHUTTER)
 if state.reply_time>=0 and not state.reply_sent and sim.elapsed>=state.reply_time:
  state.reply_sent=true;sim._noise(reply_pos(state),1200.0,"SURVIVORS REPLY" if state.thread=="deep" else "BUNKER WATCH REPLY",2.0)
 if state.reply_time>=0 and not state.receipt and sim.elapsed>=state.reply_time:
  for id in sim.units.size():
   if not sim.units[id].alive:continue
   var range=1200.0 if sim.elapsed<=state.reply_time+2.0 else sim.passive_range(id) if sim.line_clear(sim.units[id].pos,reply_pos(state)) else 0.0
   var arrivals=sim.acoustic_paths.arrivals(sim.units[id].pos,reply_pos(state),range)
   if arrivals.is_empty():continue
   state.receipt=true
   sim.events.append({"type":"return_received","receiver":id,"direction":sim.units[id].pos.direction_to(arrivals[0].goal),"identity":"return","time":sim.elapsed})
   sim.message="SURVIVORS: Surface trace current is zero. Our shutter is open; the first deep crossing can begin." if state.thread=="deep" else "BUNKER WATCH: Mouth clear. The watch crew is coming out through the cleared approach."
   break
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.concealed_harbour
 if not state.known:return {"known":false,"text":"Rescue the witness to learn the local problem"}
 return {"known":true,"thread":state.thread,"phase":state.phase,"pos":state.pos,"carrier":state.carrier,"placement":state.placement,"connected":state.connected,"receipt":state.receipt,"account":state.account,"seats":placements(state),"reply_pos":reply_pos(state),"actions":context(sim),"text":("SURFACE TRACE CONNECTED" if state.connected else "TRACE PHYSICALLY DISCONNECTED") if state.thread=="deep" else ("SHELTER MOUTH BLOCKED" if state.phase=="ready" and sim.mission.structures.has(SCREEN) else "SHELTER MOUTH CLEAR"),"station_seen":state.station_seen.duplicate(true)}
static func recovered_facts(m:Dictionary)->Dictionary:
 if not applies(m) or not m.concealed_harbour.receipt:return {}
 var state=m.concealed_harbour
 return {"concealed_consequence":"deep_trace_severed" if state.thread=="deep" else "shelf_"+state.placement}
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if not OperationsCatalog.supports(m.get("id",-1),"witness"):return not m.has("concealed_harbour")
 var s=m.get("concealed_harbour",{})
 if not s is Dictionary or not s.has_all(["thread","known","phase","pos","carrier","trail","placement","connected","heard_departures","next_trace","next_noise","reply_time","receipt","account","station_seen","folded","reply_sent"]):return false
 if s.thread not in ["deep","shelf"] or not s.known is bool or s.phase not in ["waiting","ready","towing","seated"] or not s.pos is Vector2 or not s.pos.is_finite() or not Rect2(Vector2.ZERO,m.world_size).has_point(s.pos) or not s.carrier is int or not s.trail is Array or not s.connected is bool or not s.receipt is bool or not s.account is String:return false
 if not s.folded is bool or not s.reply_sent is bool or not s.station_seen is Dictionary or not s.heard_departures is int or s.heard_departures<0:return false
 for field in ["next_trace","next_noise","reply_time"]:
  if not (s[field] is int or s[field] is float) or not is_finite(s[field]):return false
 if not s.station_seen.is_empty() and (not s.station_seen.get("open") is bool or not (s.station_seen.get("time") is float or s.station_seen.get("time") is int) or s.station_seen.time<0 or s.station_seen.time>data.get("elapsed",0)):return false
 for p in s.trail:
  if not p is Vector2 or not p.is_finite() or not Rect2(Vector2.ZERO,m.world_size).has_point(p):return false
 if s.phase=="towing" and (s.carrier!=0 or not data.units[0].alive):return false
 if s.phase!="towing" and (s.carrier!=-1 or not s.trail.is_empty()):return false
 if s.receipt and ((s.thread=="shelf" and s.phase!="seated") or (s.thread=="deep" and s.connected)):return false
 if s.phase=="seated" and not placements(s).any(func(p):return p.id==s.placement):return false
 return data.get("outcome","")!="won" or s.receipt

static func expected_structures(m:Dictionary,initial:Array,time:float)->Array:
 var result=initial.duplicate();var s=m.get("concealed_harbour",{})
 if s.is_empty():return result
 if s.get("thread")=="shelf":
  if s.get("folded",false):result.erase(SCREEN)
  if s.get("phase")=="seated" and s.get("placement")=="baffle":result.append(Rect2(2040,940,200,60))
 else:
  if not s.get("connected",true):result.erase(TRACE_BLOCK)
  if s.get("reply_time",-1)>=0 and time>=s.reply_time:result.erase(DEPARTURE_SHUTTER)
 return result
