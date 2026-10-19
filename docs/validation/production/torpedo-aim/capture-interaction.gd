extends SceneTree
var g
var folder="/workspace/Siren-s-Song-contact-clearance/work/torpedo-aim/raw"
var events=[]
func _initialize():call_deferred("run")
func pointer(p:Vector2,down:bool,touch:bool):
 var e
 if touch:e=InputEventScreenTouch.new();e.index=0
 else:e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.global_position=p
 e.position=p;e.pressed=down;root.push_input(e,true)
 events.append({"down":down,"touch":touch,"point":str(p),"stock_after":g.sim.tools.knock,"projectile_keys_after":g.sim.projectiles.map(func(p):return p.target)})
func run():
 root.size=Vector2i(2520,1080);await process_frame;await process_frame
 g=load("res://scenes/main.tscn").instantiate();g.set_script(preload("res://tests/fit_label_main.gd"));g.fixture_dpi=420.;g.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(g);await process_frame;await process_frame
 g._start_mission(4);g.sim.units[0].pos=Vector2(600,750)
 for i in 2:g.sim.sirens[i].pos=Vector2(710+2*i,750);g.sim.sirens[i].vel=Vector2.ZERO
 g.sim.paused=false
 for i in 24:g.sim.advance(1./60)
 g.sim.paused=true;g.sim._observe();g._toggle_advanced();g._refresh()
 DirAccess.make_dir_recursive_absolute(folder)
 var point=Vector2.ZERO
 for n in 192:
  if n in [24,96]:point=g.order_buttons.knock.get_global_rect().get_center();pointer(point,true,false)
  if n in [25,97]:pointer(point,false,false)
  if n in [60,132]:
   var key=0 if n==60 else 1
   for a in g.ocean.knock_aim_targets():
    if a.key==key:point=a.rect.get_center()+g.ocean.global_position
   pointer(point,true,n==132)
  if n in [61,133]:pointer(point,false,n==133)
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
 assert(g.sim.tools.knock==0 and g.sim.projectiles.size()==2 and g.sim.projectiles[0].target==0 and g.sim.projectiles[1].target==1 and g.sim.units[0].route.is_empty())
 var f=FileAccess.open(folder.path_join("interaction.json"),FileAccess.WRITE);f.store_string(JSON.stringify({"fps":12,"frames":192,"paused_entire_clip":true,"elapsed":g.sim.elapsed,"events":events,"final_stock":g.sim.tools.knock,"final_projectile_keys":g.sim.projectiles.map(func(p):return p.target)},"  "));f.close()
 print("AIM_INTERACTION stock=",g.sim.tools.knock," projectile_keys=",g.sim.projectiles.map(func(p):return p.target)," elapsed=",g.sim.elapsed)
 g.queue_free();await process_frame;await create_timer(.5).timeout;quit()
