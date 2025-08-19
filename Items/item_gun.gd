extends Item

func use() -> void:
	player.shoot()
	queue_free()

func _on_draggable_item_dragging(delta):
	use()
