extends Node3D

# --- Settings ---
@export var interaction_distance: float = 3.0

# --- Internal state ---
var is_open: bool = false
var is_locked: bool = false
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"


func _ready() -> void:
	# Register in the "interactable" group so Player.gd can find us for the label
	add_to_group("interactable")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_warning("RollingDoor: No node found in group 'player'.")


func _process(_delta: float) -> void:
	if player == null:
		return

	if is_player_in_range(player.global_position):
		_check_interact_input()


# Called by Player.gd to check whether to show the "Press E" label
func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance


func _check_interact_input() -> void:
	if Input.is_action_just_pressed("interact"):
		if is_locked:
			print("Door is locked. Solve the laser puzzle first!")
			return
		_toggle_door()


func _toggle_door() -> void:
	is_open = not is_open
	if is_open:
		anim_player.play("toggleRollDoor")
	else:
		anim_player.play_backwards("toggleRollDoor")


# --- Called externally once the laser puzzle is solved ---
func unlock_door() -> void:
	pass  # TODO: Set is_locked = false once puzzle completion is implemented
