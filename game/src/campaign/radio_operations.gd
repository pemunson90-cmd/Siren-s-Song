extends RefCounted
#116 AI-DESIGNED recovery watches. Revert this table and catalog hook to restore
# former placements; sensing, movement and physical recovery rules are shared.
const WATCHES={31:{0:Vector2(1868,650),1:Vector2(1460,560)},33:{3:Vector2(2210,1874),2:Vector2(2230,1480)}}
const SCREENS={31:[Rect2(1740,820,80,80)],33:[Rect2(2080,1740,80,80),Rect2(2280,1740,80,80)]}
static func apply(m:Dictionary)->void:
 if not m.id in WATCHES:return
 for id in WATCHES[m.id]:
  var e=m.sirens[id];var p=WATCHES[m.id][id]
  e.pos=p;e.home=p;e.goal=p;e.band=1
  e.patrol_points=[p,p+Vector2(0,180) if m.id==31 else p+Vector2(180,0)]
  e.patrol_index=0
 m.structures.append_array(SCREENS[m.id])
 m.brief+=" A pair of recovery watches can share your last seen area after a visible 3s report. Break contact before it completes, or use Disrupt or a decoy. The outside contour stays open."
