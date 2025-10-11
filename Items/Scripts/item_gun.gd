extends Item

func _ready():
	if Global.score <= 5: #tutorial
		create_tween().tween_property($CanvasLayer/tutorial,"modulate:a",1,1)

func use() -> void:
	if $DraggableItem/CollisionShape2D.disabled == false:
		$DraggableItem/CollisionShape2D.disabled = true
		rotation = 0
		player.shoot()
		await create_tween().tween_property($DraggableItem/TextureRect,"global_rotation",5,.4).set_trans(Tween.TRANS_SPRING).finished
		queue_free()

func _on_draggable_item_dragging(delta):
	$DraggableItem/TextureRect.global_rotation = 0
	if global_position.y < 80:
		use()
		
