extends SceneTree
# Actual-render regression. Run with Compatibility and an X display; the
# headless route-editor harnesses separately exercise commands and gestures.
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func frame():
 for n in 4:await process_frame
 await RenderingServer.frame_post_draw
func image_of(preview):
 return root.get_texture().get_image().get_region(Rect2i(preview.get_global_rect()))
func capture(img:Image,name:String):
 if not folder.is_empty():img.save_png(folder.path_join(name+".png"))
func run():
 if DisplayServer.get_name()=="headless":printerr("Planner chart render checks require an actual Compatibility display");quit(2);return
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 root.content_scale_size=Vector2i.ZERO;root.size=Vector2i(1200,900)
 var sim=load("res://src/simulation/simulation.gd").new();sim.start(10)
 var preview=load("res://src/presentation/route_program_preview.gd").new();preview.sim=sim;preview.position=Vector2(20,30);preview.size=Vector2(1120,800);root.add_child(preview);await frame()
 preview.fit_chart();await frame();var before=sim.snapshot();var img=image_of(preview)
 var rock=Vector2i(preview.screen_position(Vector2(1000,1200)));var water=Vector2i(preview.screen_position(Vector2(1150,1200)))
 check(img.get_pixelv(rock)!=img.get_pixelv(water),"charted basalt differs visibly from adjacent open water in the route planner")
 check(sim.snapshot()==before,"reading and drawing planning context preserve the actual mission")
 capture(img,"charted-warning")
 sim.start(11);preview.fit_chart();preview.queue_redraw();await frame();var earned=image_of(preview)
 # This source-known fixture changes an unmeasured private obstacle, leaving
 # the actual public chart intact. It must produce no new planning silhouette.
 sim.mission.rocks.append(Rect2(1500,400,200,200));sim.sirens[0].pos=Vector2(1700,500)
 preview.queue_redraw();await frame();var unseen=image_of(preview)
 check(earned.get_data()==unseen.get_data(),"unseen terrain and hostile movement cannot change the earned-chart preview")
 capture(unseen,"earned-confluence")
 print("PLANNER CHART RENDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
