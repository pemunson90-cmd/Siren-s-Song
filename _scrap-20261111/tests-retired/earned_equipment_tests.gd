extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/equipment/equipment_catalog.gd"
 if not ResourceLoader.exists(path):
  check(false,"earned equipment catalog supplies optional fitting and compatible choices")
 else:
  var kit=load(path)
  var bare={"quietus":"","drone_a":"","drone_b":""}
  check(kit.valid_fitting({}) and kit.valid_fitting(bare),"absent or explicit bare fit needs no entitlement")
  var original={};var selected=kit.choose(original,"quietus","quietus_correlator",["quietus_correlator"])
  check(selected.ok and selected.fitted.quietus=="quietus_correlator" and original.is_empty(),"earned fit returns copy without changing previous or grant state")
  check(not kit.choose({},"quietus","quietus_correlator",[]).ok,"notes without recovered entitlement cannot fit kit")
  check(not kit.choose({},"drone_a","quietus_correlator",["quietus_correlator"]).ok,"Quietus receiver does not fit drone")
  check(not kit.choose({},"quietus","drone_sampler",["drone_sampler"]).ok,"field sampler does not fit Quietus")
  var a=kit.choose({},"drone_a","drone_sampler",["drone_sampler"])
  check(a.ok and not kit.choose(a.fitted,"drone_b","drone_sampler",["drone_sampler"]).ok,"one recovered pod cannot be cloned across drones")
  check(kit.choose(kit.choose(a.fitted,"drone_a","",["drone_sampler"]).fitted,"drone_b","drone_sampler",["drone_sampler"]).ok,"unfit then transfer pod between dives")
  check(not kit.valid_fitting({"quietus":"mystery"}) and not kit.valid_fitting({"enemy":""}),"unknown equipment and slot reject")
  check(not kit.valid_fitting({"quietus":12}) and not kit.valid_fitting([]),"malformed fit rejects")
  var cards=kit.public_catalog(["quietus_correlator"])
  check(cards.size()==1 and cards[0].id=="quietus_correlator" and cards[0].has_all(["name","compatible_slots","benefit","cost"]),"public catalog describes only genuinely available benefit and cost")
  cards[0].name="bad";check(kit.public_catalog(["quietus_correlator"])[0].name!="bad","presentation cannot mutate shared catalog")
  check(kit.items_for({},0).is_empty() and kit.has(selected.fitted,0,"quietus_correlator") and kit.items_for(selected.fitted,1).is_empty(),"legacy absent fit and per-craft lookup stay isolated")
 print("EARNED EQUIPMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
