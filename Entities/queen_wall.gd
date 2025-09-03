extends Entity
class_name QueenWall

@export var chases: bool = false
var speed = 0.5
var h_speed = 0.0
var bullet_owner: Node3D
var player: CharacterBody3D
@export var queens: Array[Node]


func _ready() -> void:
	$AnimationPlayer.play(["left","middle","right"].pick_random())
	#if randi_range(1,2) == 2:
		#$AnimationPlayer.play("start")
	#else:
		#$AnimationPlayer.play("startflip")
	global_rotation.x = 0
	

func hit(player):
	super(player)
	if get_node_or_null("EntityContainer/CollisionShape3D2"):
		$EntityContainer/CollisionShape3D2.queue_free()

func _process(delta: float) -> void:
	super(delta)
	global_position.x = 0
	
	#if global_rotation.x < bullet_owner.global_rotation.x:
		#global_rotation.x = bullet_owner.global_rotation.x
	speed -= delta/player.gear
	$AudioStreamPlayer.volume_db = clampf(0.0-abs($EntityContainer/Sprite3D.global_position.z),-999,0.0)
	global_position.x += h_speed
	global_rotation.x -= deg_to_rad(speed)
	
	if not chases:
		return

	var prevpos = $EntityContainer/Sprite3D.position.y
	$EntityContainer/Sprite3D.position.y = lerp($EntityContainer/Sprite3D.position.y,player.get_node("Camera3D").position.y-8,0.15)
	$EntityContainer/Sprite3D.scale.y = 1+abs((player.get_node("Camera3D").position.y-8)-$EntityContainer/Sprite3D.position.y)*0.5


func _on_queen_animation_looped() -> void:
	for i in queens:
		i.flip_h = not i.flip_h
	$AudioStreamPlayer.stream = preload("uid://6a5cybye2b62")
	$AudioStreamPlayer.play()
