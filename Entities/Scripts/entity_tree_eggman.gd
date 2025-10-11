extends "res://Entities/Scripts/entity_tree.gd"

func _ready() -> void:
	super()
	$EntityContainer/AnimatedSprite3D.flip_h = [true,false].pick_random()
