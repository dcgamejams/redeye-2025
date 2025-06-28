class_name EyeFlight
extends Node3D

@export_category("Required Nodes")
@export var hurt_area: Area3D
@export var target:Node3D
@export var aim_at: Node3D

@export_category("Speed")
@export var speed:float = 6.0
@export var local_space:bool = false

# TODO: Each eye will have a basic state-machine (code, not node)
# enum States { ACTIVE, FLYING, WORKING, RETRACTING, IDLE, HOME }

# TODO: Do we need a higher FOV? 


var original_rotation:Vector3 = Vector3.ZERO

# For prototyping / testing, I'm flipping booleans
var home = true
var active = false
var launch_position: Vector3

func _ready() -> void:
	hurt_area.set_collision_layer_value(1, false)
	hurt_area.body_entered.connect(_on_crash_collision)
	original_rotation = basis.get_euler()
	
func smooth_rotation(to_rotation:Vector3, duration:float):
	transform.basis = Basis.from_euler(to_rotation)
	
func _process(delta):
	if (target and not home):
		var forward:Vector3 = Vector3.FORWARD
		if (local_space == false) :
			forward = target.global_transform.basis.z
		else:
			forward = target.transform.basis.z
			
		var modulate_speed
		if active:
			modulate_speed = speed
		else:
			modulate_speed = speed / 2
		global_translate((forward * modulate_speed) * delta)

# TODO: rewind after a bad collision. This is essentially respawn for now
# lerp, speed
func _on_crash_collision(_body):
	home = true
	position = launch_position
	rotation = original_rotation
