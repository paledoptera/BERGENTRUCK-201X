extends Item

func _ready() -> void:
	super()
	if Global.level == 2:
		score_amount = 2
	if Global.level == 3:
		score_amount = 0

func use() -> void:
	if Global.level == 3:
		player.hp = min(player.hp+10,100)
		queue_free()
	else:
		super()
