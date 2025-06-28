extends Node

# Event Hub pattern, may not be required, but can help "Signal up" & "Call down" by providing some globals

@warning_ignore("unused_signal")
signal eye_added

var player_container: Node3D
var player_ui: CanvasLayer
var launch_points: Node3D
var reticle: Reticle
