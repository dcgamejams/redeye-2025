extends Station

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	required_items = [Hub.Items.BEANS, Hub.Items.CUP]

func assign_eye(eye: EyeFlight) -> bool:
	#if not full
	
	if eye.holding in required_items:
		return true
		
	 		
	return false
