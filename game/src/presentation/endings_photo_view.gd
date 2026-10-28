extends RefCounted
# 027 wall reuses archive plates, recorded captions and the existing scroll.
# Revert this presenter and its two flow hooks; no persisted state to migrate.
const Ending=preload("res://src/campaign/endings_photo.gd")
const Finale=preload("res://src/presentation/finale/finale.gd")
const LedgerView=preload("res://src/presentation/ledger/ledger_view.gd")
static func present(host,legacy:Callable)->bool:
 var ending=Ending.resolve(host.expedition,host.photo_intel)
 if ending.is_empty():return false
 host.sim.paused=true;host.screen="photo_ending";host._clear_menu()
 var finale=Finale.heading(host,ending)
 if not finale:
  host._menu_text("RECOVERED FILM",28)
  LedgerView.render(host,host.expedition,host.photo_intel)
 var frames=Ending.frames(host.recovered_evidence)
 if frames.is_empty():host._menu_text("NO RECOVERED PHOTOGRAPHS",20)
 for item in frames:
  var plate=host.PhotoView.Plate.new()
  plate.vm=host.PhotoView.from_shot(item.shot)
  plate.custom_minimum_size=Vector2(0,minf(300.,host.size.y*0.32))
  host.panel_box.add_child(plate)
  if item.captions.is_empty():host._menu_text(item.subject,20)
  for caption in item.captions:host._menu_text(caption,18)
 # Research keys are separate from recovered photographs. An empty research
 # set must never deny the real frames above it.
 if not ending.intel_keys.is_empty():host._menu_text("RECOVERED RESEARCH / %d"%ending.intel_keys.size(),18)
 if ending.photo_variant=="studied":host._menu_text("STUDIED SIREN TYPES / 3+",18)
 for key in ending.choices:
  if not ending.choices[key].is_empty():host._menu_text(Finale.fact_line(key,ending.choices[key]),17)
 host._menu_text("FORK OUTCOME / "+ending.title,20)
 host._button(host.panel_box,preload("res://src/persistence/save_states/save2_controller.gd").legacy_title(host,"VIEW FORK OUTCOME").replace("FIRST ENDING","VIEW FIRST ENDING"),legacy,"fork_ending")
 preload("res://src/persistence/save_states/save2_controller.gd").replay_entry(host,"ending")
 if not host.recovered_evidence.is_empty():host._button(host.panel_box,"REVIEW FIELD RECORDS",func():host._evidence_gallery(0),"evidence")
 if finale:Finale.credits_button(host)
 host._button(host.menu_footer,"OPERATIONS ARCHIVE",host._show_campaign,"back");host.menu_footer.show()
 host._save_archive();host.call_deferred("_layout")
 return true
