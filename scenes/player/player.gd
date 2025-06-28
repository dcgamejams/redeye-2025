extends CharacterBody3D

@export var acceleration = 5
@export var top_speed = 10

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var speed = 0
var flight_direction = Vector3(1, 0, 0)
var flying = false

func _physics_process(delta: float) -> void:
	if not flying:
		if Input.is_action_just_pressed("launch"):
			flying = true
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_collide(velocity)
