extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var out:FileAccess
var s
var sequence=0
func _initialize():call_deferred("run")
func sample(label:String):
 var snap=s.snapshot()
 var digest=HashingContext.new();digest.start(HashingContext.HASH_SHA256);digest.update(var_to_bytes(snap))
 var msg=s.message.replace("Decoy transmitting · 15 seconds","DECOY_EVENT").replace("Decoy launched · 15s transmission","DECOY_EVENT")
 out.store_line(JSON.stringify({"sequence":sequence,"label":label,"state_sha256":digest.finish().hex_encode(),"elapsed":s.elapsed,"hull":s.hull,"outcome":s.outcome,"message_normalized":msg,"events":s.events,"accumulator":s.accumulator,"sensor_clock":s.sensor_clock,"contacts":s.contacts,"noises":s.noises,"tools":s.tools,"selected":s.selected,"queue":s.queue_mode,"pass":s.pass_through}));sequence+=1
func order(name:String,args:Dictionary={}):
 var ok=s.command(name,args);sample("order:%s:%s:%s"%[name,str(args),ok]);return ok
func advance(n:int):
 for i in n:
  s.advance(0.1)
  if i%5==0:sample("step")
 sample("step-end")
func move(point:Vector2):
 if not order("route",{"point":point}):return false
 s.paused=false
 for i in 2600:
  s.advance(0.1)
  if i%5==0:sample("moving")
  if not s.outcome.is_empty():return false
  if s.units[0].pos.distance_to(point)<20 and s.units[0].vel.length()<2:sample("arrived");return true
  if s.units[0].route.is_empty() and s.units[0].vel.length()<2:return false
 return false
func run():
 var dest=""
 for a in OS.get_cmdline_user_args():
  if a.begins_with("--out="):dest=a.trim_prefix("--out=")
 out=FileAccess.open(dest,FileAccess.WRITE)
 for mission in 6:
  s=Sim.new();s.start(mission);sample("mission-start:%d"%mission)
  order("decoy",{"point":Vector2(800,850)})
  s.paused=false;advance(160)
  s.paused=true;sample("paused-before");advance(50)
  var r=Sim.new();r.restore(bytes_to_var(var_to_bytes(s.snapshot())));s=r;sample("restored")
  order("select",{"unit":1});order("queue");order("route",{"point":Vector2(300,750)})
  order("contact_hold");order("emergency",{"point":Vector2(400,800)});order("select",{"unit":0})
  order("ping");s.paused=false;advance(20)
 s=Sim.new();s.start(4);sample("well-response-start");move(Vector2(600,600));order("decoy",{"point":Vector2(800,850)});advance(220)
 s=Sim.new();s.start(4);sample("well-lock-start");move(Vector2(800,800));order("decoy",{"point":Vector2(1100,650)})
 for n in 4*60:
  s.advance(1.0/60)
  if n%10==0:sample("lock-wait")
  if s.contacts.values().any(func(c):return s.elapsed-c.time<0.3 and c.lock>0.5):break
 order("decoy",{"point":Vector2(1100,650)});advance(160)
 out.close();print("REGRESSION_REPLAY records=",sequence);quit()
