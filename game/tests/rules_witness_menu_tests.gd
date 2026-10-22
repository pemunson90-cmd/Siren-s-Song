extends SceneTree
# Witness capsule carriage honors winch capacity; menu SPACE never touches the
# hidden mission pause state.
const Sim=preload("res://src/simulation/simulation.gd")
const BERTH=Vector2(1840,760)
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func frames():
 for n in 4:await process_frame
func step(sim,seconds:float):
 sim.paused=false
 for n in ceili(seconds*60):sim.advance(1./60.)
 sim.paused=true
func fresh(unit:int,fit:Dictionary):
 var sim=Sim.new();sim.start(12,"endurance",{"fitted":fit});sim.sirens=[]
 sim.units[unit].pos=BERTH+Vector2(0,40);sim.units[unit].vel=Vector2.ZERO;sim.command("select",{"unit":unit});step(sim,.02)
 return sim
func key(code:int):
 var e=InputEventKey.new();e.keycode=code;e.pressed=true;e.echo=false;return e
func run():
 var base={"quietus":"","drone_a":"","drone_b":""}
 var scout=base.duplicate();scout["chassis_a"]="scout"
 var sim=fresh(1,scout)
 check(sim.witness_status().known,"witness site is known to the scout fixture")
 check(not sim.witness_context().winch.ready,"zero cargo scout cannot winch the occupied capsule")
 check(not sim.command("salvage",{"item":"witness_capsule"}) and sim.witness_status().capsule.state=="at_berth","scout salvage command is refused and the capsule stays at berth")
 var endure=base.duplicate();endure["chassis_a"]="endurance"
 sim=fresh(1,endure)
 check(sim.witness_context().winch.ready,"one cargo place drone can winch the capsule")
 check(sim.command("salvage",{"item":"witness_capsule"}),"one cargo place drone starts the winch")
 step(sim,4.5)
 check(sim.witness_status().capsule.state=="carried" and sim.witness_status().capsule.carrier==1,"capsule is carried by the capable drone")
 sim=fresh(0,base)
 check(sim.witness_context().winch.ready,"default Quietus hull can winch the capsule")
 var quiet=base.duplicate();quiet["hull"]="quiet"
 sim=fresh(0,quiet)
 check(sim.witness_context().winch.ready,"low noise hull has one place and can winch the capsule")
 # A module already filling the only place blocks the capsule too.
 sim=fresh(1,endure)
 sim.mission.module_recovery.modules["probe_module"]={"state":"cargo","unit":1,"pos":Vector2.ZERO}
 check(not sim.witness_context().winch.ready,"a full winch refuses the capsule like it refuses salvage")
 # Menu SPACE.
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://rules-r1-menu.save"
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(g.store.path+suffix)
 root.size=Vector2i(2520,1080);await frames()
 root.add_child(g);await frames();g.set_process(false)
 g._start_mission(0);g._enter_water();await frames()
 g.sim.paused=false
 g._unhandled_key_input(key(KEY_SPACE))
 check(g.sim.paused,"SPACE during live play still pauses")
 g._unhandled_key_input(key(KEY_SPACE))
 check(not g.sim.paused,"SPACE during live play still resumes")
 g.sim.paused=true
 g._briefing(0)
 check(g.screen=="briefing" and g.sim.paused,"briefing holds mission paused")
 g._unhandled_key_input(key(KEY_SPACE))
 check(g.sim.paused,"SPACE in briefing does not unpause the hidden mission")
 g._settings_menu()
 check(g.screen=="settings" and g.sim.paused,"settings holds mission paused")
 g._unhandled_key_input(key(KEY_SPACE))
 check(g.sim.paused,"SPACE in settings does not unpause the hidden mission")
 g.queue_free();await frames()
 print("RULES WITNESS MENU CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
