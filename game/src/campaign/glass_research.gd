extends RefCounted
# Actual recovered material is consumed once with received regional evidence.
const RECIPES={"prism_core":{"item":"quietus_prism","evidence":"glass_record_16","operation":20},"keeper_wafer":{"item":"quietus_decoder","evidence":"glass_record_17","operation":21}}
static func recovered(previous:Dictionary,mission:Dictionary)->Dictionary:
 var p=previous.duplicate(true)
 if not mission.get("recovered",false) or not mission.get("glass_reach",{}).get("retrieved",false):return p
 var artifact=mission.glass_reach.get("artifact",{})
 if artifact.get("state","")!="recovered" or artifact.get("id","") not in RECIPES:return p
 if not p.has("research"):p.research={"materials":[],"spent":[],"projects":[]}
 if artifact.id not in p.research.materials:p.research.materials.append(artifact.id)
 for material in p.research.materials:
  var recipe=RECIPES[material]
  if material in p.research.spent or recipe.evidence not in p.facts or recipe.operation not in p.completed:continue
  p.research.spent.append(material);p.research.projects.append(recipe.item)
  if recipe.item not in p.entitlements:p.entitlements.append(recipe.item)
 return p
static func valid(p:Dictionary)->bool:
 var earned=p.get("entitlements",[])
 if not p.has("research"):return "quietus_prism" not in earned and "quietus_decoder" not in earned
 var state=p.research
 if not state is Dictionary or state.size()!=3:return false
 for key in ["materials","spent","projects"]:
  if not state.get(key) is Array or state[key].size()>2:return false
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
  if matches.size()!=1 or project not in earned:return false
 for project in ["quietus_prism","quietus_decoder"]:
  if (project in earned)!=(project in state.projects):return false
 return true
static func detail(p:Dictionary)->String:
 if not p.has("research"):return "Reach research needs physically recovered material and a received regional account."
 return "RECOVERED MATERIAL %s\nCONSUMED IN RESEARCH %s\nOPTIONAL FITTINGS %s"%[", ".join(p.research.materials),", ".join(p.research.spent),", ".join(p.research.projects)]
