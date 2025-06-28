@tool
extends PanelContainer
class_name EyeItem

@export var label: Label

# TODO: Timers, progress bar

func _ready():
	label.add_theme_font_size_override("font_size", 100)
	%ProgressBar.custom_minimum_size.x = 200
	%ProgressBar.custom_minimum_size.y = 40
