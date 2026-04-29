extends Node

# Sættes automatisk — alle noder i gruppen "objective_mirror" tæller
var _mirrors_lit_this_frame: Dictionary = {}
var _target_hit_this_frame: bool = false
var _level_complete: bool = false

func _process(_delta):
	# Nulstil hver frame — laser fylder dem op igen løbende
	_mirrors_lit_this_frame.clear()
	_target_hit_this_frame = false
	
	# Tjek completion til sidst i framen
	_check_completion.call_deferred()

# Kaldes fra laser.gd når den rammer et objective_mirror
func mark_mirror_lit(mirror_node: Node) -> void:
	_mirrors_lit_this_frame[mirror_node] = true

# Kaldes fra laser.gd når den rammer target
func mark_target_hit() -> void:
	_target_hit_this_frame = true

func _check_completion() -> void:
	if _level_complete:
		return
	
	# Hent alle spejle der skal rammes
	var required = get_tree().get_nodes_in_group("objective_mirror")
	
	# Tjek om alle er lit denne frame
	for mirror in required:
		if not _mirrors_lit_this_frame.has(mirror):
			return  # Mindst ét spejl er ikke ramt endnu
	
	# Alle spejle lit OG target ramt?
	if not _target_hit_this_frame:
		return
	
	# Level complete!
	_level_complete = true
	_on_level_complete()

func _on_level_complete() -> void:
	print("Level klaret! Låser dør op.")
	# Find døren og lås den op
	var doors = get_tree().get_nodes_in_group("level_door")
	for door in doors:
		if door.has_method("unlock_door"):
			door.unlock_door()

# Nulstil når nyt level loader
func reset() -> void:
	_mirrors_lit_this_frame.clear()
	_target_hit_this_frame = false
	_level_complete = false
