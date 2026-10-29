extends "res://src/simulation/simulation.gd"
# Test-only witness: the permanent SILENT counterexample records received craft
# warnings, never unattended cargo locks or hidden enemy lock state.
var continuous_silent=true
var hunt_peak=0.
var received_locks=0
var received_lock_episodes=0
var observed_locking={}
var received_lock_peak=0.
var receiving={}
var ordinary_bare=false
var ordinary_commands=true
func command(order:String,args:Dictionary={})->bool:
 if ordinary_bare and order not in ["route","depth","choir_action"]:
  ordinary_commands=false
  return false
 return super.command(order,args)
func advance(dt:float)->void:
 continuous_silent=continuous_silent and units[0].silent
 super.advance(dt)
 continuous_silent=continuous_silent and units[0].silent
 hunt_peak=maxf(hunt_peak,float(mission.get("reconnaissance",{}).get("hunt",0.)))
 var current={}
 for id in contacts:
  var c=contacts[id]
  if elapsed-float(c.time)>.4:continue
  # A stale-report gap cannot create a new episode. Re-arm only after received
  # evidence of zero lock or another target; the first positive report is real.
  var locked=c.get("target",-1)==0 and float(c.get("lock",0.))>0.
  if locked:
   received_lock_peak=maxf(received_lock_peak,float(c.lock))
   if not observed_locking.get(id,false):received_lock_episodes+=1
  observed_locking[id]=locked
  if locked:
   current[id]=true
   if not receiving.has(id):received_locks+=1
 receiving=current
