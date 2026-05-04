extends CharacterBody3D

# --- Indstillinger for bevægelse ---
const WALK_SPEED = 5.0 # Hvor hurtigt vi går
const SPRINT_SPEED = 19.0 # Hvor hurtigt vi løber
const JUMP_VELOCITY = 4.5 # Hvor højt vi hopper
const SENSITIVITY = 0.003 # Hvor hurtigt kameraet drejer (muse-følsomhed)

const ACCELERATION = 10.0
const FRICTION = 10.0

# --- Indstillinger for "Headbob" (kameraet der vipper når man går) ---
const BOB_FREQ = 2.0
const BOB_AMP = 0.05
const IDLE_BOB_FREQ = 1.0
const IDLE_BOB_AMP = 0.01 
var t_bob = 0.0

# Henter alle vores lyde fra scenen
@onready var flashlight_audio = $FlashlightAudio
@onready var walk_audio = $WalkAudio
@onready var sprint_audio = $SprintAudio

# Henter kameraet og lommelygten
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
@onready var spotlight: SpotLight3D = $Neck/Flashlight/SpotLight3D
@onready var flashlight_anim: AnimationPlayer = $Neck/Flashlight/AnimationPlayer

# Raycast (LaserSpil) 
@onready var interact_ray = $Neck/Camera3D/RayCast3D

# "Press E" label – lives at UI/Interactable in the main scene
@onready var interact_label: Label = get_tree().root.get_node("Main/UI/Interactable")

var current_interactable = null
var _interact_label_default_text: String = ""

# Kører når spillet starter
func _ready() -> void:
	# Låser og skjuler musen, så den ikke er i vejen på skærmen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if flashlight_anim.has_animation("draw"):
		flashlight_anim.play("draw")
	else:
		print_debug("Warning: 'draw' animation not found on AnimationPlayer")
	
	interact_label.hide()
	_interact_label_default_text = interact_label.text

# Fanger når spilleren bruger musen eller tasterne
func _unhandled_input(event: InputEvent) -> void:
	# Drejer spillerens hoved og krop, når musen bevæges
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		neck.rotate_x(event.relative.y * SENSITIVITY)
		# Sørger for, at man ikke kan kigge længere op/ned end direkte op i loftet/ned i gulvet
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# Viser musen igen, hvis man f.eks. trykker Escape (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	# Tænder/slukker lommelygten og afspiller klik-lyden
	if event.is_action_pressed("toggle_flashlight"):
		spotlight.visible = not spotlight.visible
		flashlight_audio.play()
		
	# Tjek om spilleren trykker på 'E'
	if event.is_action_pressed("interact"):
		if interact_ray.is_colliding():
			var target = interact_ray.get_collider()
			# Tjek om det vi kigger på, har en "interact" funktion
			if target.has_method("interact"):
				target.interact()
				current_interactable = target

# NY FUNKTION (LASER)
func _process(delta):
	# Hvis vi har en menu åben (current_interactable er ikke tom)
	if current_interactable:
		var distance = global_position.distance_to(current_interactable.global_position)
		# Hvis vi er mere end 1.5 meter væk
		if distance > 1.5:
			close_current_interaction()

	# --- Opdater "Press E" label ---
	_update_interact_label()

# Checks whether any interactable is close/aimed-at and shows/hides the label
func _update_interact_label() -> void:
	# Don't show the label while a rotation menu is open
	if current_interactable != null:
		interact_label.hide()
		return

	# 1. Check raycast for mirrors / anything with interact()
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target.has_method("interact"):
			interact_label.text = _interact_label_default_text
			interact_label.show()
			return

	# 2. Check proximity-based interactables (doors etc.) in group "interactable"
	for node in get_tree().get_nodes_in_group("interactable"):
		if node.has_method("is_player_in_range") and node.is_player_in_range(global_position):
			if node.has_method("get_interact_label_text"):
				var custom_text: String = node.get_interact_label_text()
				interact_label.text = custom_text if custom_text != "" else _interact_label_default_text
			else:
				interact_label.text = _interact_label_default_text
			interact_label.show()
			return

	interact_label.hide()
		
# NY FUNKTION (LASER)
func close_current_interaction():
	get_tree().call_group("UI", "close_rotation_menu")
	current_interactable = null



# Styrer fysikken og bevægelsen (kører hele tiden)
func _physics_process(delta: float) -> void:
	# Tilføjer tyngdekraft, hvis spilleren falder / er i luften
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Får spilleren til at hoppe
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Tjekker om spilleren holder løbe-knappen nede
	var current_speed = WALK_SPEED
	var is_sprinting = false
	
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
		is_sprinting = true

	# Fanger hvilke knapper spilleren trykker på (W, A, S, D) og udregner retningen
	var input_dir := Input.get_vector("moveleft", "moveright", "moveforward", "moveback")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()

	# Gør bevægelsen mere glidende (acceleration og friktion)
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)

	# Får spilleren til rent faktisk at rykke sig i 3D-verdenen
	move_and_slide()

	# --- STYRER FODTRIN-LYDENE ---
	# Tjekker om vi rører jorden, og om vi faktisk bevæger os
	if is_on_floor() and velocity.length() > 0.1:
		if is_sprinting:
			# Stopper gå-lyden og starter løbe-lyden
			walk_audio.stop()
			if not sprint_audio.playing:
				sprint_audio.play()
		else:
			# Stopper løbe-lyden og starter gå-lyden
			sprint_audio.stop()
			if not walk_audio.playing:
				walk_audio.play()
	else:
		# Stopper alle lyde, hvis vi står stille eller er i luften
		walk_audio.stop()
		sprint_audio.stop()

	# --- STYRER HEADBOB (Kameraet vipper) ---
	var bob_target := Vector3.ZERO
	
	if not flashlight_anim.is_playing() or flashlight_anim.current_animation != "draw":
		if is_on_floor():
			if velocity.length() > 0.1: 
				t_bob += delta * velocity.length()
				bob_target = _headbob(t_bob, BOB_FREQ, BOB_AMP)
			else:
				t_bob += delta * 2.0 
				bob_target = _headbob(t_bob, IDLE_BOB_FREQ, IDLE_BOB_AMP)

	camera.transform.origin = camera.transform.origin.lerp(bob_target, 10 * delta)

# Hjælpe-funktion til at udregne den matematik der får kameraet til at vippe
func _headbob(time: float, freq: float, amp: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * freq) * amp
	pos.x = cos(time * freq / 2) * amp
	return pos
