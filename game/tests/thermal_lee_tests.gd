extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 var s=Sim.new();s.start(3);s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s.units[0].pos=Vector2(860,840);s.units[1].alive=false;s.units[2].alive=false;s.contacts={};s.known={};return s
func finish():print("THERMAL LEE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=fixture()
 check(s.mission.get("thermal_revision",0)==1,"fresh Foundry authors a local thermal-front opportunity")
 check(s.has_method("contact_visible"),"contact reception is separate from terrain/optical visibility")
 if not s.has_method("contact_visible"):finish();return
 var enemy=s.sirens[0];enemy.pos=Vector2(1080,840);enemy.lock=0.0;enemy.stun=0.0;enemy.target=-1
 check(s.visible(enemy.pos) and not s.contact_visible(enemy),"front reduces passive contact reception without hiding chart water")
 s._observe();check(s.known.has(Vector2i(26,21)) and not s.contacts.has(0),"thermal passive loss does not erase or suppress earned chart cells")
 s.units[0].silent=false;enemy.pos=Vector2(1110,840);enemy.lock=1.0;enemy.target=0
 check(s.contact_visible(enemy),"actual line-of-sight charge on owned craft remains observable across front")
 s._observe();check(s.contacts.has(0) and s.contacts[0].lock==1.0 and s.contacts[0].time==s.elapsed,"observable beam produces a fresh warning rather than stale hidden damage")
 enemy.target=-1;check(not s.contact_visible(enemy),"old decaying lock without a live target grants no remote observation")
 enemy.target=0;enemy.stun=1.0;check(not s.contact_visible(enemy),"stunned contact does not gain an invented beam emission")
 enemy.stun=0.0;s.mission.structures=[Rect2(970,800,40,100)];s._build_navigation();check(not s.contact_visible(enemy),"beam warning never sees through physical cover")
 s.mission.structures=[];s._build_navigation();enemy.pos=Vector2(1010,840);s.units[0].pos=Vector2(990,840);enemy.target=-1;enemy.lock=0.0
 check(s.contact_visible(enemy),"close separation bypass is based on the source and listener")
 s=fixture();enemy=s.sirens[0];enemy.pos=Vector2(1080,840);enemy.lock=0.0;enemy.stun=0.0;enemy.target=-1
 s.mission.objectives[0].pos=Vector2(1080,840);check(s.camera_context().ready,"optical evidence range/LOS is unchanged by thermal reception loss")
 var before=s.snapshot();s.advance(10);check(s.snapshot()==before,"pause freezes front encounter without new knowledge or resource use")
 var restored=Sim.new();check(restored.restore(before) and restored.snapshot()==before,"active front metadata and state restore without migration")
 var old=before.duplicate(true);old.mission.erase("thermal_band");old.mission.erase("thermal_revision");old.mission.erase("thermal_fronts");old.mission.erase("departure_revision");var legacy=Sim.new()
 check(legacy.restore(old) and legacy.snapshot()==old and legacy.contact_visible(legacy.sirens[0])==legacy.visible(legacy.sirens[0].pos),"legacy Foundry archive restores exact unmasked behavior")
 var bad=before.duplicate(true);bad.mission.thermal_fronts[0].transmission=NAN;check(not Sim.valid_snapshot(bad),"nonfinite thermal strength is rejected before restore")
 bad=before.duplicate(true);bad.mission.id=2;check(not Sim.valid_snapshot(bad),"authored Foundry thermal data cannot activate globally in other chapters")
 for chapter in [0,1,2,4,5]:
  var other=Sim.new();other.start(chapter);check(not other.mission.has("thermal_revision") and not other.mission.has("thermal_fronts"),"chapter%d retains its existing environment"%chapter)
 # This real charge is initially outside the reduced passive horizon. Sensor
 # refresh must keep its emission current before any subsequent hull damage.
 var threat=fixture();threat.units[0].pos=Vector2(900,840);threat.sirens=[threat.sirens[0]];threat.sirens[0].pos=Vector2(1060,840);threat.sirens[0].home=threat.sirens[0].pos;threat.sirens[0].goal=threat.sirens[0].pos;threat.sirens[0].stun=0.0;threat.sirens[0].lock=0.0;threat.sirens[0].target=-1;threat.paused=false
 var warnings=true;var damage_seen=false
 for n in 300:
  var hull=threat.hull;threat.advance(1.0/60)
  if threat.hull<hull:
   damage_seen=true;warnings=warnings and threat.contacts.has(0) and threat.elapsed-threat.contacts[0].time<0.3 and threat.contacts[0].lock>0
 check(damage_seen and warnings,"real unbroken visible charge cannot deal untelegraphed thermal-masked damage")
 finish()
