extends RefCounted
# Derived 027 ending, no new saved fields. Revert the presenter/flow hooks or set
# FinalPair.ENABLED=false; retain final-pair catalog identities for saved dives.
const Pair=preload("res://src/campaign/final_pair_operations.gd")
const Endings=preload("res://src/campaign/endings.gd")
const MAX_FRAMES=12
static func resolve(progress:Dictionary,intel:Dictionary,enabled:bool=Pair.ENABLED,campaign:bool=true)->Dictionary:
 if not enabled or not Pair.IDS.all(func(id):return id in progress.get("completed",[])):return {}
 var ending=Endings.campaign_resolve(progress) if campaign else Endings.resolve(progress)
 if ending.is_empty():return {}
 var keys=intel.keys().filter(func(k):return float(intel[k].get("q",0.))>0.);keys.sort()
 var studied=keys.filter(func(k):return str(k).begins_with("siren_")).size()
 var film="studied" if studied>=3 else "recorded" if not keys.is_empty() else "blind"
 var facts=progress.get("facts",{});var choices={}
 for key in ["glass_choice","choir_choice","choir_people","choir_plant"]:choices[key]=facts.get(key,"")
 ending["photo_variant"]=film
 ending["choices"]=choices
 ending["intel_keys"]=keys
 ending["variant"]=ending.id+"/"+film+"/"+"/".join(choices.values())
 return ending
static func frames(archive:Dictionary)->Array:
 var result=[];var keys=archive.keys();keys.sort()
 for key in keys:
  var best={}
  for shot in archive[key].get("shots",[]):
   if not shot.get("usable",true) or not shot.has("frame"):continue
   if best.is_empty() or float(shot.q)>float(best.q):best=shot
  if best.is_empty():continue
  var labels=[]
  for finding in best.get("findings",[]):
   var label=str(finding.get("label",finding.get("text","")))
   if not label.is_empty() and label not in labels:labels.append(label)
  # A subject label identifies the photograph, not an unobserved finding.
  result.append({"key":key,"shot":best.duplicate(true),"captions":labels,"subject":archive[key].get("name",str(key))})
 result.sort_custom(func(a,b):return float(a.shot.q)>float(b.shot.q) if float(a.shot.q)!=float(b.shot.q) else str(a.key)<str(b.key))
 return result.slice(0,MAX_FRAMES)
