extends Node2D

@export var sprite : Sprite2D

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
