extends SceneTree
# Own-position fixtures isolate local work and history. Real guard voyages are separate.
const Sim=preload("res://src/simulation/simulation.gd")
const Harbour=preload("res://src/simulation/concealed_harbour.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func step(s,time:float):
 s.paused=false
 for n in ceili(time*60):s.advance(1./60.)
 s.paused=true
func fresh(thread:String="deep",facts:Dictionary={}):
 var s=Sim.new();s.start(12,"endurance",{"context":{"thread":thread,"facts":facts,"completed":[6,7,9,11] if thread=="deep" else [6,8,10,11],"references":{}}});s.sirens=[];return s
func board(s):
 s.units[0].pos=Vector2(1840,800);s.units[0].vel=Vector2.ZERO;step(s,.02)
 check(s.command("salvage",{"item":"witness_capsule"}),"actual local occupied-pod winch begins")
 step(s,4.1)
func hook(s):
 s.units[0].pos=s.mission.concealed_harbour.pos+Vector2(0,-60);s.units[0].vel=Vector2.ZERO
 return s.command("concealed_tow",{"action":"attach"})
func staged_place(s,id:String):
 var p=Harbour.placements(s.mission.concealed_harbour).filter(func(v):return v.id==id)[0].pos
 # Staged water coordinates, not an earned journey: the helper still computes
 # its own actual trail and refuses seating until the tow reaches local water.
 s.units[0].pos=p;s.units[0].vel=Vector2.ZERO;step(s,.02)
 return s.command("concealed_tow",{"action":id})
func progress(thread:String)->Dictionary:
 return {"version":2,"route":thread,"routes":[thread],"facts":{thread:"Recovered branch","confluence_route":"concealed"},"completed":[6,7,9,11] if thread=="deep" else [6,8,10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
func finish_dive(s):
 s.units[0].pos=Vector2(2260,2700);s.units[0].vel=Vector2.ZERO
 check(s.command("witness_land"),"occupied witness still must physically land")
 step(s,.02)
func run():
 var s=fresh()
 check(s.has_method("concealed_status"),"rescued witness has a physical concealed consequence beyond pod delivery")
 if not s.has_method("concealed_status"):finish();return
 check(not s.concealed_status().known and not s.command("concealed_tow",{"action":"attach"}),"unrescued witness reveals no private work or interaction")
 board(s)
 check(s.concealed_status().known and s.concealed_status().account.contains("not a departing hull"),"living navigator identifies a specific mistaken sound interpretation")
 var staged=Sim.new();staged.restore(s.snapshot());finish_dive(staged)
 check(staged.outcome.is_empty() and not staged.all_records(),"pod landing alone cannot claim the newly promised departure consequence")
 step(s,6.1);var heard=s.mission.concealed_harbour.heard_departures
 check(heard>0,"connected deep float actually receives departure sound along acoustic paths")
 check(hook(s) and s.concealed_status().connected,"coupling alone leaves the real trace socket connected")
 s.units[0].pos=Vector2(1840,970);s.units[0].vel=Vector2.ZERO;step(s,.02)
 var midstore=Store.new();midstore.path="user://concealed-mid-tow.save"
 var midarchive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress("deep"),"active":s.snapshot()}
 check(midstore.save(midarchive) and midstore.load_game()==midarchive,"actual current binary save preserves partially hauled connected trace and real trail")
 var resumed=Sim.new();check(resumed.restore(midstore.load_game().get("active",{})),"partial connected tow restores through ordinary snapshot validation")
 step(s,.3);step(resumed,.3)
 check(s.concealed_status()==resumed.concealed_status(),"restored partial tow and socket produce the same next simulation state")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(midstore.path+suffix)
 var held=s.snapshot();s.advance(10);check(s.snapshot()==held,"unlimited pause freezes tow, traces and replies")
 check(s._craft_speed(s.units[0],78)<=40,"attached tow changes actual craft speed")
 check(s.command("concealed_tow",{"action":"release"}) and s.mission.concealed_harbour.phase=="ready","release leaves the equipment at its actual water position")
 step(s,6.1);check(s.mission.concealed_harbour.heard_departures>heard and not s.concealed_status().receipt,"attach then release in place does not solve the trace or claim a departure")
 check(hook(s),"same released float can be reattached locally")
 s.units[0].pos=Vector2(1840,850);s.units[0].vel=Vector2.ZERO;step(s,.02)
 check(not s.concealed_status().connected and s.command("concealed_tow",{"action":"release"}),"actual hauling clears the socket and permits legitimate cast-off without a destination chore")
 check(not s.concealed_status().receipt,"onboard navigator cannot immediately certify an external reply")
 s.units[0].pos=Vector2(2180,840);s.units[0].vel=Vector2.ZERO;step(s,2.1)
 check(s.concealed_status().receipt,"actual station response reaches a living receiver through water")
 finish_dive(s)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"deep consequence, actual witness landing and Q recovery produce a valid successful dive")
 var deep=Campaign.recover(progress("deep"),s.mission)
 check(deep.facts.get("concealed_consequence","")=="deep_trace_severed","first recovered deep outcome stores the actual trace consequence")
 var shelves=[]
 for placement in ["service","baffle"]:
  var shelf=fresh("shelf",{"shelf_warning":"occupied bays warned","warning_chain":"service_local_receipt"});board(shelf)
  check(shelf.concealed_status().account.contains("nurseries") and shelf.concealed_status().account.contains("local service receipt"),"shelf witness consumes relevant prior gallery and service facts")
  var before=shelf.acoustic_paths.arrivals(Vector2(1740,970),Vector2(2300,970),1500)
  check(shelf.blocked(Vector2(2010,1070)),"collapsed shelf screen physically blocks the refuge mouth")
  check(hook(shelf),"bare Quietus can attach the screen outside its solid face")
  check(not shelf.blocked(Vector2(2010,1070)),"folding onto tow removes the actual collapsed obstruction")
  if placement=="baffle":
   shelf.units[2].pos=Vector2(2140,970);shelf.units[2].vel=Vector2.ZERO
   check(not staged_place(shelf,placement),"unfolding screen refuses to enclose another living craft")
   shelf.units[2].pos=Vector2(2060,2680)
  check(staged_place(shelf,placement),"both advertised shelf placements can be seated through the real local command")
  check(not shelf.path(Vector2(1940,1130),Vector2(2300,1130)).is_empty(),"lower refuge entry remains physically navigable after either choice")
  check(shelf.blocked(Vector2(2140,970))==(placement=="baffle"),"baffle choice actually closes only the short northern approach")
  var after=shelf.acoustic_paths.arrivals(Vector2(1740,970),Vector2(2300,970),1500)
  shelves.append(after[0].strength if not after.is_empty() else 0.)
  shelf.units[0].pos=Vector2(2300,970);shelf.units[0].vel=Vector2.ZERO;step(shelf,2.1)
  check(shelf.concealed_status().receipt,"harbour watch receipt follows the actual opened mouth and placement")
  finish_dive(shelf)
  var history=Campaign.recover(progress("shelf"),shelf.mission)
  check(Sim.valid_snapshot(shelf.snapshot()),"actual shelf state is a valid current snapshot")
  if not Sim.valid_snapshot(shelf.snapshot()):print("SHELF VALIDATORS"," operations=",Sim.Operations.valid(shelf.mission,shelf.elapsed)," world=",Sim.WorldRegion.valid(shelf.snapshot())," consequence=",Sim.Consequences.valid_mission(shelf.mission,shelf.elapsed)," witness=",Sim.Witness.valid(shelf.snapshot())," new=",Sim.Concealed.valid(shelf.snapshot()))
  check(shelf.outcome=="won" and history.facts.get("concealed_consequence","")=="shelf_"+placement,"shelf success records its actual chosen physical harbour")
  check(Endings.resolve(history).get("story","")!=Endings.resolve(deep).get("story","") and Endings.resolve(history).get("outcome","")!=Endings.resolve(deep).get("outcome",""),"deep departure and shelter harbour earn substantively distinct endings")
  var replay=Campaign.recover(history,s.mission)
  check(replay.facts.get("concealed_consequence")==history.facts.get("concealed_consequence"),"replay cannot rewrite first committed harbour consequence")
 check(shelves.size()==2 and shelves[1]<shelves[0],"sheltered placement has a real acoustic cost/benefit compared with direct open service")
 var missing=fresh("shelf");board(missing)
 check(not missing.concealed_status().account.contains("Your gallery warning"),"missing earlier warning never invents prior action")
 var old=s.snapshot();old.mission.erase("concealed_harbour")
 check(not Sim.valid_snapshot(old),"incompatible old active finale rejects cleanly without compatibility flags")
 var prior=progress("deep");prior.completed.append(12);prior.facts.merge({"witness_arrival":"quietus","witness_recovery":"No transport lost.","resolution":"concealed_recovery"});prior.history.append({"mission":12,"thread":"deep","fitted":{"quietus":"","drone_a":"","drone_b":""}})
 var old_ending=Endings.resolve(prior)
 var retained=Campaign.recover(prior,s.mission)
 check(Campaign.valid(prior) and not retained.facts.has("concealed_consequence") and Endings.resolve(retained)==old_ending,"committed prior ending is not rewritten as newly performed environmental work")
 var store=Store.new();store.path="user://concealed-harbour-test.save"
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":deep,"active":s.snapshot()}
 check(store.save(archive) and store.load_game()==archive,"actual binary save preserves the new completed consequence and first history")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 finish()
func finish():
 print("CONCEALED HARBOUR CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
