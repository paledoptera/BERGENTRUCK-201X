extends Entity

@export var chases: bool = false
var speed = 5.0
var h_speed = 0.0
var bullet_owner: Node3D
var player: CharacterBody3D

var chestreturn = false
var positionx = 0

var particles = []

func _ready() -> void:
	#global_position.x = player.get_node("Camera3D").global_position.x
	#$EntityContainer.global_position.y = player.get_node("Camera3D").global_position.y-15
	$Timer.start(.05)
	show()
	global_rotation_degrees = Vector3.ZERO
	positionx = global_position.x
	await create_tween().tween_property(self,"position:z",25,.8).finished
	$Timer.queue_free()
	var time = .5
	particles[particles.size()-1].hide()
	for node in particles:
		create_tween().tween_property(node,"position",Vector3(-1.422,39.375,10),time)
		#time -= .05
	chestreturn = true
	await get_tree().create_timer(.55).timeout
	for node in particles:
		node.queue_free()
	$AnimationPlayer.play("fade")
	set_process(false)

func _process(delta: float) -> void:
	super(delta)
	if chestreturn:
		$EntityContainer.global_position = particles[particles.size()-1].global_position + Vector3(0,-5,1)
		#position = position.move_toward(Vector3(0,-20,1),delta*30)
	else:
		global_position.x = positionx
		$EntityContainer.global_position.y = player.get_node("Camera3D").global_position.y-10



func _on_timer_timeout():
	var particle = preload("res://Global/Particles/heartpuff.tscn").instantiate()
	particles.append(particle)
	get_parent().add_child(particle)
	particle.global_position = $EntityContainer/Sprite3D.global_position
