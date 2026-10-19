extends SceneTree
func _initialize():call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate()
 game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="root-blackwater-layout-fixture"
 game.fixture_safe_area=Rect2(136,0,root.size.x-136,root.size.y)
 root.add_child(game)
 await process_frame
 game.set_process(false)
 game._start_mission(2)
 game.sim.units[0].pos=Vector2(760,330)
 game.sim.units[0].vel=Vector2(80,0)
 game.sim.command("camera")
 game.sim.paused=true
 game._refresh();game._layout()
 for n in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/Siren-s-Song-gauntlet/work/blackwater-settling-layout/cover-settling.png")
 print("ROOT_LAYOUT synthetic_own_pose=true paused=true touchheight=",game.ui_touch_height," feedrect=",game.ocean.optical_feed.get_global_rect()," font=",game.ocean.optical_feed.receiver_font_size)
 game.queue_free();await process_frame;await process_frame;quit()
