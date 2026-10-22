extends RefCounted
const Divergence=preload("res://src/campaign/divergence_missions.gd")
const CHAIN_INLET=Vector2(480,1000)
const CHAIN_PANEL=Vector2(1520,1000)
const CHAIN_MAST=Vector2(1000,400)
const CHAIN_SHUTTER=Rect2(880,960,240,120)
const CHAIN_RECOVERY=Vector2(180,1000)
static func make(id:int,history:Dictionary={})->Dictionary:
 var wake=id==9
 var m={"id":id,"title":"Wake Crossing" if wake else "Warning Chain","brief":"","record":"","depth":5100 if wake else 2600,"darkness":false,"region_revision":1,"world_size":Vector2(2000,2080),"start":Vector2(1000,1880),"extraction":Vector2(1000,180),"rocks":[],"objectives":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[],"launch_context":history.duplicate(true)}
 m.corridors=[{"pos":m.extraction,"name":"NORTH WATER RECOVERY","route":"deep" if wake else "shelf"}]
 if wake:
  m.wake_crossing=preload("res://src/simulation/wake_crossing.gd").initial();m.contact_report_revision=1
  m.rocks=[Rect2(880,660,240,820),Rect2(100,1020,420,220),Rect2(1480,1020,420,220),Rect2(120,300,420,180),Rect2(1460,300,420,180)]
  m.signal_sources=[{"id":"wake_packet","label":"RETURN RECEIVER","pos":Vector2(480,620),"evidence":"The measured return is the bell's telemetry line, tight and regular. Someone is alive on it. Quietus can read the packet without answering it.","located":false,"confirm":true,"range":1600.0,"cadence":[0.8,1.6,0.8]}, {"id":"wake_repeater","label":"ABANDONED REPEATER","pos":Vector2(1520,620),"evidence":"A surviving repeater carries an older unequal cadence. Its close packet shows a wrecked rig's beacon; a matching rhythm alone never proves anyone is alive on it.","located":false,"range":1600.0,"cadence":[1.6,0.8,1.6]}]
  m.required_site_ids=["wake_packet"]
  m.signal_sources[1].evidence="The beacon belongs to a wrecked rig, and its last battery is nearly gone. Played once, it will call loudly into the northern saddle, where Siren patrols will turn toward it. Nobody answers it."
  m.signal_sources[0].evidence="The measured return is the bell's own telemetry, not a position fix. The old eastern beacon is a wrecked rig still calling. Siren patrols still pass sightings across the northern saddle. The line carries people; the beacon carries only noise."
  if history.get("facts",{}).has("rendezvous"):m.signal_sources[0].evidence+=" Your recovered tender run used this same correction channel at the berth."
  m.brief="Find the live return receiver, recover the bell's line packet with Quietus, then cross to northern recovery. Two unlabeled carriers reach the southern lee. A fitted berthing correlator can compare the recovered RETURN reference after six settled seconds; without it, close scouting or finite RECON still identifies either source. Neither cadence nor a bearing guarantees safety. The eastern beacon may draw a patrol off; inspect its hardware before spending it. Reserve air for the crossing and any independent drone's return."
  m.record="The wrecked rig's beacon kept calling while the bell's line stayed quiet. Siren patrols still trade local sightings. A dead call can buy cover without being anyone's lifeline; the packet and Quietus have crossed the watch line."
  Divergence._patrol(m,Vector2(620,850),[Vector2(620,850),Vector2(620,520),Vector2(780,420),Vector2(760,1400)])
  Divergence._patrol(m,Vector2(1340,850),[Vector2(1340,850),Vector2(1340,450),Vector2(1220,300),Vector2(1250,1430)])
  m.sirens[1].type="hunter"
  m.sirens[1].pos=Vector2(900,380);m.sirens[1].home=m.sirens[1].pos;m.sirens[1].goal=m.sirens[1].pos
  m.brief+=" A Siren patrol and a northern hunter can report local sightings. The long western outside water remains a solo route without tools or playback."
 else:
  m.rocks=[Rect2(880,800,240,160),Rect2(880,1080,240,520),Rect2(140,520,500,220),Rect2(1360,520,500,220),Rect2(300,1230,320,200),Rect2(1380,1230,320,200)]
  m.structures=[CHAIN_SHUTTER]
  m.warning_chain={"power":"off","unit":-1,"output":"","opened":false,"sends":[],"result":{}}
  for item in [[CHAIN_INLET,"WEST SERVICE INLET","chain_west","The preparations belong to one warning plant. A local craft can supply its service bus; the backup generator frees that body but discloses the western inlet."],[CHAIN_PANEL,"EAST ROUTING PANEL","chain_east","The powered panel can route a narrow service warning across the shutter or energize the northern mast. A service receipt proves one local branch; mast telemetry proves transmission, not an external audience."],[CHAIN_PANEL,"WARNING PLANT OPERATING RECORD","chain_relay","The warning plant was commissioned. The returned operating record distinguishes a verified local service receipt from a mast transmission with external reception unknown."]]:
   m.objectives.append({"pos":item[0],"name":item[1],"site_id":item[2],"captured":false,"kind":"plant","optical":item[2],"evidence":item[3]})
  m.corridors.append({"pos":CHAIN_RECOVERY,"name":"WEST SERVICE RECOVERY","route":"shelf"})
  m.brief="Port Ardent's cable to the coast runs through an unpowered relay plant on the shelf. At WEST SERVICE INLET, CONNECT any settled craft within60m: that body's umbilical powers the distant panel until it releases, moves or is lost. START BACKUP is the complete solo alternative; one audible generator start frees the power craft. At EAST ROUTING PANEL, Quietus or a recovered fitted field sampler can select the output and SEND WARNING through the powered plant. SERVICE opens a real water and sound crosslink and sends from EAST; the western branch must actually receive it. NORTH MAST sends from northern hardware; its telemetry proves transmission, while external reception stays unknown. No camera hold is needed. Once commissioned, disconnect the helper and choose north or west service recovery. Both routes lead onward; an equipped craft still has its ordinary recovery stakes."
  if history.get("facts",{}).has("shelf_warning"):m.brief+=" The bunker has already answered: "+history.facts.shelf_warning+" Their cable to the bunker needs this plant; these receivers are not empty infrastructure."
  m.record="The warning plant works again. Its operating record preserves exactly what Quietus proved: a local service acknowledgement or a northern mast transmission whose wider audience remains unknown. The motors and the mast were loud work, and Quietus cannot say who heard them."
  Divergence._patrol(m,Vector2(740,1080),[Vector2(740,1080),Vector2(700,760),Vector2(740,380),Vector2(800,1700)])
  Divergence._patrol(m,Vector2(1280,800),[Vector2(1280,800),Vector2(1250,1250),Vector2(1250,1700),Vector2(1280,400)])
  m.sirens[0].type="sentinel";m.sirens[0]["tether"]=190.0
  m.brief+=" A Siren sentinel holds the western preparation; the eastern arm is patrolled."
 return m

static func supports_config(config:Dictionary)->bool:
 var source=config.get("source_id",-1)
 return config.size()==2 and config.get("history")==true and source in [9,10]

# Identity-bound authored helpers remain on their original operation.
static func supports_identity(id:int,config:Dictionary)->bool:
 return id==config.source_id or config.source_id==10
