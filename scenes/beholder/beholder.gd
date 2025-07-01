extends Node3D

func _ready() -> void:
	Hub.start_game.connect(_start_animation)
	%AnimationPlayer.animation_finished.connect(_fall_back_to_idle)	

func _start_animation():
	%AnimationPlayer.play("Fight")


func _fall_back_to_idle(_finished_animation):
	%AnimationPlayer.play("IDLE")
