extends RefCounted
# Route and recovered-fact carry (handoff 077). Seam: OperationCatalog.make calls Carry.apply(m,id,history)
# once, right after the operation is built. Revert: delete that one line in operation_catalog.gd, or set
# ENABLED=false. Empty or missing history changes nothing, so legacy saves and frozen journeys match
# today's mission exactly. Reads only facts already saved; no save field, no sensing or combat rule.
const Table=preload("res://src/campaign/carry/carry_table.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
const ENABLED=true
static func matches(row:Dictionary,history:Dictionary)->bool:
 var when:Dictionary=row.when
 if when.has("thread") and history.get("thread","")!=when.thread:return false
 if when.has("fact"):
  var value=history.get("facts",{}).get(when.fact)
  if not value is String or value not in when.is:return false
 return true
static func rows_for(id:int,history:Dictionary)->Array:
 var result=[]
 if not ENABLED or history.is_empty():return result
 for row in Table.ROWS:
  if row.op==id and matches(row,history):result.append(row)
 return result
static func apply(m:Dictionary,id:int,history:Dictionary)->void:
 for row in rows_for(id,history):
  if not _delta(m,row):continue
  if m.has("brief"):m.brief+=" "+row.line
static func _delta(m:Dictionary,row:Dictionary)->bool:
 match row.kind:
  "mouth":
   if m.get("corridors",[]).size()>=2:return false
   m.corridors.append({"pos":row.pos,"name":row.name,"route":row.route});return true
  "drop_guard":
   var n:int=m.sirens.size()
   var at:int=row.index if row.index>=0 else n+row.index
   if at<0 or at>=n:return false
   m.sirens.remove_at(at)
   for k in range(at,m.sirens.size()):m.sirens[k].patrol=k
   return true
  "add_guard":
   R.add(m,[R.guard(row.type,row.pos,row.band)]);return true
  "start":
   m.start=row.pos;return true
 return false
