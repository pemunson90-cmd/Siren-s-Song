extends SceneTree
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Ops=preload("res://src/presentation/expedition_operations.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func text_of(game)->String:
 return "\n".join(game.panel_box.find_children("*","Label",true,false).map(func(label):return label.text))
func _initialize():call_deferred("run")
func run():
 for branch in ["concealed","overt"]:
  # Self-contained recovered-context fixture. This suite positions an own
  # actor to isolate Main adaptation; it does not claim an earned14 journey.
  var id=12 if branch=="concealed" else 13
  var progress={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Fixture recovered carrier","confluence_route":branch,"resolution":"concealed_recovery" if id==12 else "overt_warning"},"completed":[6,7,9,11,id],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
  var profile={"completed":[0,1,2,3,4,5],"unlocked":5,"expedition":progress}
  check(Campaign.valid(progress),"self-contained recovered%s context satisfies campaign schema"%branch)
  var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://blind-passage-%s-fixture.save"%branch
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
  root.add_child(game);game.set_process(false)
  game.completed=profile.completed.duplicate();game.unlocked=profile.unlocked;game.expedition=profile.expedition.duplicate(true);game.fitted_equipment=profile.get("equipment",game.fitted_equipment).duplicate(true)
  var tutorial=game.completed.duplicate();var recovered=game.expedition.completed.duplicate();var history=game.expedition.history.duplicate(true)
  game._show_campaign()
  check(game.panel_box.get_children().any(func(node):return node is Button and node.get_meta("action","")=="expedition14")==Campaign.BLIND_PASSAGE_READY,"ordinary Operations14 visibility follows the reviewed readiness gate")
  if Campaign.BLIND_PASSAGE_READY:
   game._briefing(14)
   check(game.screen=="briefing" and text_of(game).contains("Blind Passage".to_upper()) and text_of(game).contains("HANDOFF"),"enabled candidate ordinary14 selection opens its navigation briefing")
  game._start_mission(14)
  check(game.sim.mission.get("carried_evidence","")==("concealed_recovery" if branch=="concealed" else "overt_warning"),"Main14 launch carries actual%s recovered context"%branch)
  if game.sim.mission.id!=14:
   check(false,"model registry must dispatch14 before Main adapter can execute")
   game.queue_free();await process_frame;continue
  game._clear_menu();Ops.briefing(game,14);var briefing=text_of(game)
  check(briefing.contains("HANDOFF") and briefing.contains("RETURN") and not briefing.contains("carrier reached") and not briefing.contains("precise source mark"),"14 orders explain physical chart/handoff/return without receiver instructions")
  game.screen="mission";game.sim.paused=false;game.sim.advance(.2);game.sim.paused=true
  var earned=game.sim.mission.terrain_chart_note.duplicate(true);var before=game.expedition.duplicate(true);game._archive()
  check(game.expedition==before,"archive getter remains read-only")
  game._save_archive()
  check(game.expedition.get("terrain_notes",{}).get("14",{})==earned,"actual save retains earned chart notes before snapshot packaging")
  check(game.expedition.completed==recovered and game.expedition.history==history,"chart notes do not fabricate completion or history")
  if Campaign.BLIND_PASSAGE_READY:
   var active=game.store.load_game();check(not active.is_empty() and active.active.mission.id==14 and active.expedition.terrain_notes["14"]==earned,"enabled proof candidate active14 passes actual SaveStore")
  game._start_mission(0);game._save_archive()
  var dropped=game.store.load_game()
  check(not dropped.is_empty() and dropped.active.mission.id==0 and dropped.expedition.get("terrain_notes",{}).get("14",{})==earned,"abandoning active14 preserves its earned chart in real replacement save")
  game.expedition=dropped.get("expedition",game.expedition).duplicate(true);game._start_mission(14)
  check(game.sim.mission.launch_context.get("terrain_notes",{}).get("14",{})==earned and game.sim.public_chart().generation>=earned.generation,"retry launch context restores retained region knowledge")
  # Terminal dispatch fixture: actual model handoff and extraction checks run;
  # teleporting own actor isolates application debrief from travel/controller.
  game.sim.sirens=[];game.sim.units[0].pos=game.sim.mission.handoff_pos;game.sim.units[0].vel=Vector2.ZERO;game.sim.paused=false;game.sim.advance(.1)
  check(game.sim.mission.handoff_complete and not game.sim.mission.recovered and 14 not in game.expedition.completed,"far handoff alone grants no recovered campaign completion")
  game.sim.units[0].pos=game.sim.mission.withdrawal_pos;game.sim.units[0].vel=Vector2.ZERO;game.sim.advance(.1)
  check(game.sim.outcome=="won" and game.sim.mission.recovered,"terminal fixture reaches model's physical-return consequence")
  game._process(0.)
  check(game.screen=="debrief" and game.completed==tutorial and game.unlocked==5,"14 frame debrief preserves tutorial IDs and unlocked semantics")
  check(14 in game.expedition.completed and game.expedition.history.any(func(item):return item.mission==14),"14 recovery commits through expedition adapter")
  check(text_of(game).contains("PASSAGE RECOVERED") and not text_of(game).contains("NEXT DIVE"),"14 recovery stays in connected expedition debrief")
  if Campaign.BLIND_PASSAGE_READY:
   var won=game.store.load_game();check(not won.is_empty() and 14 in won.expedition.completed,"enabled proof candidate debrief14 survives disk reload")
  # Lost/abandoned14 retains notes without terminal advancement.
  game._start_mission(0);game.expedition=profile.expedition.duplicate(true);game._start_mission(14);game.sim.outcome="withdrawn";game.sim.message="Fixture incomplete return";game._debrief()
  check(14 not in game.expedition.completed and game.expedition.has("terrain_notes") and text_of(game).contains("INCOMPLETE WITHDRAWAL"),"incomplete14 debrief retains chart without reward")
  game.queue_free();await process_frame
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://blind-passage-%s-fixture.save"%branch+suffix)
 print("BLIND PASSAGE MAIN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
