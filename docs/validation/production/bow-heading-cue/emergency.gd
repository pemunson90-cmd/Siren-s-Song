extends SceneTree
var game
var folder=""
var take="emp"
var commands=[]
func _initialize():call_deferred("run")
func order(name,args={}):
 var accepted=game.sim.command(name,args);commands.append({"frame":-1,"time":game.sim.elapsed,"name":name,"args":str(args),"accepted":accepted});print("EMERGENCY_COMMAND ",commands.back());return accepted
func state():
 var s=game.sim;var observed=[]
 for key in s.contacts:
  var c=s.contacts[key];observed.append({"id":key,"position":str(c.pos),"age":s.elapsed-c.time,"mode":c.mode,"lock":c.lock,"type":c.get("type","patroller")})
 return {"time":s.elapsed,"screen":game.screen,"position":str(s.units[0].pos),"velocity":str(s.units[0].vel),"angle":s.units[0].angle,"route":s.units[0].route.duplicate(true),"hull":s.hull,"oxygen":s.oxygen,"tools":s.tools.duplicate(),"contacts":observed,"message":s.message,"outcome":s.outcome,"paused":s.paused}
func run():
 var fixture=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg.begins_with("--fixture="):fixture=arg.trim_prefix("--fixture=")
  if arg.begins_with("--take="):take=arg.trim_prefix("--take=")
 game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="navigation-emergency-experience";root.add_child(game)
 await process_frame;await process_frame;game.set_process(false);game._start_mission(4)
 var f=FileAccess.open(fixture,FileAccess.READ);var earned=f.get_var();f.close();assert(game.sim.restore(earned))
 var restored_hash=var_to_bytes(game.sim.snapshot()).hex_encode().sha256_text();var route_before=game.sim.units[0].route.duplicate(true)
 assert(order("route",{"point":Vector2(820,520)}));assert(game.sim.units[0].route==route_before)
 game.sim.paused=false;game._refresh();game._layout();game.ocean.zoom_at(2.0,game.ocean.size/2);game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(game.sim.units[0].pos))
 var initial=state();var samples=[];var initial_commands=commands.size();DirAccess.make_dir_recursive_absolute(folder)
 for n in 240:
  if n==15 and take!="idle":
   assert(order("emergency",{"point":Vector2(420,580)}));commands.back().frame=n
   if take=="emp":assert(order("emp"));commands.back().frame=n
  game.sim.advance(1.0/15);game._observation_diagnostics()
  if not game.sim.outcome.is_empty() and game.screen=="mission":game._debrief()
  game._refresh();game.ocean.queue_redraw()
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
  if n%15==0:var view=state();view.frame=n;samples.append(view)
 var report={"take":take,"fps":15,"frames":240,"restored_snapshot_hash":restored_hash,"initial":initial,"commands":commands,"commands_during_clip":commands.size()-initial_commands,"camera":"ordinary2x zoom and initial own-position pan only; fixed throughoutclip; programmatic notOSgesture","samples":samples,"final":state()}
 f=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print("EMERGENCY_FINAL ",report)
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
