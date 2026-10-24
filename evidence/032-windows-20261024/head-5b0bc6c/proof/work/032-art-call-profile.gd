extends SceneTree
# Diagnostic only: actual native Canvas calls for the frozen new art bodies.
# Timer/proxy overhead is included; this is not the paired performance verdict.
const Art=preload("res://src/presentation/art/art_renderer.gd")
const Table=preload("res://src/presentation/art/art_table.gd")
class Proxy:
 extends RefCounted
 var canvas
 var quietus=preload("res://assets/craft/quietus.png")
 var world_offset=Vector2(0,190)
 var world_scale=.8
 var costs=PackedInt64Array([0,0,0,0,0,0,0])
 var counts=PackedInt64Array([0,0,0,0,0,0,0])
 func note(slot,at):costs[slot]+=Time.get_ticks_usec()-at;counts[slot]+=1
 func draw_polygon(a,b,c=PackedVector2Array(),d=null):
  var at=Time.get_ticks_usec();canvas.draw_polygon(a,b,c,d);note(0,at)
 func draw_polyline(a,b,c,d=true):
  var at=Time.get_ticks_usec();canvas.draw_polyline(a,b,c,d);note(1,at)
 func draw_colored_polygon(a,b):
  var at=Time.get_ticks_usec();canvas.draw_colored_polygon(a,b);note(2,at)
 func draw_line(a,b,c,d):
  var at=Time.get_ticks_usec();canvas.draw_line(a,b,c,d);note(3,at)
 func draw_circle(a,b,c):
  var at=Time.get_ticks_usec();canvas.draw_circle(a,b,c);note(4,at)
 func draw_texture_rect_region(a,b,c):
  var at=Time.get_ticks_usec();canvas.draw_texture_rect_region(a,b,c);note(5,at)
 func draw_set_transform(a,b=0.,c=Vector2.ONE):
  var at=Time.get_ticks_usec();canvas.draw_set_transform(a,b,c);note(6,at)
class View extends Control:
 var proxy
 var total=0
 func _draw():
  proxy.costs.fill(0);proxy.counts.fill(0)
  var at=Time.get_ticks_usec()
  for index in 3:
   proxy.draw_set_transform(Vector2(280+index*160,600),0.,Vector2.ONE*.8)
   Art.craft(proxy,index)
  var index=0
  for role in Table.ROLE_RECTS:
   proxy.draw_set_transform(Vector2(280+index*170,300),0.,Vector2.ONE*.8)
   Art.siren(proxy,role,Color.WHITE);index+=1
  Art.lamp_wash(proxy,Vector2(1000,300),0.)
  total=Time.get_ticks_usec()-at
var folder=""
func _initialize():call_deferred("run")
func frame(view):
 view.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
 if DisplayServer.get_name()=="headless" or folder.is_empty():printerr("Native explicit output required");quit(1);return
 root.size=Vector2i(2184,1968);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 Art.prepare();Art.cache_lamp(1.05,240.,.36)
 var view=View.new();view.proxy=Proxy.new();view.proxy.canvas=view;view.size=root.get_visible_rect().size;root.add_child(view)
 for n in 90:await frame(view)
 var rows=[]
 for n in 300:
  await frame(view)
  rows.append({"total_usec":view.total,"cost_usec":view.proxy.costs.duplicate(),"calls":view.proxy.counts.duplicate()})
 var valid=rows.size()==300 and rows[0].calls[0]>0 and rows[0].calls[1]>0
 var file=FileAccess.open(folder.path_join("profile.json"),FileAccess.WRITE)
 file.store_string(JSON.stringify({"source":"7619ff17069bf52534239702c54462bac8793561","scope":"new art seven bodies+lamp only, actual native calls; proxy/timer overhead included","slots":["draw_polygon","draw_polyline","draw_colored_polygon","draw_line","draw_circle","draw_texture_rect_region","draw_set_transform"],"adapter":RenderingServer.get_video_adapter_name(),"rows":rows}));file.close()
 view.proxy.canvas=null;view.queue_free();await process_frame
 print("ART PROFILE CHECKS 1 FAILURES ",0 if valid else 1);quit(0 if valid else 1)
