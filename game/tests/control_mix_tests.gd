extends SceneTree
# R5 (RULING_TESTS.md; Pat 2026-10-30 on one-press travel: "They are fine for
# testing but they will absolutely have to be stripped for release play").
# The share of movement done by one-press travel is a number. With dev state
# off the one-press orders do not exist and every counter stays zero; a dev run
# that uses them counts their distance; the counters never change the voyage.
const Sim=preload("res://src/simulation/simulation.gd")
const Release=preload("res://src/presentation/release_controls.gd")
var checks=0
var failures=0
var Mix=null
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 # Voyage first: runs on code without the telemetry module too.
 var plain=voyage(false,false)
 print("CONTROL MIX VOYAGE HASH ",plain)
 Mix=load("res://src/debug/control_mix.gd")
 check(Mix!=null,"control_mix telemetry module exists")
 if Mix!=null:
  check(voyage(false,true)==plain,"tagged orders and counter reads leave the dev voyage unchanged")
  check(voyage(true,true)==voyage(true,false),"tagged orders and counter reads leave the release voyage unchanged")
  kinds()
  release_zero()
  dev_counts()
  live_route_here()
  call_sites()
  debrief_row()
 print("CONTROL MIX CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)

static func open_point(s,from:Vector2,reach:float)->Vector2:
 for turn in 16:
  var p=from+Vector2.from_angle(TAU*turn/16.)*reach
  if Rect2(Vector2(60,60),s.world_size()-Vector2(120,120)).has_point(p) and not s.blocked(p,30) and s.line_clear(from,p):return p
 return from

static func fresh(release:bool):
 var s=Sim.new();s.start(0);s.sirens=[];s.mission["dev"]=not release;s.paused=false
 return s

func run_for(s,seconds:float,read:bool)->void:
 for n in int(seconds/Sim.STEP):
  s.advance(Sim.STEP)
  if read and Mix!=null and n%30==0:Mix.totals(s)

# One scripted voyage: one-press route, placed leg, emergency, drone recall.
func voyage(release:bool,tagged:bool)->int:
 var s=fresh(release);var q=s.units[0]
 var a=open_point(s,q.pos,160.)
 s.command("route",{"point":a,"travel":"route_here"} if tagged else {"point":a})
 run_for(s,6.,tagged)
 s.command("route",{"point":open_point(s,q.pos,140.),"travel":"water_leg"} if tagged else {"point":open_point(s,q.pos,140.)})
 run_for(s,6.,tagged)
 s.command("emergency",{"point":open_point(s,q.pos,120.)})
 run_for(s,6.,tagged)
 s.command("select",{"unit":1});s.command("recall")
 run_for(s,6.,tagged)
 var state=[]
 for u in s.units:state.append([u.pos.snapped(Vector2(.001,.001)),u.vel.snapped(Vector2(.001,.001)),u.alive,u.band,u.route.size()])
 return hash(var_to_str(state))

func kinds():
 check(Mix.kind("route",{"point":Vector2.ZERO})=="planned","untagged route is a planned leg")
 for key in Release.TRAVEL_SHORTCUTS:
  var expect="one_press" if Release.TRAVEL_SHORTCUTS[key].dev_only else "planned"
  check(Mix.kind("route",{"travel":key})==expect,"TRAVEL:%s counts as %s"%[key,expect])
 check(Mix.kind("emergency",{})=="emergency" and Mix.kind("recall",{})=="recall" and Mix.kind("recall_all",{})=="recall","emergency and recall kinds")

func release_zero():
 var s=fresh(true);var q=s.units[0]
 check(s.command("route",{"point":open_point(s,q.pos,160.),"travel":"route_here"}),"release accepts a placed route")
 run_for(s,8.,false)
 s.command("emergency",{"point":open_point(s,q.pos,120.)})
 run_for(s,6.,false)
 var t=Mix.totals(s)
 check(t.one_press==0.0 and t.planned==0.0 and t.emergency==0.0 and t.recall==0.0,"dev off: every counter zero "+str(t))
 check(Mix.one_press_share(s)==0.0,"dev off: one-press share zero")
 check(not s.has_meta(Mix.META),"dev off: no telemetry state on the simulation")
 check(not var_to_str(s.snapshot()).contains("one_press"),"dev off: snapshot carries no counter")

func dev_counts():
 var s=fresh(false);var q=s.units[0];var start=q.pos
 var a=open_point(s,q.pos,160.)
 check(s.command("route",{"point":a,"travel":"route_here"}),"dev one-press route accepted")
 run_for(s,12.,false)
 var t=Mix.totals(s)
 check(t.one_press>0.0,"dev one-press route counts distance "+str(t))
 check(t.one_press<=start.distance_to(a)*2.+1.,"one-press count bounded by its path")
 check(t.planned==0.0 and t.emergency==0.0 and t.recall==0.0,"only the one-press kind moved")
 var before=t.one_press
 check(s.command("route",{"point":open_point(s,q.pos,140.),"travel":"water_leg"}),"dev placed leg accepted")
 run_for(s,12.,false)
 t=Mix.totals(s)
 check(t.planned>0.0 and is_equal_approx(t.one_press,before),"placed leg counts as planned only "+str(t))
 s.command("emergency",{"point":open_point(s,q.pos,120.)})
 run_for(s,10.,false)
 check(Mix.totals(s).emergency>0.0,"emergency counts")
 var d=s.units[1];d.pos=open_point(s,q.pos,180.)
 s.command("select",{"unit":1})
 if s.command("recall"):
  run_for(s,12.,false)
  check(Mix.totals(s).recall>0.0,"recall counts")
 else:check(false,"dev recall accepted: "+s.message)
 var share=Mix.one_press_share(s)
 check(share>0.0 and share<1.0,"one-press share is a fraction of all movement %.3f"%share)
 # A replaced one-press leg keeps only what was covered.
 var r=fresh(false);var rq=r.units[0];var origin:Vector2=rq.pos;var far=open_point(r,origin,300.)
 r.command("route",{"point":far,"travel":"route_here"});run_for(r,2.,false)
 var moved=origin.distance_to(rq.pos)
 r.command("route",{"point":origin,"travel":"water_leg"})
 var t2=Mix.totals(r)
 check(moved>0.0 and t2.one_press>=moved*.9 and t2.one_press<origin.distance_to(far),"replaced one-press leg credits partial progress %.1f of %.1f moved"%[t2.one_press,moved])

# Stand-in for main: the HUD's live ROUTE HERE press reaches the simulation
# through host._order exactly as in play.
class Host extends Node:
 var sim=null
 var orders=[]
 func _order(order:String,args:Dictionary={})->void:orders.append([order,args]);sim.command(order,args)
 func _refresh()->void:pass
class Hud extends RefCounted:
 var host=null
 var subject={}

func live_route_here():
 var s=fresh(false);var q=s.units[0];var host=Host.new();host.sim=s;host.set_meta("dev_profile",true)
 var hud=Hud.new();hud.host=host;hud.subject={"kind":"chart","pos":open_point(s,q.pos,160.)}
 preload("res://src/presentation/truthful_commands.gd").route(hud,"route_here")
 check(host.orders.size()==1 and host.orders[0][1].get("travel","")=="route_here","live ROUTE HERE press tags its order "+str(host.orders))
 run_for(s,10.,false)
 var t=Mix.totals(s)
 check(t.one_press>0.0 and t.planned==0.0,"live ROUTE HERE press counts as one-press "+str(t))
 host.free()

# Every presentation one-press call (a dev-only TRAVEL key) passes its key to
# the order, so live play is attributed; placed legs may stay untagged.
static func untagged_one_press(text:String,file:String)->Array:
 var problems=[];var call=RegEx.create_from_string("_order\\(\\s*\"route\"");var tag=RegEx.create_from_string("TRAVEL:([a-z_]+)")
 var lines=text.split("\n")
 for n in lines.size():
  if call.search(lines[n])==null:continue
  for m in tag.search_all(lines[n]):
   var key=m.get_string(1)
   if Release.TRAVEL_SHORTCUTS.get(key,{}).get("dev_only",false) and not ("\"travel\":\"%s\""%key in lines[n] or "\"travel\":key" in lines[n]):problems.append("%s:%d TRAVEL:%s order lacks its travel key"%[file,n+1,key])
 return problems

func call_sites():
 check(untagged_one_press('host._order("route",{"point":p}) # TRAVEL:route_here',"bad").size()==1,"guard catches an untagged one-press call")
 check(untagged_one_press('host._order("route",{"point":p,"travel":"route_here"}) # TRAVEL:route_here',"good").is_empty(),"guard passes a tagged one-press call")
 check(untagged_one_press('host._order("route",{"point":p}) # TRAVEL:water_leg',"leg").is_empty(),"guard leaves placed legs alone")
 var problems=[];var seen=0
 for file in preload("res://tests/release_controls_tests.gd").source_files("res://src"):
  var text=FileAccess.get_file_as_string(file)
  if text.contains("_order(\"route\""):seen+=1
  problems.append_array(untagged_one_press(text,file))
 check(seen>=4,"call-site scan reached the presentation sources (%d files)"%seen)
 check(problems.is_empty(),"every one-press call passes its travel key "+str(problems))

# The debrief prints one SS_CONTROL_MIX row for critic logs, dev or not.
func debrief_row():
 var s=fresh(false);var q=s.units[0]
 s.command("route",{"point":open_point(s,q.pos,160.),"travel":"withdraw_home"});run_for(s,8.,false)
 var row=Mix.report(s)
 check(row.dev and row.one_press_share==1.0 and row.one_press>0.0,"dev report row carries the one-press share "+str(row))
 var r=fresh(true);var host=Host.new();host.sim=r
 check(not load("res://src/debug/dev_state.gd").block_debrief(host),"release debrief is not blocked")
 check(r.has_meta("control_mix_reported") and Mix.report(r).one_press_share==0.0,"release debrief logged a zero share row")
 host.free()
