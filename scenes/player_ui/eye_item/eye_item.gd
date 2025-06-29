extends Control
class_name EyeItem

@onready var label: Label = %Label
@onready var beans = %Beans
@onready var cup = %Cup
@onready var espresso = %Espresso
@onready var progress_bar = %ProgressBar
@onready var panel = %Panel

# TODO: Timers, progress bar
var eye_ui_index: int

func _ready():
	progress_bar.value = 0
	await get_tree().create_timer(1).timeout
	Hub.eye_selected.connect(_on_new_eye_item_selected)

	# Set the eye we're labeling in the UI
	eye_ui_index = _parse_node_name()
	
	Hub.eye_arrived_home.connect(func(eye_index): clear_progress_bar())
	Hub.eye_arrived_home.connect(func(eye_index): if eye_ui_index == eye_index: %Ready.visible = true)
	Hub.eye_launched.connect(func(eye_index): if eye_ui_index == eye_index: %Ready.visible = false)
	
	panel.visible = false

func _parse_node_name():
	var parsed_name = str(name).split("Eye")
	if int(parsed_name[1]) == 0:
		return 0
	else:
		return int(parsed_name[1]) - 1

# Dont look at this...
# TODO: Better parsing because we'll need to update the UI
# on other signals that take eye number as an argument
#   - this is completely fine :) whatever works, works - jacob
# NOTE: lol, ok. but I made it better with `_parse_node_name` and you added the eye_index on eye, nice!
func _on_new_eye_item_selected(eye_index):
	if eye_ui_index == eye_index:
		panel.visible = true
	else:
		panel.visible = false


func clear_holding_item():
	cup.visible = false
	beans.visible = false
	espresso.visible = false

func set_holding_item(item_name: Hub.Items):
	clear_holding_item()
	
	if item_name == Hub.Items.CUP:
		cup.visible = true
	elif item_name == Hub.Items.BEANS:
		beans.visible = true
	elif item_name == Hub.Items.ESPRESSO:
		espresso.visible = true

func clear_progress_bar():
	progress_bar.value = 0

func work_increment(inc: int):
	progress_bar.value += inc
	if progress_bar.value >= 100:
		progress_bar.value = 0
