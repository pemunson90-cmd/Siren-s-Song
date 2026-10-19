extends RefCounted
# Future authored operations stay staged until their physical hooks and ordinary play are reviewed.
const RESOLUTION_READY=true
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
const FIELD_RECORDS=["resolution_witness_sluice","resolution_warning_transmission","divergence_warning_reply","wake_packet","wake_repeater","chain_west","chain_east","chain_relay","divergence_deep","divergence_shelf","divergence_rendezvous","divergence_warning","divergence_confluence_packet","divergence_confluence_repeater","divergence_witness_packet","divergence_witness_repeater","resolution_warning_west","resolution_warning_east","resolution_warning_uplink"]
# One concrete fork. Tutorial indices/unlocked remain the original0..5 contract.
static func available(completed:Array,progress:Dictionary)->Array:
 if not [0,1,2,3,4,5].all(func(id):return id in completed):return []
 var result=[6]
 for route in progress.get("routes",[]):result.append(7 if route=="deep" else 8)
 for id in [9,10]:
  if id-2 in progress.get("completed",[]):result.append(id)
 if RESOLUTION_READY and (9 in progress.get("completed",[]) or 10 in progress.get("completed",[])):result.append(11)
 var route=progress.get("facts",{}).get("confluence_route","")
 if RESOLUTION_READY and 11 in progress.get("completed",[]) and route in ["concealed","overt"]:result.append(12 if route=="concealed" else 13)
 return result
static func recover(previous:Dictionary,mission:Dictionary)->Dictionary:
 var result=previous.duplicate(true)
 if mission.get("expedition_revision",0) not in [1,2] or not mission.get("recovered",false):return Consequences.retain(result,mission)
 if mission.id!=6 and (result.is_empty() or not valid(result)):return result
 if result.is_empty():result={"version":1,"route":"","routes":[],"facts":{},"completed":[]}
 if mission.id not in result.completed:result.completed.append(mission.id)
 for fact in mission.expedition_facts:result.facts[fact]=mission.expedition_facts[fact]
 if mission.id==6:
  result.route=mission.chosen_route
  if result.route not in result.routes:result.routes.append(result.route)
 return Consequences.recovered(result,mission)
static func valid(value)->bool:
 if not value is Dictionary:return false
 if value.is_empty():return true
 if not value.has_all(["version","route","routes","facts","completed"]) or value.version not in [1,2] or value.route not in ["deep","shelf"] or not value.routes is Array or not value.facts is Dictionary or not value.completed is Array:return false
 if value.routes.is_empty() or value.routes.size()>2 or value.route not in value.routes:return false
 var unique={}
 for route in value.routes:unique[route]=true
 if unique.size()!=value.routes.size():return false
 for route in value.routes:
  if route not in ["deep","shelf"] or not value.facts.has(route):return false
 for fact in value.facts:
  if not fact is String or not value.facts[fact] is String or (value.version==1 and fact not in ["deep","shelf","rendezvous"]):return false
 if value.completed.size()>8 or value.facts.size()>16:return false
 var seen_ids=[]
 for id in value.completed:
  if id in seen_ids:return false
  seen_ids.append(id)
  if id not in ([6,7,8] if value.version==1 else [6,7,8,9,10,11,12,13]) or (id==7 and "deep" not in value.routes) or (id==8 and "shelf" not in value.routes):return false
 if value.version==2:
  if not Consequences.valid(value):return false
  if 9 in value.completed and 7 not in value.completed:return false
  if 10 in value.completed and 8 not in value.completed:return false
  if 11 in value.completed and not (9 in value.completed or 10 in value.completed):return false
  if 12 in value.completed and (11 not in value.completed or value.facts.get("confluence_route","")!="concealed"):return false
  if 13 in value.completed and (11 not in value.completed or value.facts.get("confluence_route","")!="overt"):return false
  if value.facts.has("confluence_route") and (11 not in value.completed or value.facts.confluence_route not in ["concealed","overt"]):return false
 return 6 in value.completed and value.facts.has(value.route)

static func continuations(progress:Dictionary,mission_id:int)->Array:
 var targets={6:[7 if progress.get("route","")=="deep" else 8],7:[9],8:[10],9:[11],10:[11],11:[12 if progress.get("facts",{}).get("confluence_route","")=="concealed" else 13]}
 var accessible=available([0,1,2,3,4,5],progress)
 return targets.get(mission_id,[]).filter(func(id):return id in accessible)
