extends Entity

@export var player : Node
var speed = 0.0
var speed_acc = 0.1


func _process(delta: float) -> void:
	
	speed = lerp(speed,-1.0,speed_acc)
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,0.2)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-30),deg_to_rad(12))
	if global_rotation_degrees.x >= 11:
		speed = -2.5
		speed_acc = 0.0001
	if speed_acc < 0.1:
		speed_acc *= 1.01
	pass
	#speed = lerp(speed,float(player.car_velocity.z),0.1)
	#global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,0.1)
	#rotation.x -= float(speed)
	#rotation_degrees.x -= 1
	#rotation.x -= deg_to_rad(0.01)
	
	
