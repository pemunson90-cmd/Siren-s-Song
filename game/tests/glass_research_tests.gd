extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
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
 print("GLASS RESEARCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
