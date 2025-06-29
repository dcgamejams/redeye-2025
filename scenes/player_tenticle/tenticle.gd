class_name Tenticle
extends Node3D

@onready var path: Path3D = %"Path"

var offset = Vector3(0, 0.2, 0)

func _ready():
	clear()

func add_point(point: Vector3):
	point -= offset
	path.curve.add_point(point)

func pop() -> Vector3:
	var count = path.curve.point_count
	if count:
		var last_point = path.curve.get_point_position(count - 1)
		path.curve.remove_point(count - 1)
	
		return last_point + offset
	return Vector3.ZERO

func clear():
	path.curve.clear_points()
