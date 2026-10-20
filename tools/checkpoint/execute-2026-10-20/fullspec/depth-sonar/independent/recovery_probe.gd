extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 for op in Sim.Missions.Catalog.registered_ids():
  var s=Sim.new();s.start(op,"endurance",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}})
  for c in s.extraction_corridors():
   for dx in range(-60,61,10):
    for dy in range(-60,61,10):
     var p=c.pos+Vector2(dx,dy)
     if p.distance_to(c.pos)>=65 or not s.Depth.clear(s,p,p,1,12) or not s.Depth.clear(s,p,c.pos,1):continue
     for band in [0,2]:
      if s.Depth.clear(s,p,c.pos,band):continue
      s.units[0].pos=c.pos;s.units[1].pos=p;s.units[2].band=band
      s.command("select",{"unit":0});var a=s.ModuleRecovery.departure(s,c)
      s.command("select",{"unit":2});var b=s.ModuleRecovery.departure(s,c)
      print("MISMATCH op=",op," corridor=",c.pos," drone=",p," selected_band=",band," base=",a," peer=",b)
      quit();return
 print("NO AUTHORED MISMATCH")
 quit()
