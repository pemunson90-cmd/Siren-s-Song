extends SceneTree
# WP-166 (Pat, 16 Nov 2026): rock the game told the player about stays on the chart they see; a leg through water a depth's chart
# holds neither as clear nor as rock is flagged (the guard bar then asks first). Only the told rock is added, one cell.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 told_point_and_leg()
 uncharted_depth()
 send_anyway_once()
 print("TOLD ROCK CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func told_point_and_leg():
 var s=Sim.new();s.start(16);s.sirens=[];s._use_band(1)
 var chart=s.terrain_chart
 check(chart!=null,"Furnace Drift uses the earned chart")
 var shape:PackedVector2Array=s.rock_shapes[0]
 var edge:Vector2=(shape[0]+shape[1])*.5
 var cell:=Vector2i((edge/chart.TILE).floor())
 chart.return_cells.erase(cell)
 var before:int=chart.return_cells.size()
 check(s.tell_rock(0,"point",edge),"a refused point names its rock")
 check(chart.return_cells.has(cell),"the refused point's rock cell is on the chart")
 check(chart.return_cells.size()==before+1,"only one cell is added")
 check(s.public_chart().return_cells.has(cell),"the public chart (what is drawn) holds it")
 check(not s.tell_rock(0,"point",edge),"telling the same rock again adds nothing")
 # A blocked leg: the first rock it meets.
 var other:Vector2=(shape[1]+shape[2])*.5
 var away:Vector2=other+(other-shape[0]).normalized()*0.0
 var centre:=Vector2.ZERO
 for p in shape:centre+=p
 centre/=shape.size()
 var out:Vector2=other+(other-centre).normalized()*70.0
 var seen:Vector2i=Vector2i((other/chart.TILE).floor())
 chart.return_cells.erase(seen)
 var told:bool=s.tell_rock(0,"leg",out,centre)
 check(told or chart.return_cells.size()>before,"a blocked leg names the rock it meets")
 var water:Vector2=Vector2(3000,3000)
 check(not s.tell_rock(0,"point",water),"open water far from rock tells nothing")
func uncharted_depth():
 var s=Sim.new();s.start(16);s.sirens=[]
 var q=s.units[0]
 check(not s.leg_uncharted(0,q.pos,q.pos+Vector2(400,0)),"the middle depth never warns")
 check(not s.depth_uncharted(0,1),"the middle depth is never uncharted")
 var deep=s.depth_charts.get(2)
 check(deep!=null,"the deep depth has its own chart")
 if deep==null:return
 q.band=2;s._use_band(2)
 check(s.leg_uncharted(0,q.pos,q.pos+Vector2(500,0)),"a long leg at the deep depth crosses uncharted water")
 check(not deep.leg_uncharted(q.pos,q.pos),"the launch spot is charted at the deep depth")
# WP-167: once the player has chosen SEND ANYWAY into uncharted water at a depth, later route taps at that depth do not ask again (this dive).
class Host:
 var sim
 func _order(_name,_args):pass
 func _refresh():pass
func send_anyway_once():
 var s=Sim.new();s.start(16);s.sirens=[]
 var q=s.units[0];q.band=2;s._use_band(2)
 var h=Host.new();h.sim=s
 var guard=preload("res://src/presentation/order_guard.gd").new();guard.host=h
 var far:Vector2=q.pos+Vector2(500,0)
 check(guard.leg_uncharted(far,false),"the first deep leg into uncharted water asks")
 guard.pending={"unit":0,"point":far,"append":false,"uncharted":true,"band":2}
 guard.confirm() # SEND ANYWAY
 check(not guard.leg_uncharted(far,false),"after SEND ANYWAY at deep, a deep leg does not ask again")
 check(not guard.uncharted_ok.has(0),"the shallow depth has not been chosen")
 guard.reset()
 check(guard.leg_uncharted(far,false),"a new dive asks again")
 guard.free()
