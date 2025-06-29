class_name Tenticle
extends Node3D

@onready var path: Path3D = %"Path"
@onready var tenticle_poly: CSGPolygon3D = %CSGPolygon3D

var offset = Vector3(0, 0.2, 0)

func _ready():
	clear()
	tenticle_poly.polygon = generate_circle_polygon(0.22, 64, Vector2.ZERO)

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


func generate_circle_polygon(radius: float, num_sides: int, position: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	return polygon
