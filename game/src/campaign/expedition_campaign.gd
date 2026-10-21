extends RefCounted
# Future authored operations stay staged until their physical hooks and ordinary play are reviewed.
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
# One concrete fork. Tutorial indices/unlocked remain the original0..5 contract.
static func available(completed:Array,progress:Dictionary)->Array:
 if not [0,1,2,3,4,5].all(func(id):return id in completed):return []
 return Catalog.campaign_ids().filter(func(id):return Catalog.accessible(id,progress))

static func recover(previous:Dictionary,mission:Dictionary)->Dictionary:
 var result=previous.duplicate(true)
 if not mission.get("id") is int or mission.id not in Catalog.campaign_ids() or not Catalog.valid_facts(mission.id,mission.get("expedition_facts",{})):return result
 if mission.get("expedition_revision",0) not in [1,2] or not mission.get("recovered",false):return Consequences.retain(result,mission)
 if mission.id!=6 and (result.is_empty() or not valid(result) or mission.id not in available([0,1,2,3,4,5],result)):return result
 if not mission.get("objectives") is Array or (mission.objectives.is_empty() and not Catalog.supports(mission.id,"iron_choir")) or not mission.objectives.all(func(o):return o.get("captured",false) or o.get("optional",false)):return result
 for site in mission.get("required_site_ids",[]):
  if not mission.objectives.any(func(o):return o.get("site_id","")==site and o.get("captured",false)):return result
 if Catalog.supports(mission.id,"iron_choir") and not preload("res://src/simulation/industrial_jobs.gd").complete_mission(mission):return result
 if Catalog.supports(mission.id,"warning_plant") and mission.get("warning_chain",{}).get("result",{}).is_empty():return result
 if Catalog.supports(mission.id,"witness") and (mission.get("witness_evacuation",{}).get("state","")!="landed" or not mission.get("concealed_harbour",{}).get("receipt",false)):return result
 if Catalog.supports(mission.id,"recipient") and not mission.get("warning_recipient",{}).get("receipt",false):return result
 if result.is_empty():result={"version":1,"route":"","routes":[],"facts":{},"completed":[]}
 var first_recovery=mission.id not in result.completed
 if first_recovery:result.completed.append(mission.id)
 if first_recovery:
  for fact in mission.expedition_facts:result.facts[fact]=mission.expedition_facts[fact]
 if mission.id==6:
  if result.route.is_empty():result.route=mission.chosen_route
  if result.route not in result.routes:result.routes.append(result.route)
 result=Consequences.recovered(result,mission)
 if mission.id==9 and first_recovery and mission.has("wake_crossing"):
  result.facts["wake_crossing"]="repeater_played" if mission.wake_crossing.played_at>=0 else "repeater_unused"
 if mission.id==8 and first_recovery:
  var shelter=preload("res://src/simulation/shelf_habitat.gd").result(mission)
  if not shelter.is_empty():result.facts["shelf_warning"]=shelter
 var ending=preload("res://src/campaign/endings.gd").resolve(result)
 if not ending.is_empty():result["ending"]=ending.id
 return result
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
  if fact not in Catalog.fact_keys() or not value.facts[fact] is String or (value.version==1 and fact not in ["deep","shelf","rendezvous"]):return false
 if value.completed.size()>Catalog.campaign_ids().size() or value.facts.size()>Catalog.fact_keys().size():return false
 var seen_ids=[]
 for id in value.completed:
  if not id is int or id in seen_ids:return false
  seen_ids.append(id)
  if id not in ([6,7,8] if value.version==1 else Catalog.campaign_ids()) or (id==7 and "deep" not in value.routes) or (id==8 and "shelf" not in value.routes):return false
 if value.version==2:
  if not Consequences.valid(value):return false
  for id in value.completed:
   if not Catalog.prerequisites_met(id,value.completed):return false
   var definition=Catalog.definition(id)
   if not definition.route.is_empty() and definition.route not in value.routes:return false
   for key in definition.required_facts:
    if value.facts.get(key)!=definition.required_facts[key]:return false
  if value.facts.has("confluence_route") and (11 not in value.completed or value.facts.confluence_route not in ["concealed","overt"]):return false
 return 6 in value.completed and value.facts.has(value.route)

static func continuations(progress:Dictionary,mission_id:int)->Array:
 var accessible=available([0,1,2,3,4,5],progress)
 return accessible.filter(func(id):return mission_id in Catalog.definition(id).prerequisites)
