extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Roles=preload("res://src/simulation/sweeper_senses.gd")
const Fixtures=preload("res://tests/siren_role_scenarios.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 hearing_edges()
 search_and_memory()
 protected_rules()
 print("ROLE SENSES CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
func hearing_edges():
 # Same isolated legacy sound: only the wider ear hears the outer edge.
 for row in [["hunter",470.,true],["patroller",470.,false],["sentinel",470.,false],["hunter",440.,true],["patroller",440.,true],["sentinel",440.,false]]:
  var s=Fixtures.fixture(row[0]);var e=s.sirens[0]
  s._noise(e.pos-Vector2(row[1],0),450.,"TEST",1.)
  s._threats(.01)
  check((e.mode=="INVESTIGATE")==row[2],"%s hearing edge at %sm"%[row[0],row[1]])
 check(Roles.attention({"type":"hunter"})<Roles.attention({"type":"patroller"}),"hunter drops stale attention sooner")
 check(Roles.attention({"type":"sentinel"})>Roles.attention({"type":"patroller"}),"sentinel keeps stale attention longer")
func search_and_memory():
 for role in ["hunter","sentinel"]:
  var s=Fixtures.fixture(role);var e=s.sirens[0]
  e.pos=e.home+Vector2(40,0);e.goal=e.pos;e.last_known=e.pos;e.attention_time=5.;e.search_index=0;e.angle=0.
  var heard:Vector2=e.last_known;var origin:Vector2=e.pos
  s._station_intent(e,false,.5)
  if role=="sentinel":
   check(e.mode=="SEARCH" and e.goal==heard and e.route.is_empty() and e.angle>0.,"sentinel holds the reached station and turns")
  else:
   check(e.mode=="SEARCH" and e.goal.distance_to(heard)>80. and not e.route.is_empty(),"hunter sweeps around the last known source")
  check(e.pos==origin and e.last_known==heard,"%s search never teleports or reads the hidden craft"%role)
  s.paused=true;var saved=s.snapshot();var copy=Sim.new()
  check(Sim.valid_snapshot(saved) and copy.restore(saved),"%s active search restores with existing optional memory"%role)
  var frozen=copy.snapshot();copy.advance(1.)
  check(copy.snapshot()==frozen,"%s paused restore freezes attention and search"%role)
  var old=saved.duplicate(true)
  for field in ["attention_time","last_known","search_index"]:old.sirens[0].erase(field)
  check(copy.restore(old),"%s old save without search memory remains accepted"%role)
  e.attention_time=0.;s._station_intent(e,false,.1)
  check(e.goal==e.home and e.mode=="RETURN","%s returns to authored home when attention expires"%role)
func protected_rules():
 for role in ["hunter","sentinel"]:
  for silent in [true,false]:
   var s=Fixtures.fixture(role);var e=s.sirens[0];var radius=180. if silent else 290.
   s.units[0].silent=silent;s.units[0].pos=e.pos-Vector2(radius+1.,0)
   s._threats(.01)
   check(e.lock==0.,"%s preserves %sm sight boundary"%[role,radius])
   s.units[0].pos=e.pos-Vector2(radius-1.,0);s._threats(.01)
   check(e.lock>0. and s.hull==100.,"%s retains sight and fresh lock warning"%role)
 check(Roles.ear({"type":"sweeper"})==1.3 and Roles.attention({"type":"sweeper"})==20.,"sweeper ear and attention unchanged")
 check(Roles.speed({"type":"sweeper","suspicion":.5},48.)==34.,"sweeper movement unchanged")
