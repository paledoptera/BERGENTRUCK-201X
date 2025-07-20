extends Entity

@export var player : Node3D
var speed: float = 0.0
var screaming = true


func _process(delta: float) -> void:
	speed = lerp(speed,-player.speed,0.04)
	if screaming and $EntityContainer/AnimatedSprite3D.frame < 32:
		player.screenshake_strength = 20
	
	var dist = global_rotation.x+deg_to_rad(35)
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,0.5)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-35),deg_to_rad(12))


func _on_start_timer_timeout() -> void:
	screaming = true
	Audio.play_sfx(preload("uid://cmc4scmp6udct"),1.01)


func _on_animated_sprite_3d_animation_finished() -> void:
	var knight = preload("uid://p7xe4agr330n").instantiate() # knight.tscn
	get_parent().add_child(knight)
	knight.global_position.x = global_position.x
	knight.global_rotation = global_rotation
	knight.player = player
	knight.entities = get_parent()
	Audio.play_music(preload("uid://fu6rkj8mk5r5"),false,false) # Black Knife.ogg
	queue_free()
