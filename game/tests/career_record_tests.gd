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
 for node in [log,other,field]:node.free()
 print("CAREER RECORD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
class FakeHost:
 var economy
func _host(e):
 var h=FakeHost.new();h.economy=e;return h
