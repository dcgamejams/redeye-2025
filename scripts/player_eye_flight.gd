class_name EyeFlight
extends Node3D

@export_category("Required Nodes")
@export var hurt_area: Area3D
@export var action_area: Area3D

@export var target: Node3D
@export var aim_at: Node3D

@onready var tenticle = %Tenticle

@export_category("Speed")
@export var default_speed = 8.0
@export var speed: float = 8.0
@export var local_space: bool = false

@export_category("Parameters")
@export var tenticle_grow_time: float = 0.01
@export var retract_delay: float = 0.5

# hold item meshes
@onready var cup_mesh = %Cup
@onready var espresso_mesh = %Espresso

const SPLAT = preload("res://assets/audio/SFX/splat.wav")

var active = false
# used to keep track of which eye we are for UI interactions
var eye_index: int

# TODO: Setter funcs that emit to the UI when updated
var holding := Hub.Items.NONE

# This enum lists all the possible states the character can be in.
enum States { 
	HOME,
	FLYING, 
	WORKING,
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
	reset_hold_meshes()
	
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
		States.RETRACTING:
			retract()
		States.RETRACTING_DAMAGED:
			retract()
			
	
func follow_forward(delta):
	if not target:
		return

	var forward: Vector3 = Vector3.FORWARD
	if (local_space == false) :
		forward = target.global_transform.basis.z
	else:
		forward = target.transform.basis.z

	global_translate((forward * speed) * delta)

func retract():
	var next_pos = tenticle.pop()
	if next_pos != Vector3.ZERO:
		global_position = next_pos
		get_tree().create_timer(retract_delay).timeout.connect(retract)
	else:
		state = States.HOME
		Hub.set_launch_label.emit()

func reset_hold_meshes():
	cup_mesh.visible = false
	espresso_mesh.visible = false

func set_holding_item(item: Hub.Items):
	holding = item
	Hub.eye_hold.emit(eye_index, item)
	state = States.RETRACTING
	
	reset_hold_meshes()
	if item == Hub.Items.CUP:
		cup_mesh.visible = true
	elif item == Hub.Items.ESPRESSO:
		espresso_mesh.visible = true

func update_work(increment: int):
	Hub.eye_work_update.emit(eye_index, increment)

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
		if active: Hub.player_ui.launch_label.visible = true

		# TODO: Show UI "Launch" banner or tip
		pass
		
	if state == States.WORKING:
		# TODO: animate the tentacle moving
		pass
	
	if state == States.RETRACTING_DAMAGED:
		_damage_flash()


func add_launch_speed():
	# TODO: ramp up speed / acceleration, then once done, set to static
	# we'll see if we actually get to this, not a big deal if not
	pass

func _on_crash_collision(_body):
	play_splat()
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
		play_splat()
		if station.assign_eye(self) == true:
			set_state(States.WORKING)

func play_splat():
	var audio_player: = AudioStreamPlayer.new()
	audio_player.stream = SPLAT
	audio_player.volume_db = 7
	audio_player.pitch_scale = randf_range(0.8, 1)
	add_child(audio_player)
	audio_player.connect("finished", audio_player.queue_free, CONNECT_ONE_SHOT)
	audio_player.play()
