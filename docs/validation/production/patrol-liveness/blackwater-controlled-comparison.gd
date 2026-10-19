extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const Routes=preload("res://tests/campaign_scenarios.gd")
func _initialize():
 for variant in ["simple","east","east_decoy","east_cruise"]:
  var s=Simulation.new(); s.start(2,"disruption")
  s.units[1].alive=false; s.units[2].alive=false
  var ok=Routes.move(s,Vector2(760,410))
  if ok: s.command("camera")
  for n in 45: s.advance(0.1)
  var first_hull=s.hull; var first_emp=s.tools.emp
  if "decoy" in variant:s.command("decoy")
  if "cruise" in variant:s.command("silent")
  ok=Routes.move(s,Vector2(1150,480) if variant=="simple" else Vector2(1430,600))
  if "cruise" in variant:s.command("silent")
  if ok:s.command("camera")
  for n in 45:s.advance(0.1)
  var second_hull=s.hull
  if s.all_records():
   var home=Routes.move(s,s.mission.extraction)
   if not home and s.outcome.is_empty():
    print("REPLAN stopped=",s.units[0].pos," t=",s.elapsed," msg=",s.message)
    Routes.move(s,Vector2(1430,900))
    Routes.move(s,s.mission.extraction)
  print("BLACKWATER ",variant," outcome=",s.outcome," t=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1)," phases=",first_hull,",",second_hull," EMP_first=",first_emp," tools=",s.tools," pos=",s.units[0].pos," vel=",s.units[0].vel," route=",s.units[0].route," hold=",s.units[0].hold," captures=",s.mission.objectives.map(func(o):return o.captured)," message=",s.message)
 quit()
