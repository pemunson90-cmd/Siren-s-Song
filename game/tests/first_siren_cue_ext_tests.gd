extends SceneTree
# Handoff 049: op 1 cue, one-time new Siren type note, observer-only proof.
const Sim=preload("res://src/simulation/simulation.gd")
const Tracker=preload("res://src/presentation/first_siren_cue/notice_tracker.gd")
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
const Archive=preload("res://src/presentation/first_siren_cue/cue_archive.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func fixture(op,kind="patroller"):
 var s=Sim.new();s.start(op,"endurance")
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(120,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={};e.type=kind
 s.sirens=[e]
 for id in [1,2]:s.units[id].alive=false
 s.paused=false
 return s
func run():
 Table.enabled=true
 check(Table.OPERATIONS==[0,1,2,3],"operation table lists player ops 1 to 4")
 # Op 1 (mission id 0): chip once per Siren id.
 var s=fixture(0);var t=Tracker.new();t.bind(s)
 s._threats(.1);s._threats(.1)
 check(t.frames().size()==1 and t.seen.size()==1,"op 1 shows the bearing cue once per Siren id")
 check(t.notes().size()==1 and t.notes()[0].text=="NEW SIREN TYPE: PATROLLER","op 1 first patroller notice carries the new type note")
 s.siren_notice.emit(0,s.units[0].pos+Vector2(100,0))
 check(t.notes().size()==1 and t.frames().size()==1,"repeat notice adds neither chip nor note")
 s.elapsed+=Table.NOTE_DURATION+.1
 check(t.notes().is_empty() and t.frames().is_empty(),"chip and note expire on simulation time")
 t.unbind()
 # Once per type across missions; unbind keeps the campaign-wide memory.
 var kinds=["patroller","sweeper","hunter","sentinel","warden","interceptor","buoy","relay"]
 var camp=Tracker.new()
 for i in kinds.size():
  var k=kinds[i];var m=fixture(i%6,k);camp.bind(m)
  m.siren_notice.emit(0,m.units[0].pos+Vector2(90,0))
  check(camp.notes().size()==1 and camp.notes()[0].type==k and camp.notes()[0].text=="NEW SIREN TYPE: "+k.to_upper(),"first %s notice names its type on op %d"%[k,i%6+1])
  check((camp.frames().size()==1)==(i%6 in Table.OPERATIONS),"bearing chip still only on listed operations (%s)"%k)
  m.siren_notice.emit(0,m.units[0].pos+Vector2(80,0));camp.unbind()
 check(camp.types_seen.size()==kinds.size(),"every type recorded exactly once")
 var again=fixture(5,"hunter");camp.bind(again);again.siren_notice.emit(0,again.units[0].pos+Vector2(90,0))
 check(camp.notes().is_empty(),"a type already seen on an earlier dive never repeats its note")
 camp.unbind()
 var odd=fixture(0,"mystery");var o=Tracker.new();o.bind(odd);odd.siren_notice.emit(0,odd.units[0].pos+Vector2(90,0))
 check(o.notes().is_empty() and o.types_seen.is_empty() and o.frames().size()==1,"absent type name shows nothing and records nothing")
 odd.siren_notice.emit(7,odd.units[0].pos+Vector2(90,0));check(o.notes().is_empty(),"out of range Siren id is ignored by the note")
 o.unbind()
 # Persistence and validation.
 var saved=Tracker.new();saved.restore_types(["hunter","hunter",7,"nonsense","sweeper"])
 check(saved.saved_types()==["hunter","sweeper"],"restore keeps only known unique type strings")
 var data={"first_siren_types":["hunter","sweeper"]}
 check(Archive.valid(data),"valid type list accepted without any active dive")
 check(Archive.valid({}),"old archive without the field loads")
 check(Archive.valid({"first_siren_types":["future_kind"]}),"unknown future kind string does not invalidate a save")
 var too_many=[]
 for i in 17:too_many.append("t%d"%i)
 for bad in [["hunter","hunter"],[1],[""],["x".repeat(33)],"hunter",{"a":1},too_many]:
  check(not Archive.valid({"first_siren_types":bad}),"malformed type field rejected: "+str(bad).left(30))
 check(not Archive.valid({"first_siren_types":null}),"null type field rejected")
 var legacy={"first_siren_seen":[0],"active":{"sirens":[{}]}}
 check(Archive.valid(legacy),"legacy first_siren_seen archive still valid")
 legacy["first_siren_types"]=["hunter","hunter"];check(not Archive.valid(legacy),"bad type list rejected beside valid ids")
 # Flag off restores today's behaviour.
 Table.enabled=false
 var off=fixture(0);var f=Tracker.new();f.bind(off);off._threats(.1)
 check(f.frames().is_empty() and f.notes().is_empty() and f.types_seen.is_empty(),"flag off: no chip, no note, no memory")
 f.unbind();Table.enabled=true
 # Observer only: byte-equal snapshots with cue on and off across scripted ops 1 to 6.
 var equal=true
 for op in 6:
  var on=Sim.new();var offs=Sim.new();on.start(op,"endurance");offs.start(op,"endurance")
  var a=Tracker.new();var b=Tracker.new();a.bind(on);b.bind(offs)
  for n in 120:
   Table.enabled=true;on.advance(.1);a.frames();a.notes()
   Table.enabled=false;offs.advance(.1);b.frames();b.notes()
   if n%20==19 and var_to_bytes(on.snapshot())!=var_to_bytes(offs.snapshot()):equal=false;printerr("DIFF op ",op," step ",n)
  a.unbind();b.unbind();Table.enabled=true
 check(equal,"simulation snapshot byte-equal with the cue on and off across ops 1 to 6")
 print("FIRST SIREN CUE EXT CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
