class_name Reticle
extends Control

@export var aim_at_object:Node3D

func _ready():
	Hub.reticle = self
	pass
	
func _process(_delta):
	if aim_at_object:
		var pos = aim_at_object.global_position
		var cam = get_tree().root.get_camera_3d()
		var screenPos = cam.unproject_position(pos)
		global_position = screenPos
