extends SceneTree
const C=preload("res://src/campaign/encounters/choir_rules.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func st(done:Array=[],route:String="west")->Dictionary:
 var sites=[]
 for id in ["lock_a","lock_b","lock_c","cradle","land","reconnect"]:sites.append({"id":id,"done":id in done,"pos":Vector2(100,100)})
 return {"sites":sites,"route_choice":route,"stamp":-1.0,"sealed":false,"choice":"","jobs":[],"seen":{},"load":{}}
func run():
 check(C.site(st(),"lock_b").id=="lock_b" and C.site(st(),"nope").is_empty(),"site finds by id and returns empty for unknown")
 # Prerequisite chains: 23 needs equalizers in order.
 check(C.needs_missing(23,st(),"lock_b")=="lock_a","lock_b waits on lock_a")
 check(C.needs_missing(23,st(["lock_a"]),"lock_b")=="","lock_b is free once lock_a is done")
 check(C.needs_missing(23,st(["lock_b"]),"lock_c")=="" and C.needs_missing(23,st(["lock_a"]),"lock_c")=="lock_b","lock_c needs lock_b only")
 check(C.needs_missing(23,st(),"lock_a")=="","an action with no needs is never blocked")
 check(C.needs_missing(99,st(),"lock_b")=="" and C.needs_missing(23,st(),"unknown")=="","unknown mission or action has no needs")
 check(C.needs_missing(28,st(["lock_b"]),"land")=="lock_a","28 land reports the first missing of lock_a, lock_b")
 check(C.needs_missing(28,st(["lock_a"]),"land")=="lock_b" and C.needs_missing(28,st(["lock_a","lock_b"]),"land")=="","28 land clears when both stations are done")
 check(C.needs_missing(29,st(),"reconnect")=="lock_c" and C.needs_missing(27,st(),"cradle")=="lock_a","29 and 27 each gate on their single site")
 # Every need and load names a real site id of the rows above.
 var ids=st().sites.map(func(s):return s.id)
 for mid in C.NEEDS:
  for action in C.NEEDS[mid]:
   check(action in ids and C.NEEDS[mid][action].all(func(n):return n in ids),"NEEDS %d %s names real sites"%[mid,action])
 # Freight jam at the closed lane gate (mission 22).
 var near={"state":"transit","pos":Vector2(130,100)}
 check(C.jam(22,st(),near)=="lock_a","west freight jams at lock_a within 70 m")
 check(C.jam(22,st([],"east"),near)=="lock_b","east lane uses lock_b")
 check(C.jam(22,st(["lock_a"]),near)=="","an opened gate does not jam")
 check(C.jam(22,st(),{"state":"transit","pos":Vector2(100,170)})=="","exactly 70 m away is clear of the jam")
 check(C.jam(22,st(),{"state":"transit","pos":Vector2(100,169.9)})=="lock_a","just inside 70 m jams")
 check(C.jam(22,st(),{"state":"free","pos":Vector2(100,100)})=="","only a transiting sled jams")
 check(C.jam(22,st([],"north"),near)=="" and C.jam(25,st(),near)=="","unknown route or mission never jams")
 # Escort rule (mission 25 only).
 var sim={"mission":{"id":25},"units":[{"alive":true,"pos":Vector2(0,0)}]}
 var load={"pos":Vector2(200,0)}
 check(C.escorted(sim,load),"a craft exactly at ESCORT metres counts as escorting")
 load.pos=Vector2(200.5,0)
 check(not C.escorted(sim,load),"just beyond the escort radius holds the sled")
 sim.units[0].alive=false
 check(not C.escorted({"mission":{"id":25},"units":[{"alive":false,"pos":Vector2.ZERO}]},{"pos":Vector2.ZERO}),"a dead craft cannot escort")
 check(C.escorted({"mission":{"id":22},"units":[]},load),"missions without an escort rule are always escorted")
 # Slide: early exits leave the load untouched.
 var s27={"mission":{"id":27}}
 var free={"state":"free","pos":Vector2(10,10)}
 C.slide({"mission":{"id":22}},st(),free,1.0)
 C.slide(s27,st(),{"state":"carried","pos":Vector2(10,10)},1.0)
 C.slide(s27,st(["lock_a"]),free,1.0)
 check(free.pos==Vector2(10,10),"no slide with no rule, a carried load, or a chocked load above the ledge")
 var low={"state":"free","pos":Vector2(10,1750)}
 C.slide(s27,st(),low,1.0)
 check(low.pos==Vector2(10,1750),"the slide stops at y 1750")
 # Window drop-out (mission 29): breaker falls after WINDOW unless a reconnect is in flight.
 var s29={"mission":{"id":29},"elapsed":250.0,"message":""}
 var w=st(["lock_c"]);w.stamp=50.0
 C.tick_state(s29,w)
 check(w.stamp==-1.0 and not C.site(w,"lock_c").done and s29.message.begins_with("Far breaker dropped"),"expired window re-opens lock_c")
 var w2=st(["lock_c"]);w2.stamp=50.0;w2.jobs=[{"action":"reconnect"}]
 C.tick_state(s29,w2)
 check(w2.stamp==50.0 and C.site(w2,"lock_c").done,"a reconnect in flight holds the breaker")
 var w3=st(["lock_c"]);w3.stamp=50.0
 C.tick_state({"mission":{"id":29},"elapsed":200.0,"message":""},w3)
 check(w3.stamp==50.0,"exactly WINDOW seconds elapsed does not yet drop the breaker")
 # Notes text.
 var n26=st();n26.stamp=0.0
 check(C.notes({"mission":{"id":26},"elapsed":30.0},n26)=="HAMMER RESTARTED · west mouth seals in 70s","surge note counts down from the delay")
 n26.sealed=true
 check(C.notes({"mission":{"id":26},"elapsed":30.0},n26).begins_with("WEST MOUTH SEALED"),"sealed note wins over the countdown")
 var n29=st();n29.stamp=100.0
 check(C.notes({"mission":{"id":29},"elapsed":110.0},n29)=="FAR BREAKER HELD · 140s to RECONNECT","window note counts down from WINDOW")
 check(C.notes({"mission":{"id":29},"elapsed":9999.0},n29)=="FAR BREAKER HELD · 0s to RECONNECT","countdown clamps at zero")
 check(C.notes({"mission":{"id":23},"elapsed":0.0},st())=="","missions without notes say nothing")
 print("CHOIR RULES CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
