extends Station

func _ready() -> void:
	super()

func assign_eye(eye: EyeFlight) -> bool:
	if assigned_eyes.size() <= required_eyes:
		if eye.holding == Hub.Items.NONE:
			assigned_eyes.append(eye)
			eye.current_station = self
			if assigned_eyes.size() == required_eyes:
				start_work_timer()
			return true

	return false

func complete_work():
	for eye in assigned_eyes:
		eye.set_holding_item(Hub.Items.BEANS)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
