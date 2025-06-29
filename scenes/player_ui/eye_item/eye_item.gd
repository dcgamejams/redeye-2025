@tool
extends Control
class_name EyeItem

@onready var label: Label = %Label
@onready var beans = %Beans
@onready var cup = %Cup
@onready var espresso = %Espresso
@onready var progress_bar = %ProgressBar

# TODO: Timers, progress bar

func _ready():
	progress_bar.value = 0
	modulate.a = 0.3
	await get_tree().create_timer(1).timeout
	Hub.eye_selected.connect(_on_new_eye_item_selected)

# Dont look at this...
# TODO: Better parsing because we'll need to update the UI
# on other signals that take eye number as an argument
#   - this is completely fine :) whatever works, works - jacob
func _on_new_eye_item_selected(eye):
	modulate.a = 0.3
	var eye_item_number = str(name).split("Eye")
	if int(eye_item_number[1]) == eye:
		modulate.a = 1.0
	elif eye == 1:
		if int(eye_item_number[1]) + 1 == 1:
			modulate.a = 1.0

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
