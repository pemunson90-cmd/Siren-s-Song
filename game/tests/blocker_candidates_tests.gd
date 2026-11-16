extends SceneTree
# WP-174: two blocker candidates from the full-playthrough testers.
# 1. Shelf Return: a Siren in sight must not take the camera slot from the required WATCH ACKNOWLEDGEMENTS (the habitat panel).
# 3. Warning Chain (WP-177): a Siren in sight must not take the camera slot from PLANT CONTROLS (START BACKUP at WEST).
# 2. Wake Crossing: a recovery mouth that is shut because a signal source has not been located names that source.
const Sim=preload("res://src/simulation/simulation.gd")
const Habitat=preload("res://src/simulation/shelf_habitat.gd")
const HudWords=preload("res://src/presentation/hud_words.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func _init():
 shelf()
 wake()
 plant()
 print("BLOCKER CANDIDATES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func shelf()->void:
 var s=Sim.new();s.start(8)
 s.units[1].alive=false;s.units[2].alive=false
 s.units[0].pos=Habitat.ALARM+Vector2(35,25);s.units[0].vel=Vector2.ZERO
 s.sirens[0].pos=Habitat.ALARM+Vector2(150,0)
 advance(s,.5)
 check(s.Photo.siren_candidate(s,0)==0,"setup: the Siren is in clear view of Quietus")
 var c=s.camera_context()
 print("shelf camera: ready=",c.get("ready")," target=",c.get("target")," text=",c.get("text"))
 check(not c.get("ready",false) and int(c.get("target",-1))!=-2,"a Siren in sight does not take the camera slot while the watch record is pending")
 check(str(c.get("text","")).contains("watch acknowledgements"),"the strip still names the watch acknowledgements")
 check(not s.command("camera"),"the camera order starts no Siren study beside the required record")
 var p=s.photo_context()
 print("shelf photo_context: ready=",p.get("ready")," target=",p.get("target")," text=",p.get("text"))
 check(p.get("ready",false) and int(p.get("target",-1))==-2,"the explicit PHOTO frame still reaches the Siren (a deliberate choice)")
 # Once both replies are in, the camera slot is free again for a Siren study.
 s.mission.shelf_habitat.receipts=["west","east"];s.mission.objectives[0].captured=true
 var after=s.camera_context()
 check(after.get("ready",false) and int(after.get("target",-1))==-2,"after the watch account is aboard the Siren study is offered again")
func wake()->void:
 var s=Sim.new();s.start(9)
 var corridor=s.extraction_corridors()[0]
 var why=s.corridor_blocked_reason(corridor)
 print("wake mouth: ",why)
 check(why==HudWords.TEXT.depart_source%["NORTH WATER RECOVERY","RETURN RECEIVER"],"wake: the shut mouth says to locate the return receiver")
 var next=preload("res://src/presentation/next_step.gd").step(s)
 print("wake NEXT before reaching the mouth: ",next.text)
 check(next.text==HudWords.TEXT.next_locate_source%"RETURN RECEIVER","wake: the NEXT line names the receiver, not 'the open job on the chart'")
 s.units[0].pos=corridor.pos+Vector2(0,26);s.units[0].vel=Vector2.ZERO
 var dep=s.departure_context()
 print("wake departure text at 26 m: ",dep.text)
 check(dep.text==why and dep.reason=="locked","wake: departure context at 26 m gives the same reason")
 # Located but not yet heard: the receiver is an open job, so NEXT names that job instead.
 var located=Sim.new();located.start(9)
 located.SignalField._locate(located,located.mission.signal_sources[0],located.mission.signal_sources[0].pos)
 check(located.unlocated_required_source().is_empty(),"wake: a located receiver is no longer named as unlocated")
 var after=preload("res://src/presentation/next_step.gd").step(located)
 print("wake NEXT once located: ",after.text)
 check(after.text!=HudWords.TEXT.next_locate_source%"RETURN RECEIVER" and after.text.begins_with("NEXT"),"wake: once located, NEXT moves on to hearing it")
func plant()->void:
 var s=Sim.new();s.start(10)
 var inlet=s.warning_chain_context().stations[0].pos
 s.units[1].alive=false;s.units[2].alive=false
 s.units[0].pos=inlet+Vector2(30,0);s.units[0].vel=Vector2.ZERO
 s.sirens[0].pos=inlet+Vector2(180,0)
 advance(s,.5)
 check(s.Photo.siren_candidate(s,0)==0,"plant setup: a Siren is in clear view of Quietus at the inlet")
 var c=s.camera_context()
 print("plant camera: ready=",c.get("ready")," target=",c.get("target")," text=",c.get("text"))
 check(int(c.get("target",-1))!=-2,"plant: a Siren in sight does not take the camera slot while the plant is uncommissioned")
 check(s.photo_context().get("ready",false) and int(s.photo_context().get("target",-1))==-2,"plant: the explicit PHOTO frame still reaches the Siren")
 check(s.command("chain_power",{"mode":"backup"}),"plant: START BACKUP works at the inlet with a Siren in view")
