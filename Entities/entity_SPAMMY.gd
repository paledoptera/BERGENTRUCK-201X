extends Entity

@export var player : Node3D
@export var level: Node3D
var running = true
var scream = false
var speed: float = 0.0

func _ready() -> void:
	global_position = player.global_position


func _process(delta: float) -> void:
	speed = lerp(speed,-1.0,0.04)
	
	var dist = global_rotation.x+deg_to_rad(35)
	
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,0.2)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-35),deg_to_rad(12))


func hit(player) -> void:
	Audio.play_sfx(preload("res://Global/SFX/spamton-laugh.mp3"),1.01)
	var knight = preload("res://Entities/spamton.tscn").instantiate() # entity.knightintro.tscn
	get_parent().add_child(knight)
	knight.entities = $".."
	knight.global_rotation = global_rotation
	knight.player = player
	
	level.flash()
	set_process(false)
	for node in get_children():
		node.queue_free()
	player.get_node("Camera3D").size = .01
	Audio.stop_music(false)
	await get_tree().create_timer(3).timeout
	Audio.play_music(preload("res://Global/Music/BIG SHOT.mp3"),false,false)
	queue_free()
