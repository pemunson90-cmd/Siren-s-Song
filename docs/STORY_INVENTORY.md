# Story Inventory: player-facing narrative strings (review doc)

Source: `claude/integration` @ f212073, `game/src/**/*.gd`. Read-only inventory by lane S1. Nothing here is a rewrite or a proposal: every string is quoted verbatim from the code and tagged. Line numbers refer to that commit. Paths are relative to `game/src/`.

## How to read this

Tags (a string can carry several):

- **REJECTED-PREMISE**: contains vocabulary from the rejected Siren-evacuation / human-fleet-threat arc. Strong vocabulary matched: families, shelter(s), refuge/refugees, anchorage, evacuation, fleet, departure/depart, occupied, inhabited, witness (capsule, pod, account), survivor, keeper/engineer (as speaking characters), navigator, nurseries, berth(s), unarmed hulls. The matched terms are listed in brackets after the tag.
- **REJECTED-PREMISE?**: weak vocabulary only (carrier, sheltered, hull, harbour, rendezvous, pact, escort, surface watch, gallery, or the speaker names Ilen, Sava, Rill, Nera, Foreman, Lock keeper). Often "carrier" means a signal carrier wave and "sheltered" means terrain cover, so these need Pat's eye rather than automatic removal.
- **EXPLAINS-BEAT**: text that tells the player what a moment means (all debrief records, all ending bodies, all recap lines, plus evidence and brief text matching interpretive phrasing such as "is not", "proves", "identifies", "DECODED"). This is a heuristic first pass; some mechanical briefs may be over-tagged and some subtler explanations missed.
- **NUMBER-SPACING**: a missing space before or after a number (within60m, takes8, Winch4s, below2m/s, within%dm, ·4s). Quoted exactly as in code.
- **OK**: none of the above found.

Scope: all strings of 6 or more characters containing a space (plus capitalised single-word titles) in `game/src/campaign/*.gd`, plus those strings from `presentation`, `simulation`, `persistence`, `equipment` and `main.gd` that are either (a) in a file belonging to one specific operation (assigned to that operation below), or (b) flagged by any tag, or (c) 70 characters or longer, or (d) menu, debrief and ending screens in main.gd. Debug markers (SS_*), identifiers and short button labels are omitted. Strings built from fragments (endings, brief suffixes) appear as the separate fragments found in code. Bracketed `[field]` is the code key or variable the string is assigned to, where detectable.

Operation ids follow `operation_catalog.gd`: 0-5 introductory arc, 6-8 divergence, 9-10 onward, 11-13 resolution, 14-21 Glass Reach, 22-29 Iron Choir. Where one code path serves several operations, its strings sit in a "Shared" block directly after the last operation of that group.

## Operation 0: Shelf Signal

- `campaign/shelf_signal_operation.gd:15` [depth_hint] **OK**
  > DEEP under the arch · MIDDLE camera/recovery · craft → DEPTH / SONAR.
- `campaign/shelf_signal_operation.gd:16` [brief] **OK**
  > Photograph the listening spire, then return Quietus. DEEP passes beneath the western arch; SHALLOW has an extra sill; MIDDLE retains the long water route. Craft → DEPTH / SONAR changes adjacent layers: four stationary seconds exposed in both. Deep pumps cost reserves. Work and recovery require MIDDLE. A sweeper guards the far side. A locally heard winding tone warns of its sweep and delayed strike at the old return. Move or disrupt before it lands. Passive bearings need movement or independent receivers to narrow a position. Choose a quiet crossing or coordinate a costly active sounding, then bring the evidence home.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > Shelf Signal
- `campaign/tutorial_missions.gd:4` [brief] **EXPLAINS-BEAT**
  > A repeating signal rises from the shelf. Photograph the listening spire, then bring Quietus home. Your charts show rock, not what waits behind it. Sonar reveals water but announces your position.
- `campaign/tutorial_missions.gd:12` [record] **EXPLAINS-BEAT**
  > A manufactured pulse. Something beneath the shelf is counting the seconds between our pings.

## Operation 1: Split Channel

- `campaign/opening_depth_operations.gd:13` [hint] **OK**
  > Southern shelf: DEEP crossing · northern saddle: SHALLOW · LINK in MIDDLE.
- `campaign/opening_depth_operations.gd:14` [brief] **OK**
  > Split two receivers across the branching trench. Photograph WEST and EAST, then Quietus must LINK six seconds at the UPLINK and return. DEEP opens the southern shelf crossing; SHALLOW opens the northern saddle but closes the uplink mouth. The eastern patrol works DEEP. Separate drones can earn independent bearings while Quietus stages. Use craft → DEPTH / SONAR for soundings and layers; local work needs MIDDLE.
- `campaign/split_channel_region.gd:20` [evidence] **OK**
  > WEST CORRECTION: the relay compensates for a blind sector behind the central basalt spine. The northern saddle links the two arms; the lower west passage returns toward the recovery basin. A separate drone can observe the eastern relay while Quietus stays under cover at the uplink.
- `campaign/split_channel_region.gd:21` [evidence] **REJECTED-PREMISE?** (weak terms: sheltered)
  > EAST CORRECTION: the eastern relay listens into open water beside the long outer wall. Its return points toward the sheltered UPLINK ANCHOR south of the spine. This network is correcting for our instruments, not painting targets. Combine both records there with Quietus.
- `campaign/split_channel_region.gd:22` [evidence] **OK**
  > Combined bearings resolve a moving correction pattern. The network is measuring our sensors. The two separated receivers saw different parts of the same instrument sweep. Return through either southern passage; Quietus must recover the archive.
- `campaign/split_channel_region.gd:23` [brief] **REJECTED-PREMISE?** (weak terms: sheltered)
  > Two separated receivers are correcting one another across a branching basalt trench. Recover WEST and EAST relay images, then bring Quietus to the sheltered UPLINK ANCHOR for a six-second CAMERA / LINK. The western arm bends through cover; the eastern arm opens beside a long wall. The northern saddle crosses between them. Drones can work opposite arms while Quietus stages at the uplink; a lone submarine can make the circuit. Return to the southern recovery basin. Sonar is local. RECON surveys 560m around its launch point for eight seconds, including behind cover; distant water stays unknown.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > Split Channel
- `campaign/tutorial_missions.gd:5` [brief] **REJECTED-PREMISE** (terms: witnesses)
  > Two channels. Two witnesses. Photograph the separated WEST and EAST relays. Bring Quietus to the sheltered UPLINK ANCHOR and use CAMERA / LINK to combine their records. Drones travel faster and can expose a relay while the submarine moves. Losing them leaves a longer solo-sub approach. Return with the combined archive.
- `campaign/tutorial_missions.gd:13` [record] **EXPLAINS-BEAT**
  > The relays exchange corrections. Their network is learning the shape of our instruments.
- `campaign/tutorial_missions.gd:41` [name] **OK**
  > WEST RELAY
- `campaign/tutorial_missions.gd:41` [name] **OK**
  > EAST RELAY
- `campaign/tutorial_missions.gd:42` [name] **OK**
  > UPLINK ANCHOR

## Operation 2: Blackwater Relay

- `campaign/opening_depth_operations.gd:21` [hint] **NUMBER-SPACING** (at: within60m)
  > Buffers stay on craft · SAMPLE in MIDDLE · TRANSFER at same depth within60m.
- `campaign/opening_depth_operations.gd:22` [brief] **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: carrier; at: within60m)
  > SAMPLE REQUEST and REPLY, then bring both raw buffers aboard Quietus and return. DEEP opens the western underpass; SHALLOW opens the northern reply approach but blocks the southern carrier lane. A shallow patrol and deep sweeper guard different waters. SAMPLE in MIDDLE; meet in the same settled band within60m to TRANSFER drone buffers. Quietus can sample directly. Craft → DEPTH / SONAR shows received bearings, not promised positions.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > Blackwater Relay
- `campaign/tutorial_missions.gd:6` [brief] **EXPLAINS-BEAT**
  > The signal is a conversation. Blackwater absorbs passive returns. Settle within passive reach and SAMPLE the REQUEST and REPLY relays. Each packet describes its partner. Drones hear farther; Quietus can recover either record if they are lost. Sonar may solicit a local answer, but the ocean hears your emission. Bring the exchange home.
- `campaign/tutorial_missions.gd:14` [record] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier)
  > The carrier contains ocean temperatures from before humans existed. This installation has been waiting.
- `campaign/tutorial_missions.gd:45` [name] **OK**
  > REQUEST RELAY
- `campaign/tutorial_missions.gd:45` **OK**
  > REPLY RELAY
- `campaign/tutorial_missions.gd:47` [evidence] **OK**
  > REPLY HANDSHAKE: settle and SAMPLE 2s within passive reach. For standoff, settle first, emit SONAR under 240m with a clear line, then SAMPLE 2s during its 3s reply. The western request asks its eastern partner for a missing ocean-temperature archive.
- `campaign/tutorial_missions.gd:48` [evidence] **EXPLAINS-BEAT**
  > ANCIENT OCEAN: the eastern reply carries temperature strata older than humanity. Its header identifies the requested climate archive. The REQUEST uses the same handshake: settle within passive reach and SAMPLE 2s, or settle, SONAR under 240m with a clear line, then SAMPLE during the 3s local replay. Either packet can be recovered first.
- `campaign/tutorial_missions.gd:75` [evidence] **REJECTED-PREMISE?** (weak terms: carrier)
  >  The request announces a ballast-driven archive glider carrying a copy of the eastern REPLY around the southern basalt corridor to a buried western intake. The recovered chart marks its course. Intercept its local carrier with a settled SAMPLE 2s before it submerges at the intake; it never visits this REQUEST. This optional return-leg interception replaces the eastern approach, not the record. The fixed REPLY and its SONAR replay remain available if you miss it.
- `campaign/tutorial_missions.gd:76` [brief] **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: carrier; at: below2m/s, local4s, within60m)
  >  A recovered request may announce an archive carrier. Its route is an interception opportunity; the fixed relays remain available in either order. Blackwater breaks the bulk uplink: field notes are retained, but raw exchange data stays on the sampling craft. Bring a data carrier within60m of Quietus, settle both below2m/s with a clear line, then TRANSFER. You may move Quietus to a meeting point. Lost buffers remain at the known wreck; one audible local4s winch recovers data and co-located kit, or Quietus can SAMPLE the fixed relay again. Quietus sampling directly puts data aboard; spare drones need not return.
- `presentation/blackwater_courier_view.gd:9` **OK**
  > ANNOUNCED ARCHIVE CORRIDOR
- `presentation/blackwater_courier_view.gd:19` **REJECTED-PREMISE?** (weak terms: carrier)
  > REPLY CARRIER
- `presentation/blackwater_courier_view.gd:21` **OK**
  > LOCAL · SETTLE + SAMPLE
- `presentation/blackwater_delivery_view.gd:12` [count] **OK**
  > Q ABOARD %d/2 · FIELD NOTES %d/2
- `presentation/blackwater_delivery_view.gd:21` **OK**
  > ABOARD · 
- `presentation/blackwater_delivery_view.gd:21` [unit] **OK**
  > BUFFER · 
- `presentation/blackwater_delivery_view.gd:28` **OK**
  > RECOVER %d%% · RAW DATA
- `presentation/blackwater_delivery_view.gd:31` **OK**
  > RAW DATA · 
- `presentation/blackwater_delivery_view.gd:46` [state] **OK**
  > ABOARD QUIETUS
- `presentation/blackwater_delivery_view.gd:46` **OK**
  > NOT RECORDED
- `presentation/blackwater_delivery_view.gd:46` **OK**
  > FIELD NOTE · RAW DATA NEEDED
- `presentation/blackwater_delivery_view.gd:50` [state] **OK**
  > BUFFER · 
- `presentation/blackwater_delivery_view.gd:51` [state] **OK**
  >  · OWN WRECK
- `presentation/blackwater_delivery_view.gd:53` **OK**
  >  → Q · 
- `presentation/blackwater_delivery_view.gd:54` **OK**
  > TRANSFER: both craft settled below 2m/s, within 60m, clear line of sight, neither busy. Quietus can SAMPLE each relay directly; field notes alone do not deliver raw data.
- `presentation/blackwater_delivery_view.gd:59` **OK**
  > RAW EXCHANGE DELIVERED %d/2\nFIELD NOTES RETAINED %d/2\nOnly packets physically aboard Quietus qualify for recovery.
- `simulation/blackwater_delivery.gd:22` [text] **OK**
  > Exchange aboard Quietus · return to recovery
- `simulation/blackwater_delivery.gd:22` **OK**
  > SAMPLE REQUEST and REPLY · raw exchange must return to Quietus
- `simulation/blackwater_delivery.gd:23` [text] **OK**
  > Field notes %d/2 · Quietus buffers %d/2 · local TRANSFER or recover/resample missing data
- `simulation/blackwater_delivery.gd:26` [reason] **OK**
  > No exchange buffer available
- `simulation/blackwater_delivery.gd:30` [reason] **OK**
  > Dive ended
- `simulation/blackwater_delivery.gd:31` [alive] **OK**
  > Both transfer craft must be alive
- `simulation/blackwater_delivery.gd:32` [reason] **OK**
  > Meet at the same settled depth
- `simulation/blackwater_delivery.gd:34` [RANGE] **NUMBER-SPACING** (at: within60m)
  > Meet Quietus within60m for local TRANSFER
- `simulation/blackwater_delivery.gd:35` [reason] **OK**
  > Terrain blocks the local data connection
- `simulation/blackwater_delivery.gd:36` [reason] **NUMBER-SPACING** (at: below2m/s)
  > Settle both craft below2m/s
- `simulation/blackwater_delivery.gd:37` [reason] **OK**
  > Finish active work before local TRANSFER
- `simulation/blackwater_delivery.gd:38` [else] **OK**
  > TRANSFER · raw exchange buffers to Quietus
- `simulation/blackwater_delivery.gd:43` [carrier] **REJECTED-PREMISE?** (weak terms: carrier)
  > Select Quietus or this data carrier
- `simulation/blackwater_delivery.gd:46` [message] **OK**
  > Raw exchange transferred locally · 
- `simulation/blackwater_delivery.gd:53` **OK**
  >  field record retained · raw buffer 
- `simulation/blackwater_delivery.gd:53` **OK**
  > aboard Quietus
- `simulation/blackwater_delivery.gd:53` [unit] **OK**
  > carried by 
- `simulation/blackwater_delivery.gd:53` **NUMBER-SPACING** (at: within60m)
  >  · local TRANSFER to Quietus within60m
- `simulation/blackwater_delivery.gd:54` **NUMBER-SPACING** (at: within240m)
  > : quiet SAMPLE or settled SONAR replay within240m with a clear line
- `simulation/blackwater_delivery.gd:55` [packet] **REJECTED-PREMISE?** (weak terms: carrier)
  >  · southern REPLY CARRIER announced; fixed relay remains available
- `simulation/blackwater_delivery.gd:106` [message] **OK**
  > Raw exchange buffer at lost craft position · recover the wreck or SAMPLE the fixed relay again
- `simulation/blackwater_delivery.gd:125` [name] **OK**
  >  + raw 
- `simulation/blackwater_delivery.gd:130` **OK**
  >  buffer
- `simulation/blackwater_delivery.gd:133` [reason] **OK**
  > Buffer unavailable
- `simulation/blackwater_delivery.gd:140` [reason] **OK**
  > Dive ended
- `simulation/blackwater_delivery.gd:141` [alive] **OK**
  > Craft lost
- `simulation/blackwater_delivery.gd:142` [reason] **OK**
  > This data is already aboard Quietus
- `simulation/blackwater_delivery.gd:143` [reason] **OK**
  > Recovery in progress
- `simulation/blackwater_delivery.gd:144` [reason] **OK**
  > Finish this craft's active work first
- `simulation/blackwater_delivery.gd:145` [RANGE] **NUMBER-SPACING** (at: within60m)
  > Move within60m
- `simulation/blackwater_delivery.gd:146` [reason] **OK**
  > Salvage requires its recorded depth band
- `simulation/blackwater_delivery.gd:147` [reason] **OK**
  > Terrain blocks recovery
- `simulation/blackwater_delivery.gd:148` [reason] **NUMBER-SPACING** (at: below2m/s)
  > Settle below2m/s
- `simulation/blackwater_delivery.gd:149` [else] **NUMBER-SPACING** (at: winch4s)
  > Recover raw buffer · audible winch4s
- `simulation/blackwater_delivery.gd:155` **OK**
  > RECOVERY WINCH
- `simulation/blackwater_delivery.gd:177` [message] **OK**
  > Buffer recovery interrupted
- `simulation/blackwater_delivery.gd:183` [message] **OK**
  > Raw buffer recovered · 
- `simulation/blackwater_delivery.gd:183` **OK**
  > aboard Quietus
- `simulation/blackwater_delivery.gd:183` [id] **OK**
  > local TRANSFER to Quietus still required

## Operation 3: Cold Foundry

- `campaign/opening_depth_operations.gd:28` [hint] **EXPLAINS-BEAT**
  > Cold front weakens sound · factory solid at all depths · deep motor is not cover.
- `campaign/opening_depth_operations.gd:29` [brief] **REJECTED-PREMISE** (terms: departing, departure)
  > Photograph FURNACE, then DEPARTURE CRADLE; recover Quietus beyond the southern wall. DEEP passes beneath the central spine, but the factory remains solid. The furnace sentinel holds MIDDLE; the recovery sentinel and departing motor work DEEP. The cold front weakens sound in addition to layer loss. Wait quietly for a crossing, or coordinate a drone sounding while Quietus moves. Use craft → DEPTH / SONAR; image and recover in MIDDLE.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > Cold Foundry
- `campaign/tutorial_missions.gd:7` [brief] **REJECTED-PREMISE** (terms: departure, shelter)
  > Enter from the western shelf. Our recovery buoy lies beyond the southern factory wall. First image the FURNACE VENT, then the DEPARTURE CRADLE. The basalt spine offers shelter; the industrial perimeter does not. Station guards hold the furnace and recovery channel. A live decoy can draw them out; they return when its signal ends. Cameras may provoke a carrier response. Plan Quietus’ passage before exposing the second record. Drones can take either photograph; the submarine remains your fallback.
- `campaign/tutorial_missions.gd:15` [record] **EXPLAINS-BEAT**
  > No weapons leave the furnaces. The machine is constructing vessels for a journey into deeper water.
- `campaign/tutorial_missions.gd:50` [name] **OK**
  > FURNACE VENT
- `campaign/tutorial_missions.gd:51` [evidence] **EXPLAINS-BEAT**
  > Molten material is drawn into smooth hollow forms. This is a construction line, not a weapon aperture.
- `campaign/tutorial_missions.gd:52` [name] **REJECTED-PREMISE** (terms: departure)
  > DEPARTURE CRADLE
- `campaign/tutorial_missions.gd:53` [requirement] **EXPLAINS-BEAT**
  > Record the furnace first. Its casting pattern will identify what the cradles contain.
- `campaign/tutorial_missions.gd:54` [evidence] **REJECTED-PREMISE?** (weak terms: hulls)
  > Long smooth hulls hang in open frames. No visible armament. An empty cradle opens toward the deeper trench. They are preparing to leave.
- `campaign/tutorial_missions.gd:80` [brief] **OK**
  >  A charted cold-water front crosses the southern channel. Sound and passive contacts weaken across it in both directions. Waiting west of it may protect a staging drone, but costs information and time. Close sight and visible beam charges still expose you; optical photography remains noisy.
- `campaign/tutorial_missions.gd:81` [brief] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departs, unarmed hull)
  >  The cradle motors warm up before one unarmed hull departs southeast. Its lit return is projected from below our operating depth: it is not cover or an obstacle. Listen locally and watch guard movement before choosing your crossing. Waiting costs time; a noisy early passage may need disruption. Sight still outranks the industrial sound.
- `simulation/foundry_departure.gd:22` **OK**
  > DEEP MOTOR

## Operation 4: The Listening Well

- `campaign/opening_depth_operations.gd:36` [hint] **OK**
  > Optional comparison: moving Quietus at MIDDLE aperture, then local MIDDLE receiver.
- `campaign/opening_depth_operations.gd:37` [brief] **OK**
  > Recover three perimeter records and return. SHALLOW clears western basalt but closes the southern record; DEEP clears the eastern wall under a sweeper. The fast hunter holds MIDDLE. An unverified archive is valid. Optional comparison: cruise Quietus past PROFILE APERTURE in MIDDLE after PATTERN, then receive near RETURN ARCHIVE in MIDDLE. A deep pass is no engine reference. Craft → DEPTH / SONAR compares received bearing history.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > The Listening Well
- `campaign/tutorial_missions.gd:8` [brief] **EXPLAINS-BEAT**
  > The well is listening to us. Collect three records from its circumference. A fast responder waits in the inner water. Noise draws it out; broken sight leaves it searching the last heard or seen position. Break sight before its beam resolves. Silence is a route, too.
- `campaign/tutorial_missions.gd:16` [record] **EXPLAINS-BEAT**
  > Our engine note appears in the next transmission. They have heard the lone pilot inside Quietus.
- `campaign/tutorial_missions.gd:91` [brief] **OK**
  > The well repeats an unassigned cadence. Recover three perimeter records and return. Its fast hunter follows real noise and sightings. Optional comparison: after recording the PATTERN ARRAY, cruise Quietus through clear water within 240m of the PROFILE APERTURE while MOTION NOISE shows QUIETUS. Then bring a live receiver within passive reach of the RETURN ARCHIVE. A drone can listen while Quietus makes its pass; Quietus can make the comparison alone. Remote records remain a valid unverified archive. No comparison is worth promising a safe escape.
- `campaign/tutorial_missions.gd:92` [record] **EXPLAINS-BEAT**
  > Well archive recovered · signature unverified. The returned cadence remains unassigned; no moving Quietus comparison was observed.
- `campaign/tutorial_missions.gd:93` [name] **OK**
  > PATTERN ARRAY
- `campaign/tutorial_missions.gd:94` [evidence] **EXPLAINS-BEAT**
  > UNASSIGNED CADENCE. This perimeter record contains a repeating pattern, not an identified speaker. Optional test: cruise Quietus past the PROFILE APERTURE within 240m and a clear line while its motion-noise instrument is active. Receive the local return near the RETURN ARCHIVE: Quietus within 240m or a live drone within 330m, with a clear line. Keep the remote archive without making this comparison, or risk a moving pass for a recorded match.
- `campaign/tutorial_missions.gd:95` [name] **OK**
  > PROFILE APERTURE
- `campaign/tutorial_missions.gd:95` [name] **OK**
  > RETURN ARCHIVE

## Operation 5: Siren's Song

- `campaign/opening_depth_operations.gd:44` [hint] **OK**
  > Two images → Quietus LISTEN 6s in MIDDLE lee → physical return with warning.
- `campaign/opening_depth_operations.gd:45` [brief] **OK**
  > Photograph TRANSMITTER CROWN and OUTBOUND WAKES; Quietus must LISTEN six seconds at LEE RECEIVER, then return with the warning. DEEP opens the central crossing but closes the southern lee; SHALLOW opens the eastern approach. Different patrols and a deep sweeper cover different layers. MIDDLE retains the covered lee route. Break sight to interrupt local reports; reports carry an old area and observed depth. Coordinate drones or take observations alone. Work and recover in MIDDLE.
- `campaign/tutorial_missions.gd:2` [TITLES] **OK**
  > Siren's Song
- `campaign/tutorial_missions.gd:9` [brief] **OK**
  > The transmission crown faces the trench; outbound wakes point deeper, away from us. Photograph both to separate their meanings. Bring Quietus through the southern basalt lee to the LEE RECEIVER and use CAMERA / LISTEN for six quiet seconds. Only the submarine carries the low-frequency hydrophones needed to resolve the packet. Drones can scout the exposed crown and wakes while Quietus moves under cover; the submarine can take either image if they are lost. Return to the western buoy with what you heard. Command will ask for targets. Bring evidence instead.
- `campaign/tutorial_missions.gd:17` [record] **EXPLAINS-BEAT**
  > The final packet describes a fracture below the mantle. The Sirens are leaving. Their song asks us to listen.
- `campaign/tutorial_missions.gd:56` [name] **OK**
  > TRANSMITTER CROWN
- `campaign/tutorial_missions.gd:57` [evidence] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier)
  > Nested resonator vanes point into the trench. Their repeated spacing matches a low-frequency carrier, not a gun aperture. The sound is directed below us.
- `campaign/tutorial_missions.gd:58` [name] **OK**
  > OUTBOUND WAKES
- `campaign/tutorial_missions.gd:59` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure, unarmed hulls)
  > Smooth unarmed hulls descend away from the shelf. Their wakes converge beyond a warm fracture in the trench floor. This is a departure route, not an attack vector.
- `campaign/tutorial_missions.gd:60` [name] **OK**
  > LEE RECEIVER
- `campaign/tutorial_missions.gd:61` [requirement] **OK**
  > Need both observations: TRANSMITTER CROWN + OUTBOUND WAKES.
- `campaign/tutorial_missions.gd:62` [unit_requirement] **OK**
  > Quietus hydrophones required · small drones cannot resolve this packet.
- `campaign/tutorial_missions.gd:63` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuating)
  > DECODED: a fracture is propagating below the mantle. The outbound hulls are evacuating, not assembling for attack. The carrier repeats the safe direction away from the fracture: listen, then leave.
- `campaign/tutorial_missions.gd:115` [brief] **OK**
  >  A Siren with clear sight can report a last-seen area to one nearby peer after 2s. Break sight to interrupt; disruption stops the report but its own noise can expose you. Reports travel through the local water, never the whole network.
- `main.gd:540` [discovery] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuating)
  > The crown points into the trench. Unarmed wakes lead away from the fracture. Quietus’ hydrophones resolve what the images could not: they are evacuating.\n\n
- `main.gd:541` **OK**
  > THE SONG CONTINUES\n\n
- `main.gd:541` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: fleet (human fleet))
  > You return with a warning, not a firing solution. Above you, the fleet waits for orders. Below, the foundry lights go dark, one by one. For the first time since descent, Quietus hears only the ocean.\n\nIntroductory arc complete. Every dive remains replayable.
- `main.gd:542` **OK**
  > BEYOND THE WARNING / THE DIVERGENCE

## Operation 6: The Divergence

- `campaign/divergence_missions.gd:5` [title] **OK**
  > The Divergence
- `campaign/divergence_missions.gd:11` **REJECTED-PREMISE?** (weak terms: carrier)
  > DEEP CARRIER
- `campaign/divergence_missions.gd:11` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berths, evacuation)
  > The carrier repeats evacuation berths and a depth corridor. A rendezvous lies beyond the northeastern descent. It is a route to investigate, not proof of an ally.
- `campaign/divergence_missions.gd:11` **OK**
  > SHELFWARD ECHO
- `campaign/divergence_missions.gd:11` **REJECTED-PREMISE** (terms: inhabited)
  > The shelfward echo repeats a verified fracture warning toward an old receiving station. A western shelf corridor may let Quietus carry the packet back toward inhabited water.
- `campaign/divergence_missions.gd:12` [name] **OK**
  > DEEP DESCENT
- `campaign/divergence_missions.gd:12` [name] **OK**
  > SHELF PASSAGE
- `campaign/divergence_missions.gd:13` [brief] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure)
  > Beyond the tutorial warning, two carriers diverge through charted basalt. Their sources are not located. Listen in the western shelf water and northeastern trench; received direction may bend around rock. Separate drone listening positions can guide Quietus through the central lee. Close passive observation or a finite local RECON survey identifies a source immediately. Investigate either or both, then take Quietus through the corresponding DEEP DESCENT or SHELF PASSAGE. Your physical exit selects the next expedition; both facts remain if found. Returning to the southern recovery basin after departure is an incomplete withdrawal.
- `campaign/divergence_missions.gd:14` [record] **EXPLAINS-BEAT**
  > The warning leads in two directions. Quietus recovered a physical route, not a target order.

## Operation 7: Deep Rendezvous

- `campaign/divergence_missions.gd:5` **REJECTED-PREMISE?** (weak terms: rendezvous)
  > Deep Rendezvous
- `campaign/divergence_missions.gd:20` **REJECTED-PREMISE** (terms: berthing)
  > BERTHING CARRIER
- `campaign/divergence_missions.gd:20` **REJECTED-PREMISE** (terms: berthing, evacuation, unarmed hulls)
  > Unarmed hulls exchange low berthing corrections. The rendezvous is assembling an evacuation line farther down the trench.
- `campaign/divergence_missions.gd:24` [name] **OK**
  > NORTH TRENCH RECOVERY
- `campaign/divergence_missions.gd:25` [brief] **REJECTED-PREMISE** (terms: berth, berthing, evacuation)
  > Enter from the lower trench. Locate the berthing carrier in the western basin, then bring Quietus within clear receiver reach and use CAMERA / LISTEN to confirm the evacuation rendezvous. Drones can find its carrier while Quietus crosses the covered central saddle. Recovery lies north, beyond the berth. The long southern wall separates the lower staging basin from the central saddle. A drone can watch its western tip while Quietus crosses.
- `campaign/divergence_missions.gd:26` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuation)
  > Deep rendezvous confirmed: the hulls are organizing an evacuation, but the destination remains unresolved. Quietus has a route farther down the trench.
- `campaign/divergence_missions.gd:30` [brief] **REJECTED-PREMISE** (terms: berthing)
  >  A sentinel holds the berthing basin and returns to its post after an investigation.
- `campaign/divergence_missions.gd:31` [brief] **REJECTED-PREMISE** (terms: berth, refuge)
  >  The packet is aboard a physical unarmed tender. It stays at the berth unless you explicitly RELEASE BERTH from the locally discovered control. That one audible control transmission sends it along the announced western lane to the northern refuge, where it remains available. A drone can operate the control while Quietus stages elsewhere; Quietus can operate it alone. Quiet reception at the original berth also works. Survey locates nearby hulls and machinery; a measured vessel fix grows stale when no receiver can still sense it.
- `presentation/rendezvous_view.gd:13` [label] **REJECTED-PREMISE** (terms: berthing)
  > BERTHING HULL · 
- `presentation/rendezvous_view.gd:13` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST HULL FIX · STALE %ds
- `presentation/rendezvous_view.gd:30` [name] **REJECTED-PREMISE** (terms: berth)
  > BERTH CONTROL
- `presentation/rendezvous_view.gd:30` **REJECTED-PREMISE** (terms: berthing)
  > BERTHING HULL
- `presentation/rendezvous_view.gd:30` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST HULL FIX
- `presentation/rendezvous_view.gd:31` [text] **REJECTED-PREMISE** (terms: refuge)
  > RELEASED · REFUGE COURSE
- `presentation/rendezvous_view.gd:31` **OK**
  > RELEASE · AUDIBLE 950m / 6s
- `presentation/rendezvous_view.gd:31` **OK**
  >  · LOCAL FIX
- `presentation/rendezvous_view.gd:31` **OK**
  > STALE · %ds AGO
- `presentation/rendezvous_view.gd:40` [name] **REJECTED-PREMISE** (terms: berth)
  > BERTH CONTROL
- `presentation/rendezvous_view.gd:42` [name] **REJECTED-PREMISE** (terms: berthing)
  > BERTHING HULL
- `presentation/rendezvous_view.gd:42` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST HULL FIX
- `presentation/rendezvous_view.gd:48` [copy] **REJECTED-PREMISE** (terms: berthing)
  > BERTHING HULL
- `presentation/rendezvous_view.gd:48` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST HULL FIX
- `presentation/rendezvous_view.gd:54` [known] **REJECTED-PREMISE** (terms: berth)
  > Locate the berth control locally or with Survey.
- `presentation/rendezvous_view.gd:55` **REJECTED-PREMISE** (terms: berth)
  > BERTH CONTROL\n
- `presentation/rendezvous_view.gd:55` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berth, refuge)
  > \nRELEASE BERTH · AUDIBLE %dm / %ds\nWithin %dm · clear link · settled below 12m/s.\nOne release starts the tender's announced course to the permanent northern refuge. The course is not a live tracker. Quiet berth decode also remains available.
- `presentation/rendezvous_view.gd:58` **REJECTED-PREMISE?** (weak terms: hull)
  > CURRENT HULL · 
- `presentation/rendezvous_view.gd:58` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST HULL FIX · STALE %ds · position at last measurement
- `presentation/rendezvous_view.gd:59` **REJECTED-PREMISE?** (weak terms: hull)
  > Quietus decodes in 4s within 240m of the actual hull, with clear local reception and speed below 12m/s. A last fix is an approach reference; reacquire to decode.
- `presentation/rendezvous_view.gd:64` [lines] **REJECTED-PREMISE?** (weak terms: hull)
  > LOCAL HULL RECEPTION
- `presentation/rendezvous_view.gd:64` **REJECTED-PREMISE?** (weak terms: hull)
  > HULL RECEPTION UNAVAILABLE
- `presentation/rendezvous_view.gd:65` **OK**
  > LOCAL RANGE · %dm
- `presentation/rendezvous_view.gd:66` **OK**
  > PASSIVE DECODE · 4s
- `presentation/rendezvous_view.gd:66` [unit] **OK**
  > QUIETUS HYDROPHONES REQUIRED
- `presentation/rendezvous_view.gd:75` **REJECTED-PREMISE** (terms: refuge)
  > PERMANENT NORTH REFUGE
- `presentation/rendezvous_view.gd:76` **OK**
  > ANNOUNCED TENDER COURSE
- `presentation/rendezvous_view.gd:88` **REJECTED-PREMISE** (terms: berth)
  > BERTH RELEASED
- `presentation/rendezvous_view.gd:88` **REJECTED-PREMISE** (terms: berth)
  > BERTH CONTROL
- `simulation/rendezvous_transport.gd:56` [reason] **REJECTED-PREMISE** (terms: berth)
  > Locate the berth control locally or with Survey
- `simulation/rendezvous_transport.gd:60` [reason] **OK**
  > Dive ended
- `simulation/rendezvous_transport.gd:61` [used] **REJECTED-PREMISE** (terms: berth, refuge)
  > Berth released · announced refuge remains available
- `simulation/rendezvous_transport.gd:62` [alive] **OK**
  > Craft lost
- `simulation/rendezvous_transport.gd:63` [reason] **OK**
  > Finish this craft's packet reception first
- `simulation/rendezvous_transport.gd:64` [CONTROL_RANGE] **REJECTED-PREMISE NUMBER-SPACING** (terms: berth; at: within120m)
  > Reach berth control within120m
- `simulation/rendezvous_transport.gd:65` [reason] **OK**
  > Cover blocks the control link
- `simulation/rendezvous_transport.gd:66` [reason] **NUMBER-SPACING** (at: below12m/s)
  > Settle below12m/s
- `simulation/rendezvous_transport.gd:67` [else] **REJECTED-PREMISE NUMBER-SPACING** (terms: berth, refuge; at: audible950m)
  > RELEASE BERTH · audible950m /6s · tender goes to north refuge
- `simulation/rendezvous_transport.gd:74` **REJECTED-PREMISE** (terms: berth)
  > BERTH RELEASE
- `simulation/rendezvous_transport.gd:75` [message] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berth, departs, refuge)
  > Berth released · tender departs toward northern refuge · machinery audible; route is announced, not a live tracker
- `simulation/rendezvous_transport.gd:90` [text] **REJECTED-PREMISE?** (weak terms: hull, rendezvous)
  > Locate the rendezvous hull or use local Survey
- `simulation/rendezvous_transport.gd:92` [captured] **REJECTED-PREMISE?** (weak terms: rendezvous)
  > Rendezvous packet aboard · return Quietus to recovery
- `simulation/rendezvous_transport.gd:93` [text] **REJECTED-PREMISE?** (weak terms: rendezvous)
  > Quietus hydrophones must decode the rendezvous packet
- `simulation/rendezvous_transport.gd:94` [local] **REJECTED-PREMISE?** (weak terms: carrier)
  > Regain local carrier reception · measured fixes can become stale
- `simulation/rendezvous_transport.gd:95` [text] **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: hull; at: within240m)
  > Bring Quietus within240m of the actual hull
- `simulation/rendezvous_transport.gd:96` [settled] **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: rendezvous; at: below12m/s)
  > Settle below12m/s to decode the rendezvous packet
- `simulation/rendezvous_transport.gd:97` [else] **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: hull, rendezvous; at: decode4s)
  > READY · RENDEZVOUS HULL · passive decode4s

## Operation 8: Shelf Return

- `campaign/divergence_missions.gd:5` **OK**
  > Shelf Return
- `campaign/divergence_missions.gd:37` [brief] **OK**
  >  A fast hunter listens along the eastern approach; cover breaks its visual pursuit.
- `presentation/shelf_habitat_view.gd:7` [name] **OK**
  > COMMUNAL RESONATOR
- `presentation/shelf_habitat_view.gd:15` [name] **OK**
  > COMMUNAL RESONATOR
- `presentation/shelf_habitat_view.gd:40` [result] **REJECTED-PREMISE** (terms: shelter)
  > SHELTER REPLIES ·%d/2\n
- `presentation/shelf_habitat_view.gd:41` [alarm] **OK**
  > COMMUNAL RESONATOR\n
- `presentation/shelf_habitat_view.gd:41` **REJECTED-PREMISE? NUMBER-SPACING** (weak terms: galleries; at: One1200m/)
  > \nOne1200m/8s audible common call. Actual water paths decide which galleries receive it; listen for their returning replies. A shorter work route, with a hunter's real investigation risk. Local warnings remain available.
- `presentation/shelf_habitat_view.gd:44` **REJECTED-PREMISE NUMBER-SPACING** (terms: berths; at: below2m/s, local140m, within100m)
  > \nOccupied berths and maintenance platforms sit behind these pressure windows. Quietus can warn within100m, clear line, settled below2m/s. A small local140m pulse serves only this gallery; the second requires another close approach.\n
- `presentation/shelf_habitat_view.gd:44` **REJECTED-PREMISE** (terms: shelter)
  > Watch the resident work-lights withdraw and listen for their shelter account. The longer outer return keeps passive information; the short exhaust trench masks both sides.
- `presentation/shelf_habitat_view.gd:82` **OK**
  > EXHAUST FRONT · MUTUAL MASK
- `presentation/shelf_habitat_view.gd:128` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE SEALED
- `presentation/shelf_habitat_view.gd:128` **REJECTED-PREMISE** (terms: occupied)
  > OCCUPIED GALLERY
- `presentation/shelf_habitat_view.gd:128` **OK**
  >  · LAST OBSERVATION
- `presentation/shelf_habitat_view.gd:135` **OK**
  > ONE AUDIBLE ALARM
- `presentation/shelf_habitat_view.gd:135` **OK**
  > WARN / RECEIVE
- `simulation/shelf_habitat.gd:6` [name] **REJECTED-PREMISE?** (weak terms: gallery)
  > UPPER GALLERY
- `simulation/shelf_habitat.gd:6` [name] **REJECTED-PREMISE?** (weak terms: gallery)
  > LOWER GALLERY
- `simulation/shelf_habitat.gd:7` [ACCOUNT] **REJECTED-PREMISE** (terms: berths, nurseries, occupied, shelter, shelters)
  > The work-lights go behind pressure shutters. The returning account lists occupied sleeping berths and warm-water nurseries, not firing coordinates. The shelf shelters cannot abandon their pressure-rated homes at once: this warning buys time to seal them. Carry the acknowledged shelter call onward to the warning plant.
- `simulation/shelf_habitat.gd:15` [name] **REJECTED-PREMISE** (terms: shelter)
  > SHELTER ACKNOWLEDGEMENTS
- `simulation/shelf_habitat.gd:16` [name] **OK**
  > WEST SHELF RECOVERY
- `simulation/shelf_habitat.gd:17` [brief] **REJECTED-PREMISE NUMBER-SPACING EXPLAINS-BEAT** (terms: inhabited, refuge, shelter; at: its1200m)
  > Terrace windows beyond the shelf receiver still draw power. Carry Quietus’s fracture warning into this inhabited refuge. Visit both gallery listening lips for quiet local delivery, or sound the charted COMMUNAL RESONATOR once: its1200m call offers a shorter work route but draws the hunter. A sent warning alone is not a returned shelter account; hear both replies. Drones can discover the galleries and watch approaches. The shorter inner return crosses a mutually masking exhaust front; the longer outer contour preserves passive information. Bring Quietus and the shelter acknowledgements to western recovery.
- `simulation/shelf_habitat.gd:18` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berths, occupied, shelter)
  > Two occupied galleries answered the fracture warning. Their pressure shutters closed over living berths; Quietus carries a shelter call toward human water, not an empty station's firing coordinates.
- `simulation/shelf_habitat.gd:26` **OK**
  > Dive ended
- `simulation/shelf_habitat.gd:27` **REJECTED-PREMISE** (terms: occupied)
  > Quietus carries the verified warning; drones can scout the occupied mouths
- `simulation/shelf_habitat.gd:28` [alive] **OK**
  > Quietus lost
- `simulation/shelf_habitat.gd:29` [range] **NUMBER-SPACING** (at: currently%dm, within%dm)
  > Bring Quietus within%dm · currently%dm
- `simulation/shelf_habitat.gd:30` **OK**
  > Terrain blocks the local connection
- `simulation/shelf_habitat.gd:31` **NUMBER-SPACING** (at: below2m/s)
  > Settle below2m/s
- `simulation/shelf_habitat.gd:32` **OK**
  > Finish Quietus's active work
- `simulation/shelf_habitat.gd:41` [receipts] **REJECTED-PREMISE** (terms: shelter)
  > Shelter acknowledgement aboard
- `simulation/shelf_habitat.gd:42` [reason] **OK**
  > Residents closing pressure shutters · listen for the local reply
- `simulation/shelf_habitat.gd:43` [reason] **REJECTED-PREMISE NUMBER-SPACING** (terms: occupied; at: ·100m)
  > LOCAL WARNING ·100m direct pulse · one occupied gallery
- `simulation/shelf_habitat.gd:45` [alarm_used] **OK**
  > Common alarm spent · local warnings remain available
- `simulation/shelf_habitat.gd:46` [reason] **NUMBER-SPACING** (at: ·1200m/8s)
  > SOUND ALARM ·1200m/8s audible · one use
- `simulation/shelf_habitat.gd:46` [account] **REJECTED-PREMISE** (terms: occupied, shelter)
  > Two occupied galleries · return their shelter acknowledgements
- `simulation/shelf_habitat.gd:53` [message] **REJECTED-PREMISE** (terms: occupied)
  > Locate the occupied gallery with a live receiver first
- `simulation/shelf_habitat.gd:55` [reason] **REJECTED-PREMISE?** (weak terms: gallery)
  > Gallery already warned · listen for its reply
- `simulation/shelf_habitat.gd:58` [alarm_used] **OK**
  > Common alarm already spent · local warnings remain available
- `simulation/shelf_habitat.gd:68` **REJECTED-PREMISE** (terms: shelter)
  > LOCAL SHELTER WARNING
- `simulation/shelf_habitat.gd:68` **REJECTED-PREMISE** (terms: shelter)
  > COMMON SHELTER ALARM
- `simulation/shelf_habitat.gd:70` [message] **REJECTED-PREMISE?** (weak terms: gallery)
  > Local warning sent · listen for the gallery's reply
- `simulation/shelf_habitat.gd:70` **REJECTED-PREMISE** (terms: shelter)
  > Common alarm sounded · hunter can hear · listen for two shelter replies
- `simulation/shelf_habitat.gd:82` [first] **REJECTED-PREMISE** (terms: occupied)
  >  occupied · moving work-lights behind pressure windows · Quietus can warn locally
- `simulation/shelf_habitat.gd:100` [message] **REJECTED-PREMISE** (terms: berths, occupied, shelter)
  >  shelter reply received · occupied berths sealed
- `simulation/shelf_habitat.gd:104` [message] **REJECTED-PREMISE** (terms: occupied, shelter)
  > Both occupied galleries answered · shelter account aboard · choose the masked inner trench or the longer outer return
- `simulation/shelf_habitat.gd:109` **REJECTED-PREMISE?** (weak terms: galleries)
  > Both galleries received the common alarm and answered.
- `simulation/shelf_habitat.gd:109` **REJECTED-PREMISE?** (weak terms: galleries)
  > Both galleries received close local warnings and answered.
- `simulation/shelf_habitat.gd:109` **REJECTED-PREMISE?** (weak terms: galleries)
  > The common call and a close local warning reached both galleries; both answered.

## Operation 9: Wake Crossing

- `campaign/onward_missions.gd:10` [title] **OK**
  > Wake Crossing
- `campaign/onward_missions.gd:11` [name] **OK** (also used by op 10)
  > NORTH WATER RECOVERY
- `campaign/onward_missions.gd:15` [label] **OK**
  > RETURN RECEIVER
- `campaign/onward_missions.gd:15` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuation)
  > The measured return cadence belongs to a moving evacuation network. Quietus recovers the onward wake corridor without publishing its hull positions.
- `campaign/onward_missions.gd:15` [label] **OK**
  > ABANDONED REPEATER
- `campaign/onward_missions.gd:15` [evidence] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: hull)
  > A surviving repeater carries an older unequal cadence. Its close packet identifies it as an empty branch; cadence resemblance alone would never prove a friendly hull.
- `campaign/onward_missions.gd:18` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berthing, berths, departure, evacuation, families)
  > The measured return is a private berthing correction, not a hull address. The old eastern departure call was deliberately left in emptied berths while families took this lane. Automatic watchers still exchange sightings across the northern saddle; the evacuation and its watch machinery no longer serve the same purpose.
- `campaign/onward_missions.gd:19` [evidence] **REJECTED-PREMISE** (terms: berth)
  >  Your recovered tender account used this same correction channel at the berth; the old public call served a different road.
- `campaign/onward_missions.gd:20` [brief] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berthing)
  > Find the live return receiver, recover its onward packet with Quietus, then cross to northern recovery. Two unlabeled carriers reach the southern lee. A fitted berthing correlator can compare the recovered RETURN reference after six settled seconds; without it, close scouting or finite RECON still identifies either source. Neither cadence nor a bearing guarantees safety. The eastern old call may offer a local diversion; inspect its hardware before spending it. Reserve air for the crossing and any independent drone's return.
- `campaign/onward_missions.gd:21` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berths, families)
  > The empty eastern berths were deliberately left calling while families used the private return lane. Their automatic watchers still trade local sightings. An abandoned call can be useful cover without becoming a friendly vessel; the onward packet and Quietus have crossed that watch line.
- `campaign/onward_missions.gd:26` [brief] **OK**
  >  A patrol and northern hunter can report local sightings. The long western outside water remains a solo route without tools or playback.
- `presentation/wake_crossing_view.gd:9` [name] **REJECTED-PREMISE** (terms: departure)
  > OLD DEPARTURE LOOP
- `presentation/wake_crossing_view.gd:17` **REJECTED-PREMISE** (terms: departure)
  > OLD DEPARTURE LOOP · ONE USE\n
- `presentation/wake_crossing_view.gd:17` **OK**
  > PLAYBACK TIMER ·%ds from your local order\n
- `presentation/wake_crossing_view.gd:17` **NUMBER-SPACING** (at: after2, below2m/s, lasts15s, within65m)
  > \n\nAny bare craft can connect within65m, clear line, below2m/s. One1100m open-water emission lasts15s; basalt can weaken or block it. Ordinary listeners may investigate its water, but current sight and louder evidence take priority. No guard response is guaranteed. Time it against your own crossing, then recover the operator. A watch with sight can report after2 uninterrupted seconds; cover or disruption cancels. A reached peer searches a coarse old point, not your live position. The longer outer water remains available without playback or tools.
- `presentation/wake_crossing_view.gd:39` **OK**
  > OLD LOOP ·%ds
- `presentation/wake_crossing_view.gd:39` **REJECTED-PREMISE** (terms: berths)
  > EMPTY BERTHS · ONE PLAYBACK
- `presentation/wake_crossing_view.gd:39` **OK**
  > OLD LOOP · PLAYBACK SPENT
- `simulation/wake_crossing.gd:8` [ACCOUNT] **REJECTED-PREMISE** (terms: berths, departure, families, keeper)
  > KEEPER'S LAST LOOP: I left the empty berths calling. The families took the measured return lane, not this old departure road. One charge remains in the repeater. Let the watchers come to an empty mouth while you cross, if that buys you water. Once it falls silent, I cannot call them back.
- `simulation/wake_crossing.gd:15` [reason] **OK**
  > Locate the old repeater locally or with finite Survey
- `simulation/wake_crossing.gd:19` [used] **OK**
  > Last playback spent · no recharge or remote repeat
- `simulation/wake_crossing.gd:20` [alive] **OK**
  > Craft unavailable
- `simulation/wake_crossing.gd:21` [LOCAL_RANGE] **NUMBER-SPACING** (at: within65m)
  > Bring any craft within65m of the repeater
- `simulation/wake_crossing.gd:22` [reason] **OK**
  > Rock blocks the local repeater connection
- `simulation/wake_crossing.gd:23` [reason] **NUMBER-SPACING** (at: below2m/s)
  > Settle below2m/s before starting the one-use playback
- `simulation/wake_crossing.gd:24` [reason] **OK**
  > Finish this craft's current work first
- `simulation/wake_crossing.gd:25` [else] **NUMBER-SPACING** (at: ·1100m)
  > PLAY OLD LOOP ONCE ·1100m open-water sound /15s · may draw ordinary listeners; sight still wins
- `simulation/wake_crossing.gd:33` **REJECTED-PREMISE** (terms: departure)
  > OLD DEPARTURE LOOP
- `simulation/wake_crossing.gd:36` [message] **REJECTED-PREMISE NUMBER-SPACING** (terms: berths, departure; at: one15s)
  > Old departure loop plays from the empty eastern berths · one15s transmission · listen for actual watch movement

## Operation 10: Warning Chain

- `campaign/onward_missions.gd:10` **OK**
  > Warning Chain
- `campaign/onward_missions.gd:11` [name] **OK** (also used by op 9)
  > NORTH WATER RECOVERY
- `campaign/onward_missions.gd:31` **OK**
  > WEST SERVICE INLET
- `campaign/onward_missions.gd:31` **OK**
  > The preparations belong to one warning plant. A local craft can supply its service bus; the backup generator frees that body but discloses the western inlet.
- `campaign/onward_missions.gd:31` **OK**
  > EAST ROUTING PANEL
- `campaign/onward_missions.gd:31` **EXPLAINS-BEAT**
  > The powered panel can route a narrow service warning across the shutter or energize the northern mast. A service receipt proves one local branch; mast telemetry proves transmission, not an external audience.
- `campaign/onward_missions.gd:31` **OK**
  > WARNING PLANT OPERATING RECORD
- `campaign/onward_missions.gd:31` **EXPLAINS-BEAT**
  > The warning plant was commissioned. The returned operating record distinguishes a verified local service receipt from a mast transmission with external reception unknown.
- `campaign/onward_missions.gd:33` [name] **OK**
  > WEST SERVICE RECOVERY
- `campaign/onward_missions.gd:34` [brief] **NUMBER-SPACING EXPLAINS-BEAT** (at: within60m)
  > The shelf warning has reached an unpowered industrial relay plant. At WEST SERVICE INLET, CONNECT any settled craft within60m: that body's umbilical powers the distant panel until it releases, moves or is lost. START BACKUP is the complete solo alternative; one audible generator start frees the power craft. At EAST ROUTING PANEL, Quietus or a recovered fitted field sampler can select the output and SEND WARNING through the powered plant. SERVICE opens a real water and sound crosslink and sends from EAST; the western branch must actually receive it. NORTH MAST sends from northern hardware; its telemetry proves transmission, while external reception stays unknown. No camera hold is needed. Once commissioned, disconnect the helper and choose north or west service recovery. Both routes lead onward; an equipped craft still has its ordinary recovery stakes.
- `campaign/onward_missions.gd:35` [brief] **REJECTED-PREMISE** (terms: occupied)
  >  The occupied galleries have already answered: 
- `campaign/onward_missions.gd:35` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: shelter)
  >  Their shelter call now needs the onward plant; these receivers are not empty infrastructure.
- `campaign/onward_missions.gd:36` [record] **EXPLAINS-BEAT**
  > The warning plant works again. Its operating record preserves exactly what Quietus proved: a local service acknowledgement or a northern mast transmission whose wider audience remains unknown.
- `campaign/onward_missions.gd:40` [brief] **OK**
  >  A sentinel defends the western preparation; the eastern arm is patrolled.
- `presentation/warning_chain_view.gd:24` [reason] **OK**
  > Plant unavailable
- `presentation/warning_chain_view.gd:26` [umbilical] **OK**
  > POWER 
- `presentation/warning_chain_view.gd:26` **OK**
  > DRONE 
- `presentation/warning_chain_view.gd:27` **OK**
  > POWER OFF
- `presentation/warning_chain_view.gd:30` [local_receipt] **OK**
  > LOCAL RECEIPT · WEST
- `presentation/warning_chain_view.gd:31` [mast_transmission] **OK**
  > MAST SENT · EXTERNAL UNKNOWN
- `presentation/warning_chain_view.gd:32` **OK**
  >  SENT · NO RECEIPT
- `presentation/warning_chain_view.gd:33` **OK**
  > NORTH MAST
- `presentation/warning_chain_view.gd:33` **OK**
  >  · NOT SENT
- `presentation/warning_chain_view.gd:33` **OK**
  > OUTPUT UNSELECTED
- `presentation/warning_chain_view.gd:35` [local_receipt] **OK**
  > WEST RECEIPT
- `presentation/warning_chain_view.gd:36` [mast_transmission] **OK**
  > MAST TX · RX UNKNOWN
- `presentation/warning_chain_view.gd:37` **OK**
  > SENT · NO RECEIPT
- `presentation/warning_chain_view.gd:38` **OK**
  >  · NOT SENT
- `presentation/warning_chain_view.gd:38` **OK**
  > OUTPUT UNSELECTED
- `presentation/warning_chain_view.gd:41` **OK**
  > PLANT 
- `presentation/warning_chain_view.gd:45` [unit] **OK**
  > SHORE POWER · CONNECTED
- `presentation/warning_chain_view.gd:49` [lines] **OK**
  > LOCAL CONTROL · within 60m · clear line · settled below 2m/s
- `presentation/warning_chain_view.gd:50` [inlet] **OK**
  > CONNECT supplies quiet shore power while this craft holds its retained course. DISCONNECT or an accepted movement order releases it. START BACKUP runs independently: one audible 900m / 6s start.
- `presentation/warning_chain_view.gd:51` [else] **OK**
  > Quietus or a fitted field sampler operates this panel. OPEN SERVICE opens the physical crosslink once; NORTH MAST preserves its current opening. Selecting an output does not send. Use SEND WARNING separately.
- `presentation/warning_chain_view.gd:53` [backup] **OK**
  > START BACKUP
- `presentation/warning_chain_view.gd:53` [service] **OK**
  > OPEN SERVICE
- `presentation/warning_chain_view.gd:53` [mast] **OK**
  > NORTH MAST
- `presentation/warning_chain_view.gd:53` [send] **OK**
  > SEND WARNING
- `presentation/warning_chain_view.gd:54` **OK**
  > CROSSLINK · 
- `presentation/warning_chain_view.gd:56` **OK**
  > SERVICE / EAST PANEL
- `presentation/warning_chain_view.gd:56` **OK**
  > NORTH MAST
- `presentation/warning_chain_view.gd:56` **OK**
  >  · %dm / %ds · 
- `presentation/warning_chain_view.gd:56` **OK**
  > local receipt required
- `presentation/warning_chain_view.gd:56` **OK**
  > transmission only; external reception unknown
- `presentation/warning_chain_view.gd:57` **OK**
  > COMMISSIONED · 
- `presentation/warning_chain_view.gd:57` **OK**
  > . Power may be released; recover Quietus by either mouth.
- `presentation/warning_chain_view.gd:62` **OK**
  > PLANT RESULT / 
- `presentation/warning_chain_view.gd:62` **OK**
  > PLANT NOT COMMISSIONED / no warning result recovered
- `presentation/warning_chain_view.gd:80` [pos] **OK**
  > BACKUP GENERATOR START
- `presentation/warning_chain_view.gd:80` **OK**
  > SERVICE SHUTTER
- `presentation/warning_chain_view.gd:80` **OK**
  > SERVICE WARNING
- `presentation/warning_chain_view.gd:80` **OK**
  > NORTH MAST WARNING
- `presentation/warning_chain_view.gd:81` **OK**
  >  · %dm / %ds
- `presentation/warning_chain_view.gd:90` [text] **OK**
  > CROSSLINK 
- `presentation/warning_chain_view.gd:94` [text] **OK**
  > WEST INLET · BACKUP
- `presentation/warning_chain_view.gd:94` **OK**
  > EAST PANEL · WARNING
- `presentation/warning_chain_view.gd:98` [text] **OK**
  > NORTH MAST · TX / RX UNKNOWN
- `presentation/warning_chain_view.gd:98` **OK**
  > NORTH MAST · SELECTED
- `presentation/warning_chain_view.gd:98` **OK**
  > NORTH MAST
- `presentation/warning_chain_view.gd:123` **OK**
  > BACKUP GENERATOR START
- `presentation/warning_chain_view.gd:123` **OK**
  > SERVICE SHUTTER
- `presentation/warning_chain_view.gd:123` **OK**
  > SERVICE WARNING
- `presentation/warning_chain_view.gd:123` **OK**
  > NORTH MAST WARNING
- `presentation/warning_chain_view.gd:124` [remaining] **OK**
  > SERVICE SHUTTER
- `simulation/warning_chain.gd:17` [alive] **OK**
  > Craft lost
- `simulation/warning_chain.gd:18` **OK**
  > MIDDLE band and settled depth required
- `simulation/warning_chain.gd:19` [RANGE] **NUMBER-SPACING** (at: within60m)
  > Move within60m of this plant station
- `simulation/warning_chain.gd:20` **OK**
  > Terrain blocks the local plant connection
- `simulation/warning_chain.gd:21` **NUMBER-SPACING** (at: below2m/s)
  > Settle below2m/s
- `simulation/warning_chain.gd:22` **OK**
  > Finish this craft's active work first
- `simulation/warning_chain.gd:26` [reason] **OK**
  > Dive ended
- `simulation/warning_chain.gd:28` [reason] **OK**
  > This craft has no plant umbilical
- `simulation/warning_chain.gd:29` [reason] **OK**
  > Plant already commissioned · choose recovery
- `simulation/warning_chain.gd:31` [backup] **OK**
  > Backup already running
- `simulation/warning_chain.gd:32` [umbilical] **OK**
  > A craft already supplies the plant
- `simulation/warning_chain.gd:35` [HOLD] **OK**
  > Release this craft's conditional hold first
- `simulation/warning_chain.gd:37` [drone_sampler] **OK**
  > Quietus or a fitted field sampler must operate this panel
- `simulation/warning_chain.gd:38` [off] **OK**
  > Plant unpowered · CONNECT a craft or START BACKUP at WEST
- `simulation/warning_chain.gd:43` [reason] **OK**
  > Select SERVICE or NORTH MAST first
- `simulation/warning_chain.gd:44` [sends] **OK**
  > This output has already activated · select the other branch
- `simulation/warning_chain.gd:45` [output] **OK**
  > Output already selected
- `simulation/warning_chain.gd:47` [connect] **OK**
  > CONNECT · quiet own-body shore supply
- `simulation/warning_chain.gd:47` [disconnect] **OK**
  > DISCONNECT · release retained course
- `simulation/warning_chain.gd:47` [backup] **NUMBER-SPACING** (at: audible900m/)
  > START BACKUP · audible900m/6s, once
- `simulation/warning_chain.gd:47` [service] **OK**
  > SERVICE · open water/sound crosslink
- `simulation/warning_chain.gd:47` [mast] **OK**
  > NORTH MAST · preserve a closed crosslink
- `simulation/warning_chain.gd:47` [send] **OK**
  > SEND WARNING · finite physical output
- `simulation/warning_chain.gd:51` [s] **OK**
  > Plant unpowered · CONNECT at WEST or START BACKUP
- `simulation/warning_chain.gd:52` [off] **OK**
  > Powered %s · configure and send at EAST
- `simulation/warning_chain.gd:52` **OK**
  > by backup
- `simulation/warning_chain.gd:53` [text] **OK**
  > Western service branch received the warning
- `simulation/warning_chain.gd:53` **OK**
  > North mast transmitted · external reception unknown
- `simulation/warning_chain.gd:53` **OK**
  >  · recover Quietus
- `simulation/warning_chain.gd:56` [name] **OK**
  > WEST SERVICE INLET
- `simulation/warning_chain.gd:56` [name] **OK**
  > EAST ROUTING PANEL
- `simulation/warning_chain.gd:75` [unit] **OK**
  > BACKUP GENERATOR START
- `simulation/warning_chain.gd:79` [opened] **OK**
  > SERVICE SHUTTER
- `simulation/warning_chain.gd:83` **OK**
  > SERVICE WARNING
- `simulation/warning_chain.gd:83` **OK**
  > NORTH MAST WARNING
- `simulation/warning_chain.gd:87` [message] **OK**
  > No service receipt · the powered NORTH MAST remains available
- `simulation/warning_chain.gd:89` [record] **EXPLAINS-BEAT**
  > SERVICE RECEIPT / The western branch received this warning through the opened crosslink. One local acknowledgement is proved; the wider population remains unobserved.
- `simulation/warning_chain.gd:89` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: inhabited)
  > MAST TRANSMISSION / Powered northern hardware sent the warning; external reception unknown. Quietus recovered a transmission record, not proof that an inhabited shore answered.
- `simulation/warning_chain.gd:99` [message] **OK**
  > Shore supply disconnected · reconnect a craft or START BACKUP at WEST

## Operation 11: Confluence

- `campaign/confluence_region.gd:23` **OK**
  > LIVE FACTORY DISPATCH
- `campaign/confluence_region.gd:23` **REJECTED-PREMISE** (terms: departure, evacuation, witness)
  > The factory dispatch joins an evacuation memory to the human fracture warning. The immense casting line is making departure hulls. Quietus can carry this out as a concealed witness record or forward it through the open warning chain; neither choice makes the return water safe.
- `campaign/confluence_region.gd:24` [repeater_played] **REJECTED-PREMISE** (terms: berths, departure, families, occupied)
  >  Your Wake log records that you spent the old loop at empty berths. This live dispatch names occupied departure cradles instead: the same network kept a false road calling while its families moved.
- `campaign/confluence_region.gd:25` **OK**
  > OLD SERVICE REPEATER
- `campaign/confluence_region.gd:25` **OK**
  > This is an old dispatch, not the living factory memory. Its local service circuit controls the sealed cross-island sluice. Operating it opens a shorter eastern return, but its motor will disclose this recess. The western channel remains passable without it.
- `campaign/confluence_region.gd:26` [label] **OK**
  > CONFLUENCE SLUICE MOTOR
- `campaign/confluence_region.gd:28` [name] **OK**
  > CONCEALED ASCENT
- `campaign/confluence_region.gd:28` [name] **OK**
  > OPEN WARNING PASSAGE
- `campaign/confluence_region.gd:29` [brief] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: witness)
  > A monumental factory lies north of the basalt divide. Recover its live dispatch, then bring Quietus back to one of the two southern recovery mouths. The western arm is a narrow broken channel with sheltered recesses; the wider eastern passage carries a north-setting current that helps the approach and resists the return. A west-setting current crosses the narrow southern saddle between the entry mouths. Rock separates their sight and sound. Drones can investigate the two arms independently while Quietus advances, or Quietus can do all the fieldwork alone. Two unlocated carriers remain: the living factory memory and an old service repeater. A received cadence and recovered RETURN reference can distinguish their patterns; without a fitted correlator, close observation or finite local RECON still works. The service repeater may offer a physical shortcut, at a cost you can inspect there. Preserve air and drone energy for withdrawal. Return through CONCEALED ASCENT to carry a private witness, or OPEN WARNING PASSAGE to forward the warning. The physical southern exit commits the next operation; no hidden purity score chooses it.
- `campaign/confluence_region.gd:30` [brief] **OK**
  >  Your deep approach begins in the eastern current passage.
- `campaign/confluence_region.gd:30` **OK**
  >  Your shelf approach begins below the western broken channel.
- `campaign/confluence_region.gd:31` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure, evacuation, witness)
  > The factory is building departure hulls. Its living dispatch links the evacuation to the fracture warning. Quietus returned through a chosen passage with a witness, not a target list; opening the optional service sluice changed the physical return without certifying the water safe.
- `campaign/resolution_missions.gd:44` [title] **OK**
  > Confluence
- `presentation/confluence_resolution.gd:19` [title] **OK**
  > CONCEALED RECOVERY
- `presentation/confluence_resolution.gd:19` **OK**
  > WARNING PASSAGE
- `presentation/confluence_resolution.gd:20` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: witness)
  > The living dispatch is aboard. Quietus chose the concealed passage; the witness store is now available.
- `presentation/confluence_resolution.gd:20` **OK**
  > The living dispatch is aboard. Quietus chose the warning passage; the next operation will send it and listen for an answer.
- `presentation/confluence_resolution.gd:22` [story] **EXPLAINS-BEAT**
  > The living dispatch is aboard. This replay used the %s passage; your campaign continues to %s.
- `presentation/confluence_resolution.gd:22` **OK**
  > The Concealed Record
- `presentation/confluence_resolution.gd:22` **OK**
  > Open Warning
- `presentation/confluence_resolution.gd:24` [service] **OK**
  > The cross-island sluice stands opened. Your motor run left a passage through the basalt.
- `presentation/confluence_resolution.gd:24` **OK**
  > The cross-island sluice remains shut. Quietus returned around the island.
- `presentation/confluence_resolution.gd:26` [story] **EXPLAINS-BEAT**
  > The living dispatch is aboard.
- `presentation/confluence_resolution.gd:26` **OK**
  > The living dispatch is aboard; the service sluice stands open.
- `presentation/confluence_resolution.gd:26` **OK**
  > The living dispatch is aboard; you left the service sluice shut.
- `presentation/confluence_resolution.gd:55` **OK**
  > FIELD RECORD
- `presentation/confluence_resolution.gd:133` **OK**
  > CONFLUENCE / RECOVERY
- `presentation/confluence_resolution.gd:134` **OK**
  > LIVING DISPATCH ABOARD
- `presentation/confluence_resolution.gd:137` **OK**
  > DEEP-WATER HISTORY
- `presentation/confluence_resolution.gd:137` **REJECTED-PREMISE** (terms: shelter)
  > SHELTER HISTORY

## Operation 12: The Concealed Record

- `campaign/resolution_missions.gd:44` **OK**
  > The Concealed Record
- `campaign/resolution_missions.gd:55` **REJECTED-PREMISE** (terms: occupied, witness)
  > OCCUPIED WITNESS CAPSULE
- `campaign/resolution_missions.gd:55` **REJECTED-PREMISE** (terms: berth, evacuation, occupied, witness)
  > An occupied pressure-rated evacuation capsule waits at the witness berth. Local WINCH loads the living witness onto a real fleet craft; LAND it in the southeast harbour. Carrier loss ejects this same sealed pod for local recovery.
- `campaign/resolution_missions.gd:56` **OK**
  > SERVICE SLUICE CONTROL
- `campaign/resolution_missions.gd:56` **OK**
  > The local actuator retracts the man-made service sluice. Its finite motor run is audible; the open passage changes the return route without silencing or ordering any patrol.
- `campaign/resolution_missions.gd:57` [label] **OK**
  > SERVICE SLUICE MOTOR
- `campaign/resolution_missions.gd:60` [name] **OK**
  > CONCEALED RECOVERY BASIN
- `campaign/resolution_missions.gd:61` [brief] **REJECTED-PREMISE** (terms: occupied, witness)
  > Confluence's concealed passage leads to a witness store beyond the southern overhang. WINCH its occupied witness capsule onto Quietus or either bare drone: settle below 2m/s within 60m with clear line of sight for one audible four-second winch. Carry the living witness to the southeast basin and explicitly LAND WITNESS there; Quietus must also return. If a carrier is lost, its sealed pressure pod ejects at that own-craft position and the same witness can be winched aboard another craft. The occupied pod remains sealed for recovery. Recovered kit at the same wreck shares that single winch. The long western detour works with the service sluice shut and needs no transmission or machinery. Alternatively, operate the charted SERVICE SLUICE CONTROL on its north side: an audible motor permanently opens the man-made passage for a shorter return. It never closes or crushes craft. Quietus can operate it in four seconds; a fitted drone sampler can work independently in eight audible seconds, if it survives. The actuator is optional and does not replace the witness. Decide whether the changed route is worth making the machinery heard, then bring the occupied capsule home. Active tools remain available; no hidden purity score invalidates recovery.
- `campaign/resolution_missions.gd:62` [brief] **REJECTED-PREMISE** (terms: departure, navigator, occupied, survivor, witness)
  >  The living navigator knows a danger at the departure throat. Reserve air to act on the survivor’s account before bringing the occupied witness home.
- `campaign/resolution_missions.gd:62` **REJECTED-PREMISE** (terms: families, keeper, occupied, refuge, shelter, survivor, witness)
  >  The living harbour keeper knows why this refuge cannot receive the shelter families. Reserve air to act on the survivor’s account before bringing the occupied witness home.
- `campaign/resolution_missions.gd:63` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: witness)
  > The witness record returns without forwarding its source through the warning chain. The service sluice, if opened, remains an actual route through the overhang; the unannounced western detour remains a valid alternative. This resolves the concealed operation, not the fate of the ocean.
- `campaign/resolution_missions.gd:69` [brief] **REJECTED-PREMISE** (terms: refuge)
  >  A sentinel listens outside the receiving refuge. The western return has a moving patrol.
- `campaign/resolution_missions.gd:70` [else] **OK**
  >  A sentinel holds the water north of the sluice; the western route has a moving patrol.
- `presentation/concealed_harbour_view.gd:8` [name] **OK**
  > LISTENING FLOAT
- `presentation/concealed_harbour_view.gd:8` **REJECTED-PREMISE** (terms: refuge)
  > COLLAPSED REFUGE SCREEN
- `presentation/concealed_harbour_view.gd:23` [receipt] **REJECTED-PREMISE** (terms: departure)
  > LOCAL DEPARTURE ACK RECEIVED
- `presentation/concealed_harbour_view.gd:23` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE ADMISSION ACK RECEIVED
- `presentation/concealed_harbour_view.gd:24` [towing] **OK**
  > QUIETUS TOW · 40 CRUISE / 26 SILENT · MOVING CABLE AUDIBLE
- `presentation/concealed_harbour_view.gd:25` [seated] **OK**
  > SEATED · RECEIVE THE LOCAL STATION ACK
- `presentation/concealed_harbour_view.gd:26` [connected] **REJECTED-PREMISE** (terms: departure)
  > TRACE SEVERED · RECEIVE THE LOCAL DEPARTURE ACK
- `presentation/concealed_harbour_view.gd:27` **REJECTED-PREMISE** (terms: witness)
  >  · WITNESS ACCOUNT / ATTACH LOCAL TOW
- `presentation/concealed_harbour_view.gd:30` **REJECTED-PREMISE** (terms: witness)
  > Rescue the witness first.
- `presentation/concealed_harbour_view.gd:36` **NUMBER-SPACING** (at: audible1200m, for2s, ·40m/s)
  > TOW ·40m/s CRUISE /26m/s SILENT · moving cable audible. The station’s first reply is audible1200m for2s through actual water paths. If missed, approach within local passive reach for quiet reception.
- `presentation/concealed_harbour_view.gd:37` **REJECTED-PREMISE** (terms: occupied, witness)
  > Quietus tows. Drones can scout each approach, receive the station reply, protect the tow or carry the occupied witness independently. Release leaves the equipment in actual water for local reattachment. No finite tool is required.
- `presentation/concealed_harbour_view.gd:38` [receipt] **OK**
  > RECEIVED LOCAL ACCOUNT · 
- `presentation/concealed_harbour_view.gd:38` **REJECTED-PREMISE** (terms: departure)
  > Departure station reports trace current zero and opens its own departure shutter.
- `presentation/concealed_harbour_view.gd:38` **REJECTED-PREMISE** (terms: families, refuge, shelter)
  > Refuge watch admits pressure-shelter families through the cleared mouth.
- `presentation/concealed_harbour_view.gd:70` **OK**
  > TOW · 
- `presentation/concealed_harbour_view.gd:70` **OK**
  > LISTENING FLOAT
- `presentation/concealed_harbour_view.gd:70` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE SCREEN
- `presentation/concealed_harbour_view.gd:92` **REJECTED-PREMISE** (terms: departure)
  > DEPARTURE SHUTTER
- `presentation/concealed_harbour_view.gd:92` **REJECTED-PREMISE** (terms: occupied, refuge)
  > OCCUPIED REFUGE BAYS
- `presentation/concealed_harbour_view.gd:92` **OK**
  >  · OPEN
- `presentation/concealed_harbour_view.gd:92` **OK**
  >  · LOCAL FIX
- `presentation/concealed_harbour_view.gd:97` [receipt] **OK**
  > THIS DIVE · 
- `presentation/concealed_harbour_view.gd:97` **REJECTED-PREMISE** (terms: departure)
  > Surface trace physically disconnected; local departure station replied.
- `presentation/concealed_harbour_view.gd:97` **REJECTED-PREMISE** (terms: refuge)
  > Refuge mouth cleared · 
- `presentation/concealed_harbour_view.gd:97` **OK**
  > SHORT SERVICE APPROACH
- `presentation/concealed_harbour_view.gd:97` **REJECTED-PREMISE?** (weak terms: sheltered)
  > SHELTERED LOWER APPROACH
- `presentation/concealed_harbour_view.gd:97` **OK**
  > \nThe ending preserves the first committed campaign consequence.
- `presentation/resolution_world.gd:60` **OK**
  > SLUICE CLOSED
- `presentation/resolution_world.gd:79` **OK**
  > SLUICE OPEN
- `presentation/witness_evacuation_view.gd:19` **REJECTED-PREMISE** (terms: witness)
  > LIVING WITNESS · LAND
- `presentation/witness_evacuation_view.gd:22` **REJECTED-PREMISE** (terms: witness)
  > WINCH %d%% · WITNESS
- `presentation/witness_evacuation_view.gd:38` [info] **REJECTED-PREMISE** (terms: occupied)
  > OCCUPIED POD
- `presentation/witness_evacuation_view.gd:38` **REJECTED-PREMISE** (terms: witness)
  > LIVING WITNESS
- `presentation/witness_evacuation_view.gd:39` [salvage] **OK**
  > OWN TRANSPORT WRECK
- `presentation/witness_evacuation_view.gd:47` **REJECTED-PREMISE** (terms: witness)
  > \nONE WINCH · 4s · within 60m · clear line · below 2m/s\nAUDIBLE · 520m open-water estimate\nThe living witness rides this real craft. LAND WITNESS at southeast harbour; Quietus must also recover. Colocated kit shares this winch and stays inactive cargo.
- `presentation/witness_evacuation_view.gd:53` [carried] **OK**
  > ACTUAL TRANSPORT · 
- `presentation/witness_evacuation_view.gd:54` [salvage] **REJECTED-PREMISE** (terms: occupied)
  > OWN LOST TRANSPORT · same sealed occupied pod
- `presentation/witness_evacuation_view.gd:55` [landed] **OK**
  > LANDED BY · 
- `presentation/witness_evacuation_view.gd:56` **REJECTED-PREMISE** (terms: witness)
  > LAND WITNESS · selected carrier within 60m of southeast harbour, clear line, below 2m/s. Quietus recovery is separate.
- `presentation/witness_evacuation_view.gd:67` [name] **REJECTED-PREMISE** (terms: occupied, witness)
  > OCCUPIED WITNESS CAPSULE
- `presentation/witness_evacuation_view.gd:103` **REJECTED-PREMISE** (terms: witness)
  > WITNESS LANDED · 
- `presentation/witness_evacuation_view.gd:103` **REJECTED-PREMISE?** (weak terms: harbour)
  > \nTHIS RECOVERY · CONCEALED HARBOUR
- `presentation/witness_evacuation_view.gd:104` [won] **REJECTED-PREMISE?** (weak terms: harbour)
  > The passenger reached harbour. Quietus did not recover; this dive grants no new campaign arrival.
- `presentation/witness_evacuation_view.gd:105` **REJECTED-PREMISE** (terms: occupied)
  > Same occupied pod rescued %d time(s) after actual transport loss.
- `simulation/concealed_harbour.gd:27` [name] **OK**
  > CLEAR SERVICE MOUTH
- `simulation/concealed_harbour.gd:27` [description] **REJECTED-PREMISE** (terms: refuge)
  > Park the folded screen on the western service cradle. Both approaches stay open: the northern entrance is short and direct, and carries sound directly into the refuge.
- `simulation/concealed_harbour.gd:27` [name] **REJECTED-PREMISE?** (weak terms: sheltered)
  > SHELTERED LOWER MOUTH
- `simulation/concealed_harbour.gd:27` [description] **OK**
  > Unfold the screen across the north entrance. Close the short straight approach; the longer lower turn stays open and bends sound around the inner wall. This placement cannot trap Quietus.
- `simulation/concealed_harbour.gd:31` [text] **REJECTED-PREMISE NUMBER-SPACING EXPLAINS-BEAT** (terms: berthing, departing, departure, navigator; at: least90m)
  > NAVIGATOR: That float straddles the departure throat. Its submerged pickup feeds berthing traffic into a surface trace: listening hardware, not a departing hull. Take its tow eye, then actually haul it at least90m from the socket: the surface trace breaks and its taut cable clears the departure throat. Merely attaching and releasing does nothing. Cast off in clear water once the cable is clear. The departure station can confirm its own disconnected line and open its local shutter.
- `simulation/concealed_harbour.gd:32` [text] **REJECTED-PREMISE** (terms: berthing)
  >  Your berthing tender account names the same correction channel; the float copied that traffic without joining the convoy.
- `simulation/concealed_harbour.gd:34` [text] **REJECTED-PREMISE** (terms: departure, families, keeper, refuge)
  > HARBOUR KEEPER: The factory made departure hulls, but pressure-bound families need a harbour first. The collapsed screen blocks this refuge mouth. Tow its folded boom to either cradle: preserve the short open service approach, or unfold a sound baffle and admit families through the longer lower turn.
- `simulation/concealed_harbour.gd:35` [text] **REJECTED-PREMISE** (terms: nurseries)
  >  Your gallery warning bought time to seal nurseries; these lit bays are the next receiving harbour for those households.
- `simulation/concealed_harbour.gd:36` [service_local_receipt] **OK**
  >  You verified a local service receipt at the warning plant. That preparation did not clear this physical mouth.
- `simulation/concealed_harbour.gd:43` [message] **REJECTED-PREMISE** (terms: witness)
  > Living witness has practical knowledge · open WITNESS ACCOUNT from the selected craft orders
- `simulation/concealed_harbour.gd:47` [reason] **REJECTED-PREMISE** (terms: witness)
  > Rescue the witness to learn the local problem
- `simulation/concealed_harbour.gd:49` [reason] **OK**
  > Bring Quietus within 65m of the tow eye, clear line and below 2m/s
- `simulation/concealed_harbour.gd:50` [seated] **OK**
  > Environmental work complete · receive the local station reply
- `simulation/concealed_harbour.gd:52` [release] **NUMBER-SPACING** (at: cruise40m/s, silent26m/s)
  > Tow attached · actual trail · cruise40m/s / silent26m/s; moving cable audible
- `simulation/concealed_harbour.gd:55` [reason] **NUMBER-SPACING** (at: within65m)
  > Move the attached tow within65m of this cradle and settle
- `simulation/concealed_harbour.gd:57` [ready] **OK**
  > Move every living craft clear of the unfolding north screen
- `simulation/concealed_harbour.gd:60` [ready] **REJECTED-PREMISE** (terms: occupied)
  > Recover the occupied pressure pod clear of the unfolding north screen
- `simulation/concealed_harbour.gd:65` [reason] **REJECTED-PREMISE** (terms: witness)
  > Quietus has the towing hardpoint; drones can scout, receive, protect or carry the witness
- `simulation/concealed_harbour.gd:66` [reason] **OK**
  > Quietus unavailable
- `simulation/concealed_harbour.gd:68` [reason] **OK**
  > Terrain blocks the tow eye
- `simulation/concealed_harbour.gd:69` [reason] **OK**
  > Settle below 2m/s to attach
- `simulation/concealed_harbour.gd:70` [reason] **OK**
  > Finish active work first
- `simulation/concealed_harbour.gd:71` [else] **OK**
  > ATTACH TOW · no tool consumed · movement drags audibly; release anywhere in clear water
- `simulation/concealed_harbour.gd:81` **OK**
  > TOW COUPLING
- `simulation/concealed_harbour.gd:81` [message] **OK**
  > Tow attached · HAUL90m to pull the trace from its socket
- `simulation/concealed_harbour.gd:81` **REJECTED-PREMISE** (terms: refuge)
  > Screen folded onto tow · refuge mouth physically clear
- `simulation/concealed_harbour.gd:84` [carrier] **OK**
  > Tow released at its actual water position · reattach locally
- `simulation/concealed_harbour.gd:86` [message] **OK**
  > Bring the attached tow locally to its cradle and settle
- `simulation/concealed_harbour.gd:91` **OK**
  > TOW SEATED
- `simulation/concealed_harbour.gd:91` [pos] **OK**
  > Tow seated · wait for a received local station acknowledgement
- `simulation/concealed_harbour.gd:118` [next_noise] **OK**
  > TOW DRAG
- `simulation/concealed_harbour.gd:122` [message] **REJECTED-PREMISE** (terms: departure)
  > Trace hauled out of its socket · taut cable clears departure throat · receive the local station reply
- `simulation/concealed_harbour.gd:126` [reply_sent] **REJECTED-PREMISE** (terms: departure)
  > DEPARTURE STATION REPLY
- `simulation/concealed_harbour.gd:126` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE WATCH REPLY
- `simulation/concealed_harbour.gd:135` [message] **REJECTED-PREMISE** (terms: departure)
  > DEPARTURE STATION: Surface trace current is zero. Our local departure shutter is open; the first deep crossing can begin.
- `simulation/concealed_harbour.gd:135` **REJECTED-PREMISE** (terms: families, refuge, shelters)
  > HARBOUR WATCH: Mouth clear. Families from the pressure shelters are being admitted into the lit refuge bays.
- `simulation/concealed_harbour.gd:140` [text] **REJECTED-PREMISE** (terms: witness)
  > Rescue the witness to learn the local problem
- `simulation/concealed_harbour.gd:141` [text] **OK**
  > SURFACE TRACE CONNECTED
- `simulation/concealed_harbour.gd:141` **OK**
  > TRACE PHYSICALLY DISCONNECTED
- `simulation/concealed_harbour.gd:141` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE MOUTH BLOCKED
- `simulation/concealed_harbour.gd:141` **REJECTED-PREMISE** (terms: refuge)
  > REFUGE MOUTH CLEAR
- `simulation/witness_evacuation.gd:36` [name] **REJECTED-PREMISE** (terms: occupied, witness)
  > OCCUPIED WITNESS CAPSULE
- `simulation/witness_evacuation.gd:42` [at_berth] **REJECTED-PREMISE** (terms: occupied, witness)
  > Living witness awaits local WINCH · bring the occupied capsule to southeast harbour
- `simulation/witness_evacuation.gd:42` [carried] **REJECTED-PREMISE** (terms: witness)
  > Living witness aboard transport · explicitly LAND at southeast harbour
- `simulation/witness_evacuation.gd:42` [salvage] **REJECTED-PREMISE** (terms: occupied)
  > Occupied pressure pod ejected at own lost-craft position · recover locally
- `simulation/witness_evacuation.gd:42` [landed] **REJECTED-PREMISE** (terms: witness)
  > Living witness landed · local station account and Quietus recovery required
- `simulation/witness_evacuation.gd:42` **REJECTED-PREMISE** (terms: berth, witness)
  > Locate the witness berth by local observation or Survey
- `simulation/witness_evacuation.gd:43` [name] **OK**
  > CONCEALED RECOVERY BASIN
- `simulation/witness_evacuation.gd:48` [name] **REJECTED-PREMISE** (terms: occupied, witness)
  > Occupied witness capsule
- `simulation/witness_evacuation.gd:51` [witness] **REJECTED-PREMISE** (terms: occupied, witness)
  >  + occupied witness capsule
- `simulation/witness_evacuation.gd:56` [reason] **REJECTED-PREMISE** (terms: occupied)
  > Locate the occupied capsule first
- `simulation/witness_evacuation.gd:61` [reason] **OK**
  > Dive ended
- `simulation/witness_evacuation.gd:62` [alive] **OK**
  > Craft lost
- `simulation/witness_evacuation.gd:63` [reason] **OK**
  > Capsule already carried or landed
- `simulation/witness_evacuation.gd:64` [reason] **REJECTED-PREMISE** (terms: occupied)
  > This item is not the occupied pod site
- `simulation/witness_evacuation.gd:65` [reason] **REJECTED-PREMISE** (terms: occupied)
  > Occupied capsule recovery in progress
- `simulation/witness_evacuation.gd:66` [reason] **OK**
  > Finish this craft's active work first
- `simulation/witness_evacuation.gd:67` [RANGE] **REJECTED-PREMISE** (terms: occupied)
  > Move within 60m of the occupied pod
- `simulation/witness_evacuation.gd:68` [reason] **OK**
  > Salvage requires its recorded depth band
- `simulation/witness_evacuation.gd:69` [reason] **OK**
  > Terrain blocks the winch
- `simulation/witness_evacuation.gd:70` [reason] **OK**
  > Settle below 2m/s
- `simulation/witness_evacuation.gd:71` [else] **REJECTED-PREMISE** (terms: occupied)
  > WINCH occupied capsule · 4s audible · 520m open-water reach
- `simulation/witness_evacuation.gd:72` [reason] **REJECTED-PREMISE** (terms: witness)
  > This craft does not carry the witness
- `simulation/witness_evacuation.gd:73` [reason] **OK**
  > Dive ended
- `simulation/witness_evacuation.gd:75` [reason] **REJECTED-PREMISE?** (weak terms: harbour)
  > Ascend to MIDDLE and settle for harbour landing
- `simulation/witness_evacuation.gd:76` [RANGE] **REJECTED-PREMISE** (terms: occupied)
  > Bring the occupied capsule within 60m of southeast harbour
- `simulation/witness_evacuation.gd:77` [reason] **REJECTED-PREMISE?** (weak terms: harbour)
  > Terrain blocks harbour landing
- `simulation/witness_evacuation.gd:78` [reason] **REJECTED-PREMISE** (terms: witness)
  > Settle below 2m/s to land the witness
- `simulation/witness_evacuation.gd:79` [reason] **OK**
  > Finish this craft's active work first
- `simulation/witness_evacuation.gd:80` [else] **REJECTED-PREMISE** (terms: witness)
  > LAND living witness · local harbour
- `simulation/witness_evacuation.gd:84` **REJECTED-PREMISE** (terms: witness)
  > Witness unavailable
- `simulation/witness_evacuation.gd:86` **OK**
  > RECOVERY WINCH
- `simulation/witness_evacuation.gd:87` [message] **REJECTED-PREMISE NUMBER-SPACING** (terms: occupied, witness; at: winch4s)
  > Occupied pressure pod · living witness aboard · audible winch4s
- `simulation/witness_evacuation.gd:90` **REJECTED-PREMISE** (terms: witness)
  > Witness unavailable
- `simulation/witness_evacuation.gd:92` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: witness)
  > The living witness was physically landed in the concealed southeast harbour by 
- `simulation/witness_evacuation.gd:92` **OK**
  > . The account is preserved without broadcasting the passage.
- `simulation/witness_evacuation.gd:93` [pos] **REJECTED-PREMISE** (terms: witness)
  > Living witness landed safely · 
- `simulation/witness_evacuation.gd:93` **OK**
  > return Quietus to recovery
- `simulation/witness_evacuation.gd:93` **REJECTED-PREMISE** (terms: witness)
  > complete the witness-guided local work and receive its station reply
- `simulation/witness_evacuation.gd:99` [pos] **REJECTED-PREMISE** (terms: occupied)
  > Transport lost · occupied sealed pressure pod ejected at its last own position · recover locally
- `simulation/witness_evacuation.gd:108` [pos] **REJECTED-PREMISE** (terms: occupied, witness)
  >  carries the occupied witness capsule · LAND at southeast harbour
- `simulation/witness_evacuation.gd:119` [message] **REJECTED-PREMISE** (terms: occupied)
  > Occupied pod winch interrupted
- `simulation/witness_evacuation.gd:126` **OK**
  > DRONE A
- `simulation/witness_evacuation.gd:126` **OK**
  > DRONE B
- `simulation/witness_evacuation.gd:127` [account] **OK**
  > No transport lost.
- `simulation/witness_evacuation.gd:128` **REJECTED-PREMISE** (terms: occupied, witness)
  >  lost while carrying the occupied pod; %d rescue(s) brought the same living witness home.
- `simulation/witness_evacuation.gd:130` [account] **OK**
  >  Launched equipment left behind: 

## Operation 13: The Open Warning

- `campaign/resolution_missions.gd:44` **OK**
  > The Open Warning
- `campaign/resolution_missions.gd:81` [name] **OK**
  > WARNING TRANSMISSION SECTOR
- `campaign/resolution_missions.gd:81` [unit_requirement] **OK**
  > Quietus must carry and transmit the recovered warning.
- `campaign/resolution_missions.gd:81` [evidence] **EXPLAINS-BEAT**
  > Quietus sends the recovered Confluence packet from its actual chosen position. A local receiver begins replying; the return identifies reception, not the receiver's allegiance or safe water.
- `campaign/resolution_missions.gd:81` [label] **OK**
  > WARNING CHAIN TRANSMISSION
- `campaign/resolution_missions.gd:82` **OK**
  > LOCAL WARNING ACKNOWLEDGEMENT
- `campaign/resolution_missions.gd:82` **REJECTED-PREMISE** (terms: berth, departure)
  > The berth station acknowledges this delivered warning. Its waiting launch offers an exposed eastern crossing or the sheltered north service route; departure remains a separate local order.
- `campaign/resolution_missions.gd:84` [name] **OK**
  > NORTHEAST WARNING RECOVERY
- `campaign/resolution_missions.gd:85` [brief] **REJECTED-PREMISE** (terms: berth, refuge)
  > Confluence’s warning is aboard. Choose Quietus’s transmission origin inside the charted sector; settle and use CAMERA / TRANSMIT for six seconds. The 2000m warning follows actual water paths: a completed emission can miss behind terrain, so reposition and retry if no reply arrives. Find the local acknowledgement by received bearings or close observation, then receive it with Quietus. A vulnerable recipient launch waits in the northern breakwater berth. It never leaves automatically. Tap its measured hull and deliberately choose EXPOSED, an ungated passage around the south breakwater into the eastern watch, or SHELTERED, a shorter route through the north service gate. Open that physical gate locally within 60m, clear line and below 2m/s; its release is audible 650m for six seconds. An earned Warning Chain service receipt can instead ride this newly received warning to operate the connected gate. Bare Quietus needs no proof, fitted kit or finite tool for the manual sheltered route. Drones can scout, release the gate, protect the launch or observe its arrival; Quietus must transmit, receive the initial reply and recover independently. Protect the recipient’s actual hull with terrain or finite tools. Receive its real arrival at the northeast refuge and recover Quietus there. Recipient destruction fails the dive; retry remains available. Announced courses are plans, never live tracking.
- `campaign/resolution_missions.gd:86` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berth, refuge)
  > The warning reached the berth. Its recipient made the chosen physical crossing to the northern refuge, and Quietus recovered after receiving the actual arrival. A crew who can carry Confluence’s account now stands before the surface watch.
- `campaign/resolution_missions.gd:92` [brief] **OK**
  >  An eastern hunter reacts to local evidence while a sentinel holds the northern response basin.
- `presentation/resolution_world.gd:89` **OK**
  > TRANSMISSION SECTOR
- `presentation/resolution_world.gd:98` **OK**
  > OWN SEND ORIGIN
- `presentation/warning_recipient_view.gd:11` [name] **OK**
  > WARNING RECIPIENT
- `presentation/warning_recipient_view.gd:11` **OK**
  > SERVICE GATE
- `presentation/warning_recipient_view.gd:38` [text] **OK**
  > PASSAGE OPEN
- `presentation/warning_recipient_view.gd:38` **OK**
  > MANUAL RELEASE · AUDIBLE
- `presentation/warning_recipient_view.gd:38` **OK**
  >  · %d%%
- `presentation/warning_recipient_view.gd:38` **OK**
  > LAST FIX · %ds
- `presentation/warning_recipient_view.gd:71` **OK**
  > NORTH SERVICE GATE\n
- `presentation/warning_recipient_view.gd:71` **OK**
  > PASSAGE OPEN
- `presentation/warning_recipient_view.gd:71` **OK**
  > CLOSED · physical barrier
- `presentation/warning_recipient_view.gd:71` **OK**
  > \nManual release: within 60m, clear line, below 2m/s. Audible 650m / 6s. A service credential carried by this received warning can operate the connected gate. No proof or kit is needed for the local release.
- `presentation/warning_recipient_view.gd:72` [vessel] **OK**
  > WARNING RECIPIENT
- `presentation/warning_recipient_view.gd:73` [known] **REJECTED-PREMISE?** (weak terms: hull)
  > LOCAL HULL · %s · %d%%
- `presentation/warning_recipient_view.gd:73` **REJECTED-PREMISE?** (weak terms: hull)
  > LAST FIX · %ds AGO · position and hull at last observation
- `presentation/warning_recipient_view.gd:75` **REJECTED-PREMISE?** (weak terms: sheltered)
  > EXPOSED: no gate release, but a longer passage around the south breakwater into the eastern watch. SHELTERED: shorter north service passage behind cover; open its real gate first.
- `presentation/warning_recipient_view.gd:76` **REJECTED-PREMISE** (terms: departure, refuge)
  > Choose locally within 240m, clear link, below 12m/s. No automatic departure. Protect with terrain, distraction, EMP or torpedo as needed. Reacquire the actual arrival at the northern refuge; Quietus recovery is separate.
- `presentation/warning_recipient_view.gd:89` **OK**
  > SERVICE OPEN
- `presentation/warning_recipient_view.gd:89` **OK**
  > SERVICE GATE
- `presentation/warning_recipient_view.gd:93` **OK**
  > RECIPIENT · %d%%
- `presentation/warning_recipient_view.gd:93` **OK**
  > LAST RECIPIENT FIX · %ds
- `presentation/warning_recipient_view.gd:115` [heading] **OK**
  > RECIPIENT LOST AFTER ARRIVAL
- `presentation/warning_recipient_view.gd:115` **OK**
  > RECIPIENT ARRIVAL PREVIOUSLY RECEIVED
- `presentation/warning_recipient_view.gd:115` **REJECTED-PREMISE** (terms: refuge)
  > RECIPIENT AT REFUGE
- `presentation/warning_recipient_view.gd:116` **OK**
  >  COURSE\n
- `presentation/warning_recipient_view.gd:116` **OK**
  > HISTORICAL ARRIVAL RECEIPT
- `presentation/warning_recipient_view.gd:116` **OK**
  > THIS CROSSING · ARRIVAL RECEIVED
- `presentation/warning_recipient_view.gd:117` [failed] **OK**
  > The recipient was destroyed after its arrival was received. This dive grants no campaign outcome.
- `presentation/warning_recipient_view.gd:117` **REJECTED-PREMISE** (terms: refuge)
  > The recipient reached refuge. Quietus did not recover; this dive grants no campaign outcome.
- `simulation/resolution_operations.gd:55` [qualification] **OK**
  > Open-water emission reach; reception remains unknown.
- `simulation/warning_recipient.gd:14` [name] **OK**
  > WARNING RECIPIENT
- `simulation/warning_recipient.gd:25` **OK**
  > WARNING SERVICE GATE
- `simulation/warning_recipient.gd:33` [reason] **OK**
  > Reach service release within 60m
- `simulation/warning_recipient.gd:34` [reason] **OK**
  > Receive the local warning reply first
- `simulation/warning_recipient.gd:35` [reason] **OK**
  > Dive ended
- `simulation/warning_recipient.gd:35` [reason] **OK**
  > Dive ended
- `simulation/warning_recipient.gd:36` [alive] **OK**
  > Craft lost
- `simulation/warning_recipient.gd:36` [reason] **OK**
  > Craft lost
- `simulation/warning_recipient.gd:39` [opened] **OK**
  > Service passage open
- `simulation/warning_recipient.gd:40` [reason] **OK**
  > Finish this craft's active work first
- `simulation/warning_recipient.gd:41` [reason] **OK**
  > Terrain blocks service release
- `simulation/warning_recipient.gd:42` [reason] **OK**
  > Settle below 2m/s
- `simulation/warning_recipient.gd:43` [else] **OK**
  > OPEN SERVICE · audible 650m / 6s
- `simulation/warning_recipient.gd:45` [alive] **OK**
  > Recipient lost
- `simulation/warning_recipient.gd:46` [arrived] **REJECTED-PREMISE** (terms: refuge)
  > Recipient at refuge
- `simulation/warning_recipient.gd:47` [reason] **OK**
  > Recipient already in transit
- `simulation/warning_recipient.gd:48` [reason] **OK**
  > Reach recipient within 240m with clear local link
- `simulation/warning_recipient.gd:49` [reason] **OK**
  > Settle below 12m/s
- `simulation/warning_recipient.gd:50` [reason] **OK**
  > Finish this craft's active work first
- `simulation/warning_recipient.gd:51` [else] **REJECTED-PREMISE?** (weak terms: sheltered)
  > Choose the ungated exposed course or open the sheltered service course
- `simulation/warning_recipient.gd:55` **OK**
  > Service unavailable
- `simulation/warning_recipient.gd:56` [message] **OK**
  > Service passage opens · recipient still awaits a deliberate course
- `simulation/warning_recipient.gd:62` [opened] **REJECTED-PREMISE?** (weak terms: sheltered)
  > Open the north service gate before choosing the sheltered course
- `simulation/warning_recipient.gd:66` [message] **OK**
  > Recipient course blocked · clear the physical passage
- `simulation/warning_recipient.gd:70` [pos] **REJECTED-PREMISE** (terms: departs)
  > Warning recipient departs by 
- `simulation/warning_recipient.gd:70` **REJECTED-PREMISE** (terms: refuge)
  >  course · observe its refuge arrival, then recover Quietus
- `simulation/warning_recipient.gd:78` [pos] **REJECTED-PREMISE** (terms: refuge)
  > Recipient arrival received at refuge · recover Quietus
- `simulation/warning_recipient.gd:91` [paused] **OK**
  > Warning recipient destroyed · the passage failed · retry the operation
- `simulation/warning_recipient.gd:100` [name] **OK**
  > WARNING RECIPIENT

## Operation 14: Glass Fence

- `campaign/glass_reach_operations.gd:3` [TITLES] **OK**
  > Glass Fence
- `campaign/glass_reach_operations.gd:16` [evidence] **REJECTED-PREMISE** (terms: keeper)
  > Keeper Ilen / These floats listen to engines, not loyalties. Their lamps rise before a report. Deep water under the western teeth gives a slow quiet passage; the central opening is shorter and watched.

## Operation 15: Needle Strait

- `campaign/glass_reach_operations.gd:3` **OK**
  > Needle Strait
- `campaign/glass_reach_operations.gd:17` [evidence] **REJECTED-PREMISE?** (weak terms: ilen)
  > Ilen / The shallow strain vanes feed the listening fence. Release one locally and the western strait falls quiet. Deep water bypasses the vane wall but reaches the eastern repeater. A disabled listener cannot finish its charged report.

## Operation 16: Furnace Drift

- `campaign/glass_reach_operations.gd:3` **OK**
  > Furnace Drift
- `campaign/glass_reach_operations.gd:18` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: engineer)
  > Engineer Sava / This thermal atlas belongs to the basin's cooling plant. The crossflow carries hot exhaust and sound around the central piers. Take the measured atlas home; its material spectrum may explain the prisms in the western wreck field.

## Operation 17: Silt Archive

- `campaign/glass_reach_operations.gd:3` **OK**
  > Silt Archive
- `campaign/glass_reach_operations.gd:19` [evidence] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier, sava)
  > Sava / The archive spindle is a physical return ledger. Its reception note is not the spindle itself. Winch it to a living craft and bring that carrier to recovery; losing the carrier leaves the same spindle in that water.

## Operation 18: Lantern Anchorage

- `campaign/glass_reach_operations.gd:3` **REJECTED-PREMISE** (terms: anchorage)
  > Lantern Anchorage
- `campaign/glass_reach_operations.gd:20` [evidence] **REJECTED-PREMISE** (terms: anchorage, families, occupied)
  > Ilen / The occupied anchorage needs its service bus. Restore the sheltered passage and its families can use the short water, but the listening relay stays supplied. Sever the reporting spur and the watchers lose the channel; the arrivals take the longer outside passage. Quietus must carry the selected station account home.

## Operation 19: Last Carrier

- `campaign/glass_reach_operations.gd:3` **REJECTED-PREMISE?** (weak terms: carrier)
  > Last Carrier
- `campaign/glass_reach_operations.gd:21` [evidence] **REJECTED-PREMISE** (terms: departure)
  > Sava / The last carrier's local departure register is received. It names one living departure, not every vessel beyond the Reach. Cross the listening chain, hear the northern register, and choose either physical recovery mouth.
- `campaign/glass_reach_operations.gd:32` [name] **OK**
  > EAST REACH RECOVERY
- `campaign/glass_reach_operations.gd:49` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: anchorage)
  >  The recovered anchorage account left the service water open.
- `campaign/glass_reach_operations.gd:49` **REJECTED-PREMISE** (terms: anchorage)
  >  The anchorage's reporting spur was severed; the outer return remains available.
- `campaign/glass_reach_operations.gd:49` **REJECTED-PREMISE** (terms: anchorage)
  >  No recovered anchorage choice is assumed.

## Operation 20: Prism Grave

- `campaign/glass_reach_operations.gd:3` **OK**
  > Prism Grave
- `campaign/glass_reach_operations.gd:22` [evidence] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: sava)
  > Sava / A cracked directional prism remains in the grave. A photograph identifies it; only the recovered crystal supplies the material. The furnace atlas lets us cut one Quietus fitting: greater directional reach at higher pulse cost and a shared hardware slot.

## Operation 21: Keeper's Cache

- `campaign/glass_reach_operations.gd:3` **REJECTED-PREMISE** (terms: keeper)
  > Keeper's Cache
- `campaign/glass_reach_operations.gd:23` [evidence] **REJECTED-PREMISE** (terms: keeper)
  > Ilen / The keeper's service wafer is still in its sealed cache. Recover that material with the silt ledger and we can cut a local decoder. It opens a measured service gate quietly from nearby; it is no remote authority over the network.

### Shared across operations 14-21 (Glass Reach)

- `campaign/glass_reach_operations.gd:30` [name] **OK** (ops 14-21)
  >  / RECEIVED ACCOUNT
- `campaign/glass_reach_operations.gd:31` [name] **OK** (ops 14-21)
  > SOUTH REACH RECOVERY
- `campaign/glass_reach_operations.gd:61` [brief] **OK** (ops 14-21)
  > \nKeep Quietus and its account together. Local records and machinery work in settled MIDDLE. The bare outside water avoids the central network; other bands open shorter inner crossings. Buoys hear real engines and emissions; relays forward stale uncertain reports after a charge. Quiet, masking, terrain, depth, relocation or physical disruption can break that chain. Return to a named recovery mouth.
- `campaign/glass_reach_operations.gd:62` [brief] **NUMBER-SPACING** (ops 15, 18, 19; at: takes8, the18/19)
  >  Tap a craft → REACH WORK for local machinery. Manual work takes8 audible seconds; a recovered fitted decoder can open the18/19 service gate quietly.
- `campaign/glass_reach_operations.gd:63` [brief] **REJECTED-PREMISE? NUMBER-SPACING** (ops 17, 20, 21; weak terms: carrier, carriers; at: Winch4s, within60m, within65m)
  >  Tap the marked material → RECOVER, or craft → REACH WORK. Winch4s within60m; carriers must recover in MIDDLE within65m of the chosen mouth, or transfer locally to Quietus. A lost carrier leaves its physical cargo at the lost position.
- `campaign/glass_reach_operations.gd:64` [id] **REJECTED-PREMISE?** (op 18; weak terms: carrier)
  >  REACH WORK offers RESTORE SERVICE or SEVER SPUR. First recovery commits the real consequence in Last Carrier.
- `campaign/glass_reach_operations.gd:66` [brief] **OK** (ops 14-21, appended when a prior resolution fact exists)
  >  Previous received outcome: 
- `campaign/glass_reach_operations.gd:66` [concealed_recovery] **REJECTED-PREMISE** (ops 14-21, appended when a prior resolution fact exists; terms: witness)
  > a living witness reached the concealed harbour.
- `campaign/glass_reach_operations.gd:66` [overt_warning] **REJECTED-PREMISE** (ops 14-21, appended when a prior resolution fact exists; terms: refuge)
  > a warned recipient reached its refuge.
- `campaign/glass_reach_operations.gd:66` **OK** (ops 14-21, appended when a prior resolution fact exists)
  > the earlier local account remains in the archive.
- `simulation/glass_reach_work.gd:12` [reason] **OK** (runtime feedback for ops 14-21)
  > No Reach task here
- `simulation/glass_reach_work.gd:20` [reason] **OK** (runtime feedback for ops 14-21)
  > Dive ended
- `simulation/glass_reach_work.gd:21` [alive] **OK** (runtime feedback for ops 14-21)
  > Craft lost
- `simulation/glass_reach_work.gd:22` [reason] **OK** (runtime feedback for ops 14-21)
  > Material already carried or unavailable
- `simulation/glass_reach_work.gd:23` [reason] **REJECTED-PREMISE** (runtime feedback for ops 14-21; terms: anchorage)
  > Anchorage choice already made or unavailable
- `simulation/glass_reach_work.gd:24` [reason] **OK** (runtime feedback for ops 14-21)
  > Vane already released or unavailable
- `simulation/glass_reach_work.gd:25` [reason] **OK** (runtime feedback for ops 14-21)
  > Service gate already open or unavailable
- `simulation/glass_reach_work.gd:28` [active] **OK** (runtime feedback for ops 14-21)
  > Reach work in progress
- `simulation/glass_reach_work.gd:29` [reason] **OK** (runtime feedback for ops 14-21)
  > Settle at this work's recorded depth
- `simulation/glass_reach_work.gd:30` [reason] **NUMBER-SPACING** (runtime feedback for ops 14-21; at: gate120m, within60m)
  > Meet local work within60m (decoder gate120m)
- `simulation/glass_reach_work.gd:31` [reason] **OK** (runtime feedback for ops 14-21)
  > Terrain blocks local work
- `simulation/glass_reach_work.gd:32` [reason] **NUMBER-SPACING** (runtime feedback for ops 14-21; at: below2m/s)
  > Settle below2m/s
- `simulation/glass_reach_work.gd:33` [reason] **OK** (runtime feedback for ops 14-21)
  > Finish this craft's active work
- `simulation/glass_reach_work.gd:34` [else] **NUMBER-SPACING** (runtime feedback for ops 14-21; at: ·4s)
  > RECOVER material ·4s audible
- `simulation/glass_reach_work.gd:34` **NUMBER-SPACING** (runtime feedback for ops 14-21; at: ·2s)
  > LOCAL DECODER ·2s quiet
- `simulation/glass_reach_work.gd:34` **NUMBER-SPACING** (runtime feedback for ops 14-21; at: ·8s)
  > LOCAL MACHINERY ·8s audible
- `simulation/glass_reach_work.gd:42` [paused] **OK** (runtime feedback for ops 14-21)
  > Reach withdrawal · field notes retained; no new recovery or material research
- `simulation/glass_reach_work.gd:48` **OK** (runtime feedback for ops 14-21)
  > RECOVERY WINCH
- `simulation/glass_reach_work.gd:48` **OK** (runtime feedback for ops 14-21)
  > REACH MACHINERY
- `simulation/glass_reach_work.gd:56` [carrier] **OK** (runtime feedback for ops 14-21)
  > Physical Reach material transferred locally to Quietus
- `simulation/glass_reach_work.gd:68` [carrier] **REJECTED-PREMISE?** (runtime feedback for ops 14-21; weak terms: carrier)
  > Reach material at lost carrier position · recover its actual depth
- `simulation/glass_reach_work.gd:76` [message] **OK** (runtime feedback for ops 14-21)
  > Reach work interrupted
- `simulation/glass_reach_work.gd:80` [carrier] **OK** (runtime feedback for ops 14-21)
  > Physical material aboard 
- `simulation/glass_reach_work.gd:80` **REJECTED-PREMISE?** (runtime feedback for ops 14-21; weak terms: carrier)
  >  · recover carrier or TRANSFER locally to Quietus
- `simulation/glass_reach_work.gd:90` [message] **OK** (runtime feedback for ops 14-21)
  > Local service water opened; reporting spur remains supplied
- `simulation/glass_reach_work.gd:90` **OK** (runtime feedback for ops 14-21)
  > Local reporting spur interrupted; outside water remains open
- `simulation/glass_reach_work.gd:91` [gate] **OK** (runtime feedback for ops 14-21)
  > Local service gate opened
- `simulation/glass_reach_work.gd:114` [detail] **OK** (runtime feedback for ops 14-21)
  > REACH WORK · 
- `simulation/glass_reach_work.gd:114` **OK** (runtime feedback for ops 14-21)
  > material 
- `simulation/glass_reach_work.gd:114` **OK** (runtime feedback for ops 14-21)
  > local machinery / 

## Operation 22: Hammerwake

- `campaign/iron_choir_operations.gd:3` [TITLES] **OK**
  > Hammerwake
- `campaign/iron_choir_operations.gd:14` [evidence] **REJECTED-PREMISE?** (weak terms: foreman, rill)
  > Foreman Rill / The hammer train is stalled, not abandoned. Release its actual sled by the western service lane or the eastern shipping lane, observe the dock arrival, then bring your account home. The forked interceptors commit to what they last acquired; change your water during their windup.
- `campaign/iron_choir_operations.gd:35` [load] **OK**
  > freight sled

## Operation 23: Pressure Stair

- `campaign/iron_choir_operations.gd:3` **OK**
  > Pressure Stair
- `campaign/iron_choir_operations.gd:15` [evidence] **REJECTED-PREMISE** (terms: keeper)
  > Lock keeper Nera / Three equalizers vent into separate pressure locks. Work them in any safe sequence; shutters truly open. A crowned warden charges local pressure from received evidence. Wait out its finite discharge, break its acquisition or use another band. Quietus alone can cycle every lock.

## Operation 24: Choir Cut

- `campaign/iron_choir_operations.gd:3` **OK**
  > Choir Cut
- `campaign/iron_choir_operations.gd:16` [evidence] **REJECTED-PREMISE?** (weak terms: gallery, rill)
  > Rill / The ballast is the switch. Tow it to BYPASS to restore the short gallery and leave the reporting bus supplied, or to ISOLATE to cut the bus and keep the long outside water. The first recovered placement commits Last Shift's actual route and relay support.

## Operation 25: Last Shift

- `campaign/iron_choir_operations.gd:3` **OK**
  > Last Shift
- `campaign/iron_choir_operations.gd:17` [evidence] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure, evacuation, refuge)
  > Nera / Last shift is aboard the evacuation sled. Deliberately choose its east shipping refuge or west service refuge. No departure countdown runs before your order. Watch its actual arrival; the course announcement is not a tracker. Your returned ballast, people and plant accounts change local water, not distant fate.
- `campaign/iron_choir_operations.gd:41` [load] **REJECTED-PREMISE** (terms: evacuation, occupied)
  > occupied evacuation sled
- `campaign/iron_choir_operations.gd:60` [record] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berth)
  >  Recovered workers staff the service berth.
- `campaign/iron_choir_operations.gd:60` **OK**
  >  No recovered crew landing is assumed; local manual service is available.

## Operation 26: The Cold Hammer

- `campaign/iron_choir_operations.gd:3` **OK**
  > The Cold Hammer
- `campaign/iron_choir_operations.gd:18` [evidence] **REJECTED-PREMISE?** (weak terms: rill)
  > Rill / A pressure spindle rests in the deep cooling sump. A local noisy release opens the direct return; the longer outside passage needs no release. Recover the physical spindle, not its photograph. Our hammer measurements can turn it into a faster but louder pressure sleeve.

## Operation 27: Counterweight Grave

- `campaign/iron_choir_operations.gd:3` **OK**
  > Counterweight Grave
- `campaign/iron_choir_operations.gd:19` [evidence] **REJECTED-PREMISE?** (weak terms: nera)
  > Nera / Move the grounded counterweight to its receiving cradle, then winch the exposed traction core. Our pressure-lock measurements and the recovered material can build one drone traction yoke. A yoke steadies a load through service water; it cannot move a remote load.

## Operation 28: Names in the Bell

- `campaign/iron_choir_operations.gd:3` **OK**
  > Names in the Bell
- `campaign/iron_choir_operations.gd:20` [evidence] **REJECTED-PREMISE** (terms: berth, occupied, refuge)
  > Rill / The maintenance bell is occupied. Attach locally, tow it through real water and LAND it at the western refuge. A returned landing account staffs Last Shift's west service berth. Quietus can carry the job alone; a fitted drone frees its pilot to scout.
- `campaign/iron_choir_operations.gd:50` [load] **REJECTED-PREMISE** (terms: occupied)
  > occupied maintenance bell

## Operation 29: Spare Lung

- `campaign/iron_choir_operations.gd:3` **OK**
  > Spare Lung
- `campaign/iron_choir_operations.gd:21` [evidence] **REJECTED-PREMISE?** (weak terms: gallery, nera)
  > Nera / Reconnect the plant and Last Shift gains a current-assisted masked gallery, but its reporting feed stays alive. Dismantle the security feed and the powered western warden goes dark; no remote shield appears. Recover your chosen local work account.

### Shared across operations 22-29 (Iron Choir)

- `campaign/iron_choir_operations.gd:30` [name] **OK** (ops 22-29)
  > CHOIR SOUTH RECOVERY
- `campaign/iron_choir_operations.gd:67` [brief] **OK** (ops 22-29)
  > \nCraft → CHOIR WORK, or tap acquired machinery/load. All work is local and interruptible; peer selection does not move equipment or cargo. Manual Quietus towing uses wide water; a fitted drone yoke buys a narrower slower noisy load route. Release a tow before changing depth. No receiver exposure substitutes for physical work. The south recovery mouth stays available after the job.
- `presentation/industrial_view.gd:7` **OK** (runtime feedback for ops 22-29)
  > LOCAL WORK
- `presentation/industrial_view.gd:37` **OK** (runtime feedback for ops 22-29)
  > LAST FIX %ds
- `presentation/industrial_view.gd:40` **OK** (runtime feedback for ops 22-29)
  > PRESSURE / %.1fs
- `simulation/industrial_jobs.gd:21` [reason] **OK** (runtime feedback for ops 22-29)
  > No industrial work here
- `simulation/industrial_jobs.gd:29` [reason] **OK** (runtime feedback for ops 22-29)
  > Dive ended
- `simulation/industrial_jobs.gd:30` [alive] **OK** (runtime feedback for ops 22-29)
  > Craft lost
- `simulation/industrial_jobs.gd:31` [active] **OK** (runtime feedback for ops 22-29)
  > Industrial work in progress
- `simulation/industrial_jobs.gd:32` [reason] **OK** (runtime feedback for ops 22-29)
  > Settle at the work's physical depth
- `simulation/industrial_jobs.gd:33` [reason] **NUMBER-SPACING** (runtime feedback for ops 22-29; at: within60m)
  > Reach within60m through clear local water
- `simulation/industrial_jobs.gd:34` [reason] **NUMBER-SPACING** (runtime feedback for ops 22-29; at: below2m/s)
  > Settle below2m/s
- `simulation/industrial_jobs.gd:35` [reason] **OK** (runtime feedback for ops 22-29)
  > Finish this craft's other local work
- `simulation/industrial_jobs.gd:36` [reason] **OK** (runtime feedback for ops 22-29)
  > Bare Quietus or this drone's fitted traction yoke required
- `simulation/industrial_jobs.gd:37` [reason] **OK** (runtime feedback for ops 22-29)
  > This craft has no attached load
- `simulation/industrial_jobs.gd:38` [moored] **OK** (runtime feedback for ops 22-29)
  > Voyage already deliberately started
- `simulation/industrial_jobs.gd:39` [id] **REJECTED-PREMISE** (runtime feedback for ops 22-29; terms: berth)
  > Open or staff the western service berth first
- `simulation/industrial_jobs.gd:40` [wreck] **OK** (runtime feedback for ops 22-29)
  > Material sealed, carried or recovered
- `simulation/industrial_jobs.gd:41` [reason] **OK** (runtime feedback for ops 22-29)
  > Tow the real load locally to its receiving socket
- `simulation/industrial_jobs.gd:42` [done] **OK** (runtime feedback for ops 22-29)
  > Machinery work already complete
- `simulation/industrial_jobs.gd:43` [reason] **OK** (runtime feedback for ops 22-29)
  > Local infrastructure choice already made
- `simulation/industrial_jobs.gd:44` [reason] **OK** (runtime feedback for ops 22-29)
  > Another craft owns this physical work
- `simulation/industrial_jobs.gd:45` [else] **OK** (runtime feedback for ops 22-29)
  > LOCAL 
- `simulation/industrial_jobs.gd:45` **OK** (runtime feedback for ops 22-29)
  > 4s winch
- `simulation/industrial_jobs.gd:45` **OK** (runtime feedback for ops 22-29)
  > 8s audible work
- `simulation/industrial_jobs.gd:52` [carrier] **OK** (runtime feedback for ops 22-29)
  > Physical tow attached · release before depth change
- `simulation/industrial_jobs.gd:53` [carrier] **OK** (runtime feedback for ops 22-29)
  > Load released at its real position
- `simulation/industrial_jobs.gd:60` [message] **OK** (runtime feedback for ops 22-29)
  > Physical freight course blocked
- `simulation/industrial_jobs.gd:64` **REJECTED-PREMISE** (runtime feedback for ops 22-29; terms: berth)
  > CHOIR BERTH RELEASE
- `simulation/industrial_jobs.gd:64` [message] **REJECTED-PREMISE** (runtime feedback for ops 22-29; terms: departs)
  > Sled departs by 
- `simulation/industrial_jobs.gd:64` **REJECTED-PREMISE** (runtime feedback for ops 22-29; terms: refuge)
  >  course · locally observe its actual refuge arrival
- `simulation/industrial_jobs.gd:66` **OK** (runtime feedback for ops 22-29)
  > RECOVERY WINCH
- `simulation/industrial_jobs.gd:66` **OK** (runtime feedback for ops 22-29)
  > CHOIR MACHINERY
- `simulation/industrial_jobs.gd:83` [pos] **OK** (runtime feedback for ops 22-29)
  > Industrial 
- `simulation/industrial_jobs.gd:83` **OK** (runtime feedback for ops 22-29)
  >  physically complete
- `simulation/industrial_jobs.gd:106` **OK** (runtime feedback for ops 22-29)
  > physical 
- `simulation/industrial_jobs.gd:106` **OK** (runtime feedback for ops 22-29)
  >  completed
- `simulation/industrial_jobs.gd:127` [paused] **OK** (runtime feedback for ops 22-29)
  > Industrial load lost · retry preserves recovered campaign history
- `simulation/industrial_jobs.gd:162` [detail] **OK** (runtime feedback for ops 22-29)
  > INDUSTRIAL WORK · 
- `simulation/industrial_threats.gd:31` [mode] **OK** (runtime feedback for ops 22-29)
  > INTERCEPT LISTEN
- `simulation/industrial_threats.gd:31` **OK** (runtime feedback for ops 22-29)
  > WARDEN IDLE
- `simulation/industrial_threats.gd:36` [angle] **OK** (runtime feedback for ops 22-29)
  > BURST WINDUP
- `simulation/industrial_threats.gd:36` **OK** (runtime feedback for ops 22-29)
  > PRESSURE CHARGE
- `simulation/industrial_threats.gd:37` **OK** (runtime feedback for ops 22-29)
  > INTERCEPTOR WINDUP
- `simulation/industrial_threats.gd:37` **OK** (runtime feedback for ops 22-29)
  > WARDEN CHARGE
- `simulation/industrial_threats.gd:49` [mode] **OK** (runtime feedback for ops 22-29)
  > BURST WINDUP
- `simulation/industrial_threats.gd:49` **OK** (runtime feedback for ops 22-29)
  > PRESSURE CHARGE
- `simulation/industrial_threats.gd:54` [remaining] **OK** (runtime feedback for ops 22-29)
  > WARDEN PRESSURE
- `simulation/industrial_threats.gd:56` [mode] **OK** (runtime feedback for ops 22-29)
  > COMMITTED BURST
- `simulation/industrial_threats.gd:70` [mode] **OK** (runtime feedback for ops 22-29)
  > BURST RECOVERY
- `simulation/industrial_threats.gd:70` **OK** (runtime feedback for ops 22-29)
  > PRESSURE RECOVERY

## Non-operation text

### Endings (`campaign/endings.gd`)

- `campaign/endings.gd:3` [title] **EXPLAINS-BEAT**
  > SILENT EXODUS
- `campaign/endings.gd:3` [outcome] **EXPLAINS-BEAT**
  > The evacuees escape hidden.
- `campaign/endings.gd:3` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departing, fleet (human fleet), refugees, witness)
  > Quietus returns with the deep-water witness account and keeps the concealed passage out of the fleet's targeting network. Below the surface, the departing vessels pass without pursuit. The last carrier fades into the trench; the refugees have a future beyond our charts.
- `campaign/endings.gd:4` [title] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: pact)
  > BEACON PACT
- `campaign/endings.gd:4` [outcome] **EXPLAINS-BEAT**
  > The evacuees coordinate a public safe channel.
- `campaign/endings.gd:4` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: fleet (human fleet))
  > The deep-water account gives the warning its meaning. Quietus broadcasts the agreed passage and the fleet holds its fire. Human escorts and Siren carriers share a channel through the fracture zone. Their first pact is practical: everyone gets out.
- `campaign/endings.gd:5` [title] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: harbour)
  > HIDDEN HARBOUR
- `campaign/endings.gd:5` [outcome] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuate, shelters)
  > The shelters evacuate covertly.
- `campaign/endings.gd:5` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: fleet (human fleet), inhabited, shelter, shelters, witness)
  > The shelf record identifies inhabited shelters beneath the industrial lights. Quietus carries their witness account home without exposing the service passage. Shelter craft slip through the hidden harbour while the surface fleet watches empty water. The people below survive without becoming targets.
- `campaign/endings.gd:6` [title] **EXPLAINS-BEAT**
  > SURFACE RECKONING
- `campaign/endings.gd:6` [outcome] **EXPLAINS-BEAT**
  > The surface warning averts disaster, exposing the corridor.
- `campaign/endings.gd:6` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuation)
  > The shelf warning reaches the surface in time. Ships clear the fracture zone and the approaching disaster claims no fleet. The public transmission also reveals the evacuation corridor. Quietus has saved thousands, but the route can never be secret again; both sides must now answer for what follows.
- `campaign/endings.gd:19` [drone_a] **EXPLAINS-BEAT**
  > DRONE A
- `campaign/endings.gd:19` [drone_b] **EXPLAINS-BEAT**
  > DRONE B
- `campaign/endings.gd:20` [outcome] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: witness)
  > The living witness reaches the concealed harbour.
- `campaign/endings.gd:21` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: fleet (human fleet), occupied, refuge, shelter, survivor, witness)
  >  physically lands the occupied witness capsule in the southeast refuge. Quietus returns with the survivor's account, keeping the passage outside the fleet's targeting network. This witness has a safe harbour; the fate of other shelter craft remains beyond our observations. 
- `campaign/endings.gd:24` [outcome] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure)
  > The deep departure line gains a hidden crossing.
- `campaign/endings.gd:25` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berthing, departure, navigator, survivor, unarmed hulls)
  >  lands the living navigator. Guided by the survivor’s account, Quietus removes the listening float from the departure mouth and physically severs its surface trace. The departure station reports its own line dark and opens its local shutter. The first deep crossing begins beyond that silent mouth; the berthing corrections Quietus recorded now lead unarmed hulls away from the fracture. Their destination belongs to the people aboard them. 
- `campaign/endings.gd:27` [outcome] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: families, shelter)
  > The pressure-shelter families gain a concealed harbour.
- `campaign/endings.gd:28` [mouth] **EXPLAINS-BEAT**
  > The short service approach stays open, a direct route for arrivals and for sound.
- `campaign/endings.gd:28` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: families)
  > The screen now shields the north entrance. Arriving families take the longer lower turn into quieter water.
- `campaign/endings.gd:29` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: families, keeper, occupied, refuge, shelters, survivor)
  >  lands the living harbour keeper. The survivor reveals why the occupied pressure shelters cannot leave together. Quietus clears the collapsed screen from their receiving refuge; its watch acknowledges the open mouth and begins admitting families into the lit bays. 
- `campaign/endings.gd:29` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: berths, evacuation, nurseries)
  >  By the next watch, sleeping berths and warm-water nurseries share a crowded harbour beneath the industrial shelf. The hidden passage has become a place to live while the evacuation continues. 
- `campaign/endings.gd:32` [passage] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: sheltered)
  > the sheltered service passage
- `campaign/endings.gd:32` **EXPLAINS-BEAT**
  > the exposed eastern channel
- `campaign/endings.gd:33` [first] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: refuge)
  > The warned recipient reaches the northern refuge through 
- `campaign/endings.gd:33` **EXPLAINS-BEAT**
  > . Quietus returns after receiving its arrival. 
- `campaign/endings.gd:35` [outcome] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: pact)
  > A warned passage becomes the first public pact.
- `campaign/endings.gd:36` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departing, refuge, unarmed hulls, witness)
  > The deep-water witness account travels aboard the surviving launch. At the refuge, its crew and the human watch agree on a common channel: no firing on the departing unarmed hulls. The first escort sails beside the craft it was sent to hunt. A pact begins with that difficult crossing, and grows as each vessel answers.
- `campaign/endings.gd:38` [outcome] **EXPLAINS-BEAT**
  > The shelf warning reaches the people who can act.
- `campaign/endings.gd:39` [story] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: fleet (human fleet), inhabited, refuge, shelter, shelters)
  > The launch carries the shelf shelters’ warning into the surface watch. Its crew marks the inhabited passages on the fleet’s charts; ships turn clear while shelter pilots bring their people through. By morning the industrial lights are dark and the refuge is crowded. The public crossing has exposed the corridor, and neither side can deny who lived beneath it.
- `campaign/endings.gd:42` [drone_a] **EXPLAINS-BEAT**
  > DRONE A
- `campaign/endings.gd:42` [drone_b] **EXPLAINS-BEAT**
  > DRONE B
- `campaign/endings.gd:42` **EXPLAINS-BEAT**
  > The rescue craft

### Archive recap (`campaign/archive_recap.gd`)

- `campaign/archive_recap.gd:5` **EXPLAINS-BEAT**
  > Blackwater · ocean archive older than humanity.
- `campaign/archive_recap.gd:6` **EXPLAINS-BEAT**
  > Blackwater · a relay requests a missing ocean archive.
- `campaign/archive_recap.gd:7` **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: hulls)
  > Foundry · hollow hulls; no visible armament.
- `campaign/archive_recap.gd:8` **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: hulls)
  > Foundry · hulls with no visible armament at an open cradle.
- `campaign/archive_recap.gd:9` **EXPLAINS-BEAT**
  > Foundry · hollow forms on a construction line.
- `campaign/archive_recap.gd:10` **EXPLAINS-BEAT**
  > Well · cadence matches Quietus; speaker and intent unresolved.
- `campaign/archive_recap.gd:11` **EXPLAINS-BEAT**
  > Well · repeating cadence; Quietus comparison unverified.
- `campaign/archive_recap.gd:12` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: evacuation)
  > Finale · fracture warning and evacuation packet.
- `campaign/archive_recap.gd:13` **REJECTED-PREMISE EXPLAINS-BEAT** (terms: unarmed hulls)
  > Finale · unarmed hulls head deeper.
- `campaign/archive_recap.gd:14` **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier)
  > Finale · carrier directed into the trench.
- `campaign/archive_recap.gd:15` **EXPLAINS-BEAT**
  > No chapter records are retained.

### Other campaign files (consequences, research, plant variant, default objective names)

- `campaign/campaign_consequences.gd:98` [message] **OK**
  >  locally identified · packet reception is a separate task
- `campaign/campaign_consequences.gd:98` **EXPLAINS-BEAT**
  >  locally identified · field note retained
- `campaign/campaign_consequences.gd:105` [label] **REJECTED-PREMISE?** (weak terms: carrier)
  > UNRESOLVED CARRIER
- `campaign/campaign_consequences.gd:142` **REJECTED-PREMISE?** (weak terms: carrier)
  > UNRESOLVED CARRIER
- `campaign/glass_research.gd:40` **OK**
  > Research needs physically recovered material and a received regional account.
- `campaign/glass_research.gd:41` **OK**
  > RECOVERED MATERIAL %s\nCONSUMED IN RESEARCH %s\nOPTIONAL FITTINGS %s
- `campaign/plant_operation.gd:34` [name] **OK**
  > NORTH WATER RECOVERY
- `campaign/plant_operation.gd:34` [name] **OK**
  > WEST SERVICE RECOVERY
- `campaign/tutorial_missions.gd:39` [name] **OK**
  > SIGNAL SPIRE
- `campaign/tutorial_missions.gd:39` **OK**
  > RELAY MOUTH
- `campaign/tutorial_missions.gd:39` **OK**
  > ARCHIVE NODE

### Menu, briefing, debrief and ending screens (`main.gd`)

- `main.gd:277` [text] **REJECTED-PREMISE?** (weak terms: hull)
  > DEPTH %dm    O₂ %03d%%    HULL %03d%%    RECORDS %d / %d    %s
- `main.gd:318` [legacy] **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > FLEET GUARD · any fresh fleet contact holds
- `main.gd:321` [knock_armed] **OK**
  > TORPEDO · QUIETUS · 150m · noisy flight · impact pins 8s · tap fresh S# · CANCEL
- `main.gd:437` **OK**
  > ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.
- `main.gd:438` **OK**
  > USS QUIETUS  /  OPERATIONS ARCHIVE
- `main.gd:441` **OK**
  > Resuming preserves the active dive's equipment.
- `main.gd:451` **OK**
  > Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.
- `main.gd:453` **OK**
  > NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d
- `main.gd:454` [rows] **OK**
  > COMPARE: O₂ / DISRUPT / SURVEY
- `main.gd:459` **OK**
  > ALL: 3 DECOYS · 2 DRONES · 2 TORPEDOES\nDISRUPT: 12s · SURVEY: 8s, audible
- `main.gd:460` **OK**
  > CYCLE LOADOUT · endurance / disruption / survey
- `main.gd:481` **REJECTED-PREMISE? NUMBER-SPACING EXPLAINS-BEAT** (weak terms: fleet (own craft group, UI sense); at: within156m, within214.5m, within60m)
  > ORDERS\nTap a craft for its command ring; FLEET chooses a station. Empty water plots its route. ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Settle and SAMPLE for two seconds. Quietus receives within156m; drones within214.5m. Cover blocks reception. An audible SONAR may prompt a local relay replay; a decoded packet explains its partner's handshake. Drone buffers TRANSFER locally to Quietus: both settled, within60m, clear link. Return with both packets aboard.
- `main.gd:483` **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > ORDERS\nTap a craft for its command ring; FLEET chooses a station. Tap empty water to replace its route. Craft → ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Drag / pinch inspects freely; FOCUS follows the craft and FIT shows the region. CAMERA works within 240m of a gold record marker. Return Quietus after all records are secured.
- `main.gd:484` **OK**
  > SPACE / PAUSE grants unlimited planning time. Silent running is slower and quieter. Disruption interrupts nearby Sirens for 12 seconds. Quietus torpedoes travel noisily up to 150m; impact pins one Siren for 8s. Cover blocks sonar, enemy sight and torpedoes.
- `main.gd:486` **OK**
  > NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d · 3 DECOYS · 2 DRONES · 2 TORPEDOES
- `main.gd:534` **REJECTED-PREMISE?** (weak terms: hull)
  > Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%
- `main.gd:536` **OK**
  > YOUR FIELD RECORD · ACROSS DIVES
- `main.gd:545` **OK**
  > Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.
- `main.gd:556` **OK**
  > INTEL PHOTO GRADE %s · %d photographs · %d%% quality
- `main.gd:561` **OK**
  > SIREN'S SONG / RECOVERED OUTCOME
- `main.gd:570` **OK**
  > NEW CAMPAIGN / CHOOSE ANOTHER ROUTE
- `main.gd:576` **OK**
  > This replaces this campaign's progress, equipment and field records. Audio settings stay. Both route choices can be played again.
- `main.gd:685` **OK**
  > Actionable sound cues also appear in the tactical display. Audio pauses when you suspend the dive.

### Presentation (`presentation/`)

**`presentation/camera_feed.gd`**

- `presentation/camera_feed.gd:38` **REJECTED-PREMISE?** (weak terms: carrier)
  > REPLY CARRIER · LOCAL
- `presentation/camera_feed.gd:76` [received_name] **REJECTED-PREMISE?** (weak terms: carrier)
  > REPLY CARRIER

**`presentation/equipment_context.gd`**

- `presentation/equipment_context.gd:20` **OK**
  > BARE remains available. A launch fixes its equipment; resuming keeps the active dive’s fit.

**`presentation/expedition_operations.gd`**

- `presentation/expedition_operations.gd:16` **REJECTED-PREMISE** (terms: refuge)
  > IRON CHOIR / Craft → CHOIR WORK or tap acquired machinery and physical loads. Start voyages deliberately, observe actual arrival, tow locally and LAND people at refuge. All machinery/cargo follows its working craft and real depth. Bare Quietus can complete every core job sequentially without finite tools; fitted drones buy alternate narrow load routes.
- `presentation/expedition_operations.gd:20` **REJECTED-PREMISE** (terms: anchorage)
  > GLASS REACH / Local craft → REACH WORK opens machinery, material and transfer controls. Status gives exact local distance/depth/readiness. The southern mouth also permits explicit incomplete withdrawal. First recovered anchorage choice shapes Last Carrier; failed dives and replays do not replace it.
- `presentation/expedition_operations.gd:23` [index] **EXPLAINS-BEAT**
  > PLANT ORDERS\nCONNECT a settled craft at WEST for quiet shore power, or START BACKUP once with a 900m / 6s audible start. Quietus or a fitted sampler selects the output at EAST. OPEN SERVICE opens the physical crosslink; NORTH MAST leaves its opening unchanged. Then use SEND WARNING separately. Service requires a local receipt; mast telemetry proves transmission with external reception unknown. Recover Quietus by either mouth after commissioning.
- `presentation/expedition_operations.gd:24` [index] **REJECTED-PREMISE** (terms: occupied, shelter)
  > SHELTER ORDERS\nTap a measured gallery or the charted communal resonator for its local warning action and exact readiness. Watch the occupied windows, then hear the returning shelter call. No camera hold is required.
- `presentation/expedition_operations.gd:25` [else] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier)
  > OBSERVATION ORDERS\nArrival arcs show where a carrier reached that receiver; sound may bend around basalt. They are not exact target bearings. Close clear passive reception or local RECON earns a precise source mark. Pause gives planning time, never new passive samples. Named recovery corridors show which interpretations you have confirmed.
- `presentation/expedition_operations.gd:26` **OK**
  > RECOVERED THREAD / Your first successful recovery from Wake Crossing or Warning Chain selects the history carried into Confluence. The other dive remains replayable; replay does not rewrite a launched dive or the committed thread. Failed dives retain field notes, never the new fitting or continuation.
- `presentation/expedition_operations.gd:27` [index] **REJECTED-PREMISE EXPLAINS-BEAT** (terms: departure)
  > Choose a physical exit with Quietus after its carrier is identified. Investigating both retains both facts; your exit selects the continuation. The southern basin permits incomplete withdrawal after departure, without completing an expedition route.
- `presentation/expedition_operations.gd:50` **REJECTED-PREMISE?** (weak terms: carrier)
  > PHYSICAL ROUTE / %s\nRecovered carrier facts: %s
- `presentation/expedition_operations.gd:54` **OK**
  > COMMITTED THREAD · %s\nThis recovered history carries forward. Both onward dives remain replayable.
- `presentation/expedition_operations.gd:59` **REJECTED-PREMISE?** (weak terms: hull)
  > Dive time %02d:%02d / Hull %d%%
- `presentation/expedition_operations.gd:65` **OK**
  > Field observations remain in the archive. This dive grants no new recovered fitting, continuation or committed history.

**`presentation/expedition_view.gd`**

- `presentation/expedition_view.gd:20` **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > OWN FLEET
- `presentation/expedition_view.gd:29` **REJECTED-PREMISE?** (weak terms: carrier)
  > No current carrier measurements. Listen from another position or use local SURVEY.
- `presentation/expedition_view.gd:58` [withdrawal] **OK**
  > INCOMPLETE WITHDRAWAL\nReturn Quietus to the southern basin. Field observations remain; this does not recover an expedition route.
- `presentation/expedition_view.gd:61` **OK**
  > %s\n%s\nPlot the selected craft’s approach. Only Quietus’s settled arrival commits this recovery corridor.
- `presentation/expedition_view.gd:61` **REJECTED-PREMISE?** (weak terms: carrier)
  > INTERPRET CARRIER FIRST · approach only
- `presentation/expedition_view.gd:95` **REJECTED-PREMISE?** (weak terms: carrier)
  > INTERPRET CARRIER

**`presentation/fleet_instruments.gd`**

- `presentation/fleet_instruments.gd:90` [reserve] **REJECTED-PREMISE?** (weak terms: hull)
  > HULL %d · O₂ %d
- `presentation/fleet_instruments.gd:107` **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > FLEET GUARD

**`presentation/mission_hud.gd`**

- `presentation/mission_hud.gd:63` **REJECTED-PREMISE** (terms: berth)
  > RELEASE BERTH\n950m / 6s
- `presentation/mission_hud.gd:74` [wake_playback] **NUMBER-SPACING** (at: ·15s)
  > PLAY OLD LOOP\nONCE ·15s
- `presentation/mission_hud.gd:75` **REJECTED-PREMISE?** (weak terms: sheltered)
  > SHELTERED\nSERVICE COURSE
- `presentation/mission_hud.gd:77` **REJECTED-PREMISE** (terms: witness)
  > WITNESS ACCOUNT
- `presentation/mission_hud.gd:401` **NUMBER-SPACING** (at: ·15s)
  > PLAY OLD LOOP\nONCE ·15s
- `presentation/mission_hud.gd:410` **REJECTED-PREMISE** (terms: berth)
  > RELEASE BERTH\n950m / 6s
- `presentation/mission_hud.gd:484` **REJECTED-PREMISE?** (weak terms: carrier)
  >  · recover this carrier

**`presentation/module_recovery_view.gd`**

- `presentation/module_recovery_view.gd:103` **OK**
  > \nONE WINCH · 4s settled · 60m · clear line of sight\nAUDIBLE · 520m open-water estimate\nQuietus receives recovered buffers aboard. A drone carries them until local TRANSFER to Quietus.
- `presentation/module_recovery_view.gd:103` **REJECTED-PREMISE?** (weak terms: carrier)
  > \nRecovered kit stays inactive cargo until its carrier reaches recovery.
- `presentation/module_recovery_view.gd:104` **REJECTED-PREMISE?** (weak terms: carrier)
  > \nRECOVER · 4s settled · within 60m · clear line of sight\nAUDIBLE WINCH · 520m open-water estimate\nCarried cargo stays inactive. Bring its carrier to Quietus's chosen recovery mouth.
- `presentation/module_recovery_view.gd:127` **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > FLEET RECOVERY\n
- `presentation/module_recovery_view.gd:135` **OK**
  > Abandoned kits are unavailable next launch. Bare drones remain available.
- `presentation/module_recovery_view.gd:139` **REJECTED-PREMISE?** (weak terms: carrier)
  > Return each carrier to this mouth: within 65m, below 12m/s, clear of terrain. Salvage needs a local 4s audible retrieval. Carried kits stay inactive until recovered.

**`presentation/ocean_view.gd`**

- `presentation/ocean_view.gd:365` **REJECTED-PREMISE?** (weak terms: carrier)
  > CARRIER · CRADLE

**`presentation/operation_instruments.gd`**

- `presentation/operation_instruments.gd:26` [detail] **OK**
  > \nAUDIBLE on completion · %ds · ~%dm open-water reach; listener reception unknown.
- `presentation/operation_instruments.gd:53` [text] **OK**
  > \nRECEIVED MEASUREMENTS · %d (historical arrivals, not delivery acknowledgments).
- `presentation/operation_instruments.gd:54` [text] **OK**
  > \nOnly received arrival measurements establish reception; direction may bend around terrain.

**`presentation/receiver_scene.gd`**

- `presentation/receiver_scene.gd:33` **REJECTED-PREMISE?** (weak terms: hull)
  > No hull image / range

**`presentation/route_program_panel.gd`**

- `presentation/route_program_panel.gd:92` [text] **OK**
  >  · DRIVE %s · %s PROFILE\nTO sets incoming drive; INHERIT keeps current. STOP settles, then continues.
- `presentation/route_program_panel.gd:92` **OK**
  >  · TO sets incoming propulsion. INHERIT keeps manual. STOP settles, then continues.

**`presentation/sonar_history.gd`**

- `presentation/sonar_history.gd:25` [text] **OK**
  > BEARING HISTORY · %s\n%s · %s / %s · listen %.1fs\nOwn noise ~%dm · passive masking ×%.1f
- `presentation/sonar_history.gd:30` [text] **OK**
  > \nNo received signals. Move quietly or separate craft for independent bearing rays.
- `presentation/sonar_history.gd:31` **OK**
  > \nBearings alone give no range, band or clear passage. Echoes keep their original reflection time.

### Simulation messages (`simulation/`)

**`simulation/acoustic_network.gd`**

- `simulation/acoustic_network.gd:20` **REJECTED-PREMISE** (terms: berth)
  > CHOIR BERTH RELEASE

**`simulation/depth_bands.gd`**

- `simulation/depth_bands.gd:119` **NUMBER-SPACING** (at: stationary4s)
  > Depth change · stationary4s · exposed in BOTH bands until settled.
- `simulation/depth_bands.gd:121` **NUMBER-SPACING** (at: within60m)
  > RAW BUFFER aboard · meet Quietus at SAME settled depth within60m to TRANSFER.
- `simulation/depth_bands.gd:122` **REJECTED-PREMISE?** (weak terms: carrier)
  > Archive ready · recover Quietus settled in MIDDLE; retained kit still needs its carrier.
- `simulation/depth_bands.gd:123` **OK**
  > Local record nearby · settle in MIDDLE to CAMERA / SAMPLE; shifting exposes both bands.
- `simulation/depth_bands.gd:125` **NUMBER-SPACING** (at: takes4s)
  > Sweep heard locally · move from the old return or disrupt; a layer shift takes4s.
- `simulation/depth_bands.gd:126` **NUMBER-SPACING** (at: moving160m)
  > Listening for returns · moving160m or leaving the emitter band can lose your return.
- `simulation/depth_bands.gd:127` **OK**
  > Own motion masks passive bearings · slow down or listen from an independent craft.
- `simulation/depth_bands.gd:128` **OK**
  > Craft → DEPTH / SONAR · bearings need movement or a second receiver; depth costs time.

**`simulation/module_recovery.gd`**

- `simulation/module_recovery.gd:80` [message] **REJECTED-PREMISE?** (weak terms: carrier)
  > %s carries %s · bring carrier to recovery
- `simulation/module_recovery.gd:83` [text] **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > Fleet recovery ready
- `simulation/module_recovery.gd:91` **REJECTED-PREMISE?** (weak terms: carrier)
  > Carrier outside this recovery mouth
- `simulation/module_recovery.gd:93` [confirmation_required] **REJECTED-PREMISE** (terms: depart)
  > Recover remaining modules, or explicitly depart without them

**`simulation/signal_field.gd`**

- `simulation/signal_field.gd:35` **REJECTED-PREMISE?** (weak terms: rendezvous)
  > Quietus LISTEN confirms the rendezvous
- `simulation/signal_field.gd:35` **REJECTED-PREMISE?** (weak terms: carrier)
  > route interpretation recorded; choose its physical exit or investigate the other carrier
- `simulation/signal_field.gd:56` [paused] **OK**
  > Incomplete withdrawal · field observations retained; expedition route incomplete

**`simulation/simulation.gd`**

- `simulation/simulation.gd:107` [message] **OK**
  > Chart loaded. Tap a craft for DEPTH / SONAR; tap water to plot a route.
- `simulation/simulation.gd:271` [message] **REJECTED-PREMISE?** (weak terms: carrier)
  > Bring the physical Reach material carrier to this recovery mouth in MIDDLE
- `simulation/simulation.gd:272` [message] **REJECTED-PREMISE?** (weak terms: carrier)
  > Recover the actual industrial material carrier here in MIDDLE
- `simulation/simulation.gd:435` [confirm] **REJECTED-PREMISE** (terms: depart)
  > Recovery continues · route remaining module carriers, then depart
- `simulation/simulation.gd:494` [message] **REJECTED-PREMISE?** (weak terms: fleet (own craft group, UI sense))
  > Quietus fleet guard · hold while any fresh contact is observed
- `simulation/simulation.gd:495` [else] **OK**
  > %s SCOUT · stop on its own passive contact · release or replot to continue
- `simulation/simulation.gd:550` [message] **OK**
  > Decoy needs clear water within 160m and a clear path · no charge spent
- `simulation/simulation.gd:646` [courier] **REJECTED-PREMISE?** (weak terms: carrier)
  > REPLY CARRIER · local moving archive · settle + SAMPLE 2s
- `simulation/simulation.gd:651` **NUMBER-SPACING** (at: fm%s)
  > %s · %dm / quiet %.0fm%s
- `simulation/simulation.gd:661` **REJECTED-PREMISE?** (weak terms: carrier)
  > REPLY CARRIER
- `simulation/simulation.gd:666` [text] **OK**
  > No exact source located · listen from another position or spend local RECON
- `simulation/simulation.gd:689` [text] **OK**
  > TRANSMISSION SECTOR · Quietus chooses clear water inside the charted sector; settle below 12m/s
- `simulation/simulation.gd:692` [text] **NUMBER-SPACING** (at: range%s)
  > %s · %dm away / 240m range%s
- `simulation/simulation.gd:695` **OK**
  > Quietus must operate the archive uplink. Bring the submarine to this anchor.
- `simulation/simulation.gd:716` [record] **EXPLAINS-BEAT**
  > A returned pattern matches Quietus' moving engine cadence. Its source and intent remain unresolved.
- `simulation/simulation.gd:717` [message] **EXPLAINS-BEAT**
  > Returned cadence matches Quietus reference · comparison recorded
- `simulation/simulation.gd:722` [caption] **EXPLAINS-BEAT**
  > ENGINE REFERENCE: Quietus moving %.1f m/s at %.1fs near PROFILE APERTURE. LOCAL RETURN: received by %s at %.1fs near RETURN ARCHIVE. The returned cadence matches the recorded reference. Source and intent remain unresolved.
- `simulation/simulation.gd:748` **REJECTED-PREMISE** (terms: berth)
  > BERTH RELEASE
- `simulation/simulation.gd:827` **OK**
  > Drone lost · Quietus command restored. Submarine camera remains available.
- `simulation/simulation.gd:1441` [message] **OK**
  > Warning sent from this origin · listen for a reply from another position; retransmission remains available
- `simulation/simulation.gd:1443` [message] **OK**
  > Pattern record secured · optional moving Quietus comparison explained in recovered records
- `simulation/simulation.gd:1446` **EXPLAINS-BEAT**
  > REQUEST decoded · REPLY accepts SONAR replay within 240m; or approach quietly
- `simulation/simulation.gd:1446` **EXPLAINS-BEAT**
  > REPLY decoded · ancient temperatures · REQUEST accepts SONAR replay within 240m
- `simulation/simulation.gd:1447` [record] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: carrier)
  > REQUEST decoded · southern REPLY CARRIER announced · intercept + SAMPLE, or SONAR / quiet eastern relay
- `simulation/simulation.gd:1450` [message] **REJECTED-PREMISE? EXPLAINS-BEAT** (weak terms: hulls)
  > Warning decoded: deep fracture; outbound hulls are leaving. Bring Quietus and this packet home.
- `simulation/simulation.gd:1457` [message] **REJECTED-PREMISE** (terms: departure)
  > The factory answers the camera. Carrier pulse at the departure cradle · plan your recovery route.

### Equipment, persistence and other

- `equipment/equipment_catalog.gd:6` [benefit] **NUMBER-SPACING** (at: takes2.5s)
  > Adjacent depth transition takes2.5s instead of4s, still exposed in both bands.
- `equipment/equipment_catalog.gd:6` [cost] **NUMBER-SPACING** (at: spends0.75)
  > Each change spends0.75 reserve and emits a250m pump pulse. Uses Quietus hardware slot.
- `equipment/equipment_catalog.gd:7` [cost] **NUMBER-SPACING** (at: at28m/s, capped22m/s)
  > Tow speed capped22m/s with extra propulsion noise; uses drone slot. Bare Quietus tows wider water at28m/s.
- `equipment/equipment_catalog.gd:8` [benefit] **NUMBER-SPACING** (at: reaches40%)
  > Forward SONAR reaches40% farther.
- `equipment/equipment_catalog.gd:8` [cost] **NUMBER-SPACING** (at: emit25%)
  > Forward pulses cost double reserve and emit25% farther. Uses Quietus hardware slot; all-around sonar unchanged.
- `equipment/equipment_catalog.gd:9` [name] **REJECTED-PREMISE** (terms: keeper)
  > Keeper service decoder
- `equipment/equipment_catalog.gd:9` [benefit] **NUMBER-SPACING** (at: within120m)
  > Open nearby Reach service gates quietly in2s within120m, after measuring their local position.
- `equipment/equipment_catalog.gd:9` [cost] **NUMBER-SPACING** (at: takes8, within60m)
  > Uses Quietus hardware slot. Bare manual work takes8 audible seconds within60m; outside routes remain available.
- `equipment/equipment_catalog.gd:10` [benefit] **NUMBER-SPACING** (at: by45%)
  > Reduce propulsion sound by45% at the same actual speed.
- `equipment/equipment_catalog.gd:11` [benefit] **NUMBER-SPACING** (at: at112m/s, of78m/s, remains42m/s)
  > Cruise at112m/s instead of78m/s; silent speed remains42m/s.
- `equipment/equipment_catalog.gd:12` [benefit] **NUMBER-SPACING** (at: from330m)
  > Extend this drone's ordinary passive and chart reach from330m to460m.
- `equipment/equipment_catalog.gd:14` [benefit] **OK**
  > Compare fresh received cadence with a recovered reference before close source acquisition.
- `equipment/equipment_catalog.gd:14` [cost] **EXPLAINS-BEAT**
  > Settle below 12m/s for 6 seconds. Matching cadence does not prove identity, range or safety.
- `equipment/equipment_catalog.gd:15` [benefit] **OK**
  > Prepare compatible field receivers and operate the powered Warning Chain panel while Quietus takes another task.
- `equipment/equipment_catalog.gd:15` [cost] **NUMBER-SPACING** (at: takes4, takes8)
  > One pod on one drone. Receiver exposure takes8 audible seconds; Quietus takes4. Plant switches require a settled local connection.
- `persistence/save_store.gd:63` [warning] **OK**
  > Archive is unreadable. Original files retained; starting a new operations session.

## Count summary

Unique strings inventoried: **924** (operation-assigned 651, shared blocks 91, non-operation 182). A string used by two operations is listed under both but counted once here.

| Tag | Strings |
|---|---|
| REJECTED-PREMISE | 217 |
| REJECTED-PREMISE? | 108 |
| EXPLAINS-BEAT | 115 |
| NUMBER-SPACING | 66 |
| OK | 499 |

Per operation (strings attributed to that id, shared blocks excluded):

| Op | Title | Strings | REJECTED | REJECTED? | EXPLAINS | NUMBER | OK |
|---|---|---|---|---|---|---|---|
| 0 | Shelf Signal | 5 | 0 | 0 | 2 | 0 | 3 |
| 1 | Split Channel | 12 | 1 | 2 | 1 | 0 | 8 |
| 2 | Blackwater Relay | 66 | 0 | 7 | 3 | 10 | 49 |
| 3 | Cold Foundry | 13 | 4 | 1 | 5 | 0 | 4 |
| 4 | The Listening Well | 11 | 0 | 0 | 4 | 0 | 7 |
| 5 | Siren's Song | 18 | 4 | 1 | 6 | 0 | 12 |
| 6 | The Divergence | 9 | 3 | 1 | 3 | 0 | 4 |
| 7 | Deep Rendezvous | 55 | 25 | 17 | 3 | 6 | 12 |
| 8 | Shelf Return | 48 | 20 | 8 | 2 | 7 | 17 |
| 9 | Wake Crossing | 29 | 11 | 1 | 5 | 5 | 13 |
| 10 | Warning Chain | 103 | 3 | 0 | 7 | 4 | 92 |
| 11 | Confluence | 30 | 6 | 0 | 5 | 0 | 22 |
| 12 | The Concealed Record | 144 | 76 | 6 | 3 | 5 | 59 |
| 13 | The Open Warning | 70 | 10 | 5 | 2 | 0 | 54 |
| 14 | Glass Fence | 2 | 1 | 0 | 0 | 0 | 1 |
| 15 | Needle Strait | 2 | 0 | 1 | 0 | 0 | 1 |
| 16 | Furnace Drift | 2 | 1 | 0 | 1 | 0 | 1 |
| 17 | Silt Archive | 2 | 0 | 1 | 1 | 0 | 1 |
| 18 | Lantern Anchorage | 2 | 2 | 0 | 0 | 0 | 0 |
| 19 | Last Carrier | 6 | 4 | 1 | 1 | 0 | 1 |
| 20 | Prism Grave | 2 | 0 | 1 | 1 | 0 | 1 |
| 21 | Keeper's Cache | 2 | 2 | 0 | 0 | 0 | 0 |
| 22 | Hammerwake | 3 | 0 | 1 | 0 | 0 | 2 |
| 23 | Pressure Stair | 2 | 1 | 0 | 0 | 0 | 1 |
| 24 | Choir Cut | 2 | 0 | 1 | 0 | 0 | 1 |
| 25 | Last Shift | 5 | 3 | 0 | 2 | 0 | 2 |
| 26 | The Cold Hammer | 2 | 0 | 1 | 0 | 0 | 1 |
| 27 | Counterweight Grave | 2 | 0 | 1 | 0 | 0 | 1 |
| 28 | Names in the Bell | 3 | 2 | 0 | 0 | 0 | 1 |
| 29 | Spare Lung | 2 | 0 | 1 | 0 | 0 | 1 |
| - | Shared 14-21 | 40 | 3 | 4 | 0 | 7 | 27 |
| - | Shared 22-29 | 51 | 4 | 0 | 0 | 2 | 45 |
| - | Non-operation | 182 | 31 | 46 | 58 | 20 | 58 |

## Files by amount of rejected vocabulary

Core terms counted: families, shelter(s), refuge/refugee, anchorage, evacuat*, depart*. The word fleet is counted in its own column because in the UI it also means the own craft group of the player (FLEET GUARD, OWN FLEET); only "the fleet", "surface fleet", "human fleet" and the possessive are tagged as the rejected sense. "Anywhere" counts every occurrence in the file including code identifiers, comments and fact keys (not all player-facing). "In inventoried strings" counts only occurrences inside strings listed above. "Broad" adds occupied, inhabited, witness, survivor, keeper, navigator, nursery, berth, unarmed hull, engineer.

| File | Core anywhere | Core in inventoried strings | Broad anywhere | fleet (any sense) |
|---|---|---|---|---|
| `simulation/concealed_harbour.gd` | 27 | 20 | 46 | 0 |
| `simulation/warning_recipient.gd` | 26 | 4 | 29 | 1 |
| `campaign/endings.gd` | 25 | 25 | 49 | 6 |
| `simulation/shelf_habitat.gd` | 15 | 14 | 30 | 0 |
| `presentation/concealed_harbour_view.gd` | 14 | 14 | 20 | 0 |
| `simulation/simulation.gd` | 13 | 2 | 46 | 3 |
| `presentation/module_recovery_view.gd` | 13 | 0 | 27 | 5 |
| `campaign/resolution_missions.gd` | 9 | 9 | 51 | 1 |
| `campaign/glass_reach_operations.gd` | 9 | 9 | 16 | 0 |
| `campaign/tutorial_missions.gd` | 8 | 6 | 11 | 0 |
| `main.gd` | 7 | 1 | 17 | 38 |
| `presentation/mission_hud.gd` | 7 | 0 | 41 | 23 |
| `presentation/ocean_view.gd` | 7 | 0 | 22 | 9 |
| `campaign/divergence_missions.gd` | 6 | 6 | 17 | 0 |
| `campaign/onward_missions.gd` | 6 | 6 | 12 | 0 |
| `campaign/iron_choir_operations.gd` | 6 | 6 | 12 | 0 |
| `campaign/confluence_region.gd` | 6 | 6 | 11 | 0 |
| `simulation/rendezvous_transport.gd` | 6 | 4 | 14 | 0 |
| `presentation/expedition_operations.gd` | 5 | 5 | 8 | 0 |
| `simulation/wake_crossing.gd` | 5 | 4 | 8 | 0 |
| `presentation/warning_recipient_view.gd` | 5 | 4 | 8 | 0 |
| `presentation/shelf_habitat_view.gd` | 4 | 3 | 11 | 0 |
| `presentation/confluence_resolution.gd` | 4 | 1 | 5 | 3 |
| `simulation/foundry_departure.gd` | 4 | 0 | 4 | 0 |
| `presentation/rendezvous_view.gd` | 3 | 3 | 24 | 0 |
| `simulation/module_recovery.gd` | 3 | 1 | 3 | 4 |
| `presentation/witness_evacuation_view.gd` | 3 | 0 | 25 | 1 |
| `campaign/expedition_campaign.gd` | 3 | 0 | 5 | 0 |
| `presentation/wake_crossing_view.gd` | 2 | 2 | 9 | 0 |
| `simulation/industrial_jobs.gd` | 2 | 2 | 5 | 0 |
| `campaign/opening_depth_operations.gd` | 2 | 2 | 2 | 0 |
| `campaign/archive_recap.gd` | 2 | 1 | 3 | 0 |
| `simulation/glass_reach_work.gd` | 1 | 1 | 3 | 0 |
| `campaign/operation_catalog.gd` | 1 | 0 | 10 | 0 |
| `simulation/acoustic_paths.gd` | 1 | 0 | 1 | 0 |
| `presentation/evidence_catalog.gd` | 1 | 0 | 1 | 0 |
| `simulation/witness_evacuation.gd` | 0 | 0 | 77 | 1 |
| `presentation/fleet_instruments.gd` | 0 | 0 | 16 | 5 |
| `simulation/advanced_sonar.gd` | 0 | 0 | 0 | 1 |
| `presentation/expedition_view.gd` | 0 | 0 | 0 | 1 |
| `persistence/save_store.gd` | 0 | 0 | 0 | 3 |
| `campaign/fleet_inventory.gd` | 0 | 0 | 0 | 6 |

Files in `game/src` with at least one core hit: 42. Core vocabulary also appears outside `game/src` (tests, fixtures, assets such as `game/assets/evidence/finale_departure.png.import` and `finale_warning.svg`); those were not audited because they are not player-facing text strings.
