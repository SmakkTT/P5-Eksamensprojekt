extends CanvasLayer

@onready var slider      = $Panel/HBoxContainer/VBoxContainer/HSlider
@onready var angle_label = $Panel/HBoxContainer/VBoxContainer/AngleLabel
@onready var tilt_slider = $Panel/HBoxContainer2/VBoxContainer2/VSlider
@onready var tilt_label  = $Panel/HBoxContainer2/VBoxContainer2/TiltLabel

var current_box = null

func _ready():
	# Skjul menu ved start
	hide()
	slider.value_changed.connect(_on_slider_value_changed)
	tilt_slider.value_changed.connect(_on_tilt_slider_value_changed)

func open_rotation_menu(box):
	# Åbn menu og vis mus
	current_box = null  # Nullify first so value_changed does not fire rotation
	var current_y = box.get_parent().rotation_degrees.y
	var current_x = box.get_parent().rotation_degrees.x
	# Disconnect before setting value to prevent value_changed firing during setup
	if slider.value_changed.is_connected(_on_slider_value_changed):
		slider.value_changed.disconnect(_on_slider_value_changed)
	if tilt_slider.value_changed.is_connected(_on_tilt_slider_value_changed):
		tilt_slider.value_changed.disconnect(_on_tilt_slider_value_changed)
	slider.value      = current_y
	angle_label.text  = str(int(current_y)) + "°"
	tilt_slider.value = current_x
	tilt_label.text   = str(int(current_x)) + "°"
	# Reconnect after values are set
	slider.value_changed.connect(_on_slider_value_changed)
	tilt_slider.value_changed.connect(_on_tilt_slider_value_changed)
	current_box = box
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_rotation_menu():
	# Luk menu og skjul mus
	hide()
	current_box = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Luk menu ved E eller ESC
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.current_interactable = null
		close_rotation_menu()

	# Piltaster styrer sliderne
	if visible and event is InputEventKey and event.pressed:
		var step = 0.1
		# Shift = større step
		if event.shift_pressed:
			step = 5.0
		match event.keycode:
			KEY_LEFT:
				slider.value -= step
			KEY_RIGHT:
				slider.value += step
			KEY_UP:
				tilt_slider.value += step
			KEY_DOWN:
				tilt_slider.value -= step

## Opdaterer spejlets Y-rotation (venstre/højre)
func _on_slider_value_changed(value):
	var clamped = clampf(value, -180.0, 180.0)
	angle_label.text = str(snappedf(clamped, 0.1)) + "°"
	if current_box:
		current_box.set_y_rotation(clamped)

## Opdaterer spejlets y-rotation (op/ned)
func _on_tilt_slider_value_changed(value):
	var clamped = clampf(value, -180.0, 180.0)
	tilt_label.text = str(snappedf(clamped, 0.1)) + "°"
	if current_box:
		current_box.set_z_rotation(clamped)
