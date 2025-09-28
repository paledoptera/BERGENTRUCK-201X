extends TextureRect

@export var ID = 0
@export var never_locked = false
@export var fresheners = false
@export var selected_icon = preload("res://Levels/Assets/Visuals/bobbles/kris.png")
var unlocked = true

func _ready():
	$Sprite2D.frame = ID+2
	if fresheners:
		$Sprite2D.texture = preload("uid://c654dk2d2ndik") #freshener_icons.png
	#if Global.player_save.flags.skins_unlocked[ID] == false and never_locked == false: #if not unlocked
	#	unlocked = false
	#	$Sprite2D.frame = 1
