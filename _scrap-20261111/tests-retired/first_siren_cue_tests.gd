extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func fixture(op):
 var s=Sim.new();s.start(op,"endurance")
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(120,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={}
 s.sirens=[e]
 for id in [1,2]:s.units[id].alive=false
 s.paused=false
 return s
func run():
 var path="res://src/presentation/first_siren_cue/notice_tracker.gd"
 var Script=load(path) if ResourceLoader.exists(path) else null
 check(Script!=null,"first-notice tracker exists")
 if Script==null:finish();return
 var Table=load("res://src/presentation/first_siren_cue/cue_table.gd")
 for op in [0,1,2,3,4,5]:
  var s=fixture(op);var tracker=Script.new();tracker.bind(s)
  var before_lock=[]
  var observe=func(_id,_pos):before_lock.append(s.sirens[0].lock)
  s.siren_notice.connect(observe)
  s._threats(.1)
  var expected=op in [0,1,2,3]
  check((tracker.frames().size()==1)==expected,"operation filter %d"%op)
  check(not before_lock.is_empty() and before_lock[0]==0.,"existing visual decision notifies before lock increments")
  s._threats(.1);s._threats(.1)
  check(tracker.seen.size()==(1 if expected else 0),"repeat acquisition stays once per Siren")
  if expected:
   check(is_equal_approx(tracker.frames()[0].bearing,90.),"bearing points toward the source without adding a contact")
   check(tracker.frames()[0].get("unit",-1)==0,"bearing records its reference craft for an unambiguous label")
   s.siren_notice.emit(1,s.units[0].pos+Vector2.LEFT*120)
   check(tracker.seen.size()==2 and tracker.frames().size()==2,"each Siren has an independent once-only record")
   s.elapsed+=Table.DURATION+.1
   check(tracker.frames().is_empty(),"cue expires on simulation time")
  s.siren_notice.disconnect(observe);tracker.unbind()
 var heard=fixture(1);heard.sirens[0].pos=heard.units[0].pos+Vector2(350,0);heard.sirens[0].home=heard.sirens[0].pos
 var ear=Script.new();ear.bind(heard);heard._noise(heard.units[0].pos,900.,"CAMERA",1.,heard.units[0].band);heard._threats(.1)
 check(heard.sirens[0].lock==0. and not ear.frames().is_empty(),"existing heard investigation cues before any lock")
 ear.unbind()
 var environmental=fixture(3);environmental.sirens[0].pos=environmental.units[0].pos+Vector2(350,0);environmental.sirens[0].home=environmental.sirens[0].pos
 var provenance=Script.new();provenance.bind(environmental)
 environmental._noise(environmental.sirens[0].pos,1150.,"FACTORY RESPONSE",8.,environmental.sirens[0].band);environmental._threats(.1)
 check(environmental.sirens[0].get("attention_time",0)>0 and provenance.seen.is_empty(),"environmental acquisition does not consume a craft-notice cue")
 environmental.noises.clear();environmental._noise(environmental.units[0].pos,900.,"CAMERA",2.,environmental.units[0].band);environmental._threats(.1)
 check(provenance.frames().size()==1,"later actual craft emission still gets the first notice")
 provenance.unbind()
 var s=fixture(1);var tracker=Script.new();tracker.bind(s);s._threats(.1)
 s.start(1,"endurance");s.siren_notice.emit(0,s.units[0].pos+Vector2(120,0))
 check(tracker.seen.size()==1 and tracker.frames().size()==1,"new dive resets the once-only record")
 tracker.unbind()
 var on=fixture(3);var off=fixture(3);var a=Script.new();var b=Script.new();a.bind(on);b.bind(off)
 var hashes=[]
 for n in 8:
  Table.enabled=true;on.advance(.1);a.frames()
  Table.enabled=false;off.advance(.1);b.frames()
  hashes.append(hash(on.snapshot())==hash(off.snapshot()))
 check(hashes.all(func(equal):return equal),"cue on/off preserve every scripted simulation snapshot hash")
 check(a.seen.size()==1 and b.seen.is_empty(),"off switch suppresses presentation")
 Table.enabled=true;a.unbind();b.unbind()
 finish()
func finish():
 print("FIRST SIREN CUE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
