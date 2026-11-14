extends RefCounted
# Saved facts only. Never read live mission choices or infer a missing decision.
const GROUPS=[
 [["selected_thread","Thread"],["confluence_route","Confluence"]],
 [["glass_choice","Glass"],["choir_choice","Choir"]],
 [["choir_people","People"],["choir_plant","Plant"]]
]
static func lines(progress:Dictionary)->Array:
 var facts=progress.get("facts",{});var result=[]
 for group in GROUPS:
  var parts=[]
  for pair in group:
   var value=str(progress.get(pair[0],"") if pair[0]=="selected_thread" else facts.get(pair[0],""))
   if not value.is_empty():parts.append(pair[1]+": "+value.replace("_"," ").replace("\n"," ").left(48))
  if not parts.is_empty():result.append(" / ".join(parts))
 if result.is_empty():return result # nothing recovered yet: no heading and no filler line
 result.push_front("WHAT YOU CARRY IN / saved record")
 return result
