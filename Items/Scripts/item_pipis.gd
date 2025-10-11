extends Item

func _ready():
	if randi_range(1,100) == 97:
		$DraggableItem/TextureRect.texture = preload("uid://3hug78wjwykg") #MsPipis.png
	if player.hp < 100:
		$pipistext.hide()
	else:
		create_tween().tween_property($pipistext,"modulate:a",0,1)

func use() -> void:
	pass

func _on_explode_timeout():
	player.hp -= 15
	var particle = preload("uid://dcqkfrrrjrodp").instantiate()
	add_sibling(particle)
	Audio.play_sfx(preload("uid://db5f8ibsxoiwt"),2,10)
	particle.emitting = true
	particle.global_position = global_position
	queue_free()
