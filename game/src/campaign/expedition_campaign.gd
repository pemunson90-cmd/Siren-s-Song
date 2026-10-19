extends RefCounted
const FIELD_RECORDS=["divergence_deep","divergence_shelf","divergence_rendezvous","divergence_warning"]
# One concrete fork. Tutorial indices/unlocked remain the original0..5 contract.
static func available(completed:Array,progress:Dictionary)->Array:
 if not [0,1,2,3,4,5].all(func(id):return id in completed):return []
 var result=[6]
 for route in progress.get("routes",[]):result.append(7 if route=="deep" else 8)
 return result
static func recover(previous:Dictionary,mission:Dictionary)->Dictionary:
 var result=previous.duplicate(true)
 if mission.get("expedition_revision",0)!=1 or not mission.get("recovered",false):return result
 if mission.id!=6 and (result.is_empty() or not valid(result)):return result
 if result.is_empty():result={"version":1,"route":"","routes":[],"facts":{},"completed":[],"remote_decoy":false}
 if mission.id not in result.completed:result.completed.append(mission.id)
 for fact in mission.expedition_facts:result.facts[fact]=mission.expedition_facts[fact]
 if mission.id==6:
  result.route=mission.chosen_route
  if result.route not in result.routes:result.routes.append(result.route)
  result.remote_decoy=true
 return result
static func valid(value)->bool:
 if not value is Dictionary:return false
 if value.is_empty():return true
 if not value.has_all(["version","route","routes","facts","completed","remote_decoy"]) or value.version!=1 or value.route not in ["deep","shelf"] or not value.routes is Array or not value.facts is Dictionary or not value.completed is Array or not value.remote_decoy is bool:return false
 if value.routes.is_empty() or value.routes.size()>2 or value.route not in value.routes:return false
 var unique={}
 for route in value.routes:unique[route]=true
 if unique.size()!=value.routes.size():return false
 for route in value.routes:
  if route not in ["deep","shelf"] or not value.facts.has(route):return false
 for fact in value.facts:
  if fact not in ["deep","shelf","rendezvous"] or not value.facts[fact] is String:return false
 for id in value.completed:
  if id not in [6,7,8] or (id==7 and "deep" not in value.routes) or (id==8 and "shelf" not in value.routes):return false
 return 6 in value.completed and value.remote_decoy and value.facts.has(value.route)
