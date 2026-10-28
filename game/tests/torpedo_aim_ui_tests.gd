extends SceneTree
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func frames():
 for i in 3:await process_frame
func pointer(p:Vector2,down:bool,touch:bool=false,emulated:bool=false):
 var e
 if touch:e=InputEventScreenTouch.new();e.index=0
 else:e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.global_position=p
 e.position=p;e.pressed=down
 if emulated:e.device=InputEvent.DEVICE_ID_EMULATION
 root.push_input(e,true);await process_frame
func click(p:Vector2,touch:bool=false):
 await pointer(p,true,touch);await pointer(p,false,touch);await frames()
func setup(g):
 # The original aim cases require two finite torpedoes on Quietus.
 g.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();g.tool_racks.quietus.knock=2
 g._start_mission(4);g.sim.units[0].pos=Vector2(600,750)
 for i in 2:g.sim.sirens[i].pos=Vector2(710+2*i,750);g.sim.sirens[i].vel=Vector2.ZERO;g.sim.sirens[i].band=1;g.sim.sirens[i].transition={}
 g.sim.paused=false
 for i in 24:g.sim.advance(1./60)
 g.sim.paused=true;g.sim._observe();g._toggle_advanced();g._order("knock");g._refresh();await frames()
func run():
 var edge=preload("res://src/presentation/torpedo_aim.gd").layout([{"key":0,"tag":"S1","anchor":Vector2(2,250)}],Rect2(8,8,784,484),48,[])
 check(edge.size()==1 and Rect2(8,8,784,484).encloses(edge[0].rect),"visible edge contact retains a full-size inset callout")
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for profile in [{"name":"cover","size":Vector2i(2520,1080),"inset":136},{"name":"inner","size":Vector2i(2184,1968),"inset":0}]:
  root.size=profile.size;await frames()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(preload("res://tests/fit_label_main.gd"));g.fixture_dpi=420.
  if profile.inset:g.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(g);await frames();await setup(g)
  check(g.ocean.has_method("knock_aim_targets"),"overlapping fresh contacts provide distinct selectable aim callouts")
  if not g.ocean.has_method("knock_aim_targets"):g.queue_free();await frames();finish();return
  if not capture_dir.is_empty():
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir+"/challenger-"+profile.name+".png")
  var aims=g.ocean.knock_aim_targets();var scale=Vector2(profile.size)/g.get_viewport_rect().size
  check(aims.size()==2 and aims[0].key==0 and aims[1].key==1,"aim callouts preserve deterministic observed identity order")
  var live=g.sim.sirens;g.sim.sirens=[]
  check(g.ocean.knock_aim_targets()==aims,"aim geometry cannot query hidden live Siren count or positions")
  g.sim.sirens=live
  if aims.size()!=2:g.queue_free();await frames();finish();return
  check(not aims[0].rect.intersects(aims[1].rect),"overlapping world contacts have nonoverlapping touch targets")
  for a in aims:
   check(a.rect.size.x*scale.x>=126.-.01 and a.rect.size.y*scale.y>=126.-.01,"aim callout retains48dp target at420dpi")
   check(Rect2(Vector2.ZERO,g.ocean.size).encloses(a.rect) and a.rect.position.y>=g.ocean.instrument_top,"aim target stays inside chart below zoom/header")
   for row in g.ocean.contact_readout_rects():check(not row.intersects(a.rect),"aim callout preserves urgent and historical instrument rows")
   check(not a.rect.has_point(g.ocean.screen_position(g.sim.mission.objectives[2].pos)),"aim callout preserves briefed objective marker")
   for target in g.sim.knockdown_targets():check(not a.rect.intersects(Rect2(g.ocean.screen_position(target.pos)-Vector2.ONE*70*g.ocean.world_scale,Vector2.ONE*140*g.ocean.world_scale)),"aim callout preserves observed Siren silhouette")
  var glyph_size=ThemeDB.fallback_font.get_string_size("S1",HORIZONTAL_ALIGNMENT_LEFT,-1,g.ocean.feedback_font_size)
  var ambiguous=g.ocean.screen_position(g.sim.contacts[0].pos)+g.ocean.global_position+Vector2(12,-18)+Vector2(glyph_size.x/2,-g.ocean.feedback_font_size/2.)
  await click(ambiguous)
  check(g.sim.tools.knock==2 and g.sim.projectiles.is_empty() and g.knock_armed,"ambiguous original S1 glyph tap never silently fires at S2")
  await setup(g);aims=g.ocean.knock_aim_targets()
  var route=g.sim.units[0].route.duplicate(true)
  await click(aims[0].rect.get_center()+g.ocean.global_position)
  check(g.sim.projectiles.size()==1 and g.sim.projectiles[0].target==0 and g.sim.tools.knock==1,"mouse selects intended S1 rather than overlapping S2 exactly once")
  var prior=g.sim.snapshot()
  await pointer(aims[0].rect.get_center()+g.ocean.global_position,true,false,true);await pointer(aims[0].rect.get_center()+g.ocean.global_position,false,false,true)
  check(g.sim.snapshot()==prior and g.sim.units[0].route==route,"emulated mouse after input cannot double fire or issue hidden route")
  await setup(g);aims=g.ocean.knock_aim_targets();var p=aims[1].rect.get_center()+g.ocean.global_position
  await pointer(p,true,true)
  g.sim.sirens[0].pos=Vector2(712,750);g.sim.sirens[1].pos=Vector2(710,750);g.sim._observe()
  await pointer(p,false,true);await frames()
  check(g.sim.projectiles.size()==1 and g.sim.projectiles[0].target==1 and g.sim.tools.knock==1,"touch release retains intended S2 key while observed bodies move")
  await setup(g);p=g.ocean.knock_aim_targets()[0].rect.get_center()+g.ocean.global_position;await pointer(p,true,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=p+Vector2(40,0);root.push_input(drag,true);await process_frame
  await pointer(p+Vector2(40,0),false,true);await frames()
  check(g.sim.tools.knock==2 and g.sim.projectiles.is_empty() and g.sim.units.all(func(u):return u.route.is_empty()),"drag beginning on callout pans without firing or route")
  for invalid in ["stale","range","pinned","cover"]:
   await setup(g);p=g.ocean.knock_aim_targets()[0].rect.get_center()+g.ocean.global_position;await pointer(p,true,true)
   if invalid=="stale":g.sim.contacts[0].time=-1.
   if invalid=="range":g.sim.sirens[0].pos=Vector2(1500,900)
   if invalid=="pinned":g.sim.sirens[0].stun=8.
   if invalid=="cover":g.sim.mission.depth_geometry[1].rocks.append(Rect2(650,735,20,30));g.sim._build_navigation()
   await pointer(p,false,true);await frames()
   check(g.sim.tools.knock==2 and g.sim.projectiles.is_empty() and g.sim.units.all(func(u):return u.route.is_empty()),"changed "+invalid+" cannot spend or retarget another fresh contact")
  for order in ["knock","select","program"]:
   await setup(g);p=g.ocean.knock_aim_targets()[0].rect.get_center()+g.ocean.global_position;await pointer(p,true,true)
   g._order(order,{"unit":1} if order=="select" else {});await pointer(p,false,true);await frames()
   check(g.sim.tools.knock==2 and g.sim.projectiles.is_empty() and g.sim.units.all(func(u):return u.route.is_empty()),"cancel/"+order+" during aim gesture never becomes fire or route")
  await setup(g);g._order("camera");g._order("knock");await frames()
  var optical_aims=g.ocean.knock_aim_targets()
  check(g.ocean.optical_feed.visible and optical_aims.size()==2 and optical_aims.all(func(a):return not a.rect.intersects(g.ocean.optical_feed.get_rect())),"both aim callouts remain available clear of actual optical inset")
  await setup(g);g.ocean.zoom_at(4.,g.ocean.size/2);g.ocean.pan_chart(Vector2(10000,10000))
  check(g.ocean.knock_aim_targets().is_empty(),"offscreen cached contacts get no callouts")
  g.queue_free();await frames();await create_timer(.5).timeout
 finish()
func finish():print("TORPEDO AIM CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
