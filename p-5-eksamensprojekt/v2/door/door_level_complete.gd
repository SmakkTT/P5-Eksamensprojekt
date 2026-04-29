extends Node3D

@export var interaction_distance: float = 3.0

var is_open: bool = false
var is_locked: bool = true  # Låst fra start
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"
@onready var next_level_trigger: Area3D = $Triggerboxes

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("level_door")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	next_level_trigger.body_entered.connect(_on_next_level_trigger_body_entered)

func _process(_delta: float) -> void:
	pass  # Ingen manuel interact — LevelManager styrer døren

func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance

func get_interact_label_text() -> String:
	if is_locked:
		return "Døren er låst — løs puslespillet først"
	return ""

# Kaldes automatisk af LevelManager når alle objectives er opfyldt
func unlock_door() -> void:
	if not is_locked:
		return
	is_locked = false
	is_open = true
	anim_player.play("toggleRollDoor")  # Åbner døren automatisk

func _on_next_level_trigger_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if not is_open or anim_player.is_playing():
		return
	_on_player_reached_next_level()

func _on_player_reached_next_level() -> void:
	LevelManager.reset()
	FadeTransition.change_scene("res://Scene/Main.tscn")
