extends Entity

func _process(delta: float) -> void:
	if $EntityContainer/Sprite3D.global_position.y < -30.0 and randi_range(1,10)==5:
		queue_free()
