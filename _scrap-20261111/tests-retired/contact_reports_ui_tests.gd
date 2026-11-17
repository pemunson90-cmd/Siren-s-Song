extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var capture="";var snapshot=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture=arg.trim_prefix("--capture-dir=")
  if arg.begins_with("--snapshot="):snapshot=arg.trim_prefix("--snapshot=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="local-report-warning";root.add_child(game)
  game._start_mission(1);game.sim.paused=true
  if not snapshot.is_empty():
   var f=FileAccess.open(snapshot,FileAccess.READ);check(f!=null,"earned snapshot exists")
   if f!=null:
    check(game.sim.restore(f.get_var()),"earned live mission restores for observation-only render");game.mission_index=game.sim.mission.id
  else:
   # Narrow UI fixture: one earned contact, not remote enemy truth.
   game.sim.contacts={0:{"pos":game.sim.units[0].pos+Vector2(150,0),"time":0.0,"mode":"LOCKING","lock":1.0,"angle":0.0,"target":0,"type":"sentinel","report_remaining":1.0}}
  await process_frame;await process_frame;game._layout();await process_frame
  var rows=game.ocean.contact_entries();var boxes=game.ocean.contact_readout_rects()
  check(rows.any(func(r):return r.text.contains("REPORT")),"%s report warning is visible"%dimensions)
  check(rows.size()==boxes.size(),"%s one existing row per earned contact"%dimensions)
  for i in rows.size():
   var text_width=ThemeDB.fallback_font.get_string_size(rows[i].text,HORIZONTAL_ALIGNMENT_LEFT,-1,game.ocean.feedback_font_size).x+16
   check(text_width<=boxes[i].size.x,"%s entire beam/report warning fits existing row"%dimensions)
   check(Rect2(Vector2.ZERO,game.ocean.size).encloses(boxes[i]),"%s warning stays inside chart"%dimensions)
   for button in game.zoom_buttons:check(not boxes[i].intersects(button.get_rect()),"%s warning avoids zoom control"%dimensions)
   if i>0:check(not boxes[i].intersects(boxes[i-1]),"%s warning rows remain separate"%dimensions)
  if not capture.is_empty():
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(capture+"/warning-%dx%d.png"%[dimensions.x,dimensions.y])
  game.queue_free();await process_frame
 print("CONTACT REPORT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
