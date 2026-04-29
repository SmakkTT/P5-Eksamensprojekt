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

func _ready() -> void:
	# Fade ind ved start
	anim.play_backwards("dissolve")
