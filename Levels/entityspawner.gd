extends Node3D

@export_file var chunk_queue: Array[String]
@export var timer : Timer
@export var player : Node3D
var current_chunk : Node3D
var last_chunk : String
var chunks_to_be_deleted : Array[Node]

func _process(delta: float) -> void:
	if not current_chunk:
		_spawn_chunk()
		return
	
	
	if current_chunk.global_rotation_degrees.x > 100:
		chunks_to_be_deleted.append(current_chunk)
		current_chunk = null
	
	if chunks_to_be_deleted.size() > 0:
		for chunk in chunks_to_be_deleted:
			chunk.life_time -= (player.speed/10)*delta
			if chunk.life_time <= 0:
				chunks_to_be_deleted.erase(chunk)
				chunk.queue_free()
				print("CHUNK ERASED")

func _spawn_chunk() -> void:
	
	var queue = chunk_queue.duplicate()
	if last_chunk:
		queue.erase(last_chunk)
	
	if queue.size() > 0:
		last_chunk = queue.pick_random()
		var chunk = load(last_chunk).instantiate()
		print("CHUNK ", chunk, " CREATED")
		add_child(chunk)
		chunk.global_rotation_degrees.x = -70
		current_chunk = chunk
