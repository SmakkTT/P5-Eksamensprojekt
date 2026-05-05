extends CanvasLayer

@onready var slider      = $Panel/HBoxContainer/VBoxContainer/HSlider
@onready var angle_label = $Panel/HBoxContainer/VBoxContainer/AngleLabel
@onready var tilt_slider = $Panel/HBoxContainer/VBoxContainer2/VSlider
@onready var tilt_label  = $Panel/HBoxContainer/VBoxContainer2/TiltLabel

var current_box = null

func _ready():
	# Skjul menu ved start
	hide()
	slider.value_changed.connect(_on_slider_value_changed)
	tilt_slider.value_changed.connect(_on_tilt_slider_value_changed)

func open_rotation_menu(box):
	# Åbn menu og vis mus
	current_box = box
	var current_y = current_box.get_parent().rotation_degrees.y
	var current_x = current_box.get_parent().rotation_degrees.x
	slider.value      = current_y
	angle_label.text  = str(int(current_y)) + "°"
	tilt_slider.value = current_x
	tilt_label.text   = str(int(current_x)) + "°"
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

## Opdaterer spejlets Y-rotation (venstre/højre)
func _on_slider_value_changed(value):
	angle_label.text = str(snappedf(value, 0.1)) + "°"
	if current_box:
		current_box.set_y_rotation(value)

## Opdaterer spejlets y-rotation (op/ned)
func _on_tilt_slider_value_changed(value):
	tilt_label.text = str(snappedf(value, 0.1)) + "°"
	if current_box:
		current_box.set_z_rotation(value)
