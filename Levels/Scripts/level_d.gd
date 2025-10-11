extends Level

var item_index = 0

func _spawn_item() -> void:
	var queue: Array = item_queue_intro.duplicate()
	var pick = wrap(item_index,0,queue.size())
	item_index += 1
	
	
	#_check_stage_progress()
	
	if queue.size() > 0:
		var item_path = queue[pick]
		if not item_path or item_path == "":
			return
		var item = load(item_path)
		if not item:
			return
		var spawn_beam = preload("uid://cy5s1qmefmmj7").instantiate()
		item = item.instantiate()
		print("ITEM ", item, " CREATED")
		entities.add_child(item)
		
		item.global_position.x = 0 #_get_random_item_position()
		item.global_rotation_degrees.x = -152
		if item.beam_on_spawn > 0:
			spawn_beam.get_node("AnimationPlayer").speed_scale = player.speed/10
			$Player/Background.add_child(spawn_beam)
			spawn_beam.base_pos = Vector3(item.get_node("EntityContainer/Sprite3D").global_position.x,-20.0,-40.0)
			spawn_beam.player = player
			spawn_beam.frame = item.beam_on_spawn-1
			if spawn_beam.frame == 3:
				
				var double_beam = spawn_beam.duplicate()
				double_beam.get_node("AnimationPlayer").speed_scale = player.speed/12
				$Player/Background.add_child(double_beam)
				double_beam.base_pos = Vector3(item.get_node("EntityContainer/Sprite3D").global_position.x,-20.0,-40.0)
				double_beam.player = player
				double_beam.frame = item.beam_on_spawn-1
				
