extends SceneTree
var checks=0
var failures=0
class DrawSpy extends RefCounted:
 var calls=[]
 func draw_rect(rect,color,filled=true,width=1.):calls.append(["rect",rect,color,filled,width])
 func draw_line(a,b,color,width=1.,antialiased=false):calls.append(["line",a,b,color,width])
class PublicOnly extends RefCounted:
 var hidden_rocks=[]
 var chart_reads=0
 var chart={"revision":1,"cell_size":40.,"clear_cells":[Vector2i(1,2)],"return_cells":[Vector2i(2,2)],"surface_segments":[PackedVector2Array([Vector2(80,80),Vector2(80,100)])]}
 func public_chart()->Dictionary:
  chart_reads+=1;return chart.duplicate(true)
 func course_segments(_id:int=-1)->Array:return [{"from":Vector2(40,100),"to":Vector2(60,100),"confirmed":true},{"from":Vector2(60,100),"to":Vector2(100,100),"confirmed":false}]
 func delivery_context():return {"handoff_pos":Vector2(2100,300),"handoff_sector":Rect2(1880,80,440,440),"withdrawal_pos":Vector2(300,2700),"handoff_complete":false,"return_available":false,"recovered":false}
 func course_status(_id):return {"state":"blocked","reason":"New terrain — replot","clear_distance":0.}
class ChartSim extends "res://src/simulation/simulation.gd":
 var hidden_reads=0
 func public_chart()->Dictionary:return {"revision":1,"cell_size":40.,"clear_cells":[Vector2i(1,2)],"return_cells":[Vector2i(2,2)],"surface_segments":[PackedVector2Array([Vector2(80,80),Vector2(80,100)])]}
 func course_segments(_id:int=-1)->Array:return []
 func course_status(_id:int=-1)->Dictionary:return {"state":"tentative","reason":"Unsurveyed course","clear_distance":10.}
 func blocked(point:Vector2,margin:float=0.)->bool:
  hidden_reads+=1;return super.blocked(point,margin)
class OceanProbe extends "res://src/presentation/ocean_view.gd":
 var hidden_rocks=0
 func _rock(_rect:Rect2)->void:hidden_rocks+=1
func check(ok:bool,message:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+message)
func _initialize():call_deferred("run")
func run():
 var path="res://src/presentation/earned_chart_view.gd"
 if not ResourceLoader.exists(path):
  check(false,"earned chart public-only world/planner renderer exists");finish();return
 var view=load(path);var sim=PublicOnly.new();var original=sim.chart.duplicate(true)
 var spy=DrawSpy.new();view.draw_terrain(spy,view.chart(sim),1.)
 check(spy.calls.size()==3,"one certified-water field plus two exact observed face strokes")
 check(spy.calls[0][0]=="rect" and spy.calls[0][1]==Rect2(40,80,40,40) and spy.calls[0][3],"CLEAR is a filled knowledge field")
 check(spy.calls.slice(1).all(func(c):return c[0]=="line" and c[1]==Vector2(80,80) and c[2]==Vector2(80,100)),"physical face never extends to RETURN cell edge or hidden backside")
 sim.hidden_rocks=[Rect2(0,0,900,900)];var other=DrawSpy.new();view.draw_terrain(other,view.chart(sim),1.)
 check(spy.calls==other.calls,"same public chart produces same terrain despite different hidden geometry")
 check(sim.chart==original,"rendering retains chart without earning samples")
 var routes=DrawSpy.new();view.draw_course(routes,view.segments(sim,0),1.,true)
 check(routes.calls.any(func(c):return c[3]==view.CONFIRMED),"confirmed course has distinct solid style")
 check(routes.calls.filter(func(c):return c[3]==view.TENTATIVE).size()>1,"tentative course has broken amber style")
 var reads=sim.chart_reads
 check(view.status(sim,0).contains("REPLOT"),"new terrain stop explains retained route and explicit replot")
 check(sim.chart_reads==reads,"ship status reads lightweight course DTO without copying entire chart per frame")
 check(view.chart(RefCounted.new()).is_empty(),"legacy without chart getter retains original world path")
 if not view.has_method("objective"):
  check(false,"public navigation objective and charted-coordinate context exist");finish();return
 check(view.objective(sim).contains("HANDOFF") and not view.objective(sim).contains("0/0"),"navigation objective replaces empty record count")
 var context=view.goal_context(sim,Vector2(2100,300))
 check(context.get("subkind","")=="corridor" and context.pos==Vector2(2100,300),"announced handoff is observational route context, not CAMERA machinery")
 check(view.context_detail(sim,context).contains("terrain"),"briefed coordinate does not imply surveyed approach")
 var real=ChartSim.new();real.start(0);real.known={Vector2i(1,2):true}
 var ocean=OceanProbe.new();ocean.sim=real;ocean.size=Vector2(800,500);root.add_child(ocean)
 var preview=load("res://src/presentation/route_program_preview.gd").new();preview.sim=real;preview.size=Vector2(600,300);root.add_child(preview)
 real.hidden_reads=0
 await process_frame;await process_frame
 check(ocean.hidden_rocks==0,"Ocean earned chart never renders full authored rocks")
 check(real.hidden_reads==0,"planner earned chart never classifies known cells with hidden blocked()")
 ocean.queue_free();preview.queue_free();await process_frame
 finish()
func finish():print("EARNED CHART VIEW CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
