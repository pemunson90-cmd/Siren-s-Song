extends SceneTree
func _initialize():call_deferred("run")
func click(button):
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=button.get_global_rect().get_center();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
 await process_frame
func run():
 var folder="";var idle=false
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
  if arg=="--idle":idle=true
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="route-program-motion";root.add_child(game)
 for n in 6:await process_frame
 game.set_process(false);game._start_mission(0)
 var s=game.sim;var programmed=s.has_method("route_goals");var initial_sha=var_to_bytes(s.snapshot()).hex_encode().sha256_text()
 if not idle:
  for id in [1,2]:
   assert(s.command("select",{"unit":id}));assert(s.command("route",{"point":Vector2(500,700) if id==1 else Vector2(600,880)}))
  assert(s.command("select",{"unit":0}));assert(s.command("route",{"point":Vector2(260,800)}));assert(s.command("queue"));assert(s.command("route",{"point":Vector2(380,800)}));assert(s.command("waypoint_mode"));assert(s.command("route",{"point":Vector2(540,800)}))
  if programmed:
   for args in [{"index":0,"mode":"cruise"},{"index":1,"mode":"silent","stop":true},{"index":2,"mode":"cruise"}]:assert(s.command("route_edit",args))
  else:assert(s.command("silent"))
 game._refresh();game._layout();game.ocean.zoom_at(2.0,game.ocean.size/2);game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(Vector2(360,800)))
 s.paused=false;var samples=[];var inputs=[];var transitions=[];var previous_silent=s.units[0].silent;var previous_count=s.units[0].route.size()
 DirAccess.make_dir_recursive_absolute(folder)
 for n in 240:
  if not idle and n in [15,75,90,120]:
   var selected={15:1,75:0,90:2,120:0}[n];await click(game.unit_buttons[selected]);inputs.append({"frame":n,"order":"select","unit":selected})
   if not programmed and n in [75,120]:await click(game.order_buttons.silent);inputs.append({"frame":n,"order":"silent"})
  s.advance(1.0/15);game._refresh();game.ocean.queue_redraw()
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
  var u=s.units[0]
  if u.silent!=previous_silent or u.route.size()!=previous_count:
   transitions.append({"frame":n,"time":s.elapsed,"silent":u.silent,"speed":u.vel.length(),"pos":u.pos,"remaining_nodes":u.route.size()});previous_silent=u.silent;previous_count=u.route.size()
  samples.append({"frame":n,"time":s.elapsed,"pos":u.pos,"velocity":u.vel,"silent":u.silent,"hull":s.hull,"oxygen":s.oxygen,"selected":s.selected,"route_nodes":u.route.size(),"contacts":s.contacts.duplicate(true),"outcome":s.outcome})
 var f=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);f.store_string(JSON.stringify({"initial_snapshot_sha256":initial_sha,"setup":"unmodified fresh Shelf Signal; ordinary route/queue/STOP commands; both drones independently moving; programmed incoming modes before frame0 or baseline initial manual CRUISE. Idle gets no route/mode commands.","programmed":programmed,"idle":idle,"camera":"normal2x zoom, fixed own-route center before frame0; no camera changes in clip","inputs":inputs,"transitions":transitions,"samples":samples,"final_hull":s.hull,"final_outcome":s.outcome},"  "));f.close()
 game.queue_free();await process_frame;await create_timer(0.2).timeout;quit()
