extends "res://Entities/entity_tree.gd"

@export var sprite : Sprite3D
@export var sprite_2 : Sprite3D


func _ready() -> void:
	var rand_scale = randf_range(0.8,1.2)
	$EntityContainer/Sprite3D.pixel_size = pixel_size*rand_scale
	$EntityContainer/Sprite3D.flip_h = [true,false].pick_random()
	damage *= rand_scale
	car_jump_mult *= rand_scale
	sprite_2.global_position.x = -sprite.global_position.x
	sprite_2.texture = sprite.texture
	sprite_2.flip_h = not sprite.flip_h
