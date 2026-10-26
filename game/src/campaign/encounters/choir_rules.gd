extends RefCounted
# Iron Choir 22-29 rule tables: what each operation asks of the player beyond the shared
# tow/winch/lock machinery. industrial_jobs.gd reads these; site positions live in the operation.
# 22 freight intercept: the released sled runs a lane at SLED_SPEED and jams (taking damage)
#    at the lane's closed gate until that gate site is worked. West lane gate lock_a, east lock_b.
# 23 lock sequence: NEEDS orders the three equalizers.
# 25 escort: the sled only advances while a living craft is within ESCORT metres.
# 26 surge: lifting the spindle restarts the hammer; DELAY seconds later the west mouth seals.
# 27 chock and slide: a loose counterweight slides back south unless chocked at the ledge.
# 28 decompression stops: the occupied bell must be towed to both stations before landing.
# 29 split: the east reconnect only works within WINDOW seconds of throwing the far breaker.
const NEEDS={23:{"lock_b":["lock_a"],"lock_c":["lock_b"]},27:{"cradle":["lock_a"]},28:{"lock_b":["lock_a"],"land":["lock_a","lock_b"]},29:{"reconnect":["lock_c"]}}
const WITH_LOAD={27:["lock_a"],28:["lock_a","lock_b"]}
const LANE_GATE={22:{"west":"lock_a","east":"lock_b"}}
const SLED_SPEED={22:36.,25:18.}
const ESCORT={25:200.}
const JAM_RATE=4.
const SURGE={26:{"delay":100.,"seal":Rect2(1100,350,150,150)}}
const WINDOW={29:150.}
const SLIDE={27:{"speed":6.,"chock":"lock_a"}}
static func site(state:Dictionary,id:String)->Dictionary:
 for s in state.sites:
  if s.id==id:return s
 return {}
static func needs_missing(mid:int,state:Dictionary,action:String)->String:
 for need in NEEDS.get(mid,{}).get(action,[]):
  if not site(state,need).get("done",false):return need
 return ""
# Site id of the closed lane gate holding a transiting sled, or "".
static func jam(mid:int,state:Dictionary,load:Dictionary)->String:
 var gate=LANE_GATE.get(mid,{}).get(state.route_choice,"")
 if gate.is_empty() or load.state!="transit":return ""
 var s=site(state,gate)
 return gate if not s.is_empty() and not s.done and load.pos.distance_to(s.pos)<70. else ""
static func escorted(sim,load:Dictionary)->bool:
 if not ESCORT.has(sim.mission.id):return true
 return sim.units.any(func(u):return u.alive and u.pos.distance_to(load.pos)<=ESCORT[sim.mission.id])
# The chocked ledge keeps a loose counterweight; below it (or without the chock) it slides south.
static func slide(sim,state:Dictionary,load:Dictionary,dt:float):
 var rule=SLIDE.get(sim.mission.id,{})
 if rule.is_empty() or load.state!="free":return
 var chock=site(state,rule.chock)
 if chock.done and load.pos.y<=chock.pos.y+60.:return
 if load.pos.y>=1750.:return
 var step=load.pos+Vector2(0,rule.speed*dt)
 if sim.Depth.clear(sim,load.pos,step,load.band,16.):load.pos=step
static func tick_state(sim,state:Dictionary):
 var mid=sim.mission.id
 if SURGE.has(mid) and state.stamp>=0. and not state.sealed and sim.elapsed-state.stamp>=SURGE[mid].delay:
  var seal:Rect2=SURGE[mid].seal
  if not sim.units.any(func(u):return u.alive and seal.grow(70.).has_point(u.pos)):
   state.sealed=true;sim.mission.structures.append(seal);sim._build_navigation();sim.message="Hammer cycle seals the west mouth"
 if WINDOW.has(mid) and state.stamp>=0. and state.choice.is_empty() and sim.elapsed-state.stamp>WINDOW[mid] and not state.jobs.any(func(j):return not j.is_empty() and j.action=="reconnect"):
  state.stamp=-1.;site(state,"lock_c").done=false;sim.message="Far breaker dropped out; throw it again"
static func notes(sim,state:Dictionary)->String:
 var mid=sim.mission.id;var load=state.load
 var live=not state.seen.is_empty() and sim.elapsed-state.seen.time<1.
 match mid:
  22:
   var gate=jam(mid,state,load)
   if not gate.is_empty() and live:return "FREIGHT JAMMED AT LANE GATE · work "+gate.to_upper()
   if load.get("state","")=="transit" and not live:return "FREIGHT RUNNING UNOBSERVED · open the lane gate ahead of it"
  25:
   if load.get("state","")=="transit" and live:return "SLED ESCORTED" if escorted(sim,load) else "SLED HOLDING FOR ESCORT"
  26:
   if state.sealed:return "WEST MOUTH SEALED · COOLING RELEASE is the other way out"
   if state.stamp>=0.:return "HAMMER RESTARTED · west mouth seals in %ds"%maxi(0,ceili(SURGE[mid].delay-(sim.elapsed-state.stamp)))
  29:
   if state.stamp>=0. and state.choice.is_empty():return "FAR BREAKER HELD · %ds to RECONNECT"%maxi(0,ceili(WINDOW[mid]-(sim.elapsed-state.stamp)))
 return ""
