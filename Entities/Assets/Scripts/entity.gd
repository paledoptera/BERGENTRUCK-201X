extends Area3D
class_name Entity


@export var hp = -1
@export var items : Array[ItemDropData]
@export var solid : bool = true
@export var stompable : bool = false
@export var damage : float = 0.0
@export var collision_shape : CollisionShape3D
