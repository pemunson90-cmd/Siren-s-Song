extends SceneTree
# Parity of per-operation metadata against a golden dumped from base 075f627e, before
# operation_meta.gd existed. Regenerate only for a deliberate, reviewed change:
#   godot --headless --path game --script res://tests/operation_meta_parity_tests.gd -- --regenerate
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Meta=preload("res://src/campaign/operation_meta.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Budgets=preload("res://src/campaign/endurance_budgets.gd")
const Region=preload("res://src/presentation/art/region_table.gd")
const Audio=preload("res://src/audio/region_audio_table.gd")
const Graph=preload("res://src/campaign/route_map/route_graph.gd")
const MapTable=preload("res://src/campaign/route_map/route_graph_table.gd")
const GOLDEN="res://tests/fixtures/operation_meta_golden.json"
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func row(id:int)->Dictionary:
 var budget=Budgets.for_mission(id);var routes={}
 for route in ["deep","shelf","none"]:
  var mission={"id":id} if route=="none" else {"id":id,"chosen_route":route}
  routes[route]={"region":Region.key(mission),"audio":Audio.bed(mission).stream.resource_path,"gain_db":Audio.bed(mission).gain_db}
 var p:Vector2=MapTable.POSITIONS.get(id,Meta.position(id))
 return {"hunt_cap":Meta.hunt_cap(id),"oxygen_seconds":budget.oxygen_seconds,"drone_seconds":budget.drone_seconds,"routes":routes,"position":[p.x,p.y]}
func graph(completed:Array,progress:Dictionary,intel:Dictionary,unlocked:int)->Dictionary:
 var g=Graph.build(completed,progress,intel,unlocked);var nodes=[]
 for n in g.nodes:nodes.append({"id":n.id,"state":n.state,"named":n.label!="UNKNOWN","can_open":n.can_open,"position":[n.position.x,n.position.y]})
 return {"nodes":nodes,"edges":g.edges.map(func(e):return [e.from,e.to]),"rumors":g.rumors.map(func(r):return [r.from,r.to,r.key])}
func scenarios()->Dictionary:
 var deep={"version":2,"route":"deep","routes":["deep"],"completed":[6],"facts":{"deep":"observed"}}
 var shelf={"version":2,"route":"shelf","routes":["shelf"],"completed":[6,8],"facts":{"shelf":"observed"}}
 var photo=deep.duplicate(true);photo.facts.glass_record_37_bonus="Recovered window photograph"
 var fork=deep.duplicate(true);fork.completed=[6,7,9,11];fork.facts.confluence_route="concealed"
 var late=deep.duplicate(true);late.completed=[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25];late.notes={"sorley_boy":"110"}
 var opening=[0,1,2,3,4,5]
 return {"fresh":[[],{},{},0],"first":[[0],{},{},3],"gap":[[0,2],{},{},2],"missing_four":[[0,1,2,3,5],{},{},5],
  "all_opening":[opening,{},{},5],"deep":[opening,deep,{},5],"shelf":[opening,shelf,{},5],
  "photo":[opening,photo,{},5],"film":[opening,deep,{"silt_scour":{"q":.3,"op":17},"relay_blink":{"q":.4,"op":8}},5],
  "fork":[opening,fork,{},5],"late":[opening,late,{"exhaust_stack":{"q":.5,"op":16}},5]}
func dump()->Dictionary:
 var out={"source":"base 075f627e","ids":Catalog.registered_ids(),"ops":{},"unknown":{},"graphs":{}}
 for id in Catalog.registered_ids():out.ops[str(id)]=row(id)
 for id in [-1,42,999]:out.unknown[str(id)]=row(id)
 var s=scenarios()
 for key in s:out.graphs[key]=graph(s[key][0],s[key][1],s[key][2],s[key][3])
 return out
func same(a,b)->bool:return JSON.stringify(a,"",true)==JSON.stringify(b,"",true)
func _initialize():
 var text=JSON.stringify(dump(),"\t",false)+"\n"
 if "--regenerate" in OS.get_cmdline_user_args():
  var f=FileAccess.open(GOLDEN,FileAccess.WRITE);f.store_string(text);f.close()
  print("REGENERATED ",GOLDEN)
 var golden=JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
 check(golden is Dictionary,"golden fixture loads")
 if not golden is Dictionary:finish();return
 var now=JSON.parse_string(text)
 check(FileAccess.get_file_as_string(GOLDEN)==text,"refactored dump is byte-identical to the golden")
 check(same(now.ids,golden.ids),"registered operation IDs match the golden")
 for key in golden.ops:
  var want=golden.ops[key];var got=now.ops.get(key,{})
  check(got.get("hunt_cap")==want.hunt_cap,"operation %s Hunt cap"%key)
  check(got.get("oxygen_seconds")==want.oxygen_seconds and got.get("drone_seconds")==want.drone_seconds,"operation %s endurance budget"%key)
  for route in want.routes:
   check(same(got.get("routes",{}).get(route),want.routes[route]),"operation %s region and audio bed for route %s"%[key,route])
  check(same(got.get("position"),want.position),"operation %s route-map position"%key)
 for key in golden.unknown:check(same(now.unknown.get(key),golden.unknown[key]),"unknown operation %s keeps base defaults"%key)
 for key in golden.graphs:
  for part in ["nodes","edges","rumors"]:
   check(same(now.graphs.get(key,{}).get(part),golden.graphs[key][part]),"route graph %s %s"%[key,part])
 # Row coverage and table integrity.
 check(Meta.ids()==Catalog.registered_ids(),"every registered operation has exactly one metadata row")
 for id in Meta.ids():
  var r=Meta.row(id)
  check(r.region in Region.STYLES and r.region in Audio.BEDS,"operation %d region has a style and an audio bed"%id)
  for route in r.get("route_regions",{}):check(r.route_regions[route] in Region.STYLES,"operation %d route region %s is a style"%[id,route])
  check(r.position is Vector2,"operation %d has a route-map position"%id)
  check(r.has("oxygen_seconds")==r.has("drone_seconds"),"operation %d endurance is complete or absent"%id)
 var cells={}
 for id in Meta.ids():cells[Meta.position(id)]=true
 check(cells.size()==Meta.ids().size(),"route-map positions are distinct")
 check(Meta.arc_ids(Meta.TUTORIAL)==[0,1,2,3,4,5] and Meta.map_requires(6)==[0,1,2,3,4,5] and Meta.map_requires(7)==null,"tutorial arc and its gate")
 check(Hunt.CAPS.size()==42,"protected Hunt CAPS keeps 42 values")
 # Unknown IDs get the documented defaults without an error.
 check(not Meta.has_row(999) and Meta.row(999).is_empty(),"no row for unknown operation 999")
 check(Meta.region(999)==Meta.DEFAULT_REGION and Meta.region(999,"shelf")=="shelf","unknown region defaults to shelf")
 check(Meta.hunt_cap(999)==Meta.DEFAULT_HUNT_CAP and Meta.hunt_cap(-1)==1.,"unknown Hunt cap defaults to 1.0")
 check(Meta.endurance(999)==Meta.DEFAULT_ENDURANCE and Meta.endurance(-5)=={"oxygen_seconds":300.0,"drone_seconds":240.0},"unknown endurance defaults to 300 s and 240 s")
 check(Meta.position(999)==Vector2(999,5) and Meta.map_requires(999)==null and Meta.map_sources(999,[3])==[3],"unknown map position and catalog-gated edges")
 check(not Meta.tutorial(999) and Region.key({"id":999})=="shelf" and Audio.bed({"id":999}).gain_db==-19.0,"unknown operation reaches shelf style and bed")
 finish()
func finish():
 print("OPERATION META CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
