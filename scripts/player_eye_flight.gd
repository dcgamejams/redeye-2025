class_name EyeFlight
extends Node3D

@export_category("Required Nodes")
@export var hurt_area: Area3D
@export var action_area: Area3D

@export var target:Node3D
@export var aim_at: Node3D

@onready var tenticle = %Tenticle

@export_category("Speed")
@export var default_speed = 6.0
@export var speed: float = 6.0
@export var local_space:bool = false

@export_category("Parameters")
@export var tenticle_grow_time:float = 0.01

var active = false
var holding := Hub.Items.NONE

# This enum lists all the possible states the character can be in.
enum States { 
	HOME,
	FLYING, 
	WORKING,
	WORKING_FINISHED,
	RETRACTING_DAMAGED,
	RETRACTING,
}

# This variable keeps track of the character's current state.
var state: States = States.HOME

# TODO: Do we need a higher FOV? 

var original_rotation:Vector3 = Vector3.ZERO

# For prototyping / testing, I'm flipping booleans
var launch_position: Vector3

func _ready() -> void:
	hurt_area.set_collision_layer_value(1, false)
	hurt_area.body_entered.connect(_on_crash_collision)

	action_area.set_collision_layer_value(1, false)
	action_area.body_entered.connect(_on_action_entered)

	original_rotation = basis.get_euler()
	tenticle.reparent(get_tree().root)
	
func smooth_rotation(to_rotation:Vector3, duration:float):
	transform.basis = Basis.from_euler(to_rotation)

func _process(delta):
	match state:
		States.HOME:
			pass
		States.FLYING:
			follow_forward(delta)
		States.WORKING:
			pass
		States.WORKING_FINISHED:
			pass
		States.RETRACTING:
			pass
		States.RETRACTING_DAMAGED:
			pass
			
	
func follow_forward(delta):
	if not target:
		return

	var forward: Vector3 = Vector3.FORWARD
	if (local_space == false) :
		forward = target.global_transform.basis.z
	else:
		forward = target.transform.basis.z

	global_translate((forward * speed) * delta)

func set_state(new_state: States) -> void:
	var previous_state := state
	state = new_state

	############
	# You can check both the previous and the new state to determine what to do when the state changes. 
	# This checks the previous state.
	if previous_state == States.HOME:
		add_launch_speed()
	
	#############
	# Here, I check the new state.
	if state == States.HOME:
		# TODO: Show UI "Launch" banner or tip
		pass
		
	if state == States.WORKING:
		# TODO: animate the tentacle moving
		# TODO: Signal "progress" on a task
		pass
		
	if state == States.WORKING_FINISHED:
		# TODO: Emit to the UI i am done
		pass
	
	if state == States.RETRACTING_DAMAGED:
		_damage_flash()
		await get_tree().create_timer(1.5).timeout
		_respawn_at_home()
		tenticle.clear()


func add_launch_speed():
	# TODO: ramp up speed / acceleration, then once done, set to static 
	pass

func _on_crash_collision(_body):
	set_state(States.RETRACTING_DAMAGED)

func _damage_flash():
	visible = false
	await get_tree().create_timer(0.2).timeout
	visible = true
	await get_tree().create_timer(0.2).timeout
	visible = false
	await get_tree().create_timer(0.2).timeout
	visible = true

func grow_tenticle():
	if state == States.FLYING:
		tenticle.add_point(global_position)
		get_tree().create_timer(tenticle_grow_time).timeout.connect(grow_tenticle)

func _respawn_at_home():
	position = launch_position
	rotation = original_rotation
	
	set_state(States.HOME)

func launch():
	if state == States.HOME:
		set_state(States.FLYING)
		grow_tenticle()

func _on_action_entered(body):
	if body.is_in_group('stations'):
		var station: Station = body
		if station.assign_eye(self) == true:
			set_state(States.WORKING)
