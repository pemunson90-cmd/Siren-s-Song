extends SceneTree
# Staged observation-cost regression. Certified cells remain known; new water still needs sight.
class Probe extends "res://src/simulation/simulation.gd":
 var probes=[]
 func visible(point:Vector2,band:int=1)->bool:
  probes.append(point);return super.visible(point,band)
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Probe.new();s.start(0)
 var before=s.snapshot();var known=s.known.duplicate();s.probes=[]
 s._observe()
 check(not known.is_empty(),"the fixture has actually observed water")
 check(s.snapshot()==before,"a repeated paused observation preserves the complete simulation state")
 var repeats=0
 for point in s.probes:
  if known.get(Vector2i(point/s.TILE),false)==true:repeats+=1
 check(repeats==0,"already certified water performs no redundant sight queries")
 check(not s.probes.is_empty(),"unobserved cells still perform ordinary visibility checks")
 var cell=known.keys()[0];s.known[cell]=false
 s._observe()
 check(s.known[cell]==true,"a false entry is still evaluated and becomes known when visible")
 var previous=s.tools.recon
 check(s.command("recon") and s.tools.recon==previous-1,"active survey still uses the ordinary finite tool path")
 check(s.known.size()>=known.size(),"survey preserves previously earned cells")
 print("KNOWN WATER CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
