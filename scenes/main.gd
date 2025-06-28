extends Node3D

@onready var main_menu = $MainMenu
@onready var player_container = $PlayerContainer	

var eye_scene = preload("res://scenes/player/player.tscn")

var player_flight_follower_scene = preload("res://scenes/player_flight/player_follower.tscn")
var player_flight_move_plane_scene = preload("res://scenes/player_flight/player_move_plane.tscn")

# Main
func _ready() -> void:
	player_container = player_container

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and main_menu.visible:
		main_menu.hide()
		start_game()
	
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()

# TODO: Determine how to store state
# How many, which keys, how are they named? What properties do they have?

# How do we access them, call methods, swap between? Coordinate activites? Listen for completion

# Node based? get_children()?
# Map?
# Array of Resources?
var eyes = ['1', '2', '3', 'R', 'F'] 

func start_game():
	
	# For now, make 8 for the UI
	for i in range(7):
		Hub.eye_added.emit(i)

	# TODO: add multiple "eyes" or players (?), and listen for input to switch to them. 
	#var new_eye = eye_scene.instantiate()
	#player_container.add_child(new_eye, true)
	
	# TESTING: https://godotengine.org/asset-library/asset/2272 
	
	# Testing out using this asset as a base flight controller
	# Open to opinions on it. If we use it, there is still lots
	# to solve for, like collisions, rewinding and the Path3D tube trail
 	
	var player_flight: MoveAlongObjectForward = player_flight_move_plane_scene.instantiate()
	var player_follower: SmoothFollow = player_flight_follower_scene.instantiate()
	
	var launches = Hub.launch_points.get_children()
	var launch_num = randi_range(0, launches.size() - 1)

	player_follower.target = player_flight

	player_follower.position = launches[launch_num].position
	player_flight.position = launches[launch_num].position

	player_container.add_child(player_flight)
	player_container.add_child(player_follower)
	
	Hub.player_ui.visible = true
