extends RefCounted
# 130 R5 control-mix telemetry (dev state only). Per order kind, the distance a
# craft has covered along the path that order installed: one-press travel,
# planned legs, emergency, recall. Progress is the arc length of the craft's
# closest point on that path, so arrival, ALL STOP, crash or a replacing order
# all credit what was actually covered. Lives in sim metadata, never in a save.
# A "route" order is one-press when its args carry a TRAVEL key other than the
# release placed-leg keys (presentation/release_controls.gd TRAVEL_SHORTCUTS).
# Each path segment keeps the kind of the order that plotted it, so a queued leg
# never relabels the untraveled remainder of an earlier route.
# Reads nothing back into the simulation. Revert: drop the Route.command hooks.
const KINDS=["one_press","planned","emergency","recall"]
const PLACED_LEGS=["","water_leg","water_leg_confirm"]
const META="control_mix"

static func on(sim)->bool:
 return sim.mission is Dictionary and sim.mission.get("dev",false)

static func kind(order:String,args:Dictionary)->String:
 match order:
  "route":return "planned" if str(args.get("travel","")) in PLACED_LEGS else "one_press"
  "emergency":return "emergency"
  "recall","recall_all":return "recall"
 return ""

static func _state(sim)->Dictionary:
 if not sim.has_meta(META):
  var totals={}
  for k in KINDS:totals[k]=0.0
  sim.set_meta(META,{"totals":totals,"legs":{}})
 return sim.get_meta(META)

# Arc length along path at the point closest to p.
static func _progress(path:PackedVector2Array,p:Vector2)->float:
 var best=INF;var at=0.0;var run=0.0
 for i in range(path.size()-1):
  var a=path[i];var b=path[i+1];var c=Geometry2D.get_closest_point_to_segment(p,a,b)
  var d=p.distance_squared_to(c)
  if d<best:best=d;at=run+a.distance_to(c)
  run+=a.distance_to(b)
 return at

# Credit newly covered arc length to the kind of each segment it crossed.
static func _flush(sim,id:int)->void:
 var state=_state(sim);var leg=state.legs.get(id,{})
 if leg.is_empty():return
 var done=_progress(leg.path,sim.units[id].pos)
 if done<=leg.done:return
 var run=0.0
 for i in range(leg.path.size()-1):
  var end=run+leg.path[i].distance_to(leg.path[i+1])
  var covered=minf(done,end)-maxf(leg.done,run)
  if covered>0.0:state.totals[leg.kinds[i]]+=covered
  run=end
 leg.done=done

static func _units(sim,order:String)->Array:
 return [1,2] if order=="recall_all" else [sim.selected]

# Before a Route order: credit progress on the legs it may replace.
static func before(sim,order:String)->void:
 if not on(sim):return
 var routes={}
 for id in _units(sim,order):_flush(sim,id);routes[id]=sim.units[id].route
 _state(sim)["routes"]=routes

# Kinds of the nodes still ahead on the current leg, one per route node.
static func _ahead(state:Dictionary,id:int,count:int)->Array:
 var kinds:Array=state.legs.get(id,{}).get("kinds",[])
 return kinds.slice(maxi(0,kinds.size()-count))

# After an accepted Route order: a newly installed path starts a fresh leg.
# A queued leg keeps the old remainder's kinds and tags only the appended nodes.
static func after(sim,order:String,args:Dictionary)->void:
 if not on(sim):return
 var k=kind(order,args)
 var state=_state(sim)
 for id in _units(sim,order):
  var u=sim.units[id];var leg_kind=k
  var old:Array=state.get("routes",{}).get(id,[])
  # A program edit replots the current leg under the kind of its next node.
  if leg_kind=="" and order in ["route_edit","route_insert","route_delete","route_undo","order_undo"]:
   var ahead=_ahead(state,id,old.size());leg_kind=ahead[0] if not ahead.is_empty() else "planned"
  if leg_kind=="" or u.route.is_empty():continue
  # RECALL ALL may refuse one drone; its untouched route keeps its own leg.
  if order=="recall_all" and is_same(u.route,old):continue
  var kinds=[]
  # A queued route appends to a copy of the old route, so its nodes lead.
  if order=="route" and sim.queue_mode and not old.is_empty() and u.route.size()>old.size():
   kinds=_ahead(state,id,old.size())
   while kinds.size()<old.size():kinds.push_front(leg_kind)
  var path=PackedVector2Array([u.pos])
  for node in u.route:path.append(node.pos)
  while kinds.size()<u.route.size():kinds.append(leg_kind)
  state.legs[id]={"kinds":kinds,"path":path,"done":0.0}

# Metres covered per kind so far. All zero with dev state off.
static func totals(sim)->Dictionary:
 var result={}
 for k in KINDS:result[k]=0.0
 if not on(sim) or not sim.has_meta(META):return result
 for id in _state(sim).legs.keys():_flush(sim,id)
 return _state(sim).totals.duplicate()

# Share of covered distance under one-press orders, 0..1 (0 when nothing moved).
static func one_press_share(sim)->float:
 var t=totals(sim);var sum=0.0
 for k in KINDS:sum+=t[k]
 return t.one_press/sum if sum>0.0 else 0.0
