extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var sim=preload("res://src/simulation/simulation.gd").new()
 sim.start(3,"disruption")
 var rows=preload("res://src/presentation/acoustic_feedback.gd").rows(sim.acoustic_feedback())
 check(rows[-1].contains("COLD FRONT") and rows[-1].contains("OPEN RANGE"),"fresh Foundry qualifies own open range with mutual information cost")
 sim.start(2,"disruption")
 var other=preload("res://src/presentation/acoustic_feedback.gd").rows(sim.acoustic_feedback())
 check(other[-1]=="OPEN WATER · basalt bends/weakens sound · enemy reception unknown" and rows.size()==other.size(),"thermal replaces existing qualification without another top-stack row")
 for dimensions in [Vector2i(1280,720),Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions
  var game=load("res://scenes/main.tscn").instantiate()
  if dimensions.x>1280:game.set_script(preload("res://tests/density_main.gd"))
  game.capture_scenario="thermal-contact-clearance";root.add_child(game);game._start_mission(3)
  game.sim.command("ping");game.sim.captures[2]={"target":1,"elapsed":0.0}
  for id in 3:game.sim.contacts[id]={"pos":game.sim.units[0].pos+Vector2(30+id*40,20),"time":0.0,"mode":"LOCKING" if id==2 else "PATROL","lock":2.0 if id==2 else 0.0,"angle":0.0,"target":0 if id==2 else -1,"type":"sentinel"}
  for n in 4:await process_frame
  game._layout();await process_frame
  var boxes=game.ocean.contact_readout_rects()
  check(boxes.size()==3 and game.ocean.contact_entries()[0].urgent,"%s observed beam stays first with three contacts"%dimensions)
  var clear=true
  for box in boxes:clear=clear and Rect2(Vector2.ZERO,game.ocean.size).encloses(box) and not box.intersects(Rect2(game.ocean.optical_feed.position,game.ocean.optical_feed.size))
  check(clear,"%s thermal qualification preserves all three contacts above optical inset"%dimensions)
  game.queue_free();await process_frame
 print("THERMAL UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
