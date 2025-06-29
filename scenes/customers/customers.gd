extends Node3D

@onready var crowd = %crowd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hub.order_added.connect(on_order_added)
	Hub.money_delta.connect(on_order_finished)

func on_order_added():
	var available_children = []
	for child in crowd.get_children():
		if not child.visible:
			available_children.append(child)
	if available_children.size() == 0:
		return
	var random_index = randi_range(0, available_children.size() - 1)
	available_children[random_index].set_body()

# Orders can expire or complete, doesn't matter, pop the right customer
func on_order_finished(money):
	# only reap if the money was a failure
	if money > 0:
		return
	# quick and dirty reap first active child
	for child in crowd.get_children():
		if child.visible:
			child.reset_body()
			break
