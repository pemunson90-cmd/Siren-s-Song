extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")

var trace:Array=[]
func _initialize():call_deferred("run")
func protect(s):
 var selected=s.selected
 for contact in s.contacts.values():
  if s.elapsed-contact.time<0.3 and contact.lock>1 and s.tools.emp>0:
   var target=int(contact.get("target",-1))
   if target>=0 and s.units[target].alive:s.command("select",{"unit":target});s.command("emp");s.command("select",{"unit":selected});break
func advance(s,seconds:float,defend:bool=true):
 for n in roundi(seconds*10):
  s.advance(0.1)
  if defend:protect(s)
func travel(s,id:int,destination:Vector2)->bool:
 if not s.units[id].alive or not s.command("select",{"unit":id}) or not s.command("route",{"point":destination}):return false
 s.paused=false
 for n in 1800:
  advance(s,0.1)
  if not s.outcome.is_empty() or not s.units[id].alive:return false
  if s.units[id].pos.distance_to(destination)<20 and s.units[id].vel.length()<2:return true
  if s.units[id].route.is_empty() and s.units[id].vel.length()<2:return false
 return false
func setup()->Dictionary:
 var s=Sim.new();s.start(3,"disruption")
 s.command("route",{"point":Vector2(740,800)});s.command("select",{"unit":2});s.command("route",{"point":Vector2(860,840)})
 var reached=travel(s,1,Vector2(1000,540))
 if reached:s.command("select",{"unit":1});s.command("camera");advance(s,4.5)
 s.command("select",{"unit":1})
 if s.units[1].alive:
  s.command("route",{"point":Vector2(860,540)});s.command("queue");s.command("route",{"point":Vector2(860,840)});s.command("queue")
 s.command("select",{"unit":2});s.paused=true
 print("ORDINARY_FURNACE reached=",reached," captured=",s.mission.objectives[0].captured," time=",s.elapsed," hull=",s.hull," tools=",s.tools," alive=",s.units.map(func(u):return u.alive)," positions=",s.units.map(func(u):return u.pos))
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-earned.snapshot",FileAccess.WRITE);f.store_var(s.snapshot());f.close()
 return s.snapshot()
func sample(s,relative:float)->Dictionary:
 var own=[]
 for u in s.units:own.append({"pos":u.pos,"speed":u.vel.length(),"alive":u.alive,"route":u.route.size(),"hold":u.hold})
 var fresh=s.contacts.values().filter(func(c):return s.elapsed-c.time<0.3)
 return {"relative":relative,"time":s.elapsed,"hull":s.hull,"emp":s.tools.emp,"own":own,"fresh_contacts":fresh.size(),"observed_lock":fresh.any(func(c):return c.lock>0),"records":s.mission.objectives.map(func(o):return o.captured),"message":s.message,"outcome":s.outcome}
func episode(initial:Dictionary,thermal:bool,idle:bool,defend:bool,wait_seconds:float=0.0)->Dictionary:
 var s=Sim.new();assert(s.restore(initial));trace=[]
 var accepted=true
 if not idle and wait_seconds==0:accepted=s.command("route",{"point":Vector2(1110,830)})
 s.paused=false;var camera_attempted=false;var exposure=false;var withdrew=false
 for n in 250+roundi(wait_seconds*10):
  if not idle and wait_seconds>0 and n==roundi(wait_seconds*10):
   s.command("select",{"unit":2});accepted=s.command("route",{"point":Vector2(1110,830)})
  s.advance(0.1)
  if defend and not idle:protect(s)
  if not idle and n>=roundi(wait_seconds*10) and s.units[2].alive:
   var u=s.units[2]
   if not camera_attempted and u.pos.distance_to(Vector2(1110,830))<20 and u.vel.length()<2:
    s.command("select",{"unit":2});camera_attempted=true;exposure=s.command("camera")
   if s.mission.objectives[1].captured and not withdrew:
    s.command("select",{"unit":2});s.command("route",{"point":Vector2(1040,880)});withdrew=true
  trace.append(sample(s,(n+1)*0.1))
  if not s.outcome.is_empty():break
 var result={"thermal":thermal,"idle":idle,"defend":defend,"accepted":accepted,"exposure":exposure,"withdrew":withdrew,"initial_sha":var_to_bytes(initial).hex_encode().sha256_text(),"final":sample(s,s.elapsed-initial.elapsed),"trace":trace}
 var name=("thermal" if thermal else "baseline")+("-idle" if idle else "-emp" if defend else "-noemp")+("-wait12" if wait_seconds>0 else "")
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/thermal-product-probe/"+name+".json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
 print("ENV_RESULT ",name," ",JSON.stringify(result.final)," exposure=",exposure," withdraw=",withdrew)
 return result
func run():
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-qualified.snapshot",FileAccess.READ);var initial=f.get_var();f.close()
 var candidate="--candidate" in OS.get_cmdline_user_args()
 episode(initial,candidate,false,true);episode(initial,candidate,false,false);episode(initial,candidate,true,false);episode(initial,candidate,false,true,12.0)
 quit()
