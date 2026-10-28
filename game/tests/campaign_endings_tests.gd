extends SceneTree
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(s,seconds:float):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60)
func _initialize():call_deferred("run")
func run():
 for thread in ["deep","shelf"]:
  for route in ["concealed","overt"]:
   var id=12 if route=="concealed" else 13
   var progress={"version":2,"route":thread,"routes":[thread],"facts":{thread:"Recovered branch account","confluence_route":route},"completed":[6,7 if thread=="deep" else 8,9 if thread=="deep" else 10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
   check(Campaign.valid(progress),"rough recovered graph context is valid")
   check(id in Campaign.available([0,1,2,3,4,5],progress),"each planned final operation is reachable")
   var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://pass0-ending-%s-%s.save"%[thread,route]
   for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
   root.add_child(game);game.set_process(false)
   game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition=progress
   game._start_mission(id)
   # Local terminal adapter fixture, not a campaign playthrough. All record,
   # acoustic delivery, capture and recovery transitions use real model code.
   game.sim.sirens=[]
   if id==13:
    game.sim.units[0].pos=Vector2(1840,1080)
    check(game.sim.command("camera"),"ordinary transmission begins")
    step(game.sim,6.2)
   game.sim.units[0].pos=Vector2(1840,800) if id==12 else Vector2(1740,440)
   step(game.sim,.9)
   check(game.sim.command("salvage",{"item":"witness_capsule"}) if id==12 else game.sim.command("camera"),"ordinary physical winch or final reply reception begins")
   step(game.sim,4.2)
   if id==13:
    game.sim.units[0].pos=Vector2(1840,380);game.sim.units[0].vel=Vector2.ZERO
    check(game.sim.command("warning_gate") and game.sim.command("warning_depart",{"course":"sheltered"}),"actual recipient release precedes earned ending")
   if id==12:preload("res://tests/concealed_fixture.gd").solve(game.sim)
   game.sim.units[0].pos=game.sim.mission.extraction;game.sim.units[0].vel=Vector2.ZERO
   if id==12:check(game.sim.command("witness_land"),"actual occupied capsule is explicitly landed before final recovery")
   step(game.sim,55.0 if id==13 else .1)
   check(game.sim.outcome=="won","final operation reaches its real extraction transition")
   game._process(0.)
   var expected={"deepconcealed":"silent_exodus","deepovert":"beacon_pact","shelfconcealed":"hidden_harbour","shelfovert":"surface_reckoning"}[thread+route]
   check(game.screen=="ending" and game.expedition.get("ending","")==expected,"each branch retains its provisional family and shows this recovery")
   var labels="\n".join(game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text))
   check(labels.contains("PROVISIONAL FORK / "+Endings.resolve(game.expedition).title) and Endings.campaign_resolve(game.expedition).is_empty(),"recovery outcome is visibly provisional and final resolver stays closed")
   game._show_campaign()
   labels="\n".join(game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text))
   check(labels.contains(Endings.course_line(game.expedition)) and Endings.campaign_resolve(game.expedition).is_empty(),"Operations shows the distinct provisional course and final resolver stays closed")
   var saved=game.store.load_game()
   check(not saved.is_empty() and saved.expedition.ending==expected and game.store.valid(saved),"current ending save reloads atomically")
   var settings=game.settings.duplicate();game._confirm_new_campaign()
   var reset=game.panel_box.get_children().filter(func(node):return node is Button and node.get_meta("action","")=="confirm_new_campaign")
   check(reset.size()==1,"explicit new-campaign confirmation is reachable")
   if reset.size()==1:reset[0].pressed.emit();await process_frame
   check(game.completed.is_empty() and game.expedition.is_empty() and game.unlocked==0 and game.settings==settings,"new campaign clears branch commitment and preserves settings")
   check(not game.store.load_game().is_empty(),"fresh campaign is saved through the real store")
   game.queue_free();await process_frame
   for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://pass0-ending-%s-%s.save"%[thread,route]+suffix)
 var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://pass0-first-hardware.save";root.add_child(game);game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5
 game._briefing(6)
 check(game._equipment_entitlements().has("quietus_vector_drive") and game._equipment_entitlements().has("drone_deep_cells"),"tutorial finale unlocks general hardware before first expedition")
 game._choose_equipment("quietus","quietus_vector_drive",6);game._choose_equipment("drone_a","drone_deep_cells",6)
 game._start_mission(6);game._save_archive()
 check(game.sim.mission.launch_equipment.quietus=="quietus_vector_drive" and game.sim.mission.launch_equipment.drone_a=="drone_deep_cells" and not game.store.load_game().is_empty(),"early hardware fits through real callback and persists into posttutorial launch")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://pass0-first-hardware.save"+suffix)
 print("CAMPAIGN ENDINGS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
