extends Item

func use() -> void:
	if Global.level == 3 or Global.level == 6:
		player.hp = min(player.hp+10,100)
		player.TURN_ACCELERATION += 1
		queue_free()
	else:
		super()
