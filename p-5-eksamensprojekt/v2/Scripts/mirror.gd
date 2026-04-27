extends Node3D

@export var interact_distance: float = 3.0

var player: Node3D = null
var is_active: bool = false

signal mirror_activated(mirror)
signal mirror_deactivated

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(_delta):
	if player == null:
		return
	var in_range = global_position.distance_to(player.global_position) <= interact_distance
	if in_range and Input.is_action_just_pressed("interact"):
		if not is_active:
			is_active = true
			mirror_activated.emit(self)
		else:
			is_active = false
			mirror_deactivated.emit()

# Kaldes fra UI-sliderens value_changed signal
func set_rotation_y(value: float):
	rotation_degrees.y = value

func set_rotation_x(value: float):
	rotation_degrees.x = value
