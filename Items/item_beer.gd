extends Item

func _ready():
	super()
	if Global.modifiers.DrunkMode:
		set_collision_mask_value(3,true)
		if Global.score > 0:
			queue_free()

func use() -> void:
	if Global.modifiers.DrunkMode:
		if $DraggableItem.drag:
			player.drunkness = max(player.drunkness-1,0)
			lifetime = 0.1
	elif Global.level == 3 or Global.level == 7:
		player.hp = min(player.hp+10,100)
		player.TURN_ACCELERATION += 1
		queue_free()
	else:
		super()
	
