extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func length_of(route:Array,origin:Vector2)->float:
 var distance=0.0
 for node in route:distance+=origin.distance_to(node.pos);origin=node.pos
 return distance
func _initialize()->void:
 var s=Sim.new();s.start(11,"endurance",{"context":{"thread":"deep","completed":[9]}})
 check(s.mission.rocks.any(func(r):return r is PackedVector2Array),"Confluence physical terrain uses genuinely authored polygons")
 check(s.world_size().y>4000,"Confluence separates approach, discovery and return basins")
 check(s.sirens.map(func(e):return e.type).has("hunter") and s.sirens.map(func(e):return e.type).has("sentinel") and s.sirens.map(func(e):return e.type).has("patroller"),"both approaches face a mixed roster with different physical jobs")
 check(not s.line_clear(Vector2(1000,2200),Vector2(2700,2200)),"central basalt divides sight and direct approach")
 check(s.extraction_corridors().all(func(c):return c.pos.y>4000 and not c.available),"both choices require bringing the memory back through southern recovery")
 var gates=s.mission.get("physical_gates",[])
 check(gates.size()==1,"optional repeater controls one physical cross-island sluice")
 check(s.has_method("confluence_context"),"presentation receives a permitted local Confluence context")
 if s.has_method("confluence_context"):
  check(s.confluence_context().landmarks.is_empty() and s.confluence_context().gates.is_empty(),"unseen factory and service door stay out of presentation")
 check(s.mission.endurance.oxygen_seconds>=720,"ordinary solo reconnaissance has a substantial oxygen budget")
 if gates.is_empty():
  print("CONFLUENCE OPERATION CHECKS ",checks," FAILURES ",failures);quit(1);return
 var gate=gates[0]
 var west=Vector2(1050,2900);var east=Vector2(2680,2900)
 var closed=length_of(s.path(west,east),west)
 check(not s.line_clear(west,east),"closed service sluice really blocks cross-island sight")
 var repeater=s.mission.signal_sources.filter(func(source):return source.id=="confluence_repeater")[0]
 s.units[0].pos=repeater.pos;s.units[0].vel=Vector2.ZERO
 Consequences.observe(s,true)
 var sites=s.mission.objectives.filter(func(site):return site.site_id=="confluence_repeater")
 check(sites.size()==1 and sites[0].get("optional",false) and not sites[0].captured,"finding the old repeater offers an optional physical operation")
 if s.has_method("confluence_context"):
  check(s.confluence_context().gates.size()==1 and s.confluence_context().landmarks.is_empty(),"only actually discovered service machinery enters the chart")
 if sites.is_empty():
  print("CONFLUENCE OPERATION CHECKS ",checks," FAILURES ",failures);quit(1);return
 var site=sites[0]
 check(site.get("completion_open_structure","")==gate.id,"discovery and actuator share the actual door")
 # Earn the actual closed door face, then remove it through the same completion
 # hook used by quiet Quietus and an independently fitted noisy drone sampler.
 s.paused=false;s.units[0].pos=Vector2(2600,2900);s._terrain_observe()
 var before=s.public_chart().return_cells.size()
 check(before>0,"local receiver earns the actual closed service door face")
 site.captured=true;s._record_secured(site,0)
 check(gate.opened and not s.mission.structures.has(gate.closed_shape),"completing optional operation permanently opens physical passage")
 check(s.line_clear(west,east) and length_of(s.path(west,east),west)+900<closed,"service choice earns a materially shorter return across the divide")
 check(s.noises.any(func(n):return n.pos==site.pos and n.radius>=1100),"opening discloses the real actuator position through local sound")
 check(s.public_chart().return_cells.size()<before,"earned chart retires the removed door rather than preserving a phantom blocker")
 var restored=Sim.new()
 check(restored.restore(s.snapshot()),"current polygon operation and opened-door chart restore together")
 check(not restored.blocked(gate.closed_shape.get_center(),24),"restored open door remains physically navigable")
 var bad=s.snapshot();bad.mission.rocks[0]=PackedVector2Array([Vector2.ZERO,Vector2(NAN,1),Vector2.ONE])
 check(not Sim.valid_snapshot(bad),"invalid polygon points are rejected from current saves")
 var live=s.mission.signal_sources.filter(func(source):return source.id=="confluence_packet")[0]
 s.units[0].pos=live.pos;Consequences.observe(s,true)
 for objective in s.mission.objectives:
  if objective.site_id=="confluence_packet":objective.captured=true
 check(s.all_records(),"optional service machinery never replaces the live packet requirement")
 print("CONFLUENCE OPERATION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
