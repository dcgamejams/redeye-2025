extends CanvasLayer

# TODO: 
# How does the UI read state from the "players" (eyes)? 

var eye_item_scene = preload("res://scenes/player_ui/eye_item/eye_item.tscn")

func _ready() -> void:
	Hub.player_ui = self
	Hub.eye_added.connect(_on_new_eye_item)
	Hub.eye_selected.connect(_on_new_eye_item_selected)

func _on_new_eye_item(key):
	var new_eye_item: EyeItem = eye_item_scene.instantiate()
	new_eye_item.label.text = str(key + 1)
	%EyeList.add_child(new_eye_item)

func _on_new_eye_item_selected(eye):
	pass
