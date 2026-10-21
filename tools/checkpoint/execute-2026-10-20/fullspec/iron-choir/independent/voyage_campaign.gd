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
func tick(s,t):
 s.paused=false
 for i in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func initial():return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19],"facts":{"deep":"received","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func recover(s):
 s.units[0].pos=s.mission.extraction;s.units[0].vel=Vector2.ZERO;tick(s,.1)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"actual completed physical job permits valid recovery op="+str(s.mission.id))
func _initialize():
 var p=initial();var ending=Endings.resolve(p).id
 for op in range(22,30):
  var s=Sim.new();s.start(op);s.sirens=[];tick(s,.1)
  check(not s.all_records() and s.outcome.is_empty(),"empty receivers cannot auto-complete unfinished physical op="+str(op))
 var s=Sim.new();s.start(22);s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
 s.units[0].pos=Vector2(750,2080)
 check(s.command("choir_action",{"action":"west"}),"freight voyage starts only after local deliberate command")
 tick(s,1.);s.Choir.observe(s);var last=s.choir_context().load.duplicate(true);var origin=s.mission.iron_choir.load.pos
 var restored=Sim.new();check(restored.restore(s.snapshot()),"actual in-flight freight partial snapshot restores")
 s.units[0].pos=Vector2(300,2350);restored.units[0].pos=s.units[0].pos
 tick(s,230.);tick(restored,230.)
 var load=s.mission.iron_choir.load
 print("FREIGHT RESULT pos=",load.pos," state=",load.state," hull=",load.hull," receipt=",s.mission.iron_choir.receipt)
 check(load.pos.distance_to(origin)>1000 and load.state=="arrived" and load.hull==100,"physical freight reaches real destination through authored water")
 check(restored.mission.iron_choir.load.pos==load.pos and restored.mission.iron_choir.load.state==load.state,"restored freight continues to identical actual arrival")
 check(not s.mission.iron_choir.receipt and s.outcome.is_empty() and s.choir_context().load.pos==last.pos,"hidden arrival grants no remote receipt or live presentation tracking")
 s.units[0].pos=load.pos+Vector2(0,50);tick(s,.1)
 check(s.mission.iron_choir.receipt and s.all_records(),"local physical arrival observation earns actual dock receipt")
 recover(s);p=Campaign.recover(p,s.mission)
 check(22 in p.completed and Campaign.valid(p) and Endings.resolve(p).id==ending,"new recovered freight advances valid history without changing old ending")
 s=Sim.new();s.start(23);s.sirens=[]
 for site in s.mission.iron_choir.sites:
  s.units[0].pos=site.pos+Vector2(0,35);s.units[0].vel=Vector2.ZERO;s.command("select",{"unit":0})
  check(s.command("choir_action",{"action":site.id}),"actual equalizer starts "+site.id)
  tick(s,.8);s.units[2].band=2;s.command("select",{"unit":2});var copy=Sim.new()
  check(copy.restore(s.snapshot()),"unselected actual equalizer partial save restores "+site.id)
  tick(s,7.4);tick(copy,7.4)
  check(site.done and copy.mission.iron_choir.sites.any(func(w):return w.id==site.id and w.done),"worker-local shutter opens after selection/restore "+site.id)
 recover(s);p=Campaign.recover(p,s.mission)
 check(23 in p.completed and Campaign.valid(p),"empty-objective industrial completion requires all real locks and current recovery")
 # Source-known stage only local salvage access; real depth/winch/recovery funds sleeve.
 s=Sim.new();s.start(26);s.sirens=[];s.units[0].pos=Vector2(1450,465)
 check(s.command("depth",{"band":2}),"spindle carrier physically descends")
 tick(s,4.2);check(s.command("choir_action",{"action":"recover"}),"actual deep material winch starts")
 tick(s,4.2);var a=s.mission.iron_choir.artifact
 check(a.state=="cargo" and a.carrier==0 and a.band==2 and Sim.valid_snapshot(s.snapshot()),"actual deep material remains physical cargo with valid save")
 check(s.command("depth",{"band":1}),"material carrier physically returns to recovery band")
 tick(s,4.2);recover(s);p=Campaign.recover(p,s.mission)
 check(p.research.spent==["pressure_spindle"] and "quietus_pressure_sleeve" in p.entitlements and Campaign.valid(p),"actual returned material and dock proof fund one pressure sleeve")
 check(Campaign.recover(p,s.mission)==p,"replayed receipt cannot duplicate material or research spend")
 var store=preload("res://src/persistence/save_store.gd").new();store.path="user://independent-iron.save"
 var envelope={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":p,"active":s.snapshot()}
 check(store.save(envelope) and store.load_game()==envelope,"physical campaign/research/current recovered payload roundtrips checksummed save")
 print("INDEPENDENT IRON VOYAGE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
