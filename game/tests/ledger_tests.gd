extends SceneTree
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
const Table=preload("res://src/campaign/ledger/ledger_table.gd")
const View=preload("res://src/presentation/ledger/ledger_view.gd")
const Endings=preload("res://src/campaign/endings.gd")
class Host extends RefCounted:
 var labels=[]
 func _menu_text(text,size):labels.append(text)
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func flat(panels)->Array:
 var result=[]
 for panel in panels:result.append_array(panel.rows)
 return result
func has_row(panels,part:String)->bool:
 return flat(panels).any(func(r):return r.contains(part))
func _initialize():
 var base=[6,7,9,11]
 var cases={
  "silent_exodus":{"selected_thread":"deep","completed":base+[12],"facts":{"confluence_route":"concealed","witness_arrival":"drone_a","concealed_consequence":"deep_trace_severed"}},
  "hidden_harbour":{"selected_thread":"shelf","completed":[6,8,10,11,12],"facts":{"confluence_route":"concealed","witness_arrival":"quietus","concealed_consequence":"shelf_baffle"}},
  "beacon_pact":{"selected_thread":"deep","completed":base+[13],"facts":{"confluence_route":"overt","warning_arrival":"sheltered"}},
  "surface_reckoning":{"selected_thread":"shelf","completed":[6,8,10,11,13],"facts":{"confluence_route":"overt","warning_arrival":"exposed"}}}
 for id in cases:
  var progress=cases[id];var before=progress.duplicate(true)
  var panels=Ledger.build(progress,{})
  check(Endings.resolve(progress).id==id,"fixture resolves to "+id)
  check(progress==before,"ledger never mutates progress "+id)
  check(has_row(panels,"Confluence:") and panels.size()==4,"four panels and recorded Confluence outcome "+id)
  check(panels.all(func(p):return not p.rows.is_empty()),"no empty panels "+id)
  check(Endings.resolve(progress).id==id,"ledger leaves ending family unchanged "+id)
 check(has_row(Ledger.build({"facts":{"varne_staff":"service"}},{}),"Varne staff: recorded as service."),"legacy Varne staff fact remains readable")
 check(has_row(Ledger.build({"facts":{"glass_choice":"sever","varne_staff":"service"}},{}),"Varne staff: recorded as sever."),"canonical Varne choice takes precedence over legacy alias")
 var deep=Ledger.build(cases.silent_exodus,{})
 check(has_row(deep,"Tessaly divers: not recorded") and has_row(deep,"Trench mouth") and not has_row(deep,"Port Ardent"),"deep thread reports only recorded trench infrastructure")
 check(has_row(Ledger.build(cases.hidden_harbour,{}),"Port Ardent watch: six came out through the baffled"),"shelf baffle line")
 check(has_row(Ledger.build(cases.surface_reckoning,{}),"Kestrel sailors: taken aboard a launch through the exposed"),"exposed launch line")
 # Partial and old saves: expected-but-missing facts read not recorded, unexpected ones are silent.
 var partial=Ledger.build({"selected_thread":"deep","completed":[6,7,9,11,12,22],"facts":{"confluence_route":"concealed"}},{})
 check(has_row(partial,"Kestrel sailors: not recorded") and has_row(partial,"Tessaly divers: not recorded"),"missing expected facts say not recorded")
 check(not has_row(partial,"Choir") and not has_row(partial,"Choir people"),"unreached sites print nothing")
 var old_save=Ledger.build({}, {})
 check(old_save.size()==4 and has_row(old_save,"Artifacts recovered: not recorded (of 8)."),"old save renders four panels and unrecorded artifact count")
 check(Ledger.build({"facts":"bad","completed":3,"research":7},5).size()==4,"malformed optional fields render four panels")
 check(Ledger.build(null,null).is_empty(),"non-dictionary progress prints nothing")
 var late={"selected_thread":"deep","completed":[18,22,28,29],"facts":{"choir_people":"landed","choir_plant":"dismantle","choir_choice":"weird_value","glass_choice":"sever"}}
 var lp=Ledger.build(late,{})
 check(has_row(lp,"Choir people: recovered workers") and has_row(lp,"Varne staff: recorded as sever.") and has_row(lp,"Choir plant: plant dismantled.") and has_row(lp,"Varne fence: reporting spur severed."),"late arc lines")
 check(has_row(lp,"Choir line: recorded as weird value."),"unknown value is echoed, not guessed")
 var know=Ledger.build({"research":{"materials":["prism_core","keeper_wafer","nonsense"],"spent":[],"projects":["quietus_prism"]}},{"siren_a":{"q":0.5},"siren_b":{"q":0.},"wreck_1":{"q":0.4}})
 var rows=flat(know)
 check(has_row(know,"Artifacts recovered: 2 of 8.") and has_row(know,"Research completed: 1.") and has_row(know,"subjects with intel: 2.") and has_row(know,"Siren types photographed: 1."),"knowledge counts")
 check(has_row(Ledger.build({"completed":[11]},{}),"Artifacts recovered: not recorded"),"missing research record is not recorded")
 var host=Host.new()
 check(View.render(host,cases.beacon_pact,{})>0 and host.labels.back()==Table.FOOTER and host.labels[0]=="PEOPLE","view emits panels and AI-DESIGNED footer")
 var long=Table.FACT_ROWS.size()>0 and Table.FACT_ROWS.all(func(r):return r[5].values().all(func(v):return v.length()<=70 and not v.contains("—")))
 check(long,"table lines short and free of em dashes")
 print("LEDGER CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
