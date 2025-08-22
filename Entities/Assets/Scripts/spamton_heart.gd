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
	var time = .34
	for node in particles:
		create_tween().tween_property(node,"position",Vector3(-1.422,29.375,15.581),time).set_trans(Tween.TRANS_SINE)
		#time -= .05
	var tween = create_tween()
	tween.tween_property(self,"position",Vector3(-1.2,7.6,16.2),.6)
	await get_tree().create_timer(.1).timeout
	chestreturn = true
	await get_tree().create_timer(.4).timeout
	for node in particles:
		node.queue_free()
	queue_free()

func _process(delta: float) -> void:
	super(delta)
	if chestreturn:
		$EntityContainer.position.y = 20
		#position = position.move_toward(Vector3(0,-20,1),delta*30)
	else:
		global_position.x = positionx
		$EntityContainer.global_position.y = player.get_node("Camera3D").global_position.y-10



func _on_timer_timeout():
	var particle = preload("res://Global/Particles/heartpuff.tscn").instantiate()
	particles.append(particle)
	get_parent().add_child(particle)
	particle.global_position = $EntityContainer/Sprite3D.global_position
