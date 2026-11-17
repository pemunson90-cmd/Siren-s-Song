extends RefCounted
# Shared world/planner chart. Cells describe measured water, never wall faces.
# Only exact physically received surface patches produce solid terrain strokes.
const CONFIRMED=Color("72d9d3")
const TENTATIVE=Color("d3b77c")
const ChartCache=preload("res://src/presentation/chart_cache/chart_geometry_cache.gd")
static func chart(sim)->Dictionary:
 return sim.public_chart() if sim!=null and sim.has_method("public_chart") else {}
static func segments(sim,unit:int)->Array:
 return sim.course_segments(unit) if sim!=null and sim.has_method("course_segments") else []
static func draw_terrain(view,data:Dictionary,scale:float)->void:
 # [AI-DESIGNED] Cached path (WP-20); the per-cell code below is the fallback.
 if ChartCache.active(data):
  var cache=ChartCache.request(view,"earned",data,[],func(_tile):return Color(.065,.18,.205,.7))
  cache.draw_fill(view)
  cache.draw_faces(view,Color("132b32"),7./maxf(scale,.01),Color("819c96"),2./maxf(scale,.01))
  cache.draw_orphans(view,Color("132b32")) # WP-107: route-blocking return cells with no drawn face
  return
 var cell=float(data.get("cell_size",40.))
 for key in data.get("clear_cells",[]):
  view.draw_rect(Rect2(Vector2(key)*cell,Vector2.ONE*cell),Color(.065,.18,.205,.7))
 # No RETURN-cell squares, connected silhouettes, end caps or closure: a
 # measurement ending at a patch edge says nothing about the unseen rock.
 for face in data.get("surface_segments",[]):
  if face.size()!=2:continue
  view.draw_line(face[0],face[1],Color("132b32"),7./maxf(scale,.01))
  view.draw_line(face[0],face[1],Color("819c96"),2./maxf(scale,.01))
 ChartCache.draw_orphan_list(view,ChartCache.orphans(data),Color("132b32")) # WP-107
# WP-135: the edge of the surveyed water (clear cells beside unsurveyed ones) is a thin line, so a part-charted patch reads
# as a patch. The lines are rebuilt only when the cell count changes (the view keeps them in two meta entries).
const EDGE_COLOUR:=Color(0.42,0.82,0.8,0.5)
static func draw_survey_edge(view,data:Dictionary,scale:float)->void:
 var cells:Array=data.get("clear_cells",[])
 if cells.is_empty():return
 if int(view.get_meta("survey_edge_count",-1))!=cells.size():
  var cell:=float(data.get("cell_size",40.));var have:={}
  for key in cells:have[Vector2i(key)]=true
  var lines:=PackedVector2Array()
  for key in have:
   var at:=Vector2(key)*cell
   if not have.has(key+Vector2i(0,-1)):lines.append_array([at,at+Vector2(cell,0)])
   if not have.has(key+Vector2i(0,1)):lines.append_array([at+Vector2(0,cell),at+Vector2(cell,cell)])
   if not have.has(key+Vector2i(-1,0)):lines.append_array([at,at+Vector2(0,cell)])
   if not have.has(key+Vector2i(1,0)):lines.append_array([at+Vector2(cell,0),at+Vector2(cell,cell)])
  view.set_meta("survey_edge_lines",lines);view.set_meta("survey_edge_count",cells.size())
 var edge:PackedVector2Array=view.get_meta("survey_edge_lines")
 if not edge.is_empty():view.draw_multiline(edge,EDGE_COLOUR,1.6/maxf(scale,.01))
static func draw_course(view,parts:Array,scale:float,selected:bool)->void:
 for part in parts:
  var color=CONFIRMED if part.confirmed else TENTATIVE
  if not selected:color.a=.35
  var width=2./maxf(scale,.01)
  if part.confirmed:view.draw_line(part.from,part.to,color,width)
  else:
   var delta:Vector2=part.to-part.from;var length=delta.length();var step=18./maxf(scale,.01)
   var at=0.
   while at<length:
    view.draw_line(part.from+delta.normalized()*at,part.from+delta.normalized()*minf(at+step*.55,length),color,width)
    at+=step
static func status(sim,unit:int)->String:
 var course=sim.course_status(unit) if sim.has_method("course_status") else {}
 if course.is_empty():return ""
 match course.get("state",""):
  "blocked":return "NEW TERRAIN · REPLOT · queued intent retained"
  "frontier":return "SURVEY FRONTIER · extend chart or replot"
  "tentative":return "TENTATIVE COURSE · dashed amber is unsurveyed"
 return "CHARTED COURSE · solid cyan is confirmed water" if course.get("clear_distance",0.)>0 else "EARNED CHART · plot through measured water"
