extends SceneTree
var game
var folder=""
var profile="desktop"
var records=[]
func _initialize():call_deferred("run")
func settled():
 for n in 3:await process_frame
 await RenderingServer.frame_post_draw
func save(name):
 game._refresh();game.ocean.queue_redraw();await settled();root.get_texture().get_image().save_png(folder.path_join(name+".png"))
 var o=game.ocean;var marker=o.selected_heading_marker() if o.has_method("selected_heading_marker") else PackedVector2Array()
 records.append({"name":name,"snapshot_hash":var_to_bytes(game.sim.snapshot()).hex_encode().sha256_text(),"marker":str(marker),"world_scale":o.world_scale,"font_basis":o.feedback_font_size,"camera_zoom":o.chart_camera.zoom,"metrics":game._ui_metrics()})
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg.begins_with("--profile="):profile=arg.trim_prefix("--profile=")
 DirAccess.make_dir_recursive_absolute(folder);game=load("res://scenes/main.tscn").instantiate()
 if profile!="desktop":
  game.set_script(load("res://tests/density_main.gd"))
  if profile=="cover":game.fixture_safe_area=Rect2(136,0,2384,1080)
 game.capture_scenario="bow-heading-cue";root.add_child(game);await settled();game.set_process(false);game._start_mission(4)
 var f=FileAccess.open("/workspace/Siren-s-Song-gauntlet/docs/validation/production/navigation-emergency-experience/clip-initial.bin",FileAccess.READ);assert(game.sim.restore(f.get_var()));f.close()
 game.sim.command("route",{"point":Vector2(820,520)});game.sim.paused=false;game._refresh();game._layout();game.ocean.zoom_at(2.0,game.ocean.size/2);game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(game.sim.units[0].pos))
 var turn_snapshot={}
 for n in 61:
  if n==15:game.sim.command("emergency",{"point":Vector2(420,580)});game.sim.command("emp")
  game.sim.advance(1.0/15)
  if n==30:turn_snapshot=game.sim.snapshot()
  if n in [0,15,30,45,60]:await save("emergency-%03d"%n)
 assert(game.sim.restore(turn_snapshot));game.sim.paused=false;game.ocean.fit_chart();await save("quietus-turn-fit")
 game.ocean.zoom_at(4.0,game.ocean.size/2);game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(game.sim.units[0].pos));await save("quietus-turn-4x")
 game.ocean.pan_chart(Vector2(9999,9999));await save("pan-away-4x")
 # Ordinary owned-drone southward turn exercises the opposite sign and name clearance.
 game._start_mission(0);game.sim.command("select",{"unit":1});game.sim.command("route",{"point":Vector2(140,900)});game.sim.paused=false
 for n in 30:game.sim.advance(0.1)
 game.ocean.fit_chart();await save("drone-south-fit")
 game.ocean.zoom_at(4.0,game.ocean.size/2);game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(game.sim.units[1].pos));await save("drone-south-4x")
 f=FileAccess.open(folder.path_join("views.json"),FileAccess.WRITE);f.store_string(JSON.stringify(records,"  "));f.close()
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
