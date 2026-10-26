extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Table=preload("res://src/presentation/status_text/status_table.gd")
const MODULE="res://src/presentation/status_text/status_text.gd"
const FALLBACK="No exact source located · listen from another position or spend local RECON"
const EXPECTED={
 6:"SOURCE SEARCH · listen elsewhere or spend local RECON",
 9:"RETURN RECEIVER · listen elsewhere or spend local RECON",
 11:"CONFLUENCE SIGNALS · listen elsewhere or spend local RECON",
 22:"FREIGHT SLED · use CHOIR WORK at the berth and lane gates",
 24:"BALLAST · CHOIR WORK offers BYPASS or ISOLATE",
 27:"COUNTERWEIGHT · CHOIR WORK tracks its tow, lock and cradle",
 28:"OCCUPIED BELL · CHOIR WORK handles tow, locks and landing",
 29:"SECURITY FEED · CHOIR WORK offers LOCK C / RECONNECT or DISMANTLE"
}
class PublicView:
 extends RefCounted
 var mission={"id":22,"phase":"work"}
 var actions={"lock_a":{"ready":false,"reason":"Reach within60m through clear local water"}}
 var corridors=[]
 func choir_context()->Dictionary:return {"actions":actions.duplicate(true)}
 func extraction_corridors()->Array:return corridors.duplicate(true)
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:
 var status=load(MODULE)
 check(status!=null,"status text module loads")
 if status==null:finish();return
 for id in EXPECTED:
  var sim=Sim.new();sim.start(id,"endurance")
  var context_before:Dictionary=sim.camera_context().duplicate(true)
  var message_before:String=sim.message
  var snapshot_before=sim.snapshot()
  check(context_before.text==FALLBACK,"operation %d original camera fallback"%id)
  check(status.present(sim,FALLBACK)==EXPECTED[id],"operation %d authored public intent"%id)
  var composite:String="DEPTH 2 · "+FALLBACK+" · QUEUE 0"
  check(status.present(sim,composite)=="DEPTH 2 · "+EXPECTED[id]+" · QUEUE 0","operation %d composite retains surrounding text"%id)
  Table.enabled=false
  check(status.present(sim,composite)==composite,"operation %d off switch preserves original text"%id)
  Table.enabled=true
  check(status.present(sim,"other telemetry · RECON") == "other telemetry · RECON","operation %d unrelated text byte equal"%id)
  check(sim.message==message_before and sim.camera_context()==context_before and sim.snapshot()==snapshot_before,"operation %d pure presentation"%id)
  sim.command("select",{"unit":0})
  var selected_message:String=sim.message
  var selected_context:Dictionary=sim.camera_context().duplicate(true)
  var selected_snapshot=sim.snapshot()
  status.present(sim,selected_context.text)
  Table.enabled=false
  status.present(sim,selected_context.text)
  Table.enabled=true
  check(sim.message==selected_message and sim.camera_context()==selected_context and sim.snapshot()==selected_snapshot,"operation %d selected context and message stay byte equal with module on/off"%id)
 var view=PublicView.new()
 check(status.present(view,FALLBACK)==EXPECTED[22],"public work context selects the operation line")
 view.mission.phase="recovery"
 view.corridors=[{"available":true,"name":"CHOIR SOUTH RECOVERY"}]
 check(status.present(view,FALLBACK)=="RECOVERY READY · bring Quietus to an available corridor","public available corridor takes priority over persistent work actions")
 view.corridors=[{"available":false}]
 check(status.present(view,FALLBACK)==EXPECTED[22],"phase alone cannot claim an unavailable recovery corridor")
 view.actions={}
 check(status.present(view,FALLBACK)=="CHOIR WORK · inspect known local job or recovery route","no public work action avoids a false source search")
 Table.enabled=false
 check(status.present(view,FALLBACK)==FALLBACK,"progression lines respect off switch")
 Table.enabled=true
 for id in [0,7]:
  var sim=Sim.new();sim.start(id,"endurance")
  var context:Dictionary=sim.camera_context()
  check(context.text!=FALLBACK,"control operation %d takes a distinct context branch"%id)
  check(status.present(sim,context.text)==context.text,"control operation %d unchanged"%id)
  check(status.present(sim,"PREFIX · "+FALLBACK)=="PREFIX · "+FALLBACK,"control operation %d fallback token still unchanged"%id)
 var unknown=Sim.new();unknown.start(1,"endurance")
 check(status.present(unknown,FALLBACK)==FALLBACK,"unknown operation does not invent guidance")
 check(status.arrivals_label(0)=="ARRIVALS\n0 signals","zero arrivals compact label")
 check(status.arrivals_label(2)=="ARRIVALS\n2 signals","received arrivals compact label")
 check(status.arrivals_hint(0)=="ARRIVALS: no signals received yet","zero arrivals explained")
 check(status.arrivals_hint(2)=="2 signals received; tap ARRIVALS to read","received arrivals explained")
 Table.enabled=false
 check(status.arrivals_label(2)=="ARRIVALS\n2" and status.arrivals_hint(2).is_empty(),"arrivals off switch restores old presentation")
 Table.enabled=true
 finish()
func finish()->void:
 print("STATUS TEXT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
