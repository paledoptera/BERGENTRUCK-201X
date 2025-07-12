extends Node3D
class_name Chunk

func _ready() -> void:
	_correct_sprite_size(self)

func _correct_sprite_size(object: Node) -> void:
	var children = object.get_children()
	
	for child in children:
		if child.get_child_count() > 0:
			_correct_sprite_size(child)
		if child is Sprite3D:
			child.pixel_size = 0.06
		
