extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 for n in 3:await process_frame
 var main=load("res://scenes/main.tscn").instantiate();main.capture_scenario="menu";root.add_child(main)
 await process_frame;await process_frame
 var has_progress=main.get_property_list().any(func(p):return p.name=="expedition")
 check(has_progress,"actual Main owns absent-default expedition progress")
 if not has_progress:main.queue_free();await process_frame;quit(1);return
 var store=load("res://src/persistence/save_store.gd").new();var original=store._read("/workspace/Siren-s-Song-gauntlet-archives/earned-campaign-play/six-chapters-recovered-profile/godot/app_userdata/Siren's Song/quietus.save")
 if original.is_empty():
  # Portable UI contract setup is separate from the external earned-profile run.
  main.completed=[0,1,2,3,4,5];main.unlocked=5
 else:
  main.completed=original.completed.duplicate();main.unlocked=original.unlocked;main.recovered_evidence=original.evidence.duplicate(true)
 main._show_campaign();await process_frame
 var buttons=main.panel_box.get_children().filter(func(c):return c is Button and c.get_meta("action","")=="expedition6")
 check(buttons.size()==1 and not buttons[0].disabled,"completed tutorial offers actual playable expedition entry in Operations")
 if not buttons.is_empty():buttons[0].pressed.emit()
 await process_frame
 check(main.screen=="briefing","ordinary entry button opens expedition briefing")
 main._start_mission(6);main._enter_water();await process_frame
 check(main.sim.mission.id==6 and main.sim.observable_sites().is_empty(),"Main enters unlocated-source mission without fabricated objective0")
 check(not main._archive().has("expedition"),"starting an investigation does not grant progression or equipment")
 main.sim.units[0].pos=main.sim.mission.signal_sources[1].pos+Vector2(0,150);main.sim.paused=false;main.sim.advance(0.1)
 var corridor=main.sim.extraction_corridors().filter(func(c):return c.route=="shelf")[0]
 main.sim.units[0].pos=corridor.pos;main.sim.units[0].vel=Vector2.ZERO;main.sim.advance(0.1);main._debrief()
 check(main.completed==[0,1,2,3,4,5] and main.unlocked==5,"expedition success preserves tutorial completion/unlocked semantics")
 check(main.expedition.get("route","")=="shelf" and main.expedition.get("remote_decoy",false),"Main consumes genuine physical exit outcome into optional progression")
 var archived=main._archive();check(store.valid(archived),"Main's extended archive passes production SaveStore validation")
 check(main._evidence_is_text({"optical":"divergence_shelf"}),"new acoustic field notes use text gallery rendering")
 main._show_campaign();await process_frame
 check(main.panel_box.get_children().any(func(c):return c is Button and c.get_meta("action","")=="expedition8"),"selected physical branch offers its real continuation")
 check(not main.panel_box.get_children().any(func(c):return c is Button and c.get_meta("action","")=="expedition7"),"unselected route does not appear as unlocked content")
 main.queue_free();await process_frame;await create_timer(0.5).timeout
 print("EXPEDITION MENU CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
