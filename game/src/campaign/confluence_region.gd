extends RefCounted
# Authored water, rock and industry share one geometry. The two halves of the
# basalt divide meet at an optional man-made sluice; they are not scaled slabs.
static func build(m:Dictionary)->void:
 var deep=m.launch_context.thread=="deep" or (m.launch_context.thread.is_empty() and 9 in m.launch_context.completed)
 m.world_size=Vector2(3600,4800)
 m.start=Vector2(3060,4310) if deep else Vector2(600,4310)
 m.extraction=Vector2(440,4510)
 m.rocks=[
  PackedVector2Array([Vector2(-100,-100),Vector2(320,-100),Vector2(410,430),Vector2(300,760),Vector2(470,1100),Vector2(400,1330),Vector2(590,1610),Vector2(550,1860),Vector2(370,2100),Vector2(540,2480),Vector2(350,3000),Vector2(650,3300),Vector2(500,3780),Vector2(-100,3900)]),
  PackedVector2Array([Vector2(1430,1160),Vector2(1720,1040),Vector2(2010,1240),Vector2(2130,1530),Vector2(2390,1750),Vector2(2320,1850),Vector2(2460,2010),Vector2(2400,2150),Vector2(1300,2150),Vector2(1260,2020),Vector2(1400,1930),Vector2(1230,1840),Vector2(1320,1750),Vector2(1190,1530)]),
  PackedVector2Array([Vector2(1300,2450),Vector2(2400,2450),Vector2(2470,2810),Vector2(2280,3210),Vector2(2490,4180),Vector2(2250,4540),Vector2(1950,4460),Vector2(1630,4570),Vector2(1370,4280),Vector2(1440,3550),Vector2(1230,3350)]),
  PackedVector2Array([Vector2(3200,-100),Vector2(3700,-100),Vector2(3700,3900),Vector2(3160,3800),Vector2(3190,3460),Vector2(3040,3280),Vector2(3110,3000),Vector2(3320,2850),Vector2(3330,2160),Vector2(3050,2020),Vector2(3060,1830),Vector2(3210,1600),Vector2(3110,1380),Vector2(3290,1170),Vector2(3270,830),Vector2(3080,650)]),
  PackedVector2Array([Vector2(740,2510),Vector2(900,2460),Vector2(1010,2640),Vector2(900,2810),Vector2(720,2750)]),
  PackedVector2Array([Vector2(2720,2120),Vector2(2880,2050),Vector2(3060,2170),Vector2(3010,2350),Vector2(2800,2370)]),
  PackedVector2Array([Vector2(2110,540),Vector2(2300,420),Vector2(2500,560),Vector2(2440,820),Vector2(2220,870),Vector2(2080,710)])]
 var factory=Rect2(380,1300,600,360)
 var gate=Rect2(1300,2150,1100,300)
 m.structures=[factory,gate]
 m.physical_gates=[{"id":"confluence_service_sluice","site_id":"confluence_repeater","closed_shape":gate,"opened":false}]
 m.landmarks=[{"id":"confluence_factory","pos":factory.get_center(),"rect":factory,"kind":"factory","source_id":"confluence_packet"}]
 m.currents=[{"center":Vector2(2770,3270),"radius":700.0,"velocity":Vector2(0,-26)},{"center":Vector2(1870,4620),"radius":500.0,"velocity":Vector2(-18,0)}]
 var live=_source("confluence_packet","KESTREL TRANSMISSION",Vector2(1080,1840),"Kestrel's last transmission, still repeating from the ridge: a patrol submarine bottomed with a torpedo tube open when the Sirens arrived, eleven sailors alive in the aft escape trunk, air running down. Quietus can carry this out quietly, for a craft to answer, or forward it through the open warning chain to a surface ship; neither choice makes the return water safe.",[.8,1.6,.8])
 if m.launch_context.facts.get("wake_crossing","")=="repeater_played":live.evidence+=" Your Wake log records that you spent a wrecked rig's beacon to draw patrols off. This transmission comes from people still breathing; the same noise can bring the patrols here."
 var service=_source("confluence_repeater","OLD SERVICE REPEATER",Vector2(2960,2460),"This is an old ridge survey repeater, not Kestrel's own transmission. Its local circuit controls the sealed cross-ridge sluice. Operating it opens a shorter eastern return, but its motor will disclose this recess. The western channel remains passable without it.",[1.6,.8,1.6])
 service.merge({"optional":true,"completion_open_structure":"confluence_service_sluice","completion_emission":{"radius":1400.0,"label":"CONFLUENCE SLUICE MOTOR","duration":10.0}})
 m.signal_sources=[live,service];m.required_site_ids=["confluence_packet"]
 m.corridors=[{"pos":m.extraction,"name":"CONCEALED ASCENT","route":"concealed"},{"pos":Vector2(3160,4200),"name":"OPEN WARNING PASSAGE","route":"overt"}]
 m.brief="The submarine Kestrel lies bottomed on the ridge north of the basalt divide. Recover its live transmission, then bring Quietus back to one of the two southern recovery mouths. The western arm is a narrow broken channel with sheltered recesses; the wider eastern passage carries a north-setting current that helps the approach and resists the return. A west-setting current crosses the narrow southern saddle between the entry mouths. Rock separates their sight and sound. Drones can investigate the two arms independently while Quietus advances, or Quietus can do all the fieldwork alone. Two unlocated carriers remain: Kestrel's transmission and an old survey repeater. A received cadence and recovered RETURN reference can distinguish their patterns; without a fitted correlator, close observation or finite local RECON still works. The service repeater may offer a physical shortcut, at a cost you can inspect there. Preserve air and drone energy for withdrawal. Return through CONCEALED ASCENT to bring the sailors out quietly, or OPEN WARNING PASSAGE to call a surface ship. The physical southern exit commits the next operation; no hidden purity score chooses it."
 m.brief+=" Your deep approach begins in the eastern current passage." if deep else " Your shelf approach begins below the western broken channel."
 m.record="Kestrel's transmission is recovered: eleven alive in the aft trunk, the torpedo tube still open. Quietus returned through a chosen passage with a record, not a target list; opening the optional service sluice changed the physical return without certifying the water safe."
 _guard(m,Vector2(930,2000),[Vector2(930,2000),Vector2(1070,1710),Vector2(1070,2310),Vector2(1090,2930),Vector2(870,3190),Vector2(790,3550)],"patroller")
 _guard(m,Vector2(990,1180),[Vector2(990,1180),Vector2(1090,1370)],"sentinel")
 m.sirens[1]["tether"]=210.0
 _guard(m,Vector2(2780,1740),[Vector2(2780,1740),Vector2(2640,2460),Vector2(2740,3100),Vector2(2850,3570),Vector2(3000,2780)],"hunter")
static func _source(id:String,label:String,pos:Vector2,evidence:String,cadence:Array)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"optical":"divergence_"+id,"evidence":evidence,"located":false,"cadence":cadence,"confirm":true,"sampler_compatible":true}
static func _guard(m:Dictionary,pos:Vector2,points:Array,role:String)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":role,"patrol_points":points,"patrol_index":0})
