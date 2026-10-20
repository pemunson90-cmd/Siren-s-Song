extends SceneTree
func sha(bytes:PackedByteArray)->String:
 var context=HashingContext.new();context.start(HashingContext.HASH_SHA256);context.update(bytes);return context.finish().hex_encode()
func _initialize():
 var args=OS.get_cmdline_user_args();var m=JSON.parse_string(FileAccess.get_file_as_string(args[0]));var restored=0
 for row in m.frames:
  var image=Image.load_from_file(args[1].path_join('%06d.png'%row.index));image.convert(row.format)
  var bytes=image.save_png_to_buffer()
  if sha(bytes)!=row.sha256:printerr('Original PNG reconstruction mismatch ',row.path);quit(1);return
  if '--restore' in args:
   if FileAccess.file_exists(row.path):
    if FileAccess.get_sha256(row.path)!=row.sha256:printerr('Refusing to replace changed original ',row.path);quit(1);return
   else:
    DirAccess.make_dir_recursive_absolute(row.path.get_base_dir())
    var file=FileAccess.open(row.path,FileAccess.WRITE)
    if file==null:printerr("Cannot restore original ",row.path);quit(1);return
    file.store_buffer(bytes);file.close()
  restored+=1
 print('EXACT ORIGINAL PNG RECONSTRUCTION ',restored,' FAILURES 0');quit()
