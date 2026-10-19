extends SceneTree
var game
var step=0
var idle=false
var camera_attempted=false
var withdrew=false
var output=""
func _initialize():call_deferred("run")
func policy():
 var s=game.sim
 if not idle:
  var selected=s.selected
  for c in s.contacts.values():
   if s.elapsed-c.time<0.3 and c.lock>1 and s.tools.emp>0:
    var target=int(c.get("target",-1))
    if target>=0 and s.units[target].alive:s.command("select",{"unit":target});s.command("emp");s.command("select",{"unit":selected});break
  if step==720:s.command("select",{"unit":2});s.command("route",{"point":Vector2(1110,830)})
  if step>=720 and s.units[2].alive:
   var u=s.units[2]
   if not camera_attempted and u.pos.distance_to(Vector2(1110,830))<20 and u.vel.length()<2:
    s.command("select",{"unit":2});camera_attempted=true;s.command("camera")
   if s.mission.objectives[1].captured and not withdrew:
    s.command("select",{"unit":2});s.command("route",{"point":Vector2(1040,880)});withdrew=true
func tick():
 game.sim.advance(1.0/60);step+=1
 if step%6==0:policy()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
  if arg=="--idle":idle=true
 game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="thermal-paired";root.add_child(game);game.set_process(false)
 game._start_mission(3)
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-qualified.snapshot",FileAccess.READ);var data=f.get_var();f.close();assert(game.sim.restore(data));game.ocean.sim=game.sim
 game.sim.paused=false;game.sim.message="REALTIME · earned furnace staging · cold-front comparison";game._refresh();game._layout()
 for n in 5:await process_frame
 game.ocean.zoom_at(2,game.ocean.size/2)
 game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(Vector2(1000,770)))
 for n in 480:tick()
 for frame in 300:
  game._refresh();game.ocean.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(output+"/frame-%04d.png"%frame)
  if frame%15==0:print("THERMAL_MOVIE ",frame," elapsed=",game.sim.elapsed," selected=",game.sim.selected," hull=",game.sim.hull," emp=",game.sim.tools.emp," alive=",game.sim.units.map(func(u):return u.alive)," contacts=",game.sim.contacts)
  for n in 4:tick()
 print("THERMAL_MOVIE_END elapsed=",game.sim.elapsed," oxygen=",game.sim.oxygen," alive=",game.sim.units.map(func(u):return u.alive)," camera=",camera_attempted," withdrew=",withdrew);quit()
