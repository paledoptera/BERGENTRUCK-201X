extends Node3D

@export var chunk_queue: Array[PackedScene]
@export var timer : Timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer.is_stopped() and chunk_queue.size() > 0:
		var chunk = chunk_queue.pop_front().instantiate()
		chunk.global_rotation_degrees.x = -90
		add_child(chunk)
		timer.start(9.0)
