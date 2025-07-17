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
@export var delete_on_loop_around : bool = true
@export var disable_collision_on_hit : bool = false

func _ready() -> void:
	$EntityContainer/Sprite3D.pixel_size = pixel_size

func _process(delta: float) -> void:
	if not delete_on_loop_around:
		return
	
	if $EntityContainer/Sprite3D.global_position.y < -30.0:
		queue_free()
	#$EntityContainer/Sprite3D.sorting_offset = -global_position.z*5
	#if $EntityContainer/Sprite3D.global_position.z > 0.0:
		#$EntityContainer/Sprite3D.no_depth_test = true
	#else:
		#$EntityContainer/Sprite3D.no_depth_test = false

func hit(player) -> void:
	if disable_collision_on_hit and collision_shape:
		collision_shape.queue_free()
	#$HitSoundImpact.play()
	#$HitSoundEffect.play()
	#player
	#rotation_degrees.x -= 20
