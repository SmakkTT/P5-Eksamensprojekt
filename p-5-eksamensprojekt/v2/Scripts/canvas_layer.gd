extends CanvasLayer

@onready var slider = $Panel/HSlider
var current_box = null

func _ready():
	hide()
	slider.value_changed.connect(_on_slider_value_changed)

func open_rotation_menu(box):
	current_box = box
	slider.value = current_box.rotation_degrees.y
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

# Denne funktion kan nu kaldes fra Player-scriptet
func close_rotation_menu():
	hide()
	current_box = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# 'ui_cancel' er typisk ESC. Vi tjekker også for 'interact' (E)
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact")):
		# Fortæl spilleren at interaktionen er slut, så den stopper afstandstjekket
		var player = get_tree().get_first_node_in_group("Player") # Husk at putte din player i en gruppe kaldet "Player"
		if player:
			player.current_interactable = null
		
		close_rotation_menu()

func _on_slider_value_changed(value):
	if current_box:
		current_box.set_y_rotation(value)
