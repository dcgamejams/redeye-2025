extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hub.start_game.connect(_start_animation)
	

func _start_animation():
	%AnimationPlayer.play("Fight")
	await get_tree().create_timer(3.0).timeout
	%AnimationPlayer.play("IDLE")
