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
 matched_noise_contrast()
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

func matched_noise_contrast():
 # One identical isolated legacy sound, within the sentinel's existing tether.
 # Player craft stay at their real fixture launch, outside sight and hearing.
 var rows={}
 for role in ["hunter","sentinel"]:
  var s=Fixtures.fixture(role);var e=s.sirens[0]
  var source:Vector2=e.home-Vector2(150,0)
  s._noise(source,450.,"TEST",.2)
  var length=0.;var search_length=0.;var lost_at=0.
  var search_origin=Vector2.INF;var search_end=Vector2.INF;var settled_search=Vector2.INF;var search_time=0.
  var modes=[]
  for n in 250:
   var before:Vector2=e.pos;var was_search=e.mode=="SEARCH"
   s.advance(.1)
   length+=before.distance_to(e.pos)
   if was_search and e.mode=="SEARCH":search_length+=before.distance_to(e.pos)
   if e.mode=="SEARCH":
    if search_origin==Vector2.INF:search_origin=e.pos
    search_end=e.pos
    search_time+=.1
    if search_time>2. and settled_search==Vector2.INF:settled_search=e.pos
   if e.mode not in modes:modes.append(e.mode)
   if lost_at==0. and "SEARCH" in modes and e.attention_time==0.:lost_at=s.elapsed
  rows[role]={"lost_at":lost_at,"path":length,"search_path":search_length,"search_origin":search_origin,"search_end":search_end,"settled_search":settled_search,"final":e.pos,"modes":modes}
  print("ROLE CONTRAST ",role," ",rows[role])
  check(s.hull==100. and e.target==-1,"%s matched noise probe has no hidden craft sighting"%role)
  check(lost_at>0. and "SEARCH" in modes and "RETURN" in modes,"%s physically investigates, searches and loses interest"%role)
 check(rows.sentinel.lost_at-rows.hunter.lost_at>5.5,"same noise leaves sentinel interested at least five seconds longer")
 check(rows.hunter.search_path>rows.sentinel.search_path+100.,"hunter physically sweeps more than100m while sentinel holds")
 check(rows.sentinel.settled_search.distance_to(rows.sentinel.search_end)<1.,"sentinel brakes at reached search station and holds position")
