extends SceneTree
func _initialize():
 var Sim=load("res://src/simulation/simulation.gd")
 var s=Sim.new();s.start(0);s.mission.rocks=[Rect2(450,400,100,200)];s._build_navigation()
 s.units[0].pos=Vector2(300,500);s.units[1].pos=Vector2(900,300);s.units[2].pos=Vector2(140,800)
 var e=s.sirens[0];e.pos=Vector2(700,500);e.home=e.pos;e.goal=e.pos;e.type="hunter";e.route=[];e.vel=Vector2.ZERO
 s.command("ping");s.command("route",{"point":Vector2(300,800)});s.paused=false
 var trace=[]
 for n in 900:
  s.advance(1.0/60)
  if n%120==0:trace.append({"time":s.elapsed,"sub":s.units[0].pos,"siren":e.pos,"goal":e.goal,"mode":e.mode,"last_known":e.get("last_known",Vector2.ZERO),"fresh":s.contacts,"hull":s.hull})
 print(JSON.stringify({"fixture":"authored basalt island + initialpositions; ordinary SONAR and silent route away, no post-start hiddengoal or forcedreaction","trace":trace}))
 quit()
