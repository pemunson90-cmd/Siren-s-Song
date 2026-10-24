extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Ocean=preload("res://src/presentation/ocean_view.gd")
const Data=preload("res://src/presentation/landmarks/landmark_data.gd")
var output=""
func _initialize():call_deferred("capture")
func capture():
 root.size=Vector2i(1600,1000)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):output=arg.trim_prefix("--out=")
 DirAccess.make_dir_recursive_absolute(output)
 for item in [[8,Vector2(1350,1580)],[14,Vector2(1580,1080)],[28,Vector2(1050,1210)]]:
  var sim=Sim.new();sim.start(item[0]);sim.paused=false
  var accepted=sim.command("route",{"point":item[1]})
  for step in 4800:
   if not sim.outcome.is_empty() or (sim.units[0].route.is_empty() and sim.units[0].vel.length()<2.):break
   sim.advance(Sim.STEP)
   for contact in sim.contacts.values():
    if sim.elapsed-contact.time<.3 and contact.get("lock",0)>1.2 and sim.tools.emp>0:sim.command("emp");break
  sim.paused=true
  var ocean=Ocean.new();ocean.sim=sim;ocean.size=Vector2(1600,1000);root.add_child(ocean)
  await process_frame;await process_frame
  ocean.zoom_at(2.,Vector2(800,500));ocean.focus_craft()
  var title=Label.new();title.text="M3a visual route inspection / operation %d / actual %.1fs / hull %.1f / route accepted %s"%[item[0],sim.elapsed,sim.hull,accepted];title.position=Vector2(20,18);root.add_child(title)
  for state in [false,true]:
   Data.enabled=state;ocean.queue_redraw()
   await process_frame;await RenderingServer.frame_post_draw
   var path=output+"/op_%02d_%s.png"%[item[0],"after" if state else "before"]
   var img=root.get_texture().get_image();var error=img.save_png(path)
   print("LANDMARK_CAPTURE ",path," error=",error," position=",sim.units[0].pos," emp_remaining=",sim.tools.emp," projected=",preload("res://src/presentation/landmarks/landmark_view.gd").project(sim).size())
  Data.enabled=true;title.queue_free();ocean.queue_free();await process_frame
 quit()
