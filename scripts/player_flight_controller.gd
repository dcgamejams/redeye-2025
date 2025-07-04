class_name PlayerFlightController
extends Node3D

@export_subgroup("Speed Control")
@export var normal_speed:float = 4
@export var boost_speed:float = 8
@export var brake_speed:float = 2.5

@export_subgroup("Banking")
@export var min_pitch:float = -30.0
@export var max_pitch:float = 30.0
@export var min_yaw:float = -90.0
@export var max_yaw:float = 90.0
@export var rotation_smoothing:float = 2.0

@export_subgroup("Model & Structure")
@export var player_model:Node3D
@onready var _movement_plane:EyeFlight = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_movement_plane.speed = normal_speed;

var animated_vertical = 0.0
var animated_horizontal = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _movement_plane.active == false:
		return

	if Input.is_action_just_pressed("cancel_and_retract"):
		_movement_plane.cancel_and_retract()

	if _movement_plane.state == _movement_plane.States.HOME or _movement_plane.state == _movement_plane.States.FLYING:
		var speed_delta = ( 
			Input.get_action_strength("ui_text_caret_page_up") - 
			Input.get_action_strength("ui_text_caret_page_down")
		)
		var horizontal:float = (
			Input.get_action_strength("move_right") - 
			Input.get_action_strength("move_left")
		)
		var vertical:float = (
			Input.get_action_strength("move_down") - 
			Input.get_action_strength("move_up")
		)

		_movement_plane.speed = normal_speed
		if Input.is_action_pressed("speed_up"):
			_movement_plane.speed = boost_speed
		elif Input.is_action_pressed("brake"):
			_movement_plane.speed = brake_speed

		var speed = clampf(_movement_plane.speed + (speed_delta * delta), brake_speed, boost_speed)
		
		_movement_plane.speed = speed
		_rotation_look(horizontal, vertical, delta)
		_horizontal_lean(player_model, horizontal, 80, 50, delta)
	

func _rotation_look(horizontal:float, vertical:float, delta:float):
	var aim_rot:Vector3 = _movement_plane.basis.get_euler()
	aim_rot.z = 0
	aim_rot.y += -horizontal * delta
	aim_rot.x += vertical * delta
	aim_rot.x = deg_to_rad(MathLib.clamp_angle(rad_to_deg(aim_rot.x), min_pitch, max_pitch))
	_movement_plane.smooth_rotation(aim_rot, rotation_smoothing * delta)

func _horizontal_lean(target:Node3D, input_axis:float, lean_limit:float, damp:float, delta:float):
	if target:
		var target_euler_angles = target.transform.basis.get_euler()
		var bank = lerp_angle(target_euler_angles.z, input_axis * lean_limit, damp * delta)
		target.rotate_object_local(Vector3.FORWARD, deg_to_rad(bank))

# when return home, we want to clear out where we were looking.
func clear_aim_targeting():
	_movement_plane.rotation = Vector3.ZERO
