extends MeshInstance3D

var spin_speed = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += delta * spin_speed
