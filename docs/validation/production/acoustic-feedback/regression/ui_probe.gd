extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
var game
func _initialize():call_deferred("run")
func threats(s)->int:
 var total=0
 for c in s.contacts.values():
  if s.elapsed-c.time<0.5 and c.mode in ["LOCKING","BEAM"] and c.target>=0:total+=1
 return total
func run():
 var best={};var max_rows=0;var attempts=0;var camera_best={};var camera_rows=0
 for mission in 6:
  for point in [Vector2(1300,510),Vector2(900,700),Vector2(600,400)]:
   var s=Simulation.new();s.start(mission);s.command("silent");s.command("route",{"point":point});s.paused=false;attempts+=1
   for tick in 450:
    if tick%40==0:s.command("ping")
    s.advance(0.1)
    var count=threats(s)
    if count>max_rows:max_rows=count;best=s.snapshot()
    if count>camera_rows and s.camera_context().ready:
     var copy=Simulation.new();copy.restore(s.snapshot());copy.command("camera")
     if copy.capture_unit>=0:camera_rows=count;camera_best=copy.snapshot()
    if not s.outcome.is_empty():break
 print("SCAN attempts=",attempts," max_observed_fresh_threat_rows=",max_rows," camera_coexisting_rows=",camera_rows)
 if best.is_empty():quit(1);return
 for profile in ["cover","inner"]:
  root.size=Vector2i(2520,1080) if profile=="cover" else Vector2i(2184,1968)
  await process_frame;await process_frame
  game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="acoustic-regression"
  game.fixture_safe_area=Rect2(136,0,root.size.x-136,root.size.y) if profile=="cover" else Rect2(0,0,root.size.x,root.size.y)
  root.add_child(game);await process_frame;await process_frame
  for scenario in ["coexistence","max-threats"]:
   var sample=camera_best if scenario=="coexistence" and camera_rows>0 else best
   game._start_mission(sample.mission.id);game.sim.restore(sample)
   game.sim.command("decoy");game.sim.command("ping")
   game._refresh();game._layout();game.ocean.fit_chart()
   for n in 4:await process_frame
   game.ocean.zoom_at(2.0,game.ocean.screen_position(game.sim.units[0].pos))
   await process_frame;await RenderingServer.frame_post_draw
   var args=OS.get_cmdline_user_args();var folder=args[0]
   root.get_texture().get_image().save_png(folder.path_join(profile+"-"+scenario+".png"))
   var rows=game.ocean.acoustic_rows();var font=game.ocean.feedback_font_size;var top=game.ocean.instrument_top
   print("UI profile=",profile," scenario=",scenario," window=",root.size," root_control=",game.size," chart=",game.ocean.size," font=",font," instrument_top=",top," rows=",rows," threats=",threats(game.sim)," capture=",game.sim.capture_unit," optical_top=",game.ocean.optical_feed.position.y," threat_bottom=",top+rows.size()*(font+5)+12+28+(threats(game.sim)-1)*30+9)
  game.queue_free();await process_frame
 await create_timer(0.5).timeout;quit()
