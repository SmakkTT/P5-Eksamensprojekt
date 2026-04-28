extends CanvasLayer

@onready var anim = $AnimationPlayer

func change_scene(target: String) -> void:
	# 1. Play the fade OUT (transparent to black)
	anim.play("dissolve")
	
	# 2. Wait for the animation to finish
	await anim.animation_finished
	
	# 3. Change the actual scene
	get_tree().change_scene_to_file(target)
	
	# 4. Play the fade IN (black to transparent)
	anim.play_backwards("dissolve")

func _ready() -> void:
	# This automatically plays the fade-in the second the game launches!
	anim.play_backwards("dissolve")
