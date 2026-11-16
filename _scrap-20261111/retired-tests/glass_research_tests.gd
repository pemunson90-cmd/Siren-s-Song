extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func pulse(prism:bool):
 var s=load("res://src/simulation/simulation.gd").new();s.start(14,"endurance",{"fitted":{"quietus":"quietus_prism" if prism else "","drone_a":"","drone_b":""}})
 s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={};s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 s.sirens=s.sirens.slice(0,1);s.sirens[0].pos=Vector2(1000,600);s.units[0].pos=Vector2(400,600);s.units[0].angle=0
 s.command("sonar_mode",{"sector":"forward","power":"low"});s.command("ping")
 return s
func _initialize():
 check(ResourceLoader.exists("res://src/campaign/glass_research.gd"),"physical material research ledger exists")
 if ResourceLoader.exists("res://src/campaign/glass_research.gd"):
  var research=load("res://src/campaign/glass_research.gd")
  var p={"completed":[16,17],"facts":{"glass_record_16":"received atlas","glass_record_17":"received silt ledger"},"entitlements":[]}
  var mission={"recovered":false,"glass_reach":{"retrieved":false,"artifact":{"id":"prism_core","state":"site"}}}
  check(research.recovered(p.duplicate(true),mission)==p,"discovery alone grants no material or entitlement")
  mission.recovered=true;mission.glass_reach.retrieved=true;mission.glass_reach.artifact.state="recovered"
  p.completed.append(20);p=research.recovered(p,mission)
  check(p.research.materials==["prism_core"] and p.research.spent==["prism_core"] and "quietus_prism" in p.entitlements,"real recovered prism and recovered atlas pay one practical project")
  var before=p.duplicate(true);p=research.recovered(p,mission)
  check(p==before,"replay cannot farm recovered material or spend it twice")
  mission.glass_reach.artifact.id="keeper_wafer";p.completed.append(21);p=research.recovered(p,mission)
  check("quietus_decoder" in p.entitlements and p.research.spent.size()==2 and research.valid(p),"second recovered material buys useful optional decoder without fake references")
  var bad=p.duplicate(true);bad.research.spent=[]
  check(not research.valid(bad),"research entitlement without physical material cost rejects")
 var bare=pulse(false);var prism=pulse(true)
 check(bare.sonar.pending.filter(func(packet):return packet.kind=="echo").is_empty() and prism.sonar.pending.any(func(packet):return packet.kind=="echo"),"actual prism fitting earns a600m directional return unavailable to bare low power")
 check(absf((120.-prism.oxygen)-2.*(120.-bare.oxygen))<.001 and prism.noises.back().radius>bare.noises.back().radius,"extra directional range pays double reserve and greater physical acoustic exposure")
 check(prism.valid_snapshot(prism.snapshot()),"prism's longer listening/echo interval is a valid current snapshot")
 print("GLASS RESEARCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
