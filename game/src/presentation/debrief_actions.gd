extends RefCounted
# WP-11 (cold review 6, I6): on a loss or withdrawal debrief the action row
# (PHOTO GALLERY, RETRY, OPERATIONS ARCHIVE) moves up to sit under the
# loss heading and message, so it is on the first screen without scrolling.
# The cause, damage and recovery lines follow it. The buttons stay the same
# nodes in the same scroll content, with the same actions and order.
# Seam: CampaignFlow.debrief and ExpeditionOperations.debrief call lift().
# Revert: ENABLED=false keeps the buttons at the end of the page.
const ENABLED=true
const ACTIONS=["evidence","retry","back"]
static func lift(host,at:int)->void:
 if not ENABLED or at<0:return
 var box=host.panel_box # a Control in the game; test hosts pass a plain Node
 var row=[]
 for child in box.get_children():
  if child is Button and str(child.get_meta("action","")) in ACTIONS:row.append(child)
 row.sort_custom(func(a,b):return ACTIONS.find(str(a.get_meta("action","")))<ACTIONS.find(str(b.get_meta("action",""))))
 for n in row.size():box.move_child(row[n],mini(at+n,box.get_child_count()-1))
# WP-109 (critic round 8): the result's buttons never need a scroll and are never clipped by the card edge. They move
# from the scrolling page into the pinned footer row (menu_footer, sized by Main._layout), in this order. The same
# nodes keep their actions; only their parent changes. Seams: the Campaign, Expedition-operation, Career and
# Expedition-run result menus call footer() last. Revert: FOOTER=false leaves the buttons at the end of the page.
const FOOTER=true
const FOOTER_ACTIONS=["evidence","next_dive","next_expedition","expedition6","run_next","retry","career_retry","run_retry_save","career_board","run_return","back"]
static func footer(host)->void:
 if not FOOTER or host.get("menu_footer")==null:return
 var box=host.panel_box
 var row=[]
 for child in box.get_children():
  if child is Button and str(child.get_meta("action","")) in FOOTER_ACTIONS:row.append(child)
 if row.is_empty():return
 row.sort_custom(func(a,b):return FOOTER_ACTIONS.find(str(a.get_meta("action","")))<FOOTER_ACTIONS.find(str(b.get_meta("action",""))))
 for button in row:
  box.remove_child(button);host.menu_footer.add_child(button)
  button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;button.mouse_filter=Control.MOUSE_FILTER_STOP
 host.menu_footer.show()
