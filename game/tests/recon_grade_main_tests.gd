extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://recon-grade-main.save"
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
 root.add_child(game);game.set_process(false)
 # Mechanical local photograph fixture. Quietus remains at extraction while
 # its physically present drone performs the ordinary exposure and recovery.
 game._start_mission(0);game.sim.units[1].pos=game.sim.mission.objectives[0].pos
 game.sim.command("select",{"unit":1});check(game.sim.command("camera"),"real close drone exposure begins")
 game.sim.paused=false
 for n in 250:game.sim.advance(1./60)
 game._process(0.)
 check(game.screen=="debrief" and game.sim.outcome=="won","actual remote photograph completes current operation")
 var text="\n".join(game.panel_box.find_children("*","Label",true,false).map(func(label):return label.text))
 check(text.contains("INTEL PHOTO GRADE A"),"operation debrief displays earned proximity/craft grade")
 var saved=game.store.load_game()
 check(not saved.is_empty() and saved.photo_records["0:0"].photo_quality>.95,"current save preserves actual photo even without gallery plate")
 game.photo_records={};game._load_archive()
 check(game.photo_records["0:0"].photo_quality>.95,"campaign photo grade restores through real Main loader")
 game._new_campaign();check(game.photo_records.is_empty(),"new campaign clears previous photo score")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://recon-grade-main.save"+suffix)
 print("RECON GRADE MAIN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
