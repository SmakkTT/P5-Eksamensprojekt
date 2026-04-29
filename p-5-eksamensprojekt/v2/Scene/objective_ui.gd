extends CanvasLayer

@onready var objective_label: RichTextLabel = $ObjectiveLabel
@onready var progress_label: RichTextLabel  = $ProgressLabel

func _ready():
	add_to_group("objective_ui")

	# Sæt objective-teksten
	objective_label.bbcode_enabled = true
	objective_label.text = "[font_size=26][b][color=yellow]Brug laserstrålen til at ramme målet for at åbne døren![/color][/b][/font_size]"

	progress_label.bbcode_enabled = true

	# Vis straks med 0 progress så teksten ikke er tom
	var needed = _get_needed_count()
	if needed > 0:
		progress_label.text = "[color=yellow]Ram " + str(needed) + " spejle med laseren: 0/" + str(needed) + "[/color]"
	else:
		progress_label.text = "[color=yellow]Ram målet med laseren[/color]"

func update_progress(lit: int, needed: int, target_hit: bool) -> void:
	if needed == 0:
		progress_label.text = "[color=" + ("green" if target_hit else "yellow") + "]Ram target med laseren " + ("✓" if target_hit else "") + "[/color]"
		return

	var mirror_done = lit >= needed
	var mirror_color = "green" if mirror_done else "yellow"
	var target_color = "green" if target_hit else "yellow"

	progress_label.text = (
		"[color=" + mirror_color + "]Ram " + str(needed) + " spejle med laseren: " + str(min(lit, needed)) + "/" + str(needed) + (" ✓" if mirror_done else "") + "[/color]\n" +
		"[color=" + target_color + "]Ram target med laseren" + (" ✓" if target_hit else "") + "[/color]"
	)

func show_complete() -> void:
	objective_label.text = "[color=green]Dør er åbnet! gå videre![/color]"
	progress_label.text  = ""

func _get_needed_count() -> int:
	var n = LevelManager.required_mirror_count
	if n > 0:
		return n
	return get_tree().get_nodes_in_group("objective_mirror").size()
