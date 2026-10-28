extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Crew=preload("res://src/campaign/crew/crew.gd")
const Table=preload("res://src/campaign/crew/crew_table.gd")
const View=preload("res://src/presentation/crew/crew_view.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
class Host extends RefCounted:
 var labels=[]
 var expedition={}
 func _menu_text(text,size):labels.append(text)
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func facts_for(row)->Dictionary:
 return {row.when.fact:row.when["is"][0]}
func world(m:Dictionary)->String:
 var copy=m.duplicate(true);copy.erase("photo_marks");copy.erase("launch_context")
 return var_to_str(copy)
func _init():
 for row in Table.ROWS:
  check(row.kind in ["mark","credit","line"] and Voices_ok(row),"row shape "+row.id)
  check(not row.has("op") or (row.op>=0 and row.op<=40),"op in range "+row.id)
  var empty=Economy.new_state()
  var before=empty.duplicate(true)
  Crew.credit(empty,{},{"facts":{}})
  check(empty==before,"no facts credits nothing "+row.id)
  check(not Crew.present({}).any(func(r):return r.id==row.id),"absent fact means no crew "+row.id)
  check(not Crew.present({row.when.fact:"nothing_recorded"}).any(func(r):return r.id==row.id),"unknown value means no crew "+row.id)
  if row.kind=="credit":
   var e=Economy.new_state()
   var cur={"facts":facts_for(row)}
   Crew.credit(e,{"facts":{}},cur)
   for key in row.credit:check(e.stock[key]==Economy.new_state().stock[key]+row.credit[key],"credit paid once "+row.id+" "+key)
   var once=e.duplicate(true)
   Crew.credit(e,cur,cur)
   check(e==once,"credit does not repeat "+row.id)
   check(Economy.valid(e),"credited economy still validates "+row.id)
   var full=Economy.new_state();full.stock.scrap=99;full.stock.cells=99;full.stock.alloy=99
   Crew.credit(full,{},cur)
   check(full.stock.scrap==99 and full.stock.cells==99 and Economy.valid(full),"credit respects the cap "+row.id)
  elif row.kind=="mark":
   var ctx={"facts":facts_for(row),"thread":"","completed":[],"intel":{}}
   var base=Catalog.make(row.op,{})
   var m=Catalog.make(row.op,ctx)
   var marks=m.get("photo_marks",[]).filter(func(x):return x.id=="crew_"+row.id)
   check(marks.size()==1,"crew mark appears once on its op "+row.id)
   check(world(m)==world(base),"crew mark changes no world rule "+row.id)
   check(not Catalog.make(row.op,{}).has("photo_marks") or Catalog.make(row.op,{}).photo_marks.is_empty(),"empty crew adds no mark "+row.id)
   var other=Catalog.make(row.op+1,ctx)
   check(not other.get("photo_marks",[]).any(func(x):return x.id=="crew_"+row.id),"crew mark stays on its op "+row.id)
   Table.enabled=false
   check(not Catalog.make(row.op,ctx).get("photo_marks",[]).any(func(x):return x.id=="crew_"+row.id),"switch off restores old behavior "+row.id)
   Table.enabled=true
  elif row.kind=="line":
   check(Crew.briefing_lines(facts_for(row),row.op).size()==1 and Crew.briefing_lines({},row.op).is_empty(),"briefing line only with crew "+row.id)
  check(Crew.ledger_lines(facts_for(row)).size()==1,"ledger lists the crew "+row.id)
 # Briefing and SUPPLIES text draw nothing without crew and the list with crew.
 var host=Host.new()
 View.briefing(host,15);View.supplies(host)
 check(host.labels.is_empty(),"no crew draws nothing")
 host.expedition={"facts":{"witness_arrival":"quietus","choir_people":"landed"}}
 View.briefing(host,15);View.supplies(host)
 check(host.labels.size()==3 and host.labels[0].begins_with(Table.HEAD),"crew list and op line drawn")
 check(host.labels[1].begins_with("OKAFOR / BRANNOCK"),"line attributed to the voices table speaker")
 check(host.labels[2].contains("Kestrel sailors") and host.labels[2].contains("Hollins workers"),"supplies lists each crew")
 # Ledger: crew lines join the people panel; the legacy panel is unchanged without crew.
 var plain=Ledger.build({"facts":{},"completed":[]},{})
 var crewed=Ledger.build({"facts":{"witness_arrival":"quietus"},"completed":[]},{})
 check(var_to_str(plain)==var_to_str(Ledger.build({"completed":[]},{})),"ledger without crew unchanged")
 check(crewed[0].rows.any(func(r):return r.contains("Brannock crew, Kestrel sailors")),"ledger people panel lists crew")
 # A campaign that rescued nobody keeps today's launch: every effect is a grant, never a requirement.
 check(Economy.refit_cost(Economy.new_state(),Economy.Catalog.default_loadout()).is_empty(),"bare launch stays free")
 print("CREW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func Voices_ok(row)->bool:
 return preload("res://src/campaign/voices/voices_table.gd").SPEAKERS.has(row.speaker) and not row.line.contains("—")
