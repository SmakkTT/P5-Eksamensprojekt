extends MeshInstance3D

var is_active := false

func _ready():
	_add_xray_outline()

func activate():
	if is_active:
		return
	is_active = true
	print("🎯 Level klaret!")

func _add_xray_outline():
	var mat = StandardMaterial3D.new()
	mat.shading_mode        = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color        = Color(1.0, 0.85, 0.0, 1.0)
	mat.cull_mode           = BaseMaterial3D.CULL_FRONT
	mat.no_depth_test       = true
	mat.render_priority     = 1

	# Glow — kræver Glow aktiveret i WorldEnvironment
	mat.emission_enabled            = true
	mat.emission                    = Color(1.0, 0.85, 0.0)
	mat.emission_energy_multiplier  = 4.0   # Højere = stærkere glow

	var outline = MeshInstance3D.new()
	outline.mesh              = self.mesh
	outline.material_override = mat
	outline.scale             = Vector3(1.02, 1.02, 1.02)  # Tynd kant
	outline.name              = "XRayOutline"

	add_child(outline)
