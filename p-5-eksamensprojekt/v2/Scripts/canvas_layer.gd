extends CanvasLayer

@onready var slider      = $Panel/VBoxContainer/HSlider
@onready var angle_label = $Panel/VBoxContainer/AngleLabel

var current_box = null

func _ready():
	# Skjul menu ved start
	hide()
	slider.value_changed.connect(_on_slider_value_changed)

func open_rotation_menu(box):
	# Åbn menu og vis mus
	current_box = box
	var current_angle = current_box.get_parent().rotation_degrees.y
	slider.value = current_angle
	angle_label.text = str(int(current_angle)) + "°"
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_rotation_menu():
	# Luk menu og skjul mus
	hide()
	current_box = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Luk menu ved input
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.current_interactable = null
		close_rotation_menu()

func _on_slider_value_changed(value):
	# Opdater boksens vinkel
	angle_label.text = str(int(value)) + "°"
	if current_box:
		current_box.set_y_rotation(value)
