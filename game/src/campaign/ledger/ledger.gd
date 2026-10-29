extends RefCounted
# 078 campaign ledger: read-only account built from saved facts, completed list, research and photo intel.
# Seam: Ledger.build(progress,intel) -> panels; shown by presentation/ledger/ledger_view.gd. No saved fields,
# no ending rules. Absent or malformed data prints "not recorded" only for expected facts, else nothing.
# Revert: Table.enabled=false.
const Table=preload("res://src/campaign/ledger/ledger_table.gd")
const Research=preload("res://src/campaign/glass_research.gd")
static func build(progress,intel,economy:Dictionary={})->Array:
 if not Table.enabled or not progress is Dictionary:return []
 var facts=progress.get("facts",{}) if progress.get("facts",{}) is Dictionary else {}
 var done=progress.get("completed",[]) if progress.get("completed",[]) is Array else []
 var thread=str(progress.get("selected_thread",progress.get("route","")))
 var rows={}
 for row in Table.FACT_ROWS:
  var text=_fact_row(row,facts,done,thread)
  if not text.is_empty():
   if not rows.has(row[0]):rows[row[0]]=[]
   rows[row[0]].append(text)
 preload("res://src/campaign/crew/crew.gd").add_people(rows,facts)
 var sorley=preload("res://src/campaign/sorley_rescue.gd").line(progress)
 if not sorley.is_empty():
  if not rows.has("people"):rows["people"]=[]
  rows.people.append(sorley)
 var counts=_counts(progress,intel)
 rows["knowledge"]=counts+rows.get("knowledge",[])
 var losses=preload("res://src/campaign/ironman_losses.gd").lines(economy)
 if not losses.is_empty():rows["infrastructure"]=rows.get("infrastructure",[])+losses
 var result=[]
 for panel in Table.PANELS:
  result.append({"id":panel[0],"title":panel[1],"rows":rows.get(panel[0],[Table.NOT_RECORDED])})
 return result
static func _fact_row(row:Array,facts:Dictionary,done:Array,thread:String)->String:
 if not row[4].is_empty() and row[4]!=thread:return ""
 var value=str(facts.get(row[2],"")).strip_edges()
 var line=Table.NOT_RECORDED
 if not value.is_empty():
  line=row[5].get(value,Table.UNKNOWN_VALUE%value.replace("_"," ").left(Table.MAX_VALUE_CHARS)+".")
 elif row[3] not in done:return ""
 return row[1]+": "+line
static func _counts(progress:Dictionary,intel)->Array:
 var result=[]
 var research=progress.get("research",{})
 if research is Dictionary and research.has("materials") and research["materials"] is Array:
  var found=research["materials"].filter(func(id):return Research.RECIPES.has(id)).size()
  result.append(Table.ARTIFACT_LINE%[found,8])
  var projects=research.get("projects",[])
  if projects is Array and not projects.is_empty():result.append(Table.PROJECT_LINE%projects.size())
 else:result.append(Table.ARTIFACTS_NOT_RECORDED)
 if intel is Dictionary:
  var keys=intel.keys().filter(func(k):return intel[k] is Dictionary and float(intel[k].get("q",0.))>0.)
  if not keys.is_empty():result.append(Table.INTEL_LINE%keys.size())
  var sirens=keys.filter(func(k):return str(k).begins_with("siren_")).size()
  if sirens>0:result.append(Table.SIREN_LINE%sirens)
 return result
