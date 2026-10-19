extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.READ);var earned=f.get_var();f.close()
 for point in [Vector2(420,580),Vector2(420,720),Vector2(760,720)]:
  for tool in [false,true]:
   var s=Sim.new();assert(s.restore(earned));var start_hash=var_to_bytes(s.snapshot()).hex_encode().sha256_text();var emergency=s.command("emergency",{"point":point});var emp=s.command("emp") if tool else false;s.paused=false;var stopped=false
   for n in 160:
    s.advance(0.1)
    if "unsafe terrain" in s.message:stopped=true
   var fresh=[]
   for key in s.contacts:
    if s.elapsed-s.contacts[key].time<0.3:fresh.append({"id":key,"mode":s.contacts[key].mode,"lock":s.contacts[key].lock,"pos":s.contacts[key].pos})
   print("EMERGENCY point=",point," tool=",tool," accepted=",emergency," emp=",emp," same_initial=",start_hash," time=",s.elapsed," pos=",s.units[0].pos," speed=",s.units[0].vel.length()," hull=",s.hull," tools=",s.tools," terrain_stop=",stopped," outcome=",s.outcome," fresh=",fresh," message=",s.message)
 quit()
