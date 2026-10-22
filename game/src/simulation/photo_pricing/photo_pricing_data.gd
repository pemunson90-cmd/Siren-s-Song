extends RefCounted
# Applies the table's EDITS to an operation once it has been built. Pure data:
# unknown operations, objectives or features are ignored.
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
static func apply(m:Dictionary,id:int)->void:
	for edit in Table.EDITS:
		if int(edit.op)!=id:continue
		var objs:Array=m.get("objectives",[])
		if int(edit.obj)>=objs.size() or not objs[int(edit.obj)].get("subject") is Dictionary:continue
		var s:Dictionary=objs[int(edit.obj)].subject
		if edit.has("subject"):
			for key in edit.subject:s[key]=edit.subject[key]
		if edit.has("feature"):
			for f in s.get("features",[]):
				if f.id==edit.feature:
					for key in edit.set:f[key]=edit.set[key]
