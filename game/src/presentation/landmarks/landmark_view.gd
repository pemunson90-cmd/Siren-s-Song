extends RefCounted
# M3a ground adapter. Existing geometry and public observations are read only.
# Unregister from feature_views.GROUND_VIEWS, or disable Data.enabled, to revert.
const Data=preload("res://src/presentation/landmarks/landmark_data.gd")
static func applies(sim)->bool:return sim!=null and not Data.rows(sim.mission.id).is_empty()
static func build_panel(_hud)->void:pass
# Intersect a single physical face with exact received patches. No closure, joining,
# or inference from water cells, nearby walls, or the known centre of a feature.
static func measured_patches(a:Vector2,b:Vector2,measured:Array)->Array:
 var result=[];var axis=a.direction_to(b);var length=a.distance_to(b)
 if length<.01:return result
 for face in measured:
  if face.size()!=2:continue
  var first:Vector2=face[0];var last:Vector2=face[1]
  if absf(axis.cross(first-a))>.01 or absf(axis.cross(last-a))>.01:continue
  var start=maxf(0,minf(axis.dot(first-a),axis.dot(last-a)))
  var end=minf(length,maxf(axis.dot(first-a),axis.dot(last-a)))
  if end-start>.01:result.append(PackedVector2Array([a+axis*start,a+axis*end]))
 return result
static func visible_patches(sim,a:Vector2,b:Vector2,outward:Vector2,band:int)->Array:
 var result=[];var count=maxi(1,ceili(a.distance_to(b)/Data.FACE_STEP))
 for n in count:
  var first=a.lerp(b,float(n)/count);var last=a.lerp(b,float(n+1)/count)
  # End and midpoint sight all required. Test just outside the physical face.
  if sim.visible(first+outward,band) and sim.visible(last+outward,band) and sim.visible(first.lerp(last,.5)+outward,band):result.append(PackedVector2Array([first,last]))
 return result
static func project(sim)->Array:
 if sim==null:return []
 var result=[];var band:int=sim.units[sim.selected].band
 var chart:Dictionary=sim.public_chart();var shapes:Array=sim.Depth.rock_shapes(sim,band)
 for landmark in Data.rows(sim.mission.id):
  if landmark.band!=band:continue
  var item=landmark.duplicate(true);item["patches"]=[];item["lights"]=[]
  if landmark.source=="rock":
   if landmark.rock>=shapes.size() or shapes[landmark.rock]!=landmark.polygon:continue
   var polygon:PackedVector2Array=shapes[landmark.rock]
   var edge:int=landmark.edge
   if edge<0 or edge>=polygon.size():continue
   var first=polygon[edge];var last=polygon[(edge+1)%polygon.size()]
   var axis=first.direction_to(last);var centre=first.lerp(last,landmark.at)
   var half=minf(Data.PATCH_SPAN*.5,first.distance_to(last)*.45)
   var a=centre-axis*minf(half,first.distance_to(centre))
   var b=centre+axis*minf(half,last.distance_to(centre))
   var inward=axis.orthogonal()
   if not Geometry2D.is_point_in_polygon(centre+inward,polygon):inward=-inward
   var faces=measured_patches(a,b,chart.get("surface_segments",[])) if not chart.is_empty() else visible_patches(sim,a,b,-inward,band)
   for face in faces:item.patches.append({"a":face[0],"b":face[1],"inward":inward,"edge_origin":centre})
   if Data.LAMP_OFFSETS.has(landmark.style):
    for offset in Data.LAMP_OFFSETS[landmark.style]:
     var lamp=centre+axis*offset-inward*2.
     if offset>=-half and offset<=half and sim.visible(lamp,band):item.lights.append(lamp)
  elif landmark.source=="subject":
   for site in sim.observable_sites():
    if site.get("optical","")!=landmark.key or site.get("stage","")=="lead":continue
    if site.get("band",1)==band and sim.visible(site.pos,band):item.lights.append(site.pos)
  elif landmark.source=="load":
   var body:Dictionary=sim.choir_context().get("load",{})
   if not body.is_empty() and body.get("age",INF)<.3 and sim.visible(body.pos,band):item.lights.append(body.pos)
  if not item.patches.is_empty() or not item.lights.is_empty():result.append(item)
 return result
static func draw(view)->void:
 for landmark in project(view.sim):
  for face in landmark.patches:_face(view,landmark,face)
  for lamp in landmark.lights:
   for radius in [Data.GLOW_RADIUS,Data.GLOW_RADIUS*.55]:view.draw_circle(lamp,radius,Color(landmark.color,landmark.glow*.12))
   view.draw_circle(lamp,3.,Color(landmark.color,.9))
   view.draw_circle(lamp,1.2,Color("e5eee2"))
static func _paint(view,points:PackedVector2Array,polygon:PackedVector2Array,color:Color)->void:
 for clipped in drawable_pieces(points,polygon):view.draw_colored_polygon(clipped,color)
static func drawable_pieces(points:PackedVector2Array,polygon:PackedVector2Array)->Array:
 if points.size()<3:return []
 var area=0.
 for n in points.size():area+=points[n].cross(points[(n+1)%points.size()])
 if absf(area)<.1 or Geometry2D.triangulate_polygon(points).is_empty():return []
 # Omit a whole fixed motif if it would cross a boundary. Never use the unseen
 # back edge to cut its visible shape, even on a thin or concave physical form.
 if not Geometry2D.clip_polygons(points,polygon).is_empty():return []
 return [points]
static func _face(view,landmark:Dictionary,face:Dictionary)->void:
 var a:Vector2=face.a;var b:Vector2=face.b;var inward:Vector2=face.inward
 var axis=a.direction_to(b);var length=a.distance_to(b)
 var phase=axis.dot(a-face.edge_origin)
 var step=Data.RIB_STEP*2.
 var at=floorf(phase/step)*step-phase
 # Large localized forms sit inside the existing solid, not on a new ledge.
 # Clip each form to both the received patch and its actual rock footprint.
 var patch=PackedVector2Array([a,b,b+inward*Data.SURFACE_DEPTH,a+inward*Data.SURFACE_DEPTH])
 while at<length+step:
  var p=a+axis*at;var shape=PackedVector2Array()
  var form:Dictionary=Data.FORMS[landmark.style]
  for point in form.points:shape.append(p+axis*point.x*step+inward*point.y*Data.SURFACE_DEPTH)
  var color=Color(landmark.color,form.alpha) if form.color.is_empty() else Color(form.color,form.alpha)
  for bounded in Geometry2D.intersect_polygons(shape,patch):_paint(view,bounded,landmark.polygon,color)
  at+=step
