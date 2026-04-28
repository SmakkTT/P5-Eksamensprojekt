extends Node3D

# --- Settings ---
@export var interaction_distance: float = 3.0

# --- Internal state ---
var is_open: bool = false
var is_locked: bool = false  # TODO: set back to true once laser puzzle is implemented
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"

# FIX APPLIED HERE: Now targets the Area3D instead of the CollisionShape3D
@onready var next_level_trigger: Area3D = $Triggerboxes


func _ready() -> void:
	# Register in the "interactable" group so Player.gd can find us for the label
	add_to_group("interactable")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_warning("RollingDoor: No node found in group 'player'.")

	# This will now work perfectly because next_level_trigger is an Area3D
	next_level_trigger.body_entered.connect(_on_next_level_trigger_body_entered)


func _process(_delta: float) -> void:
	if player == null:
		return

	if is_player_in_range(player.global_position):
		_check_interact_input()


# Called by Player.gd to check whether to show the "Press E" label
func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance


# Called by Player.gd to get the correct label text when near this door
func get_interact_label_text() -> String:
	if is_locked:
		return "Door is locked"
	return ""  # Empty = use the default "Press E to interact"


func _check_interact_input() -> void:
	if Input.is_action_just_pressed("interact"):
		if is_locked:
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


# --- Triggered when a body enters the NextLevelTrigger area ---
func _on_next_level_trigger_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
		
	# NEW: Abort if the door is closed OR if the door is currently animating
	if not is_open or anim_player.is_playing():
		return
		
	_on_player_reached_next_level()


func _on_player_reached_next_level() -> void:
	# Call your new global Autoload and pass the path to the next level
	FadeTransition.change_scene("res://Scene/Main.tscn")
