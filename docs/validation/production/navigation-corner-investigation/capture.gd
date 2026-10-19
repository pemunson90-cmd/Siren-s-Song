extends SceneTree
const Routes=preload("res://tests/campaign_scenarios.gd")
func _initialize():call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="navigation-turn-baseline";root.add_child(game)
 await process_frame;await process_frame;game.set_process(false);game._start_mission(2)
 var s=game.sim;s.units[1].alive=false;s.units[2].alive=false
 for id in [0,1]:
  assert(Routes.move(s,s.mission.objectives[id].pos+Vector2(0,140)));assert(s.command("camera"))
  for n in 45:s.advance(0.1)
 var initial=s.snapshot();print("TURN_INITIAL time=",s.elapsed," pos=",s.units[0].pos," angle=",s.units[0].angle," tools=",s.tools)
 assert(s.command("route",{"point":s.mission.extraction}));s.paused=false;game._refresh();game._layout()
 game.ocean.zoom_at(2.0,game.ocean.size/2)
 game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(s.units[0].pos))
 var samples=[]
 var folder="/workspace/Siren-s-Song-gauntlet/work/navigation-corner-investigation/frames";DirAccess.make_dir_recursive_absolute(folder)
 for n in 240:
  s.advance(1.0/15);game._observation_diagnostics();game._refresh();game.ocean.queue_redraw()
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
  if n%15==0:samples.append({"frame":n,"time":s.elapsed,"position":str(s.units[0].pos),"velocity":str(s.units[0].vel),"angle":s.units[0].angle,"route":s.units[0].route.duplicate(true),"message":s.message,"hull":s.hull,"outcome":s.outcome})
 var f=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);f.store_string(JSON.stringify({"source":"a178825","setup":"both-drones-lost fixture; ordinary finite-tool forward-order approach with4.5s holds","inputs_during_clip":0,"camera":"programmatic normal2x zoom/pan; not OS input","samples":samples,"final_hull":s.hull,"final_outcome":s.outcome,"final_message":s.message},"  "));f.close()
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
