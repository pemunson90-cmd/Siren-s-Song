extends SceneTree
const R=preload("res://src/campaign/encounters/roster.gd")
const EnemyTypes=preload("res://src/simulation/enemy_types.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var g=R.guard("patroller",Vector2(10,20),2,[Vector2(1,1),Vector2(2,2)])
 check(g.pos==Vector2(10,20) and g.home==g.pos and g.goal==g.pos,"guard starts at home with goal on its position")
 check(g.type=="patroller" and g.band==2 and g.mode=="PATROL" and g.target==-1,"guard keeps type, band and idle patrol state")
 check(g.stun==0.0 and g.lock==0.0 and g.suspicion==0.0 and g.route.is_empty(),"guard starts calm with no route")
 # Defaults and copy semantics.
 var d=R.guard("buoy",Vector2.ZERO)
 check(d.band==1 and d.patrol_points.is_empty() and d.patrol_index==0,"guard defaults to MIDDLE with no patrol points")
 var pts=[Vector2(5,5)]
 var c=R.guard("patroller",Vector2.ZERO,1,pts)
 pts.append(Vector2(9,9))
 check(c.patrol_points.size()==1,"patrol points are copied, not shared with the caller")
 var e=R.guard("sentinel",Vector2.ZERO,1,[],{"tether":99.0,"band":0})
 check(e.tether==99.0 and e.band==0,"extra keys add and override base keys")
 var a=R.guard("hunter",Vector2(3,3));var b=R.guard("hunter",Vector2(3,3))
 check(a==b,"guard is deterministic for equal arguments")
 a.route.append(1)
 check(b.route.is_empty(),"each guard owns its own route array")
 # add() assigns the index into the mission siren list.
 var m={"sirens":[R.guard("warden",Vector2.ZERO)]}
 R.add(m,[R.guard("buoy",Vector2(1,1)),R.guard("relay",Vector2(2,2))])
 check(m.sirens.size()==3 and m.sirens[1].patrol==1 and m.sirens[2].patrol==2,"add appends and numbers patrol by list position")
 var empty={"sirens":[]}
 R.add(empty,[])
 check(empty.sirens.is_empty(),"adding an empty list changes nothing")
 # listening line: one buoy per gap plus one relay.
 var gaps=[Vector2(100,0),Vector2(200,0),Vector2(300,0)]
 var line=R.listening_line(gaps,Vector2(50,50),0)
 check(line.size()==4 and line.slice(0,3).all(func(x):return x.type=="buoy"),"listening line has a buoy per gap")
 check(line[3].type=="relay" and line[3].pos==Vector2(50,50) and line.all(func(x):return x.band==0),"relay sits behind the buoys on the same band")
 check(R.listening_line([],Vector2.ZERO).size()==1,"no gaps still yields the relay")
 # post: tethered sentinel with a three-point patrol triangle.
 var p=R.post(Vector2(100,100),1,200.0)
 check(p.type=="sentinel" and p.tether==200.0 and p.patrol_points.size()==3 and p.patrol_points[0]==p.pos,"post is a tethered sentinel anchored on its position")
 check(R.post(Vector2.ZERO).tether==170.0,"post tether defaults to 170")
 # Every role the roster builders use is a known shared role name.
 for t in ["buoy","relay","sentinel","patroller","interceptor","warden"]:check(t in EnemyTypes.ALL,"role %s is a shared enemy type"%t)
 check(EnemyTypes.SWEEPER in EnemyTypes.ALL and EnemyTypes.ALL.size()==8,"enemy type list holds eight roles including the sweeper")
 var seen={}
 for t in EnemyTypes.ALL:seen[t]=true
 check(seen.size()==EnemyTypes.ALL.size(),"enemy type names are unique")
 print("ROSTER CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
