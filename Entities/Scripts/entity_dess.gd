extends Entity

@export var player : Node3D
@export var level: Node3D
var running = false
var scream = false
var speed: float = 0.0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if not running:
		if not scream and global_rotation.x > deg_to_rad(-10):
			scream = true
			Audio.play_sfx(preload("uid://x8hcmkbyjaih"),1.01)
			$EntityContainer/AnimatedSprite3D.play("scream")
		if global_rotation.x > 0:
			speed = -4
			running = true
			$EntityContainer/AnimatedSprite3D.play("run")
			Audio.play_music(preload("uid://dnc5v8nomkpkc"),false,false)
		else:
			return
			
	speed = lerp(speed,-1.0,0.04)
	
	var dist = global_rotation.x+deg_to_rad(35)
	
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,0.2)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-35),deg_to_rad(12))


func hit(player) -> void:
	Audio.play_sfx(preload("uid://5r2sxx3bimdf"),1.01)
	var knight = preload("uid://fysnkkrqt4d1").instantiate() # entity.knightintro.tscn
	get_parent().add_child(knight)
	knight.global_rotation = global_rotation
	knight.player = player

	var tween = player.create_tween()
	tween.set_parallel(true)
	tween.tween_property(player.get_node("Camera3D"),"size",.008,2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	level.flash()
	Audio.stop_music(false)
	Audio.play_sfx(preload("uid://ge82chjg4nmx"),1.01,0)
	queue_free()
