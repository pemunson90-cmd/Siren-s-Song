extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var failures=0
var checks=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var legacy=Sim.new();legacy.start(0);var saved=legacy.snapshot()
 check(legacy.has_method("world_size"),"simulation exposes authored world bounds")
 if not legacy.has_method("world_size"):quit(1);return
 check(legacy.world_size()==Vector2(1600,960),"legacy chapter retains old world geometry")
 var restored=Sim.new();check(restored.restore(saved) and restored.snapshot()==saved,"old active snapshot remains byte-equivalent after restore")
 var s=Sim.new();s.start(1)
 check(s.world_size()==Vector2(2000,2400),"fresh Split Channel unfolds beyond a tactical viewport")
 check(s.command("route",{"point":s.mission.objectives[2].pos}),"operator route accepts goals beyond legacy bottom edge")
 check(s.navigation.region.size==Vector2i(50,60),"navigation covers authored region")
 check(s.units[0].pos.y>2000 and s.mission.extraction==s.units[0].pos,"deployment and recovery occupy southern basin")
 check(not s.visible(s.mission.objectives[0].pos),"remote relay is not revealed on deployment")
 check(s.known.has(Vector2i(s.units[0].pos/40)),"local chart observations work beyond legacy bottom edge")
 check(not s.path(s.units[0].pos,s.mission.objectives[0].pos+Vector2(0,180)).is_empty(),"west relay has a physically reachable approach")
 check(not s.path(s.units[0].pos,s.mission.objectives[1].pos+Vector2(0,180)).is_empty(),"east relay has a physically reachable approach")
 check(s.blocked(Vector2(2010,2000)) and not s.blocked(Vector2(220,2180)),"physical world edge follows region")
 var behind_cover=Vector2(420,1900)
 check(not s.visible(behind_cover),"basin overhang occludes passive returns")
 s.command("recon")
 check(s.visible(behind_cover),"local survey remains strategically useful behind nearby cover")
 check(s.tools.recon==1 and s.recon_time==8.0,"local survey preserves finite stock and eight-second duration")
 check(not s.visible(s.mission.objectives[0].pos),"survey does not expose the entire expanded world")
 check(s.command("route",{"point":Vector2(640,2140)}),"expanded goal can be replaced and retains history")
 var snap=s.snapshot();var r=Sim.new();check(r.restore(snap) and r.snapshot()==snap,"expanded region and earned fog restore without migration")
 s.paused=false;r.paused=false;s.advance(0.2);r.advance(0.2)
 check(s.snapshot()==r.snapshot(),"expanded route history and active local survey advance identically after restore")
 var malformed=snap.duplicate(true);malformed.mission.world_size=Vector2(INF,2400)
 check(not Sim.valid_snapshot(malformed),"nonfinite bounds cannot allocate a grid")
 malformed=snap.duplicate(true);malformed.mission.world_size=Vector2(20000,24000)
 check(not Sim.valid_snapshot(malformed),"oversized bounds cannot allocate a grid")
 malformed=snap.duplicate(true);malformed.known[Vector2i(50,60)]=true
 check(not Sim.valid_snapshot(malformed),"expanded fog cells must lie within authored region")
 print("EXPANDED REGION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
