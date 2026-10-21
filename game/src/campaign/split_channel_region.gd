extends RefCounted
# Three connected waters, not a stretched copy of the old arena. The central
# spine divides receivers; the northern saddle links the two relay arms.
static func apply(mission:Dictionary)->void:
 mission["region_revision"]=1;mission["world_size"]=Vector2(2000,2400)
 mission["start"]=Vector2(220,2180);mission.extraction=mission.start
 mission.rocks=[
  Rect2(-120,1820,680,160), # recovery basin's western overhang
  Rect2(840,1800,1280,180), # southern shelf; two exits around its west end
  Rect2(760,880,300,740), # central spine, shielding the uplink recess
  Rect2(760,120,300,520), # upper spine, interrupted by a cross-channel saddle
  Rect2(-120,1120,480,300), # western branch bend
  Rect2(450,670,160,240), # west relay's screening tooth
  Rect2(1260,1140,300,400), # east corridor has a long exposed outer approach
  Rect2(1590,250,530,260), # eastern headwall
  Rect2(300,-120,300,350), # northern return passage
 ]
 var west=mission.objectives[0];var east=mission.objectives[1];var link=mission.objectives[2]
 west.pos=Vector2(420,400);east.pos=Vector2(1550,760);link.pos=Vector2(1110,1660)
 west["evidence"]="WEST CORRECTION: the relay compensates for a blind sector behind the central basalt spine. The northern saddle links the two arms; the lower west passage returns toward the recovery basin. A separate drone can observe the eastern relay while Quietus stays under cover at the uplink."
 east["evidence"]="EAST CORRECTION: the eastern relay listens into open water beside the long outer wall. Its return points toward the covered UPLINK ANCHOR south of the spine. Combine both records there with Quietus."
 link["evidence"]="Joined, the two logs agree on the moment the riser parted. Return through either southern passage; Quietus must recover the log."
 mission.brief="Corran Bank's two positioning transponders sit on either side of a branching basalt trench. Recover WEST and EAST relay images, then bring Quietus to the covered UPLINK ANCHOR for a six-second CAMERA / LINK. The western arm bends through cover; the eastern arm opens beside a long wall. The northern saddle crosses between them. Drones can work opposite arms while Quietus stages at the uplink; a lone submarine can make the circuit. Return to the southern recovery basin. Sonar is local. RECON surveys 560m around its launch point for eight seconds, including behind cover; distant water stays unknown."
 var homes=[Vector2(420,700),Vector2(1690,1050)]
 var circuits=[
  [Vector2(420,700),Vector2(260,920),Vector2(620,1040),Vector2(680,580)],
  [Vector2(1690,1050),Vector2(1770,1530),Vector2(1160,1660),Vector2(1180,940)]
 ]
 for i in mission.sirens.size():
  var enemy=mission.sirens[i]
  enemy.pos=homes[i];enemy.home=homes[i];enemy.goal=homes[i]
  enemy.patrol_points=circuits[i];enemy.patrol_index=0
