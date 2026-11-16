extends SceneTree
class PublicOperation:
 extends RefCounted
 var selected=0
 var units=[{"name":"QUIETUS","pos":Vector2(1830,1080),"vel":Vector2.ZERO}]
 var sites=[{"site_id":"warning_transmission","name":"WARNING TRANSMISSION SECTOR","pos":Vector2(500,1120),"kind":"transmitter","own_origin":true,"origin_region":Rect2(300,1000,2200,700),"duration":6.,"captured":false}]
 var clock={"unit":-1,"target":-1,"duration":0.,"elapsed":0.}
 var readings=[]
 var operations=[{"site_id":"warning_transmission","action":"TRANSMIT","unit":0,"duration":6.,"optional":false,"repeatable":true,"completed":false,"emission":{"radius":2000.,"duration":8.,"label":"WARNING CHAIN TRANSMISSION"}}]
 func observable_sites():return sites.duplicate(true)
 func operation_context():return {"gates":[],"transmission_region":Rect2(300,1000,2200,700),"operations":operations.duplicate(true)}
 func capture_feedback():return clock.duplicate()
 func camera_context():return {"ready":true,"target":0}
 func signal_readings():return readings.duplicate(true)
 func equipment_feedback():return {"fitted":{}}
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var view=load("res://src/presentation/operation_instruments.gd")
 check(view!=null,"public operation instrument adapter exists")
 if view==null:finish();return
 var sim=PublicOperation.new();var before=sim.sites.duplicate(true)
 var action=view.action(sim)
 check(action.label=="TRANSMIT" and action.enabled and "6s" in action.detail and "actual" in action.detail,"known sector offers real own-origin six-second transmission")
 check(not action.has("point") and not action.has("route"),"transmit context cannot steer Quietus toward a fake anchor")
 check(view.phase(sim)=="UNSENT","charted transmission site is not a received or decoded signal")
 sim.clock={"unit":0,"target":0,"duration":6.,"elapsed":2.}
 check("2.0 / 6s" in view.action(sim).detail and view.phase(sim)=="TRANSMITTING","active transmitter uses own effective capture clock")
 sim.clock={"unit":-1,"target":-1,"duration":0.,"elapsed":0.};sim.sites[0].captured=true;sim.operations[0].completed=true;sim.operations[0]["last_completed"]={"pos":Vector2(1830,1080),"time":.5,"age":.5}
 check(view.phase(sim)=="SENT","completed sending without an earned arrival never claims a reply")
 sim.readings=[{"receiver":0,"origin":Vector2(1830,1080),"direction":Vector2.UP,"time":1.,"age":.1,"uncertainty":.65,"label":"UNRESOLVED CARRIER"}]
 check(view.phase(sim)=="RECEIVED","only actual public measurement changes status to received")
 check(sim.sites[0].pos==before[0].pos,"view never moves a chart badge to manufacture an exact transmission anchor")
 sim.sites=[{"site_id":"witness_sluice","name":"SERVICE SLUICE CONTROL","pos":Vector2(1780,2040),"kind":"receiver","completion_open_structure":"witness_service_sluice","duration":4.,"captured":false,"completion_emission":{"radius":1100.,"duration":8.,"label":"SERVICE SLUICE MOTOR"}}]
 sim.operations=[{"site_id":"witness_sluice","action":"ACTUATE","unit":0,"duration":4.,"optional":true,"repeatable":false,"completed":false,"emission":{"radius":1100.,"duration":8.,"label":"SERVICE SLUICE MOTOR"}}]
 action=view.action(sim)
 check(action.label=="ACTUATE" and "optional" in action.detail.to_lower() and "audible" in action.detail.to_lower(),"known actuator describes voluntary machinery exposure rather than camera reception")
 finish()
func finish():print("RESOLUTION INSTRUMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
