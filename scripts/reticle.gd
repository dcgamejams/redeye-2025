class_name Reticle
extends Control

@export var aim_at_object:Node3D

func _ready():
	Hub.eye_selected.connect(_on_eye_selected)

func _on_eye_selected(eye: int):
	aim_at_object = Hub.get_eye(eye).aim_at

func _process(_delta):
	if aim_at_object:
		var pos = aim_at_object.global_position
		var cam = get_tree().root.get_camera_3d()
		var screenPos = cam.unproject_position(pos)
		global_position = screenPos
