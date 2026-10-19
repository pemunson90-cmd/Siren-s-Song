extends SceneTree
var game
var preview
var expected=preload("res://src/presentation/chart_camera.gd").new()
var gesture=preload("res://src/input/map_gesture.gd").new()
var folder=""
var events=[]
func _initialize():call_deferred("run")
func send(kind:String,index:int,p:Vector2):
 var e
 if index>=0:
  if kind=="move":e=InputEventScreenDrag.new();e.index=index
  else:e=InputEventScreenTouch.new();e.index=index;e.pressed=kind=="press"
 else:
  if kind=="move":e=InputEventMouseMotion.new()
  else:e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=kind=="press"
 e.position=p+preview.global_position;root.push_input(e,true)
 var a=gesture.feed(kind,index,p)
 if a.has("zoom"):expected.zoom_at(a.zoom,a.anchor)
 if a.has("pan"):expected.pan(a.pan)
 events.append({"kind":kind,"index":index,"preview_point":str(p)})
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
 root.size=Vector2i(2520,1080);await process_frame;await process_frame
 game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.fixture_safe_area=Rect2(136,0,2384,1080);game.capture_scenario="planner-navigation";root.add_child(game)
 for i in 6:await process_frame
 game.set_process(false);game._start_mission(0)
 game.sim.command("route",{"point":Vector2(260,800)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(380,800)});game.sim.command("route",{"point":Vector2(540,800)})
 game._order("program")
 for i in 8:await process_frame
 game.route_editor.selected_goal=1;game.route_editor.refresh()
 for i in 5:await process_frame
 preview=game.route_editor.preview;expected.configure(preview.size)
 var anchor=expected.to_screen(Vector2(380,800));var before=game.sim.snapshot();DirAccess.make_dir_recursive_absolute(folder)
 for n in 144:
  var stage=n%24
  if n in [24,48]:send("press",0,anchor-Vector2(30,0))
  if n in [25,49]:send("press",1,anchor+Vector2(30,0))
  if n in [26,50]:send("move",0,anchor-Vector2(60,0))
  if n in [27,51]:send("move",1,anchor+Vector2(60,0))
  if n in [28,52]:send("release",0,anchor-Vector2(60,0))
  if n in [29,53]:send("release",1,anchor+Vector2(60,0))
  if n==84:send("press",-1,anchor)
  if n==85:send("move",-1,anchor+Vector2(36,0))
  if n==86:send("release",-1,anchor+Vector2(36,0))
  if n==120:send("press",0,expected.to_screen(Vector2(400,780)))
  if n==121:send("release",0,expected.to_screen(Vector2(400,780)))
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
 var report={"fps":12,"frames":144,"paused":game.sim.paused,"elapsed":game.sim.elapsed,"preview_size":str(preview.size),"initial_chart":str(Rect2((preview.size-Vector2(1600,960)*minf(preview.size.x/1600,preview.size.y/960))/2,Vector2(1600,960)*minf(preview.size.x/1600,preview.size.y/960))),"events":events,"desired_final_point":"(400,780)","expected_zoom":expected.zoom,"actual_chart":str(preview.chart_rect()),"actual_goals":game.sim.route_goals(),"selected":game.route_editor.selected_goal,"resources_unchanged":game.sim.tools==before.tools and game.sim.hull==before.hull and game.sim.oxygen==before.oxygen}
 var f=FileAccess.open(folder.path_join("trace.json"),FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print("PLANNER_TRACE ",report)
 game.queue_free();await process_frame;await create_timer(.5).timeout;quit()
