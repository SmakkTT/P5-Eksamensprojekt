extends StaticBody3D

# Funktionen som RayCasten kalder
func interact():
	# Vi kalder en global gruppe "UI", og beder den åbne slideren for denne boks
	get_tree().call_group("UI", "open_rotation_menu", self)

# Funktionen som UI'en kalder for at rotere boksen
func set_y_rotation(degrees: float):
	rotation_degrees.y = degrees
