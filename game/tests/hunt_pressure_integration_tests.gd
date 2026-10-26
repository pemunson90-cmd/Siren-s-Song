extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Table=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture(on:bool,distance:float=350.):
 Table.enabled=on
 var s=Sim.new();s.start(22,"endurance")
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 for u in s.units:u.alive=false
 s.units[0].alive=true;s.units[0].pos=Vector2(300,500)
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(distance,0);e.home=e.pos;e.goal=e.pos;e.type="sentinel";e.route=[];e.patrol_points=[];e.stun=0.;e.lock=0.;e.target=-1;e.band=s.units[0].band;e.transition={}
 s.sirens=[e];s.mission.reconnaissance={"hunt":95.,"floor":0.,"delay":0.,"secured":[]}
 return s
func _initialize()->void:
 Table.enabled=true
 var s=Sim.new();s.start(22)
 check(Hunt.active(s.mission),"fresh operation opts in")
 s._noise(s.units[0].pos,100.,"DECOY")
 check(s.Recon.state(s.mission).hunt==0.,"actual decoy noise path adds no Hunt")
 s._noise(s.units[0].pos,100.,"RECON UPLINK")
 check(s.Recon.state(s.mission).hunt==0.,"actual survey noise path adds no Hunt")
 s._noise(s.units[0].pos,100.,"ACTIVE SONAR")
 check(s.Recon.state(s.mission).hunt==5.,"actual sonar noise path adds five")
 var saved=s.snapshot();var restored=Sim.new()
 check(Sim.valid_snapshot(saved) and restored.restore(saved),"new mission state validates/restores")
 if saved.mission.has("hunt_pressure"):
  var bad=saved.duplicate(true);bad.mission.hunt_pressure.seen=1
  check(not Sim.valid_snapshot(bad),"optional validator rejects corrupt boolean")
 else:check(false,"optional validator has a real field to validate")
 var legacy=saved.duplicate(true);legacy.mission.erase("hunt_pressure")
 var old=Sim.new();check(old.restore(legacy) and not Hunt.active(old.mission),"absent optional field remains inactive after restore")
 var old_hunt=old.Recon.state(old.mission).hunt;old._noise(old.units[0].pos,100.,"DECOY")
 check(old.Recon.state(old.mission).hunt==old_hunt+4.,"legacy action amount stays four")
 var a=fixture(true);var b=fixture(false)
 a.units[0].vel=Vector2(78,0);b.units[0].vel=Vector2(78,0)
 Table.enabled=true;a._threats(Sim.STEP)
 Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens==b.sirens and a.hull==b.hull,"high Hunt leaves actual hearing and movement identical beyond sight")
 a=fixture(true,250.);b=fixture(false,250.)
 Table.enabled=true;a._threats(Sim.STEP)
 Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens[0].lock>0 and b.sirens[0].lock==0,"eligible sight extends while legacy sight does not")
 a=fixture(true,100.);b=fixture(false,100.)
 for n in 80:
  Table.enabled=true;a._threats(Sim.STEP)
  Table.enabled=false;b._threats(Sim.STEP)
 check(a.sirens==b.sirens and a.hull==b.hull and a.outcome==b.outcome,"same acquired target retains identical lock/beam/damage and movement")
 Table.enabled=true
 var save_source=Sim.new();save_source.start(0);save_source.Recon.action(save_source.mission,45.)
 Hunt.observe(save_source,Sim.STEP);var save_snapshot=save_source.snapshot()
 var disk=Store.new();disk.path="user://hunt-roundtrip.save"
 var envelope={"version":1,"unlocked":0,"completed":[],"upgrade":"endurance","settings":{},"active":save_snapshot}
 check(disk.save(envelope),"existing on-disk save path accepts Hunt")
 var disk_copy=Sim.new();var stored=disk.load_game()
 check(stored.has("active") and disk_copy.restore(stored.active) and disk_copy.mission==save_snapshot.mission,"existing save codec preserves owned metadata")
 Table.enabled=true
 print("HUNT INTEGRATION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
