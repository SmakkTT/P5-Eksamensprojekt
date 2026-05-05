# mirror.gd — Subclass of Interactable, handles mirror rotation
class_name Mirror
extends Interactable

func interact() -> void:
	get_tree().call_group("UI", "open_rotation_menu", self)

func set_y_rotation(degrees: float) -> void:
	get_parent().rotation_degrees.y = degrees

func get_interact_label_text() -> String:
	return ""  # uses default "Press E to interact"
