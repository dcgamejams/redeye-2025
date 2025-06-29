extends CanvasLayer

var order_scene = preload("res://scenes/player_ui/cup_order.tscn")
var eye_item_scene = preload("res://scenes/player_ui/eye_item/eye_item.tscn")
var eye_list: Dictionary
var order_list: Array

const MAX_ORDERS = 8

@onready var launch_label = %LaunchLabel
@onready var money = %Money

func _ready() -> void:
	Hub.player_ui = self
	Hub.order_added.connect(_on_order_added)
	Hub.eye_added.connect(_on_new_eye_item)
	Hub.eye_selected.connect(_on_new_eye_item_selected)
	Hub.eye_hold.connect(_on_new_eye_hold_added)
	Hub.eye_work_update.connect(_on_new_eye_work_updated)
	Hub.money_change.connect(_on_money_change)
	Hub.set_launch_label.connect(_on_set_launch_label)

func _on_order_added():
	if order_list.size() < MAX_ORDERS:
		var new_order = order_scene.instantiate()
		%Orders.add_child(new_order, true)
		order_list.append(new_order)

func _on_new_eye_item(key):
	var new_eye_item: EyeItem = eye_item_scene.instantiate()
	%EyeList.add_child(new_eye_item, true)
	eye_list[key] = new_eye_item
	new_eye_item.label.text = str(key + 1)

func _on_set_launch_label():
	launch_label.visible = true

func _on_new_eye_item_selected(eye_index: int):
	var new_eye = Hub.get_eye(eye_index)
	if new_eye.state == new_eye.States.HOME:
		launch_label.visible = true
	else:
		launch_label.visible = false

func _on_new_eye_hold_added(eye_idx: int, item: Hub.Items):
	var eye_item: EyeItem = eye_list[eye_idx]
	eye_item.set_holding_item(item)

func _on_new_eye_work_updated(eye_idx: int, work: int):
	var eye_item: EyeItem = eye_list[eye_idx]
	eye_item.work_increment(work)

func _on_money_change(new_val: int):
	if order_list.size():
		var first_order = order_list.pop_front()
		first_order.queue_free()
	
	money.text = str(new_val) + "$"
	if new_val < 0:
		money.modulate = Color.RED
	else:
		money.modulate = Color.GREEN
