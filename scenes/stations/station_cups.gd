extends Station

const CUP_SFX = preload("res://assets/audio/SFX/cup_impact.wav")

func _ready() -> void:
	super()
	work_rate = 0.5
	work_increment = 20

func assign_eye(eye: EyeFlight) -> bool:
	if assigned_eyes.size() <= required_eyes:
		if eye.holding == Hub.Items.NONE:
			assigned_eyes.append(eye)
			eye.current_station = self
			if assigned_eyes.size() == required_eyes:
				Hub.play_audio(CUP_SFX, 5, randf_range(0.9, 1.1))
				start_work_timer()
			return true

	return false

func complete_work():
	for eye in assigned_eyes:
		eye.set_holding_item(Hub.Items.CUP)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
