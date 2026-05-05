class_name LevelDoor
extends Node3D

@export var interaction_distance: float = 3.0

var is_open: bool = false
var is_locked: bool = true
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $"Sketchfab_model_002/a8a349c2440244838af408996c0ee375_fbx_002/RootNode_002/SM_RollingDoor_002/Door rolling part_003/AnimationPlayer"
@onready var next_level_trigger: Area3D = $Triggerboxes

func _ready() -> void:
	# Opsæt grupper og find spiller
	add_to_group("interactable")
	add_to_group("level_door")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

	next_level_trigger.body_entered.connect(_on_next_level_trigger_body_entered)

func _process(_delta: float) -> void:
	pass

func is_player_in_range(player_pos: Vector3) -> bool:
	return global_position.distance_to(player_pos) <= interaction_distance

func get_interact_label_text() -> String:
	# Vis besked hvis låst
	if is_locked:
		return "Døren er låst. Løs puslespillet først"
	return ""

func unlock_door() -> void:
	# Lås op og åbn dør
	if not is_locked:
		return
	is_locked = false
	is_open = true
	anim_player.play("toggleRollDoor")

func _on_next_level_trigger_body_entered(body: Node3D) -> void:
	# Tjek om døren er helt åben
	if not body.is_in_group("player"):
		return
	if not is_open or anim_player.is_playing():
		return
	_on_player_reached_next_level()

func _on_player_reached_next_level() -> void:
	# Skift niveau
	LevelManager.reset()
	FadeTransition.change_scene("res://Scene/Main.tscn")
