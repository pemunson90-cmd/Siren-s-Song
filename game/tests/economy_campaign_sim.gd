extends RefCounted
# Deterministic campaign economy simulator (AI-DESIGNED calibration harness, Pat tunes).
# Walks the real operation graph (OperationCatalog prerequisites, route and fact gates) and
# drives the real Economy functions: launch charge, settle, repair, rebuild, spares, research,
# unlock purchase. It does not fly dives; a profile only decides each dive's outcome, hull wear
# and which fitted modules come home. Assumptions: the starter fittings below are owned, no
# drone chassis is ever fitted (chassis unlocks are alloy sinks only), and evidence for each
# recipe arrives when its source operation completes.
const Economy=preload("res://src/campaign/economy.gd")
const Table=preload("res://src/campaign/economy_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Fleet=preload("res://src/campaign/fleet_inventory.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const OpCatalog=preload("res://src/campaign/operation_catalog.gd")
const FINAL_OP=34
const REFINE_RESERVE=12
const REPAIR_BELOW=75
const ARCS=[1,2,3,4,5]
const HULL_ORDER=["hull:quiet","chassis:scout","hull:fast","chassis:heavy","chassis:endurance"]
# losses: failed dives before the win; wear: hull points lost on the winning dive;
# lose_modules: how many fitted drone modules the winning dive leaves on the seabed.
const PROFILES={
 "careful":{"wear":5},
 "average":{"wear":15},
 "struggling":{"wear":30}
}
static var _artifacts:Dictionary={}
static func artifact_of(id:int)->String:
 if _artifacts.is_empty():
  for op in OpCatalog.registered_ids():
   var m=OpCatalog.make(op,{});var state=m.get("glass_reach",m.get("iron_choir",{}))
   _artifacts[op]=str(state.get("artifact",{}).get("id",""))
 return _artifacts.get(id,"")
static func arc_of(id:int)->int:
 if id<=5:return 1
 if id<=13 or id in [38,39,40]:return 2
 if id<=21 or id==37:return 3
 if id<=29:return 4
 return 5
static func order(deep:bool,concealed:bool)->Array:
 var o=[0,1,2,3,4,5,6]
 o.append_array([7,9] if deep else [8,10])
 o.append(11);o.append(12 if concealed else 13)
 o.append_array([38 if deep else 39,40])
 o.append_array([14,15,37,16,17,20,21,18,19,22,23,26,27,28,24,29,25,30,31,32,33,35,36,34])
 return o
static func losses_before_win(profile:String,n:int)->int:
 if profile=="average":return 1 if n%3==2 else 0
 if profile=="struggling":return 2 if n%3==0 else 1
 return 0
static func lost_modules(profile:String,n:int,items:Array)->Array:
 if items.is_empty():return []
 if profile=="average" and n%2==1:return [items[(n/2)%items.size()]]
 if profile=="struggling":return items.duplicate()
 return []
# ---- loadout ---------------------------------------------------------------------------
static func _place(fit:Dictionary,unit:int,item:String)->bool:
 var slot=Catalog.SLOTS[unit]
 for key in Catalog.MOUNT_KEYS[slot]:
  if fit[key].is_empty():
   fit[key]=item
   if Catalog.valid_fitting(fit):return true
   fit[key]="";return false
 return false
# Components in drop order (last dropped first). frame: hull key value.
static func components(owned:Array,lost:Array,hull:String)->Array:
 var parts=[]
 var drone_a=["drone_survey_array","photo_flash"];var drone_b=["drone_deep_cells","drone_traction_yoke"]
 var quietus=["quietus_baffles","quietus_prism","quietus_decoder","quietus_pressure_sleeve"]
 for item in drone_a:if item in owned and item not in lost:parts.append({"unit":1,"item":item})
 for item in drone_b:if item in owned and item not in lost:parts.append({"unit":2,"item":item})
 for item in quietus:if item in owned and item not in lost:parts.append({"unit":0,"item":item})
 if hull!="standard":parts.append({"unit":-1,"item":hull})
 return parts
static func build_fit(parts:Array)->Dictionary:
 var fit=Catalog.default_loadout()
 for p in parts:
  if p.unit==-1:fit.hull=p.item
 for p in parts:
  if p.unit>=0:_place(fit,p.unit,p.item)
 return fit
static func owned_items(expedition:Dictionary)->Array:
 var owned=["drone_survey_array","photo_flash","drone_deep_cells","quietus_baffles"]
 for item in expedition.get("entitlements",[]):owned.append(item)
 return owned
static func best_hull(e:Dictionary,expedition:Dictionary)->String:
 if Economy.is_unlocked(e,expedition,"hull:quiet"):return "quiet"
 return "standard"
# ---- one run ----------------------------------------------------------------------------
static func run(preset:String,ironman:bool,profile:String,deep:bool,concealed:bool)->Dictionary:
 var plan=PROFILES[profile]
 var e=Economy.new_state(preset,ironman)
 var expedition={"entitlements":[],"facts":{},"completed":[]}
 var fleet={}
 var spare_item="drone_survey_array"
 var r={"preset":preset,"ironman":ironman,"profile":profile,"deep":deep,"concealed":concealed,"reached_final":false,
  "launches":0,"reduced":0,"bare":0,"wins":0,"loss_dives":0,"rebuilt":0,"refined":0,"repairs":0,"blocked":0,"max_alloy":0,"alloy_streak":0,
  "lags":[],"unlocked":[],"researched":[],"arcs":{},"hull_arc":0,"graph_ok":true,"valid":true,"unreachable":0,"spent_research":0}
 var streak=0;var recovered_at={};var played=order(deep,concealed)
 var progress={"completed":[],"route":"deep" if deep else "shelf","facts":{"confluence_route":"concealed" if concealed else "overt"}}
 var n=0
 for index in played.size():
  var id=played[index]
  if not OpCatalog.prerequisites_met(id,progress.completed) or (OpCatalog.definition(id).campaign and not OpCatalog.accessible(id,progress)):
   r.graph_ok=false;r.unreachable+=1;continue
  var attempts=losses_before_win(profile,n)
  var won=false
  for attempt in attempts+1:
   _maintain(e,expedition,fleet,r,recovered_at,n,false)
   var lost=Fleet.lost(fleet)
   var parts=components(owned_items(expedition),lost,best_hull(e,expedition))
   var chosen=parts.duplicate();var fit=build_fit(chosen)
   var wanted=fit
   while not Economy.can_pay(e,Economy.refit_cost(e,fit)) and not chosen.is_empty():
    chosen.pop_back();fit=build_fit(chosen)
    # Drop order is reverse of the list: hull frame first, then quietus extras, drone modules last.
   if fit!=wanted:r.reduced+=1
   if chosen.is_empty() and not parts.is_empty():r.bare+=1
   if not Economy.charge_launch(e,fit):
    r.valid=false;continue
   r.launches+=1
   var win=attempt==attempts
   var before=fleet.duplicate(true)
   var launched=Catalog.items_for(fit,1)+Catalog.items_for(fit,2)
   var hull=0.0;var alive=[false,false]
   var lost_now=[];var recovered_now=launched.duplicate()
   if win:
    hull=float(clampi(e.cond.quietus-plan.wear,0,100));alive=[true,true]
    lost_now=lost_modules(profile,n,launched)
    for item in lost_now:recovered_now.erase(item)
    if not launched.is_empty():
     if not fleet.has("outcomes"):fleet["outcomes"]={}
     fleet.outcomes[id]={"recovered":recovered_now.duplicate(),"lost":lost_now.duplicate()}
   else:
    r.loss_dives+=1
   var art=artifact_of(id)
   var material=art!="" and win and art not in expedition.get("research",{}).get("materials",[])
   if win:fleet=Economy.absorb_losses(e,before,fleet)
   var recov=recovered_now.size()
   Economy.settle(e,{"outcome":"won" if win else "lost","hull":hull,"alive":alive,"first":win,"recovered":recov if win else 0,"artifact":material,"key":"%d|%d"%[id,attempt]})
   if win:
    won=true
    expedition.completed.append(id)
    for key in OpCatalog.definition(id).facts:expedition.facts[key]="received"
    progress.completed.append(id)
    var previous=expedition.duplicate(true)
    if art!="":
     var mission={"recovered":true,"glass_reach":{"retrieved":true,"artifact":{"id":art,"state":"recovered"}}}
     var current=Research.recovered(previous,mission)
     expedition=Economy.after_recover(e,previous,current)
     if art in Research.RECIPES:recovered_at[art]=n+1
   if not Economy.valid(e):r.valid=false
  if not won:continue
  n+=1;r.wins+=1
  _maintain(e,expedition,fleet,r,recovered_at,n,true)
  r.max_alloy=maxi(r.max_alloy,e.stock.alloy)
  streak=streak+1 if e.stock.alloy>10 else 0
  r.alloy_streak=maxi(r.alloy_streak,streak)
  var arc=arc_of(id);var next_arc=arc_of(played[index+1]) if index+1<played.size() else 0
  if next_arc!=arc:r.arcs[arc]=e.stock.duplicate()
  if id==FINAL_OP:r.reached_final=true
  if r.hull_arc==0 and (Economy.is_unlocked(e,expedition,"hull:quiet") or Economy.is_unlocked(e,expedition,"hull:fast")):r.hull_arc=arc
 r.unlocked=e.unlocks.duplicate();r.researched=expedition.get("research",{}).get("projects",[]).duplicate()
 r.final_stock=e.stock.duplicate()
 return r
# Scrap beyond a working reserve refines into the alloy a purchase still lacks.
static func _fund(e:Dictionary,cost:Dictionary,r:Dictionary)->void:
 while not Economy.can_pay(e,cost) and e.stock.scrap>=REFINE_RESERVE+Economy.refine_cost(e).get("scrap",0) and Economy.refine(e):r.refined+=1
# Between-operation spending, in priority order. count_blocked records wants left unmet.
static func _maintain(e:Dictionary,expedition:Dictionary,fleet:Dictionary,r:Dictionary,recovered_at:Dictionary,n:int,count_blocked:bool)->void:
 if e.cond.quietus<=REPAIR_BELOW and Economy.repair(e,"quietus"):r.repairs+=1
 for target in ["drone_a","drone_b"]:
  if Economy.repair(e,target):r.repairs+=1
 for item in Fleet.lost(fleet):
  var rebuilt=Economy.rebuild(e,fleet,item)
  if rebuilt!=fleet:
   fleet.clear();fleet.merge(rebuilt);r.rebuilt+=1
 for material in Research.pending(expedition):
  _fund(e,Economy.research_cost(e),r)
  var researched=Economy.research(e,expedition,material)
  if researched!=expedition:
   expedition.clear();expedition.merge(researched)
   r.lags.append(n-recovered_at.get(material,n));r.spent_research+=1
 for unlock in HULL_ORDER:
  if unlock in e.unlocks or unlock in expedition.get("research",{}).get("projects",[]):continue
  if unlock.begins_with("hull:"):_fund(e,Economy.unlock_cost(e,unlock),r)
  if not Economy.buy_unlock(e,unlock):break
 if e.stock.scrap>=10 and e.spares.is_empty():Economy.build_spare(e,"drone_survey_array")
 if count_blocked:
  if e.cond.quietus<=REPAIR_BELOW or e.cond.drone_a<100 or e.cond.drone_b<100:r.blocked+=1
  r.blocked+=Fleet.lost(fleet).size()
  r.blocked+=Research.pending(expedition).size()
static func line(r:Dictionary)->String:
 var arcs=[]
 for a in ARCS:
  var s=r.arcs.get(a,{})
  arcs.append("A%d %d/%d/%d"%[a,s.get("scrap",0),s.get("cells",0),s.get("alloy",0)])
 return "SIM %s%s %s %s%s | %s | final %s reduced %d bare %d blocked %d lags %s refined %d hull %s maxAlloy %d streak %d unl %d res %d"%[r.preset,"+IRON" if r.ironman else "",r.profile,"deep" if r.deep else "shelf","/conc" if r.concealed else "/overt"," ".join(arcs),str(r.reached_final),r.reduced,r.bare,r.blocked,str(r.lags),r.refined,str(r.hull_arc),r.max_alloy,r.alloy_streak,r.unlocked.size(),r.researched.size()]
