extends SceneTree
# Controlled own-position fixtures isolate custody; real-guard journeys live
# separately. No capsule/mission completion flag is injected as success proof.
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
const BERTH=Vector2(1840,760)
const HOME=Vector2(2260,2700)
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(sim,seconds:float):
 sim.paused=false
 for n in ceili(seconds*60):sim.advance(1./60.)
 sim.paused=true
func fresh(unit:int=0,fitted:Dictionary={}):
 var sim=Sim.new();sim.start(12,"endurance",{"fitted":fitted if not fitted.is_empty() else {"quietus":"","drone_a":"","drone_b":""}});sim.sirens=[]
 sim.units[unit].pos=BERTH+Vector2(0,40);sim.units[unit].vel=Vector2.ZERO;sim.command("select",{"unit":unit});step(sim,.02)
 return sim
func progress()->Dictionary:
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch","confluence_route":"concealed"},"completed":[6,7,9,11],"notes":{},"references":{},"entitlements":["quietus_vector_drive","drone_deep_cells","quietus_baffles"],"history":[],"selected_thread":"deep"}
func run():
 var abstract=fresh()
 abstract.command("camera");step(abstract,4.2)
 abstract.units[0].pos=HOME;abstract.units[0].vel=Vector2.ZERO;step(abstract,.02)
 check(abstract.outcome.is_empty(),"a remote captured witness record cannot finish evacuation at home Quietus")
 for site in abstract.mission.objectives:
  if site.get("site_id","")=="witness_packet":site.captured=true
 step(abstract,.02)
 check(abstract.outcome.is_empty() and not abstract.all_records(),"even an old abstract captured flag cannot complete an untransported witness")
 var sim=fresh(1)
 check(sim.has_method("witness_status") and sim.has_method("witness_context"),"public occupied-capsule custody and local actions exist")
 if not sim.has_method("witness_status"):finish();return
 check(sim.units.size()==3 and sim.witness_status().known and sim.witness_status().capsule.state=="at_berth","local own observation identifies one occupied capsule without a fourth combat body")
 check(sim.witness_context().winch.ready and not sim.witness_context().land.ready,"bare local drone can winch but cannot land a remote pod")
 check(not sim.camera_context().ready,"witness body requires physical WINCH rather than an abstract camera capture")
 var untouched=sim.witness_status();sim.command("select",{"unit":2})
 check(not sim.command("salvage",{"item":"witness_capsule"}) and sim.witness_status()==untouched,"a remote peer cannot claim or move an observed occupied pod")
 sim.command("select",{"unit":1})
 var route=BERTH+Vector2(140,40);check(sim.command("route",{"point":route}),"ordinary carrier course can be prepared before loading")
 var goals=sim.route_goals();check(sim.command("salvage",{"item":"witness_capsule"}),"explicit ordinary salvage command starts occupied pod winch")
 check(sim.route_goals()==goals and sim.units[1].hold=="HOLD" and sim.noises.filter(func(n):return n.label=="RECOVERY WINCH").size()==1,"winch preserves route and uses one actual finite audible emission")
 sim.command("select",{"unit":0});sim.units[0].pos=sim.units[1].pos
 check(not sim.command("salvage",{"item":"witness_capsule"}) and sim.witness_context().winch.claimed_by==1,"two locally eligible craft cannot winch duplicate copies of the same occupant")
 sim.command("select",{"unit":1});sim.units[0].pos=Vector2(2060,2680)
 var held=sim.snapshot();check(not sim.command("route",{"point":Vector2(1000,1000)}) and sim.snapshot().mission.witness_evacuation==held.mission.witness_evacuation,"rejected rock route preserves active occupied-pod work")
 step(sim,1.5);check(sim.witness_status().jobs[1].elapsed>1.4,"actual partial capsule work advances on its own carrier")
 var paused=sim.snapshot();sim.advance(10);check(sim.snapshot()==paused,"tactical pause freezes occupied pod and partial winch")
 var archive={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress(),"active":paused}
 var store=Store.new();store.path="user://occupied-witness-test.save"
 check(store.save(archive) and store.load_game()==archive,"real current binary archive preserves a partial occupied-pod winch")
 var restored=Sim.new();check(restored.restore(store.load_game().active),"partial winch binary snapshot restores")
 step(sim,2.6);step(restored,2.6)
 check(sim.witness_status()==restored.witness_status() and sim.witness_status().cargo==[[],["witness_capsule"],[]],"the same unique occupied capsule finishes aboard its actual drone after restore")
 check(sim.witness_status().capsule.occupied and sim.witness_status().capsule.carrier==1 and not sim.all_records(),"carried survivor remains physically remote from harbour completion")
 check(not sim.command("witness_land"),"remote landing is rejected without teleporting the passenger")
 sim.units[1].pos=HOME;sim.units[1].vel=Vector2.ZERO
 check(sim.witness_context().land.ready and sim.command("witness_land"),"actual local living carrier explicitly lands its passenger")
 check(sim.witness_status().landed and sim.witness_status().cargo==[[],[],[]] and sim.witness_status().capsule.landed_by==1,"landing secures the one capsule in harbour and empties only its carrier")
 step(sim,.02);check(sim.outcome.is_empty(),"a drone landing does not extract a distant Quietus")
 sim.units[0].pos=HOME;sim.units[0].vel=Vector2.ZERO;step(sim,.02)
 check(sim.outcome=="won" and Sim.valid_snapshot(sim.snapshot()),"physical witness landing plus normal Quietus recovery completes a valid current dive")
 check(not sim.command("witness_land"),"a landed witness cannot be duplicated by repeating LAND")
 var malformed=sim.snapshot();malformed.mission.witness_evacuation.losses=[1]
 check(not Sim.valid_snapshot(malformed),"a living landing craft cannot be invented as a lost occupied-pod transport")
 malformed=sim.snapshot();malformed.mission.witness_evacuation.rescues=1
 check(not Sim.valid_snapshot(malformed),"saved rescue count must match actual transport losses")
 var recovered=Campaign.recover(progress(),sim.mission)
 check(recovered.facts.get("witness_arrival","")=="drone_a" and recovered.facts.get("witness_recovery","").contains("No transport lost"),"first successful campaign recovery records its actual landing carrier and intact voyage")
 check(Campaign.valid(recovered) and Endings.resolve(recovered).story.contains("DRONE A") and not Endings.resolve(recovered).story.contains("departing vessels"),"arrival ending describes the observed living passenger rather than an unseen evacuation fleet")
 var failed=Campaign.recover(progress(),abstract.mission)
 check(not failed.facts.has("witness_arrival"),"field notes or failed dives cannot commit a living witness arrival")
 var sheltered=Sim.new();sheltered.restore(sim.snapshot());sheltered.units[1].alive=false
 check(sheltered.witness_status().landed and Sim.valid_snapshot(sheltered.snapshot()),"a craft lost after landing cannot undo the passenger's actual safe harbour")
 var interrupted=fresh(1);interrupted.command("salvage",{"item":"witness_capsule"});step(interrupted,.5)
 check(interrupted.command("route",{"point":BERTH+Vector2(140,40)}) and interrupted.witness_status().jobs==[{},{},{}],"accepted replacement movement cancels the exposed occupied-pod winch immediately")
 var bad=interrupted.snapshot();bad.mission.witness_evacuation.state="salvage"
 check(not Sim.valid_snapshot(bad),"saved ejected occupant requires a real dead carrier")
 bad=interrupted.snapshot();bad.mission.witness_evacuation.job={"unit":1,"item":"witness_capsule","elapsed":.5}
 check(not Sim.valid_snapshot(bad),"saved winch cannot continue on a craft whose HOLD was released")
 var unknown=Sim.new();unknown.start(12)
 check(not unknown.witness_status().known and unknown.witness_status().capsule.is_empty() and unknown.salvage_sites().is_empty(),"undiscovered initial berth never projects a hidden passenger position")
 var lost=fresh(1,{"quietus":"","drone_a":"drone_deep_cells","drone_b":""})
 check(lost.command("salvage",{"item":"witness_capsule"}),"fitted carrier still loads the actual occupied pod")
 step(lost,4.1);var at=lost.units[1].pos;lost.units[1].battery=0;step(lost,.02)
 var sites=lost.salvage_sites()
 check(lost.witness_status().capsule.state=="salvage" and lost.witness_status().capsule.pos==at and lost.witness_status().capsule.losses==[1],"actual carrier exhaustion ejects the same occupied pod once at its own known position")
 check(sites.size()==1 and sites[0].get("witness",false),"colocated launched kit and occupied pod form one physical salvage target")
 lost.units[0].pos=at+Vector2(0,40);lost.units[0].vel=Vector2.ZERO;lost.command("select",{"unit":0})
 check(lost.command("salvage",{"item":sites[0].item}),"bare Quietus starts one shared kit-and-survivor winch")
 step(lost,4.1)
 check(lost.witness_status().cargo[0]==["witness_capsule"] and lost.module_recovery_status().cargo[0]==["drone_deep_cells"] and lost.salvage_sites().is_empty(),"one physical winch recovers exactly one living pod and the actual inert kit")
 check(lost.witness_status().capsule.rescues==1 and lost.units[1].alive==false,"recovery preserves the real carrier loss rather than resurrecting a drone")
 lost.units[2].alive=false;lost.units[0].pos=HOME;lost.units[0].vel=Vector2.ZERO
 check(lost.command("witness_land"),"Quietus can land the survivor after losing every helper")
 step(lost,.02);check(lost.outcome=="won" and lost.mission.physical_gates[0].opened==false,"bare Quietus and the quiet closed-sluice route retain permanent finishability")
 var rescue=Campaign.recover(progress(),lost.mission)
 check(rescue.facts.get("witness_arrival","")=="quietus" and rescue.facts.get("witness_recovery","").contains("DRONE A") and rescue.facts.get("witness_recovery","").contains("1 rescue"),"successful rescue retains its actual lost transport and recovered occupant account")
 var replay=Campaign.recover(recovered,lost.mission)
 check(replay.facts.get("witness_arrival","")==recovered.facts.get("witness_arrival","") and replay.facts.get("witness_recovery","")==recovered.facts.get("witness_recovery",""),"completed replay cannot rewrite first committed physical arrival or loss")
 archive.active=lost.snapshot();archive.expedition=rescue
 check(store.save(archive) and store.load_game()==archive,"completed occupied-pod rescue and first-commit facts survive actual binary save")
 var twice=fresh(1,{"quietus":"","drone_a":"drone_deep_cells","drone_b":"drone_sampler"})
 twice.command("salvage",{"item":"witness_capsule"});step(twice,4.1);twice.units[1].battery=0;step(twice,.02)
 twice.units[2].pos=twice.witness_status().capsule.pos+Vector2(0,20);twice.units[2].vel=Vector2.ZERO;twice.command("select",{"unit":2})
 check(twice.command("salvage",{"item":twice.salvage_sites()[0].item}),"surviving B can recover the original occupant and another drone's inert kit")
 step(twice,4.1);twice.units[2].battery=0;step(twice,.02)
 check(twice.salvage_sites().size()==1 and twice.salvage_sites()[0].get("witness",false) and twice.witness_status().capsule.losses==[1,2],"two actual transport losses still expose one occupied pod with both colocated modules")
 twice.units[0].pos=twice.witness_status().capsule.pos+Vector2(0,20);twice.units[0].vel=Vector2.ZERO;twice.command("select",{"unit":0})
 check(twice.command("salvage",{"item":twice.salvage_sites()[0].item}),"bare Q can winch the combined two-loss wreck once")
 step(twice,4.1)
 check(twice.witness_status().capsule.rescues==2 and twice.witness_status().cargo==[["witness_capsule"],[],[]] and twice.module_recovery_status().cargo[0].size()==2 and twice.salvage_sites().is_empty() and Sim.valid_snapshot(twice.snapshot()),"repeated exposed rescue preserves one living witness, two real carrier losses and two unique modules")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 finish()
func finish():
 print("WITNESS EVACUATION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
