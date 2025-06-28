class_name Tenticle
extends Node3D

@onready var path: Path3D = %"Path"

func _ready():
	clear()

func add_point(point: Vector3):
	point -= Vector3(0, 0.2, 0)
	path.curve.add_point(point)

func pop() -> Vector3:
	var last_point = path.curve.get_point_position(-1)
	path.curve.remove_point(-1)
	
	return last_point

func clear():
	path.curve.clear_points()
