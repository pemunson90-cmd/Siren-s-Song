extends RefCounted
# Read-only projection of existing progression and recovered photographic intel.
# Seam: route-map view calls build(); revert with Table.enabled=false.
const Table=preload("res://src/campaign/route_map/route_graph_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
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
  var state="RECOVERED" if id in recovered else "AVAILABLE" if (id<6 and id<=unlocked) or id in available else "KNOWN FROM PHOTOS" if id in known else "LOCKED"
  var prerequisite_known=id==0 or (id<6 and id-1 in completed) or (id==6 and [0,1,2,3,4,5].all(func(required):return required in completed)) or (id>6 and Catalog.prerequisites_met(id,recovered))
  var named=state!="LOCKED" and (id in recovered or id in known or prerequisite_known)
  var label=str(Catalog.make(id).title) if named else "UNKNOWN"
  nodes.append({"id":id,"state":state,"label":label,"can_open":named and state in ["AVAILABLE","RECOVERED"],"position":Table.POSITIONS.get(id,Vector2(id,5)),"route":definition.route,"required_facts":definition.required_facts.duplicate(true)})
  var prerequisites=[id-1] if id>0 and id<=6 else definition.prerequisites
  for prerequisite in prerequisites:edges.append({"from":prerequisite,"to":id})
 return {"enabled":Table.enabled,"nodes":nodes,"edges":edges,"rumors":rumors}
