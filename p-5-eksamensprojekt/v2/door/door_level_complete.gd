class_name LevelDoor
extends Node3D

@export var interaction_distance: float = 3.0
@export_file("*.tscn") var next_scene: String = ""  # Set this per level in the Inspector

var is_open: bool = false
var is_locked: bool = true
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"
@onready var next_level_trigger: Area3D = $Triggerboxes
@onready var door_part: MeshInstance3D = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003"


func _ready() -> void:
	add_to_group("interactable")
	add_to_group("level_door")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	next_level_trigger.body_entered.connect(_on_next_level_trigger_body_entered)

	# Wait one frame so the scene is fully placed in world space
	await get_tree().process_frame
	_init_shader_clip()


func _init_shader_clip() -> void:
	var mat = door_part.get_active_material(0) as ShaderMaterial
	if mat == null:
		push_warning("LevelDoor: no ShaderMaterial found on door_part")
		return

	# Get the door mesh's AABB (local space), find the top corner,
	# then convert it to world space — this is the top of the door frame
	var aabb: AABB = door_part.get_aabb()
	var local_top := Vector3(0.0, aabb.position.y + aabb.size.y, 0.0)
	var world_top := door_part.global_transform * local_top
	mat.set_shader_parameter("clip_height", world_top.y)


func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	# DEBUG: F1 toggles lock on/off
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		if is_locked:
			unlock_door()
		else:
			is_locked = true
			is_open = false
			anim_player.play_backwards("toggleRollDoor")


func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance


func get_interact_label_text() -> String:
	if is_locked:
		return "Døren er låst. Løs puslespillet først"
	return ""


func unlock_door() -> void:
	if not is_locked:
		return
	is_locked = false
	is_open = true
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
