extends SceneTree
# WP-57: the damage record names every hull loss, the dive that began damaged, and where to repair;
# the Career board puts each rider under its own contract and shows the same rider every visit.
const Sim=preload("res://src/simulation/simulation.gd")
const Log=preload("res://src/presentation/damage_log/damage_log.gd")
const Board=preload("res://src/presentation/career/career_board.gd")
const State=preload("res://src/campaign/career/career_state.gd")
const Economy=preload("res://src/campaign/economy.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var s=Sim.new();s.start(0);s.paused=false
 var log=Log.new();log.bind(s)
 # A dive that begins damaged (condition carried from an earlier dive) says so.
 s.hull=60.;log.sample()
 s.elapsed+=1.;log.sample()
 check(log.summary().contains("began at Hull 60%"),"a dive that began damaged says so")
 # A Siren beam kill names the beam.
 s.elapsed+=1.;s.hull=0.;s.outcome="lost";s.message=Sim.VAPORIZED_TEXT;log.sample()
 check(log.summary().contains("· a Siren beam"),"beam loss names the beam")
 # A beam kill is named from the finished lock, even after a rider's message replaced the beam message.
 var bs=Sim.new();bs.start(0);bs.paused=false
 var beam=Log.new();beam.bind(bs)
 bs.elapsed+=1.;bs.hull=0.;bs.outcome="lost";bs.message="RIDER FAILED · a launched craft was lost · base contract continues"
 bs.contacts={0:{"pos":bs.units[0].pos+Vector2(0,-200),"time":bs.elapsed,"mode":"BEAM","target":0,"type":"sweeper","source":"optical"}}
 beam.sample()
 check(beam.summary().contains("· a Siren beam") and not beam.summary().contains("does not record"),"beam loss is named from the lock, not the message")
 # The recorded hull differs from the hull at the end of a dive: one line says why.
 var f=Economy.new_state();f.cond.quietus=Economy.preset(f).floor
 var host=_host(f);host.sim=bs
 check(Log.floor_line(host)=="Quietus came home at 0%% and is recorded at %d%%, the lowest this difficulty records after a loss."%Economy.preset(f).floor,"the floor is explained: "+Log.floor_line(host))
 bs.hull=Economy.preset(f).floor;check(Log.floor_line(host)=="","no floor line when the hull ended at the recorded value")
 # A loss with no recorded source says so instead of guessing.
 var t=Sim.new();t.start(0);t.paused=false
 var other=Log.new();other.bind(t)
 t.elapsed+=1.;t.hull=70.;other.sample()
 check(other.summary().contains("a cause the game does not record"),"unknown loss says it is not recorded")
 # A Warden field around Quietus is named.
 var w=Sim.new();w.start(0);w.paused=false
 var field=Log.new();field.bind(w)
 w.sirens=[{"type":"warden","industry":{"patches":[{"pos":w.units[0].pos,"radius":85.}],"hit":[],"phase":"idle"}}]
 w.elapsed+=1.;w.hull=90.;field.sample()
 check(field.summary().contains("a Warden pressure field"),"pressure field loss names the field")
 # Repair line: standard preset, damaged hull; accessible preset mends by itself.
 var e=Economy.new_state();e.cond.quietus=60
 check(Log.repair_line(_host(e)).contains("REPAIR QUIETUS HULL"),"damaged hull points to the repair")
 e.cond.quietus=100
 check(Log.repair_line(_host(e))=="","a whole hull needs no repair line")
 # Career board: each rider line names its own contract, and the same contract keeps its rider.
 var career=State.new_career()
 var a=State.rider_offer(career,"brannock_watch");var b=State.rider_offer(career,"brannock_watch")
 check(a==b,"the same contract shows the same rider on every view")
 check(Board.rider_line("Brannock Watch",a).begins_with("OPTIONAL RIDER FOR BRANNOCK WATCH · "),"rider line names its contract")
 for node in [log,other,field,beam]:node.free()
 print("CAREER RECORD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
class FakeHost:
 var economy
 var sim
func _host(e):
 var h=FakeHost.new();h.economy=e;return h
