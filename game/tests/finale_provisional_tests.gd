extends SceneTree
const Finale=preload("res://src/presentation/finale/finale.gd")
const Table=preload("res://src/presentation/finale/finale_table.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Photo=preload("res://src/campaign/endings_photo.gd")
class Host extends RefCounted:
 var expedition={}
 var photo_intel={}
 var sim={"outcome":"won","mission":{"id":31}}
 var end_of_line_seen=false
 var shown=0
 var labels=[]
 func _show_ending():shown+=1
 func _menu_text(text,size):labels.append(text)
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var facts={"choir_choice":"bypass","choir_plant":"reconnect"};var before=facts.duplicate(true)
 check(Finale.lines(facts)==["Choir choice recorded: bypass.","Plant state recorded: reconnect."],"only recorded choices supply the two provisional lines")
 check(Finale.lines({})==["No choir choice was recorded.","No plant state was recorded."],"missing facts use truthful fixed fallback lines")
 check(Finale.lines(facts).size()==2 and facts==before,"placeholder count bounded and facts unmodified")
 for key in Table.LABELS:check(Finale.fact_line(key,"recorded_value")==Table.LABELS[key]+" / recorded value","plain data-table label "+key)
 var data={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance"}
 check(Store.new().valid(data),"old minimal archive needs no new field")
 for value in [true,false]:
  var good=data.duplicate(true);good[Table.SEEN_FIELD]=value
  check(Store.new().valid(good),"optional boolean accepted "+str(value))
 for value in [1,"true",{},[]]:
  var bad=data.duplicate(true);bad[Table.SEEN_FIELD]=value
  check(not Store.new().valid(bad),"malformed optional seen field rejected "+str(value))
 var host=Host.new()
 host.expedition={"route":"deep","routes":["deep"],"selected_thread":"deep","facts":{"deep":"Recovered branch account","confluence_route":"concealed"},"completed":[6,7,9,11,12,25,30,31]}
 var ending=Photo.resolve(host.expedition,{})
 check(not ending.is_empty(),"fixture retains an existing fork outcome")
 host.sim.mission.id=30
 check(not Finale.first_recovery(host,{"completed":[]}) and host.shown==0,"op30 never triggers End of Line")
 host.sim.mission.id=31;host.sim.outcome="lost"
 check(not Finale.first_recovery(host,{"completed":[]}),"loss cannot trigger finale")
 host.sim.outcome="won"
 check(Finale.first_recovery(host,{"completed":[30]}) and host.shown==1,"first last recovery hands into existing wall")
 check(Finale.heading(host,ending) and host.end_of_line_seen,"rendered intro records seen state")
 check(host.labels[0]==Table.TITLE and host.labels.size()==4,"one heading, two placeholders and existing film title only")
 check(not Finale.first_recovery(host,{"completed":[30,31]}) and host.shown==1,"replay never automatically repeats intro")
 var saved=data.duplicate(true);saved.expedition=host.expedition.duplicate(true);Finale.write(host,saved)
 check(saved[Table.SEEN_FIELD]==true,"seen marker written only as optional boolean")
 Finale.clear(host);Finale.restore(host,saved)
 check(host.end_of_line_seen,"saved seen marker restores")
 saved.erase(Table.SEEN_FIELD);Finale.restore(host,saved)
 check(host.end_of_line_seen and host.shown==1,"legacy completed pair gets manual access without showing a screen")
 Finale.restore(host,data)
 check(not host.end_of_line_seen,"empty profile cannot inherit another profile's marker")
 Table.enabled=false;host.end_of_line_seen=true
 var retained={};Finale.write(host,retained)
 check(retained[Table.SEEN_FIELD] and not Finale.show(host),"off switch preserves recorded state but disables new presentation")
 check(Finale.fact_line("glass_choice","recorded_value")=="GLASS CHOICE / RECORDED_VALUE","off switch restores original raw wall labels")
 Table.enabled=true;Finale.clear(host)
 check(not host.end_of_line_seen,"new campaign reset clears seen state")
 print("FINALE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
