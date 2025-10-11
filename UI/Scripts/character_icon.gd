extends TextureRect

@export var ID = 0
@export var never_locked = false
var unlocked = true
@export_multiline var description = ""
@export_multiline var locked_description = ""

func _ready():
	$Sprite2D.frame = ID+2
	if Global.player_save.flags.skins_unlocked[ID] == false and never_locked == false: #if not unlocked
		unlocked = false
		$Sprite2D.frame = 1
