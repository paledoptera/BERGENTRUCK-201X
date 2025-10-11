extends Entity

@export var chases: bool = false
@export var speed = 5.0
var h_speed = 0.0
@export var bullet_owner: Node3D
@export var entity_container: Node
var player: CharacterBody3D


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	super(delta)
	if global_rotation.x < bullet_owner.global_rotation.x:
		global_rotation.x = bullet_owner.global_rotation.x
	speed = lerp(speed,0.0,5*delta)
	global_position.x += h_speed
	global_rotation.x -= deg_to_rad(speed)
	
	if not chases:
		return

	var prevpos = $EntityContainer/Sprite3D.position.y
	$EntityContainer/Sprite3D.position.y = lerp($EntityContainer/Sprite3D.position.y,player.get_node("Camera3D").position.y-8,0.15)
	$EntityContainer/Sprite3D.scale.y = 1+abs((player.get_node("Camera3D").position.y-8)-$EntityContainer/Sprite3D.position.y)*0.5
