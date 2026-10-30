extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fresh(op:int,unit:int=0):
 var s=Sim.new();s.start(op,"endurance",{"fitted":{"quietus":"","drone_a":"","drone_b":""}})
 s.sirens=[];s.selected=unit
 # Source-known custody fixture: receive the local source in MIDDLE before
 # staging the authored pod band. Ordinary observation owns source/fact/site state.
 s.units[unit].pos=s.Witness.berth(s.mission);s.units[unit].band=1
 s.Consequences.observe(s)
 check(s.Witness.known(s),"local MIDDLE observation identifies the pod before loading")
 s.Depth.cargo_bands(s);s.units[unit].band=s.Depth.cargo_band(s,s.Witness.ITEM)
 s.Witness.collect_at(s,unit,s.units[unit].pos)
 check(s.mission.witness_evacuation.state=="carried" and s.mission.witness_evacuation.carrier==unit,"fixture really loads the identified pod on its actual carrier")
 s.units[unit].pos=s.mission.extraction;s.units[unit].band=2;s._use_band(2)
 return s
func _initialize():call_deferred("run")
func run():
 # Authored op12 sailors use the multiple-occupant class; op41 carries one boy.
 for row in [[41,0,8.],[41,1,8.],[12,0,12.],[12,2,12.]]:
  var s=fresh(row[0],row[1]);var u=s.units[s.selected]
  check(s.command("depth",{"band":1}),"occupied carrier can ascend "+str(row))
  check(u.transition.remaining==row[2],"ascent scales by survivor load "+str(row))
  check(s.Depth.occupied(u)==[2,1],"long ascent still occupies both bands")
  s.Depth.advance(s,1.)
  var copy=Sim.new();check(copy.restore(s.snapshot()),"partial carried ascent restores")
  s.Depth.advance(s,row[2]-1.)
  if copy.units.is_empty():continue
  copy.Depth.advance(copy,row[2]-1.)
  check(u.band==1 and copy.units[copy.selected].band==1,"restored ascent finishes at same band")
  check(not s.command("depth",{"band":0}),"settle prevents immediate second ascent")
  check(u.get("ascent_settle",-1.)==6. and copy.units[copy.selected].get("ascent_settle",-1.)==6.,"ascent starts exact six-second settle on both resumed carriers")
  var frozen=s.snapshot();s.advance(3.);check(s.snapshot()==frozen,"tactical pause freezes settle countdown")
  var settled=Sim.new();check(settled.restore(s.snapshot()),"settle countdown restores")
  check(not settled.command("depth",{"band":0}),"restored settle prevents early ascent")
  s.Depth.advance(s,5.9);check(not s.command("depth",{"band":0}),"six-second settle remains until deadline")
  s.Depth.advance(s,.11);check(s.command("depth",{"band":0}),"next ascent allowed after six seconds")
 var s=fresh(41);s.units[0].band=1
 check(s.command("depth",{"band":2}) and s.units[0].transition.remaining==4.,"carried descent unchanged")
 s=fresh(41);s.mission.witness_evacuation.state="landed";s.mission.witness_evacuation.carrier=-1
 check(s.command("depth",{"band":1}) and s.units[0].transition.remaining==4.,"empty craft ascent unchanged")
 check(s.Depth.SurvivorAscent.duration_for_count(2)==12. and s.Depth.SurvivorAscent.duration_for_count(3)==12.,"two or more use twelve seconds without creating new custody")
 s=Sim.new();s.start(0);var legacy=s.snapshot()
 for u in legacy.units:u.erase("ascent_settle")
 check(Sim.new().restore(legacy),"legacy saves need no settle field")
 # Sleeve trades retain ordinary descent timing but cannot bypass survivor safety.
 s=fresh(41);s.mission.launch_equipment.quietus="quietus_pressure_sleeve"
 check(s.command("depth",{"band":1}) and s.units[0].transition.remaining==8.,"pressure sleeve cannot shorten carried ascent")
 var active=s.snapshot()
 for value in [-1.,6.1,INF,"bad"]:
  var bad=active.duplicate(true);bad.units[0]["ascent_settle"]=value
  check(not Sim.valid_snapshot(bad),"malformed settle rejected "+str(value))
 for change in [{"carried_ascent":false},{"carried_ascent":1},{"remaining":12.1},{"to":2}]:
  var bad=active.duplicate(true);bad.units[0].transition.merge(change,true)
  check(not Sim.valid_snapshot(bad),"malformed carried transition rejected "+str(change))
 s.Depth.advance(s,8.)
 check(s.command("depth",{"band":2}) and s.units[0].transition.remaining==2.5,"sleeved descent remains available during settle at existing duration")
 s.Depth.advance(s,2.5)
 check(s.units[0].get("ascent_settle",0.)==6.,"descending does not count as holding a settled band")
 s=Sim.new();s.start(0);s.units[0].pos=s.mission.extraction;s.units[0].band=2;s._use_band(2)
 check(s.command("depth",{"band":1}),"legacy ordinary transition begins")
 legacy=s.snapshot();legacy.units[0].erase("ascent_settle");legacy.units[0].transition.erase("carried_ascent")
 var old=Sim.new();var loaded=old.restore(legacy)
 check(loaded,"legacy in-progress two-field transition restores")
 if loaded:
  old.Depth.advance(old,4.)
  check(old.units[0].band==1 and old.units[0].get("ascent_settle",0.)==0.,"legacy transition preserves old duration without retroactive settle")
 var tow={"id":28,"iron_choir":{"load":{"state":"towed","carrier":1}}}
 check(s.Depth.SurvivorAscent.count(tow,1)==2 and s.Depth.SurvivorAscent.count(tow,0)==0,"occupied tow counts only on its existing real carrier")
 check(s.Depth.SurvivorAscent.line(tow,1,{}).contains("release before changing depth"),"occupied tow HUD preserves depth prohibition")
 print("SURVIVOR ASCENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
