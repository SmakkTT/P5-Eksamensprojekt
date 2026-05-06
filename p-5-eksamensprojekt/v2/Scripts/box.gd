extends Node3D

var mirrors_visible: bool = true

@onready var mirror_mesh = $Mirror/MirrorMesh
@onready var mirror_viewport = $Mirror/MirrorMesh/SubViewport
@onready var mirror_cam = $Mirror/MirrorMesh/SubViewport/Camera3D

func _ready():
	# Frigør spejlkameraet
	mirror_cam.set_as_top_level(true)
	
	# Sæt opløsning
	mirror_viewport.size = get_viewport().size
	
	var mat = mirror_mesh.get_active_material(0)
	if mat is ShaderMaterial:
		# Send billede til shader
		mat.set_shader_parameter("reflection_texture", mirror_viewport.get_texture())

func _unhandled_input(event: InputEvent) -> void:
	# DEBUG: F2 toggles mirrors off for performance
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		mirrors_visible = not mirrors_visible

		# Hide meshes
		$Mirror/MirrorMesh.visible = mirrors_visible
		$Mirror/MirrorMesh2.visible = mirrors_visible

		# Stop/start subviewport rendering
		var vp1 = $Mirror/MirrorMesh/SubViewport
		var vp2 = $Mirror/MirrorMesh2/SubViewport
		var update_mode = SubViewport.UPDATE_ALWAYS if mirrors_visible else SubViewport.UPDATE_DISABLED
		vp1.render_target_update_mode = update_mode
		vp2.render_target_update_mode = update_mode

		# Disable mirror cameras
		$Mirror/MirrorMesh/SubViewport/Camera3D.current = mirrors_visible
		$Mirror/MirrorMesh2/SubViewport/Camera3D.current = mirrors_visible

func _process(_delta):
	var main_cam = get_viewport().get_camera_3d()
	if not main_cam: return

	# Match spillerens FOV
	mirror_cam.fov = main_cam.fov

	# Find spejlets plan
	var m_normal = mirror_mesh.global_transform.basis.z.normalized()
	var m_pos = mirror_mesh.global_position
	var plane = Plane(m_normal, m_pos.dot(m_normal))

	# Spejl positionen
	var cam_pos = main_cam.global_position
	var dist = plane.distance_to(cam_pos)
	mirror_cam.global_position = cam_pos - m_normal * (dist * 2.0)

	# Spejl rotationen
	var cam_forward = -main_cam.global_transform.basis.z
	var cam_up = main_cam.global_transform.basis.y
	
	var reflected_forward = cam_forward.bounce(m_normal)
	var reflected_up = cam_up.bounce(m_normal)

	# Opdater spejlkameraet
	mirror_cam.look_at(mirror_cam.global_position + reflected_forward, reflected_up)
