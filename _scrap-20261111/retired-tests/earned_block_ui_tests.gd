extends "res://tests/wide_menus_ui_tests.gd"
# WP-119 (critic round 9): a result says what the dive earned, what it cost and which craft it lost and why.
# Campaign (EARNED block = what Economy.settle applied), Naval Career and Expedition run results, on the cover screen.
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const Words=preload("res://src/presentation/runs/run_words.gd")
const Economy=preload("res://src/campaign/economy.gd")
const EconPanel=preload("res://src/presentation/economy_panel.gd")
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
const Names=preload("res://src/names.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const RunArch=preload("res://src/campaign/runs/run_archive.gd")
const RunSt=preload("res://src/campaign/runs/run_state.gd")
func labels_text(node)->String:
 var out:PackedStringArray=[]
 for label in node.find_children("*","Label",true,false):out.append(label.text)
 return "\n".join(out)
func words(cost:Dictionary)->String:
 return Economy.fmt(cost).to_lower().replace(" + ",", ").replace("free","nothing")
# Drone A is shot by Siren 0 (or runs flat when the dive has no Siren): the dive's own loss record, as ThreatRead keeps it.
func lose_drone_a(sim)->void:
 sim.units[1].alive=true;sim.units[1].erase("aboard") # a drone in the water (a stowed one is not alive and is never lost)
 ThreatRead.observe(sim)
 sim.units[1].alive=false
 sim.events=[{"type":"loss","pos":sim.units[1].pos,"siren":0 if not sim.sirens.is_empty() else -1}]
 sim.elapsed+=1.
 ThreatRead.observe(sim)
func words_case()->void:
 # The lines are the words table's, and a lost craft names its cause.
 var row={"name":"DRONE A","bearing":97.,"siren":0,"label":"S1 PATROL","battery":false}
 check(Words.lost_lines([row])==["Lost: Drone A, to a Siren beam from 097° (S1 PATROL)."],"a beam loss names the craft, the bearing and the Siren: "+str(Words.lost_lines([row])))
 row.bearing=-1.;row.battery=true;row.label=""
 check(Words.lost_lines([row])==["Lost: Drone A, its battery ran flat."],"a flat battery is named")
 var before={"emp":3,"decoy":2,"recon":1,"knock":1,"sonobuoy":0,"silt_screen":0,"hull_patch":0,"relay_buoy":0}
 var line:Array=Words.dive_ledger(before,before,before,"",-1.,["Lost: Drone A."])
 check(line[1].begins_with("Spent:") and line[2]=="Lost: Drone A." and line[3].begins_with("Earned:"),"lost craft sit between Spent and Earned: "+str(line))
 check(Words.ABANDONED_LINE.contains("END DIVE · LOSE RUN"),"the chosen end is stated plainly")
func campaign_case()->void:
 var shape=Vector2i(2520,1080);root.size=shape;await settle()
 var path="user://earned-block.save"
 var game=await make_game(path)
 game.size=Vector2(game.get_viewport_rect().size);game._layout();await settle()
 check(not Economy.preset(game.economy).replenish,"the test runs on a preset that does not refill")
 # A dive launched through the economy records what the launch cost; a bare launch is free.
 game.mission_index=0;game.fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").default_loadout()
 EconPanel.begin(game,0);await settle()
 check(game.get_meta(EconPanel.META_PAID,null) is Dictionary and game.get_meta(EconPanel.META_PAID).is_empty(),"a bare launch records a free launch")
 lose_drone_a(game.sim)
 var stock:Dictionary=game.economy.stock.duplicate();var cond=game.economy.cond.duplicate()
 game.sim.hull=0.;game.sim.outcome="lost";game.sim.message="Hull lost."
 game._debrief();await settle();await settle()
 var text:String=labels_text(game.panel_box)
 var gained:Dictionary={}
 for key in stock:gained[key]=int(game.economy.stock[key])-int(stock[key])
 var shown:Dictionary={}
 for key in gained:
  if gained[key]>0:shown[key]=gained[key]
 check(text.contains(Words.CAMPAIGN_TITLE),"the Campaign result has the earned block")
 check(text.contains(Words.EARNED_LINE%words(shown)),"Earned is exactly what the economy credited: "+words(shown)+" in\n"+text)
 check(not shown.is_empty() or text.contains("Earned: nothing."),"a dive that credits nothing says so")
 check(text.contains("Spent: nothing (the launch was free)."),"a free launch says so")
 check(text.contains(Words.CAMPAIGN_BALANCE%words(game.economy.stock)),"the balance is the one the economy now holds: "+words(game.economy.stock))
 check(text.contains("Lost: Drone A"),"a lost drone is listed")
 if not game.sim.sirens.is_empty():check(text.contains("Lost: Drone A, to a Siren beam from") and text.contains("Siren beam from 0") and text.contains("SIREN)") or text.contains("(S1 "),"the lost drone's cause is the Siren beam it knew: "+text)
 check(int(game.economy.cond[Names.CRAFT_DRONE_A])<100 and text.contains("recorded at %d%%"%int(game.economy.cond[Names.CRAFT_DRONE_A])),"what replaces the drone is its recorded condition")
 check(int(cond[Names.CRAFT_DRONE_A])==100,"the drone started whole")
 # A paid launch is stated from the charge, not recomputed.
 game.set_meta(EconPanel.META_PAID,{"cells":2,"scrap":1})
 check(EconPanel.dive_block(game).has(Words.CAMPAIGN_SPENT%"1 scrap, 2 cells"),"the launch cost is read from what was charged: "+str(EconPanel.dive_block(game)))
 game.set_meta(EconPanel.META_PAID,{})
 # The block sits before the photograph and the dive-time line.
 var order:Array=game.panel_box.find_children("*","Label",true,false).map(func(l):return l.text)
 var at_block:int=order.find(Words.CAMPAIGN_TITLE);var at_stats:int=-1
 for i in order.size():
  if order[i].begins_with("Dive time"):at_stats=i
 check(at_block>=0 and at_stats>=0 and at_block>at_stats and at_block-at_stats<=2,"a lost dive's earned block follows the dive-time line directly, before the damage record")
 await finish(game,path)
func career_case()->void:
 var path="user://earned-block-career.save"
 var game=await make_game(path)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game,true)
 check(CareerArchive.persist(game,CareerState.new_career()),"a career is saved")
 CareerFront.start(front);await settle()
 var career=game.get_node_or_null("CareerSession")
 if career==null:check(false,"the contract board opens");await finish(game,path);return
 career._select_contract("brannock_watch");await settle();career._begin();await settle()
 check(career.active_started,"the contract dive launches")
 if career.active_started:
  lose_drone_a(career.sim)
  career.sim.hull=0.;career.sim.outcome="lost"
  career._debrief();await settle();await settle()
  var card:String=labels_text(career.panel_box)
  check(card.contains("Lost: Drone A"),"the Career result lists the lost drone: "+card)
  if not career.sim.sirens.is_empty():check(card.contains("to a Siren beam from"),"and its cause")
  check(card.contains("Earned:") and card.contains("Used:"),"the Career result still states earned and used")
 await finish(game,path)
func expedition_case()->void:
 var path="user://earned-block-run.save"
 var game=await make_game(path)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game,true)
 check(RunArch.persist(game,RunSt.new_run(12345)),"a seeded run is saved")
 Modes.start(front);await settle()
 var session=game.get_node_or_null("ExpeditionSession")
 if session==null:check(false,"the expedition opens");await finish(game,path);return
 if session.RunOffers.pending(session.run_state):session._pick_offer("refit");await settle()
 session._begin();await settle()
 lose_drone_a(session.sim)
 # The player ends the dive: the result says so, lists the lost drone with its cause, and puts both before the set-up lines.
 session._debrief(true);await settle();await settle()
 var text:String=labels_text(session.panel_box)
 check(text.contains(Words.ABANDONED_LINE),"an ended dive says the player ended it: "+text)
 check(text.contains("Lost: Drone A"),"the lost drone is listed")
 if not session.sim.sirens.is_empty():check(text.contains("Lost: Drone A, to a Siren beam from"),"with its cause")
 var order:Array=session.panel_box.find_children("*","Label",true,false).map(func(l):return l.text)
 var lost_at:int=-1;var best_at:int=-1;var kit_at:int=-1
 for i in order.size():
  if order[i].begins_with("Lost: Drone A"):lost_at=i
  if order[i].begins_with("Best photo in each operation"):best_at=i
  if order[i].begins_with("Starting kit"):kit_at=i
 check(lost_at>=0 and best_at>lost_at and kit_at>best_at,"order: lost craft, best photo of each operation, then the run's set-up lines (%d, %d, %d)"%[lost_at,best_at,kit_at])
 await finish(game,path)
func run():
 words_case()
 await campaign_case()
 await career_case()
 await expedition_case()
 print("EARNED BLOCK UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
