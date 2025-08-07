extends "res://UI/level_icon.gd"
class_name Bonus

@export var special_val: String
@export var click_sound: AudioStream

func _ready() -> void:
	$Sprite2D/RichTextLabel.text = special_val
	
	#if Global.player_save.flags.get("levels_unlocked")[value-1]:
		#unlocked = true
		#$Sprite2D.frame = value-1
	#else:
		#$Sprite2D.frame = 3
	
	#if Global.player_save.flags.get("levels_beaten")[value-1]:
		#$Sprite2D/TickMark.visible = true
