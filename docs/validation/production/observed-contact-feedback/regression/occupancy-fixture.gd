extends SceneTree
# Ordinary commands and accelerated simulation; no unit/contact fixture edits.
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var context="camera";var path="";var inset=0.0
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--context="):context=arg.trim_prefix("--context=")
  if arg.begins_with("--image-path="):path=arg.trim_prefix("--image-path=")
  if arg.begins_with("--safe-inset-x="):inset=float(arg.trim_prefix("--safe-inset-x="))
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="acoustic-context"
 if inset>0:game.fixture_safe_area=Rect2(inset,0,root.size.x-inset,root.size.y)
 root.add_child(game);await process_frame;await process_frame;game._start_mission(0)
 game.sim.command("select",{"unit":1 if context=="camera" else 0})
 if context=="threat":game.sim.command("silent")
 game.sim.command("route",{"point":Vector2(1300,510)});game.sim.paused=false
 for i in 1000:
  if context=="threat" and i%40==0:game.sim.command("ping")
  game.sim.advance(0.1)
  if context=="camera" and game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:break
  if context=="threat" and game.sim.contacts.values().any(func(c):return c.lock>0 and game.sim.elapsed-c.time<0.3):break
  if not game.sim.outcome.is_empty():break
 game.sim.paused=true
 if context=="camera":game.sim.command("camera")
 game.sim.command("decoy");game.sim.command("ping")
 game.sim.contacts={
  0:{"pos":Vector2(900,650),"time":game.sim.elapsed-5,"mode":"INVESTIGATE","lock":0.0,"angle":0.0,"target":-1,"type":"patroller"},
  1:{"pos":Vector2(1000,650),"time":game.sim.elapsed-13,"mode":"RETURN","lock":3.0,"angle":0.0,"target":0,"type":"hunter"},
  2:{"pos":game.sim.units[1].pos+Vector2(-60,0),"time":game.sim.elapsed,"mode":"LOCKING","lock":2.0,"angle":0.0,"target":1,"type":"sentinel"}}
 game._refresh();game._layout();await process_frame;await process_frame
 print("REGRESSION_FIXTURE forced_cached_observations=true optical_visible=",game.ocean.optical_feed.is_visible_in_tree()," entries=",game.ocean.contact_entries()," rects=",game.ocean.contact_readout_rects()," optical=",game.ocean.optical_feed.get_rect())
 assert(game.ocean.optical_feed.is_visible_in_tree())
 assert(game.ocean.contact_entries()[0].urgent)
 for r in game.ocean.contact_readout_rects():assert(not r.intersects(game.ocean.optical_feed.get_rect()))
 if context=="threat":game.ocean.zoom_at(2.0,game.ocean.screen_position(game.sim.units[0].pos))
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 if not path.is_empty():root.get_texture().get_image().save_png(path)
 print("ACOUSTIC_CONTEXT kind=",context," elapsed=",game.sim.elapsed," hull=",game.sim.hull," outcome=",game.sim.outcome," capture=",game.sim.capture_unit," message=",game.sim.message," contacts=",game.sim.contacts)
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
