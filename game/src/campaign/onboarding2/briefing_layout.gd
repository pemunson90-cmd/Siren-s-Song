extends Node
# Presentation-only width adapter for029. No per-frame work or saved state.
# Revert: Rows.enabled=false, or remove the flow hook and this folder.
const Rows=preload("res://src/campaign/onboarding2/briefing_rows.gd")
var host:Control
var queued=false
static func attach(main):
 var layout=main.get_node_or_null("Onboard2BriefingLayout")
 if layout==null:
  layout=load("res://src/campaign/onboarding2/briefing_layout.gd").new()
  layout.name="Onboard2BriefingLayout";layout.host=main;main.add_child(layout)
 layout.queue_reflow()
func _ready():
 host.resized.connect(queue_reflow);host.menu.resized.connect(queue_reflow)
func queue_reflow():
 if queued:return
 queued=true;reflow.call_deferred()
func reflow():
 queued=false
 if not is_instance_valid(host) or host.screen!="briefing" or not Rows.applies(int(host.get_meta("onboard2_fit_index",-1))):return
 var inset=Vector2.ONE*Rows.STYLE.margin
 var desired=host.size-inset*2.
 if host.menu.position.is_equal_approx(inset) and host.menu.size.is_equal_approx(desired):return
 host.menu.position=inset;host.menu.size=desired
