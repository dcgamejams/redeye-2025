extends Station

func _ready() -> void:
	super()

func complete_work():
	for eye in assigned_eyes:
		# TODO: EMIT COMPLETE
		eye.set_state(eye.States.WORKING_FINISHED)
