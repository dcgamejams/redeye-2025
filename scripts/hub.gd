extends Node

# Event Hub pattern, may not be required, but can help "Signal up" & "Call down" by providing some globals

@warning_ignore("unused_signal")
signal eye_added
signal eye_selected
signal eye_reset

var eye_container: Node3D
var player_ui: CanvasLayer
var launch_points: Node3D
var current_eye: EyeFlight

# TODO: Probably need more than this, ...but.
enum Items { 
	NONE,
	BEANS,
	CUP,
	MILK,
	ESPRESSO,
	COFFEE,
}

func get_eye(eye: int) -> EyeFlight:
	return eye_container.get_child(eye - 1)

# Random for now, may want to be assigned later... 
func get_random_launch_position() -> Vector3:
	var launches = launch_points.get_children()
	var launch_num = randi_range(0, launches.size() - 1)
	return launches[launch_num].position
