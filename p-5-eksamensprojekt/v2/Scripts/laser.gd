extends RayCast3D

@onready var beam_mesh      = $BeamMesh
@onready var end_particles  = $EndParticles
@onready var beam_particles = $BeamParticles

var next_laser = null
const LASER_SCENE = preload("res://Scene/laser.tscn")

@export var max_bounces:    int   = 10
@export var current_bounce: int   = 0
@export var laser_length:   float = 100.0

const SURFACE_OFFSET: float = 0.02

func _ready():
	beam_mesh.mesh = beam_mesh.mesh.duplicate()
	beam_particles.process_material = beam_particles.process_material.duplicate()
	target_position = Vector3(0, -laser_length, 0)

func _process(_delta):
	force_raycast_update()

	if is_colliding():
		var cast_point  = to_local(get_collision_point())
		var ramt_objekt = get_collider()

		# --- Visuel opdatering ---
		var beam_length = abs(cast_point.y)
		beam_mesh.mesh.height             = beam_length
		beam_mesh.position.y              = cast_point.y / 2.0
		end_particles.position.y          = cast_point.y
		beam_particles.position.y         = cast_point.y / 2.0

		var particle_amount = int(snapped(beam_length * 50, 1))
		beam_particles.amount = max(1, particle_amount)
		beam_particles.process_material.emission_box_extents = Vector3(
			beam_mesh.mesh.top_radius,
			beam_length / 2.0,
			beam_mesh.mesh.top_radius
		)

		# --- Refleksionslogik ---
		if ramt_objekt.is_in_group("spejl") and current_bounce < max_bounces:
			var normal       = get_collision_normal()
			var incoming_dir = (get_collision_point() - global_position).normalized()
			var bounce_dir   = incoming_dir.bounce(normal)

			if next_laser == null:
				next_laser = LASER_SCENE.instantiate()
				next_laser.current_bounce = current_bounce + 1
				next_laser.top_level = true
				add_child(next_laser)

				# FIX 1: Udeluk det spejl vi netop ramte —
				# child-laseren kan dermed ALDRIG ramme det igen,
				# uanset kassens størrelse eller vinkel.
				next_laser.add_exception(ramt_objekt)

			next_laser.global_position = get_collision_point() + bounce_dir * SURFACE_OFFSET

			# FIX 2: Sæt rotation direkte med en Quaternion i stedet for
			# den skrøbelige look_at + rotate_object_local kombination.
			# Laseren fyrer langs lokal -Y, så vi roterer (0,-1,0) hen mod bounce_dir.
			var q = Quaternion(Vector3.DOWN, bounce_dir.normalized())
			next_laser.global_transform.basis = Basis(q)

		else:
			kill_next_laser()

	else:
		var beam_length = abs(target_position.y)
		beam_mesh.mesh.height             = beam_length
		beam_mesh.position.y              = target_position.y / 2.0
		end_particles.position.y          = target_position.y
		beam_particles.position.y         = target_position.y / 2.0
		kill_next_laser()

func kill_next_laser():
	if next_laser != null:
		next_laser.queue_free()
		next_laser = null
