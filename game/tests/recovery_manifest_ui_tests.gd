extends SceneTree
const Manifest=preload("res://src/presentation/recovery_manifest.gd")
class ManifestSim:
 extends "res://src/simulation/simulation.gd"
 var mouth=Vector2(300,800)
 var requests=[]
 func extraction_corridors()->Array:return [{"pos":mouth,"name":"HOME BASIN","route":"home","available":true}]
 func departure_context()->Dictionary:return {"available":true,"pending":false,"confirmation_required":false,"corridor":extraction_corridors()[0],"recovered":[],"left":[],"recovered_drones":[],"text":""}
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
func stage(game,drone_b_out:bool):
 var s=game.sim
 for id in 3:
  var u=s.units[id];u.alive=true;u.band=1;u.transition={};u.vel=Vector2.ZERO;u.pos=s.mouth+Vector2(10*id,0)
 if drone_b_out:s.units[2].pos=s.mouth+Vector2(400,0)
 s.paused=false;s.outcome="";s.requests.clear();game.screen="mission"
func run():
 # Pure projection first: no scene needed.
 var probe=ManifestSim.new();probe.start(0)
 for id in 3:probe.units[id].alive=true;probe.units[id].band=1;probe.units[id].transition={};probe.units[id].vel=Vector2.ZERO;probe.units[id].pos=probe.mouth
 check(Manifest.entries(probe).all(func(r):return r.in),"every craft at the mouth is IN")
 probe.units[2].pos=probe.mouth+Vector2(400,0)
 var rows=Manifest.entries(probe)
 check(rows[2].in==false and roundi(rows[2].distance)==400 and rows[0].in and rows[1].in,"only the far craft is OUT, with its distance")
 check(Manifest.lines(rows)[2].ends_with("OUT · 400m TO RECOVERY"),"manifest line names the craft OUT with a distance: "+Manifest.lines(rows)[2])
 probe.units[1].alive=false
 check(Manifest.lines(Manifest.entries(probe))[1].ends_with("OUT · LOST"),"a lost craft is listed OUT")
 root.size=Vector2i(2520,1080);await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="module-recovery-ui-fixture"
 game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false);game.sim=ManifestSim.new();game._start_mission(0);await settle()
 var s=game.sim
 # Drone B outside recovery: EXTRACT shows the manifest and nothing else happens.
 stage(game,true);game._recovery_route();await settle()
 check(game.screen=="recovery_manifest" and s.paused,"EXTRACT with a craft outside opens the manifest and pauses")
 var text=texts(game)
 check(("%s · OUT"%s.units[2].name.to_upper()) in text and "400m TO RECOVERY" in text,"manifest names DRONE B OUT with a distance")
 check("lost with its cargo" in text,"manifest says what OUT means")
 check(s.requests.is_empty() and s.outcome.is_empty(),"no order is sent and the dive is not ended by the manifest")
 var before=[s.units[1].pos,s.units[2].pos,s.units[2].alive]
 var hold=action(game,"manifest_hold");check(hold!=null and action(game,"manifest_confirm")!=null,"manifest offers HOLD and CONFIRM")
 hold.pressed.emit();await settle()
 check(game.screen=="mission" and not s.paused and s.outcome.is_empty() and s.requests.is_empty(),"HOLD keeps the dive running with nothing sent")
 check(before==[s.units[1].pos,s.units[2].pos,s.units[2].alive],"HOLD leaves every craft unchanged")
 # CONFIRM: same validated departure order as the module sheet's ABANDON.
 stage(game,true);game._recovery_route();await settle()
 var corridor=s.departure_context().corridor
 action(game,"manifest_confirm").pressed.emit();await settle()
 check(s.requests.size()==1 and s.requests[0]=={"order":"depart","args":{"confirm":true,"corridor":corridor}} and s.outcome=="won","CONFIRM ends the dive with the same departure order as today")
 # All craft in: no manifest; EXTRACT behaves as before (route order to the mouth).
 s.outcome="";stage(game,false);game._recovery_route();await settle()
 check(game.screen=="mission" and action(game,"manifest_hold")==null,"all craft in: no manifest is shown")
 check(not s.paused,"all craft in: the press does not pause the dive")
 print("RECOVERY MANIFEST CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
