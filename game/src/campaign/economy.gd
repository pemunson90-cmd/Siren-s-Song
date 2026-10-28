extends RefCounted
# Campaign economy. Three resources (scrap, cells, alloy) come from physically recovered
# material and salvage; they pay for repair, refit, manufacturing, research and frame
# unlocks between operations. A bare standard launch is always free, so no balance can
# soft-lock the campaign. Presets change prices, income and attrition only; sensing,
# fairness and unlimited pause are untouched. Functions mutate the economy dictionary.
# Seam: Main.economy (saved as archive "economy"), CampaignFlow briefing/debrief hooks,
# ExpeditionOperations research hold, EconomyPanel. Data lives in economy_table.gd.
# Revert: economy_table.enabled=false. Old archives without the field use new_state().
const Table=preload("res://src/campaign/economy_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Fleet=preload("res://src/campaign/fleet_inventory.gd")
const RES=Table.RES
const PRESETS=Table.PRESETS
const ORDER=Table.ORDER
const TARGETS=Table.TARGETS
static func new_state(preset:String="standard",ironman:bool=false)->Dictionary:
 return {"preset":preset,"ironman":ironman,"stock":Table.START.duplicate(),"spares":{},"unlocks":[],
  "cond":{"quietus":100,"drone_a":100,"drone_b":100},"last_fit":Catalog.default_loadout(),"settled":"",
  "report":"No dive yet. Starter supplies aboard."}
# An archive saved before the economy keeps the frames it already flew with.
static func legacy_state(fit:Dictionary)->Dictionary:
 var e=new_state()
 for unit in 3:
  var frame=Catalog.frame(fit,unit)
  if not frame.get("unlock","").is_empty() and frame.unlock not in e.unlocks:e.unlocks.append(frame.unlock)
 e.last_fit=fit.duplicate(true) if Catalog.valid_fitting(fit) else Catalog.default_loadout()
 return e
static func preset(e:Dictionary)->Dictionary:
 return PRESETS[e.preset]
static func pristine_choice(preset_id:String,ironman:bool)->Dictionary:
 return new_state(preset_id if preset_id in ORDER else "standard",ironman)
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
  if cost.get(key,0)>0:parts.append("%d %s"%[cost[key],Table.NAMES[key]])
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
 return "BALANCE · %s"%" · ".join(RES.map(func(k):return "%s %d"%[Table.NAMES[k],e.stock.get(k,0)]))
# Manufacturing price of one copy of a fitting. Keyed by item id so new fittings price by power.
static func item_cost(item:String,e:Dictionary)->Dictionary:
 if Table.ITEM_PRICE.has(item):return scaled(Table.ITEM_PRICE[item],e)
 var cost={"scrap":Table.ITEM_BASE_SCRAP+int(Catalog.ITEMS.get(item,{}).get("power",1))}
 if item in Table.ALIEN:cost["alloy"]=1
 return scaled(cost,e)
# Installing an item that was not aboard on the last launch costs power cells. Ironman
# charges every fitted item on every launch, retries included.
static func refit_cost(e:Dictionary,fitted:Dictionary)->Dictionary:
 if not Table.enabled:return {}
 # Returning every craft to its bare standard frame is the free fallback even
 # when the previous launch used a paid hull or chassis.
 if Catalog.canonical(fitted)==Catalog.default_loadout():return {}
 var cells=0;var scrap=0;var last=e.last_fit
 for key in Catalog.FRAME_KEYS.values():
  if fitted.get(key,"")!=last.get(key,""):
   cells+=2 if key=="hull" else 1;scrap+=1 if key=="hull" else 0
 for slot in Catalog.SLOTS:
  for key in Catalog.MOUNT_KEYS[slot]:
   var item=fitted.get(key,"")
   if item.is_empty() or not Catalog.ITEMS.has(item):continue
   if e.ironman or item not in Catalog.items_for(last,Catalog.SLOTS.find(slot)):
    cells+=1+(1 if Catalog.ITEMS[item].power>=2 else 0)
 return scaled({"cells":cells,"scrap":scrap},e)
static func charge_launch(e:Dictionary,fitted:Dictionary)->bool:
 if not pay(e,refit_cost(e,fitted)):return false
 e.last_fit=fitted.duplicate(true)
 # A retry can end at the exact same mission/time as its predecessor. Clear
 # only when a fresh launch succeeds; repeated debriefs still settle once.
 e.settled=""
 return true
# ---- repair ----------------------------------------------------------------
static func repair_cost(e:Dictionary,target:String)->Dictionary:
 var missing=100-e.cond.get(target,100)
 if missing<=0:return {}
 if target=="quietus":return scaled({"cells":int(ceil(missing/float(Table.REPAIR_HULL_PER_STEP)))},e)
 return scaled({"cells":1,"scrap":1},e)
static func repair(e:Dictionary,target:String)->bool:
 var cost=repair_cost(e,target)
 if cost.is_empty() or not pay(e,cost):return false
 e.cond[target]=100
 return true
# Craft begin an operation in their recorded condition: Quietus hull, drone battery.
static func apply_launch(e:Dictionary,sim)->void:
 if not Table.enabled:return
 sim.hull=float(e.cond.quietus)
 sim.units[1].battery=float(e.cond.drone_a);sim.units[2].battery=float(e.cond.drone_b)
# ---- manufacturing ---------------------------------------------------------
static func lost_items(fleet:Dictionary)->Array:
 return Fleet.lost(fleet)
# Manufacture a replacement for a lost fitting; returns the corrected fleet.
static func rebuild(e:Dictionary,fleet:Dictionary,item:String)->Dictionary:
 if item not in lost_items(fleet) or not pay(e,item_cost(item,e)):return fleet
 return Fleet.rebuild(fleet,item)
static func spare_allowed(item:String)->bool:
 return Catalog.ITEMS.has(item) and Catalog.ITEMS[item].compatible_slots.any(func(s):return s in ["drone_a","drone_b"])
static func build_spare(e:Dictionary,item:String)->bool:
 if not spare_allowed(item) or e.spares.get(item,0)>=1 or not pay(e,item_cost(item,e)):return false
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
# Scrap refines into alloy so frame unlocks never depend on finding an artifact.
static func refine_cost(e:Dictionary)->Dictionary:
 return scaled({"scrap":Table.REFINE.scrap},e)
static func refine(e:Dictionary)->bool:
 if e.stock.alloy>=Table.CAP or not pay(e,refine_cost(e)):return false
 e.stock.alloy=mini(Table.CAP,e.stock.alloy+Table.REFINE.alloy)
 return true
# ---- research ----------------------------------------------------------------
static func research_cost(e:Dictionary)->Dictionary:
 return scaled(Table.RESEARCH_COST,e)
static func target_name(item:String)->String:
 if Catalog.ITEMS.has(item):return Catalog.ITEMS[item].name
 for unit in 3:
  for id in Catalog.frames(unit):
   if Catalog.frames(unit)[id].get("unlock","")==item:return Catalog.frames(unit)[id].name
 return item
# After a dive's campaign recovery, new research is held as pending: the material stays
# recovered and the player pays alloy to research it from the supplies panel.
static func after_recover(e:Dictionary,previous:Dictionary,current:Dictionary)->Dictionary:
 preload("res://src/campaign/crew/crew.gd").credit(e,previous,current)
 if not Table.enabled or not current.has("research"):return current
 var result=Research.hold(previous,current)
 if result.research.spent.size()<current.research.spent.size():
  e.report+="\nResearch ready. Pay %s in SUPPLIES to research it."%fmt(research_cost(e))
 return result
static func research(e:Dictionary,expedition:Dictionary,material:String)->Dictionary:
 if material not in Research.pending(expedition) or not pay(e,research_cost(e)):return expedition
 return Research.start(expedition,material)
# ---- frame unlocks -----------------------------------------------------------
static func unlock_of(unit:int,id:String)->String:
 return str(Catalog.frames(unit).get(id,{}).get("unlock",""))
static func is_unlocked(e:Dictionary,expedition:Dictionary,unlock:String)->bool:
 if unlock.is_empty() or not Table.enabled:return true
 return unlock in e.unlocks or unlock in expedition.get("research",{}).get("projects",[])
static func frame_locked(e:Dictionary,expedition:Dictionary,unit:int,id:String)->bool:
 return not is_unlocked(e,expedition,unlock_of(unit,id))
static func unlock_cost(e:Dictionary,unlock:String)->Dictionary:
 return scaled(Table.UNLOCK_PRICE.get(unlock,{"alloy":4}),e)
static func buy_unlock(e:Dictionary,unlock:String)->bool:
 if unlock.is_empty() or unlock in e.unlocks or not pay(e,unlock_cost(e,unlock)):return false
 e.unlocks.append(unlock)
 return true
# A locked frame in a loadout reads as the standard frame with that unit's mounts emptied.
static func lock_frames(e:Dictionary,expedition:Dictionary,fit:Dictionary)->Dictionary:
 if not Table.enabled:return fit
 var result=fit.duplicate(true)
 for unit in 3:
  var key=Catalog.FRAME_KEYS[Catalog.SLOTS[unit]]
  if not frame_locked(e,expedition,unit,Catalog.frame_id(result,unit)):continue
  result[key]=Catalog.default_loadout()[key]
  if not Catalog.valid_fitting(result):
   for mount in Catalog.MOUNT_KEYS[Catalog.SLOTS[unit]]:result[mount]=""
 return result
# ---- settlement after a dive -------------------------------------------------
# facts: outcome, hull, alive [bool,bool], first (first recovery), recovered (modules
# brought home), artifact (new alien material), key (once-only guard).
static func settle(e:Dictionary,facts:Dictionary)->void:
 if e.settled==facts.key:return
 e.settled=facts.key
 var gain={"scrap":0,"cells":0,"alloy":0}
 var base=Table.INCOME.lost
 if facts.outcome=="won":base=Table.INCOME.first if facts.first else Table.INCOME.replay
 for key in gain:gain[key]=base[key]
 gain.scrap+=Table.INCOME.module_scrap*facts.recovered
 if facts.artifact:gain.alloy+=Table.INCOME.artifact_alloy
 var income={}
 for key in gain:
  var n=int(ceil(gain[key]*preset(e).income-0.0001)) if gain[key]>0 else 0
  income[key]=n;e.stock[key]=mini(Table.CAP,e.stock[key]+n)
 var floor_cond=preset(e).floor
 e.cond.quietus=maxi(floor_cond,mini(e.cond.quietus,roundi(facts.hull)))
 for i in 2:
  var target=TARGETS[i+1]
  if not facts.alive[i]:e.cond[target]=maxi(floor_cond,mini(e.cond[target],50))
 e.report="LAST DIVE · %s\nSALVAGE RECOVERED · %s"%[facts.outcome.to_upper(),fmt(income).replace("FREE","NONE")]
 if preset(e).replenish:refill(e)
static func refill(e:Dictionary)->void:
 for key in RES:e.stock[key]=maxi(e.stock[key],Table.REFILL[key])
 for target in TARGETS:e.cond[target]=100
# ---- presets ---------------------------------------------------------------
static func cycle_preset(e:Dictionary)->bool:
 if e.ironman:return false
 e.preset=ORDER[(ORDER.find(e.preset)+1)%ORDER.size()]
 if preset(e).replenish:refill(e)
 return true
static func set_ironman(e:Dictionary)->void:
 e.ironman=true
# ---- save validation ---------------------------------------------------------
# Registered in persistence/save_checks.gd; an absent field is new-economy defaults.
static func valid_archive(data:Dictionary)->bool:
 return not data.has("economy") or valid(data.economy)
static func valid(value)->bool:
 if not value is Dictionary or not value.has_all(["preset","ironman","stock","spares","cond","last_fit","settled","report"]):return false
 if value.size()!=(9 if value.has("unlocks") else 8):return false
 if not value.preset is String or value.preset not in ORDER or not value.ironman is bool:return false
 if not value.stock is Dictionary or value.stock.size()!=RES.size():return false
 for key in RES:
  if not value.stock.get(key) is int or value.stock[key]<0 or value.stock[key]>Table.CAP:return false
 if not value.cond is Dictionary or value.cond.size()!=TARGETS.size():return false
 for target in TARGETS:
  if not value.cond.get(target) is int or value.cond[target]<0 or value.cond[target]>100:return false
 if not value.spares is Dictionary or value.spares.size()>Catalog.ITEMS.size():return false
 for item in value.spares:
  if not item is String or not Catalog.ITEMS.has(item) or not value.spares[item] is int or value.spares[item]!=1:return false
 if not value.settled is String or value.settled.length()>60 or not value.report is String or value.report.length()>1500:return false
 if value.has("unlocks"):
  if not value.unlocks is Array or value.unlocks.size()>Table.UNLOCK_PRICE.size():return false
  for unlock in value.unlocks:
   if not unlock is String or not Table.UNLOCK_PRICE.has(unlock) or value.unlocks.count(unlock)!=1:return false
 return Catalog.valid_fitting(value.last_fit)
