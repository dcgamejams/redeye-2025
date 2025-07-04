extends Node

# Event Hub pattern, may not be required, but can help "Signal up" & "Call down" by providing some globals
signal order_added
signal eye_added
signal eye_selected
signal eye_reset
signal eye_hold
signal eye_work_update
signal set_launch_label
signal money_change
signal money_delta
signal start_game
signal eye_arrived_home
signal eye_launched

var eye_container: Node3D
var player_ui: CanvasLayer
var launch_points: Node3D
var current_eye: EyeFlight
var front_marker: Marker3D

var money = 0

# TODO: Probably need more than this, ...but.
enum Items { 
	NONE,
	BEANS,
	CUP,
	MILK,
	ESPRESSO,
	COFFEE,
}

func get_eye(eye_index: int) -> EyeFlight:
	return eye_container.get_child(eye_index)

# Random for now, may want to be assigned later... 
func get_random_launch_position() -> Vector3:
	var launches = launch_points.get_children()
	var launch_num = randi_range(0, launches.size() - 1)
	return launches[launch_num].position

func update_money(delta: int):
	money += delta
	money_change.emit(money)
	money_delta.emit(delta)

func play_audio(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var audio_player: = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.pitch_scale = pitch_scale
	add_child(audio_player)
	audio_player.connect("finished", audio_player.queue_free, CONNECT_ONE_SHOT)
	audio_player.play()
