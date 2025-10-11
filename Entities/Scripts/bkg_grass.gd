extends Node3D
@export var sprite : Sprite3D

func _process(delta: float) -> void:
	if sprite.global_position.y < -30.0:
		queue_free()
