extends CanvasLayer

@onready var slider = $Panel/HSlider
var current_box = null

func _ready():
	hide()
	slider.value_changed.connect(_on_slider_value_changed)

func open_rotation_menu(box):
	current_box = box
	# FIX: Læs nuværende rotation fra MeshInstance3D (forælderen), ikke StaticBody3D
	slider.value = current_box.get_parent().rotation_degrees.y
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_rotation_menu():
	hide()
	current_box = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.current_interactable = null
		close_rotation_menu()

func _on_slider_value_changed(value):
	if current_box:
		current_box.set_y_rotation(value)
