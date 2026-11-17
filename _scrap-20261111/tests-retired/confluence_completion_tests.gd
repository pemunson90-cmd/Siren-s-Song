extends SceneTree
const Plan=preload("res://tests/confluence_command_plan.gd")
func _initialize():
 var failures=0
 for scenario in [["shelf","concealed",false],["deep","overt",true],["deep","concealed",false],["shelf","overt",false]]:
  var s=Plan.play(scenario[0],scenario[1],scenario[2])
  print("CONFLUENCE_TECHNICAL ",scenario," outcome=",s.outcome," t=",s.elapsed," oxygen=",s.oxygen," hull=",s.hull," tools=",s.tools," pos=",s.units[0].pos," facts=",s.mission.expedition_facts.keys())
  if s.outcome!="won" or s.mission.chosen_route!=scenario[1]:failures+=1
 print("CONFLUENCE COMPLETION CHECKS 4 FAILURES ",failures)
 quit(1 if failures else 0)
