extends StaticBody3D

func interact():
	get_tree().call_group("UI", "open_rotation_menu", self)

func set_y_rotation(degrees: float):
	# FIX: Roter MeshInstance3D (forælderen) — så mesh OG kollision drejer sammen
	get_parent().rotation_degrees.y = degrees
