extends "res://Entities/entity_tree.gd"

@export var sprite : Sprite3D
@export var sprite_2 : Sprite3D


func _ready() -> void:
	super()
	sprite_2.global_position.x = -sprite.global_position.x
	sprite_2.texture = sprite.texture
	sprite_2.flip_h = not sprite.flip_h
