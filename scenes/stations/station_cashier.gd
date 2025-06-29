extends Station

var money_min: int = 15
var money_max: int = 30

const SIP = preload("res://assets/audio/SFX/sip.wav")
const CASH = preload("res://assets/audio/SFX/cash-register.wav")

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
				Hub.play_audio(SIP, 8, randf_range(0.8, 1.2))
				start_work_timer()
			return true

	return false

func complete_work():
	Hub.update_money(randi_range(money_min, money_max))
	Hub.play_audio(CASH, 5, randf_range(0.95, 1.05))
	for eye in assigned_eyes:
		eye.set_holding_item(Hub.Items.NONE)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
	visible = false
