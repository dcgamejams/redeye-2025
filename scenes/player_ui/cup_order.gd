extends Control

var min_time: float = 60
var max_time: float = 90
var length: float

var money_penalty_min: int = 5
var money_penalty_max: int = 15

var timer: SceneTreeTimer
var done = false

@onready var timer_texture = %Timer
@onready var cross = %Cross

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	length = randf_range(min_time, max_time)
	timer = get_tree().create_timer(length)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if done:
		return
	
	timer_texture.value = (1 - (timer.time_left / length)) * 100
	if timer.time_left <= 0:
		times_up()
		done = true

func times_up():
	Hub.update_money(-1 * randi_range(money_penalty_min, money_penalty_max))
	cross.visible = true
	get_tree().create_timer(0.5).timeout.connect(queue_free)
