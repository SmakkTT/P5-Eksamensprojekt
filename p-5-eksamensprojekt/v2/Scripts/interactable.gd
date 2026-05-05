# interactable.gd — Superclass for all interactable world objects
class_name Interactable
extends StaticBody3D

func interact() -> void:
	pass

func get_interact_label_text() -> String:
	return ""

func is_player_in_range(player_pos: Vector3) -> bool:
	return false
