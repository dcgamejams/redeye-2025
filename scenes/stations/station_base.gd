extends StaticBody3D
class_name Station

@export var station_label: String
@export var required_eyes: int = 1
@export var required_work: int = 100
@export var required_items: Array[Hub.Items]
@export var work_increment: int = 10
@export var work_rate: float = 0.5

var assigned_eyes: Array[EyeFlight] = []
var work_done = 0

func _ready() -> void:
	add_to_group('stations')

func start_work_timer():
	var work_timer: Timer = Timer.new()
	work_timer.wait_time = work_rate
	work_timer.one_shot = true
	work_timer.timeout.connect(perform_work)
	add_child(work_timer)
	work_timer.start()

func perform_work():
	if not required_eyes == assigned_eyes.size():
		return
		
	for eye in assigned_eyes:
		eye.update_work(work_increment)
	
	work_done = work_done + work_increment
		
	if work_done == required_work:
		complete_work()
		work_done = 0
	else:
		start_work_timer()
	

# FINISH IMPLEMENTATION
func complete_work():
	# EMIT!!!
	pass

# IMPLEMENT REQUIREMENTS
func assign_eye(eye: EyeFlight) -> bool:
	return false
