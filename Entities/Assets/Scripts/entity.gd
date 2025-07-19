extends Node3D
class_name Entity


@export var hp = -1
@export var items : Array[ItemDropData]
@export var solid : bool = true
@export var stompable : bool = false
@export var damage : float = 0.0
@export var car_jump_mult : float = 1.0
@export var collision_shape : CollisionShape3D
@export var pixel_size : float = 0.06
@export var hit_sound_impact : AudioStream
@export var hit_sound_effect : AudioStream
@export var disable_collision_on_hit : bool = false

func _ready() -> void:
	var rand_scale = randf_range(0.8,1.2)
	$EntityContainer/Sprite3D.pixel_size = pixel_size*rand_scale
	$EntityContainer/Sprite3D.flip_h = [true,false].pick_random()
	damage *= rand_scale
	car_jump_mult *= rand_scale
	#if collision_shape:
		#collision_shape.scale *= Vector3(rand_scale,rand_scale,rand_scale)
	
func _process(delta: float) -> void:
	if $EntityContainer/Sprite3D.global_position.y < -30.0:
		queue_free()

func hit(player) -> void:
	if disable_collision_on_hit and collision_shape:
		collision_shape.queue_free()
	if stompable:
		queue_free()
