extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func node(graph,id):return graph.nodes.filter(func(row):return row.id==id)[0]
func edge(rows,a,b):return rows.any(func(row):return row.from==a and row.to==b)
func _initialize():
 var path="res://src/campaign/route_map/route_graph.gd"
 var Graph=load(path) if ResourceLoader.exists(path) else null
 check(Graph!=null,"derived route graph exists")
 if Graph==null:finish();return
 var Table=load("res://src/campaign/route_map/route_graph_table.gd")
 var fresh=Graph.build([],{}, {},0)
 check(fresh.nodes.size()==30 and fresh.nodes.map(func(row):return row.id)==Catalog.registered_ids(),"all thirty existing operations appear once")
 check(node(fresh,0).state=="AVAILABLE" and node(fresh,0).label!="UNKNOWN","first operation is available and named")
 check(fresh.nodes.slice(1).all(func(row):return row.state=="LOCKED" and row.label=="UNKNOWN"),"fresh profile cannot learn later operation names")
 var incomplete=Graph.build([0],{}, {},3)
 check(node(incomplete,1).label!="UNKNOWN" and node(incomplete,2).label=="UNKNOWN","an unlock counter never discloses names beyond recovered prerequisites")
 var positions={}
 for row in fresh.nodes:positions[row.position]=true
 check(Table.POSITIONS.size()==30 and positions.size()==30,"layout covers thirty distinct node positions")
 for id in range(1,7):check(edge(fresh.edges,id-1,id),"opening group and expedition gate retain edge%d"%id)
 for id in range(7,30):
  for prerequisite in Catalog.definition(id).prerequisites:check(edge(fresh.edges,prerequisite,id),"catalog edge%d to%d preserved"%[prerequisite,id])
 var completed=[0,1,2,3,4,5]
 var progress={"version":2,"route":"deep","routes":["deep"],"completed":[6],"facts":{"deep":"observed"}}
 var original=progress.duplicate(true);var available=Campaign.available(completed,progress)
 var mid=Graph.build(completed,progress,{},5)
 check(node(mid,6).state=="RECOVERED" and node(mid,7).state=="AVAILABLE","recovered branch point opens the existing deep route")
 check(node(mid,8).state=="LOCKED" and node(mid,8).label=="UNKNOWN","the unchosen branch grants no early name or availability")
 check(mid.nodes.filter(func(row):return row.id>=6 and row.state=="AVAILABLE").map(func(row):return row.id)==available.filter(func(id):return id not in progress.completed),"available expedition nodes use the existing campaign rules")
 var intel={"silt_scour":{"q":.3,"op":17},"relay_blink":{"q":.4,"op":8}}
 var film=Graph.build(completed,progress,intel,5)
 check(node(film,19).state=="KNOWN FROM PHOTOS" and node(film,19).label!="UNKNOWN","returned film may name an unreached operation")
 check(node(film,10).state=="KNOWN FROM PHOTOS","M1 returned-film targets derive from the existing table")
 check(edge(film.rumors,17,19),"Silt Archive film draws its observed rumour connection")
 check(Campaign.available(completed,progress)==available and progress==original,"reading film never grants access or writes campaign state")
 var faint=Graph.build(completed,progress,{"silt_scour":{"q":.29,"op":17}},5)
 check(node(faint,19).state=="LOCKED" and not edge(faint.rumors,17,19),"insufficient film never reveals a name or rumour")
 progress.completed=[6,7,9]
 check(node(Graph.build(completed,progress,{},5),11).state=="AVAILABLE","the existing any-prerequisite merge works")
 progress.completed.append(11);progress.facts.confluence_route="concealed"
 var fork=Graph.build(completed,progress,{},5)
 check(node(fork,12).state=="AVAILABLE" and node(fork,13).state=="LOCKED","required facts preserve the existing second fork")
 check(node(fork,12).required_facts==Catalog.definition(12).required_facts,"graph exposes only the existing progression contract")
 Table.enabled=false
 check(not Graph.build(completed,progress,intel,5).enabled,"off switch is table-owned")
 Table.enabled=true
 finish()
func finish():
 print("ROUTE MAP CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
