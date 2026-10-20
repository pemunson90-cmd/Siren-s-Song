extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const World=preload("res://src/simulation/world_region.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func make(item="",drone="",index=0):
 var sim=Sim.new();sim.start(index,"disruption",{"fitted":{"quietus":item,"drone_a":drone,"drone_b":""}});return sim
func run(sim,count):
 sim.paused=false
 var peak=0.0
 for tick in count:sim.advance(Sim.STEP);peak=maxf(peak,sim.units[0].vel.length())
 return peak
func _initialize():
 var probe=Sim.new()
 if not probe.has_method("passive_range"):check(false,"general hardware reaches actual simulation systems")
 else:
  var bare=make();var vector=make("quietus_vector_drive")
  for sim in [bare,vector]:sim.command("silent");sim.command("route",{"point":Vector2(140,300)})
  var bare_peak=run(bare,300);var vector_peak=run(vector,300)
  check(vector_peak>bare_peak+20 and vector.units[0].pos.y<bare.units[0].pos.y-30,"vector drive changes real cruise speed and traversal")
  vector.command("silent");run(vector,120)
  check(vector.units[0].vel.length()<43,"vector drive preserves ordinary42m/s silent mode after braking")
  var loud=make();var quiet=make("quietus_baffles")
  for sim in [loud,quiet]:sim.units[0].vel=Vector2(78,0);sim.sirens[0].pos=Vector2(500,800)
  check(not loud._heard_arrival(loud.sirens[0]).is_empty() and quiet._heard_arrival(quiet.sirens[0]).is_empty(),"baffles alter real Siren motion hearing at the same speed")
  check(is_equal_approx(quiet.acoustic_feedback().motion[0].radius,loud.acoustic_feedback().motion[0].radius*.55),"public motion footprint uses actual baffled hearing")
  var survey=make("","drone_survey_array");var ordinary=make()
  check(survey.visible(Vector2(140,300)) and not ordinary.visible(Vector2(140,300)) and 1 in survey.passive_receivers(Vector2(140,300)),"array sees ordinary clear water beyond bare drone reach")
  check(survey.known.has(Vector2i(3,7)) and not ordinary.known.has(Vector2i(3,7)),"array earns farther ordinary chart knowledge")
  var regional=make("","drone_survey_array",8);var regional_bare=make("","",8)
  check(regional.known.size()>regional_bare.known.size(),"larger-region observation candidates respect upgraded range")
  var cells=make("","drone_deep_cells");var battery=make();run(cells,120);run(battery,120)
  check(is_equal_approx(100-cells.units[1].battery,(100-battery.units[1].battery)*.5) and cells.units[2].battery==battery.units[2].battery,"deep cells halve real fitted-drone depletion only")
  var fit={"quietus":"quietus_vector_drive","drone_a":"drone_survey_array","drone_b":"drone_deep_cells"}
  var active=Sim.new();active.start(6,"disruption",{"fitted":fit});fit.quietus="";active.command("silent");active.command("route",{"point":active.units[0].pos+Vector2(100,-200)});run(active,47);active.paused=true
  var restored=Sim.new();check(restored.restore(active.snapshot()),"current active upgrade fitting restores into fresh simulation")
  check(restored.mission.launch_equipment.quietus=="quietus_vector_drive" and restored.passive_range(1)==460 and restored.mission.launch_equipment.drone_b=="drone_deep_cells","launch freezes real fitted capabilities across save/reload")
 print("CRAFT UPGRADE SIM CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
