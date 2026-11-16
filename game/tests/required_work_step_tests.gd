extends SceneTree
# WP-176: Glass Reach and Iron Choir (operations 14-29) name the next unmet step of their work on the NEXT line, in the shut recovery
# mouth's reason, and (where a marker is on the chart) as the GOAL point; the work was only in the briefing before.
const Sim=preload("res://src/simulation/simulation.gd")
const NextStep=preload("res://src/presentation/next_step.gd")
const W=preload("res://src/presentation/hud_words.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
# Every required record filed, as the testers' state: "objectives" all captured, only the work remains.
func filed(id:int)->Object:
 var s=Sim.new();s.start(id)
 for o in s.mission.objectives:o.captured=true
 return s
func show(s,tag:String)->Dictionary:
 var step:Dictionary=NextStep.step(s)
 var why:String=s.corridor_blocked_reason(s.extraction_corridors()[0])
 print(tag," | NEXT: ",step.text," | site: ",step.site.get("pos","none")," | mouth: ",why)
 return step
func _init():
 var s=filed(15)
 var step=show(s,"15 Needle Strait, records filed")
 check(step.text==W.TEXT.next_work%W.TEXT.work_vane,"15: NEXT names the RELEASE VANE")
 check(step.site.get("pos",Vector2.ZERO)==s.mission.glass_reach.work_pos,"15: GOAL is the vane marker already on the chart")
 check(s.corridor_blocked_reason(s.extraction_corridors()[0]).contains("RELEASE VANE"),"15: the shut mouth names the vane")
 s.mission.glass_reach.choice="vane"
 check(s.required_work_step().is_empty() and s.all_records(),"15: once the vane is released nothing is left to name and the mouth opens")
 s=filed(18)
 step=show(s,"18 anchorage")
 check(step.text.contains("SERVICE or SEVER"),"18: NEXT names the anchorage choice")
 s=filed(17)
 step=show(s,"17 archive spindle")
 check(step.text.begins_with("NEXT: WINCH") or step.text.contains("WINCH"),"17: NEXT names the winch of the material")
 s=filed(22)
 step=show(s,"22 Hammerwake, start")
 check(step.text.contains("open LOCK A"),"22: first the lane gate LOCK A")
 check(s.corridor_blocked_reason(s.extraction_corridors()[0]).contains("LOCK A"),"22: the shut mouth names LOCK A")
 s.mission.iron_choir.sites[1].done=true
 step=show(s,"22 after LOCK A")
 check(step.text.contains("START WEST VOYAGE") and step.text.contains("RELEASE"),"22: then START WEST VOYAGE at RELEASE")
 s.mission.iron_choir.load.state="transit";s.mission.iron_choir.route_choice="west"
 step=show(s,"22 sled in transit")
 check(step.text.contains("wait for the FREIGHT SLED to arrive"),"22: the sled running free: wait for it")
 s.mission.iron_choir.arrived=true
 step=show(s,"22 sled at dock, not yet seen")
 check(step.text.contains("watch the FREIGHT SLED arrive"),"22: arrived but unconfirmed: watch it")
 s.mission.iron_choir.receipt=true
 check(s.required_work_step().is_empty(),"22: receipt in, nothing left")
 s=filed(23)
 step=show(s,"23 locks")
 check(step.text.contains("open LOCK A"),"23: LOCK A first")
 s.mission.iron_choir.sites[0].done=true
 check(s.required_work_step().text.contains("open LOCK B"),"23: then LOCK B")
 s.mission.iron_choir.sites[1].done=true
 check(s.required_work_step().text.contains("open LOCK C"),"23: then LOCK C")
 s.mission.iron_choir.sites[2].done=true
 check(s.required_work_step().is_empty(),"23: all three open, nothing left")
 s=filed(24)
 step=show(s,"24 ballast")
 check(step.text.contains("ATTACH the BALLAST") and step.text.contains("BYPASS or ISOLATE"),"24: attach and tow the ballast to BYPASS or ISOLATE")
 s.mission.iron_choir.load.state="towed";s.mission.iron_choir.load.carrier=0
 check(s.required_work_step().text.contains("tow the BALLAST to BYPASS or ISOLATE"),"24: towing: take it to BYPASS or ISOLATE")
 s=filed(26)
 step=show(s,"26 spindle")
 check(step.text.contains("WINCH"),"26: winch the spindle")
 s=filed(27)
 step=show(s,"27 counterweight")
 check(step.text.contains("LOCK A"),"27: LOCK A first")
 s=filed(28)
 step=show(s,"28 bell")
 check(step.text.contains("LOCK A"),"28: LOCK A first")
 s=filed(29)
 step=show(s,"29 split")
 check(step.text.contains("LOCK C") and step.text.contains("DISMANTLE"),"29: LOCK C then RECONNECT, or DISMANTLE")
 s.mission.iron_choir.sites[0].done=true
 check(s.required_work_step().text.contains("RECONNECT now"),"29: breaker thrown: RECONNECT now")
 s.mission.iron_choir.choice="reconnect"
 check(s.required_work_step().is_empty(),"29: choice made, nothing left")
 # A hidden material position is not given away: the unseen winch step carries no chart point.
 s=filed(26);s.units[0].pos=Vector2(80,80)
 step=NextStep.step(s)
 if not s.visible(s.mission.iron_choir.artifact.pos,s.mission.iron_choir.artifact.band):check(not step.site.has("pos"),"26: unseen spindle: no chart point named")
 # Operations without Reach or Choir work are untouched.
 s=Sim.new();s.start(1)
 check(s.required_work_step().is_empty(),"1: no Reach or Choir work to name")
 print("REQUIRED WORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
