extends Station

func _ready() -> void:
	super()

func assign_eye(eye: EyeFlight) -> bool:
	if eye.holding == Hub.Items.NONE and assigned_eyes.size() == 0:
		assigned_eyes.append(eye)
		return true

	return false

func perform_work():
	if assigned_eyes.size() == 1:
		work_done = work_done + work_increment
		print('work')
		
	if work_done == required_work:
		complete_work()

func complete_work():
	for eye in assigned_eyes:
		eye.holding = Hub.Items.BEANS
		eye.set_state(eye.States.WORKING_FINISHED)
