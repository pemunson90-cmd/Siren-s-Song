extends SceneTree
const Data=preload("res://src/presentation/landmarks/landmark_data.gd")
const Sim=preload("res://src/simulation/simulation.gd")
class ObservedFixture:
 extends RefCounted
 const Depth=preload("res://src/simulation/depth_bands.gd")
 var mission
 var units=[{"band":1}]
 var selected=0
 var observed=false
 var chart={}
 var sites=[]
 var load_body={}
 func _init():mission=preload("res://src/campaign/operation_catalog.gd").make(6)
 func public_chart():return chart
 func visible(_point,_band=1):return observed
 func rock_polygon(rock):return Sim.rock_polygon(rock)
 func observable_sites():return sites
 func choir_context():return {"load":load_body}
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/presentation/landmarks/landmark_view.gd"
 var View=load(path) if ResourceLoader.exists(path) else null
 check(View!=null,"surface-only landmark projection exists")
 if View==null:finish();return
 var a=Vector2.ZERO;var b=Vector2(100,0)
 check(View.measured_patches(a,b,[]).is_empty(),"unknown surface stays unknown")
 var parts=View.measured_patches(a,b,[PackedVector2Array([Vector2(20,0),Vector2(35,0)])])
 check(parts.size()==1 and parts[0][0].is_equal_approx(Vector2(20,0)) and parts[0][1].is_equal_approx(Vector2(35,0)),"one received patch cannot expose the remainder")
 check(View.measured_patches(a,b,[PackedVector2Array([Vector2(0,5),Vector2(100,5)])]).is_empty(),"nearby parallel wall grants no face")
 check(View.measured_patches(a,b,[PackedVector2Array([Vector2(100,0),Vector2(100,100)])]).is_empty(),"touching corner grants no adjacent face")
 parts=View.measured_patches(a,b,[PackedVector2Array([Vector2(-10,0),Vector2(30,0)]),PackedVector2Array([Vector2(80,0),Vector2(120,0)])])
 check(parts.size()==2 and parts[0][1]==Vector2(30,0) and parts[1][0]==Vector2(80,0),"separate patches retain their unobserved gap")
 var square=PackedVector2Array([Vector2.ZERO,Vector2(100,0),Vector2(100,100),Vector2(0,100)])
 check(View.drawable_pieces(PackedVector2Array([Vector2.ZERO,Vector2(40,0),Vector2(80,0)]),square).is_empty(),"zero-area intersection is never submitted to the renderer")
 var fixed=PackedVector2Array([Vector2(5,0),Vector2(25,0),Vector2(25,70),Vector2(5,70)])
 var thin=PackedVector2Array([Vector2.ZERO,Vector2(100,0),Vector2(100,20),Vector2(0,20)])
 check(View.drawable_pieces(fixed,thin).is_empty(),"unmeasured back edge cannot cut a motif into its own hidden silhouette")
 var pieces=View.drawable_pieces(fixed,square)
 var other_back=PackedVector2Array([Vector2.ZERO,Vector2(100,0),Vector2(100,95),Vector2(0,85)])
 check(pieces==[fixed] and View.drawable_pieces(fixed,other_back)==pieces,"different unobserved back edges produce identical fixed decoration")
 check(View.drawable_pieces(PackedVector2Array([Vector2(-10,10),Vector2(20,10),Vector2(20,30),Vector2(-10,30)]),square).is_empty(),"a crossing decoration is omitted whole rather than clipped to hidden geometry")
 var fixture=ObservedFixture.new()
 check(View.project(fixture).is_empty(),"no hidden feature can appear from table knowledge")
 fixture.observed=true
 check(View.project(fixture).size()==3,"known real terrain can carry its three distinctive treatments")
 var landmark=Data.rows(6)[0];var poly=landmark.polygon
 var centre=poly[landmark.edge].lerp(poly[(landmark.edge+1)%poly.size()],landmark.at)
 var axis=poly[landmark.edge].direction_to(poly[(landmark.edge+1)%poly.size()])
 var start=centre-axis*10.;var end=centre+axis*10.
 fixture.observed=false;fixture.chart={"clear_cells":[Vector2i(0,0)],"surface_segments":[PackedVector2Array([start,end])]}
 var projected=View.project(fixture)
 check(projected.size()==1 and projected[0].patches.size()==1 and projected[0].patches[0].a.is_equal_approx(start) and projected[0].patches[0].b.is_equal_approx(end),"only exact measured part of landmark survives the projection")
 fixture.chart={"clear_cells":[Vector2i(0,0)],"surface_segments":[]}
 check(View.project(fixture).is_empty(),"measured water grants no unknown landmark footprint")
 fixture.chart={};fixture.observed=true;fixture.mission.rocks=[]
 check(View.project(fixture).is_empty(),"missing old-save geometry is skipped safely")
 fixture=ObservedFixture.new();fixture.mission.id=22;fixture.mission.rocks=[];fixture.observed=true
 fixture.load_body={"pos":Vector2(750,2100),"age":.5}
 check(View.project(fixture).is_empty(),"remembered moving load grants no live lamp")
 fixture.load_body.age=0.
 check(View.project(fixture).size()==1 and View.project(fixture)[0].lights==[fixture.load_body.pos],"fresh observed sled carries its current lamp")
 fixture=ObservedFixture.new();fixture.mission.id=21;fixture.mission.rocks=[];fixture.observed=true;fixture.units[0].band=0
 fixture.sites=[{"optical":"locker_latch","stage":"lead","pos":Vector2(1320,1080),"band":0}]
 check(View.project(fixture).is_empty(),"a photo lead cannot disclose its true lamp location")
 fixture.sites[0].stage="shape"
 check(View.project(fixture).size()==1,"observed photo subject has a visible setting at its own depth")
 fixture.units[0].band=1
 check(View.project(fixture).is_empty(),"a shallow photo landmark cannot appear in the middle band")
 for op in range(6,30):
  var sim=Sim.new();sim.start(op);var before=sim.snapshot()
  View.project(sim)
  check(sim.snapshot()==before,"operation%d drawing changes no mission or save state"%op)
  var original=sim.units[sim.selected].band
  sim.units[sim.selected].band=0
  check(View.project(sim).all(func(row):return row.band==0),"only shallow-band detail can show in shallow water")
  sim.units[sim.selected].band=original
  Data.enabled=false;check(View.project(sim).is_empty(),"off switch removes detail");Data.enabled=true
 finish()
func finish():
 print("LANDMARKS UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
