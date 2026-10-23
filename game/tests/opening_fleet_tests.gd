extends SceneTree
# Source-known opening and forced-impact fixtures isolate friendly hulls from AI.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 for operation in 6:
  var s=Sim.new();s.start(operation);s.sirens=[]
  for id in 3:
   s._use_band(s.units[id].band)
   check(not s.blocked(s.units[id].pos,12),"opening%d craft%d starts clear of terrain"%[operation,id])
  s._use_band(s.units[0].band)
  var goal=s.units[0].pos+Vector2(320,0)
  check(s.command("route",{"point":goal}),"opening%d accepts the first eastward route"%operation)
  s.paused=false
  for n in 600:s.advance(Sim.STEP)
  check(s.hull==100.0 and s.units.all(func(u):return u.alive),"opening%d eastward route does not strike an own craft"%operation)
  print("OPENING ",operation," hull=",s.hull," pos=",s.units[0].pos," message=",s.message)
 # Recreate the old spawn alignment deliberately: damage must remain real and
 # the message must identify the friendly hull instead of hiding its cause.
 var forced=Sim.new();forced.start(0);forced.sirens=[]
 forced.units[2].pos=forced.units[0].pos+Vector2(140,0)
 forced.command("route",{"point":forced.units[0].pos+Vector2(320,0)});forced.paused=false
 var impacts=[]
 for n in 600:
  forced.advance(Sim.STEP)
  if forced.message.begins_with("Hull strike") and not forced.message in impacts:impacts.append(forced.message)
 check(absf(forced.hull-86.5012016296387)<.000001,"forced friendly impact preserves the measured pre-fix damage")
 check(forced.hull<100.0 and not impacts.is_empty(),"forced friendly impact retains physical hull damage")
 check(impacts.all(func(message):return "DRONE B" in message),"every friendly strike identifies Drone B")
 print("FORCED OPENING hull=",forced.hull," impacts=",impacts)
 print("OPENING FLEET CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
