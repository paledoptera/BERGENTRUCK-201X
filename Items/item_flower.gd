extends Item

func _ready() -> void:
	super()
	if Global.level == 2:
		score_amount = 2
	if Global.level == 3 or Global.level == 7:
		score_amount = 0

func use() -> void:
	if Global.level == 3 or Global.level == 7:
		if Global.modifiers.DrunkMode == false:
			player.hp = min(player.hp+10,player.max_hp)
		else:
			player.hp = min(player.hp+max(1,10-player.drunkness/3),player.max_hp)
		queue_free()
	else:
		super()
