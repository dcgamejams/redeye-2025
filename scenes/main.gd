extends Node3D

@onready var main_menu = $MainMenu
@onready var eye_container = $EyeContainer

const SNARL = preload("res://assets/audio/SFX/enemy_snarl.wav")

var player_flight_follower_scene = preload("res://scenes/player_flight/player_follower.tscn")
var player_eye_flight_scene = preload("res://scenes/player_flight/player_eye_flight.tscn")

var intro_wait = true

# Main
func _ready() -> void:
	Hub.eye_container = eye_container

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_accept") and main_menu.visible:
		main_menu.hide()
		start_game()
	if main_menu.visible or intro_wait:
		return
	
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().quit()

	# There's likely a way to access "change_1" dynamically & parse the eye number to int - 1
	if Input.is_action_just_pressed('change_1'):
		swap_eye(1)
	elif Input.is_action_just_pressed('change_2'):
		swap_eye(2)
	elif Input.is_action_just_pressed('change_3'):
		swap_eye(3)
	elif Input.is_action_just_pressed('change_4'):
		swap_eye(4)
	elif Input.is_action_just_pressed('change_5'):
		swap_eye(5)
	elif Input.is_action_just_pressed("launch"):
		launch_eye()
	

func play_snarl():
	await get_tree().create_timer(0.3).timeout
	var audio_player: = AudioStreamPlayer.new()
	audio_player.stream = SNARL
	audio_player.volume_db = 7
	audio_player.pitch_scale = 0.6
	add_child(audio_player)
	audio_player.connect("finished", audio_player.queue_free, CONNECT_ONE_SHOT)
	audio_player.play()

func start_game():
	
	# TESTING: https://godotengine.org/asset-library/asset/2272 
	# Testing out using this asset as a base flight controller
	# Open to opinions on it. If we use it, there is still lots
	# to solve for, like collisions, rewinding and the Path3D tube trail

	# Set up 1 follower
	var new_player_follower: SmoothFollow = player_flight_follower_scene.instantiate()
	new_player_follower.distance = -20
	new_player_follower.target = $IntroSpawn
	# just ripping the values from the main menu camera to make it less jumpy
	new_player_follower.position = Vector3(14.64, 9.921, -26.01)
	new_player_follower.rotation = Vector3(0, 124.2, 0)
	add_child(new_player_follower)

	# Make 5 "player eyes" in random launch spots
	for i in range(5):
		var eye_flight: EyeFlight = player_eye_flight_scene.instantiate()
		eye_flight.active = false
		eye_flight.eye_index = i
		eye_container.add_child(eye_flight, true)
		eye_flight.global_position = Hub.launch_points.get_child(i).global_position
		eye_flight.launch_position = Hub.launch_points.get_child(i).global_position
		Hub.eye_added.emit(i)
	
	play_snarl()
	
	await get_tree().create_timer(2.0).timeout
	intro_wait = false
	new_player_follower.distance = 2
	swap_eye(1)
	Hub.player_ui.visible = true
	
	order_up()

func order_up():
	get_tree().create_timer(randf_range(20, 30)).timeout.connect(order_up)
	Hub.order_added.emit()

# A placeholder, for demo
# Could be done via statemachine, (on_exit, clean up current eye, switch to new)
func swap_eye(eye: int):
	if Hub.current_eye:
		Hub.current_eye.active = false
	
	var next_eye: EyeFlight = eye_container.get_child(eye - 1)
	next_eye.active = true
	Hub.current_eye = next_eye
	Hub.eye_selected.emit(eye)

func launch_eye():
	if Hub.current_eye:
		Hub.current_eye.launch()
		Hub.player_ui.launch_label.visible = false
