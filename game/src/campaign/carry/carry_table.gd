extends RefCounted
# Route and recovered-fact carry table (ops 14 to 36). AI-DESIGNED, pending owner ratification.
# Every row reads facts the campaign already saves (launch_context: thread plus facts) and
# applies one small authored world delta. Tune or remove rows here; carry.gd holds the logic.
# when: {"thread": String} and/or {"fact": key, "is": [values]}. Missing facts never match.
# kind: mouth (extra recovery mouth), drop_guard (index, -1 = last), add_guard, start.
# Every row leaves the bare-Quietus route of its op intact (see carry_tests.gd). Story text is
# short placeholder text for the owner to replace.
const ROWS=[
 {"id":"fence_shelf_mouth","op":14,"when":{"thread":"shelf"},"kind":"mouth",
  "pos":Vector2(900,1800),"name":"SHELF TEETH RECOVERY","route":"shelf",
  "line":"Your shelf crossing charted a second mouth under the western teeth."},
 {"id":"fence_wake_hunter","op":14,"when":{"fact":"wake_crossing","is":["repeater_played"]},"kind":"drop_guard","index":-1,
  "line":"The Wake beacon you spent drew the shallow hunter off this fence."},
 {"id":"strait_local_receipt","op":15,"when":{"fact":"warning_chain","is":["service_local_receipt"]},"kind":"drop_guard","index":-1,
  "line":"The local receipt stood the eastern deep watch down."},
 {"id":"drift_overt_post","op":16,"when":{"fact":"confluence_route","is":["overt"]},"kind":"drop_guard","index":1,
  "line":"The overt warning pulled the east post away from the plant."},
 {"id":"archive_sheltered_warden","op":17,"when":{"fact":"warning_arrival","is":["sheltered"]},"kind":"drop_guard","index":-1,
  "line":"The sheltered launch passage left the north warden unrelieved."},
 {"id":"cache_shelf_start","op":21,"when":{"thread":"shelf"},"kind":"start","pos":Vector2(600,2650),
  "line":"Shelf water brings Quietus in from the south-west edge of the crater."},
 {"id":"cache_external_buoy","op":21,"when":{"fact":"warning_chain","is":["mast_transmission_external_unknown"]},"kind":"add_guard",
  "type":"buoy","pos":Vector2(2450,2350),"band":1,
  "line":"Your mast transmission was heard outside; a listener now floats off the south-east rim."},
 {"id":"hammer_concealed_warden","op":22,"when":{"fact":"confluence_route","is":["concealed"]},"kind":"drop_guard","index":-1,
  "line":"The concealed route left the southern warden unreplaced."},
 # 085: independent, reversible arc-six rows. Remove a row to restore that op's baseline;
 # Carry.ENABLED=false restores every carry delta. Core work, photos and gates stay intact.
 {"id":"survey_shelf_mouth","op":30,"when":{"thread":"shelf"},"kind":"mouth",
  "pos":Vector2(300,1500),"name":"SHELF GALLERY RECOVERY","route":"shelf",
  "line":"Your shelf crossing charted a recovery mouth at the west end of the survey gallery."},
 {"id":"shaft_local_receipt","op":31,"when":{"fact":"warning_chain","is":["service_local_receipt"]},"kind":"drop_guard","index":0,
  "line":"The local warning receipt drew the middle shaft watch away from the feed line."},
 {"id":"shut_in_recovered_workers","op":32,"when":{"fact":"choir_people","is":["landed"]},"kind":"start","pos":Vector2(1100,2700),
  "line":"The recovered Hollins workers charted a direct approach to the foot of Calder's shut-in shaft."},
 {"id":"well_dismantled_listener","op":34,"when":{"fact":"choir_plant","is":["dismantle"]},"kind":"drop_guard","index":0,
  "line":"Dismantling the Hollins plant left Calder's first listener without its feed."}]
