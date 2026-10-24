extends SceneTree
func _initialize():
 var Old=load("C:/Users/Archi/Documents/Codex/2026-10-23/continue-as-codex-on-the-siren/work/landmark_view_before_review.gd")
 var fixed=PackedVector2Array([Vector2(5,0),Vector2(25,0),Vector2(25,70),Vector2(5,70)])
 var thin=PackedVector2Array([Vector2.ZERO,Vector2(100,0),Vector2(100,20),Vector2(0,20)])
 var observed=Old.drawable_pieces(fixed,thin)
 print("BEFORE_REVIEW_HIDDEN_EDGE_OUTPUT ",observed)
 print("LANDMARK BACK EDGE REGRESSION CHECKS 1 FAILURES ",0 if observed.is_empty() else 1)
 quit(0 if observed.is_empty() else 1)
