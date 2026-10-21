extends RefCounted
# Campaign economy. Three resources come from physically recovered material and
# salvage; they pay for repair, refit, manufacturing and research between
# operations. A bare standard Quietus launch is always free, so no balance can
# soft-lock the campaign. Presets change prices, income and attrition only;
# sensing fairness and unlimited pause are untouched. All functions mutate the
# economy dictionary in place.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const RES=["scrap","cells","alloy"]
const NAMES={"scrap":"SCRAP","cells":"CELLS","alloy":"ALLOY"}
const ORDER=["standard","accessible","survival"]
const PRESETS={
 "standard":{"name":"STANDARD","cost":1.0,"income":1.0,"floor":60,"replenish":false,"note":"Costs persist. Wear and wrecks are recoverable."},
 "accessible":{"name":"ACCESSIBLE","cost":0.5,"income":1.0,"floor":100,"replenish":true,"note":"Supplies refill and craft mend between operations."},
 "survival":{"name":"SURVIVAL","cost":1.5,"income":0.6,"floor":30,"replenish":false,"note":"Heavy attrition. Lean income, dear repairs."}
}
const START={"scrap":6,"cells":6,"alloy":0}
const REFILL={"scrap":6,"cells":6,"alloy":3}
const CAP=99
const ALIEN=["quietus_pressure_sleeve","drone_traction_yoke","quietus_prism","quietus_decoder"]
const TARGETS=["quietus","drone_a","drone_b"]
static func new_state(preset:String="standard")->Dictionary:
 return {"preset":preset,"ironman":false,"stock":START.duplicate(),"spares":{},"cond":{"quietus":100,"drone_a":100,"drone_b":100},"last_fit":Catalog.default_loadout(),"settled":"","report":"No dive yet. Starter supplies aboard."}
static func preset(e:Dictionary)->Dictionary:
 return PRESETS[e.preset]
# ---- costs -----------------------------------------------------------------
static func scaled(cost:Dictionary,e:Dictionary)->Dictionary:
 var result={}
 for key in cost:
  var n=int(ceil(cost[key]*preset(e).cost-0.0001))
  if cost[key]>0 and n<1:n=1
  if n>0:result[key]=n
 return result
static func fmt(cost:Dictionary)->String:
 if cost.is_empty():return "FREE"
 var parts=[]
 for key in RES:
  if cost.get(key,0)>0:parts.append("%d %s"%[cost[key],NAMES[key]])
 return " + ".join(parts)
static func can_pay(e:Dictionary,cost:Dictionary)->bool:
 for key in cost:
  if e.stock.get(key,0)<cost[key]:return false
 return true
static func shortfall(e:Dictionary,cost:Dictionary)->String:
 var need={}
 for key in cost:
  if e.stock.get(key,0)<cost[key]:need[key]=cost[key]-e.stock.get(key,0)
 return fmt(need)
static func pay(e:Dictionary,cost:Dictionary)->bool:
 if not can_pay(e,cost):return false
 for key in cost:e.stock[key]-=cost[key]
 return true
static func balance_text(e:Dictionary)->String:
 return "BALANCE · %s"%" · ".join(RES.map(func(k):return "%s %d"%[NAMES[k],e.stock.get(k,0)]))
# Manufacturing price of one copy of a fitting.
static func item_cost(item:String,e:Dictionary)->Dictionary:
 var cost={"scrap":2+Catalog.ITEMS[item].power}
 if item in ALIEN:cost["alloy"]=1
 return scaled(cost,e)
# Installing an item that was not aboard on the last launch costs power cells.
# Ironman charges every fitted item on every launch, retries included.
static func refit_cost(e:Dictionary,fitted:Dictionary)->Dictionary:
 var cells=0;var scrap=0;var last=e.last_fit
 for key in Catalog.FRAME_KEYS.values():
  if fitted.get(key,"")!=last.get(key,""):
   cells+=2 if key=="hull" else 1;scrap+=1 if key=="hull" else 0
 for slot in Catalog.SLOTS:
  for key in Catalog.MOUNT_KEYS[slot]:
   var item=fitted.get(key,"")
   if item.is_empty():continue
   if e.ironman or item not in Catalog.items_for(last,Catalog.SLOTS.find(slot)):
    cells+=1+(1 if Catalog.ITEMS[item].power>=2 else 0)
 return scaled({"cells":cells,"scrap":scrap},e)
static func charge_launch(e:Dictionary,fitted:Dictionary)->bool:
 if not pay(e,refit_cost(e,fitted)):return false
 e.last_fit=fitted.duplicate(true)
 return true
# ---- repair ----------------------------------------------------------------
static func repair_cost(e:Dictionary,target:String)->Dictionary:
 var missing=100-e.cond.get(target,100)
 if missing<=0:return {}
 if target=="quietus":return scaled({"cells":int(ceil(missing/25.0))},e)
 return scaled({"cells":1,"scrap":1},e)
static func repair(e:Dictionary,target:String)->bool:
 var cost=repair_cost(e,target)
 if cost.is_empty() or not pay(e,cost):return false
 e.cond[target]=100
 return true
# Craft begin an operation in their recorded condition: Quietus hull, drone battery.
static func apply_launch(e:Dictionary,sim)->void:
 sim.hull=float(e.cond.quietus)
 sim.units[1].battery=float(e.cond.drone_a);sim.units[2].battery=float(e.cond.drone_b)
# ---- manufacturing ---------------------------------------------------------
static func lost_items(fleet:Dictionary)->Array:
 var result=[]
 for outcome in fleet.get("outcomes",{}).values():result.append_array(outcome.lost)
 return result
# Manufacture a replacement for a lost fitting; returns the corrected fleet.
static func rebuild(e:Dictionary,fleet:Dictionary,item:String)->Dictionary:
 var result=fleet.duplicate(true)
 if item not in lost_items(result) or not pay(e,item_cost(item,e)):return fleet
 for id in result.outcomes:
  if item in result.outcomes[id].lost:result.outcomes[id].lost.erase(item);result.outcomes[id].recovered.append(item)
 return result
static func build_spare(e:Dictionary,item:String)->bool:
 if e.spares.get(item,0)>=1 or not pay(e,item_cost(item,e)):return false
 e.spares[item]=1
 return true
# A spare copy replaces a fitting newly lost in the dive just recovered.
static func absorb_losses(e:Dictionary,before:Dictionary,after:Dictionary)->Dictionary:
 var result=after.duplicate(true);var used=[]
 for id in result.get("outcomes",{}):
  if before.get("outcomes",{}).has(id):continue
  for item in result.outcomes[id].lost.duplicate():
   if e.spares.get(item,0)>0:
    e.spares[item]-=1;result.outcomes[id].lost.erase(item);result.outcomes[id].recovered.append(item);used.append(item)
 for item in e.spares.keys():
  if e.spares[item]<=0:e.spares.erase(item)
 if not used.is_empty():e.report+="\nSpare copies installed: %s."%", ".join(used.map(func(i):return Catalog.ITEMS[i].name))
 return result
# ---- research --------------------------------------------------------------
static func research_cost(e:Dictionary)->Dictionary:
 return scaled({"alloy":2},e)
# After a dive's campaign recovery, new research that cannot be paid is held:
# the material stays recovered and can be researched deliberately later.
static func after_recover(e:Dictionary,previous:Dictionary,current:Dictionary)->Dictionary:
 if not current.has("research"):return current
 var result=current.duplicate(true);var had=previous.get("research",{}).get("projects",[])
 for item in current.research.projects:
  if item in had:continue
  if pay(e,research_cost(e)):
   e.report+="\nResearch paid: %s."%Catalog.ITEMS[item].name;continue
  for material in Research.RECIPES:
   if Research.RECIPES[material].item==item:result.research.spent.erase(material)
  result.research.projects.erase(item)
  if item not in previous.get("entitlements",[]):result.entitlements.erase(item)
  e.report+="\nResearch held for %s: %s short. Recovered material is safe."%[Catalog.ITEMS[item].name,shortfall(e,research_cost(e))]
 return result
# ---- settlement after a dive -------------------------------------------------
# facts: outcome, hull, alive [bool,bool], first (first recovery), recovered
# (modules brought home), artifact (new alien material), key (once-only guard).
static func settle(e:Dictionary,facts:Dictionary)->void:
 if e.settled==facts.key:return
 e.settled=facts.key
 var gain={"scrap":0,"cells":0,"alloy":0};var won=facts.outcome=="won"
 if won:
  gain.scrap+=3 if facts.first else 1;gain.cells+=2 if facts.first else 1
 else:gain.cells+=1
 gain.scrap+=2*facts.recovered
 if facts.artifact:gain.alloy+=3
 var income={}
 for key in gain:
  var n=int(ceil(gain[key]*preset(e).income-0.0001)) if gain[key]>0 else 0
  income[key]=n;e.stock[key]=mini(CAP,e.stock[key]+n)
 var floor_cond=preset(e).floor
 e.cond.quietus=maxi(floor_cond,mini(e.cond.quietus,roundi(facts.hull)))
 for i in 2:
  var target=TARGETS[i+1]
  if not facts.alive[i]:e.cond[target]=maxi(floor_cond,mini(e.cond[target],50))
 e.report="LAST DIVE · %s\nSALVAGE RECOVERED · %s"%[facts.outcome.to_upper(),fmt({"scrap":income.scrap,"cells":income.cells,"alloy":income.alloy}).replace("FREE","NONE")]
 if preset(e).replenish:refill(e)
static func refill(e:Dictionary)->void:
 for key in RES:e.stock[key]=maxi(e.stock[key],REFILL[key])
 for target in TARGETS:e.cond[target]=100
# ---- presets ---------------------------------------------------------------
static func cycle_preset(e:Dictionary)->bool:
 if e.ironman:return false
 e.preset=ORDER[(ORDER.find(e.preset)+1)%ORDER.size()]
 if preset(e).replenish:refill(e)
 return true
static func set_ironman(e:Dictionary)->void:
 e.ironman=true
static func valid(value)->bool:
 if not value is Dictionary or not value.has_all(["preset","ironman","stock","spares","cond","last_fit","settled","report"]):return false
 if not value.preset is String or value.preset not in ORDER or not value.ironman is bool:return false
 if not value.stock is Dictionary or value.stock.size()!=RES.size():return false
 for key in RES:
  if not value.stock.get(key) is int or value.stock[key]<0 or value.stock[key]>CAP:return false
 if not value.cond is Dictionary or value.cond.size()!=3:return false
 for target in TARGETS:
  if not value.cond.get(target) is int or value.cond[target]<0 or value.cond[target]>100:return false
 if not value.spares is Dictionary or value.spares.size()>Catalog.ITEMS.size():return false
 for item in value.spares:
  if not item is String or not Catalog.ITEMS.has(item) or not value.spares[item] is int or value.spares[item]<1 or value.spares[item]>1:return false
 if not value.settled is String or not value.report is String or value.report.length()>1500:return false
 return Catalog.valid_fitting(value.last_fit)
