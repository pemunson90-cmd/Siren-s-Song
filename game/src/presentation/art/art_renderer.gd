extends RefCounted
const Palette=preload("res://src/presentation/accessibility/palette.gd")
# One shared immutable geometry cache. Draw methods consume public values only.
# Revert via ArtTable.enabled. The preceding renderer stays in its original seam.
const Table=preload("res://src/presentation/art/art_table.gd")
const RAY=preload("res://assets/craft/siren_ray.png")
static var outlines={}
static var uvs={}
static var meshes={}
static var lamp=PackedVector2Array()
static var lamp_colors=PackedColorArray()
static var lamp_arrays=[]
static var lamp_fov=-1.0
static var lamp_length=-1.0
static var lamp_strength=-1.0
static func prepare()->void:
 if not outlines.is_empty():return
 for key in Table.SHAPES:
  var points:PackedVector2Array=Table.SHAPES[key]
  var outline=points.duplicate();outline.append(points[0]);outlines[key]=outline
  if Table.ROLE_RECTS.has(key):
   var rect:Rect2=Table.ROLE_RECTS[key];var uv=PackedVector2Array()
   # Sample the dense biological/armoured core, excluding the source image's
   # transparent wing/tail margins. Material fills each cached role silhouette.
   for point in points:uv.append(Table.RAY_MATERIAL_UV.position+(point-rect.position)/rect.size*Table.RAY_MATERIAL_UV.size)
   uvs[key]=uv
 for key in Table.SHAPES:
  if key!="quietus":meshes[key]=_mesh(Table.SHAPES[key],uvs.get(key,PackedVector2Array()))
 meshes["lamp"]=ArrayMesh.new()
 lamp.resize(3);lamp_colors.resize(3)
 lamp_arrays.resize(Mesh.ARRAY_MAX);lamp_arrays[Mesh.ARRAY_INDEX]=PackedInt32Array([0,1,2])
static func _mesh(points:PackedVector2Array,uv:PackedVector2Array)->ArrayMesh:
 var arrays=[];arrays.resize(Mesh.ARRAY_MAX)
 arrays[Mesh.ARRAY_VERTEX]=points;arrays[Mesh.ARRAY_INDEX]=Geometry2D.triangulate_polygon(points)
 if not uv.is_empty():arrays[Mesh.ARRAY_TEX_UV]=uv
 var mesh=ArrayMesh.new()
 mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES)
 return mesh
static func craft(view,index:int)->void:
 prepare()
 var key="quietus" if index==0 else "drone_a" if index==1 else "drone_b"
 if index==0:
  # Retain the charcoal painted material and its original footprint.
  view.draw_texture_rect_region(view.quietus,Rect2(-66,-17,132,34),Rect2(60,145,1940,390))
  view.draw_polyline(outlines[key],Table.HULL_SEAM,Table.HULL_OUTLINE_WIDTH,true)
 else:
  view.draw_mesh(meshes[key],null,Transform2D.IDENTITY,Table.HULL)
  view.draw_polyline(outlines[key],Table.EDGE,Table.DRONE_OUTLINE_WIDTH,true)
  view.draw_line(Vector2(-8,-5),Vector2(-8,5),Table.AMBER,3.)
static func siren(view,role:String,shade:Color)->void:
 prepare()
 # The dense material is nearly opaque for these three normal roles. Only the
 # Sweeper's real texture holes and existing layered pin fade need a backing.
 if shade.a<1. or role in Table.NORMAL_UNDERLAY:
  view.draw_mesh(meshes[role],null,Transform2D.IDENTITY,Color(Table.SIREN_BODY,shade.a))
 # Modulate preserves the original continuous pin-depth tint without mutable
 # packed colors or per-frame polygon triangulation in CanvasItem.
 view.draw_mesh(meshes[role],RAY,Transform2D.IDENTITY,shade)
 view.draw_polyline(outlines[role],Color(Table.SIREN_EDGE,shade.a),Table.SIREN_OUTLINE_WIDTH,true)
 # Red lighting is already carried by the retained biological material.
 if role=="hunter":
  for n in Table.HUNTER_SEGMENTS:
   var x=-38.+n*Table.HUNTER_PITCH
   view.draw_line(Vector2(x,-7),Vector2(x+5,6),Color(Table.SIREN_SEGMENT,shade.a),Table.SIREN_OUTLINE_WIDTH)
  view.draw_line(Vector2(-58,0),Vector2(-92,5),Color(Table.SIREN_FILAMENT,shade.a*Table.FILAMENT_ALPHA),Table.HULL_OUTLINE_WIDTH)
static func installation(view,recorded:bool)->void:
 prepare()
 view.draw_mesh(meshes.installation,null,Transform2D.IDENTITY,Table.INDUSTRY_BODY)
 view.draw_polyline(outlines.installation,Table.INDUSTRY_EDGE,Table.SEAM_WIDTH,true)
 for x in Table.INDUSTRY_RIBS:
  view.draw_line(Vector2(x,-58),Vector2(x,24),Table.INDUSTRY_DARK,Table.RIB_WIDTH)
  view.draw_line(Vector2(x+2,-54),Vector2(x+2,18),Table.CYAN if x<0 else Table.AMBER,Table.SEAM_WIDTH)
 for y in Table.INDUSTRY_CROSSBARS:view.draw_line(Vector2(-34,y),Vector2(34,y),Table.INDUSTRY_EDGE,Table.SEAM_WIDTH)
 view.draw_circle(Vector2(0,-32),Table.INDUSTRY_PORT_RADIUS,Table.INDUSTRY_PORT)
 view.draw_arc(Vector2(0,-32),Table.INDUSTRY_RING_RADIUS,0.,TAU,Table.INDUSTRY_ARC_SEGMENTS,Table.CYAN if recorded else Table.AMBER,Table.SEAM_WIDTH)
static func factory(view,r:Rect2,scale:float)->void:
 # Detail remains within the already earned/briefed manufactured rectangle.
 var inset=minf(r.size.x,r.size.y)*Table.FACTORY_INSET
 for n in Table.FACTORY_BAYS:
  var x=r.position.x+r.size.x*(.12+n*.24)
  view.draw_line(Vector2(x,r.position.y+inset),Vector2(x+inset,r.position.y+inset*2),Table.AMBER,Table.FACTORY_STROKE/maxf(Table.DETAIL_MIN_SCALE,scale))
  view.draw_line(Vector2(x,r.end.y-inset),Vector2(x+inset,r.end.y-inset*2),Table.CYAN,Table.FACTORY_STROKE/maxf(Table.DETAIL_MIN_SCALE,scale))
static func face(view,a:Vector2,b:Vector2,inward:Vector2,scale:float)->void:
 # Only this measured 18m strip; never infer the rest of a hidden factory.
 var middle=a.lerp(b,.5)
 view.draw_line(middle+inward*4.,middle+inward*14.,Table.AMBER,Table.SEAM_WIDTH/maxf(Table.DETAIL_MIN_SCALE,scale))
static func cache_lamp(fov:float,reach:float,strength:float)->void:
 # Called by the existing photographic cache publication. A single bounded
 # local shape changes only when actual optics change, never with craft motion.
 prepare()
 var length=minf(reach,Table.LAMP_FADE_LENGTH)
 if fov==lamp_fov and length==lamp_length and strength==lamp_strength:return
 lamp_fov=fov;lamp_length=length;lamp_strength=strength
 lamp[0]=Vector2.ZERO;lamp[1]=Vector2.from_angle(-fov*.5)*length;lamp[2]=Vector2.from_angle(fov*.5)*length
 lamp_colors[0]=Color(Table.LAMP,Table.LAMP_ALPHA*strength/Table.LAMP_REFERENCE)
 lamp_colors[1]=Color(Table.LAMP,0);lamp_colors[2]=lamp_colors[1]
 lamp_arrays[Mesh.ARRAY_VERTEX]=lamp;lamp_arrays[Mesh.ARRAY_COLOR]=lamp_colors
 meshes.lamp.clear_surfaces()
 meshes.lamp.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,lamp_arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES)
static func lamp_wash(view,pos:Vector2,aim:float)->void:
 if lamp_strength<=0:return
 view.draw_set_transform(view.world_offset+pos*view.world_scale,aim,Vector2.ONE*view.world_scale)
 if Palette.high_contrast():view.draw_mesh(meshes.lamp,null,Transform2D.IDENTITY,Color(1,1,1,.2))
 else:view.draw_mesh(meshes.lamp,null)
 view.draw_set_transform(view.world_offset,0,Vector2.ONE*view.world_scale)
static func lamp_guide(view,pos:Vector2,aim:float,fov:float,reach:float)->void:
 # A short, dashed camera-direction instrument on earned charts. No filled
 # corridor or terrain sample; its fade cap is presentation, never visibility.
 var length=minf(reach,Table.LAMP_FADE_LENGTH)
 var tint=Color(Table.LAMP,Table.LAMP_GUIDE_ALPHA*(.2 if Palette.high_contrast() else 1.))
 for side in 2:
  var direction=Vector2.from_angle(aim+fov*(float(side)-.5))
  for n in Table.LAMP_GUIDE_DASHES:
   var start=Table.LAMP_GUIDE_START+n*length*Table.LAMP_GUIDE_STEP
   view.draw_line(pos+direction*start,pos+direction*(start+length*Table.LAMP_GUIDE_DUTY),tint,Table.HULL_OUTLINE_WIDTH)
