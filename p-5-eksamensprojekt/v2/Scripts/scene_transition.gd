extends CanvasLayer

@onready var anim = $AnimationPlayer

func change_scene(target: String) -> void:
	# Fade til sort
	anim.play("dissolve")

	# Vent på animation
	await anim.animation_finished

	# Skift scene
	get_tree().change_scene_to_file(target)

	# Fade ind igen
	anim.play_backwards("dissolve")

func quit_game(delay: float = 0.0) -> void:
	# Wait for the delay before starting the fade
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	# Fade to black
	anim.play("dissolve")

	# Wait for fade to finish then quit
	await anim.animation_finished
	get_tree().quit()

func _ready() -> void:
	# Fade ind ved start
	anim.play_backwards("dissolve")
