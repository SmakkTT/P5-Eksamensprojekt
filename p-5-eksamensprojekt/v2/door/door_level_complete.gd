class_name LevelDoor
extends Node3D

@export var interaction_distance: float = 3.0
@export_file("*.tscn") var next_scene: String = ""  # Set this per level in the Inspector
@export var last_level: bool = false                 # Check this on the final level

var is_open: bool = false
var is_locked: bool = true
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"
@onready var next_level_trigger: Area3D = $Triggerboxes
@onready var door_part: MeshInstance3D = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003"
@onready var sound_door_toggle: AudioStreamPlayer = $Sounds/DoorToggle
@onready var sound_door_locked: AudioStreamPlayer = $Sounds/DoorIsLocked


func _ready() -> void:
	add_to_group("level_door")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	next_level_trigger.body_entered.connect(_on_next_level_trigger_body_entered)

	await get_tree().process_frame
	_init_shader_clip()


func _init_shader_clip() -> void:
	var mat = door_part.get_active_material(0) as ShaderMaterial
	if mat == null:
		push_warning("LevelDoor: no ShaderMaterial found on door_part")
		return

	var aabb: AABB = door_part.get_aabb()
	var local_top := Vector3(0.0, aabb.position.y + aabb.size.y, 0.0)
	var world_top := door_part.global_transform * local_top
	mat.set_shader_parameter("clip_height", world_top.y)


func _process(_delta: float) -> void:
	if player == null:
		return
	if is_player_in_range(player.global_position):
		if is_locked:
			_show_locked_label()
			if Input.is_action_just_pressed("interact"):
				sound_door_locked.play()


func _show_locked_label() -> void:
	if player.get("interact_label") and player.interact_label != null:
		player.interact_label.text = "Døren er låst. Løs puslespillet først"
		player.interact_label.show()


func _unhandled_input(event: InputEvent) -> void:
	# DEBUG: F1 toggles lock on/off
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		if is_locked:
			sound_door_locked.play()
			unlock_door()
		else:
			is_locked = true
			is_open = false
			sound_door_toggle.play()
			anim_player.play_backwards("toggleRollDoor")


func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance


func unlock_door() -> void:
	if not is_locked:
		return
	is_locked = false

	if last_level:
		# Game completed overlay, sound & quit game with a delay
		var label = get_tree().current_scene.get_node_or_null("UI/GameCompleted/GameCompletedLabel")
		label.visible = true
		var green_overlay = get_tree().current_scene.get_node_or_null("UI/GameCompleted/GreenOverlay")
		green_overlay.visible = true
		var complete_audio = get_tree().current_scene.get_node_or_null("UI/GameCompleted/AudioStreamPlayer")
		complete_audio.play()
		FadeTransition.quit_game(3.0)
		return

	# Normal door open — play toggle sound and animate
	is_open = true
	sound_door_toggle.play()
	anim_player.play("toggleRollDoor")


func _on_next_level_trigger_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if not is_open or anim_player.is_playing():
		return
	_on_player_reached_next_level()


func _on_player_reached_next_level() -> void:
	if next_scene == "":
		push_warning("LevelDoor: next_scene is not set in the Inspector!")
		return
	LevelManager.reset()
	FadeTransition.change_scene(next_scene)
