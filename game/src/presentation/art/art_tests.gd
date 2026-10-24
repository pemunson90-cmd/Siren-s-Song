extends RefCounted
class Canvas:
 extends RefCounted
 var quietus=preload("res://assets/craft/quietus.png")
 var calls=0
 var mesh_calls=0
 var vertices=[]
 var modulates=[]
 var world_offset=Vector2.ZERO
 var world_scale=1.0
 func draw_set_transform(_p,_r=0.,_s=Vector2.ONE):pass
 func draw_mesh(_mesh,_texture=null,_transform=Transform2D.IDENTITY,modulate=Color.WHITE):calls+=1;mesh_calls+=1;modulates.append(modulate)
 func draw_texture_rect_region(_a,_b,_c):calls+=1
 func draw_polyline(a,_b,_c,_d=true):calls+=1;vertices.append_array(a)
 func draw_line(a,b,_c,_d):calls+=1;vertices.append_array([a,b])
 func draw_circle(a,r,_c):calls+=1;vertices.append_array([a-Vector2.ONE*r,a+Vector2.ONE*r])
 func draw_colored_polygon(a,_b):calls+=1;vertices.append_array(a)
 func draw_polygon(a,_b,_c=PackedVector2Array(),_d=null):calls+=1;vertices.append_array(a)
 func draw_rect(r,_color,_filled=true,_width=-1):calls+=1;vertices.append_array([r.position,r.end])
 func draw_texture_rect(_texture,r,_tile=false,_modulate=Color.WHITE):calls+=1;vertices.append_array([r.position,r.end])
 func draw_arc(p,r,_from,_to,_segments,_color,_width):calls+=1;vertices.append_array([p-Vector2.ONE*r,p+Vector2.ONE*r])
# Feature-local contracts. Native pixels and complete state checks live in the
# same-source art_render_measurements fixture.
static func run()->Dictionary:
 var checks=0;var failures=0
 var path="res://src/presentation/art/art_table.gd"
 checks+=1
 if not ResourceLoader.exists(path):
  printerr("FAIL cached art table is installed")
  return {"checks":checks,"failures":1}
 var table=load(path)
 var signatures={}
 for key in ["quietus","drone_a","drone_b","patroller","sentinel","sweeper","hunter","installation"]:
  checks+=1
  var points:PackedVector2Array=table.SHAPES[key]
  var valid=points.size()>=4
  var bounds:Vector2=table.BOUNDS[key]
  for p in points:valid=valid and p.is_finite() and absf(p.x)<=bounds.x and absf(p.y)<=bounds.y
  if not valid:failures+=1;printerr("FAIL finite footprint ",key)
  checks+=1
  var signature=var_to_bytes(points).hex_encode().sha256_text()
  if signatures.has(signature):failures+=1;printerr("FAIL distinct silhouette ",key)
  signatures[signature]=true
 checks+=1
 var previous=table.enabled;table.enabled=false
 if table.enabled:failures+=1;printerr("FAIL old look switch")
 table.enabled=previous
 var renderer=load("res://src/presentation/art/art_renderer.gd")
 renderer.prepare()
 renderer.cache_lamp(1.,240.,.36)
 var geometry=var_to_bytes(renderer.outlines)
 var lamp_geometry=var_to_bytes(renderer.lamp)
 var lamp_palette=var_to_bytes(renderer.lamp_colors)
 var mesh_state={}
 for key in renderer.meshes:
  var mesh=renderer.meshes[key]
  checks+=1
  if mesh.get_surface_count()!=1:failures+=1;printerr("FAIL prepared mesh surface ",key);continue
  var arrays=mesh.surface_get_arrays(0);var points=arrays[Mesh.ARRAY_VERTEX];var indices=arrays[Mesh.ARRAY_INDEX]
  var valid=points.size()>=3 and indices.size()>0 and indices.size()%3==0
  for index in indices:valid=valid and index>=0 and index<points.size()
  if table.SHAPES.has(key):
   valid=valid and points.size()==table.SHAPES[key].size()
   for n in points.size():valid=valid and Vector2(points[n].x,points[n].y)==table.SHAPES[key][n]
  if renderer.uvs.has(key):valid=valid and arrays[Mesh.ARRAY_TEX_UV]==renderer.uvs[key]
  if not valid:failures+=1;printerr("FAIL finite indexed mesh preserves exact shape and UV ",key)
  mesh_state[key]=var_to_bytes(arrays)
  mesh_state[key+"_id"]=mesh.get_instance_id()
 var canvas=Canvas.new()
 var before_calls=canvas.calls;renderer.craft(canvas,0)
 checks+=1
 if canvas.calls-before_calls!=2:failures+=1;printerr("FAIL Quietus budget retains texture and outline without redundant ornament")
 for index in [1,2]:
  before_calls=canvas.calls;renderer.craft(canvas,index)
  checks+=1
  if canvas.calls-before_calls!=3:failures+=1;printerr("FAIL drone budget retains filled outline and amber instrument")
 for role in table.ROLE_RECTS:
  var before_meshes=canvas.mesh_calls;renderer.siren(canvas,role,Color.WHITE)
  checks+=1
  if canvas.mesh_calls-before_meshes!=(2 if role=="sweeper" else 1):failures+=1;printerr("FAIL role material budget retains only necessary normal underlay ",role)
 var before_meshes=canvas.mesh_calls;renderer.siren(canvas,"patroller",Color(.5,.6,.7,.8))
 checks+=1
 if canvas.mesh_calls-before_meshes!=2:failures+=1;printerr("FAIL pin fade retains its existing layered body alpha")
 var objects=Performance.get_monitor(Performance.OBJECT_COUNT)
 for n in 100:
  for index in 3:renderer.craft(canvas,index)
  for role in table.ROLE_RECTS:renderer.siren(canvas,role,Color.WHITE)
  renderer.lamp_wash(canvas,Vector2(n,0),0.)
  renderer.lamp_guide(canvas,Vector2.ZERO,0.,1.,240.)
 checks+=1
 # Two unused ornamental aperture discs were removed from the prepared cache.
 if geometry!=var_to_bytes(renderer.outlines) or lamp_geometry!=var_to_bytes(renderer.lamp) or lamp_palette!=var_to_bytes(renderer.lamp_colors) or renderer.meshes.size()!=8 or renderer.lamp.size()!=3 or renderer.lamp_colors.size()!=3 or renderer.uvs.size()!=4:
  failures+=1;printerr("FAIL repeated drawing retains bounded immutable geometry cache")
 for key in renderer.meshes:
  checks+=1
  if mesh_state[key]!=var_to_bytes(renderer.meshes[key].surface_get_arrays(0)) or mesh_state[key+"_id"]!=renderer.meshes[key].get_instance_id():
   failures+=1;printerr("FAIL drawing preserves cached mesh contents and identity ",key)
 var exact_tint=Color(.33,.55,.66,.77);renderer.siren(canvas,"sentinel",exact_tint)
 checks+=1
 if not canvas.modulates.has(exact_tint):failures+=1;printerr("FAIL continuous pin tint remains exact")
 checks+=1
 if objects!=Performance.get_monitor(Performance.OBJECT_COUNT):failures+=1;printerr("FAIL repeated art creates no retained objects")
 var world=load("res://src/presentation/confluence_world.gd")
 var factory_canvas=Canvas.new();var footprint=Rect2(100,100,400,300)
 var context={"landmarks":[{"kind":"factory","rect":footprint}]}
 world.draw_landmarks(factory_canvas,context,1.)
 checks+=1
 if factory_canvas.calls!=0:failures+=1;printerr("FAIL unknown factory remains absent")
 context["surface_segments"]=[PackedVector2Array([Vector2(140,100),Vector2(220,100)])]
 world.draw_landmarks(factory_canvas,context,1.)
 checks+=1
 if factory_canvas.vertices.is_empty() or not factory_canvas.vertices.all(func(p):return p.x>=140 and p.x<=220 and p.y>=100 and p.y<=118):
  failures+=1;printerr("FAIL partial factory stays inside measured 18m strip")
 factory_canvas.vertices=[]
 context.surface_segments=[PackedVector2Array([Vector2(100,100),Vector2(500,100)]),PackedVector2Array([Vector2(500,100),Vector2(500,400)]),PackedVector2Array([Vector2(500,400),Vector2(100,400)]),PackedVector2Array([Vector2(100,400),Vector2(100,100)])]
 world.draw_landmarks(factory_canvas,context,1.)
 checks+=1
 if factory_canvas.vertices.is_empty() or not factory_canvas.vertices.all(func(p):return footprint.grow(.01).has_point(p)):
  failures+=1;printerr("FAIL fully earned factory detail stays inside actual footprint")
 var source=FileAccess.get_file_as_string("res://src/presentation/art/art_renderer.gd")
 var draw_source=source.substr(source.find("static func craft"))
 checks+=1
 if ".new(" in draw_source or "PackedVector2Array(" in draw_source or "PackedColorArray(" in draw_source or "=[]" in draw_source or "={}" in draw_source:
  failures+=1;printerr("FAIL new draw paths construct no per-frame collections/resources")
 var sim=load("res://src/simulation/simulation.gd").new();sim.start(0,"endurance")
 var feed=load("res://src/presentation/camera_feed.gd").new()
 feed.art_lamp_source=sim.mission;feed.art_lamp_unit=sim.selected;feed.art_lamp_band=sim.units[sim.selected].band
 feed.art_lamp_mission=sim.mission.id;feed.art_lamp_clock=sim.elapsed;feed.art_lamp_strength=.36
 checks+=1
 if not feed.art_lamp_current(sim):failures+=1;printerr("FAIL valid own cached lamp")
 for gate in ["dead","band","selected","expired","outcome","hidden","mission"]:
  var alive=sim.units[0].alive;var band=sim.units[0].band;var clock=sim.elapsed;var mission=sim.mission
  if gate=="dead":sim.units[0].alive=false
  if gate=="band":sim.units[0].band=0 if band!=0 else 2
  if gate=="selected":sim.selected=1
  if gate=="expired":sim.elapsed+=.31
  if gate=="outcome":sim.outcome="won"
  if gate=="hidden":feed.visible=false
  if gate=="mission":sim.mission=sim.mission.duplicate(true)
  checks+=1
  if feed.art_lamp_current(sim):failures+=1;printerr("FAIL own cached lamp closes on ",gate)
  sim.units[0].alive=alive;sim.units[0].band=band;sim.elapsed=clock;sim.selected=0;sim.outcome="";feed.visible=true;sim.mission=mission
 checks+=1
 var camera_source=FileAccess.get_file_as_string("res://src/presentation/camera_feed.gd")
 if "art_lamp_strength=float(op.lamp)" not in camera_source or "art_lamp_strength=float(_frame" in camera_source:
  failures+=1;printerr("FAIL lamp strength comes only from own steady optics, not preview flash")
 feed.free();sim=null;canvas=null;factory_canvas=null
 return {"checks":checks,"failures":failures}
