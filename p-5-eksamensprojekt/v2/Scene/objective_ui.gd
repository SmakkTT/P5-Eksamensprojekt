extends CanvasLayer

@onready var objective_label: RichTextLabel = $ObjectiveLabel
@onready var progress_label: RichTextLabel  = $ProgressLabel

func _ready():
	# Sæt objective-teksten fra LevelManager
	objective_label.text = "[color=yellow]" + LevelManager.objective_text + "[/color]"

	# Skjul progress hvis ingen spejle kræves
	var needed = _get_needed_count()
	progress_label.visible = needed > 0

func update_progress(lit: int, needed: int, target_hit: bool) -> void:
	if needed == 0:
		progress_label.visible = false
		return

	var mirror_color = "yellow" if lit < needed else "green"
	var target_color = "green" if target_hit else "yellow"

	progress_label.text = (
		"[color=" + mirror_color + "]Spejle ramt: " + str(lit) + "/" + str(needed) + "[/color]\n" +
		"[color=" + target_color + "]Target: " + ("✓" if target_hit else "✗") + "[/color]"
	)

func show_complete() -> void:
	objective_label.text = "[color=green]Dør åbnet! Gå videre![/color]"
	progress_label.text  = "[color=green]Level klaret! ✓[/color]"

func _get_needed_count() -> int:
	var n = LevelManager.required_mirror_count
	if n > 0:
		return n
	return get_tree().get_nodes_in_group("objective_mirror").size()
