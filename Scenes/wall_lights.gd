extends Node3D

var base_blur = 1.0
var flicker_amplitude = 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Fire sound flicker".play()
