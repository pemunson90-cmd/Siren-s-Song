extends SceneTree
const Feedback=preload("res://src/presentation/contact_feedback.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(value:bool,label:String):
 checks+=1
 if not value:failures+=1
 print("CONTACT_ADVERSARIAL ","PASS " if value else "FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(4)
 var c={2:{"time":0.0,"pos":Vector2(220,800),"mode":"LOCKING","lock":2.0,"target":0,"type":"hunter"}}
 check(Feedback.entries(c,0.299,s.units)[0].urgent,"fresh age below0.3 retains clear live target")
 check(not Feedback.entries(c,0.3,s.units)[0].urgent,"age exactly0.3 suppresses beam")
 check(Feedback.entries(c,0.3,s.units)[0].text=="S3 HUNTER · LAST SEEN 0s","threshold uses explicit historical age")
 check(Feedback.entries(c,20.0,s.units).size()==1,"memory retained at exact20s boundary")
 check(Feedback.entries(c,20.0001,s.units).is_empty(),"memory expires above20s")
 for target in [-1,3,100]:
  c[2].target=target
  check(not Feedback.entries(c,0,s.units)[0].urgent,"invalid own target%d cannot become urgent"%target)
 c[2].target=1;s.units[1].alive=false
 check(not Feedback.entries(c,0,s.units)[0].urgent,"dead own target cannot become urgent")
 c[2].target=0
 check(not Feedback.entries(c,0,s.units,func(_a,_b):return false)[0].urgent,"blocked current line suppresses urgent target")
 var before=var_to_bytes(c)
 var rows=Feedback.entries(c,0,s.units);rows[0].text="CHANGED";rows[0].pos=Vector2.ZERO
 check(var_to_bytes(c)==before,"returned value mutation leaves observation source unchanged")
 c[0]=c[2].duplicate(true);c[0].lock=0;c[0].mode="INVESTIGATE";c[0].type="patroller"
 c[1]=c[2].duplicate(true);c[1].time=-5;c[1].type="sentinel"
 rows=Feedback.entries(c,0,s.units)
 check(rows[0].urgent and rows[0].tag=="S3","urgent priority survives insertion order and stale role coexistence")
 check(rows[1].tag=="S1" and rows[2].text=="S2 GUARD · LAST SEEN 5s","nonurgent ordering and last-observed role remain stable")
 print("CONTACT_ADVERSARIAL checks=",checks," failures=",failures);quit(1 if failures else 0)
