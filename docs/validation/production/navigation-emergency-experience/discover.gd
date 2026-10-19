extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var configs=[{"mission":0,"point":Vector2(780,360)},{"mission":0,"point":Vector2(730,550)},{"mission":2,"point":Vector2(1180,550)},{"mission":4,"point":Vector2(760,720)},{"mission":4,"point":Vector2(820,520)}]
 for config_id in configs.size():
  var config=configs[config_id];var s=Sim.new();s.start(config.mission,"disruption");s.command("silent");var accepted=s.command("route",{"point":config.point});s.paused=false
  var found=false;var observed=false
  for n in 600:
   s.advance(0.1)
   var live=[]
   for key in s.contacts:
    var c=s.contacts[key]
    if s.elapsed-c.time<0.3:
     live.append({"id":key,"lock":c.lock,"mode":c.mode,"pos":c.pos});observed=true
   if not live.is_empty() and s.units[0].vel.length()>10 and s.blocked(s.units[0].pos,70):
    print("CANDIDATE config=",config_id," mission=",config.mission," time=",s.elapsed," pos=",s.units[0].pos," vel=",s.units[0].vel," heading=",s.units[0].angle," contacts=",live," hull=",s.hull)
    var f=FileAccess.open("/workspace/Siren-s-Song-gauntlet/work/navigation-emergency-experience/candidate-%d.bin"%config_id,FileAccess.WRITE);f.store_var(s.snapshot());f.close();found=true;break
   if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
  print("DISCOVERY config=",config_id," accepted=",accepted," found=",found," ever_observed=",observed," elapsed=",s.elapsed," pos=",s.units[0].pos," hull=",s.hull," tools=",s.tools," outcome=",s.outcome," message=",s.message)
 quit()
