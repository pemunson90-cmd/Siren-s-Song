extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func fixture():
 var s=Sim.new();s.start(2);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 s.units[0].pos=Vector2(900,840);s.units[1].alive=false;s.units[2].alive=false
 s.sirens=[s.sirens[0]];var e=s.sirens[0]
 e.pos=Vector2(1060,840);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.;e.lock=0.;e.target=-1
 s.contacts={};s.known={};return s
func _initialize():
 var s=fixture();var e=s.sirens[0]
 check(not s.visible(e.pos),"dark water keeps an unobserved patrol outside passive range")
 e.target=0;e.lock=1.
 check(s.contact_visible(e),"actual charging emission on our hull is observable in dark water")
 s._observe()
 check(s.contacts.has(0) and s.passive_receivers(e.pos).is_empty(),"beam warning is fresh without inventing passive receiver provenance")
 e.target=-1
 check(not s.contact_visible(e),"decaying lock without an owned target grants no emission")
 e.target=0;e.stun=1.
 check(not s.contact_visible(e),"disrupted attacker grants no beam emission")
 e.stun=0.;s.mission.structures=[Rect2(970,800,20,100)];s._build_navigation()
 check(not s.contact_visible(e),"physical cover blocks emission observation")
 s=fixture();s.mission.darkness=false;s.units[0].silent=false;e=s.sirens[0];e.pos=Vector2(1170,840);e.target=0;e.lock=1.
 check(not s.visible(e.pos) and s.contact_visible(e),"cruise-range beam emission remains visible outside ordinary passive reach")
 s=fixture();e=s.sirens[0];e.pos=Vector2(1100,840);e.target=0;e.lock=1.;e.alert_floor=.24
 check(s.contact_visible(e),"earned hostile readiness range shares the same observable charge rule")
 e.pos=Vector2(1300,840)
 check(not s.contact_visible(e),"an out-of-range retained lock grants no remote observation")
 s=fixture();s.paused=false;var first_warning=-1.;var first_damage=-1.
 for n in 300:
  var old=s.hull;s.advance(1./60.)
  if first_warning<0 and s.contacts.has(0) and s.contacts[0].lock>0:first_warning=s.elapsed
  if first_damage<0 and s.hull<old:first_damage=s.elapsed
 check(first_damage>0,"unbroken ordinary dark-water encounter reaches actual hull damage")
 check(first_warning>=0 and first_damage-first_warning>3.5,"actual sensor pulses expose the charge before hull damage")
 print("BEAM EMISSION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
