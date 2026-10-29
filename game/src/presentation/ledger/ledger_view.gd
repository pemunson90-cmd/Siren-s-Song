extends RefCounted
# 078 ledger presenter: adds panel headings and rows to the existing scrolling menu column (host._menu_text,
# touch scroll and Android Back stay with the hosting screen). Seam: Finale.heading and endings_photo_view.
# Revert: ledger_table.gd enabled=false removes every line.
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
const Table=preload("res://src/campaign/ledger/ledger_table.gd")
static func render(host,progress,intel)->int:
 var panels=Ledger.build(progress,intel,host.get("economy") if host.get("economy") is Dictionary else {})
 if panels.is_empty():return 0
 var count=0
 for panel in panels:
  host._menu_text(panel.title,Table.HEAD_SIZE)
  for row in panel.rows:
   host._menu_text(row,Table.LINE_SIZE);count+=1
 host._menu_text(Table.FOOTER,Table.FOOTER_SIZE)
 return count
