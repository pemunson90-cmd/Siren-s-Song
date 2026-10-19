extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var resource="res://src/simulation/terrain_chart.gd"
 if not ResourceLoader.exists(resource):check(false,"earned terrain has one public chart authority")
 else:
  var Chart=load(resource)
  var m={"id":14,"terrain_chart_revision":1,"chart_geometry_revision":1,"world_size":Vector2(1200,1200),"launch_seed":Rect2(80,800,400,320)}
  var wall=PackedVector2Array([Vector2(600,200),Vector2(680,200),Vector2(680,800),Vector2(600,800)])
  var chart=Chart.new();chart.configure(m,[wall])
  var before=chart.snapshot()
  check(chart.player_path(Vector2(300,1000),Vector2(640,500)).size()==1,"unknown hidden-rock endpoint is accepted tentatively")
  var alternate=Chart.new();alternate.configure(m,[])
  check(chart.public_chart()==alternate.public_chart() and chart.player_path(Vector2(300,1000),Vector2(640,500))==alternate.player_path(Vector2(300,1000),Vector2(640,500)),"same chart different hidden geometry has identical path oracle")
  check(chart.snapshot()==before,"public route/read queries cannot acquire terrain")
  chart.observe([{"pos":Vector2(400,600),"radius":330.0}],{})
  var view=chart.public_chart()
  check(not view.return_cells.is_empty() and not view.surface_segments.is_empty(),"first visible wall face earns bounded returns")
  check(not chart.is_clear(Vector2(700,600)) and not chart.is_clear(Vector2(580,600)),"occluded rear and footprint with insufficient hull margin stay unknown")
  check(chart.is_clear(Vector2(420,620)),"whole visible water footprint is certified clear")
  check(view.surface_segments.all(func(s):return s.size()==2 and s[0].x<601 and s[1].x<601),"front face cannot reveal distant opposite face")
  var restored=Chart.new();restored.configure(m,[wall],chart.snapshot())
  check(restored.public_chart()==view,"restore rebuilds public graph without sampling")
  check(Chart.valid_state(chart.snapshot(),m),"earned sparse chart validates")
  var forged=chart.snapshot();forged.clear_cells[Vector2i(200,200)]=true
  check(not Chart.valid_state(forged,m),"out of bounds chart cannot enter save")
  var path=chart.player_path(Vector2(400,600),Vector2(900,600))
  check(not path.is_empty() and path.size()>1,"new orders detour around earned return cells only")
  check(chart.clear_distance(Vector2(420,620),Vector2(900,620))<180,"clear prefix ends before observed wall")
  var memory=chart.snapshot();chart.observe([],{})
  check(chart.snapshot()==memory,"lost fleet receiver does not erase memory or add knowledge")
  var survey=Chart.new();survey.configure(m,[wall]);survey.observe([],{"pos":Vector2(620,600),"radius":560.0})
  check(survey.is_clear(Vector2(780,620)),"finite bathymetric survey can map occluded water in its disk")
 print("TERRAIN CHART CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
