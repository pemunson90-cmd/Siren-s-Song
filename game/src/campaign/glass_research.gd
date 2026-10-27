extends RefCounted
# Actual recovered material is consumed once with received regional evidence.
const RECIPES={"pressure_spindle":{"item":"quietus_pressure_sleeve","evidence":"choir_22","operation":26},"traction_core":{"item":"drone_traction_yoke","evidence":"choir_23","operation":27},"prism_core":{"item":"quietus_prism","evidence":"glass_record_16","operation":20},"keeper_wafer":{"item":"quietus_decoder","evidence":"glass_record_17","operation":21},
 "trench_seal_core":{"item":"quietus_wellhead_seal","evidence":"glass_record_32","operation":32},
 "choir_reed":{"item":"drone_choir_tuner","evidence":"glass_record_33","operation":33},
 "deep_keel_plate":{"item":"hull:quiet","evidence":"glass_record_35","operation":35},
 "trawler_screw":{"item":"hull:fast","evidence":"glass_record_37","operation":37}}
static func recovered(previous:Dictionary,mission:Dictionary)->Dictionary:
 var p=previous.duplicate(true)
 var state=mission.get("glass_reach",mission.get("iron_choir",{}))
 if not mission.get("recovered",false) or not state.get("retrieved",false):return p
 var artifact=state.get("artifact",{})
 if artifact.get("state","")!="recovered" or artifact.get("id","") not in RECIPES:return p
 if not p.has("research"):p.research={"materials":[],"spent":[],"projects":[]}
 if artifact.id not in p.research.materials:p.research.materials.append(artifact.id)
 for material in pending(p):_spend(p,material)
 return p
# Seam: the economy layer holds new projects back as pending (economy_table.enabled), then
# start() pays them on the player's choice. A target such as "hull:quiet" unlocks a frame
# instead of granting a fitting; it is recorded in projects only, never in entitlements.
static func grants_fitting(item:String)->bool:
 return not item.contains(":")
static func _spend(p:Dictionary,material:String)->void:
 var recipe=RECIPES[material]
 p.research.spent.append(material);p.research.projects.append(recipe.item)
 if grants_fitting(recipe.item) and recipe.item not in p.entitlements:p.entitlements.append(recipe.item)
# Recovered material whose evidence is received and which awaits research.
static func pending(p:Dictionary)->Array:
 var result=[]
 if not p.has("research") or not p.has("facts") or not p.has("completed"):return result
 for material in p.research.materials:
  var recipe=RECIPES[material]
  if material in p.research.spent or recipe.evidence not in p.facts or recipe.operation not in p.completed:continue
  result.append(material)
 return result
# Deliberate research of one pending material (the economy charges for it).
static func start(previous:Dictionary,material:String)->Dictionary:
 var p=previous.duplicate(true)
 if material in pending(p):_spend(p,material)
 return p
# Returns current with every project newly added since previous returned to pending.
static func hold(previous:Dictionary,current:Dictionary)->Dictionary:
 if not current.has("research"):return current
 var result=current.duplicate(true);var had=previous.get("research",{}).get("projects",[])
 for material in current.research.spent:
  var item=RECIPES[material].item
  if item in had:continue
  result.research.spent.erase(material);result.research.projects.erase(item)
  if item not in previous.get("entitlements",[]):result.entitlements.erase(item)
 return result
static func item_of(material:String)->String:
 return RECIPES.get(material,{}).get("item","")
static func valid(p:Dictionary)->bool:
 var earned=p.get("entitlements",[])
 if not p.has("research"):return not RECIPES.values().any(func(recipe):return recipe.item in earned)
 var state=p.research
 if not state is Dictionary or state.size()!=3:return false
 for key in ["materials","spent","projects"]:
  if not state.get(key) is Array or state[key].size()>RECIPES.size():return false
  var seen=[]
  for value in state[key]:
   if not value is String or value in seen:return false
   seen.append(value)
 for material in state.materials:
  if material not in RECIPES or RECIPES[material].operation not in p.completed:return false
 for material in state.spent:
  if material not in state.materials or RECIPES[material].item not in state.projects or RECIPES[material].evidence not in p.facts:return false
 for project in state.projects:
  var matches=RECIPES.keys().filter(func(material):return RECIPES[material].item==project and material in state.spent)
  if matches.size()!=1 or (grants_fitting(project) and project not in earned):return false
 for project in RECIPES.values().map(func(recipe):return recipe.item):
  if grants_fitting(project) and (project in earned)!=(project in state.projects):return false
 return true
static func detail(p:Dictionary)->String:
 if not p.has("research"):return "Research needs physically recovered material and a received regional account."
 return "RECOVERED MATERIAL %s\nCONSUMED IN RESEARCH %s\nOPTIONAL FITTINGS %s"%[", ".join(p.research.materials),", ".join(p.research.spent),", ".join(p.research.projects)]
