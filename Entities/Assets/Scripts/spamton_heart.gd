extends Entity

@export var chases: bool = false
var speed = 5.0
var h_speed = 0.0
var bullet_owner: Node3D
var player: CharacterBody3D


func _ready() -> void:
	hide()
	await get_tree().create_timer(.5).timeout
	global_position.x = player.get_node("Camera3D").global_position.x
	#$EntityContainer.global_position.y = player.get_node("Camera3D").global_position.y-15
	$Timer.start(.05)
	show()

func _process(delta: float) -> void:
	print(bullet_owner.global_position)
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


func _on_timer_timeout():
	var particle = preload("res://Global/Particles/heartpuff.tscn").instantiate()
	get_parent().get_parent().add_child(particle)
	particle.global_position = $EntityContainer/Sprite3D.global_position
