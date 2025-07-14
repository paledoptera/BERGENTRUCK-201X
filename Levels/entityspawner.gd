extends Node3D

@export_file var chunk_queue: Array[String]
@export var timer : Timer
var current_chunk : Node3D
var chunks_to_be_deleted : Array[Node]

func _process(delta: float) -> void:
	if not current_chunk:
		_spawn_chunk()
		return
	
	
	if current_chunk.global_rotation_degrees.x > 179:
		chunks_to_be_deleted.append(current_chunk)
		current_chunk = null
	
	if chunks_to_be_deleted.size() > 0:
		for chunk in chunks_to_be_deleted:
			if chunk.global_rotation_degrees.x < 0:
				if chunk.global_rotation_degrees.x > -150:
					chunks_to_be_deleted.erase(chunk)
					chunk.queue_free()
					print("CHUNK ERASED")

func _spawn_chunk() -> void:
	if chunk_queue.size() > 0:
		var chunk = load(chunk_queue.pick_random()).instantiate()
		print("CHUNK ", chunk, " CREATED")
		add_child(chunk)
		chunk.global_rotation_degrees.x = -70
		current_chunk = chunk
