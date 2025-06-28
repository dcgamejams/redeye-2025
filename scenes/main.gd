extends Node3D

@onready var main_menu = $MainMenu
@onready var eye_container = $EyeContainer

var player_flight_follower_scene = preload("res://scenes/player_flight/player_follower.tscn")
var player_eye_flight_scene = preload("res://scenes/player_flight/player_eye_flight.tscn")

var intro_wait = true

# Main
func _ready() -> void:
	Hub.eye_container = eye_container

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and main_menu.visible:
		main_menu.hide()
		start_game()
	if main_menu.visible or intro_wait:
		return
	
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()

	# There's likely a way to access "change_1" dynamically & parse the eye number to int - 1
	if event.is_action_pressed('change_1'):
		swap_eye(1)
		
	if event.is_action_pressed('change_2'):
		swap_eye(2)

	if event.is_action_pressed('change_3'):
		swap_eye(3)

	if event.is_action_pressed('change_4'):
		swap_eye(4)

	if event.is_action_pressed('change_5'):
		swap_eye(5)
	
	if event.is_action_pressed("launch"):
		launch_eye()
	

func start_game():
	
	# TESTING: https://godotengine.org/asset-library/asset/2272 
	# Testing out using this asset as a base flight controller
	# Open to opinions on it. If we use it, there is still lots
	# to solve for, like collisions, rewinding and the Path3D tube trail

	# Set up 1 follower
	var new_player_follower: SmoothFollow = player_flight_follower_scene.instantiate()
	new_player_follower.distance = 20
	new_player_follower.target = $IntroTarget
	add_child(new_player_follower)

	# Make 5 "player eyes" in random launch spots
	for i in range(5):
		var eye_flight: EyeFlight = player_eye_flight_scene.instantiate()
		eye_flight.active = false
		eye_container.add_child(eye_flight, true)
		eye_flight.position = Hub.launch_points.get_child(i).position
		eye_flight.launch_position = Hub.launch_points.get_child(i).position
		Hub.eye_added.emit(i)
	
	await get_tree().create_timer(3.0).timeout
	intro_wait = false
	new_player_follower.distance = 2
	swap_eye(1)
	Hub.player_ui.visible = true

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
	Hub.current_eye.launch()
