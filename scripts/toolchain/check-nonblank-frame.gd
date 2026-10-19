extends SceneTree
# Decode actual PNG pixels using pinned Godot. RGB variation only rejects blank
# frames; it does not identify scene semantics or acknowledge Android composition.
func _initialize():
	var path=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--image="):path=arg.trim_prefix("--image=")
	var image=Image.new()
	if not path.is_absolute_path() or image.load(path)!=OK or image.is_empty():
		print("SS_FRAME_PIXELS invalid");quit(1);return
	image.convert(Image.FORMAT_RGBA8)
	var data=image.get_data();var nonblank=false
	for i in range(4,data.size(),4):
		if data[i]!=data[0] or data[i+1]!=data[1] or data[i+2]!=data[2]:nonblank=true;break
	print("SS_FRAME_PIXELS nonblank=",nonblank)
	quit(0 if nonblank else 3)
