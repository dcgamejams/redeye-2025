class_name EyeFlight
extends Node3D

# NOTE: Post jam potential:
# TODO: Silly physics / wiggles & jiggles
# TODO: Ragdoll arm on collision
# TODO: Add collision shapes to the ingriedents, so they can fall off
# TODO: You're physically carrying the beans or cups. They can break.
# TODO: Sloshing coffee, spilling if you BANK too hard left or right or go too fast

@export_category("Required Nodes")
@export var hurt_area: Area3D
@export var action_area: Area3D

@export var target: Node3D
@export var aim_at: Node3D

@onready var tenticle = %Tenticle
@onready var eye_index_label = $Label3D

@export_category("Speed")
@export var default_speed = 8.0
@export var speed: float = 8.0
@export var local_space: bool = false

@export_category("Parameters")
@export var tenticle_grow_time: float = 0.01

# hold item meshes
@onready var cup_mesh = %Cup
@onready var espresso_mesh = %Espresso
@onready var beans_mesh = %Beans
@onready var animation_player = $AnimationPlayer

const SNARL = preload("res://assets/audio/SFX/enemy_snarl.wav")
const SPLAT = preload("res://assets/audio/SFX/splat.wav")
const SWOOSH = preload("res://assets/audio/SFX/swoosh.wav")

var active = false
# used to keep track of which eye we are for UI interactions
var eye_index: int
var current_station: Station

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


var retract_timer = Timer.new()


func _ready() -> void:
	hurt_area.set_collision_layer_value(1, false)
	hurt_area.body_entered.connect(_on_crash_collision)

	action_area.set_collision_layer_value(1, false)
	action_area.body_entered.connect(_on_action_entered)

	original_rotation = basis.get_euler()
	tenticle.reparent(get_tree().root)
	reset_hold_meshes()
	
	eye_index_label.text = str(eye_index + 1)
	
	# this will hide the label when selected... but, it's nice to know what you're on... maybe it should decrease text size...
	Hub.eye_selected.connect(swap_font_size)

	animation_player.speed_scale = 1.6

func swap_font_size(selected_index):
	if selected_index == eye_index: 
		eye_index_label.font_size = 32 
		eye_index_label.outline_size = 12
	else:  
		eye_index_label.font_size = 120 
		eye_index_label.outline_size = 64


func smooth_rotation(to_rotation:Vector3, _duration:float):
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
	if active and Input.is_action_pressed("speed_up"):
		tenticle.pop()
		tenticle.pop()
	else:
		tenticle.pop()
		
	var next_pos = tenticle.pop()
	if next_pos != Vector3.ZERO:
		global_position = next_pos
	else:
		set_state(States.HOME)


func reset_hold_meshes():
	cup_mesh.visible = false
	espresso_mesh.visible = false
	beans_mesh.visible = false
	
func set_holding_item(item: Hub.Items):
	holding = item
	Hub.eye_hold.emit(eye_index, item)
	set_state(States.RETRACTING)
	
	reset_hold_meshes()
	if item == Hub.Items.CUP:
		cup_mesh.visible = true
	elif item == Hub.Items.ESPRESSO:
		espresso_mesh.visible = true
	elif item == Hub.Items.BEANS:
		beans_mesh.visible = true

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

	if previous_state == States.WORKING:
		animation_player.play("RESET")
		animation_player.stop()

	#############
	# Here, I check the new state.
	if new_state == States.HOME:
		Hub.eye_arrived_home.emit(eye_index)
		target.clear_aim_targeting()
		if active:
			Hub.set_launch_label.emit(true)
		
	if new_state == States.WORKING:
		animate_working()
		pass
	
	if state == States.RETRACTING_DAMAGED:
		_damage_flash()


func add_launch_speed():
	# TODO: ramp up speed / acceleration, then once done, set to static
	# we'll see if we actually get to this, not a big deal if not
	pass

func _on_crash_collision(_body):
	if state == States.RETRACTING or state == States.RETRACTING: 
		return

	Hub.play_audio(SPLAT, 5, randf_range(0.8, 1))
	Hub.play_audio(SNARL, 7, randf_range(0.8, 1.2))
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
		Hub.play_audio(SWOOSH, 3, randf_range(0.9, 1.1))
		grow_tenticle()

func _on_action_entered(body):
	# No working when retracting!
	if state == States.RETRACTING or state == States.RETRACTING_DAMAGED: 
		return

	if body.is_in_group('stations'):
		var station: Station = body
		Hub.play_audio(SPLAT, 7, randf_range(0.8, 1))
		if station.assign_eye(self) == true:
			set_state(States.WORKING)

func cancel_and_retract():
	if state == States.WORKING:
		current_station.unassign_eye(self)
		current_station = null
	
	set_state(States.RETRACTING)

func animate_working():
	animation_player.play("eye_animations/circle")
