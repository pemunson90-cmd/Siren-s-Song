extends SceneTree
# Item 143: the recovery manifest only offers END DIVE when it ends the dive, and the Confluence
# arc card and the finale first-recovery screen carry the same stats line as every other dive end.
const Manifest=preload("res://src/presentation/recovery_manifest.gd")
const Card=preload("res://src/presentation/arcs/arc_card.gd")
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const Journey=preload("res://tests/calder_trench_journey_tests.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const LINE="Dive time 02:05  /  Hull 63%  /  Life support 41%"
class ManifestSim:
 extends "res://src/simulation/simulation.gd"
 var mouth_pos=Vector2(300,800)
 var requests=[]
 func extraction_corridors()->Array:return [{"pos":mouth_pos,"name":"HOME BASIN","route":"home","available":true}]
 func departure_context()->Dictionary:
  var here=units[0].pos.distance_to(mouth_pos)<65
  return {"available":here,"pending":false,"confirmation_required":false,"corridor":extraction_corridors()[0],"recovered":[],"left":[],"recovered_drones":[],"text":""}
 func command(order:String,args:Dictionary={})->bool:
  if order in ["depart","route"]:
   requests.append({"order":order,"args":args.duplicate(true)})
   if order=="depart" and args.get("confirm",false):outcome="won"
   return true
  return super.command(order,args)
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func action(game,id:String):
 for b in game.menu.find_children("*","Button",true,false):
  if b.get_meta("action","")==id:return b
 return null
func texts(game)->String:
 var all=[]
 for l in game.menu.find_children("*","Label",true,false):all.append(l.text)
 return "\n".join(all)
func stat_lines(node)->Array:
 var re=RegEx.new();re.compile("Dive time \\d\\d:\\d\\d\\s*/\\s*Hull \\d+%\\s*/\\s*Life support \\d+%")
 return node.find_children("*","Label",true,false).filter(func(l):return l.is_visible_in_tree() and re.search(l.text)!=null).map(func(l):return l.text)
func stage(game,quietus_out:bool):
 var s=game.sim
 PlayerDive.launch_drones(s) # the drones are launched; none is aboard
 for id in 3:
  var u=s.units[id];u.alive=true;u.band=1;u.transition={};u.vel=Vector2.ZERO;u.pos=s.mouth_pos+Vector2(10*id,0)
 s.units[2].pos=s.mouth_pos+Vector2(400,0)
 if quietus_out:s.units[0].pos=s.mouth_pos+Vector2(400,0)
 s.paused=false;s.outcome="";s.requests.clear();game.screen="mission"
func set_stats(s):
 s.elapsed=125.;s.hull=63.;s.oxygen=41.
func manifest_cases():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="module-recovery-ui-fixture"
 root.add_child(game);await settle();game.set_process(false);game.sim=ManifestSim.new();game._start_mission(0);await settle()
 var s=game.sim
 stage(game,true);game._recovery_route();await settle()
 check(game.screen=="recovery_manifest","manifest opens with Quietus away")
 check(action(game,"manifest_hold")!=null,"Quietus away: HOLD is offered")
 var carry=action(game,"manifest_confirm")
 check(carry!=null and "CONTINUE" in carry.text and "HEAD FOR RECOVERY" in carry.text,"Quietus away: a labelled continue button is offered")
 var all_buttons="
".join(game.menu.find_children("*","Button",true,false).map(func(b):return b.text))
 check(not ("END DIVE" in all_buttons) and not ("END DIVE" in texts(game).replace("when the dive ends","")),"Quietus away: no END DIVE wording on any control")
 check("QUIETUS IS 400 m FROM RECOVERY" in texts(game),"Quietus away: the distance reason is shown: "+texts(game))
 action(game,"manifest_hold").pressed.emit();await settle()
 check(game.screen=="mission" and s.requests.is_empty() and s.outcome.is_empty(),"HOLD resumes the dive and sends nothing")
 stage(game,true);game.set_meta("dev_profile",true);game._recovery_route();await settle()
 action(game,"manifest_confirm").pressed.emit();await settle()
 game.set_meta("dev_profile",false)
 check(game.screen=="mission" and s.outcome.is_empty() and s.requests.size()==1 and s.requests[0].order=="route","continue leaves the dive running with the route order issued")
 s.requests.clear()
 stage(game,false);game._recovery_route();await settle()
 check(game.screen=="recovery_manifest" and action(game,"manifest_confirm")!=null,"Quietus at a mouth: CONFIRM END DIVE is offered")
 check(not ("FROM RECOVERY" in texts(game).replace("400m TO RECOVERY","")),"Quietus at a mouth: no distance reason")
 action(game,"manifest_confirm").pressed.emit();await settle()
 check(s.requests.size()==1 and s.requests[0].order=="depart" and s.outcome=="won","at a mouth CONFIRM ends the dive")
 game.queue_free();await settle()
func arc_case():
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/fit_label_main.gd"));game.fixture_dpi=420.;game.capture_scenario="dive-end-polish-ui"
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5]
 game._show_campaign();game.screen="debrief";game.sim.start(12);game.mission_index=12;game.sim.mission.recovered=true;game.sim.outcome="won";set_stats(game.sim)
 Card.recovered(game,true);await settle()
 var card=game.get_node_or_null("ArcCard")
 check(card!=null,"Confluence recovery shows the arc card")
 if card!=null:
  var found=stat_lines(card)
  check(found.size()==1,"Confluence card: exactly one stats line (found %d)"%found.size())
  if found.size()==1:check(found[0]==LINE,"Confluence card carries the sim values: "+found[0])
  check(Flow.stats_line(game.sim)==LINE,"stats line helper matches the expected text")
 game.queue_free();await settle()
func archive_fixture()->Dictionary:
 var archive={}
 for id in [30,31]:
  for index in 2:
   var s=preload("res://src/simulation/simulation.gd").new();s.start(id)
   var o=s.mission.objectives[index]
   s.units[0].band=o.band;s.units[0].pos=o.pos+Vector2(-120,0);s.units[0].angle=0.
   s.command("frame",{"mode":"tight","focus":o.optical})
   Photo.begin(s,0,index)
   for tick in 300:Photo.tick(s,0,o,1./60.);s.elapsed+=1./60.
   var shot=Photo.finish(s,0,o).shot
   archive[o.optical]={"optical":o.optical,"name":o.name,"caption":o.evidence,"shots":[shot]}
 return archive
func expedition_fixture()->Dictionary:
 var completed=[6,7,9,11,12]
 for id in range(14,34):completed.append(id)
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed","glass_choice":"salvage","choir_choice":"bypass","choir_people":"landed","choir_plant":"reconnect"},"completed":completed,"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func finale_case():
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 game.store.path="user://dive-end-polish.save"
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition=expedition_fixture();game.recovered_evidence=archive_fixture();game.active_started=false
 game._show_campaign();game.capture_scenario=""
 # The scripted finale route crosses authored water the player rules leave uncharted; it is not a discovery test: known-charts developer switch.
 var charts_before=PlayerDive.known_water(true)
 game._start_mission(34)
 game.sim.mission["dev"]=true
 var won=Journey.run_core(game.sim,34)
 game.sim.mission.erase("dev")
 PlayerDive.known_water(charts_before)
 check(won and game.sim.outcome=="won","fixture recovers operation 34")
 set_stats(game.sim)
 game._debrief();await settle()
 if game.get_node_or_null("ArcCard")!=null:
  game.get_node("ArcCard").dismiss();await settle()
 check(game.screen=="photo_ending","finale first recovery opens the photo wall (screen %s)"%game.screen)
 var found=stat_lines(game)
 check(found.size()==1,"finale first recovery: exactly one stats line (found %d)"%found.size())
 if found.size()==1:check(found[0]==LINE,"finale first recovery carries the sim values: "+found[0])
 game.queue_free();await settle()
# WP-34: photographs of a lost or abandoned dive are kept only on the easiest preset.
func take_spire_photo(game):
 var s=game.sim;s.sirens=[]
 var spire=Vector2(1300,300);var facing=2.74
 s.units[0].pos=spire+Vector2.from_angle(facing)*110;s.units[0].angle=facing+PI
 s.paused=false
 for n in 12:s.advance(1./60)
 s.command("camera")
 for n in 300:s.advance(1./60)
 s.paused=true
func photo_loss_case(preset:String,keeps:bool):
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 game.store.path="user://dive-end-photo-%s.save"%preset
 root.add_child(game);await settle();game.set_process(false)
 game.economy=preload("res://src/campaign/economy.gd").new_state(preset)
 game._start_mission(0);game.recovered_evidence={};game.photo_records={}
 take_spire_photo(game)
 var s=game.sim
 var taken:int=s.mission.photo.shots.size()
 check(taken>0,"%s: the dive took a photograph"%preset)
 game._retain_evidence()
 check(game.recovered_evidence.is_empty(),"%s: nothing is retained while the dive is still running"%preset)
 s.outcome="lost";s.message="Hull lost."
 game._evidence_gallery(0);await settle()
 check(game.recovered_evidence.has("spire")==keeps,"%s: opening the gallery after a loss %s the lost dive's frames"%[preset,"keeps" if keeps else "does not keep"])
 game.recovered_evidence={};game.photo_records={}
 game._debrief();await settle()
 var text=texts(game)
 check(text.contains("SIGNAL LOST") and text.contains("PHOTOGRAPHS TAKEN THIS DIVE") and text.contains(" · grade "),"%s: the lost screen lists the photograph with its frame quality and grade"%preset)
 check(text.contains("Kept as field records") if keeps else text.contains("Lost with the dive"),"%s: the lost screen states the photographs' fate"%preset)
 check(game.recovered_evidence.has("spire")==keeps and game.recovered_evidence.get("spire",{}).get("shots",[]).size()==(taken if keeps else 0),"%s: a lost dive %s its photographs as field records"%[preset,"keeps" if keeps else "keeps none of"])
 check(not game.completed.has(0) and game.photo_intel.is_empty() and game.expedition.is_empty(),"%s: a loss still grants no progress, intel or continuation"%preset)
 game.recovered_evidence={};game.photo_records={}
 s.outcome="";game.active_started=true
 preload("res://src/presentation/flow/photo_review.gd").retain_abandoned(game)
 check(game.recovered_evidence.has("spire")==keeps,"%s: an abandoned dive %s its photographs"%[preset,"keeps" if keeps else "keeps none of"])
 game._show_campaign();await settle()
 check(texts(game).contains("remain reviewable after loss or abandonment")==keeps and texts(game).contains("lost with it")!=keeps,"%s: the hub line tells the truth for this preset"%preset)
 game.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://dive-end-photo-%s.save"%preset+suffix)
func run():
 root.size=Vector2i(2520,1080);await settle()
 await photo_loss_case("accessible",true)
 await photo_loss_case("standard",false)
 await photo_loss_case("survival",false)
 await manifest_cases()
 await arc_case()
 await finale_case()
 print("DIVE END POLISH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
