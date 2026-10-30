extends SceneTree
const Economy=preload("res://src/campaign/economy.gd")
const Options=preload("res://src/campaign/economy_options.gd")
const Table=preload("res://src/campaign/economy_table.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func facts(key="a")->Dictionary:return {"key":key,"outcome":"won","first":true,"hull":40.,"alive":[false,true],"recovered":0,"artifact":false}
func _initialize():call_deferred("run")
func run():
 var base=Economy.new_state();check(Options.state(base).custom.is_empty() and not Options.state(base).custom_run,"advanced OFF by default")
 for key in Table.ADVANCED:
  for limit in ["min","max"]:
   var e=Economy.new_state();var custom={"repair":1.,"income":1.,"start":1.};custom[key]=Table.ADVANCED[key][limit];Options.configure(e,custom)
   check(Economy.valid(e),"bounded setup valid "+key+limit)
   if key=="start":check(e.stock.scrap==roundi(8*custom.start) and e.stock.cells==roundi(10*custom.start) and e.stock.alloy==0,"starting bundle scaled")
   if key=="repair":
    e.cond.quietus=40;check(Economy.repair_cost(e,"quietus").cells==int(ceil(3*custom.repair)),"repair multiplier applied only to repair")
    check(Economy.drone_cost(e)==Economy.drone_cost(base) and Economy.item_cost("drone_deep_cells",e)==Economy.item_cost("drone_deep_cells",base),"manufacturing unchanged")
   if key=="income":
    Economy.settle(e,facts());check(e.stock.scrap==8+int(ceil(3*custom.income)),"income multiplier applied to settlement")
 var custom=Economy.new_state();Options.configure(custom,{"repair":.5,"income":2.,"start":0.})
 check(Options.request(custom,"accessible") and Options.multiplier(custom,"income")==2.,"custom easier switch retains income override")
 var old=Economy.new_state();old.erase("economy_options")
 check(Economy.valid(old) and Options.state(old)==Options.fresh(),"old save defaults without retrospective changes")
 Economy.charge_launch(old,Economy.Catalog.default_loadout());check(Options.state(old).started,"legacy block migrates on launch")
 var e=Economy.new_state("survival");Options.configure(e,{"repair":1.,"income":1.,"start":1.})
 Economy.charge_launch(e,Economy.Catalog.default_loadout())
 check(Options.request(e,"standard") and e.preset=="survival" and e.cond.quietus==100,"request queues without applying")
 check(not Options.request(e,"accessible") and not Options.request(e,"survival"),"one pending change cannot be replaced or worsened")
 var sim=Sim.new();sim.start(0);var data={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","economy":e,"active":sim.snapshot()}
 var store=Store.new();store.path="user://economy_options.save"
 check(store.save(data) and store.load_game().economy==e,"custom pending choice and active dive round trip")
 e=store.load_game().economy
 Economy.settle(e,facts());check(e.preset=="standard" and e.cond.quietus==60 and e.stock.scrap==11,"next unique dock applies before income and condition")
 var once=e.duplicate(true);Economy.settle(e,facts());check(e==once,"duplicate settlement neither switches nor pays twice")
 check(Options.label(e)=="CUSTOM / STANDARD" and Options.state(e).history.size()==1 and Options.state(e).custom.income==1.,"custom record and overrides retained after switch")
 check(Options.request(e,"accessible") and not Options.request(e,"survival"),"second transition only toward easier")
 Economy.settle(e,facts("b"));check(e.preset=="accessible" and e.cond.quietus==100 and Options.choices(e).is_empty(),"accessible terminal preset refills at dock")
 check(str(Ledger.build({}, {},e)).contains("CUSTOM / ACCESSIBLE") and str(Ledger.build({}, {},e)).contains("SURVIVAL / STANDARD at dock"),"ledger displays custom and persisted transitions")
 check(Economy.valid(e),"two-transition final save valid")
 var iron=Economy.new_state("survival",true);check(not Options.request(iron,"standard") and Options.choices(iron).is_empty(),"Ironman cannot queue a switch")
 for mutation in ["repair","income","start","pending","history","started","unknown"]:
  var bad=Economy.new_state();Options.configure(bad,{"repair":1.,"income":1.,"start":1.})
  match mutation:
   "repair":bad.economy_options.custom.repair=NAN
   "income":bad.economy_options.custom.income=2.25
   "start":bad.economy_options.custom.start=.1
   "pending":bad.economy_options.pending="survival"
   "history":bad.economy_options.history=[{"from":"accessible","to":"standard"}]
   "started":bad.economy_options.started=1
   "unknown":bad.economy_options.unknown=0
  check(not Economy.valid(bad),"reject corrupt options "+mutation)
 check(Ledger.build({},{}).all(func(panel):return not panel.rows.is_empty()),"absent economy preserves nonempty ledger fallback")
 await surfaces()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 print("ECONOMY OPTIONS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func frames():
 for n in 6:await process_frame
func button(game,key):
 var found=game.panel_box.find_children("*","Button",true,false).filter(func(b):return b.get_meta("action","")==key)
 return found[0] if not found.is_empty() else null
func tap(game,key):
 var b=button(game,key);check(b!=null,"touch control present "+key)
 if b==null:return
 game.scroll.ensure_control_visible(b);await frames()
 check(b.size.y>=game.ui_touch_height,"touch height "+key)
 await preload("res://tests/touch_navigation_scenarios.gd").press(self,b)
 await frames()
func surfaces():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="economy-110";root.add_child(game);await frames();game.set_process(false)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=shape;game.economy=Economy.new_state();game.active_started=false;game.completed=[];game.unlocked=0;game.expedition={};game.recovered_evidence={};game.photo_records={};game.photo_intel={}
  game._show_campaign();await frames();await tap(game,"eco_advanced")
  check(not Options.state(game.economy).custom.is_empty(),"real touch enables custom "+str(shape))
  await tap(game,"eco_advanced_repair");check(Options.multiplier(game.economy,"repair")==1.25,"real touch adjusts repair")
  game.economy=Economy.new_state();Economy.charge_launch(game.economy,Economy.Catalog.default_loadout());game._show_campaign();await frames()
  check(button(game,"eco_advanced")==null,"setup locked after first launch even with pristine progress")
  await tap(game,"eco_easier_accessible");check(game.economy.preset=="standard" and Options.state(game.economy).pending=="accessible","real campaign menu touch queues next dock")
  game._show_economy();await frames()
  var iron=button(game,"eco_ironman");var before=game.economy.duplicate(true)
  check(iron!=null and iron.disabled and iron.text.contains("QUEUED"),"Supplies explains disabled Ironman while easier preset pending")
  await tap(game,"eco_ironman")
  check(game.economy==before and not game.economy.ironman,"disabled Ironman leaves preset, pending choice and mode unchanged")
 game.queue_free();await frames()
