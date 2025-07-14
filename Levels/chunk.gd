extends Node3D
class_name Chunk

var life_time = 1.0

func _ready() -> void:
	$GroundRef.visible = false
