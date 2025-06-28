@tool
extends PanelContainer
class_name EyeItem

@export var label: Label

# TODO: Timers, progress bar

func _ready():
	label.add_theme_font_size_override("font_size", 80)
	%ProgressBar.custom_minimum_size.x = 180
	%ProgressBar.custom_minimum_size.y = 30
	modulate.a = 0.3
	await get_tree().create_timer(1).timeout
	Hub.eye_selected.connect(_on_new_eye_item_selected)

# Dont look at this...
# TODO: Better parsing because we'll need to update the UI
# on other signals that take eye number as an argument
func _on_new_eye_item_selected(eye):
	modulate.a = 0.3
	var eye_item_number = str(name).split("Eye")
	if int(eye_item_number[1]) == eye:
		modulate.a = 1.0
	elif eye == 1:
		if int(eye_item_number[1]) + 1 == 1:
			modulate.a = 1.0
