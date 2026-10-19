extends SceneTree
var game
func _initialize():call_deferred("run")
func run():
 var folder=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(folder)
 game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="acoustic-foundry-ordinary";root.add_child(game)
 for n in 4:await process_frame
 game._start_mission(3);game.set_process(false)
 var actions=[["silent",{}],["route",{"point":Vector2(1350,800)}],["decoy",{"point":Vector2(900,500)}],["ping",{}],["recon",{}]]
 for a in actions:game.sim.command(a[0],a[1])
 game.sim.paused=false
 FileAccess.open(folder.path_join("commands.json"),FileAccess.WRITE).store_string(JSON.stringify({"fixture":"none: ordinary current mission3 and production commands, no state/knowledge/enemy/outcome edits","actions":actions,"warmup_seconds":8,"clip_seconds":12,"fps":15},"\t"))
 for n in 480:game.sim.advance(1.0/60)
 for n in 180:
  for tick in 4:game.sim.advance(1.0/60)
  if not game.sim.outcome.is_empty() and game.screen=="mission":game._debrief()
  game._refresh();await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
  if n%30==0:print("TRACE ",JSON.stringify({"time":game.sim.elapsed,"hull":game.sim.hull,"sub":game.sim.units[0].pos,"contacts":game.sim.contacts,"sirens":game.sim.sirens}))
 FileAccess.open(folder.path_join("end-state.json"),FileAccess.WRITE).store_string(JSON.stringify({"time":game.sim.elapsed,"hull":game.sim.hull,"outcome":game.sim.outcome,"tools":game.sim.tools,"units":game.sim.units,"contacts":game.sim.contacts,"sirens":game.sim.sirens},"\t"))
 print("END ",game.sim.elapsed," hull=",game.sim.hull," tools=",game.sim.tools," outcome=",game.sim.outcome);game.queue_free();await process_frame;await create_timer(.5).timeout;quit()
