extends Station

@onready var audio: AudioStreamPlayer3D = $Audio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	required_eyes = 2
	required_items = [Hub.Items.BEANS, Hub.Items.CUP]

func assign_eye(eye: EyeFlight) -> bool:
	#if not full
	var num_eyes = assigned_eyes.size()
	if num_eyes <= required_eyes:
		if eye.holding in required_items:
			if num_eyes > 0:
				if assigned_eyes[0].holding != eye.holding:
					assigned_eyes.append(eye)
					eye.current_station = self
					if assigned_eyes.size() == required_eyes:
						start_work_timer()
						audio.play()
					return true
				return false
			assigned_eyes.append(eye)
			eye.current_station = self
			return true
	return false

func complete_work():
	audio.stop()
	for eye in assigned_eyes:
		# set the eye holding the cup to espresso to serve
		if eye.holding == Hub.Items.CUP:
			eye.set_holding_item(Hub.Items.ESPRESSO)
		else:
			eye.set_holding_item(Hub.Items.NONE)
		eye.set_state(eye.States.RETRACTING)
	assigned_eyes.clear()
