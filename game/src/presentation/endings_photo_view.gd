extends RefCounted
# 027 wall reuses archive plates, recorded captions and the existing scroll.
# Revert this presenter and its two flow hooks; no persisted state to migrate.
const Ending=preload("res://src/campaign/endings_photo.gd")
static func present(host,legacy:Callable)->bool:
 var ending=Ending.resolve(host.expedition,host.photo_intel)
 if ending.is_empty():return false
 host.sim.paused=true;host.screen="photo_ending";host._clear_menu()
 host._menu_text("RECOVERED FILM / "+ending.title,28)
 var frames=Ending.frames(host.recovered_evidence)
 if frames.is_empty():host._menu_text("NO RECOVERED PHOTOGRAPHS",20)
 for item in frames:
  var plate=host.PhotoView.Plate.new()
  plate.vm=host.PhotoView.from_shot(item.shot)
  plate.custom_minimum_size=Vector2(0,minf(300.,host.size.y*0.32))
  host.panel_box.add_child(plate)
  host._menu_text(item.subject,20)
  for caption in item.captions:host._menu_text(caption,18)
 host._menu_text("PHOTO INTEL / %s · %d\n%s"%[ending.photo_variant.to_upper(),ending.intel_keys.size(),ending.variant],17)
 host._button(host.panel_box,"VIEW FORK OUTCOME",legacy,"fork_ending")
 if not host.recovered_evidence.is_empty():host._button(host.panel_box,"REVIEW FIELD RECORDS",func():host._evidence_gallery(0),"evidence")
 host._button(host.menu_footer,"OPERATIONS ARCHIVE",host._show_campaign,"back");host.menu_footer.show()
 host._save_archive();host.call_deferred("_layout")
 return true
