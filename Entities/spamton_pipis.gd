extends Entity

@export var chases: bool = false
var speed = 5.0
var h_speed = 0.0
var bullet_owner: Node3D
var player: CharacterBody3D


func _process(delta: float) -> void:
	$EntityContainer/Sprite3D.rotation.z += 5*delta
	if h_speed == 0:
		h_speed += randf_range(-.1,.1)
	super(delta)
	$EntityContainer.position.x = move_toward($EntityContainer.position.x,0,delta*8)
	if global_rotation.x < bullet_owner.global_rotation.x:
		global_rotation.x = bullet_owner.global_rotation.x
	speed = lerp(speed,0.0,5*delta)
	global_position.x += h_speed
	#position.y -= 10*delta
	global_rotation.x -= deg_to_rad(speed)
