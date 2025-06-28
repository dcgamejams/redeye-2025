extends Node3D

@onready var main_menu = $MainMenu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and main_menu.visible:
		main_menu.hide()
		
