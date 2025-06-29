extends Node3D

var active_crowd: Array[int] = []

@onready var crowd = %crowd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hub.order_added.connect(on_order_added)
	Hub.money_change.connect(on_order_finished)
	for node in crowd.get_children():
		node.visible = false

func on_order_added():
	var random_index = randi_range(0, crowd.get_child_count() - 1)
	crowd.get_child(random_index).visible = true
	# First in, first out 
	active_crowd.push_front(random_index)

# Orders can expire or complete, doesn't matter, pop the right customer
func on_order_finished(_money):
	var completed_crowd_index = active_crowd.pop_back()
	crowd.get_child(completed_crowd_index).visible = false
