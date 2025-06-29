extends Node3D

func _ready() -> void:
	Hub.start_game.connect(_start_animation)
	%AnimationPlayer.animation_finished.connect(func(): %AnimationPlayer.play("IDLE"))	

func _start_animation():
	%AnimationPlayer.play("Fight")
