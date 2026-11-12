extends RefCounted
# WP-11 (cold review 6, I6): on a loss or withdrawal debrief the action row
# (REVIEW FIELD RECORDS, RETRY, OPERATIONS ARCHIVE) moves up to sit under the
# loss heading and message, so it is on the first screen without scrolling.
# The cause, damage and recovery lines follow it. The buttons stay the same
# nodes in the same scroll content, with the same actions and order.
# Seam: CampaignFlow.debrief and ExpeditionOperations.debrief call lift().
# Revert: ENABLED=false keeps the buttons at the end of the page.
const ENABLED=true
const ACTIONS=["evidence","retry","back"]
static func lift(host,at:int)->void:
 if not ENABLED or at<0:return
 var box:Control=host.panel_box
 var row=[]
 for child in box.get_children():
  if child is Button and str(child.get_meta("action","")) in ACTIONS:row.append(child)
 row.sort_custom(func(a,b):return ACTIONS.find(str(a.get_meta("action","")))<ACTIONS.find(str(b.get_meta("action",""))))
 for n in row.size():box.move_child(row[n],mini(at+n,box.get_child_count()-1))
