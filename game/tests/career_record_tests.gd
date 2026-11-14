extends SceneTree
# WP-57: the damage record names every hull loss, the dive that began damaged, and where to repair;
# the Career board puts each rider under its own contract and shows the same rider every visit.
const Sim=preload("res://src/simulation/simulation.gd")
const Log=preload("res://src/presentation/damage_log/damage_log.gd")
const Board=preload("res://src/presentation/career/career_board.gd")
const State=preload("res://src/campaign/career/career_state.gd")
const Economy=preload("res://src/campaign/economy.gd")
const LossSummary=preload("res://src/presentation/loss_summary.gd")
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
 check(Log.floor_line(host)==Log.FLOOR_LINE_LOST%[0,Economy.preset(f).floor],"the floor is explained: "+Log.floor_line(host))
 check(not Log.floor_line(host).contains("came home") and Log.floor_line(host).contains("was lost"),"a lost Quietus is not said to have come home")
 bs.outcome="won";check(Log.floor_line(host).begins_with("Quietus came home at 0%"),"a recovered Quietus came home")
 bs.outcome="lost"
 bs.hull=Economy.preset(f).floor;check(Log.floor_line(host)=="","no floor line when the hull ended at the recorded value")
 # A Sweeper's finished lock is named from the Siren that holds the fired beam, with no fresh contact and no beam message.
 var sw=Sim.new();sw.start(0);sw.paused=false
 var sweep=Log.new();sweep.bind(sw)
 sw.sirens=[{"type":"sweeper","mode":"BEAM","target":0,"pos":sw.units[0].pos+Vector2(0,-200)}]
 sw.elapsed+=86.;sw.hull=0.;sw.outcome="lost";sw.message="RIDER FAILED · a launched craft was lost";sw.contacts={}
 sweep.sample()
 check(sweep.summary().contains("-100% to 0% · a Sweeper's beam") and sweep.summary().contains("01:26") and not sweep.summary().contains("does not record"),"a Sweeper's lock is named with its attacker and time: "+sweep.summary())
 check(LossSummary.line(sw).begins_with("A Sweeper's beam") and not LossSummary.line(sw).contains("remaining hull"),"the loss line names the Sweeper: "+LossSummary.line(sw))
 # Pausing after damage does not rewrite where the dive began.
 var p=Sim.new();p.start(0);p.paused=false
 var paused=Log.new();paused.bind(p)
 p.elapsed+=10.;paused.sample()
 p.elapsed+=76.;p.hull=86.;paused.sample()
 paused.sample();paused.sample()
 check(not paused.summary().contains("began at Hull") and paused.start_hull==100.,"a pause after damage keeps the start at full hull: "+paused.summary())
 p.hull=70.;paused.sample()
 check(paused.summary().contains("QUIETUS HULL -30% OBSERVED"),"hull lost while paused is still recorded: "+paused.summary())
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
 # WP-92: after a dive the result says the earnings once, in the ledger's "Earned:" line; the board keeps them in its own lines.
 var Text=preload("res://src/presentation/mode_result_text.gd")
 var report="BRANNOCK WATCH · RECOVERED\nSTANDING +2 → 5 · CONTRACT PAY 40 FUEL + 10 SALVAGE\nSALVAGE RECOVERED · 3 SCRAP\nRIDER PASSED · BONUS 5 FUEL"
 var full="\n".join(Text.career_lines(report))
 check(full.contains("Contract pay:") and full.contains("Salvage:") and full.contains("Bonus:"),"the board lists pay, salvage and bonus: "+full)
 var once="\n".join(Text.career_lines(report,false))
 check(once.contains("Standing up 3, now 5") or once.contains("Standing up"),"the dive result keeps the standing change: "+once)
 check(not once.contains("Contract pay") and not once.contains("Salvage:") and not once.contains("Bonus:") and once.contains("Rider passed."),"the dive result leaves the amounts to Earned: "+once)
 check(Text.career_earned(report).contains("contract pay") and Text.career_earned(report).contains("salvage") and Text.career_earned(report).contains("rider bonus"),"Earned: holds pay, salvage and bonus: "+Text.career_earned(report))
 for node in [log,other,field,beam,sweep,paused]:node.free()
 print("CAREER RECORD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
class FakeHost:
 var economy
 var sim
func _host(e):
 var h=FakeHost.new();h.economy=e;return h
