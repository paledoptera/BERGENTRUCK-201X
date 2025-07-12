extends Node3D
class_name Entity


@export var hp = -1
@export var items : Array[ItemDropData]
@export var solid : bool = true
@export var stompable : bool = false
@export var damage : float = 0.0
@export var collision_shape : CollisionShape3D

func _process(delta: float) -> void:
	#$EntityContainer/Sprite3D.sorting_offset = -global_position.z*5
	if $EntityContainer/Sprite3D.global_position.z > 0.0:
		$EntityContainer/Sprite3D.no_depth_test = true
	else:
		$EntityContainer/Sprite3D.no_depth_test = false
