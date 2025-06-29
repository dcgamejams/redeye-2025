extends Station

var money_min: int = 15
var money_max: int = 30

const DING = preload("res://assets/audio/SFX/bell_ding.wav")

func _ready() -> void:
	super()
	work_rate = 0.5
	work_increment = 20

func assign_eye(eye: EyeFlight) -> bool:
	if assigned_eyes.size() <= required_eyes:
		if eye.holding == Hub.Items.ESPRESSO:
			assigned_eyes.append(eye)
			eye.current_station = self
			if assigned_eyes.size() == required_eyes:
				start_work_timer()
			return true

	return false

func complete_work():
	Hub.update_money(randi_range(money_min, money_max))
	Hub.play_audio(DING, 2, randf_range(0.8, 1.1))
	for eye in assigned_eyes:
		eye.set_holding_item(Hub.Items.NONE)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
