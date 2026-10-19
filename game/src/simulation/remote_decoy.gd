extends RefCounted
# One inert pod for an equipped drone, paid from the ordinary decoy stock.
# Campaign code owns entitlement/configuration and the optional snapshot field.
# Explicit state keeps this helper independent of that serialization adapter.
const LEGACY_BOUNDS=Vector2(1600,960)
static func configure(unit:int)->Dictionary:
 return {"unit":unit,"pod":{}} if unit in [1,2] else {}

static func command(sim,state:Dictionary,order:String,args:Dictionary={})->bool:
 if order not in ["pod_place","pod_trigger"] or not _owner_ready(sim,state):return false
 if order=="pod_place":
  var point=args.get("point")
  if not state.pod.is_empty() or not sim.decoy_target_valid(point):return false
  sim.tools.decoy-=1;state.pod={"pos":point}
  sim.message="%s staged an inert decoy · trigger after withdrawal"%sim.units[state.unit].name
 else:
  if state.pod.is_empty():return false
  var point:Vector2=state.pod.pos
  state.pod={}
  sim._noise(point,1100,"DECOY",15.0)
  sim.events.append({"type":"decoy","pos":point})
  sim.message="Remote decoy transmitting · 15s · ordinary acoustic exposure"
 return true

static func feedback(sim,state:Dictionary)->Dictionary:
 var result={"equipped":false,"unit":-1,"owner_alive":false,"selected":false,"staged":false,"place_ready":false,"trigger_ready":false}
 if state.is_empty() or not _state_valid(state,_bounds(sim)) or state.unit>=sim.units.size():return result
 result.equipped=true;result.unit=state.unit;result.owner_alive=sim.units[state.unit].alive;result.selected=sim.selected==state.unit
 result.staged=not state.pod.is_empty()
 var ready=result.owner_alive and result.selected and sim.outcome.is_empty()
 result.place_ready=ready and not result.staged and sim.tools.decoy>0
 result.trigger_ready=ready and result.staged
 if result.staged:result["pos"]=state.pod.pos
 return result

static func valid(data:Dictionary,bounds:Vector2=LEGACY_BOUNDS)->bool:
 if not data.has("remote_decoy"):return true
 var state=data.remote_decoy
 if not _state_valid(state,bounds):return false
 if state.is_empty():return true
 var units=data.get("units")
 return units is Array and state.unit<units.size() and units[state.unit] is Dictionary

static func _bounds(sim)->Vector2:
 return sim.world_size() if sim.has_method("world_size") else LEGACY_BOUNDS

static func _owner_ready(sim,state:Dictionary)->bool:
 return not state.is_empty() and _state_valid(state,_bounds(sim)) and state.unit<sim.units.size() and sim.selected==state.unit and sim.units[state.unit].alive and sim.outcome.is_empty()

static func _state_valid(state:Variant,bounds:Vector2)->bool:
 if not state is Dictionary:return false
 if state.is_empty():return true
 if state.size()!=2 or not state.has_all(["unit","pod"]) or not state.unit is int or state.unit not in [1,2] or not state.pod is Dictionary:return false
 if not bounds.is_finite() or bounds.x<=12 or bounds.y<=12:return false
 if state.pod.is_empty():return true
 if state.pod.size()!=1 or not state.pod.get("pos") is Vector2:return false
 var point:Vector2=state.pod.pos
 return point.is_finite() and Rect2(Vector2(6,6),bounds-Vector2(12,12)).has_point(point)
