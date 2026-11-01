extends "res://tests/hand_pilot_journeys.gd"
# 139 (Pat 28 Oct: the fleet must matter; a walking-simulator op is a defect).
# The R2 careful hand pilot flies ops 2, 16, 17 and 20 bare with Quietus SILENT
# on STANDARD and ACCESSIBLE. Each must still finish and must put Quietus in
# real contact with the Sirens: Hunt 20 or more, or a received lock.
const CONTACT_OPS=[2,16,17,20]

func run():
 for preset in ["standard","accessible"]:
  for id in CONTACT_OPS:
   var row=fly(id,preset,true)
   check(row.hunt_peak>=20. or row.locks>0,"op%d %s meets the Sirens (hunt_peak=%s locks=%s)"%[id,preset,row.hunt_peak,row.locks])
 print("BARE CONTACT CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
