extends SceneTree
func _initialize():
 var result=preload("res://src/presentation/art/art_tests.gd").run()
 print("ART CHECKS ",result.checks," FAILURES ",result.failures)
 quit(1 if result.failures else 0)
