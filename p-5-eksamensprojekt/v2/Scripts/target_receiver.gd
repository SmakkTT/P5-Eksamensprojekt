# target_receiver.gd — Subclass of Interactable, receives the laser beam
class_name TargetReceiver
extends Interactable

func interact() -> void:
	pass  # Player cannot interact with the target directly

func get_interact_label_text() -> String:
	return ""  # No label shown
