extends SceneTree
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func click(button):
 var p=button.get_global_rect().get_center()
 var move=InputEventMouseMotion.new();move.position=p;root.push_input(move,true)
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func capture(name:String):
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func covered_area(rects:Array,bounds:Rect2) -> float:
 var xs=[];var clipped=[]
 for rect in rects:
  var r=rect.intersection(bounds)
  if r.has_area():clipped.append(r);xs.append(r.position.x);xs.append(r.end.x)
 xs.sort();var area=0.
 for n in range(1,xs.size()):
  var intervals=[]
  for r in clipped:
   if r.position.x<xs[n] and r.end.x>xs[n-1]:intervals.append(Vector2(r.position.y,r.end.y))
  intervals.sort_custom(func(a,b):return a.x<b.x)
  var bottom=-1.;var height=0.
  for v in intervals:
   height+=maxf(0,v.y-maxf(v.x,bottom));bottom=maxf(bottom,v.y)
  area+=(xs[n]-xs[n-1])*height
 return area
func touch(point:Vector2,down:bool):
 var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="playfield-hud"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
  var name="cover" if dimensions.x==2520 else "inner";var ocean=game.ocean
  await capture(name+"-start")
  if game.get("mission_hud")!=null:
   var exposed=1.-covered_area(game.mission_hud.occupied_rects(),game.get_global_rect())/(game.size.x*game.size.y)
   print("PLAYFIELD_WATER ",name," unobscured=",exposed," camera=",ocean.chart_camera.center," mode=",ocean.chart_camera.mode)
   check(exposed>=(.75 if name=="cover" else .82),"persistent HUD leaves most water unobscured")
   var scale=Vector2(dimensions)/root.get_visible_rect().size
   for button in game.mission_hud.action_controls().values():
    var font=button.get_theme_font("font");var font_size=button.get_theme_font_size("font_size");var content=button.get_theme_stylebox("normal").get_minimum_size()
    for line in button.text.split("\n"):check(font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+content.x<=button.size.x+.1,"persistent caption fits at unchanged full type size")
   var controls=game._ui_metrics().controls
   for n in controls.size():
    var c=controls[n];var r=Rect2(c.hit_rect[0],c.hit_rect[1],c.hit_rect[2],c.hit_rect[3])
    check(not c.clipped and r.size.x*scale.x>=125.99 and r.size.y*scale.y>=125.99,"actual persistent chart target48dp "+c.action)
    for j in range(n):
     var b=controls[j].hit_rect
     check(not r.intersects(Rect2(b[0],b[1],b[2],b[3])),"actual persistent chart controls do not overlap")
  check(ocean.position==Vector2.ZERO and ocean.size==game.size,"water fills safe viewport")
  var follows=ocean.chart_camera.has_method("follow")
  check(follows,"default camera supports physical craft follow")
  if follows:check(ocean.chart_camera.mode=="follow" and ocean.chart_camera.zoom>1,"fresh dive starts in tactical FOLLOW rather than FIT")
  game._order("route",{"point":Vector2(620,800)});game.sim.paused=false
  var start=game.sim.units[0].pos;var camera_start=ocean.chart_camera.center
  for n in 600:game.sim.advance(1./60.)
  ocean._sync_camera();game._refresh();await settle();await capture(name+"-moving")
  if not follows:game.queue_free();await settle();continue
  print("PLAYFIELD_SCROLL ",name," craft=",start," -> ",game.sim.units[0].pos," camera=",camera_start," -> ",ocean.chart_camera.center)
  check(game.sim.units[0].pos.distance_to(start)>100 and ocean.chart_camera.center.distance_to(camera_start)>30,"actual physical movement scrolls the followed playfield")
  var destination=game.sim.units[0].pos+Vector2(220,-20);var latest=ocean.global_position+ocean.screen_position(destination)
  await touch(latest,true);await touch(latest,false);await settle()
  check(not game.sim.route_goals().is_empty() and game.sim.route_goals()[0].pos.distance_to(destination)<.1,"ordinary route tap after physical follow uses latest camera transform")
  await click(game.pause_button);check(game.sim.paused,"persistent PAUSE remains immediate after actual moving play")
  var state=game.sim.snapshot();ocean.pan_chart(Vector2(-90,0));var manual=ocean.chart_camera.center
  game._order("select",{"unit":1});ocean._sync_camera()
  check(ocean.chart_camera.mode=="free" and ocean.chart_camera.center.distance_to(manual)<.1,"free look survives craft selection without camera jump")
  ocean.fit_chart();game._order("select",{"unit":0});ocean._sync_camera()
  check(ocean.chart_camera.mode=="overview" and ocean.chart_camera.zoom==1,"FIT stays overview through craft selection")
  game._focus_craft();check(ocean.chart_camera.mode=="follow","FOCUS explicitly returns to craft follow")
  var before=game.sim.snapshot();game.mission_hud.open("craft")
  check(game.advanced_orders and game.sim.snapshot()==before,"orders sheet opens without changing route or pause")
  await capture(name+"-orders")
  await click(game.mission_hud.extra.tools_menu)
  await click(game.order_buttons.decoy)
  check(game.decoy_armed and not game.advanced_orders,"context tool closes sheet into explicit map aim")
  before=game.sim.snapshot();await click(game.mission_hud.close_button)
  check(not game.decoy_armed and game.sim.snapshot()==before,"persistent CANCEL leaves no tool spend or world order")
  await click(game.pause_button);check(not game.sim.paused,"paused orders aim and cancel return directly to running play")
  await click(game.pause_button)
  # Opening and dismissing an overlay cannot convert its touch into a chart order.
  before=game.sim.snapshot();await click(game.advanced_button)
  var outside=game.global_position+Vector2(32,game.size.y*.5)
  await touch(outside,true);await touch(outside,false);await settle()
  check(not game.advanced_orders and game.sim.snapshot()==before and not game.map_gesture.active(),"outside-sheet dismissal consumes the whole gesture")
  game.mission_hud.open("craft");await settle()
  await click(game.mission_hud.instrument_button)
  check(game.advanced_orders and game.mission_hud.instrument_info.visible and "OPEN WATER" in game.mission_hud.instrument_info.text and "reception unknown" in game.mission_hud.instrument_info.text,"expandable instruments keep truthful acoustic uncertainty")
  game.mission_hud.dismiss()
  ocean.pan_chart(Vector2(-40,-10));var camera_state=ocean.chart_camera.snapshot();var archive=game._archive()
  check(game.store.valid(archive) and archive.chart_view==camera_state,"save includes view intent alongside a valid unchanged tactical archive")
  var saved_camera=preload("res://src/presentation/chart_camera.gd").new();saved_camera.configure(ocean.size,ocean.world_size());saved_camera.restore(archive.chart_view)
  check(saved_camera.snapshot()==camera_state,"camera save restore retains manual center zoom and mode")
  var other=Vector2i(2184,1968) if dimensions.x==2520 else Vector2i(2520,1080)
  root.size=other;await settle()
  check(ocean.chart_camera.mode=="free" and ocean.chart_camera.desired_center==camera_state.center,"resize preserves manual camera intent")
  game._show_campaign();game._enter_water();await settle()
  check(ocean.chart_camera.mode=="free" and ocean.chart_camera.desired_center==camera_state.center,"operations resume preserves manual camera intent")
  var old_path=game.store.path;game.store.path="user://optional-view-"+name+".save"
  var invalid_view=game._archive();invalid_view.chart_view=["invalid optional presentation state"]
  check(game.store.save(invalid_view),"optional invalid presentation field leaves the tactical archive valid")
  game._load_archive()
  check(game.sim.snapshot()==invalid_view.active,"loading an invalid optional view preserves valid tactical progress")
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
  game.store.path=old_path
  game.queue_free();await settle()
 var region_camera=preload("res://src/presentation/chart_camera.gd").new();region_camera.configure(Vector2(1200,800),Vector2(2000,2400));region_camera.follow(Vector2(1700,2100))
 check(region_camera.to_world(region_camera.to_screen(Vector2(1800,2200))).distance_to(Vector2(1800,2200))<.01 and region_camera.center.y>1600,"camera follows and maps genuine larger-world coordinates")
 region_camera.fit();check(region_camera.center==Vector2(1000,1200) and region_camera.zoom==1,"explicit overview fits actual supplied world dimensions")
 print("PLAYFIELD HUD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
