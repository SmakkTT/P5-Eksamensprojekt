extends AnimatableBody3D   # Skift StaticBody3D til AnimatableBody3D i scenen

# Hvor mange grader spejlet drejer per tryk
@export var rotation_step: float = 45.0
# Hvor hurtigt det animerer hen til den nye vinkel
@export var rotation_speed: float = 5.0
# Hvilken akse det drejer rundt om (Y = vandret drej, X = vip op/ned)
@export var rotation_axis: Vector3 = Vector3(0, 1, 0)   # Drejer vandret (Y-aksen)

# Maks afstand spilleren skal være inden for for at aktivere
@export var interact_distance: float = 3.0

var target_rotation: float = 0.0
var current_rotation: float = 0.0
var player: Node3D = null

func _ready():
	# Find spilleren automatisk via gruppe — tilføj din Player-node til gruppen "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(delta):
	# Glat animation mod target-vinklen
	current_rotation = lerp(current_rotation, target_rotation, delta * rotation_speed)
	transform.basis = Basis(rotation_axis, deg_to_rad(current_rotation))

func _input(event):
	if not event.is_action_pressed("interact"):   # Bind "interact" til E i Project Settings
		return
	if player == null:
		return
	if global_position.distance_to(player.global_position) > interact_distance:
		return

	target_rotation += rotation_step
