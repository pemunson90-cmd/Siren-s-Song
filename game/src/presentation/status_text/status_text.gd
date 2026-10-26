extends RefCounted
# HUD-only copy adapter. Revert by setting Table.enabled=false; it never writes to
# simulation state or changes the source camera context.
const Table=preload("res://src/presentation/status_text/status_table.gd")
static func present(sim,text:String)->String:
 if not Table.enabled or not text.contains(Table.FALLBACK):return text
 if sim==null or sim.mission==null:return text
 var id:int=int(sim.mission.get("id",-1))
 if not Table.LINES.has(id):return text
 if id in Table.CHOIR_IDS:
  var corridors:Array=sim.extraction_corridors()
  if corridors.any(func(c):return c.get("available",false)):
   return text.replace(Table.FALLBACK,Table.RECOVERY_READY)
  var work:Dictionary=sim.choir_context()
  if work.get("actions",{}).is_empty():return text.replace(Table.FALLBACK,Table.CHOIR_NO_ACTION)
 return text.replace(Table.FALLBACK,Table.LINES[id])
static func arrivals_label(count:int)->String:
 return (Table.ARRIVALS_LABEL if Table.enabled else Table.ARRIVALS_LABEL_OLD)%count
static func arrivals_hint(count:int)->String:
 if not Table.enabled:return ""
 return Table.ARRIVALS_EMPTY if count<=0 else Table.ARRIVALS_RECEIVED%count
