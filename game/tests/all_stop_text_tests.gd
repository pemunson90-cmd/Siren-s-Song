extends SceneTree
# ALL STOP states both costs up front: the oxygen and the restart seconds, on the
# button and in the engage message. Values are read from the table, never fixed here.
const Sim=preload("res://src/simulation/simulation.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const Table=preload("res://src/simulation/all_stop/all_stop_table.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	var s=Sim.new();s.start(0,"endurance");s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	s.units[0].pos=Vector2(200,700);s.units[0].angle=0.0;s.units[0].silent=false
	s.command("route",{"point":Vector2(1000,700)})
	s.paused=false
	for n in 180:s.advance(1./60)
	var secs:String="%ds restart"%ceili(Table.RESTART_SECONDS)
	var oxy:String="%.1f%% O2"%Table.ENTRY_OXYGEN
	var lab:String=AllStop.label(s)
	check(lab.begins_with("ALL STOP"),"the button still reads ALL STOP")
	check(lab.contains(oxy),"the button names the oxygen cost: "+lab)
	check(lab.contains(secs),"the button names the restart seconds: "+lab)
	check(lab.split("\n").size()==2,"the button stays two lines")
	s.command("all_stop")
	check(s.message.contains("%.1f%% oxygen"%Table.ENTRY_OXYGEN),"the engage message names the oxygen cost: "+s.message)
	check(s.message.contains(secs),"the engage message names the restart seconds: "+s.message)
	print("ALL STOP TEXT CHECKS ",checks," FAILURES ",failures)
	quit()
