extends StaticBody3D
class_name Station

@export var station_label: String
@export var required_eyes: int = 1
@export var required_work: int = 100
@export var work_increment: int = 10
@export var work_rate: float = 0.5

var assigned_eyes: Array[EyeFlight] = []
var work_done = 0
var work_timer: Timer = Timer.new()

func _ready() -> void:
	add_to_group('stations')
	
	work_timer.wait_time = work_rate
	work_timer.one_shot = false
	work_timer.timeout.connect(perform_work)
	add_child(work_timer)

func _process(delta: float) -> void:
	pass

func perform_work():
	if not required_eyes == assigned_eyes.size():
		return
		
	for eye in assigned_eyes:
		# TODO: emit work to the UI.
		pass	
	
	work_done = work_done + work_increment
		
	if work_done == required_work:
		complete_work()
	
func complete_work():
	# EMIT!!!
	pass

func assign_eye(eye: EyeFlight) -> bool:
	if assigned_eyes.size() < required_eyes:
		assigned_eyes.append(eye)

	return true
