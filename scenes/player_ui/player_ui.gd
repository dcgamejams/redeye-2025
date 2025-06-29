extends CanvasLayer

# TODO: 
# How does the UI read state from the "players" (eyes)?

var eye_item_scene = preload("res://scenes/player_ui/eye_item/eye_item.tscn")
var eye_list: Dictionary

@onready var launch_label = %"LaunchLabel"

func _ready() -> void:
	Hub.player_ui = self
	Hub.eye_added.connect(_on_new_eye_item)
	Hub.eye_selected.connect(_on_new_eye_item_selected)

func _on_new_eye_item(key):
	var new_eye_item: EyeItem = eye_item_scene.instantiate()
	%EyeList.add_child(new_eye_item, true)
	eye_list[key] = new_eye_item
	new_eye_item.label.text = str(key + 1)

func _on_new_eye_item_selected(eye):
	var new_eye = Hub.get_eye(eye)
	if new_eye.state == new_eye.States.HOME:
		launch_label.visible = true
	else:
		launch_label.visible = false
