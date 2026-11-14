extends RefCounted
# Read-only projection of existing progression and recovered photographic intel.
# Seam: route-map view calls build(); revert with Table.enabled=false.
const Table=preload("res://src/campaign/route_map/route_graph_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
const Meta=preload("res://src/campaign/operation_meta.gd")
static func build(completed:Array,progress:Dictionary,intel:Dictionary,unlocked:int)->Dictionary:
 var ids=Catalog.registered_ids();var recovered=completed+progress.get("completed",[])
 var available=Campaign.available(completed,progress)
 var reveals=Table.REVEALS.duplicate(true);var sources=Table.SOURCES.duplicate()
 for row in Intel.RETURNED_FILM:reveals[row.key]=row.ops;sources[row.key]=row.from
 var known=[];var rumors=[]
 for key in reveals:
  if not Intel.ok({"intel":intel},key,Table.MIN_QUALITY):continue
  for target in reveals[key]:
   if target not in ids:continue
   if target not in known:known.append(target)
   rumors.append({"from":sources[key],"to":target,"key":key})
 var nodes=[];var edges=[]
 for id in ids:
  if not preload("res://src/campaign/sorley_rescue.gd").visible(id,progress):continue
  var definition=Catalog.definition(id)
  # The tutorial arc unlocks by the opening counter and completed list; its gate row needs the whole arc.
  var state="RECOVERED" if id in recovered else "AVAILABLE" if (Meta.tutorial(id) and id<=unlocked) or id in available else "KNOWN FROM PHOTOS" if id in known else "LOCKED"
  var opening=Meta.map_requires(id)
  var prerequisite_known=opening.all(func(required):return required in completed) if opening!=null else Catalog.prerequisites_met(id,recovered)
  var named=state!="LOCKED" and (id in recovered or id in known or prerequisite_known)
  var mission=Catalog.make(id) if named else {}
  var label=str(mission.title) if named else "UNKNOWN"
  var can_open=named and state in ["AVAILABLE","RECOVERED"]
  nodes.append({"id":id,"state":state,"label":label,"can_open":can_open,"mark":state=="LOCKED" and not named,"position":Table.POSITIONS.get(id,Meta.position(id)),"route":definition.route,"required_facts":definition.required_facts.duplicate(true),"tag":_tag(mission) if can_open else {}})
  for prerequisite in Meta.map_sources(id,definition.prerequisites):edges.append({"from":prerequisite,"to":id})
 for row in nodes:
  if not row.tag.is_empty():row.tag["opens"]=edges.filter(func(edge):return edge.from==row.id).size()
 return {"enabled":Table.enabled,"nodes":nodes,"edges":edges,"rumors":rumors}
# Facts the briefing already shows: required photo subjects and other required tasks. How many Sirens wait is
# never shown before the dive (the dive reveals them by sound), so the map does not count them either.
static func _tag(mission:Dictionary)->Dictionary:
 var required=mission.get("objectives",[]).filter(func(objective):return not objective.get("optional",false))
 var photos=required.filter(func(objective):return objective.has("subject")).size()
 return {"photos":photos,"tasks":required.size()-photos,"opens":0}
