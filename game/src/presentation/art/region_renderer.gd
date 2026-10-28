extends RefCounted
# All atmosphere stays below stone, unknown-water masking, instruments and contacts.
# Fixed draw budget, no geometry generation, random stream, nodes or sensing calls.
const Palette=preload("res://src/presentation/accessibility/palette.gd")
static func atmosphere(view,style:Dictionary,extent:Vector2,phase:float)->void:
 if style.is_empty():return
 phase=Palette.motion_phase(phase)
 var light:Color=style.light
 if Palette.high_contrast():light.a*=.2
 for band in 8:
  var fraction=float(band)/7.
  view.draw_rect(Rect2(0,extent.y*band/8.,extent.x,extent.y/8.+1.),Color(light,light.a*(1.-fraction)))
  view.draw_rect(Rect2(0,extent.y*band/8.,extent.x,extent.y/8.+1.),Color(.005,.008,.016,float(style.falloff)*fraction))
 var drift:Vector2=style.drift
 # Tile the bounded viewport, rather than enumerating the whole world.
 var visible=Rect2(-view.world_offset/view.world_scale,view.size/view.world_scale)
 var tile=maxf(160.,80./maxf(.01,view.world_scale))
 var moving=drift*phase
 var low=Vector2i((visible.position-moving)/tile)-Vector2i.ONE
 var high=Vector2i((visible.end-moving)/tile)+Vector2i.ONE
 for y in range(low.y,high.y+1):
  for x in range(low.x,high.x+1):
   var seed_value=absi(x*73856093 ^ y*19349663)
   var at=Vector2(x*tile+float(seed_value%131),y*tile+float((seed_value/131)%137))+moving
   if at.x<0 or at.y<0 or at.x>extent.x or at.y>extent.y:continue
   view.draw_line(at,at+drift.normalized()*3.5,Color(style.dust,style.dust.a*.2) if Palette.high_contrast() else style.dust,1./maxf(.35,view.world_scale))
static func chart_terrain(view,data:Dictionary,scale:float,style:Dictionary)->void:
 var cell=float(data.get("cell_size",40.))
 for tile in data.get("clear_cells",[]):
  view.draw_rect(Rect2(Vector2(tile)*cell,Vector2.ONE*cell),Color(style.floor,.7))
 # Identical measured endpoints and widths to the preceding chart renderer.
 for face in data.get("surface_segments",[]):
  if face.size()!=2:continue
  view.draw_line(face[0],face[1],Color(style.stone,.95),7./maxf(scale,.01))
  view.draw_line(face[0],face[1],style.edge,Palette.stroke(2.)/maxf(scale,.01))
