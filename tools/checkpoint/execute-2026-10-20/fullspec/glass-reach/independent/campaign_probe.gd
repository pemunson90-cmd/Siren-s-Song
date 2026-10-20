extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
func tick(s,seconds):
 s.paused=false
 for i in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func progress(thread="deep",route="concealed"):
 return {"version":2,"route":thread,"routes":[thread],"completed":[6,7 if thread=="deep" else 8,9 if thread=="deep" else 10,11,12 if route=="concealed" else 13,14,15,16,17],"facts":{thread:"received carrier","confluence_route":route,"resolution":"concealed_recovery" if route=="concealed" else "overt_warning","glass_record_14":"received","glass_record_15":"received","glass_record_16":"received atlas","glass_record_17":"received ledger"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
func local_action(id,p,action):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)});s.sirens=[]
 s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,35)
 check(s.command("glass_action",{"action":action}),"staged actual local "+action+" starts")
 tick(s,8.2)
 s.units[0].pos=s.mission.extraction;s.units[0].vel=Vector2.ZERO;tick(s,.1)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"physical work permits real settled recovery "+action)
 return s
func _initialize():
 for thread in ["deep","shelf"]:
  for route in ["concealed","overt"]:
   var p=progress(thread,route);var ending=Endings.resolve(p).id
   check(Campaign.valid(p) and 14 in Campaign.available([0,1,2,3,4,5],p),"staged preserved "+thread+"/"+route+" campaign offers Glass")
   var s=local_action(18,p,"sever");p=Campaign.recover(p,s.mission)
   check(Campaign.valid(p) and p.facts.glass_choice=="sever" and Endings.resolve(p).id==ending,"real18 receipt preserves earlier ending family "+ending)
   s=local_action(18,p,"service");var replay=Campaign.recover(p,s.mission)
   check(replay.facts.glass_choice=="sever" and replay.history==p.history and Endings.resolve(replay).id==ending,"replay cannot rewrite first18 choice or committed ending/history")
   var finale=Sim.new();finale.start(19,"endurance",{"context":Sim.Consequences.context(replay)})
   check(not finale.mission.glass_reach.gate_open and finale.sirens.filter(func(e):return e.type=="relay").is_empty(),"replayed service cannot alter committed sever finale geometry/network")
 var p=progress();var s=Sim.new();s.start(20);s.sirens=[]
 s.units[0].pos=s.mission.objectives[0].pos
 check(s.command("camera"),"optional material account uses normal local reception")
 tick(s,4.2)
 s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,35)
 check(s.command("glass_action",{"action":"recover"}),"optional material physically winched")
 tick(s,4.2)
 s.units[0].pos=s.mission.extraction;s.units[0].vel=Vector2.ZERO
 check(s.command("glass_action",{"action":"withdraw"}),"explicit cargo withdrawal remains available")
 var withdrawn=Campaign.recover(p,s.mission)
 check(20 not in withdrawn.completed and "quietus_prism" not in withdrawn.entitlements and not withdrawn.has("research"),"withdrawal grants no recovered material/research despite physical cargo")
 # Repeat staged approach; permit ordinary tick extraction, then verify consume-once reward and actual saved envelope.
 s=Sim.new();s.start(20);s.sirens=[];s.units[0].pos=s.mission.objectives[0].pos;s.command("camera");tick(s,4.2)
 s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,35);s.command("glass_action",{"action":"recover"});tick(s,4.2)
 s.units[0].pos=s.mission.extraction;s.units[0].vel=Vector2.ZERO;s.units[2].band=2;s.command("select",{"unit":2});tick(s,.1)
 p=Campaign.recover(p,s.mission)
 check(s.outcome=="won" and Campaign.valid(p) and p.research.spent==["prism_core"] and "quietus_prism" in p.entitlements,"real selected-peer extraction pays physical material once")
 check(Campaign.recover(p,s.mission)==p,"replayed recovered result cannot duplicate research material/spend")
 var store=preload("res://src/persistence/save_store.gd").new();store.path="user://independent-glass-campaign.save"
 var envelope={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":s.snapshot()}
 check(store.save(envelope) and store.load_game()==envelope,"real campaign/research plus recovered active payload roundtrip checksummed save")
 print("INDEPENDENT GLASS CAMPAIGN CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
