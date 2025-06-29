extends Control

var min_time: float = 60
var max_time: float = 90
var length: float

var money_penalty_min: int = 5
var money_penalty_max: int = 15

var timer: SceneTreeTimer
var done = false

const FAILURE = preload("res://assets/audio/SFX/trombone.wav")

@onready var timer_texture = %Timer
@onready var cross = %Cross

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	length = randf_range(min_time, max_time)
	timer = get_tree().create_timer(length)
	pop_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if done:
		return
	
	timer_texture.value = (1 - (timer.time_left / length)) * 100
	if timer.time_left <= 0:
		times_up()
		done = true

func pop_in():
	var tween = get_tree().create_tween()
	scale = Vector2.ZERO
	tween.tween_property(
		self,
		"scale",
		Vector2(1, 1),
		1.5
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)

func times_up():
	Hub.update_money(-1 * randi_range(money_penalty_min, money_penalty_max))
	Hub.play_audio(FAILURE, 3, randf_range(0.8, 1.2))
	cross.visible = true
	get_tree().create_timer(0.5).timeout.connect(queue_free)
