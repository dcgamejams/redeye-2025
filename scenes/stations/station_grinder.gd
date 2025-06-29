extends Station

@onready var audio: AudioStreamPlayer3D = $Audio

func _ready() -> void:
	super()

func assign_eye(eye: EyeFlight) -> bool:
	if assigned_eyes.size() <= required_eyes:
		if eye.holding == Hub.Items.NONE:
			assigned_eyes.append(eye)
			eye.current_station = self
			if assigned_eyes.size() == required_eyes:
				start_work_timer()
				audio.play()
			return true
	return false

func complete_work():
	audio.stop()
	for eye in assigned_eyes:
		eye.set_holding_item(Hub.Items.BEANS)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
