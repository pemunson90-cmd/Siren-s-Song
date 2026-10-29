extends RefCounted
# Shared unsaved offer choice; each side-mode session owns its current selection.
static func toggle(host,redraw:Callable)->void:
 host.accept_rider=not host.accept_rider;redraw.call()
