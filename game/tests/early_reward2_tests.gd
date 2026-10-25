extends SceneTree
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Reward=preload("res://src/campaign/early_reward/early_reward.gd")
const Table=preload("res://src/campaign/early_reward/reward_table.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 check(Table.modules()==["quietus_tele_lens","quietus_baffles","low_light_back"],"three grants in order")
 var ops=[]
 for g in Table.GRANTS:ops.append(g.operation)
 check(ops==[1,3,5] and ops.max()+1<7,"grants after player ops 2, 4, 6 (ids 1,3,5), all before player op 7")
 for g in Table.GRANTS:check(Catalog.ITEMS.has(g.module) and not g.explanation.is_empty(),"table entry real: "+g.module)
 var state={}
 for step in range(6):
  var next=Reward.grant(state,step,"won")
  if step in [1,3,5]:check(next!=state and Reward.owned(next).size()==Reward.owned(state).size()+1,"op id %d grants exactly one"%step)
  else:check(next==state,"op id %d grants nothing"%step)
  check(Reward.grant(next,step,"won")==next,"op id %d replay grants once"%step)
  check(Reward.grant(next,step,"lost")==next,"op id %d loss grants nothing"%step)
  state=next
 check(Reward.owned(state)==Table.modules(),"all three owned after ops 1,3,5")
 check(Reward.valid({"completed":[0,1,2,3,4,5],"early_reward":state}),"full list validates")
 check(Reward.valid({"completed":[0,1],"early_reward":Reward.grant({},1,"won")}),"partial list validates")
 check(not Reward.valid({"completed":[0,1],"early_reward":state}),"list cannot claim unfinished ops")
 for bad in [{"granted":true,"modules":[]},{"granted":true,"modules":["unknown"]},{"granted":true,"modules":["quietus_tele_lens","quietus_tele_lens"]},{"granted":true,"modules":"x"},{"granted":false,"modules":["quietus_tele_lens"]},{"granted":true,"modules":["quietus_tele_lens"],"module":"quietus_tele_lens"}]:
  check(not Reward.valid({"completed":[0,1,2,3,4,5],"early_reward":bad}),"malformed list rejected")
 var legacy={"granted":true,"module":"quietus_tele_lens"}
 check(Reward.valid({"completed":[0,1],"early_reward":legacy}) and Reward.owned(legacy)==["quietus_tele_lens"],"existing save shape still valid and kept")
 check(Reward.earned(legacy,[]).has("quietus_tele_lens"),"existing save keeps its lens")
 var upgraded=Reward.grant(legacy,3,"won")
 check(Reward.owned(upgraded)==["quietus_tele_lens","quietus_baffles"],"existing save gains later grants without losing the lens")
 check(Reward.grant(legacy,1,"won")==legacy or Reward.owned(Reward.grant(legacy,1,"won"))==["quietus_tele_lens"],"existing save never re-grants the lens")
 # OPTICS conflict by design.
 var owned=Reward.earned(state,[])
 var a=Catalog.choose(Catalog.default_loadout(),"quietus","quietus_tele_lens",owned)
 check(a.ok,"tele lens fits")
 var b=Catalog.choose(a.fitted,"quietus","low_light_back",owned)
 check(not b.ok or not (Catalog.has(b.fitted,0,"quietus_tele_lens") and Catalog.has(b.fitted,0,"low_light_back")),"tele lens and low-light back never equip together")
 var both=a.fitted.duplicate(true)
 for k in Catalog.MOUNT_KEYS.quietus:
  if both.get(k,"").is_empty():both[k]="low_light_back";break
 check(not Catalog.valid_fitting(both),"hand-built tele plus low-light fit is illegal")
 var c=Catalog.choose(Catalog.default_loadout(),"quietus","quietus_baffles",owned)
 check(c.ok and Catalog.valid_fitting(c.fitted),"baffles fit the standard hull")
 var d=Catalog.choose(c.fitted,"quietus","low_light_back",owned)
 check(d.ok and Catalog.valid_fitting(d.fitted),"baffles plus low-light back is a legal pair")
 check(Catalog.budget(c.fitted,0).endurance==1.,"no extra oxygen cost")
 Table.enabled=false
 check(Reward.grant({},3,"won").is_empty() and Reward.grant({},5,"won").is_empty(),"flag off grants nothing")
 check(Reward.earned(state,[]).size()==3,"flag off keeps saved ownership")
 Table.enabled=true
 print("EARLY REWARD2 CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
