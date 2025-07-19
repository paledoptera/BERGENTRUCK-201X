extends Entity

var speed = 5.0
var h_speed = 0.0
var bullet_owner: Node3D


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	super(delta)
	if global_rotation.x < bullet_owner.global_rotation.x:
		global_rotation.x = bullet_owner.global_rotation.x
	speed = lerp(speed,0.0,5*delta)
	global_position.x += h_speed
	global_rotation.x -= deg_to_rad(speed)
