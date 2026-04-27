extends RayCast3D

@onready var beam_mesh = $BeamMesh
@onready var end_particles = $EndParticles
@onready var beam_particles = $BeamParticles

# --- NYT TIL OOP OG REFLEKSION ---
var next_laser = null
const LASER_SCENE = preload("res://Scene/laser.tscn")

@export var max_bounces: int = 10  # Sikkerhedsventil: Maks 10 hop!
@export var current_bounce: int = 0 # Hvor mange hop denne laser har lavet

func _ready():
	pass
	
func _process(delta):
	force_raycast_update()
	
	if is_colliding():
		var cast_point = to_local(get_collision_point())
		var ramt_objekt = get_collider()
		
		# 1. Visuel opdatering (Din eksisterende kode)
		beam_mesh.mesh.height = abs(cast_point.y) 
		beam_mesh.position.y = cast_point.y / 2
		end_particles.position.y = cast_point.y
		beam_particles.position.y = cast_point.y / 2
		
		var particle_amount = int(snapped(abs(cast_point.y) * 50, 1))
		beam_particles.amount = max(1, particle_amount)
		beam_particles.process_material.emission_box_extents = Vector3(
			beam_mesh.mesh.top_radius, abs(cast_point.y) / 2, beam_mesh.mesh.top_radius
		)
		
		# 2. REFLEKSIONS LOGIK (Er det et spejl?)
		if ramt_objekt.is_in_group("spejl") and current_bounce < max_bounces:
			
			# Hvis vi ikke allerede har spawnet den næste laser, så gør vi det nu
			if next_laser == null:
				next_laser = LASER_SCENE.instantiate()
				next_laser.current_bounce = current_bounce + 1 # Tæl bounces op
				next_laser.top_level = true # Gør at den roterer uafhængigt af forælderen
				add_child(next_laser)
			
			# Placer den nye laser præcis der, hvor spejlet bliver ramt
			next_laser.global_position = get_collision_point()
			
			# Vektormatematik: Udregn refleksionen
			var normal = get_collision_normal()
			var incoming_dir = (get_collision_point() - global_position).normalized()
			var bounce_dir = incoming_dir.bounce(normal)
			
			# Få laseren til at kigge i den nye retning
			var look_target = next_laser.global_position + bounce_dir
			next_laser.look_at(look_target, Vector3.UP)
			
			# Vigtig rettelse: Godot's look_at peger (-Z) mod målet, 
			# men jeres raycast peger nedad (-Y). Så vi vipper den lige 90 grader ned!
			next_laser.rotate_object_local(Vector3.RIGHT, deg_to_rad(-90))
			
		else:
			# Hvis vi rammer en væg (eller målet), sletter vi resten af laser-kæden
			kill_next_laser()
			
	else:
		# Hvis laseren slet ikke rammer noget, skal den køre fuld længde
		var max_point = target_position
		beam_mesh.mesh.height = abs(max_point.y)
		beam_mesh.position.y = max_point.y / 2
		end_particles.position.y = max_point.y
		beam_particles.position.y = max_point.y / 2
		kill_next_laser() # Slet evt. reflekterede lasere

# Funktion til at rydde op i hukommelsen
func kill_next_laser():
	if next_laser != null:
		next_laser.queue_free() # Sletter child-laseren fra spillet
		next_laser = null
