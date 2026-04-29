extends Node

# --- Konfigurér disse i hvert level ---
@export var objective_text: String = "Brug laserstrålen til at ramme target for at åbne døren!"
@export var required_mirror_count: int = 0  # 0 = alle i gruppen "objective_mirror"

# --- Intern state ---
var _mirrors_lit_this_frame: Dictionary = {}
var _target_hit_this_frame: bool = false
var _level_complete: bool = false

func _process(_delta):
	_mirrors_lit_this_frame.clear()
	_target_hit_this_frame = false
	_check_completion.call_deferred()

func mark_mirror_lit(mirror_node: Node) -> void:
	_mirrors_lit_this_frame[mirror_node] = true

func mark_target_hit() -> void:
	_target_hit_this_frame = true

func _check_completion() -> void:
	if _level_complete:
		return

	var all_objective_mirrors = get_tree().get_nodes_in_group("objective_mirror")
	var needed = required_mirror_count if required_mirror_count > 0 else all_objective_mirrors.size()
	var lit_count = _mirrors_lit_this_frame.size()

	# Opdater UI med progress
	_update_objective_ui(lit_count, needed)

	# Tjek om nok spejle er ramt
	if lit_count < needed:
		return

	# Tjek om target er ramt
	if not _target_hit_this_frame:
		return

	_level_complete = true
	_on_level_complete()

func _update_objective_ui(lit: int, needed: int) -> void:
	var ui = get_tree().get_first_node_in_group("objective_ui")
	if ui and ui.has_method("update_progress"):
		ui.update_progress(lit, needed, _target_hit_this_frame)

func _on_level_complete() -> void:
	var doors = get_tree().get_nodes_in_group("level_door")
	for door in doors:
		if door.has_method("unlock_door"):
			door.unlock_door()

	# Fortæl UI at level er klaret
	var ui = get_tree().get_first_node_in_group("objective_ui")
	if ui and ui.has_method("show_complete"):
		ui.show_complete()

func reset() -> void:
	_mirrors_lit_this_frame.clear()
	_target_hit_this_frame = false
	_level_complete = false
