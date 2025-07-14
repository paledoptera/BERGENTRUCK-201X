extends Node3D

@export var music : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.stream = music
	$AudioStreamPlayer.play()
