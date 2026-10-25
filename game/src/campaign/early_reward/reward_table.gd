extends RefCounted
# D2: switch off to stop new grants; keep loading saved ownership.
# Operation ids are zero based: id 1 is player op 2 (the Tele lens), id 3 is player op 4,
# id 5 is player op 6. All three arrive before player op 7. AI-DESIGNED spacing, Pat to adjust.
# low_light_back shares the OPTICS mount with the Tele lens on purpose: reach or darkness.
static var enabled=true
const GRANTS=[
 {"operation":1,"module":"quietus_tele_lens","explanation":"Tele lens: shoot farther through a narrower frame; shutter noise is unchanged."},
 {"operation":3,"module":"quietus_baffles","explanation":"Acoustic baffles: 45% less propulsion sound at the same speed. Hide while you move."},
 {"operation":5,"module":"low_light_back","explanation":"Low-light film back: an 8 second still exposure sharpens dark subjects without a flash. Shares the optics mount with the Tele lens."}]
const GRANT=GRANTS[0]
static func modules()->Array:
 var result=[]
 for g in GRANTS:result.append(g.module)
 return result
static func entry(module:String)->Dictionary:
 for g in GRANTS:
  if g.module==module:return g
 return {}
