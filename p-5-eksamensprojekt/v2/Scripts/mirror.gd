# mirror.gd  Subclass af Interactable, håndterer spejlrotation (Y = venstre/højre, X = op/ned)
class_name Mirror
extends Interactable

func interact() -> void:
	get_tree().call_group("UI", "open_rotation_menu", self)

## Drejer spejlet om Y-aksen (venstre/højre)
func set_y_rotation(degrees: float) -> void:
	get_parent().rotation_degrees.y = degrees

## Vipper spejlet om Z-aksen (op/ned)
func set_z_rotation(degrees: float) -> void:
	get_parent().rotation_degrees.z = degrees

func get_interact_label_text() -> String:
	return ""  # bruger default "Press E to interact"
