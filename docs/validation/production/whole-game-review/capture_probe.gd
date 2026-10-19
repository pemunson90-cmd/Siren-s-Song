extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var view="ready"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--review-view="): view=arg.get_slice("=",1)
 var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="critic-no-save"; root.add_child(game)
 game._start_mission(0)
 if view=="operations":
  game.active_started=false; game._show_campaign()
 elif view=="initial":
  pass
 elif view=="ready":
  game.sim.command("select",{"unit":1}); game.sim.command("route",{"point":Vector2(1300,510)}); game.sim.paused=false
  for n in 500:
   game.sim.advance(0.1)
   if game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2: break
  game.sim.paused=true
  print("CRITIC CAMERA_READY elapsed=",game.sim.elapsed," position=",game.sim.units[1].pos," camera_button=",game.order_buttons.camera.text," capture=",game.sim.capture_unit)
  game.ocean.zoom_at(1.8,game.ocean.size/2)
 game._refresh(); game._layout()
